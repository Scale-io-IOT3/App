import SwiftUI

struct TodayCardView: View {
    let foods: [Food]
    private let color: Color = .accentColor
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {

                HStack {
                    Text("Today’s foods")
                        .font(.headline)

                    Spacer()

                    Text(
                        foods.isEmpty
                            ? "No foods yet"
                            : "\(foods.count) food\(foods.count > 1 ? "s" : "")"
                    )
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .clipShape(Capsule())
                }

                Text("View all foods registered today")
                    .font(.subheadline)
                    .foregroundStyle(foods.isEmpty ? .tertiary : .secondary)

            }

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct CaloriesLeft: View {
    let consumed: Int
    let goal: Int
    var left: Int { max(0, goal - consumed) }
    var progress: Double { Double(consumed) / Double(goal) }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.accent)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(left)")
                    .font(.title.bold())
                
                Text("calories left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
