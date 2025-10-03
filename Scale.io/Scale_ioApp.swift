import SwiftUI

@main
struct Scale_ioApp: App {
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            AppSwitcher()
                .environmentObject(auth)
        }
    }
}

// MARK: - Switcher
struct AppSwitcher: View {
    @EnvironmentObject var auth: AuthViewModel
    
    var body: some View {
        ZStack {
            switch auth.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                
            case .authenticated:
                ContentView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
            case .unauthenticated:
                AuthView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8),
                   value: auth.state)
    }
}

