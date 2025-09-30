import Foundation

struct LoginResponse: AuthResponse{
    var username, access, refresh: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case access = "access_token"
        case refresh = "refresh_token"
    }
}
