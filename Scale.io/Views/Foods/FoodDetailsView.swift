import Charts
import SwiftUI

struct FoodDetailsView: View {
    let food: Food?
    var action: Bool = true
    var register: () async -> Void = {}
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                view
            }
            .padding(16)
        }
    }

    @ViewBuilder private var view: some View {
        if let f = food {
            FoodHeaderView(food: f)
            MacrosGrid(food: f)
            if action {
                CustomButton("Add Food", icon: "plus") {
                    Task { await register() }
                    dismiss()
                }
            }
        } else {
            ContentUnavailableView("Hmm… nothing popped up.", systemImage: "carrot.fill")
        }
    }
}

#Preview {
    FoodDetailsView(food: M_foods[0])
}
