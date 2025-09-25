import Foundation

struct AuthResponse: Codable {
    let username, accessToken: String
    let expiresIn: Int
}

