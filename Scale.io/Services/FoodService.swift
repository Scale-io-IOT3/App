import Foundation

class FoodService {
    let client = APIClient.shared
    
    func get(request: APIRequest) async throws -> FoodResponse{
        let endpoint = "\(request.endpoint)/\(request.query)?grams=\(request.grams)"
        return try await client.get(endpoint: endpoint)
    }
}
