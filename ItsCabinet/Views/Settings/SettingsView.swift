import SwiftUI
import SwiftData
import UIKit
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var settings: [AppSettings]

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        NavigationStack {
            List {
                Section("数据") {
                    LabeledContent("当前版本", value: "本地存储")
                    LabeledContent("云同步", value: "后续版本")
                }

                Section("提醒") {
                    Toggle("应用内提醒", isOn: notificationsEnabledBinding)

                    LabeledContent("通知权限", value: notificationStatusText)

                    if notificationStatus == .notDetermined {
                        Button {
                            Task {
                                await requestNotifications()
                            }
                        } label: {
                            Label("允许通知", systemImage: "bell")
                        }
                    } else {
                        Button {
                            openSystemSettings()
                        } label: {
                            Label(notificationStatus == .denied ? "去系统设置开启" : "去系统设置关闭", systemImage: "gear")
                        }
                    }

                    NavigationLink {
                        RuleLibraryView()
                    } label: {
                        Label("提醒规则库", systemImage: "bell.badge")
                    }
                }
            }
            .navigationTitle("我的")
            .task {
                await refreshNotificationStatus()
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                Task {
                    await refreshNotificationStatus()
                }
            }
        }
    }

    private var notificationStatusText: String {
        switch notificationStatus {
        case .notDetermined:
            "未请求"
        case .denied:
            "已关闭"
        case .authorized:
            "已开启"
        case .provisional:
            "临时开启"
        case .ephemeral:
            "临时开启"
        @unknown default:
            "未知"
        }
    }

    private var notificationsEnabledBinding: Binding<Bool> {
        Binding(
            get: { settings.first?.notificationsEnabled ?? true },
            set: { newValue in
                let setting = settings.first ?? AppSettings()
                if settings.first == nil {
                    modelContext.insert(setting)
                }
                setting.notificationsEnabled = newValue
                try? modelContext.save()

                if !newValue {
                    NotificationScheduler().cancelAllPending()
                }
            }
        )
    }

    @MainActor
    private func requestNotifications() async {
        _ = try? await NotificationScheduler().requestAuthorization()
        await refreshNotificationStatus()
    }

    @MainActor
    private func refreshNotificationStatus() async {
        notificationStatus = await NotificationScheduler().authorizationStatus()
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    SettingsView()
        .modelContainer(PreviewData.container())
}
