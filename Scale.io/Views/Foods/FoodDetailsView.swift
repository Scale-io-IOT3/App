import SwiftUI

struct FoodDetailsView: View {
    let food: Food?
    var onRegister: ((_ food: Food) async -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var quantity: Double
    @State private var measurement: Measurement = .grams
    @FocusState private var isServingFocused: Bool

    init(food: Food?, onRegister: ((_ food: Food) async -> Void)? = nil) {
        self.food = food
        self.onRegister = onRegister
        _quantity = State(initialValue: max(food?.quantity ?? 100, 1))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if let activeFood {
                FoodHeaderView(food: activeFood)
                if onRegister != nil {
                    servingEditor
                }
                MacrosGrid(food: activeFood)

                if let onRegister {
                    CustomButton("Add Food", icon: "plus") {
                        guard let foodForLogging else { return }
                        Task { await onRegister(foodForLogging) }
                        dismiss()
                    }
                    .disabled(foodForLogging == nil)
                }
            }
        }
        .padding(16)
    }

    private var activeFood: Food? {
        guard let food else { return nil }
        guard onRegister != nil else { return food }
        guard let grams = servingInGrams else { return food }
        return food.scaled(to: grams)
    }

    private var foodForLogging: Food? {
        guard let food else { return nil }
        guard onRegister != nil else { return food }
        guard let grams = servingInGrams else { return nil }
        return food.scaled(to: grams)
    }

    private var servingEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Serving Size")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                amountField

                Picker("Unit", selection: $measurement) {
                    ForEach(Measurement.allCases, id: \.self) { unit in
                        Text(unit.rawValue)
                            .tag(unit)
                    }
                }
                .pickerStyle(.menu)

                Spacer(minLength: 0)

                Stepper(
                    "", value: $quantity, in: 0...2500, step: measurement.servingStep
                )
                .labelsHidden()
            }
        }
    }

    private var amountField: some View {
        TextField(
            "Amount",
            value: $quantity,
            format: .number.precision(
                .fractionLength(0...1)
            )
        )
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.trailing)
        .monospacedDigit()
        .frame(width: 90)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .focused($isServingFocused)
        .animation(.easeInOut(duration: 0.15), value: isServingFocused)
    }

    private var servingInGrams: Double? {
        let grams = quantity * measurement.toGramsFactor
        guard grams.isFinite, grams > 0 else { return nil }
        return grams
    }
}

#Preview {
    FoodDetailsView(food: M_foods[0]) { food in
        _ = food
    }
}
