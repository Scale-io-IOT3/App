import Charts
import SwiftUI

struct MacrosGrid: View {
    let food: Food
    
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 10) {
            GridRow {
                MacroCell(title: "Carbs", value: food.macros.carbohydrates)
                MacroCell(title: "Proteins", value: food.macros.proteins)
                MacroCell(title: "Fat", value: food.macros.fat)
            }
            
            GridRow {
                MacroProgress(value: food.macros.percentages.carbs)
                MacroProgress(value: food.macros.percentages.proteins)
                MacroProgress(value: food.macros.percentages.fat)
            }
        }
        .padding(.bottom, 30)

    }
}

struct MacroCell: View {
    let title: String
    let value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text("\(value, specifier: "%.1f")g")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(alignment: .leading)
    }
}

struct MacroProgress: View {
    let value: Double
    
    var body: some View {
        ProgressView(value: value / 100)
            .tint(.accent)
            .frame(maxWidth: .infinity)
    }
}
