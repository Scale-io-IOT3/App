import Charts
import SwiftUI

struct FoodHeaderView: View {
  let food: Food
  var body: some View {
    HStack(spacing: 24) {
      MacrosChartView(food: food)
      VStack(alignment: .leading) {
        Text(food.name)
          .font(.title3)
          .fontWeight(.semibold)
        
        Text(food.brands)
          .font(.headline)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.top)
  }
}

struct MacrosChartView: View {
  let food: Food

  var macroValues: [(macro: MacrosColor, value: Double)] {
    [
      (.carbs, food.macros.percentages.carbs),
      (.fat, food.macros.percentages.fat),
      (.proteins, food.macros.percentages.proteins),
    ]
  }

  var body: some View {
    ZStack {
      Chart(macroValues, id: \.macro.rawValue) { macro in
        SectorMark(
          angle: .value("Percentage", macro.value),
          innerRadius: .ratio(0.7),
          angularInset: 1
        )
        .foregroundStyle(by: .value("Macro", macro.macro.rawValue))
      }
      .chartForegroundStyleScale([
        "Carbs": Color.cyan,
        "Fat": Color.yellow,
        "Protein": Color.mint,
      ])

      .chartLegend(.hidden)

      VStack(spacing: 2) {
        Text("\(food.calories)")
          .font(.title2)
          .fontWeight(.bold)
        Text("kcal")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .frame(width: 100, height: 100)
  }
}
