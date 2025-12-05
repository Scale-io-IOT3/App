import Foundation

struct Meal: Codable {
    let id: UUID = .init()
    let createdAt: String
    var date: Date { Meal.formatDate(from: createdAt) }
    let foods: [Food]

    enum CodingKeys: CodingKey {
        case createdAt
        case foods
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.configure()

        return formatter
    }()

    static func formatDate(from string: String) -> Date {
        return dateFormatter.date(from: string) ?? Date()
    }
}

extension DateFormatter {
    func configure() {
        self.calendar = Calendar(identifier: .iso8601)
        self.locale = Locale(identifier: "en_US_POSIX")
        self.timeZone = TimeZone(secondsFromGMT: 0)
        self.dateFormat = "yyyy-MM-dd"
    }
}
