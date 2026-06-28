import Foundation
import SwiftData

enum DefaultDataSeeder {
    static func seedIfNeeded(
        modelContext: ModelContext,
        now: Date = .now,
        calendar: Calendar = .current
    ) throws {
        try seedSettingsIfNeeded(modelContext: modelContext)
        try seedRuleGroupIfNeeded(modelContext: modelContext)
        try seedHealthRemindersIfNeeded(modelContext: modelContext, now: now, calendar: calendar)
        try modelContext.save()
    }

    private static func seedSettingsIfNeeded(modelContext: ModelContext) throws {
        let settings = try modelContext.fetch(FetchDescriptor<AppSettings>())
        if settings.isEmpty {
            modelContext.insert(AppSettings(defaultReminderHour: 9, defaultReminderMinute: 0))
        }
    }

    private static func seedRuleGroupIfNeeded(modelContext: ModelContext) throws {
        let groups = try modelContext.fetch(FetchDescriptor<ReminderRuleGroup>())
        let hasSystemPreset = groups.contains { $0.isSystemPreset && $0.name == "通用动态规则" }
        if hasSystemPreset {
            return
        }

        let bands = RuleLibrarySeed.systemPresetBands.map {
            ReminderRuleBand(
                minShelfLifeDays: $0.minShelfLifeDays,
                maxShelfLifeDays: $0.maxShelfLifeDays,
                warningDaysBeforeExpiry: $0.warningDaysBeforeExpiry
            )
        }
        modelContext.insert(ReminderRuleGroup(name: "通用动态规则", isSystemPreset: true, bands: bands))
    }

    private static func seedHealthRemindersIfNeeded(
        modelContext: ModelContext,
        now: Date,
        calendar: Calendar
    ) throws {
        let reminders = try modelContext.fetch(FetchDescriptor<HealthReminder>())
        let existingTypes = Set(reminders.map(\.type))

        for preset in healthPresets where !existingTypes.contains(preset.type) {
            modelContext.insert(HealthReminder(
                type: preset.type,
                lastCompletedDate: now,
                cycleValue: preset.cycleValue,
                cycleUnit: .months,
                nextReminderDate: HealthCycleCalculator.nextReminderDate(
                    completedDate: now,
                    cycleValue: preset.cycleValue,
                    cycleUnit: .months,
                    calendar: calendar
                )
            ))
        }
    }

    private static let healthPresets: [(type: HealthReminderType, cycleValue: Int)] = [
        (.externalDeworming, 1),
        (.internalDeworming, 3),
        (.vaccination, 11)
    ]
}
