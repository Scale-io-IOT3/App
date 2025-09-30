import SwiftUI

@main
struct Scale_ioApp: App {
    @StateObject var auth = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            AppSwitcher()
        }
        .environmentObject(auth)
    }
}

struct AppSwitcher: View {
    @EnvironmentObject var auth: AuthViewModel
    var body: some View {
        if auth.connected {
            ContentView()
        } else {
            AuthView()
        }
    }
}
