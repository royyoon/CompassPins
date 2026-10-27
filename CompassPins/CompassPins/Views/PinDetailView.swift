import SwiftUI

struct PinDetailView: View {
    let pin: Pin
    let explorer: Explorer?

    @EnvironmentObject var apiService: APIService
    @State private var showingSubmitSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Pin header with colorful journey badge
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: journeyIcon)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(journeyColor)
                            .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(pin.journey.displayName)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(journeyColor)
                            Text(pin.name)
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        Spacer()

                        statusBadge
                    }
                }

                // Supervision warning
                if let supervision = pin.supervision {
                    supervisionWarning(supervision)
                }

                // What to do
                if let requirements = pin.requirements {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WHAT TO DO")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Text(requirements)
                            .font(.body)
                    }
                }

                // Examples
                if let examples = pin.examples {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(journeyColor)
                            Text("EXAMPLES & IDEAS")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(journeyColor)
                        }

                        Text(examples)
                            .font(.body)
                            .padding()
                            .background(journeyColor.opacity(0.08))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(journeyColor.opacity(0.2), lineWidth: 1)
                            )
                    }
                }

                // Image (local image from Resources folder)
                if let imageURL = pin.imageURL {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(journeyColor)
                            Text("VISUAL GUIDE")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(journeyColor)
                        }
                        .padding(.horizontal)

                        // Load image from Resources folder based on journey
                        let imagePath = "\(pin.journey.rawValue)/\(imageURL)"

                        if let uiImage = loadImageFromResources(imagePath: imagePath) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .background(journeyColor.opacity(0.1))
                                .cornerRadius(16)
                                .shadow(color: journeyColor.opacity(0.3), radius: 8, x: 0, y: 4)
                                .padding(.horizontal)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 250)
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("Image not found")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // How it's earned
                VStack(alignment: .leading, spacing: 8) {
                    Text("HOW IT'S EARNED")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Text("You submit it here → your Circle's Pin Wizard approves → pin handed out at a meeting.")
                        .font(.body)
                }

                Spacer()

                // Submit button (only for parents with explorer)
                if apiService.currentUser?.role == .parent, let explorer = explorer, pin.status != .earned && pin.status != .issued {
                    VStack(spacing: 8) {
                        Text("Ready to submit?")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button(action: {
                            showingSubmitSheet = true
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                Text("Submit for Approval")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [journeyColor, journeyColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: journeyColor.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSubmitSheet) {
            if let explorer = explorer {
                SubmitPinView(pin: pin, explorer: explorer)
            }
        }
    }

    private var statusBadge: some View {
        Group {
            if pin.status != .notStarted && pin.status != .open {
                HStack {
                    Circle()
                        .fill(pin.status == .earned ? Color.green : pin.status == .issued ? Color.blue : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(pin.status.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
    }

    private func supervisionWarning(_ supervision: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(supervision + " required")
                    .font(.headline)

                if supervision.contains("supervision") {
                    Text("Done as a parent–child demonstration. Never an unsupervised activity.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    // Journey-specific colors
    private var journeyColor: Color {
        switch pin.journey {
        case .north: return Color.blue
        case .east: return Color.green
        case .south: return Color.orange
        case .west: return Color.purple
        }
    }

    // Journey-specific icons
    private var journeyIcon: String {
        switch pin.journey {
        case .north: return "house.fill"
        case .east: return "leaf.fill"
        case .south: return "building.2.fill"
        case .west: return "star.fill"
        }
    }

    // Load image from Resources folder
    private func loadImageFromResources(imagePath: String) -> UIImage? {
        print("🖼️ Attempting to load image: \(imagePath)")

        // Extract filename from path (e.g., "North/Names" -> "Names")
        let filename = imagePath.split(separator: "/").last.map(String.init) ?? imagePath

        print("🔍 Looking for filename: \(filename)")

        // Try loading directly by filename (files are flattened in bundle)
        if let path = Bundle.main.path(forResource: filename, ofType: "png") {
            print("✅ Found image at bundle path: \(path)")
            return UIImage(contentsOfFile: path)
        }

        print("❌ Image not found in bundle")

        // Try using UIImage(named:) which searches the bundle automatically
        if let image = UIImage(named: filename) {
            print("✅ Found image using UIImage(named:)")
            return image
        }

        print("❌ Image not found with UIImage(named:)")
        return nil
    }
}

#Preview {
    NavigationView {
        PinDetailView(
            pin: Pin(
                name: "Knife Safety",
                journey: .west,
                supervision: "Adult supervision",
                requirements: "Demonstrate safe knife handling. Carve or whittle an object together with your adult. Present it to your Circle.",
                examples: "Safety rules:\n• Always cut AWAY from yourself\n• Keep blade sharp (dull = dangerous)\n• Close when not in use\n• Create safety circle (arm's length)\n\nFirst projects: Tent stake, butter knife, whistle",
                imageURL: nil,
                imageURLs: [
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Pocket_knife_opened.jpg/480px-Pocket_knife_opened.jpg",
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Whittling.jpg/480px-Whittling.jpg"
                ]
            ),
            explorer: Explorer(circle: "Vikings", lastName: "Doe", firstName: "John", adventureName: nil)
        )
        .environmentObject(APIService.shared)
    }
}
