import Foundation
internal import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var connected: Bool = false
    @Published var error: String?
    
    private let service = AuthService()
    private let handler = TokenHandler.shared
    
    init() {
        Task {
            connected = await handler.get() != nil
        }
    }
    
    func login(username: String, password: String) async {
        do {
            let response = try await service.login(username: username, password: password)
            await handler.save(response)
            connected = true
            error = nil
        } catch {
            connected = false
            self.error = "Login failed. Please check your credentials."
        }
    }
    
    func logout() async {
        await handler.clear()
        connected = false
    }
}
