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

extension [Meal] {
    func today() -> [Meal] {
        return self.filter { $0.createdAt.isToday() }
            .sorted(by: { $0.createdAt < $1.createdAt })
    }
}
