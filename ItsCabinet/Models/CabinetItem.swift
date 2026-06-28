import Foundation
import SwiftData

@Model
final class CabinetItem {
    var id: UUID
    var name: String
    var productionDate: Date
    var shelfLifeValue: Int
    var shelfLifeUnitRawValue: String
    var expiryDate: Date
    var quantity: Int
    var unit: String
    var reminderRuleGroupId: UUID?
    var customReminderDays: Int?
    var note: String?
    @Attribute(.externalStorage) var imageData: Data?
    var isUsed: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        productionDate: Date,
        shelfLifeValue: Int,
        shelfLifeUnit: ShelfLifeUnit,
        expiryDate: Date,
        quantity: Int,
        unit: String,
        reminderRuleGroupId: UUID? = nil,
        customReminderDays: Int? = nil,
        note: String? = nil,
        imageData: Data? = nil,
        isUsed: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.productionDate = productionDate
        self.shelfLifeValue = shelfLifeValue
        self.shelfLifeUnitRawValue = shelfLifeUnit.rawValue
        self.expiryDate = expiryDate
        self.quantity = quantity
        self.unit = unit
        self.reminderRuleGroupId = reminderRuleGroupId
        self.customReminderDays = customReminderDays
        self.note = note
        self.imageData = imageData
        self.isUsed = isUsed
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var shelfLifeUnit: ShelfLifeUnit {
        get { ShelfLifeUnit(rawValue: shelfLifeUnitRawValue) ?? .days }
        set { shelfLifeUnitRawValue = newValue.rawValue }
    }
}
