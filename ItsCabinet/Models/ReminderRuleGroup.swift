import Foundation
import SwiftData

@Model
final class ReminderRuleGroup {
    var id: UUID
    var name: String
    var isSystemPreset: Bool
    @Relationship(deleteRule: .cascade) var bands: [ReminderRuleBand]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        isSystemPreset: Bool = false,
        bands: [ReminderRuleBand] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.isSystemPreset = isSystemPreset
        self.bands = bands
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class ReminderRuleBand {
    var id: UUID
    var minShelfLifeDays: Int?
    var maxShelfLifeDays: Int?
    var warningDaysBeforeExpiry: Int

    init(
        id: UUID = UUID(),
        minShelfLifeDays: Int? = nil,
        maxShelfLifeDays: Int? = nil,
        warningDaysBeforeExpiry: Int
    ) {
        self.id = id
        self.minShelfLifeDays = minShelfLifeDays
        self.maxShelfLifeDays = maxShelfLifeDays
        self.warningDaysBeforeExpiry = warningDaysBeforeExpiry
    }

    var domainBand: RuleBand {
        RuleBand(
            id: id,
            minShelfLifeDays: minShelfLifeDays,
            maxShelfLifeDays: maxShelfLifeDays,
            warningDaysBeforeExpiry: warningDaysBeforeExpiry
        )
    }
}
