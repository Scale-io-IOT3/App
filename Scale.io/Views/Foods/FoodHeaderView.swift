import SwiftUI
import Charts

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
    
    var macroValues: [(name: String, value: Double)] {
        [
            ("Carbohydrates", food.macros.percentages.carbs),
            ("Fat", food.macros.percentages.fat),
            ("Proteins", food.macros.percentages.proteins),
        ]
    }
    
    var body: some View {
        ZStack {
            Chart(macroValues, id: \.name) { macro in
                SectorMark(
                    angle: .value("Percentage", macro.value),
                    innerRadius: .ratio(0.7),
                    angularInset: 1
                )
                .foregroundStyle(by: .value("Macro", macro.name))
            }
            .chartForegroundStyleScale([
                "Carbohydrates": .cyan,
                "Fat": .yellow,
                "Proteins": .mint
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
