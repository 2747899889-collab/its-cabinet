# 「它的柜子」MVP 实现计划

> 执行方式：按任务逐步实现。每个任务都要先验证、再提交。当前目标不是一次性做完整商业版，而是先做出可以在 iPhone 模拟器运行、核心逻辑可测试、后续可上架准备的 V1.0 MVP。

## 目标

做一款 iOS 原生 App：

- 记录宠物食品/用品批次。
- 根据生产日期和保质期计算过期日。
- 根据提醒规则计算临期提醒。
- 支持体外驱虫、体内驱虫、疫苗三类健康周期提醒。
- 使用本地 SwiftData 存储。
- 使用 iOS 本地通知。
- V1.0 不做账号、云同步、扫码、图片上传、多宠、内购、广告。

## 技术栈

- Xcode 26.6
- Swift
- SwiftUI
- SwiftData
- XCTest
- UserNotifications
- 最低 iOS 17.0

## 成功标准

- `xcodebuild build` 成功。
- 核心日期/规则/通知计划逻辑有单元测试。
- App 能在 iPhone 模拟器启动。
- 可以手动新增用品并在列表中看到。
- 可以搜索本地用品。
- 可以查看并完成三类健康提醒。
- 可以管理本地提醒规则库。
- App Store 准备文档明确说明 V1.0 是本地数据，不承诺云同步。

## 文件结构

计划创建这些主要文件：

- `ItsCabinet.xcodeproj`：Xcode 项目。
- `ItsCabinet/ItsCabinetApp.swift`：App 入口和 SwiftData 容器。
- `ItsCabinet/ContentView.swift`：根视图。
- `ItsCabinet/Models/CabinetItem.swift`：用品批次模型。
- `ItsCabinet/Models/ReminderRuleGroup.swift`：提醒规则组和规则档位模型。
- `ItsCabinet/Models/HealthReminder.swift`：健康周期提醒模型。
- `ItsCabinet/Models/AppSettings.swift`：本地设置。
- `ItsCabinet/Domain/DateMath.swift`：日期计算工具。
- `ItsCabinet/Domain/ExpiryCalculator.swift`：过期日、临期日、状态计算。
- `ItsCabinet/Domain/HealthCycleCalculator.swift`：健康周期下一次日期计算。
- `ItsCabinet/Domain/DefaultDataSeeder.swift`：初始化预置规则和健康提醒。
- `ItsCabinet/Notifications/NotificationPlan.swift`：本地通知计划数据结构。
- `ItsCabinet/Notifications/NotificationPlanner.swift`：通知 ID 和通知内容规划。
- `ItsCabinet/Notifications/NotificationScheduler.swift`：调用 iOS 本地通知。
- `ItsCabinet/Views/RootTabView.swift`：底部导航和中央添加入口。
- `ItsCabinet/Views/Cabinet/CabinetView.swift`：柜子列表。
- `ItsCabinet/Views/Cabinet/CabinetItemRow.swift`：用品卡片行。
- `ItsCabinet/Views/AddItem/AddItemView.swift`：新增用品表单。
- `ItsCabinet/Views/Search/SearchView.swift`：本地搜索。
- `ItsCabinet/Views/Health/HealthView.swift`：健康提醒页。
- `ItsCabinet/Views/Settings/SettingsView.swift`：我的/设置页。
- `ItsCabinet/Views/Settings/RuleLibraryView.swift`：提醒规则库管理。
- `ItsCabinet/Support/PreviewData.swift`：SwiftUI 预览数据。
- `ItsCabinetTests/ExpiryCalculatorTests.swift`：过期逻辑测试。
- `ItsCabinetTests/HealthCycleCalculatorTests.swift`：健康周期测试。
- `ItsCabinetTests/NotificationPlannerTests.swift`：通知计划测试。
- `docs/app-store/v1-readiness.md`：上架准备说明。

---

## 任务 1：创建 iOS 原生项目

目标：创建一个能用 `xcodebuild` 构建的 SwiftUI iOS 项目。

修改/创建：

- `ItsCabinet.xcodeproj`
- `ItsCabinet/ItsCabinetApp.swift`
- `ItsCabinet/ContentView.swift`
- `ItsCabinetTests/ItsCabinetTests.swift`
- `.gitignore`

要求：

- 项目名：`ItsCabinet`
- Bundle ID：`com.local.ItsCabinet`
- 最低系统：iOS 17.0
- UI：SwiftUI
- 测试：XCTest
- 首页先显示大标题「它的柜子」
- `.gitignore` 包含：

