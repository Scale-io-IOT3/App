internal import Combine
import Foundation

class MealsViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var today: [Food] = []
    private let service = MealService()

    var loggedOrder: [UUID: Int] {
        Dictionary(uniqueKeysWithValues: today.enumerated().map { ($0.element.id, $0.offset) })
    }

    func setTags(_ tags: [FoodTagKind], for foodID: UUID) {
        guard let index = today.firstIndex(where: { $0.id == foodID }) else { return }
        today[index].tags = tags
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
        let foods = meals.today().flatMap(\.foods)
        self.today = tagFoods(foods)
    }

    private func fetch() async {
        guard let response = try? await service.fetch() else { return }
        self.meals = response
    }

    private func tagFoods(_ foods: [Food]) -> [Food] {
        guard !foods.isEmpty else { return [] }

        let maxCalories = foods.map(\.macros.calories).max() ?? 0
        let maxProteins = foods.map(\.macros.proteins).max() ?? 0
        let maxCarbs = foods.map(\.macros.carbohydrates).max() ?? 0
        let maxFat = foods.map(\.macros.fat).max() ?? 0
        let firstID = foods.first?.id
        let lastID = foods.count > 1 ? foods.last?.id : nil

        return foods.map { food in
            var tags: [FoodTagKind] = []
            
            if food.id == firstID { tags.append(.firstLogged) }
            if let lastID, food.id == lastID { tags.append(.lastLogged) }
            if maxCalories > 0 && food.macros.calories == maxCalories { tags.append(.mostCalories) }
            if maxProteins > 0 && food.macros.proteins == maxProteins { tags.append(.mostProtein) }
            if maxCarbs > 0 && food.macros.carbohydrates == maxCarbs { tags.append(.mostCarbs) }
            if maxFat > 0 && food.macros.fat == maxFat { tags.append(.mostFat) }

            return food.withTags(tags)
        }
    }
}
