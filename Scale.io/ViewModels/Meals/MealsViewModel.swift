internal import Combine
import Foundation

class MealsViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    private let service = MealService()

    func create(using foods: [Food]) async {
        let request = MealRequest(foods: foods)

        if let response = try? await service.create(request: request) {
            meals.append(response.meal)
            return
        }

        print("Nope")
    }

    func create(from meal: Meal) async {
        await create(using: meal.foods)
    }

    func fetch() async {
        do {
            let response = try await service.fetch()
            self.meals = response
        } catch {
            print("Nope \(error)")
        }
    }
}
