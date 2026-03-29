import SwiftUI

struct CustomButton: View {
    var label: String = "OK"
    var color: Color = .accent
    var fontWeight: Font.Weight = .semibold
    var textColor: Color = .primary
    var cornerRadius: CGFloat = 12
    var icon: String? = nil
    var action: () -> Void

    init(
        _ label: String = "OK",
        color: Color = .accent,
        fontWeight: Font.Weight = .semibold,
        textColor: Color = .white,
        cornerRadius: CGFloat = 12,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.color = color
        self.fontWeight = fontWeight
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(label)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(textColor)
            .fontWeight(fontWeight)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(color)
            )
        }
        .accessibilityLabel(label)
    }
}

#Preview {
    CustomButton(action: {})
}
