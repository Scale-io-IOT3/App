import Foundation

class AuthClient {
    static let shared = AuthClient()
    private init() {}

    func login(request: AuthRequest) async throws -> AuthResponse {
        return try await post(request)
    }

    func refresh(token: String) async throws -> AuthResponse {
        let request = RefreshRequest(token: token)
        return try await post(request)
    }

    private func post(_ req: Request, debug: Bool = false) async throws -> AuthResponse {
        return try await BaseClient.shared.post(
            endpoint: req.endpoint,
            request: req,
            debug: debug,
            withAuth: false
        )
    }
}
