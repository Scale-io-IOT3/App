import SwiftUI

struct CalorieBar: View {
    var calories: Int
    var goal: Double
    var progress: Double {
        Double(calories) / Double(goal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("\(calories) kcal")
                    .font(.title3.bold())
                Spacer()
                Text("Goal: \(Int(goal))")
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 22)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.accentColor, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * min(progress, 1.0), height: 22)
                        .animation(.easeOut(duration: 0.45), value: progress)
                }
            }
            .frame(height: 22)
        }
        .padding(.top)
    }
}
