import Foundation
import Combine

protocol AuthServiceProtocol {
    var currentUserId: String? { get }
    func signInAttendant(email: String, password: String) -> AnyPublisher<String, Error>
    func signOut() -> AnyPublisher<Bool, Never>
}

final class MockAuthService: AuthServiceProtocol {
    private(set) var currentUserId: String?

    func signInAttendant(email: String, password: String) -> AnyPublisher<String, Error> {
        // fake success with a generated user id
        let id = UUID().uuidString
        currentUserId = id
        return Just(id)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(200), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func signOut() -> AnyPublisher<Bool, Never> {
        currentUserId = nil
        return Just(true).eraseToAnyPublisher()
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
