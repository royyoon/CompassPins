import SwiftUI

struct GuestView: View {
    @EnvironmentObject var apiService: APIService
    @Binding var isSignedIn: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "rosette")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    Text("Compass Pins")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Adventure Guides Achievement Program")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Info message
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Not Enrolled Yet?")
                                .font(.headline)

                            Text("You're signed in, but you're not set up in the program yet. Contact your expedition leader to get added!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)

                // Browse catalog button
                NavigationLink(destination: PinsView()) {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("Browse Pin Catalog")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // About the program
                VStack(alignment: .leading, spacing: 16) {
                    Text("About the Program")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(icon: "figure.2.and.child.holdinghands", text: "Parent-child adventure program")
                        InfoRow(icon: "map.fill", text: "4 journeys: Family, Nature, Community, Fun")
                        InfoRow(icon: "rosette", text: "26 achievement pins to earn")
                        InfoRow(icon: "target", text: "Earn all pins to get the medallion")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()

                // Sign out button
                Button(action: {
                    apiService.clearAuth()
                    isSignedIn = false
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    GuestView(isSignedIn: .constant(true))
        .environmentObject(APIService.shared)
}
