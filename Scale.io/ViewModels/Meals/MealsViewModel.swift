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

        var utcCalendar: Calendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!

        return meals.filter { utcCalendar.isDate($0.date, inSameDayAs: Date()) }
    }

    private func fetch() async {
        if let response = try? await service.fetch() {
            self.meals = response
        }
    }

}
