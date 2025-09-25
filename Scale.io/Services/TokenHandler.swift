import Foundation
import JWTDecode
import KeychainAccess

class TokenHandler {
    let key = Keychain(service: "Scale.grp.Scale-io")
    public static let shared = TokenHandler()
    
    private init() {}
    
    
    func saveToken(token: String) {
        do {
            try key.set(token, key: "jwt_token")
        } catch {
            print("Failed to save token")
        }
    }
    
    func clearToken() {
        do {
            try key.remove("jwt_token")
        } catch {
            print("Failed to clear token")
        }
    }
    
    func retrieveToken() -> String? {
        do {
            return try key.get("jwt_token")
        } catch {
            print("Unable to retrieve token")
        }
        return nil
    }
    
    func isTokenExpired() -> Bool {
        guard let token = retrieveToken() else {
            return true
        }
        
        do {
            let jwt = try decode(jwt: token)
            guard let exp = jwt.expiresAt else {
                return true
            }
            return exp <= Date()
        } catch {
            return true
        }
    }

}
