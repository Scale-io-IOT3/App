import SwiftUI

struct CustomButton: View {
    var label: String = "OK"
    var color: Color = .accent
    var fontWeight: Font.Weight = .semibold
    var textColor: Color = .primary
    var cornerRadius: CGFloat = 12
    var icon: String? = nil
    var action: () -> Void
    @Environment(\.isEnabled) private var isEnabled
    @State private var isPressed: Bool = false

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
            .padding(.vertical, 13)
            .foregroundStyle(isEnabled ? textColor : textColor.opacity(0.6))
            .fontWeight(fontWeight)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isEnabled ? color : color.opacity(0.45))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel(label)
    }
}

#Preview {
    CustomButton(action: {})
}
