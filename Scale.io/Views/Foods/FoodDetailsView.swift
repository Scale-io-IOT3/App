import Charts
import SwiftUI

struct FoodDetailsView: View {
    let food: Food?
    var register: () async -> Void = {}
    @Environment(\.dismiss) var dismiss
    var body: some View {

        VStack(alignment: .leading, spacing: 30) {
            view.padding()
        }
    }

    @ViewBuilder private var view: some View {
        if let f = food {
            FoodHeaderView(food: f)
                .padding(.top)
            MacrosGrid(food: f)
            CustomButton(text: "Register") {
                dismiss()
                Task { await register() }
            }
        } else {
            ContentUnavailableView("Hmm… nothing popped up.", systemImage: "carrot.fill")
        }
    }
}

#Preview {
    FoodDetailsView(food: M_foods[0])
}
