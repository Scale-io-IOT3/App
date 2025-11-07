import Foundation
import JWTDecode
import KeychainAccess

actor TokenHandler {
  private let refreshKey = "refresh_token"
  private let keychain = Keychain(service: "Scale.grp.Scale-io")

  private var accessToken: String?
  public static let shared = TokenHandler()

  private init() {}

  func save(_ token: AuthResponse) {
    do {
      try keychain.set(token.refreshToken, key: refreshKey)
      accessToken = token.accessToken
    } catch {
      print("Failed to save token: \(error)")
    }
  }

  func clear() {
    do {
      try keychain.remove(refreshKey)
      accessToken = nil
    } catch {
      print("Failed to clear tokens: \(error)")
    }
  }

  func get() async -> String? {
    if let token = accessToken, validate(token) {
      return token
    }

    guard let refreshed = await refresh() else {
      return nil
    }

    return refreshed
  }

  private func getRefreshToken() -> String? {
    return try? keychain.get(refreshKey)
  }

  private func validate(_ token: String?) -> Bool {
    guard let token else { return false }

    do {
      let jwt = try decode(jwt: token)
      return !jwt.expired
    } catch {
      print("Invalid token: \(error)")
      return false
    }
  }

  private func refresh() async -> String? {
    guard let token = getRefreshToken() else {
      clear()
      return nil
    }

    do {
      let res = try await AuthClient.shared.refresh(token: token)
      save(res)
      return res.accessToken
    } catch {
      print("Refresh failed: \(error)")
      clear()
      return nil
    }
  }
}
