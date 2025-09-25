import Foundation

protocol Request: Encodable {
    var endpoint: String { get }
}
