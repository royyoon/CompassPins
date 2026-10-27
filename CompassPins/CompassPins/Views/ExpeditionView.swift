import SwiftUI

struct ExpeditionView: View {
    @EnvironmentObject var apiService: APIService

    var body: some View {
        NavigationView {
            List {
                Section("CIRCLES") {
                    ForEach(circles, id: \.name) { circle in
                        NavigationLink(destination: CircleDetailView(circleName: circle.name)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(circle.name)
                                    .font(.headline)
                                Text("\(circle.earned) earned · \(circle.toHandOut) to hand out · \(circle.toReview) to review")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section("MANAGE") {
                    NavigationLink(destination: PinCatalogView()) {
                        HStack {
                            Text("Pin catalog · 26 pins")
                            Spacer()
                            Text("3 to confirm")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button("Import Circle spreadsheet") {
                        // TODO: Implement spreadsheet import
                    }

                    NavigationLink(destination: Text("Pin Inventory")) {
                        HStack {
                            Text("Pin inventory")
                            Spacer()
                            Text("Release 3")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Broken Arrow")
        }
    }

    private var circles: [(name: String, earned: Int, toHandOut: Int, toReview: Int)] {
        // TODO: Get real data from API
        [
            ("Vikings", 12, 5, 3),
            ("Buccaneers", 8, 2, 1),
            ("Outlaws", 15, 7, 4),
            ("Rough Riders", 10, 3, 2),
            ("Creek", 6, 1, 0),
            ("Hawks", 14, 6, 5)
        ]
    }
}

struct CircleDetailView: View {
    let circleName: String

    var body: some View {
        Text("Circle detail for \(circleName)")
            .navigationTitle(circleName)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PinCatalogView: View {
    @EnvironmentObject var apiService: APIService
    @State private var catalog: [Pin] = []
    @State private var isLoading = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                List(catalog) { pin in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pin.name)
                            .font(.headline)
                        HStack {
                            Text(pin.journey.displayName)
                            Text("·")
                            if let supervision = pin.supervision {
                                Text(supervision)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Pin Catalog")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadCatalog()
        }
    }

    private func loadCatalog() async {
        isLoading = true

        do {
            let fetchedCatalog = try await apiService.getCatalog()
            await MainActor.run {
                catalog = fetchedCatalog
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    ExpeditionView()
        .environmentObject(APIService.shared)
}
