import SwiftData
import SwiftUI

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [CabinetItem]
    @Query(sort: \SearchHistoryEntry.searchedAt, order: .reverse) private var searchHistory: [SearchHistoryEntry]
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if trimmedSearchText.isEmpty {
                    historyContent
                } else if filteredItems.isEmpty {
                    ContentUnavailableView("没有找到结果", systemImage: "tray")
                } else {
                    List(filteredItems, id: \.id) { item in
                        CabinetItemRow(item: item, status: status(for: item))
                    }
                }
            }
            .navigationTitle("搜索")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "输入名称或备注")
            .onSubmit(of: .search) {
                recordSearch()
            }
            .onChange(of: searchText) { oldValue, newValue in
                try? SearchHistoryRecorder.recordWhenSearchIsCleared(
                    previousText: oldValue,
                    currentText: newValue,
                    modelContext: modelContext
                )
            }
            .onDisappear {
                recordSearch()
            }
        }
    }

    @ViewBuilder
    private var historyContent: some View {
        if searchHistory.isEmpty {
            ContentUnavailableView("暂无搜索历史", systemImage: "magnifyingglass")
        } else {
            List {
                Section("搜索历史") {
                    ForEach(searchHistory, id: \.id) { entry in
                        Button {
                            searchText = entry.query
                            recordSearch()
                        } label: {
                            Label(entry.query, systemImage: "clock")
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                delete(entry)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var filteredItems: [CabinetItem] {
        items
            .filter { !$0.isUsed }
            .filter { item in
                item.name.localizedStandardContains(trimmedSearchText)
                    || (item.note?.localizedStandardContains(trimmedSearchText) ?? false)
            }
            .sorted { $0.expiryDate < $1.expiryDate }
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

    private func recordSearch() {
        try? SearchHistoryRecorder.record(trimmedSearchText, modelContext: modelContext)
    }

    private func delete(_ entry: SearchHistoryEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
    }
}

#Preview {
    SearchView()
        .modelContainer(PreviewData.container())
}
