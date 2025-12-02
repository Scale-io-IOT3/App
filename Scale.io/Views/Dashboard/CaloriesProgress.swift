import SwiftUI

struct CalorieBar: View {
    var progress: Double
    var calories: Int
    var goal: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("\(calories) kcal")
                    .font(.title3.bold())
                Spacer()
                Text("Goal: \(Int(goal))")
                    .foregroundStyle(.secondary)
            }
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.gray.opacity(0.2))
                    .frame(height: 22)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.accent, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .animation(.easeOut(duration: 0.45), value: progress)
            }
            .frame(maxWidth: 250)
        }
        .padding()
    }
}


