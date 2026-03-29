import Charts
import SwiftUI

struct TodayCardView: View {
    let foods: [Food]

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Today’s foods")
                        .font(.headline)

                    Spacer()

                    Text(
                        foods.isEmpty
                            ? "No foods yet"
                            : "\(foods.count) food\(foods.count > 1 ? "s" : "")"
                    )
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .clipShape(Capsule())
                }

                Text("View all foods registered today")
                    .font(.subheadline)
                    .foregroundStyle(foods.isEmpty ? .tertiary : .secondary)
            }

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct CaloriesLeft: View {
    let consumed: Int
    let goal: Int
    var left: Int { max(0, goal - consumed) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Calories left", systemImage: "flame.fill")
                .font(.caption.bold())
                .foregroundStyle(.orange)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(left)")
                    .font(.title2.bold())
                Text("kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Goal \(goal)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct WeeklyCaloriesCard: View {
    let meals: [Meal]
    let goal: Int

    private struct DayCalories: Identifiable {
        let date: Date
        let calories: Int
        var id: Date { date }
    }

    private var points: [DayCalories] {
        let cal = Time.shared.calendar
        let today = Date().start
        let start = cal.date(byAdding: .day, value: -6, to: today) ?? today
        let end = cal.date(byAdding: .day, value: 1, to: today) ?? today

        let mealsInWindow = meals.filter { $0.createdAt >= start && $0.createdAt < end }
        let caloriesByDay = Dictionary(grouping: mealsInWindow, by: { $0.createdAt.start }).mapValues { dayMeals in
            dayMeals.reduce(0) { partial, meal in
                partial + meal.foods.reduce(0) { $0 + $1.macros.calories }
            }
        }

        return (0..<7).compactMap { offset in
            guard let date = cal.date(byAdding: .day, value: offset, to: start) else { return nil }
            return DayCalories(date: date, calories: caloriesByDay[date, default: 0])
        }
    }

    private var weeklyAverage: Int {
        guard !points.isEmpty else { return 0 }
        return Int(points.map(\.calories).reduce(0, +) / points.count)
    }

    private var bestDay: DayCalories? {
        points.max(by: { $0.calories < $1.calories })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("7-Day Intake Trend")
                    .font(.headline)

                Spacer()

                Text("Avg \(weeklyAverage) kcal")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Chart(points) { point in
                BarMark(
                    x: .value("Day", point.date, unit: .day),
                    y: .value("Calories", point.calories)
                )
                .foregroundStyle(
                    point.calories >= goal ? Color.orange : Color.cyan
                )
                .cornerRadius(4)

                RuleMark(y: .value("Goal", goal))
                    .foregroundStyle(.secondary.opacity(0.7))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.gray.opacity(0.25))
                    AxisValueLabel()
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 160)

            if let best = bestDay {
                Text("Highest day: \(best.calories) kcal on \(best.date.formatted(.dateTime.weekday(.wide)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
