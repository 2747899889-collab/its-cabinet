import SwiftData

@Model
final class AppSettings {
    var defaultReminderHour: Int
    var defaultReminderMinute: Int
    var notificationsEnabled: Bool?

    init(
        defaultReminderHour: Int = 9,
        defaultReminderMinute: Int = 0,
        notificationsEnabled: Bool = true
    ) {
        self.defaultReminderHour = defaultReminderHour
        self.defaultReminderMinute = defaultReminderMinute
        self.notificationsEnabled = notificationsEnabled
    }
}
