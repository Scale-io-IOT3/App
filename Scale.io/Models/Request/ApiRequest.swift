import Foundation

protocol APIRequest: Encodable {
    var endpoint: String { get }
    var query: String { get }
    var grams: Double { get }
}
