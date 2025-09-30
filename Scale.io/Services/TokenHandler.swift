import Foundation
import JWTDecode
import KeychainAccess

class TokenHandler {
    private let refreshKey = "refresh_token"
    private let keychain = Keychain(service: "Scale.grp.Scale-io")

    private var accessToken: String?
    public static let shared = TokenHandler()

    private init() {}

    func save(_ token: AuthResponse) {
        do {
            try keychain.set(token.refreshToken, key: refreshKey)
            accessToken = token.accessToken
        } catch {
            print("Failed to save token: \(error)")
        }
    }

    func clear() {
        do {
            try keychain.remove(refreshKey)
            accessToken = nil
        } catch {
            print("Failed to clear tokens: \(error)")
        }
    }

    func getAccessToken() -> String? {
        if let access = accessToken {
            return validate(access)
        }

        return nil
    }

    func getRefreshToken() -> String? {
        return try? keychain.get(refreshKey)
    }

    private func validate(_ token: String?) -> String? {
        guard let token else { return nil }

        do {
            let jwt = try decode(jwt: token)
            return jwt.expired ? nil : token
        } catch {
            print("Invalid token: \(error)")
            return nil
        }
    }
}
