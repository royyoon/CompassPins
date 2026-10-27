import SwiftUI

struct CircleView: View {
    @EnvironmentObject var apiService: APIService
    @State private var selectedTab = 0
    @State private var submissions: [Submission] = []
    @State private var explorersProgress: [ExplorerProgress] = []
    @State private var selectedCircle: String?
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                // Circle selector for multi-circle admins
                if let circles = availableCircles, circles.count > 1 {
                    Picker("Circle", selection: $selectedCircle) {
                        ForEach(circles, id: \.self) { circle in
                            Text(circle).tag(circle as String?)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }

                // Tabs: To review / To hand out
                Picker("Queue", selection: $selectedTab) {
                    Text("To review · \(submissionsToReview.count)").tag(0)
                    Text("To hand out · \(pinsToHandOut.count)").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    if selectedTab == 0 {
                        reviewQueueView
                    } else {
                        handOutQueueView
                    }
                }
            }
            .navigationTitle("Circle")
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
        }
    }

    private var availableCircles: [String]? {
        // TODO: Get from API or extract from explorers
        ["Buccaneers", "Vikings", "Outlaws", "Rough Riders", "Creek", "Hawks"]
    }

    private var submissionsToReview: [Submission] {
        submissions.filter { $0.status == .submitted }
    }

    private var pinsToHandOut: [(Explorer, String)] {
        var pins: [(Explorer, String)] = []
        for progress in explorersProgress {
            for (pinName, status) in progress.pins where status == .earned {
                pins.append((progress.explorer, pinName))
            }
        }
        return pins
    }

    private var reviewQueueView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if submissionsToReview.isEmpty {
                    Text("No submissions to review")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(submissionsToReview) { submission in
                        SubmissionReviewCard(submission: submission) {
                            await loadData()
                        }
                    }
                }
            }
            .padding()
        }
    }

    private var handOutQueueView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if pinsToHandOut.isEmpty {
                    Text("No pins to hand out")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(pinsToHandOut, id: \.1) { explorer, pinName in
                        HandOutPinCard(explorer: explorer, pinName: pinName) {
                            await loadData()
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func loadData() async {
        isLoading = true

        do {
            let progress = try await apiService.getProgress(circle: selectedCircle)
            // TODO: Load submissions from API

            await MainActor.run {
                explorersProgress = progress
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

struct SubmissionReviewCard: View {
    let submission: Submission
    let onUpdate: () async -> Void

    @EnvironmentObject var apiService: APIService
    @State private var isProcessing = false
    @State private var showSendBackSheet = false
    @State private var sendBackNote = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(submission.pin)
                .font(.headline)

            Text("\(submission.firstName) \(submission.lastName) · by \(submission.submittedBy)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let note = submission.note, !note.isEmpty {
                Text("\"\(note)\"")
                    .font(.callout)
                    .italic()
                    .padding(.vertical, 4)
            }

            Text(submission.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button("Ask for more") {
                    showSendBackSheet = true
                }
                .buttonStyle(.bordered)
                .disabled(isProcessing)

                Button("Approve") {
                    Task {
                        await approve()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showSendBackSheet) {
            NavigationView {
                Form {
                    Section("Ask for more info") {
                        TextField("What do you need?", text: $sendBackNote, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                .navigationTitle("Send Back")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showSendBackSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Send") {
                            Task {
                                await sendBack()
                            }
                        }
                        .disabled(sendBackNote.isEmpty)
                    }
                }
            }
        }
    }

    private func approve() async {
        isProcessing = true

        do {
            try await apiService.reviewSubmission(
                circle: submission.circle,
                lastName: submission.lastName,
                firstName: submission.firstName,
                pin: submission.pin,
                approve: true
            )

            await onUpdate()
        } catch {
            // Handle error
        }

        isProcessing = false
    }

    private func sendBack() async {
        isProcessing = true

        do {
            try await apiService.reviewSubmission(
                circle: submission.circle,
                lastName: submission.lastName,
                firstName: submission.firstName,
                pin: submission.pin,
                approve: false,
                note: sendBackNote
            )

            showSendBackSheet = false
            await onUpdate()
        } catch {
            // Handle error
        }

        isProcessing = false
    }
}

struct HandOutPinCard: View {
    let explorer: Explorer
    let pinName: String
    let onUpdate: () async -> Void

    @EnvironmentObject var apiService: APIService
    @State private var isProcessing = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(pinName)
                    .font(.headline)
                Text("\(explorer.firstName) \(explorer.lastName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Mark handed out") {
                Task {
                    await markIssued()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isProcessing)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }

    private func markIssued() async {
        isProcessing = true

        do {
            let pinToIssue = PinToIssue(
                circle: explorer.circle,
                lastName: explorer.lastName,
                firstName: explorer.firstName,
                pin: pinName
            )

            try await apiService.issuePins(pins: [pinToIssue])
            await onUpdate()
        } catch {
            // Handle error
        }

        isProcessing = false
    }
}

#Preview {
    CircleView()
        .environmentObject(APIService.shared)
}
