import SwiftUI

struct CustomButton: View {
    var text: String = "OK"
    var color : Color?
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color ?? Color.accent)
        )
    }
}

#Preview {
    CustomButton(action: {
        
    })
}

