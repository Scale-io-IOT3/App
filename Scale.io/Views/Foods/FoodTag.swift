import SwiftUI

struct FoodTag: View {
    let kind: FoodTagKind

    private var title: String {
        switch kind {
        case .firstLogged: return "First Logged"
        case .lastLogged: return "Last Logged"
        case .mostCalories: return "Most Calories"
        case .mostProtein: return "Most Protein"
        case .mostCarbs: return "Most Carbs"
        case .mostFat: return "Most Fat"
        }
    }

    private var icon: String {
        switch kind {
        case .firstLogged: return "clock.arrow.circlepath"
        case .lastLogged: return "clock.fill"
        case .mostCalories: return "flame.fill"
        case .mostProtein: return "bolt.fill"
        case .mostCarbs: return "leaf.fill"
        case .mostFat: return "drop.fill"
        }
    }

    private var tint: Color {
        switch kind {
        case .firstLogged: return .teal
        case .lastLogged: return .blue
        case .mostCalories: return .orange
        case .mostProtein: return .pink
        case .mostCarbs: return .cyan
        case .mostFat: return .yellow
        }
    }

    var body: some View {
        Label(title, systemImage: icon)
            .font(.system(size: 9, weight: .semibold))
            .imageScale(.small)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(tint.opacity(0.18))
            )
            .foregroundStyle(tint)
    }
}
