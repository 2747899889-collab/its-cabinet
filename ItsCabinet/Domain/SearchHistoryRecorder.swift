import Foundation
import SwiftData

enum SearchHistoryRecorder {
    static func record(
        _ query: String,
        modelContext: ModelContext,
        now: Date = .now,
        limit: Int = 10
    ) throws {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        var descriptor = FetchDescriptor<SearchHistoryEntry>(
            sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit + 1
        let entries = try modelContext.fetch(descriptor)

        if let existing = entries.first(where: { $0.query == trimmed }) {
            existing.searchedAt = now
        } else {
            modelContext.insert(SearchHistoryEntry(query: trimmed, searchedAt: now))
        }

        let allEntries = try modelContext.fetch(FetchDescriptor<SearchHistoryEntry>(
            sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]
        ))
        for entry in allEntries.dropFirst(limit) {
            modelContext.delete(entry)
        }
        try modelContext.save()
    }

    static func recordWhenSearchIsCleared(
        previousText: String,
        currentText: String,
        modelContext: ModelContext,
        now: Date = .now,
        limit: Int = 10
    ) throws {
        guard currentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        try record(previousText, modelContext: modelContext, now: now, limit: limit)
    }
}
