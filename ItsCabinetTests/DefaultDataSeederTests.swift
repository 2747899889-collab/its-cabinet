import SwiftData
import XCTest
@testable import ItsCabinet

final class DefaultDataSeederTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testSeedIfNeededCreatesDefaultsOnlyOnce() throws {
        let context = try makeContext()
        let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))

        try DefaultDataSeeder.seedIfNeeded(modelContext: context, now: now, calendar: calendar)
        try DefaultDataSeeder.seedIfNeeded(modelContext: context, now: now, calendar: calendar)

        let ruleGroups = try context.fetch(FetchDescriptor<ReminderRuleGroup>())
        let healthReminders = try context.fetch(FetchDescriptor<HealthReminder>())
        let settings = try context.fetch(FetchDescriptor<AppSettings>())

        XCTAssertEqual(ruleGroups.count, 1)
        XCTAssertEqual(ruleGroups.first?.name, "通用动态规则")
        XCTAssertEqual(ruleGroups.first?.bands.count, 5)
        XCTAssertEqual(healthReminders.count, 3)
        XCTAssertEqual(Set(healthReminders.map(\.type)), [.externalDeworming, .internalDeworming, .vaccination])
        XCTAssertEqual(settings.count, 1)
        XCTAssertEqual(settings.first?.defaultReminderHour, 9)
        XCTAssertEqual(settings.first?.defaultReminderMinute, 0)
    }

    private func makeContext() throws -> ModelContext {
        let schema = Schema([
            CabinetItem.self,
            ReminderRuleGroup.self,
            ReminderRuleBand.self,
            HealthReminder.self,
            AppSettings.self,
            SearchHistoryEntry.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }
}
