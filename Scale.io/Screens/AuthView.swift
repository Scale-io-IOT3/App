import SwiftUI

struct AuthView: View {
    @State var username: String = ""
    @State var password: String = ""
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(.accent)
                    .padding(14)
                    .background(
                        Circle()
                            .fill(Color.accentColor.opacity(0.12))
                    )

                Text("Welcome back")
                    .font(.title.bold())

                Text("Sign in to continue logging meals and tracking your progress.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 14) {
                UsernameField(name: "Username", value: $username)
                PasswordField(name: "Password", value: $password)
            }

            CustomButton(auth.isLoading ? "Signing In..." : "Sign In", icon: "arrow.right") {
                Task {
                    await auth.login(
                        username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                        password: password.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                }
            }
            .disabled(
                auth.isLoading
                    || username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 26)
        .alert(
            "Oops...",
            isPresented: Binding(
                get: { auth.error != nil },
                set: { visible in
                    if !visible {
                        auth.clearError()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(auth.error ?? "Something went wrong")
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
