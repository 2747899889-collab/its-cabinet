import Foundation

enum ShelfLifeUnit: String, CaseIterable, Codable {
    case days
    case months
}

enum CycleUnit: String, CaseIterable, Codable {
    case days
    case months
}

enum ExpiryStatus: Equatable {
    case safe(daysRemaining: Int)
    case warning(daysRemaining: Int)
    case expired(daysOverdue: Int)
}

enum DateMath {
    static func adding(_ value: Int, unit: ShelfLifeUnit, to date: Date, calendar: Calendar = .current) -> Date {
        switch unit {
        case .days:
            return calendar.date(byAdding: .day, value: value, to: date) ?? date
        case .months:
            return calendar.date(byAdding: .month, value: value, to: date) ?? date
        }
    }

    static func adding(_ value: Int, unit: CycleUnit, to date: Date, calendar: Calendar = .current) -> Date {
        switch unit {
        case .days:
            return calendar.date(byAdding: .day, value: value, to: date) ?? date
        case .months:
            return calendar.date(byAdding: .month, value: value, to: date) ?? date
        }
    }

    static func daysBetween(_ start: Date, _ end: Date, calendar: Calendar = .current) -> Int {
        let startOfStart = calendar.startOfDay(for: start)
        let startOfEnd = calendar.startOfDay(for: end)
        return calendar.dateComponents([.day], from: startOfStart, to: startOfEnd).day ?? 0
    }
}
