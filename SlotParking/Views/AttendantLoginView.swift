import SwiftUI
import Combine

struct AttendantLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningIn = false
    @State private var signedInUserId: String?

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
                    Button(action: signIn) {
                        if isSigningIn {
                            ProgressView()
                        } else {
                            Text("Sign In")
                        }
                    }
                }
            }
            .navigationTitle("Attendant")
        }
    }

    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else { return }
        isSigningIn = true
        _ = authService.signInAttendant(email: email, password: password)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                isSigningIn = false
                if case .failure = completion {
                    // handle error (could show alert)
                }
            }, receiveValue: { uid in
                signedInUserId = uid
                onSignedIn?(uid)
            })
    }
}

#Preview {
    AttendantLoginView()
}
