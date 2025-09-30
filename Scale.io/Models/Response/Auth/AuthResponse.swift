protocol AuthResponse: Codable  {
    var access: String {get set}
    var refresh: String { get set }
}
