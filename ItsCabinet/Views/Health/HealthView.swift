import SwiftData
import SwiftUI

struct HealthView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reminders: [HealthReminder]
    @Query private var settings: [AppSettings]

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedReminders, id: \.id) { reminder in
                    HealthReminderRow(
                        reminder: reminder,
                        reminderHour: settings.first?.defaultReminderHour ?? 9,
                        reminderMinute: settings.first?.defaultReminderMinute ?? 0,
                        notificationsEnabled: settings.first?.notificationsEnabled ?? true,
                        save: save
                    )
                }
            }
            .overlay {
                if sortedReminders.isEmpty {
                    ContentUnavailableView("暂无健康提醒", systemImage: "calendar")
                }
            }
            .navigationTitle("健康提醒")
        }
    }

    private var sortedReminders: [HealthReminder] {
        reminders.sorted { $0.type.displayName < $1.type.displayName }
    }

    private func save() {
        try? modelContext.save()
    }
}

private struct HealthReminderRow: View {
    @Bindable var reminder: HealthReminder
    let reminderHour: Int
    let reminderMinute: Int
    let notificationsEnabled: Bool
    let save: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminder.type.displayName)
                        .font(.headline)

                    Text(nextDateText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(daysText)
                    .font(.title2.bold())
                    .foregroundStyle(daysColor)
                    .monospacedDigit()
            }

            Toggle("启用提醒", isOn: $reminder.isEnabled)
                .onChange(of: reminder.isEnabled) { _, _ in
                    touchAndSave()
                }

            DatePicker("最近完成", selection: $reminder.lastCompletedDate, displayedComponents: .date)
                .onChange(of: reminder.lastCompletedDate) { _, _ in
                    recalculateNextDate()
                }

            Stepper("周期：\(reminder.cycleValue)\(cycleUnitText)", value: $reminder.cycleValue, in: 1...36)
                .onChange(of: reminder.cycleValue) { _, _ in
                    recalculateNextDate()
                }

            Picker("周期单位", selection: $reminder.cycleUnit) {
                Text("天").tag(CycleUnit.days)
                Text("月").tag(CycleUnit.months)
            }
            .onChange(of: reminder.cycleUnit) { _, _ in
                recalculateNextDate()
            }

            Button {
                completeNow()
            } label: {
                Label("我已完成本次", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 8)
    }

    private var daysRemaining: Int {
        HealthCycleCalculator.daysRemaining(today: .now, nextReminderDate: reminder.nextReminderDate)
    }

    private var daysText: String {
        if daysRemaining < 0 {
            return "逾期\(abs(daysRemaining))天"
        }
        return "\(daysRemaining)天"
    }

    private var daysColor: Color {
        daysRemaining < 0 ? .red : .accentColor
    }

    private var nextDateText: String {
        "下次：\(reminder.nextReminderDate.formatted(.dateTime.year().month().day()))"
    }

    private var cycleUnitText: String {
        switch reminder.cycleUnit {
        case .days:
            return "天"
        case .months:
            return "月"
        }
    }

    private func completeNow() {
        reminder.lastCompletedDate = .now
        recalculateNextDate()
        scheduleNextNotification()
    }

    private func recalculateNextDate() {
        reminder.nextReminderDate = HealthCycleCalculator.nextReminderDate(
            completedDate: reminder.lastCompletedDate,
            cycleValue: reminder.cycleValue,
            cycleUnit: reminder.cycleUnit
        )
        touchAndSave()
    }

    private func touchAndSave() {
        reminder.updatedAt = .now
        save()
    }

    private func scheduleNextNotification() {
        guard reminder.isEnabled else {
            return
        }
        guard let plan = NotificationPlanner.healthPlan(
            for: reminder,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute,
            notificationsEnabled: notificationsEnabled
        ) else { return }
        Task {
            try? await NotificationScheduler().schedule([plan])
        }
    }
}

#Preview {
    HealthView()
        .modelContainer(PreviewData.container())
}
