import Foundation
import SwiftData

@Model
final class HealthReminder {
    var id: UUID
    var typeRawValue: String
    var lastCompletedDate: Date
    var cycleValue: Int
    var cycleUnitRawValue: String
    var nextReminderDate: Date
    var isEnabled: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        type: HealthReminderType,
        lastCompletedDate: Date,
        cycleValue: Int,
        cycleUnit: CycleUnit,
        nextReminderDate: Date,
        isEnabled: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.typeRawValue = type.rawValue
        self.lastCompletedDate = lastCompletedDate
        self.cycleValue = cycleValue
        self.cycleUnitRawValue = cycleUnit.rawValue
        self.nextReminderDate = nextReminderDate
        self.isEnabled = isEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var type: HealthReminderType {
        get { HealthReminderType(rawValue: typeRawValue) ?? .externalDeworming }
        set { typeRawValue = newValue.rawValue }
    }

    var cycleUnit: CycleUnit {
        get { CycleUnit(rawValue: cycleUnitRawValue) ?? .months }
        set { cycleUnitRawValue = newValue.rawValue }
    }
}
