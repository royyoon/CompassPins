import SwiftUI
import GoogleSignIn

@main
struct CompassPinsApp: App {
    @StateObject private var apiService = APIService.shared
    @State private var isSignedIn = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isSignedIn {
                    MainTabView(isSignedIn: $isSignedIn)
                } else {
                    AuthenticationView(isSignedIn: $isSignedIn)
                }
            }
            .environmentObject(apiService)
            .task {
                // Check for stored token and restore session
                if let token = apiService.getStoredToken() {
                    print("🔐 Found stored token, restoring session...")
                    apiService.setIDToken(token)

                    // Try to restore user from cache or fetch fresh
                    do {
                        let user = try await apiService.getMe()
                        print("✅ Restored user: \(user.email)")
                        isSignedIn = true
                    } catch {
                        print("❌ Failed to restore session: \(error)")
                        // Token might be expired, clear it
                        apiService.clearAuth()
                        isSignedIn = false
                    }
                } else {
                    print("❌ No stored token found")
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
