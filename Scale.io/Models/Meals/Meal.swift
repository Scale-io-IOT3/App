import Foundation

struct Meal: Codable {
    let id: UUID = .init()
    let createdAt: Date
    let foods: [Food]

    enum CodingKeys: CodingKey {
        case createdAt
        case foods
    }
}
