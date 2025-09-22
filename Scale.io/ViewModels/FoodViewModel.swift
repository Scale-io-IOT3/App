import Foundation
internal import Combine

class FoodViewModel: ObservableObject {
    @Published private(set) var foods: [Food] = []

    private let service = FoodService()
    private let repository = FoodRepository()

    public func getCache() -> [Food] {
        return (try? repository.load()) ?? []
    }

    public func getFreshFood(food: String, quantity: Double = 100) async -> [Food] {
        return await fetch(type: .fresh, food: food, grams: quantity)
    }

    public func getProduct(food: String, quantity: Double = 100) async -> [Food] {
        return await fetch(type: .product, food: food, grams: quantity)
    }

    @MainActor
    private func fetch(type: FoodType, food: String, grams: Double) async -> [Food] {
        let request = type.makeRequest(food: food, grams: grams)
        
        do {
            self.foods = try await service.fetchFoods(request: request)
        } catch {
            print("Failed to fetch \(food): \(error)")
            self.foods = []
        }

        return self.foods
    }
}
