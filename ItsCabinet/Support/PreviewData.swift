import Foundation
import SwiftData

@MainActor
enum PreviewData {
    static func container() -> ModelContainer {
        let schema = Schema([
            CabinetItem.self,
            ReminderRuleGroup.self,
            ReminderRuleBand.self,
            HealthReminder.self,
            AppSettings.self,
            SearchHistoryEntry.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        seed(ModelContext(container))
        return container
    }

    private static func seed(_ context: ModelContext) {
        let today = Calendar.current.startOfDay(for: .now)
        let ruleGroup = ReminderRuleGroup(
            name: "通用动态规则",
            isSystemPreset: true,
            bands: RuleLibrarySeed.systemPresetBands.map {
                ReminderRuleBand(
                    minShelfLifeDays: $0.minShelfLifeDays,
                    maxShelfLifeDays: $0.maxShelfLifeDays,
                    warningDaysBeforeExpiry: $0.warningDaysBeforeExpiry
                )
            }
        )

        context.insert(AppSettings(defaultReminderHour: 9, defaultReminderMinute: 0))
        context.insert(ruleGroup)

        let items = [
            CabinetItem(
                name: "幼猫主粮",
                productionDate: today.addingTimeInterval(-340 * 24 * 60 * 60),
                shelfLifeValue: 12,
                shelfLifeUnit: .months,
                expiryDate: today.addingTimeInterval(25 * 24 * 60 * 60),
                quantity: 2,
                unit: "包",
                reminderRuleGroupId: ruleGroup.id,
                note: "鸡肉配方"
            ),
            CabinetItem(
                name: "冻干零食",
                productionDate: today.addingTimeInterval(-120 * 24 * 60 * 60),
                shelfLifeValue: 180,
                shelfLifeUnit: .days,
                expiryDate: today.addingTimeInterval(55 * 24 * 60 * 60),
                quantity: 1,
                unit: "罐",
                reminderRuleGroupId: ruleGroup.id
            ),
            CabinetItem(
                name: "羊奶粉",
                productionDate: today.addingTimeInterval(-210 * 24 * 60 * 60),
                shelfLifeValue: 180,
                shelfLifeUnit: .days,
                expiryDate: today.addingTimeInterval(-3 * 24 * 60 * 60),
                quantity: 1,
                unit: "盒",
                reminderRuleGroupId: ruleGroup.id
            )
        ]
        items.forEach(context.insert)

        let healthReminders = [
            HealthReminder(
                type: .externalDeworming,
                lastCompletedDate: today.addingTimeInterval(-20 * 24 * 60 * 60),
                cycleValue: 1,
                cycleUnit: .months,
                nextReminderDate: today.addingTimeInterval(10 * 24 * 60 * 60)
            ),
            HealthReminder(
                type: .internalDeworming,
                lastCompletedDate: today.addingTimeInterval(-100 * 24 * 60 * 60),
                cycleValue: 3,
                cycleUnit: .months,
                nextReminderDate: today.addingTimeInterval(-10 * 24 * 60 * 60)
            ),
            HealthReminder(
                type: .vaccination,
                lastCompletedDate: today.addingTimeInterval(-40 * 24 * 60 * 60),
                cycleValue: 11,
                cycleUnit: .months,
                nextReminderDate: today.addingTimeInterval(290 * 24 * 60 * 60)
            )
        ]
        healthReminders.forEach(context.insert)

        ["猫粮", "冻干", "驱虫"].forEach {
            context.insert(SearchHistoryEntry(query: $0))
        }

        try? context.save()
    }
}
