import Foundation

struct RefreshRequest: Request {
    var endpoint: String = "auth/refresh"
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case token
    }
}
