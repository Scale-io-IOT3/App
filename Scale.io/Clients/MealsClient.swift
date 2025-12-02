import Foundation

class MealsClient {
    static let shared = MealsClient()
    private let endpoint = "meals"
    private init() {}

    func fetch() async throws -> MealResponse {
        let res = try await BaseClient.shared.get(endpoint: self.endpoint) as MealResponse
        return res
    }

    func create(_ request: MealRequest) async throws -> MealCreationResponse {
        return try await BaseClient.shared.post(endpoint: request.endpoint, request: request)
    }
}
