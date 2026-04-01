import SwiftUI

struct AppSwitcher: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        ZStack {
            switch auth.state {
            case .loading:
                ProgressCard("Preparing your space...")

            case .authenticated:
                MainScreen()
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )

            case .unauthenticated:
                AuthView()
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        )
                    )
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: auth.state)
    }
}

#Preview {
    AppSwitcher()
        .environmentObject(AuthViewModel())
}
