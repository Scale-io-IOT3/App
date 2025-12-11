import Foundation

public final class Time {
    static let shared = Time()
    
    public let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        cal.locale = Locale(identifier: "en_US_POSIX")
        return cal
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.calendar = self.calendar
        formatter.locale = self.calendar.locale
        formatter.timeZone = self.calendar.timeZone
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
    
    private init() {}
    
    func dayStart(for date: Date = .init()) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    func dayAfter(for date: Date = .init()) -> Date {
        return calendar.date(byAdding: .day, value: 1, to: date)!
    }
    
    func isSameDay(_ a: Date, _ b: Date) -> Bool {
        return calendar.isDate(a, inSameDayAs: b)
    }
    
    func date(from dateString: String) -> Date {
        return self.dateFormatter.date(from: dateString) ?? Date()
    }
}
