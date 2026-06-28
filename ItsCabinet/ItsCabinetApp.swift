import SwiftUI
import SwiftData

@main
struct ItsCabinetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            CabinetItem.self,
            ReminderRuleGroup.self,
            ReminderRuleBand.self,
            HealthReminder.self,
            AppSettings.self,
            SearchHistoryEntry.self
        ])
    }
}
