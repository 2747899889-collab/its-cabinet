import Foundation
import SwiftData

@Model
final class SearchHistoryEntry {
    var id: UUID
    var query: String
    var searchedAt: Date

    init(id: UUID = UUID(), query: String, searchedAt: Date = .now) {
        self.id = id
        self.query = query
        self.searchedAt = searchedAt
    }
}
