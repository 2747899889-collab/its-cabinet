import SwiftData
import XCTest
@testable import ItsCabinet

final class SearchHistoryRecorderTests: XCTestCase {
    func testRecordKeepsOnlyTenMostRecentQueries() throws {
        let context = try makeContext()

        for index in 1...11 {
            try SearchHistoryRecorder.record("关键词\(index)", modelContext: context)
        }

        let entries = try context.fetch(FetchDescriptor<SearchHistoryEntry>(
            sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]
        ))

        XCTAssertEqual(entries.map(\.query), (2...11).reversed().map { "关键词\($0)" })
    }

    func testRecordMovesExistingQueryToMostRecent() throws {
        let context = try makeContext()

        try SearchHistoryRecorder.record("猫粮", modelContext: context)
        try SearchHistoryRecorder.record("驱虫", modelContext: context)
        try SearchHistoryRecorder.record("猫粮", modelContext: context)

        let entries = try context.fetch(FetchDescriptor<SearchHistoryEntry>(
            sortBy: [SortDescriptor(\.searchedAt, order: .reverse)]
        ))

        XCTAssertEqual(entries.map(\.query), ["猫粮", "驱虫"])
    }

    func testRecordWhenSearchIsClearedSavesPreviousQuery() throws {
        let context = try makeContext()

        try SearchHistoryRecorder.recordWhenSearchIsCleared(
            previousText: "  猫粮  ",
            currentText: "",
            modelContext: context
        )

        let entries = try context.fetch(FetchDescriptor<SearchHistoryEntry>())
        XCTAssertEqual(entries.map(\.query), ["猫粮"])
    }

    private func makeContext() throws -> ModelContext {
        let schema = Schema([SearchHistoryEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }
}