```gitignore
.superpowers/
.worktrees/
xcuserdata/
DerivedData/
*.xcuserstate
```

验证：

```bash
xcodebuild -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' build
```

如果没有 `iPhone 16` 模拟器，先运行：

```bash
xcrun simctl list devices available
```

然后换成当前机器可用的 iPhone 模拟器。

提交：

```bash
git add .gitignore ItsCabinet.xcodeproj ItsCabinet ItsCabinetTests
git commit -m "chore: scaffold iOS app"
```

---

## 任务 2：实现过期计算核心逻辑

目标：先用测试锁定“生产日期 + 保质期 = 过期日”、“规则档位选择”、“安全/临期/已过期状态”。

创建：

- `ItsCabinet/Domain/DateMath.swift`
- `ItsCabinet/Domain/ExpiryCalculator.swift`
- `ItsCabinetTests/ExpiryCalculatorTests.swift`

核心规则：

- 保质期单位支持“天”和“月”。
- 长期保存：保质期 >= 365 天，提前 45 天临期。
- 中期保存：180-364 天，提前 30 天临期。
- 短期保存：90-179 天，提前 20 天临期。
- 鲜食级：30-89 天，提前 10 天临期。
- 临期级：少于 30 天，提前 3 天临期。

测试覆盖：

- 按天计算过期日。
- 按月计算过期日。
- 200 天保质期命中 30 天提醒。
- 今天进入提醒窗口时状态为临期。
- 超过过期日后状态为已过期。

验证：

```bash
xcodebuild test -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ItsCabinetTests/ExpiryCalculatorTests
```

提交：

```bash
git add ItsCabinet/Domain ItsCabinetTests/ExpiryCalculatorTests.swift
git commit -m "feat: add expiry calculation logic"
```

---

## 任务 3：实现健康周期计算

目标：实现体外驱虫、体内驱虫、疫苗的下一次提醒日期计算。

创建：

- `ItsCabinet/Domain/HealthCycleCalculator.swift`
- `ItsCabinetTests/HealthCycleCalculatorTests.swift`

规则：

- 健康类型固定三类：体外驱虫、体内驱虫、疫苗。
- 周期单位支持“天”和“月”。
- 下一次提醒日期 = 本次完成日期 + 周期。
- 剩余天数允许为负数，用于表示已逾期。

验证：

```bash
xcodebuild test -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ItsCabinetTests/HealthCycleCalculatorTests
```

提交：

```bash
git add ItsCabinet/Domain/HealthCycleCalculator.swift ItsCabinetTests/HealthCycleCalculatorTests.swift
git commit -m "feat: add health cycle calculation"
```

---

## 任务 4：添加 SwiftData 本地模型

目标：把 V1.0 数据落到本地 SwiftData。

创建：

- `ItsCabinet/Models/CabinetItem.swift`
- `ItsCabinet/Models/ReminderRuleGroup.swift`
- `ItsCabinet/Models/HealthReminder.swift`
- `ItsCabinet/Models/AppSettings.swift`

修改：

- `ItsCabinet/ItsCabinetApp.swift`

模型：

- `CabinetItem`：用品名称、生产日期、保质期、过期日期、数量、单位、规则组、提醒天数、备注、是否用完、创建/更新时间。
- `ReminderRuleGroup`：规则组名称、是否系统预置、规则档位。
- `ReminderRuleBand`：最小保质期天数、最大保质期天数、提前提醒天数。
- `HealthReminder`：健康类型、最近完成日期、周期、下次提醒日期、是否启用。
- `AppSettings`：默认提醒时间，默认 09:00。

明确不加：

- 账号 ID。
- 云端 ID。
- 同步状态字段。
- 付费/订阅字段。

验证：

```bash
xcodebuild -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' build
```

提交：

```bash
git add ItsCabinet/Models ItsCabinet/ItsCabinetApp.swift
git commit -m "feat: add local SwiftData models"
```

---

## 任务 5：实现本地通知计划

目标：先把“该发哪些通知、通知 ID 是什么”做成可测试逻辑，再接 iOS 通知系统。

创建：

- `ItsCabinet/Notifications/NotificationPlan.swift`
- `ItsCabinet/Notifications/NotificationPlanner.swift`
- `ItsCabinet/Notifications/NotificationScheduler.swift`
- `ItsCabinetTests/NotificationPlannerTests.swift`

