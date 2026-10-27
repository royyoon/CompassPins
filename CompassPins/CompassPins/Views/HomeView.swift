import SwiftUI

struct HomeView: View {
    @EnvironmentObject var apiService: APIService
    @State private var explorersProgress: [ExplorerProgress] = []
    @State private var catalog: [Pin] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedExplorer: Explorer?
    @State private var hasLoadedInitialData = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Explorer selector (if multiple children)
                    if let children = apiService.currentUser?.children, children.count > 1 {
                        explorerSelector(children: children)
                    }

                    if let progress = currentExplorerProgress {
                        // Compass progress cards
                        compassProgressView(progress: progress)

                        // Waiting on Pin Wizard
                        waitingSection(progress: progress)

                        // Pins to collect
                        pinsToCollectSection(progress: progress)

                        // Next up
                        nextUpSection(progress: progress)
                    } else if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Loading...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else if explorersProgress.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)

                            Text("No Progress Found")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("We couldn't find your explorer record. Please contact your Circle's Pin Wizard to get set up.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)

                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        signOut()
                    }
                }
            }
            .task {
                if !hasLoadedInitialData {
                    await loadData()
                    hasLoadedInitialData = true
                }
            }
            .refreshable {
                await loadData(forceRefresh: true)
            }
        }
    }

    // MARK: - Computed Properties

    private var navigationTitle: String {
        if let child = selectedExplorer ?? apiService.currentUser?.children?.first {
            return child.displayName
        }
        return "Home"
    }

    private var currentExplorerProgress: ExplorerProgress? {
        guard let child = selectedExplorer ?? apiService.currentUser?.children?.first else {
            return nil
        }
        return explorersProgress.first { $0.explorer.id == child.id }
    }

    // MARK: - Subviews

    private func explorerSelector(children: [Explorer]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(children) { child in
                    Button(action: {
                        selectedExplorer = child
                    }) {
                        VStack {
                            Text(child.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(child.circle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            selectedExplorer?.id == child.id || (selectedExplorer == nil && child.id == children.first?.id) ?
                            Color.green : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(
                            selectedExplorer?.id == child.id || (selectedExplorer == nil && child.id == children.first?.id) ?
                            .white : .primary
                        )
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func compassProgressView(progress: ExplorerProgress) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(progress.explorer.circle)
                .font(.headline)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(Journey.allCases, id: \.self) { journey in
                    NavigationLink(destination: JourneyProgressView(
                        journey: journey,
                        explorer: progress.explorer,
                        progress: progress,
                        catalog: catalog
                    )) {
                        JourneyCard(
                            journey: journey,
                            progress: progress.journeyProgress(for: journey, allPins: catalog),
                            hasRocker: progress.rockers[journey] ?? false
                        )
                    }
                }
            }
        }
    }

    private func waitingSection(progress: ExplorerProgress) -> some View {
        Group {
            if !progress.submissions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("WAITING ON THE PIN WIZARD")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    ForEach(progress.submissions.filter { $0.status == .submitted }) { submission in
                        SubmissionCard(submission: submission)
                    }
                }
            }
        }
    }

    private func pinsToCollectSection(progress: ExplorerProgress) -> some View {
        Group {
            let earnedPins = progress.pins.filter { $0.value == .earned }

            if !earnedPins.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("EARNED — PIN TO COLLECT")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    ForEach(catalog.filter { earnedPins.keys.contains($0.name) }) { pin in
                        EarnedPinCard(pin: pin)
                    }
                }
            }
        }
    }

    private func nextUpSection(progress: ExplorerProgress) -> some View {
        Group {
            let openPins = catalog.filter { progress.pinStatus(for: $0.name) == .open || progress.pinStatus(for: $0.name) == .notStarted }

            if !openPins.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("NEXT UP")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Spacer()

                        NavigationLink("All pins") {
                            PinsView()
                        }
                        .font(.caption)
                    }

                    ForEach(openPins.prefix(3)) { pin in
                        NavigationLink(destination: PinDetailView(pin: pin, explorer: progress.explorer)) {
                            NextUpPinCard(pin: pin)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func loadData(forceRefresh: Bool = false) async {
        isLoading = true
        errorMessage = nil

        // Load catalog from local data
        catalog = PinCatalog.all

        // Debug: Print user info
        print("👤 Current user: \(apiService.currentUser?.email ?? "none")")
        print("🔐 User role: \(apiService.currentUser?.role.rawValue ?? "none")")
        print("👶 Children: \(apiService.currentUser?.children?.count ?? 0)")

        do {
            // Load progress from API (uses cache by default, force refresh on pull-to-refresh)
            let fetchedProgress = try await apiService.getProgress(forceRefresh: forceRefresh)

            await MainActor.run {
                explorersProgress = fetchedProgress

                // Debug logging
                print("✅ Loaded \(fetchedProgress.count) explorer(s)")
                for progress in fetchedProgress {
                    print("  - \(progress.explorer.firstName) \(progress.explorer.lastName) (\(progress.explorer.circle))")
                    print("    Pins: \(progress.pins.count)")
                }

                isLoading = false
            }
        } catch {
            await MainActor.run {
                print("❌ Error loading progress: \(error)")
                // Only show technical error details, the UI will show the friendly message
                if let apiError = error as? APIServiceError {
                    errorMessage = apiError.errorDescription
                } else {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        }
    }

    private func signOut() {
        apiService.clearAuth()
        // Force navigation back to auth screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(
                    rootView: AuthenticationView(isSignedIn: .constant(false))
                        .environmentObject(apiService)
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct JourneyCard: View {
    let journey: Journey
    let progress: (earned: Int, total: Int)
    let hasRocker: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(journey.direction)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if hasRocker {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }

            Text(journey.displayName)
                .font(.headline)

            Text("\(progress.earned) / \(progress.total)")
                .font(.title2)
                .fontWeight(.bold)

            ProgressView(value: Double(progress.earned), total: Double(progress.total))
                .tint(.green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SubmissionCard: View {
    let submission: Submission

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(submission.pin)
                .font(.headline)
            Text("Submitted \(submission.timestamp.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.orange.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
        )
    }
}

struct EarnedPinCard: View {
    let pin: Pin

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(pin.name)
                .font(.headline)
            Text("Approved — pick up at next Circle meeting")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
}

struct NextUpPinCard: View {
    let pin: Pin

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(pin.name)
                .font(.headline)
                .foregroundColor(.primary)
            Text("\(pin.journey.direction) · \(pin.supervision ?? "No supervision info")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    HomeView()
        .environmentObject(APIService.shared)
}
