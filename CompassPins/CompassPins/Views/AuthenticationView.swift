import SwiftUI
import GoogleSignIn

struct AuthenticationView: View {
    @EnvironmentObject var apiService: APIService
    @Binding var isSignedIn: Bool
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showDemoLogin = false
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Logo/Icon placeholder
            Image(systemName: "location.north.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)

            Text("Compass Pins")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Track your adventure journey")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            if showDemoLogin {
                // Demo login form for App Store review
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: demoLogin) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                            Text("Demo Login")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)

                    Button("Use Google Sign-In") {
                        showDemoLogin = false
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 40)
            } else {
                Button(action: signIn) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                        Text("Sign in with Google")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .disabled(isLoading)
                .padding(.horizontal, 40)

                Button("App Store Reviewer? Demo Login") {
                    showDemoLogin = true
                    email = "example@royyoon.com"
                    password = "Password123"
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            }

            if isLoading {
                ProgressView()
                    .padding()
            }

            Spacer()

            Text("Broken Arrow Expedition")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
        .padding()
    }

    private func demoLogin() {
        // Check demo credentials
        if email == "example@royyoon.com" && password == "Password123" {
            isLoading = true
            errorMessage = nil

            // Set demo mode and load mock data
            apiService.setDemoMode(true)

            Task {
                await MainActor.run {
                    isLoading = false
                    isSignedIn = true
                }
            }
        } else {
            errorMessage = "Invalid demo credentials. Use:\nEmail: example@royyoon.com\nPassword: Password123"
        }
    }

    private func signIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to find root view controller"
            return
        }

        isLoading = true
        errorMessage = nil

        // TODO: Replace with your iOS Client ID from Google Cloud Console
        let clientID = "144411573267-cadot1nebiu6tj58g54plslbgfockhri.apps.googleusercontent.com"

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            isLoading = false

            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                errorMessage = "Failed to get ID token"
                return
            }

            // Store token
            apiService.setIDToken(idToken)

            // Verify user is authorized
            Task {
                do {
                    let userData = try await apiService.getMe()

                    if userData.role == .unauthorized {
                        await MainActor.run {
                            apiService.clearAuth()
                            errorMessage = "You are not authorized to use this app. Please contact your expedition leader."
                        }
                    } else {
                        await MainActor.run {
                            isSignedIn = true
                        }
                    }
                } catch {
                    await MainActor.run {
                        apiService.clearAuth()
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

#Preview {
    AuthenticationView(isSignedIn: .constant(false))
        .environmentObject(APIService.shared)
}
