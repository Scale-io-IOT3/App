internal import Combine
import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    enum AuthState {
        case loading
        case authenticated
        case unauthenticated
    }

    @Published private(set) var state: AuthState = .loading
    @Published var error: String?

    private let service = AuthService()
    private let token = TokenHandler.shared

    init() {
        Task { await refreshSession() }
    }

    func refreshSession() async {
        state = .loading

        guard await (token.get() != nil) else {
            state = .unauthenticated
            error = "Session expired. Please log in."
            return
        }

        state = .authenticated
    }

    func login(username: String, password: String) async {
        state = .loading

        do {
            let tokens = try await service.login(username: username, password: password)
            await token.save(tokens)
            state = .authenticated
            error = nil
        } catch {
            state = .unauthenticated
            self.error = "Login failed. Please check your credentials."
        }
    }

    func logout() async {
        await token.clear()
        state = .unauthenticated
    }

    func isAuth() -> Bool {
        return state == .authenticated
    }
}
