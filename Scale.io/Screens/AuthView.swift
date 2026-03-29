import SwiftUI

struct AuthView: View {
    @State var username: String = ""
    @State var password: String = ""
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Let's sign you in.")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.accent)

                Text("You have been missed")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)

            VStack(spacing: 20) {
                UsernameField(name: "Username", value: $username)
                PasswordField(name: "Password", value: $password)
            }
            .padding(.bottom, 12)

            CustomButton("Sign In") {
                Task {
                    await auth
                        .login(
                            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                            password: password.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                }
            }
            .disabled(auth.isLoading)
        }
        .padding(.horizontal)
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
