import SwiftData
import SwiftUI

struct CabinetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [CabinetItem]

    var body: some View {
        NavigationStack {
            Group {
                if sortedActiveItems.isEmpty {
                    ContentUnavailableView("柜子是空的", systemImage: "shippingbox")
                } else {
                    List {
                        ForEach(sortedActiveItems, id: \.id) { item in
                            CabinetItemRow(item: item, status: status(for: item))
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        delete(item)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }

                                    Button {
                                        markAsUsed(item)
                                    } label: {
                                        Label("吃完", systemImage: "checkmark.circle")
                                    }
                                    .tint(.green)
                                }
                        }
                    }
                }
            }
            .navigationTitle("它的柜子")
        }
    }

    private var sortedActiveItems: [CabinetItem] {
        items
            .filter { !$0.isUsed }
            .sorted { left, right in
                let leftStatus = status(for: left)
                let rightStatus = status(for: right)
                let leftPriority = priority(for: leftStatus)
                let rightPriority = priority(for: rightStatus)
                if leftPriority != rightPriority {
                    return leftPriority < rightPriority
                }
                return left.expiryDate < right.expiryDate
            }
    }

    private func status(for item: CabinetItem) -> ExpiryStatus {
        let shelfLifeDays = ExpiryCalculator.shelfLifeDays(
            productionDate: item.productionDate,
            expiryDate: item.expiryDate
        )
        let warningDays = item.customReminderDays ?? ExpiryCalculator.warningDaysBeforeExpiry(
            shelfLifeDays: shelfLifeDays,
            bands: RuleLibrarySeed.systemPresetBands
        )
        return ExpiryCalculator.status(today: .now, expiryDate: item.expiryDate, warningDays: warningDays)
    }

    private func priority(for status: ExpiryStatus) -> Int {
        switch status {
        case .expired:
            return 0
        case .warning:
            return 1
        case .safe:
            return 2
        }
    }

    private func markAsUsed(_ item: CabinetItem) {
        item.isUsed = true
        item.updatedAt = .now
        try? modelContext.save()
        cancelNotifications(for: item)
    }

    private func delete(_ item: CabinetItem) {
        cancelNotifications(for: item)
        modelContext.delete(item)
        try? modelContext.save()
    }

    private func cancelNotifications(for item: CabinetItem) {
        NotificationScheduler().cancel(identifiers: [
            "cabinet.warning.\(item.id.uuidString)",
            "cabinet.expiry.\(item.id.uuidString)"
        ])
    }
}

#Preview {
    CabinetView()
        .modelContainer(PreviewData.container())
}
