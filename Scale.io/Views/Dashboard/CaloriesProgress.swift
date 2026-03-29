import SwiftUI

struct CalorieBar: View {
    var calories: Int
    var goal: Double

    var progress: Double {
        Double(calories) / Double(goal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Daily Calories")
                    .font(.headline)
                Spacer()
                Text("\(Int(goal)) goal")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(calories)")
                    .font(.title.bold())
                Text("kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int((min(max(progress, 0), 1)) * 100))%")
                    .font(.headline.bold())
                    .foregroundStyle(.accent)
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
                        .frame(width: {
                            let raw = progress
                            let finite = raw.isFinite ? raw : 0
                            let clamped = min(max(finite, 0), 1)
                            let w = geo.size.width * clamped
                            return w.isFinite && w >= 0 ? w : 0
                        }(), height: 22)
                        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: progress)
                }
            }
            .frame(height: 22)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
