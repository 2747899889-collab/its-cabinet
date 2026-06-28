import Foundation

enum NotificationPlanner {
    static func cabinetPlans(
        for item: CabinetItem,
        warningDate: Date,
        reminderHour: Int,
        reminderMinute: Int,
        notificationsEnabled: Bool = true,
        calendar: Calendar = .current
    ) -> [NotificationPlan] {
        guard notificationsEnabled else {
            return []
        }

        return [
            NotificationPlan(
                identifier: "cabinet.warning.\(item.id.uuidString)",
                title: "\(item.name) 即将过期",
                body: "请尽快检查库存。",
                fireDate: reminderDate(
                    from: warningDate,
                    hour: reminderHour,
                    minute: reminderMinute,
                    calendar: calendar
                )
            ),
            NotificationPlan(
                identifier: "cabinet.expiry.\(item.id.uuidString)",
                title: "\(item.name) 已到期",
                body: "请确认是否需要处理。",
                fireDate: reminderDate(
                    from: item.expiryDate,
                    hour: reminderHour,
                    minute: reminderMinute,
                    calendar: calendar
                )
            )
        ]
    }

    static func healthPlan(
        for reminder: HealthReminder,
        reminderHour: Int,
        reminderMinute: Int,
        notificationsEnabled: Bool = true,
        calendar: Calendar = .current
    ) -> NotificationPlan? {
        guard notificationsEnabled else {
            return nil
        }

        return NotificationPlan(
            identifier: "health.\(reminder.id.uuidString)",
            title: "\(reminder.type.displayName)提醒",
            body: "今天需要完成\(reminder.type.displayName)。",
            fireDate: reminderDate(
                from: reminder.nextReminderDate,
                hour: reminderHour,
                minute: reminderMinute,
                calendar: calendar
            )
        )
    }

    private static func reminderDate(
        from date: Date,
        hour: Int,
        minute: Int,
        calendar: Calendar
    ) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: DateComponents(
            calendar: calendar,
            year: components.year,
            month: components.month,
            day: components.day,
            hour: hour,
            minute: minute
        )) ?? date
    }
}
