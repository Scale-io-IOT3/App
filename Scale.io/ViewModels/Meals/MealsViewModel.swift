internal import Combine
import Foundation

class MealsViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var today: [Food] = []
    private let service = MealService()

    var loggedOrder: [UUID: Int] {
        Dictionary(uniqueKeysWithValues: today.enumerated().map { ($0.element.id, $0.offset) })
    }

    private var maxCalories: Int {
        today.map(\.macros.calories).max() ?? 0
    }

    private var maxProteins: Double {
        today.map(\.macros.proteins).max() ?? 0
    }

    private var maxQuantity: Double {
        today.map(\.quantity).max() ?? 0
    }

    private var maxCarbs: Double {
        today.map(\.macros.carbohydrates).max() ?? 0
    }

    private var maxFat: Double {
        today.map(\.macros.fat).max() ?? 0
    }

    func insights(for food: Food) -> [FoodTagKind] {
        var insights: [FoodTagKind] = []

        if today.first?.id == food.id {
            insights.append(.firstLogged)
        }

        if today.last?.id == food.id {
            insights.append(.lastLogged)
        }

        if maxCalories > 0 && food.macros.calories == maxCalories {
            insights.append(.mostCalories)
        }

        if maxProteins > 0 && food.macros.proteins == maxProteins {
            insights.append(.mostProtein)
        }


        if maxCarbs > 0 && food.macros.carbohydrates == maxCarbs {
            insights.append(.mostCarbs)
        }

        if maxFat > 0 && food.macros.fat == maxFat {
            insights.append(.mostFat)
        }

        return insights
    }

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

    func getTodayFoods() async {
        await self.fetch()

        let response = meals
            .filter { $0.createdAt.isToday() }
            .sorted(by: { $0.createdAt < $1.createdAt })
        self.today = response.flatMap { $0.foods }
    }

    private func fetch() async {
        guard let response = try? await service.fetch() else { return }
        self.meals = response
    }

}
