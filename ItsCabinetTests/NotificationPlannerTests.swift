import XCTest
@testable import ItsCabinet

final class NotificationPlannerTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testCabinetItemPlansWarningAndExpiryNotifications() throws {
        let itemId = try XCTUnwrap(UUID(uuidString: "11111111-1111-1111-1111-111111111111"))
        let productionDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
        let expiryDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 2, day: 1)))
        let warningDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 22)))
        let item = CabinetItem(
            id: itemId,
            name: "幼猫主粮",
            productionDate: productionDate,
            shelfLifeValue: 31,
            shelfLifeUnit: .days,
            expiryDate: expiryDate,
            quantity: 2,
            unit: "包"
        )

        let plans = NotificationPlanner.cabinetPlans(
            for: item,
            warningDate: warningDate,
            reminderHour: 9,
            reminderMinute: 0,
            calendar: calendar
        )

        XCTAssertEqual(plans.map(\.identifier), [
            "cabinet.warning.11111111-1111-1111-1111-111111111111",
            "cabinet.expiry.11111111-1111-1111-1111-111111111111"
        ])
        XCTAssertEqual(calendar.component(.day, from: plans[0].fireDate), 22)
        XCTAssertEqual(calendar.component(.day, from: plans[1].fireDate), 1)
        XCTAssertEqual(calendar.component(.hour, from: plans[0].fireDate), 9)
        XCTAssertEqual(calendar.component(.minute, from: plans[1].fireDate), 0)
    }

    func testCabinetItemPlansAreEmptyWhenNotificationsDisabled() throws {
        let productionDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
        let expiryDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 2, day: 1)))
        let warningDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 22)))
        let item = CabinetItem(
            name: "幼猫主粮",
            productionDate: productionDate,
            shelfLifeValue: 31,
            shelfLifeUnit: .days,
            expiryDate: expiryDate,
            quantity: 2,
            unit: "包"
        )

        let plans = NotificationPlanner.cabinetPlans(
            for: item,
            warningDate: warningDate,
            reminderHour: 9,
            reminderMinute: 0,
            notificationsEnabled: false,
            calendar: calendar
        )

        XCTAssertTrue(plans.isEmpty)
    }

    func testHealthReminderPlansOnlyNextNotification() throws {
        let reminderId = try XCTUnwrap(UUID(uuidString: "22222222-2222-2222-2222-222222222222"))
        let completedDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
        let nextDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 2, day: 1)))
        let reminder = HealthReminder(
            id: reminderId,
            type: .externalDeworming,
            lastCompletedDate: completedDate,
            cycleValue: 1,
            cycleUnit: .months,
            nextReminderDate: nextDate
        )

        let plan = try XCTUnwrap(NotificationPlanner.healthPlan(
            for: reminder,
            reminderHour: 9,
            reminderMinute: 0,
            calendar: calendar
        ))

        XCTAssertEqual(plan.identifier, "health.22222222-2222-2222-2222-222222222222")
        XCTAssertEqual(calendar.component(.month, from: plan.fireDate), 2)
        XCTAssertEqual(calendar.component(.day, from: plan.fireDate), 1)
        XCTAssertEqual(calendar.component(.hour, from: plan.fireDate), 9)
    }

    func testHealthReminderPlanIsNilWhenNotificationsDisabled() throws {
        let completedDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
        let nextDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 2, day: 1)))
        let reminder = HealthReminder(
            type: .externalDeworming,
            lastCompletedDate: completedDate,
            cycleValue: 1,
            cycleUnit: .months,
            nextReminderDate: nextDate
        )

        let plan = NotificationPlanner.healthPlan(
            for: reminder,
            reminderHour: 9,
            reminderMinute: 0,
            notificationsEnabled: false,
            calendar: calendar
        )

        XCTAssertNil(plan)
    }
}
