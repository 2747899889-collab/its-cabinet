import Foundation

struct RuleBand: Equatable, Codable, Identifiable {
    var id = UUID()
    var minShelfLifeDays: Int?
    var maxShelfLifeDays: Int?
    var warningDaysBeforeExpiry: Int

    func contains(shelfLifeDays: Int) -> Bool {
        if let minShelfLifeDays, shelfLifeDays < minShelfLifeDays {
            return false
        }
        if let maxShelfLifeDays, shelfLifeDays >= maxShelfLifeDays {
            return false
        }
        return true
    }
}

enum RuleLibrarySeed {
    static let systemPresetBands: [RuleBand] = [
        RuleBand(minShelfLifeDays: 365, maxShelfLifeDays: nil, warningDaysBeforeExpiry: 45),
        RuleBand(minShelfLifeDays: 180, maxShelfLifeDays: 365, warningDaysBeforeExpiry: 30),
        RuleBand(minShelfLifeDays: 90, maxShelfLifeDays: 180, warningDaysBeforeExpiry: 20),
        RuleBand(minShelfLifeDays: 30, maxShelfLifeDays: 90, warningDaysBeforeExpiry: 10),
        RuleBand(minShelfLifeDays: nil, maxShelfLifeDays: 30, warningDaysBeforeExpiry: 3)
    ]
}

enum ExpiryCalculator {
    static func expiryDate(
        productionDate: Date,
        shelfLifeValue: Int,
        shelfLifeUnit: ShelfLifeUnit,
        calendar: Calendar = .current
    ) -> Date {
        DateMath.adding(shelfLifeValue, unit: shelfLifeUnit, to: productionDate, calendar: calendar)
    }

    static func shelfLifeDays(
        productionDate: Date,
        expiryDate: Date,
        calendar: Calendar = .current
    ) -> Int {
        max(0, DateMath.daysBetween(productionDate, expiryDate, calendar: calendar))
    }

    static func warningDaysBeforeExpiry(shelfLifeDays: Int, bands: [RuleBand]) -> Int {
        bands.first { $0.contains(shelfLifeDays: shelfLifeDays) }?.warningDaysBeforeExpiry ?? 7
    }

    static func warningDate(expiryDate: Date, warningDays: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: -warningDays, to: expiryDate) ?? expiryDate
    }

    static func status(today: Date, expiryDate: Date, warningDays: Int, calendar: Calendar = .current) -> ExpiryStatus {
        let daysRemaining = DateMath.daysBetween(today, expiryDate, calendar: calendar)
        if daysRemaining < 0 {
            return .expired(daysOverdue: abs(daysRemaining))
        }
        if daysRemaining <= warningDays {
            return .warning(daysRemaining: daysRemaining)
        }
        return .safe(daysRemaining: daysRemaining)
    }
}
