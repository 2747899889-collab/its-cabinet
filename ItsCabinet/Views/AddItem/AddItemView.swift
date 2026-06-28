import SwiftData
import SwiftUI
import PhotosUI
import UIKit

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ruleGroups: [ReminderRuleGroup]
    @Query private var settings: [AppSettings]

    let onSaved: () -> Void

    @State private var name = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var expiryInputMode = ExpiryInputMode.shelfLife
    @State private var productionDate = Date()
    @State private var shelfLifeValue = 12
    @State private var shelfLifeUnit = ShelfLifeUnit.months
    @State private var directExpiryDate = Calendar.current.date(byAdding: .month, value: 12, to: .now) ?? .now
    @State private var quantity = 1
    @State private var unit = "包"
    @State private var selectedRuleGroupId: UUID?
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("物品") {
                    TextField("物品名称", text: $name)
                        .textInputAutocapitalization(.never)

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack {
                            itemImagePreview

                            Text(selectedImageData == nil ? "添加图片" : "更换图片")
                                .foregroundStyle(.primary)

                            Spacer()
                        }
                    }
                }

                Section("过期") {
                    Picker("录入方式", selection: $expiryInputMode) {
                        Text("保质期").tag(ExpiryInputMode.shelfLife)
                        Text("保质期至").tag(ExpiryInputMode.expiryDate)
                    }
                    .pickerStyle(.segmented)

                    if expiryInputMode == .shelfLife {
                        DatePicker("生产日期", selection: $productionDate, displayedComponents: .date)

                        Stepper("保质期：\(shelfLifeValue)\(shelfLifeUnitText)", value: $shelfLifeValue, in: 1...3650)

                        Picker("保质期单位", selection: $shelfLifeUnit) {
                            Text("天").tag(ShelfLifeUnit.days)
                            Text("月").tag(ShelfLifeUnit.months)
                        }
                    } else {
                        DatePicker("保质期至", selection: $directExpiryDate, displayedComponents: .date)
                    }

                    LabeledContent("过期日期", value: expiryDate.formatted(.dateTime.year().month().day()))

                    Picker("提醒规则", selection: $selectedRuleGroupId) {
                        Text("通用动态规则").tag(Optional<UUID>.none)
                        ForEach(ruleGroups, id: \.id) { group in
                            Text(group.name).tag(Optional(group.id))
                        }
                    }
                }

                Section("库存") {
                    Stepper("数量：\(quantity)", value: $quantity, in: 1...999)

                    Picker("单位", selection: $unit) {
                        Text("件").tag("件")
                        Text("包").tag("包")
                        Text("罐").tag("罐")
                    }
                }

                Section("备注") {
                    TextField("可选", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("新增用品")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加", action: save)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newValue in
                Task {
                    selectedImageData = try? await newValue?.loadTransferable(type: Data.self)
                }
            }
        }
    }

    private var expiryDate: Date {
        if expiryInputMode == .expiryDate {
            return directExpiryDate
        }

        return ExpiryCalculator.expiryDate(
            productionDate: productionDate,
            shelfLifeValue: shelfLifeValue,
            shelfLifeUnit: shelfLifeUnit
        )
    }

    private var shelfLifeUnitText: String {
        switch shelfLifeUnit {
        case .days:
            return "天"
        case .months:
            return "月"
        }
    }

    @ViewBuilder
    private var itemImagePreview: some View {
        if let selectedImageData,
           let uiImage = UIImage(data: selectedImageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(.secondary.opacity(0.12))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "plus")
                        .foregroundStyle(.secondary)
                }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return
        }

        let item = CabinetItem(
            name: trimmedName,
            productionDate: storedProductionDate,
            shelfLifeValue: storedShelfLifeValue,
            shelfLifeUnit: storedShelfLifeUnit,
            expiryDate: expiryDate,
            quantity: quantity,
            unit: unit,
            reminderRuleGroupId: selectedRuleGroupId,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note,
            imageData: selectedImageData
        )
        modelContext.insert(item)
        try? modelContext.save()
        scheduleNotifications(for: item)
        reset()
        onSaved()
    }

    private func scheduleNotifications(for item: CabinetItem) {
        let shelfLifeDays = ExpiryCalculator.shelfLifeDays(
            productionDate: item.productionDate,
            expiryDate: item.expiryDate
        )
        let warningDays = ExpiryCalculator.warningDaysBeforeExpiry(
            shelfLifeDays: shelfLifeDays,
            bands: selectedRuleBands
        )
        let warningDate = ExpiryCalculator.warningDate(expiryDate: item.expiryDate, warningDays: warningDays)
        let setting = settings.first
        let plans = NotificationPlanner.cabinetPlans(
            for: item,
            warningDate: warningDate,
            reminderHour: setting?.defaultReminderHour ?? 9,
            reminderMinute: setting?.defaultReminderMinute ?? 0,
            notificationsEnabled: setting?.notificationsEnabled ?? true
        )

        Task {
            try? await NotificationScheduler().schedule(plans)
        }
    }

    private var selectedRuleBands: [RuleBand] {
        guard let selectedRuleGroupId,
              let group = ruleGroups.first(where: { $0.id == selectedRuleGroupId }) else {
            return RuleLibrarySeed.systemPresetBands
        }
        return group.bands.map(\.domainBand)
    }

    private func reset() {
        name = ""
        selectedPhotoItem = nil
        selectedImageData = nil
        expiryInputMode = .shelfLife
        productionDate = Date()
        shelfLifeValue = 12
        shelfLifeUnit = .months
        directExpiryDate = Calendar.current.date(byAdding: .month, value: 12, to: .now) ?? .now
        quantity = 1
        unit = "包"
        selectedRuleGroupId = nil
        note = ""
    }

    private var storedProductionDate: Date {
        expiryInputMode == .shelfLife ? productionDate : Calendar.current.startOfDay(for: .now)
    }

    private var storedShelfLifeValue: Int {
        if expiryInputMode == .shelfLife {
            return shelfLifeValue
        }

        return max(1, Calendar.current.dateComponents([.day], from: storedProductionDate, to: expiryDate).day ?? 1)
    }

    private var storedShelfLifeUnit: ShelfLifeUnit {
        expiryInputMode == .shelfLife ? shelfLifeUnit : .days
    }
}

private enum ExpiryInputMode: Hashable {
    case shelfLife
    case expiryDate
}

#Preview {
    AddItemView(onSaved: {})
        .modelContainer(PreviewData.container())
}
