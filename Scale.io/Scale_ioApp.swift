import SwiftUI

@main
struct Scale_ioApp: App {
    @StateObject private var auth = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            AppSwitcher()
                .environmentObject(auth)
                .preferredColorScheme(.dark)
        }
    }
}
