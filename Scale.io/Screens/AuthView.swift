import SwiftUI

struct AuthView: View {
  @State var username: String = ""
  @State var password: String = ""
  @EnvironmentObject var auth: AuthViewModel
  @State var showError: Bool = false

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

      CustomButton(
        text: "Sign In",
        action: {
          Task {
            await auth.login(username: username, password: password)
            showError = !auth.isAuth()
          }
        }
      )
    }
    .padding(.horizontal)
    .alert("Error", isPresented: $showError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("Something went wrong")
    }
  }
}

#Preview {
  AuthView()
}
