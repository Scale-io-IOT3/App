import SwiftUI

struct ProgressCard: View {
    var details: String?

    init(_ details: String? = nil) {
        self.details = details
    }

    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.large)

            if let text = details {
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .appCard()
        .padding(20)
    }
}

#Preview {
    ProgressCard()
}
