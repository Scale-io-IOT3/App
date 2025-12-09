import Foundation

public final class Time {
    static let shared = Time()
    private init() {}
    
    public var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        return cal
    }
    
    var todayStart: Date {
        calendar.startOfDay(for: Date())
    }
    
    var tomorrowStart: Date {
        calendar.date(byAdding: .day, value: 1, to: todayStart)!
    }
    
    func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }
}

