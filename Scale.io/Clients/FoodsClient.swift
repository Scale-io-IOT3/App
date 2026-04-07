import Foundation

class FoodsClient {
    static let shared = FoodsClient()
    private init() {}

    func fetch(_ request: FoodRequest) async throws -> FoodResponse {
        let encodedQuery =
            request.query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .addingPercentEncoding(withAllowedCharacters: .urlPathSegmentAllowed)
            ?? request.query
        let endpoint = "\(request.endpoint)/\(encodedQuery)?grams=\(request.grams)"
        return try await BaseClient.shared.get(endpoint: endpoint)
    }
}

extension CharacterSet {
    fileprivate static let urlPathSegmentAllowed: CharacterSet = {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return allowed
    }()
}
