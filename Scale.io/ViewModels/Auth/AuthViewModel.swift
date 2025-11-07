internal import Combine
import Foundation

@MainActor
class AuthViewModel: ObservableObject {
  enum AppState {
    case loading
    case authenticated
    case unauthenticated
  }

  @Published private(set) var state: AppState = .loading
  @Published var error: String?

  private let service = AuthService()
  private let token = TokenHandler.shared

  init() {
    Task { await refreshSession() }
  }

  func refreshSession() async {
    state = .loading
    if await token.get() != nil {
      state = .authenticated
    } else {
      state = .unauthenticated
      error = "Session expired. Please log in."
    }
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
    return state == .unauthenticated
  }
}
