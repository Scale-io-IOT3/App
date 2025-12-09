internal import Combine
import Foundation

class MealsViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    private let service = MealService()

    func create(using foods: [Food]) async {
        let request = MealRequest(foods: foods.map { $0.toDto() })
        if (try? await service.create(request: request)) != nil { return await fetch() }
    }

    func create(using food: Food) async {
        let array: [Food] = [food]
        await self.create(using: array)
    }

    func create(from meal: Meal) async {
        await create(using: meal.foods)
    }

    func getTodayFoods() async -> [Meal] {
        await self.fetch()
        
        let todayStart = Time.shared.todayStart
        return meals.filter { Time.shared.isSameDay($0.date, todayStart) }
    }

    private func fetch() async {
        if let response = try? await service.fetch() {
            self.meals = response
        }
    }

}
