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
            self.error = generateError(from: error)
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

    private func generateError(from error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "No internet connection. Please check your network and try again."
            case .cannotConnectToHost, .cannotFindHost, .timedOut:
                return "Unable to reach the server right now. Please try again."
            default:
                break
            }
        }

        if let httpError = error as? HTTPError {
            switch httpError {
            case .statusCode(401), .statusCode(403):
                return "Invalid credentials. Please check your username and password."
            case .serverError, .invalidResponse, .invalidData:
                return "Something went wrong. Please try again in a moment."
            case .unknownError(let underlying):
                return underlying.localizedDescription
            default:
                break
            }
        }

        let fallback = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        if fallback.isEmpty || fallback == "The operation couldn't be completed." {
            return "Login failed. Please try again."
        }
        return fallback
    }
}
