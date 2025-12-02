import Foundation
internal import HealthKit

class FoodService {
    private let client = FoodsClient.shared

    public func fetchFoods(request: FoodRequest) async throws -> [Food] {
        let response = try await client.fetch(request)
        return response.foods
    }
    
}
