import Foundation

enum FoodType {
    case fresh
    case product
    
    func makeRequest(food: String, grams: Double) -> APIRequest {
        switch self {
        case .fresh:
            return FreshFoodRequest(query: food, grams: grams)
        case .product:
            return ProductRequest(query: food, grams: grams)
        }
    }
}
