import SwiftUI

struct MacrosBreakdown: View {
    @EnvironmentObject var health: HealthViewModel
    let calories: Int

    private func value(for macro: MacrosColor) -> Double {
        switch macro {
        case .carbs:
            return health.carbs ?? 0
        case .proteins:
            return health.proteins ?? 0
        case .fat:
            return health.fat ?? 0
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Macros breakdown")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 20) {
                MacrosChartView(
                    calories: calories,
                    carbs: health.carbs ?? 0,
                    proteins: health.proteins ?? 0,
                    fat: health.fat ?? 0,
                    size: 120
                )

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(MacrosColor.allCases) { macro in
                        MacroRow(
                            title: macro.rawValue,
                            value: value(for: macro),
                            color: macro.color
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemBackground))
        )
        .animation(.easeInOut, value: health.calories)
    }

}

private struct MacroRow: View {
    let title: String
    let value: Double
    let color: Color
    var text: String { String(format: "%.1f", value) }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.subheadline)

            Spacer()

            Text("\(text) g")
                .font(.subheadline.bold())
        }
    }
}

#Preview {
    MacrosBreakdown(calories: 1200)
        .environmentObject(HealthViewModel())
}
