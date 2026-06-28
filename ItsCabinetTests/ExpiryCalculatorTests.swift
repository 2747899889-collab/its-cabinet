import XCTest
@testable import ItsCabinet

final class ExpiryCalculatorTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testExpiryDateAddsShelfLifeDays() throws {
        let production = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))

        let expiry = ExpiryCalculator.expiryDate(
            productionDate: production,
            shelfLifeValue: 30,
            shelfLifeUnit: .days,
            calendar: calendar
        )

        XCTAssertEqual(calendar.component(.year, from: expiry), 2026)
        XCTAssertEqual(calendar.component(.month, from: expiry), 1)
        XCTAssertEqual(calendar.component(.day, from: expiry), 31)
    }

    func testExpiryDateAddsShelfLifeMonths() throws {
        let production = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 15)))

        let expiry = ExpiryCalculator.expiryDate(
            productionDate: production,
            shelfLifeValue: 2,
            shelfLifeUnit: .months,
            calendar: calendar
        )

        XCTAssertEqual(calendar.component(.year, from: expiry), 2026)
        XCTAssertEqual(calendar.component(.month, from: expiry), 3)
        XCTAssertEqual(calendar.component(.day, from: expiry), 15)
    }

    func testRuleBandSelectionForMediumStorage() {
        let bands = RuleLibrarySeed.systemPresetBands

        let warningDays = ExpiryCalculator.warningDaysBeforeExpiry(shelfLifeDays: 200, bands: bands)

        XCTAssertEqual(warningDays, 30)
    }

    func testStatusIsWarningWhenTodayIsInsideWarningWindow() throws {
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 20)))
        let expiry = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 31)))

        let status = ExpiryCalculator.status(today: today, expiryDate: expiry, warningDays: 15, calendar: calendar)

        XCTAssertEqual(status, .warning(daysRemaining: 11))
    }

    func testStatusIsExpiredAfterExpiryDate() throws {
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 2, day: 2)))
        let expiry = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 31)))

        let status = ExpiryCalculator.status(today: today, expiryDate: expiry, warningDays: 15, calendar: calendar)

        XCTAssertEqual(status, .expired(daysOverdue: 2))
    }
}
