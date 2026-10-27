import SwiftUI

struct JourneyProgressView: View {
    let journey: Journey
    let explorer: Explorer
    let progress: ExplorerProgress
    let catalog: [Pin]

    @EnvironmentObject var apiService: APIService

    private var journeyPins: [Pin] {
        catalog.filter { $0.journey == journey }
    }

    private var earnedPins: [Pin] {
        journeyPins.filter {
            let status = progress.pinStatus(for: $0.name)
            return status == .earned || status == .issued
        }
    }

    private var openPins: [Pin] {
        journeyPins.filter {
            let status = progress.pinStatus(for: $0.name)
            return status == .open || status == .notStarted
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Journey header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: journeyIcon)
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(journeyColor)
                            .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(journey.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("\(earnedPins.count) / \(journeyPins.count) earned")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if progress.rockers[journey] == true {
                            VStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title2)
                                Text("Rocker")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    ProgressView(value: Double(earnedPins.count), total: Double(journeyPins.count))
                        .tint(journeyColor)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Earned pins section
                if !earnedPins.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("EARNED (\(earnedPins.count))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        ForEach(earnedPins) { pin in
                            NavigationLink(destination: PinDetailView(pin: pin, explorer: explorer)) {
                                PinProgressCard(
                                    pin: pin,
                                    status: progress.pinStatus(for: pin.name),
                                    journeyColor: journeyColor
                                )
                            }
                        }
                    }
                }

                // Pins to do section
                if !openPins.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TO DO (\(openPins.count))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        ForEach(openPins) { pin in
                            NavigationLink(destination: PinDetailView(pin: pin, explorer: explorer)) {
                                PinProgressCard(
                                    pin: pin,
                                    status: progress.pinStatus(for: pin.name),
                                    journeyColor: journeyColor
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // Journey-specific colors
    private var journeyColor: Color {
        switch journey {
        case .north: return Color.blue
        case .east: return Color.green
        case .south: return Color.orange
        case .west: return Color.purple
        }
    }

    // Journey-specific icons
    private var journeyIcon: String {
        switch journey {
        case .north: return "house.fill"
        case .east: return "leaf.fill"
        case .south: return "building.2.fill"
        case .west: return "star.fill"
        }
    }
}

struct PinProgressCard: View {
    let pin: Pin
    let status: PinStatus
    let journeyColor: Color

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pin.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                if let supervision = pin.supervision {
                    Text(supervision)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Status badge
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.15))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private var statusColor: Color {
        switch status {
        case .issued: return .blue
        case .earned: return .green
        case .submitted: return .orange
        case .open, .notStarted: return .gray
        }
    }

    private var statusIcon: String {
        switch status {
        case .issued: return "checkmark.circle.fill"
        case .earned: return "checkmark.circle"
        case .submitted: return "clock.fill"
        case .open, .notStarted: return "circle"
        }
    }
}

#Preview {
    NavigationView {
        JourneyProgressView(
            journey: .west,
            explorer: Explorer(circle: "Vikings", lastName: "Yoon", firstName: "Rocky", adventureName: "Stinger"),
            progress: ExplorerProgress(
                explorer: Explorer(circle: "Vikings", lastName: "Yoon", firstName: "Rocky", adventureName: "Stinger"),
                pins: ["Knife Safety": .issued, "Knots": .earned, "Fire Safety": .open],
                rockers: [.west: false],
                hasMedallion: false,
                submissions: []
            ),
            catalog: PinCatalog.all
        )
        .environmentObject(APIService.shared)
    }
}