规则：

- 用品临期通知 ID：`cabinet.warning.<用品ID>`
- 用品到期通知 ID：`cabinet.expiry.<用品ID>`
- 健康通知 ID：`health.<提醒ID>`
- 用品保存时计划两条通知：临期日、到期日。
- 健康提醒每次只计划下一次通知。

验证：

```bash
xcodebuild test -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ItsCabinetTests/NotificationPlannerTests
```

提交：

```bash
git add ItsCabinet/Notifications ItsCabinetTests/NotificationPlannerTests.swift
git commit -m "feat: add local notification planner"
```

---

## 任务 6：初始化本地默认数据

目标：首次启动时自动创建系统预置规则和三类健康提醒。

创建：

- `ItsCabinet/Domain/DefaultDataSeeder.swift`

修改：

- `ItsCabinet/ContentView.swift`

默认数据：

- 规则组：通用动态规则。
- 体外驱虫：默认 1 个月周期。
- 体内驱虫：默认 3 个月周期。
- 疫苗：默认 11 个月周期。
- 默认提醒时间：09:00。

验证：

```bash
xcodebuild -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' build
```

提交：

```bash
git add ItsCabinet/Domain/DefaultDataSeeder.swift ItsCabinet/ContentView.swift
git commit -m "feat: seed local defaults"
```

---

## 任务 7：实现底部导航和柜子列表

目标：做出 App 主框架和柜子首页。

创建：

- `ItsCabinet/Views/RootTabView.swift`
- `ItsCabinet/Views/Cabinet/CabinetView.swift`
- `ItsCabinet/Views/Cabinet/CabinetItemRow.swift`

修改：

- `ItsCabinet/ContentView.swift`

导航：

- 柜子
- 搜索
- 中央添加
- 健康
- 我的

柜子列表：

- 只显示未用完用品。
- 排序：已过期 > 临期 > 安全。
- 支持左滑删除。
- 支持左滑标记用完。
- 标记用完后从当前列表移除。

验证：

```bash
xcodebuild -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' build
```

提交：

```bash
git add ItsCabinet/ContentView.swift ItsCabinet/Views
git commit -m "feat: add root navigation and cabinet list"
```

---

## 任务 8：实现手动新增用品

目标：用户可以手动新增一条用品批次。

修改：

- `ItsCabinet/Views/AddItem/AddItemView.swift`

字段：

- 物品名称。
- 生产日期。
- 保质期数值。
- 保质期单位：天/月。
- 只读过期日期。
- 数量。
- 单位：件/包/罐。
- 提醒规则组。
- 备注。

保存后：

- 写入 SwiftData。
- 回到柜子列表。
- 列表能看到新增用品。

手工验收：

```text
1. 打开 App。
2. 点击底部中央添加。
3. 输入“猫粮”。
4. 保存。
5. 回到柜子页，看到“猫粮”。
6. 重启 App 后，“猫粮”仍然存在。
```

验证：

```bash
xcodebuild -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' build
```

提交：

```bash
git add ItsCabinet/Views/AddItem/AddItemView.swift
git commit -m "feat: add manual item entry"
```

---

## 任务 9：实现本地搜索

目标：搜索柜子里的本地用品记录。

修改：

- `ItsCabinet/Views/Search/SearchView.swift`

功能：

- 搜索名称。
- 搜索备注。
- 不搜索已用完用品。
- 空搜索显示空状态。
- 没有结果显示无结果状态。
- V1.0 不显示扫码按钮。

验证：

```bash
xcodebuild -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' build
```

手工验收：

```text
1. 新增“猫粮”。
2. 搜索“猫”。
3. 能看到“猫粮”。
4. 搜索“不存在”。
5. 显示无结果。
```

提交：

```bash
git add ItsCabinet/Views/Search/SearchView.swift
git commit -m "feat: add local cabinet search"
```

---

## 任务 10：实现健康提醒页

目标：展示并管理三类固定健康周期提醒。

修改：

- `ItsCabinet/Views/Health/HealthView.swift`

功能：

- 显示体外驱虫、体内驱虫、疫苗。
- 显示下一次日期和剩余天数。
- 支持启用/关闭。
- 支持修改最近完成日期。
- 支持修改周期。
- 点击“我已完成本次”后，下一次日期自动滚动。

验证：

```bash
xcodebuild -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' build
```

手工验收：

```text
1. 打开健康页。
2. 确认有三张卡片。
3. 点击“我已完成本次”。
4. 剩余天数向后更新。
5. 重启 App 后更新仍然存在。
```

