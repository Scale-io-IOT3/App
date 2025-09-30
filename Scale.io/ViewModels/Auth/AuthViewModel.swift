import Foundation
internal import Combine

class AuthViewModel: ObservableObject {
    private let service = AuthService()
    private let token = TokenHandler.shared

    public func login(username: String, password: String) async {
        guard let response = try? await service.login(username: username, password: password) else {
            print("Unable to get a token from the API")
            return
        }

        token.saveToken(token: response.accessToken)
    }
    
    public func refresh() async {
        
    }
}
