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

    var isAuthenticated: Bool { state == .authenticated }
    var isLoading: Bool { state == .loading }

    init() {
        Task { await refreshSession() }
    }

    func refreshSession() async {
        state = .loading
        error = nil

        guard await (token.get() != nil) else {
            state = .unauthenticated
            return
        }

        state = .authenticated
    }

    func login(username: String, password: String) async {
        guard !username.isEmpty, !password.isEmpty else {
            state = .unauthenticated
            error = "Please enter both username and password."
            return
        }

        state = .loading
        error = nil

        do {
            let tokens = try await service.login(username: username, password: password)
            await token.save(tokens)
            state = .authenticated
        } catch {
            state = .unauthenticated
            self.error = error.feedback(context: .auth)
        }
    }

    func logout() async {
        await token.clear()
        state = .unauthenticated
        error = nil
    }

    func clearError() {
        error = nil
    }
}
