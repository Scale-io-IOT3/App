internal import Combine
import Foundation

class FoodViewModel: ObservableObject {
    @Published private(set) var foods: [Food] = []
    @Published public var selected: Food? = nil
    @Published public var daily: Double? = nil
    @Published public var BMR: Double? = nil
    private let service = FoodService()

    public func getFreshFood(food: String, quantity: Double = 100) async -> [Food] {
        return await fetch(type: .fresh, food: food, grams: quantity)
    }

    public func getProduct(food: String, quantity: Double = 100) async -> [Food] {
        return await fetch(type: .product, food: food, grams: quantity)
    }

    public func fetchUserBMR() async {
        guard
            let age = service.getAge(),
            let sex = service.getSex(),
            let weight = await service.fetchLatestWeight(),
            let height = await service.fetchLatestHeight()
        else {
            return BMR = 0
        }

        BMR = service.calculateBMR(weight: weight, height: height, age: age, sex: sex)
    }
    
    public func fetchDailyCalories(for date: Date) async {
        if let calories = await service.fetchDailyCalories(for: date) {
            await MainActor.run {
                self.daily = calories
            }
        }
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
