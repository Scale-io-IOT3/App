import SwiftUI

struct FoodListView: View {
    @EnvironmentObject var foodVm: FoodViewModel
    @Binding var foods: [Food]
    @Binding var presentSheet: Bool
    
    var body: some View {
        List {
            ForEach(foods) { food in
                Button {
                    foodVm.selected = food
                    presentSheet = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(food.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            
                            Text(food.brands)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .listRowSeparator(.automatic)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .animation(.smooth, value: foods)
    }
}

#Preview {
    FoodListView(
        foods: .constant([
            Food(
                name: "Banana",
                brands: "Monke",
                calories: 120,
                quantity: 1,
                macros: Macros(
                    carbohydrates: 27,
                    fat: 0.3,
                    proteins: 1.3,
                    percentages: Percentages(carbs: 93, fat: 2, proteins: 5)
                )
            ),
            Food(
                name: "Chicken Breast",
                brands: "Farm Fresh",
                calories: 165,
                quantity: 1,
                macros: Macros(
                    carbohydrates: 0,
                    fat: 3.6,
                    proteins: 31,
                    percentages: Percentages(carbs: 0, fat: 22, proteins: 78)
                )
            )
        ]),
        presentSheet: .constant(false)
    )
    .environmentObject(FoodViewModel())
}
