import Foundation

class AuthService {
    private let client = AuthClient.shared

    public func login(username: String, password: String) async throws -> LoginResponse {
        let request = AuthRequest(username: username, password: password)
        return try await client.login(request: request) as LoginResponse
    }
}
