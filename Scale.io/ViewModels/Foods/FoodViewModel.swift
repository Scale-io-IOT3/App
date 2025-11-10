internal import Combine
import Foundation

class FoodViewModel: ObservableObject {
  @Published private(set) var foods: [Food] = []
  @Published public var selected: Food? = nil
  private let service = FoodService()

  public func getFreshFood(food: String, quantity: Double = 100) async -> [Food] {
    return await fetch(type: .fresh, food: food, grams: quantity)
  }

  public func getProduct(food: String, quantity: Double = 100) async -> [Food] {
    return await fetch(type: .product, food: food, grams: quantity)
  }

  private func fetch(type: FoodType, food: String, grams: Double) async -> [Food] {
    let g = grams > 0 ? grams : 100
    let request = type.makeRequest(food: food, grams: g)

    do {
      let fetchedFoods = try await service.fetchFoods(request: request)
      self.foods = fetchedFoods
    } catch {
      print("Failed to fetch \(food): \(error)")
      self.foods = []
    }

    return self.foods
  }

}
