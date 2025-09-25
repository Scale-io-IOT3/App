import Foundation

struct AuthRequest : Request {
    var endpoint: String
    let username : String
    let password : String
    
    init(username: String, password: String) {
        self.endpoint = "login"
        self.username = username
        self.password = password
    }
    
    enum CodingKeys: CodingKey {
        case username
        case password
    }
}
