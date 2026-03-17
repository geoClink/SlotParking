import SwiftUI
import Combine

struct AttendantLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningIn = false
    @State private var signedInUserId: String?
    @State private var signInCancellable: AnyCancellable?
    @Environment(\.presentationMode) private var presentationMode
    @State private var showSuccessAlert = false

    var authService: AuthServiceProtocol = MockAuthService()
    var onSignedIn: ((String) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Attendant Login")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }

                Section {
                    Button(action: { signInCredentials(email: email, password: password) }) {
                        if isSigningIn {
                            ProgressView()
                        } else {
                            Text("Sign In")
                        }
                    }

                    // Demo sign-in for local testing when using the mock auth service
                    if authService is MockAuthService {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick demo: use the button below to sign in as a demo attendant")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Button(action: { signInCredentials(email: "attendant@example.com", password: "password123") }) {
                                Text("Sign in as Demo Attendant")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .navigationTitle("Attendant")
            .alert("Signed in", isPresented: $showSuccessAlert) {
                // empty: we will auto-dismiss after showing
            } message: {
                Text("You are now signed in as an attendant.")
            }
            .onChange(of: showSuccessAlert) { new in
                if new {
                    Haptics.success()
                }
            }
        }
    }

    private func signInCredentials(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else { return }
        isSigningIn = true
        signInCancellable = authService.signInAttendant(email: email, password: password)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                isSigningIn = false
                signInCancellable = nil
                if case .failure = completion {
                    Haptics.error()
                    // handle error (could show alert)
                }
            }, receiveValue: { uid in
                signedInUserId = uid
                isSigningIn = false
                signInCancellable = nil
                // show local success alert then auto-dismiss and call parent handler
                showSuccessAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    showSuccessAlert = false
                    presentationMode.wrappedValue.dismiss()
                    onSignedIn?(uid)
                }
            })
    }
}

#Preview {
    AttendantLoginView()
}
