internal import Combine
import Foundation

class MealsViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    private let service = MealService()

    func create(using foods: [Food]) async {
        let dto = foods.map { $0.toDto() }

        let request = MealRequest(foods: dto)
        if (try? await service.create(request: request)) != nil { return await fetch() }
    }

    func create(using food: Food) async {
        let array: [Food] = [food]
        await self.create(using: array)
    }

    func create(from meal: Meal) async {
        await create(using: meal.foods)
    }

    func getTodayFoods() async -> [Food] {
        await self.fetch()

        let response = meals.filter { $0.createdAt.isToday() }
        return response.flatMap { $0.foods }
    }

    private func fetch() async {
        guard let response = try? await service.fetch() else { return }
        self.meals = response
    }

}
