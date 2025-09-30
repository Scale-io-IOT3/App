import SwiftUI

// MARK: - Reusable blocks
struct UsernameField: View {
    var name: String
    @Binding var value: String
    
    var body: some View {
        IconTextField(
            name: name,
            systemImage: "person.fill",
            text: $value,
            isSecure: false,
            keyboardType: .default,
            textContentType: .name
        )
    }
}

struct PasswordField: View {
    var name: String
    @Binding var value: String
    
    var body: some View {
        IconTextField(
            name: name,
            systemImage: "lock.fill",
            text: $value,
            isSecure: true,
            keyboardType: .default,
            textContentType: .password
        )
    }
}

