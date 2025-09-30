import Foundation
internal import Combine

class AuthViewModel: ObservableObject {
    private let service = AuthService()
    private let handler = TokenHandler.shared

    public func login(username: String, password: String) async {
        if let response = try? await service.login(username: username, password: password){
            handler.save(response)
        }
        
    }
}
