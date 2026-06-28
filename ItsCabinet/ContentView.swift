import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        RootTabView()
            .task {
                do {
                    try DefaultDataSeeder.seedIfNeeded(modelContext: modelContext)
                } catch {
                    assertionFailure("Failed to seed default data: \(error)")
                }
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container())
}
