import SwiftUI

struct FoodCard: View {
    let food: Food
    @State private var selected: Food? = nil
    
    var body: some View {
        Button {
            selected = food
        } label: {
            FoodCardContentView(food: food)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .sheet(item: $selected) { food in
            FoodDetailsView(food: food)
                .presentationDetents([.fraction(0.48)])
        }
    }
}


fileprivate struct FoodCardContentView: View {
    let food: Food
    
    var body: some View {
        HStack(spacing: 12) {
            MacrosChartView(food: food, size: 80)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if !food.brands.isEmpty {
                    Text(food.brands)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}


#Preview {
    let foods = Food(
        name: "Banana",
        brands: "Generic",
        calories: 105,
        quantity: 1,
        macros: Macros(
            carbohydrates: 27,
            fat: 0.4,
            proteins: 1.3,
            percentages: Percentages(carbs: 93, fat: 3, proteins: 4)
        )
    )
    FoodCard(food: foods)
}
