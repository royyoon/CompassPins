import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var apiService: APIService
    @State private var selectedTab = 0
    @Binding var isSignedIn: Bool

    var body: some View {
        Group {
            if apiService.currentUser?.role == .unauthorized {
                // Guest view for unauthorized users
                GuestView(isSignedIn: $isSignedIn)
            } else {
                // Normal tab view for parents and admins
                TabView(selection: $selectedTab) {
                    // Home tab (for parents and admins)
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)

                    // Pins tab (for parents and admins)
                    PinsView()
                        .tabItem {
                            Label("Pins", systemImage: "rosette")
                        }
                        .tag(1)

                    // Circle tab (admins only)
                    if apiService.currentUser?.role == .admin {
                        CircleView()
                            .tabItem {
                                Label("Circle", systemImage: "person.3.fill")
                            }
                            .tag(2)
                    }

                    // Expedition tab (admins only)
                    if apiService.currentUser?.role == .admin {
                        ExpeditionView()
                            .tabItem {
                                Label("Expedition", systemImage: "location.circle.fill")
                            }
                            .tag(3)
                    }
                }
            }
        }
    }
}

#Preview {
    MainTabView(isSignedIn: .constant(true))
        .environmentObject(APIService.shared)
}
