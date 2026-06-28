import XCTest
@testable import ItsCabinet

final class HealthCycleCalculatorTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testNextReminderAddsCycleDays() throws {
        let completed = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))

        let next = HealthCycleCalculator.nextReminderDate(
            completedDate: completed,
            cycleValue: 30,
            cycleUnit: .days,
            calendar: calendar
        )

        XCTAssertEqual(calendar.component(.year, from: next), 2026)
        XCTAssertEqual(calendar.component(.month, from: next), 1)
        XCTAssertEqual(calendar.component(.day, from: next), 31)
    }

    func testNextReminderAddsCycleMonths() throws {
        let completed = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 15)))

        let next = HealthCycleCalculator.nextReminderDate(
            completedDate: completed,
            cycleValue: 3,
            cycleUnit: .months,
            calendar: calendar
        )

        XCTAssertEqual(calendar.component(.year, from: next), 2026)
        XCTAssertEqual(calendar.component(.month, from: next), 4)
        XCTAssertEqual(calendar.component(.day, from: next), 15)
    }

    func testDaysRemainingCanBeNegativeWhenOverdue() throws {
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 2)))
        let next = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 1)))

        XCTAssertEqual(HealthCycleCalculator.daysRemaining(today: today, nextReminderDate: next, calendar: calendar), -1)
    }

    func testHealthReminderTypesHaveChineseDisplayNames() {
        XCTAssertEqual(HealthReminderType.externalDeworming.displayName, "体外驱虫")
        XCTAssertEqual(HealthReminderType.internalDeworming.displayName, "体内驱虫")
        XCTAssertEqual(HealthReminderType.vaccination.displayName, "疫苗")
    }
}
