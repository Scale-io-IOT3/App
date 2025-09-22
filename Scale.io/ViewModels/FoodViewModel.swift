import Foundation
internal import Combine

class FoodViewModel: ObservableObject {
    @Published private(set) var foods: [Food] = []
    private let service = FoodService()
    
    @MainActor
    private func get(type: FoodType, food: String, grams: Double) async -> [Food] {
        let request = type.makeRequest(food: food, grams: grams)
        
        do {
            self.foods = try await service.fetchFoods(request: request)
        } catch {
            self.foods = []
        }
        
        return self.foods
    }

    @MainActor
    public func getFreshFood(food: String, quantity: Double = 100) async -> [Food]{
        return await self.get(type: .fresh, food: food, grams: quantity)
    }
    
    @MainActor
    public func getProduct(food: String, quantity: Double = 100) async -> [Food]{
        return await self.get(type: .product, food: food, grams: quantity)
    }
}
