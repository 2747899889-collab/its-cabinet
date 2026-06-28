import SwiftData
import SwiftUI

struct RuleLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ruleGroups: [ReminderRuleGroup]

    var body: some View {
        List {
            ForEach(sortedRuleGroups, id: \.id) { group in
                Section {
                    ForEach(group.bands, id: \.id) { band in
                        RuleBandRow(band: band)
                    }

                    if !group.isSystemPreset {
                        Button(role: .destructive) {
                            deleteGroup(group)
                        } label: {
                            Label("删除规则组", systemImage: "trash")
                        }
                    }
                } header: {
                    HStack {
                        Text(group.name)
                        if group.isSystemPreset {
                            Text("系统")
                        }
                    }
                }
            }
        }
        .navigationTitle("提醒规则库")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    addCustomRule()
                } label: {
                    Label("新增", systemImage: "plus")
                }
            }
        }
    }

    private var sortedRuleGroups: [ReminderRuleGroup] {
        ruleGroups.sorted {
            if $0.isSystemPreset != $1.isSystemPreset {
                return $0.isSystemPreset
            }
            return $0.createdAt < $1.createdAt
        }
    }

    private func addCustomRule() {
        let group = ReminderRuleGroup(
            name: "我的规则",
            isSystemPreset: false,
            bands: [
                ReminderRuleBand(
                    minShelfLifeDays: nil,
                    maxShelfLifeDays: nil,
                    warningDaysBeforeExpiry: 7
                )
            ]
        )
        modelContext.insert(group)
        try? modelContext.save()
    }

    private func deleteGroup(_ group: ReminderRuleGroup) {
        guard !group.isSystemPreset else {
            return
        }
        modelContext.delete(group)
        try? modelContext.save()
    }
}

private struct RuleBandRow: View {
    let band: ReminderRuleBand

    var body: some View {
        HStack {
            Text(rangeText)
            Spacer()
            Text("提前\(band.warningDaysBeforeExpiry)天")
                .foregroundStyle(.secondary)
        }
    }

    private var rangeText: String {
        switch (band.minShelfLifeDays, band.maxShelfLifeDays) {
        case let (min?, max?):
            return "\(min)-\(max - 1)天"
        case let (min?, nil):
            return "\(min)天及以上"
        case let (nil, max?):
            return "少于\(max)天"
        case (nil, nil):
            return "全部保质期"
        }
    }
}

#Preview {
    NavigationStack {
        RuleLibraryView()
    }
    .modelContainer(PreviewData.container())
}
