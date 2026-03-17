import Foundation
import Combine

protocol AuthServiceProtocol {
    var currentUserId: String? { get }
    func signInAttendant(email: String, password: String) -> AnyPublisher<String, Error>
    func signOut() -> AnyPublisher<Bool, Never>
}

private struct StoredAttendant: Codable {
    let id: String
    let password: String
}

final class MockAuthService: AuthServiceProtocol {
    private(set) var currentUserId: String?
    private let storageKey = "MockAttendants"
    private var attendants: [String: StoredAttendant] = [:] // email -> StoredAttendant

    init() {
        load()
        // Ensure a demo attendant exists for quick testing
        let demoEmail = "attendant@example.com"
        let demoPassword = "password123"
        if attendants[demoEmail] == nil {
            let id = UUID().uuidString
            attendants[demoEmail] = StoredAttendant(id: id, password: demoPassword)
            save()
        }
    }

    func signInAttendant(email: String, password: String) -> AnyPublisher<String, Error> {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        // if attendant exists, verify password
        if let stored = attendants[normalized] {
            if stored.password == password {
                currentUserId = stored.id
                return Just(stored.id)
                    .setFailureType(to: Error.self)
                    .delay(for: .milliseconds(150), scheduler: RunLoop.main)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: NSError(domain: "MockAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"]))
                    .eraseToAnyPublisher()
            }
        }

        // if not existing, auto-register for test convenience
        let id = UUID().uuidString
        let new = StoredAttendant(id: id, password: password)
        attendants[normalized] = new
        save()
        currentUserId = id
        return Just(id)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(150), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func signOut() -> AnyPublisher<Bool, Never> {
        currentUserId = nil
        return Just(true).eraseToAnyPublisher()
    }

    // Persistence helpers
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([String: StoredAttendant].self, from: data) {
            attendants = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(attendants) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

#if canImport(FirebaseAuth)
import FirebaseAuth

final class FirebaseAuthService: AuthServiceProtocol {
    var currentUserId: String? { Auth.auth().currentUser?.uid }

    func signInAttendant(email: String, password: String) -> AnyPublisher<String, Error> {
        Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error { promise(.failure(error)) } else if let uid = result?.user.uid { promise(.success(uid)) } else {
                    promise(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown auth error"])))
                }
            }
        }.eraseToAnyPublisher()
    }

    func signOut() -> AnyPublisher<Bool, Never> {
        do {
            try Auth.auth().signOut()
            return Just(true).eraseToAnyPublisher()
        } catch {
            return Just(false).eraseToAnyPublisher()
        }
    }
}
#endif
