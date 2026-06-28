import SwiftData
import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = Tab.cabinet

    var body: some View {
        TabView(selection: $selectedTab) {
            CabinetView()
                .tabItem {
                    Label("柜子", systemImage: "cabinet")
                }
                .tag(Tab.cabinet)

            SearchView()
            .tabItem {
                Label("搜索", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)

            AddItemView {
                selectedTab = .cabinet
            }
            .tabItem {
                Label("添加", systemImage: "plus.circle.fill")
            }
            .tag(Tab.add)

            HealthView()
            .tabItem {
                Label("健康", systemImage: "calendar")
            }
            .tag(Tab.health)

            SettingsView()
            .tabItem {
                Label("我的", systemImage: "person.crop.circle")
            }
            .tag(Tab.settings)
        }
    }
}

private enum Tab: Hashable {
    case cabinet
    case search
    case add
    case health
    case settings
}

#Preview {
    RootTabView()
        .modelContainer(PreviewData.container())
}
