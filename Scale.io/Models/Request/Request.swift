import Foundation

protocol Request: Codable {
  var endpoint: String { get }
}
