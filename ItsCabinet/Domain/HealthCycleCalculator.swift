import Foundation

enum HealthReminderType: String, CaseIterable, Codable, Identifiable {
    case externalDeworming
    case internalDeworming
    case vaccination

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .externalDeworming:
            return "体外驱虫"
        case .internalDeworming:
            return "体内驱虫"
        case .vaccination:
            return "疫苗"
        }
    }
}

enum HealthCycleCalculator {
    static func nextReminderDate(
        completedDate: Date,
        cycleValue: Int,
        cycleUnit: CycleUnit,
        calendar: Calendar = .current
    ) -> Date {
        DateMath.adding(cycleValue, unit: cycleUnit, to: completedDate, calendar: calendar)
    }

    static func daysRemaining(today: Date, nextReminderDate: Date, calendar: Calendar = .current) -> Int {
        DateMath.daysBetween(today, nextReminderDate, calendar: calendar)
    }
}
