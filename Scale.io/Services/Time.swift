import Foundation

public final class Time {
    static let shared = Time()

    public let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        return cal
    }()

    private init() {}
}

extension Date {
    var start: Date {
        Time.shared.calendar.startOfDay(for: self)
    }

    var end: Date {
        Time.shared.calendar.date(byAdding: .day, value: 1, to: self.start)!
    }

    func isToday() -> Bool {
        Time.shared.calendar.isDateInToday(self)
    }
}
