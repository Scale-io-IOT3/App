import Foundation

class MealService {
    private let client = MealsClient.shared

    public func create(request: MealRequest) async throws -> MealCreationResponse {
        return try await client.create(request)
    }
    
    public func fetch() async throws -> MealResponse {
        return try await client.fetch()
    }
}