提交：

```bash
git add ItsCabinet/Views/Health/HealthView.swift
git commit -m "feat: add health reminder screen"
```

---

## 任务 11：实现提醒规则库

目标：用户可以查看系统规则，也可以添加/删除自己的简单规则组。

修改：

- `ItsCabinet/Views/Settings/SettingsView.swift`
- `ItsCabinet/Views/Settings/RuleLibraryView.swift`

功能：

- “我的”页面进入提醒规则库。
- 显示系统预置规则组。
- 系统预置规则不能删除。
- 用户可以新增一个“固定提前 7 天”的规则组。
- 用户可以删除自己创建的规则组。

验证：

```bash
xcodebuild -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' build
```

手工验收：

```text
1. 打开 我的 > 提醒规则库。
2. 看到“通用动态规则”。
3. 新增“我的规则”。
4. “我的规则”出现。
5. 删除“我的规则”。
6. 系统预置规则不能删除。
```

提交：

```bash
git add ItsCabinet/Views/Settings
git commit -m "feat: add rule library settings"
```

---

## 任务 12：接入通知授权和通知调度

目标：把通知计划真正接入 iOS 本地通知。

修改：

- `ItsCabinet/Views/AddItem/AddItemView.swift`
- `ItsCabinet/Views/Cabinet/CabinetView.swift`
- `ItsCabinet/Views/Health/HealthView.swift`
- `ItsCabinet/Views/Settings/SettingsView.swift`

功能：

- 设置页显示通知权限状态。
- 未授权时可以点击“允许通知”。
- 用户拒绝后，显示去系统设置的入口，不反复弹窗。
- 新增用品后调度临期通知和到期通知。
- 删除/标记用完用品时取消对应通知。
- 健康提醒点击完成后，调度下一次通知。

验证：

```bash
xcodebuild -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' build
```

手工验收：

```text
1. 打开 我的。
2. 点击允许通知。
3. 新增一条快到期用品。
4. 确认有待发送通知。
5. 标记用完后，确认通知被取消。
6. 完成一次健康提醒后，确认下一次健康通知被调度。
```

提交：

```bash
git add ItsCabinet/Views
git commit -m "feat: wire local notification scheduling"
```

---

## 任务 13：补充预览数据和 UI 状态

目标：为主要 UI 状态提供 SwiftUI 预览，方便后续调样式。

创建：

- `ItsCabinet/Support/PreviewData.swift`

修改：

- `ItsCabinet/Views/Cabinet/CabinetItemRow.swift`

预览状态：

- 安全期用品。
- 临期用品。
- 已过期用品。

验证：

```bash
xcodebuild -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16' build
```

提交：

```bash
git add ItsCabinet/Support/PreviewData.swift ItsCabinet/Views/Cabinet/CabinetItemRow.swift
git commit -m "test: add SwiftUI preview fixtures"
```

---

## 任务 14：最终验证和上架准备说明

目标：确认 MVP 构建和测试通过，并补充 App Store 首发说明。

创建：

- `docs/app-store/v1-readiness.md`

验证：

```bash
xcodebuild test -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'platform=iOS Simulator,name=iPhone 16'
```

期望：

```text
** TEST SUCCEEDED **
```

再跑 Release 构建：

```bash
xcodebuild -project ItsCabinet.xcodeproj -scheme ItsCabinet -destination 'generic/platform=iOS' -configuration Release build
```

期望：

```text
** BUILD SUCCEEDED **
```

上架说明必须写清：

- V1.0 只做本地数据。
- 不承诺云同步。
- 不承诺换机恢复。
- 不收集账号。
- 不追踪用户。
- 通知依赖用户授予 iOS 通知权限。

提交：

```bash
git add docs/app-store/v1-readiness.md
git commit -m "docs: add app store readiness notes"
```

---

## 当前执行策略调整

因为 Task 1 手写 Xcode 项目比预期慢，下一步不再长时间静默等待 subagent。

后续执行改成：

1. 先检查 Task 1 半成品。
2. 如果项目已经接近可构建，就由我直接修到 `xcodebuild` 通过。
3. 如果项目文件不可用，就用 Xcode GUI 或更可靠的方式重新创建项目。
4. 每完成一个任务，我都会给你一个简短状态：做了什么、验证结果、下一步是什么。

这样你能持续看到进展，不会再等很久还不知道卡在哪里。
