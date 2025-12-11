import Foundation

struct Meal: Codable {
    let id: UUID = .init()
    let createdAt: String
    var date: Date { Time.shared.date(from: createdAt) }
    let foods: [Food]

    enum CodingKeys: CodingKey {
        case createdAt
        case foods
    }
}
