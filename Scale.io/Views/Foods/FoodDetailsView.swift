import Charts
import SwiftUI

struct FoodDetailsView: View {
  let food: Food?
  var onOk: () -> Void = {}
  @Environment(\.dismiss) var dismiss
  var body: some View {

    VStack(alignment: .leading, spacing: 30) {
      view
        .padding()
    }
  }

  @ViewBuilder private var view: some View {
    if let f = food {
      FoodHeaderView(food: f)
      MacrosGrid(food: f)
      CustomButton(text: "Register") {
        dismiss()
        onOk()
      }
    } else {
      ContentUnavailableView("No food found", systemImage: "leaf.fill")
    }
  }
}

#Preview {
  let food = Food(
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
  FoodDetailsView(food: food)
}
