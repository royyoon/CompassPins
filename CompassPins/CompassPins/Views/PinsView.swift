import SwiftUI

struct PinsView: View {
    @EnvironmentObject var apiService: APIService
    @State private var catalog: [Pin] = []
    @State private var selectedJourney: Journey = .west
    @State private var searchText = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search all 26 pins", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                // Journey selector
                journeySelector

                // Pins list
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredPins) { pin in
                                NavigationLink(destination: PinDetailView(pin: pin, explorer: nil)) {
                                    PinRow(pin: pin)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Pins")
            .task {
                await loadCatalog()
            }
        }
    }

    private var journeySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Journey.allCases, id: \.self) { journey in
                    Button(action: {
                        selectedJourney = journey
                    }) {
                        VStack(spacing: 4) {
                            Text(journey.direction)
                                .font(.caption)
                            Text(journey.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            selectedJourney == journey ?
                            Color.green : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(
                            selectedJourney == journey ? .white : .primary
                        )
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }

    private var filteredPins: [Pin] {
        var pins = catalog.filter { $0.journey == selectedJourney }

        if !searchText.isEmpty {
            pins = catalog.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return pins
    }

    private func loadCatalog() async {
        // Load from local catalog - no API call needed
        await MainActor.run {
            catalog = PinCatalog.all
            isLoading = false
        }
    }
}

struct PinRow: View {
    let pin: Pin

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(pin.name)
                .font(.headline)
                .foregroundColor(.primary)

            if let supervision = pin.supervision {
                HStack {
                    if supervision.contains("Adult supervision") {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                    Text(supervision)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    PinsView()
        .environmentObject(APIService.shared)
}
