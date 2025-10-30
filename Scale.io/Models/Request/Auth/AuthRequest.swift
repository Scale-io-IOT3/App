import Foundation

struct AuthRequest: Request {
  var endpoint: String = "auth"
  let username: String
  let password: String

  enum CodingKeys: String, CodingKey {
    case username, password
  }
}
