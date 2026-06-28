# 「它的柜子」TestFlight 上架前清单

## 当前工程配置

- App 名称：它的柜子
- Bundle ID：`com.yujianhua.itscabinet`
- 版本号：`1.0`
- 构建号：`1`
- 签名方式：Xcode 自动签名
- 最低系统：iOS 17.0

## 必须由你在 Xcode 完成

1. 打开 `ItsCabinet.xcodeproj`。
2. 进入 Xcode > Settings > Accounts，登录已加入 Apple Developer Program 的 Apple ID。
3. 选择项目 `ItsCabinet` > Target `ItsCabinet` > Signing & Capabilities。
4. 勾选 `Automatically manage signing`。
5. Team 选择你的开发者团队。
6. 如果 `com.yujianhua.itscabinet` 已被占用，把 Bundle ID 改成你账号下唯一的值，例如 `com.你的域名.itscabinet`。

## App Store Connect 准备

1. 在 App Store Connect 创建新 App。
2. 平台选择 iOS。
3. 名称填写「它的柜子」。
4. Bundle ID 选择 Xcode 中同一个 Bundle ID。
5. SKU 可填写 `itscabinet-ios`。
6. 填写测试信息：联系人、邮箱、测试说明。
7. 填写 App 隐私信息。当前 MVP 主要是本地宠物用品、健康提醒、图片数据；如果后面接云端同步或扫码 API，需要重新更新隐私说明。
8. 如未使用自定义加密，只使用系统网络/HTTPS，按实际情况填写出口合规问题。

## 上传 TestFlight Build

1. Xcode 顶部设备选择 `Any iOS Device` 或真实 iPhone，不要选模拟器。
2. 菜单选择 Product > Archive。
3. Archive 成功后，在 Organizer 中选择 Distribute App。
4. 选择 App Store Connect。
5. 选择 Upload。
6. 保持自动签名，继续上传。
7. App Store Connect 处理完成后，在 TestFlight 中选择该 Build。

## 邀请朋友内测

- 内部测试：适合团队成员，需要把对方加到 App Store Connect 用户。
- 外部测试：适合朋友体验，需要创建外部测试组，并提交 Beta App Review。
- 外部测试通过后，可用邮箱邀请，也可开启公开链接。

## 每次重新上传前检查

- 如果上传过同一个版本，必须把 `CURRENT_PROJECT_VERSION` 构建号加 1。
- 真机启动一次，确认没有崩溃。
- 通知、图片选择、搜索历史、新增物品流程至少手动走一遍。
- 不要把任何 Apple 账号、证书密码、API Key、私钥写进仓库。

## 官方参考

- TestFlight 外部测试：https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers/
- 创建 App 记录：https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/
- 上传构建版本：https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
