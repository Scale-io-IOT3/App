import Foundation
import SwiftData

class FoodService {
    private let client = APIClient.shared
    private let repository = FoodRepository()

    private func get(_ request: APIRequest) async throws -> FoodResponse {
        let endpoint = "\(request.endpoint)/\(request.query)?grams=\(request.grams)"
        return try await client.get(endpoint: endpoint)
    }

    @MainActor
    public func fetchFoods(request: APIRequest) async throws -> [Food] {
        let response = try await self.get(request)
        return response.foods.toDomain()
    }
}
