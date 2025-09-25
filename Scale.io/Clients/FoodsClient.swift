import Foundation

class FoodsClient {
    static let shared = FoodsClient()
    private init() {}
    
    func fetch(_ request : FoodRequest) async throws -> FoodResponse {
        let endpoint = "\(request.endpoint)/\(request.query)?grams=\(request.grams)"
        return try await BaseClient.shared.get(endpoint: endpoint)
    }
}
