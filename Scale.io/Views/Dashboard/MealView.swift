import SwiftUI

struct MealCard: View {
    let meal: Meal
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Meal \(index + 1)")
                .font(.headline)

            ForEach(meal.foods.prefix(3), id: \.id) { food in
                FoodHeaderView(food: food)
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

#Preview {
    let foods = [
        Food(
            name: "Banana",
            brands: "Generic",
            calories: 105,
            quantity: 1,
            macros: Macros(
                carbohydrates: 27,
                fat: 0.4,
                proteins: 1.3,
                percentages: Percentages(carbs: 93, fat: 3, proteins: 4)
            )
        )
    ]
    let meal = Meal(createdAt: "", foods: foods)
    MealCard(meal: meal, index: 1)
}
