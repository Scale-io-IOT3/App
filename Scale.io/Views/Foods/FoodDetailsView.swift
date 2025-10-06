import Charts
import SwiftUI

struct FoodDetailsView: View {
    let food: Food
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            FoodHeaderView(food: food)
            MacrosGrid(food: food)
            CustomButton{
                dismiss()
            }

        }
        .padding()
    }
}

#Preview {
    let food = Food(
        name: "Banana",
        brands: "Monke",
        calories: 120,
        quantity: 1,
        macros: Macros(
            carbohydrates: 27,
            fat: 0.3,
            proteins: 1.3,
            percentages: Percentages(carbs: 75, fat: 2, proteins: 23)
        )
    )
    FoodDetailsView(food: food)
}
