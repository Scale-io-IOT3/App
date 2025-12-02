import Foundation

struct Meal: Codable {
    let id: UUID = .init()
    let createdAt: String
    let foods: [Food]

    enum CodingKeys: CodingKey {
        case createdAt
        case foods
    }
}
