import Charts
import SwiftUI

struct FoodDetailsView: View {
    let food: Food?
    var action: Bool = true
    var onRegister: () async -> Void = {}
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            view
        }
        .padding(16)
    }

    @ViewBuilder private var view: some View {
        if let f = food {
            FoodHeaderView(food: f)
            MacrosGrid(food: f)
            if action {
                CustomButton("Add Food", icon: "plus") {
                    Task { await onRegister() }
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    FoodDetailsView(food: M_foods[0])
}
