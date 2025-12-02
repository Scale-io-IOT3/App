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
  }
}

struct MacrosChartView: View {
    let food: Food
    var size: CGFloat = 100 
    
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
                    .font(.system(size: size * 0.25, weight: .bold))
                Text("kcal")
                    .font(.system(size: size * 0.1))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}

