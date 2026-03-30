import SwiftUI

struct FieldBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.primary.opacity(0.10), lineWidth: 1)
            )
    }
}


private extension View {
    func fieldBackground() -> some View {
        modifier(FieldBackground())
    }
}

struct IconTextField: View {
    var name: String
    var systemImage: String
    @Binding var text: String
    
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    
    @State private var secureEntryEnabled: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.accent)
                .frame(width: 18)
            
            Group {
                if isSecure && secureEntryEnabled {
                    SecureField(name, text: $text)
                } else {
                    TextField(name, text: $text)
                }
            }
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .submitLabel(.done)
            .font(.subheadline.weight(.semibold))
            
            if isSecure {
                Button {
                    secureEntryEnabled.toggle()
                } label: {
                    Image(systemName: secureEntryEnabled ? "eye" : "eye.slash")
                        .foregroundStyle(.accent)
                }
                .accessibilityLabel(secureEntryEnabled ? "Show password" : "Hide password")
            }
        }
        .fieldBackground()
        .accessibilityElement(children: .contain)
    }
}
