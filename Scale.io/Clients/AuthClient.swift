import Foundation

class AuthClient {
    static let shared = AuthClient()
    private init() {}

    func login(request: AuthRequest) async throws -> LoginResponse {
        return try await BaseClient.shared.post(endpoint: request.endpoint, request: request)
    }
}
