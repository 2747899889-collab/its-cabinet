# Its Cabinet V1.0 MVP Design

## Context

Product name: 「它的柜子」, English working name: Its Cabinet.

Target platform: iOS only, distributed through the Apple App Store.

Confirmed V1.0 direction: a focused native iOS pet cabinet MVP for local pet food and supply expiry reminders plus fixed health cycle reminders. The app is local-first and does not require accounts, servers, paid subscriptions, ads, or third-party scanning APIs in V1.0.

The broader PRD includes Apple login, cloud sync, image upload, scanning, multi-pet profiles, and a fuller account/settings area. Those are treated as future iterations, not V1.0 scope.

## Goals

- Let a user manually record pet food or pet supply batches and receive expiry reminders.
- Let a user manage three fixed pet health cycles: external deworming, internal deworming, and vaccination.
- Provide a local reminder rule library with preset dynamic expiry rules and simple user-managed rule groups.
- Keep the first release small enough to build, test, and submit to App Store without a backend.

## Non-Goals

- Apple login.
- Cloud sync or server deployment.
- Account system.
- Barcode scanning or OCR.
- Image upload.
- Multi-pet profiles.
- In-app purchases, subscriptions, or ads.
- Pixel-level copying of another app's visual design.

## Assumptions

- App Store release does not require a backend server.
- V1.0 users accept local-only storage if App Store copy clearly states the limitation.
- Scanning and cloud sync can be added later if the add form and data model remain clear and migration-friendly.
- The first build targets iPhone. iPad support can use responsive SwiftUI layouts but is not a separate product requirement.

## Architecture

The app uses SwiftUI for UI, SwiftData for local persistence, and iOS Local Notifications for reminders.

Main modules:

- Cabinet: lists supply batches and supports sorting, search entry points, delete, and mark-as-used.
- Add Item: central add flow for manually creating a supply batch.
- Rule Library: stores preset and user-managed reminder rule groups.
- Health: manages three fixed recurring health reminders.
- Settings: exposes notification state, rule library, product information, and local-data notes.
- NotificationScheduler: schedules, updates, and cancels local notifications when records change.

All data is stored locally in SwiftData. V1.0 has no remote network dependency.

## Navigation

The app uses four regular tabs plus a central add action:

- Cabinet
- Search
- Central add button
- Health
- Settings

The central add button opens the item entry flow. It is not a separate content tab.

## Cabinet

Cabinet is the default home screen.

Each item card shows:

- Item name.
- Expiry status.
- Remaining days or expired days.
- Expiry date.
- Quantity and unit.
- Optional note.

Active-list sorting order:

1. Expired.
2. Warning.
3. Safe.

Items marked as used are removed from the active Cabinet list and their notifications are canceled. V1.0 does not include a separate used-item history screen.

Supported actions:

- Add an item through the central add action.
- Delete an item.
- Mark an item as used.
- Search local records from the Search tab.

Status colors follow iOS conventions without copying another app:

- Safe: neutral or green accent.
- Warning: yellow or orange accent.
- Expired: red accent with subdued visual treatment.

## Search

Search works only on local cabinet items in V1.0.

The Search tab includes:

- A top search field.
- Empty state text when no query exists.
- Results filtered by item name and optional note.

The scanning icon is omitted in V1.0 to avoid exposing a nonfunctional control. A later scanning API can prefill the same Add Item fields.

## Add Item

The Add Item flow is opened by the central add button.

Required fields:

- Item name.
- Production date.
- Shelf-life value.
- Shelf-life unit: days or months.
- Quantity.
- Unit: piece, bag, or can.
- Reminder rule group.

Derived fields:

- Expiry date, calculated from production date and shelf life.
- Warning date, calculated from the selected reminder rule.

Optional fields:

- Note.

The form supports a clear save action and cancellation. On successful save, the app persists the item and schedules its local notifications.

## Reminder Rule Library

V1.0 includes preset dynamic rules based on total shelf-life days:

- Long storage: shelf life >= 365 days, warning 45 days before expiry.
- Medium storage: 180 <= shelf life < 365 days, warning 30 days before expiry.
- Short storage: 90 <= shelf life < 180 days, warning 20 days before expiry.
- Fresh storage: 30 <= shelf life < 90 days, warning 10 days before expiry.
- Near-term storage: shelf life < 30 days, warning 3 days before expiry.

Users can manage simple local rule groups from Settings:

- Create a rule group.
- Edit a user-created rule group.
- Delete a user-created rule group.
- Use system preset rules.

System preset rules cannot be deleted. Rule management stays local. V1.0 does not support import, export, account-level sync, category binding, or remote defaults.

## Health

Health supports exactly three fixed recurring reminders:

- External deworming.
- Internal deworming.
- Vaccination.

Each health reminder stores:

- Type.
- Last completed date.
- Cycle length in days or months.
- Next reminder date.
- Enabled state.

The Health screen shows each reminder as a focused card with:

- Reminder name.
- Next date.
- Days remaining.
- Cycle length.
- Enabled state.
- A large "completed this time" action.

When the user marks a reminder complete:

1. The completion date is set to today unless the user edits it.
2. Next reminder date = completion date + cycle.
3. The existing local notification is replaced with the next one.

## Notifications

All notifications use iOS Local Notifications.

Default reminder time: 09:00 local time.

Cabinet item notifications:

- Warning notification on the calculated warning date.
- Expiry notification on the expiry date.

Health notifications:

- One notification on the next reminder date for each enabled health reminder.

Notification lifecycle:

- Creating or editing an item schedules or replaces its notifications.
- Deleting or marking an item as used cancels its notifications.
- Completing a health reminder replaces the previous notification with the next one.
- Disabling a health reminder cancels its notification.

If notification permission is not granted, the app shows a clear state and a path to system settings. It should not repeatedly prompt after the user declines.

## Data Model

Core entities:

- CabinetItem
- ReminderRuleGroup
- ReminderRuleBand
- HealthReminder
- AppSettings

CabinetItem fields:

- id
- name
- productionDate
- shelfLifeValue
- shelfLifeUnit
- expiryDate
- quantity
- unit
- reminderRuleGroupId
- customReminderDays, optional
- note, optional
- isUsed
- createdAt
- updatedAt

ReminderRuleGroup fields:

- id
- name
- isSystemPreset
- bands
- createdAt
- updatedAt

ReminderRuleBand fields:

- id
- minShelfLifeDays, optional
- maxShelfLifeDays, optional
- warningDaysBeforeExpiry

HealthReminder fields:

- id
- type
- lastCompletedDate
- cycleValue
- cycleUnit
- nextReminderDate
- isEnabled
- createdAt
- updatedAt

AppSettings fields:

- defaultReminderHour
- defaultReminderMinute

The model should not include account IDs, remote IDs, cloud sync flags, or payment fields in V1.0.

## Future Compatibility

Scanning API:

- Future scanning should prefill Add Item fields.
- V1.0 does not create scanner-specific fields unless they are also useful for manual entry.

Cloud sync:

- Future sync can add remote identity and conflict handling in a later migration.
- V1.0 avoids server assumptions and keeps local models explicit.

Multi-pet:

- Future multi-pet support can add a Pet entity and attach CabinetItem and HealthReminder records to a pet.
- V1.0 uses an implicit single-pet model.

Monetization:

- V1.0 is free with no ads and no in-app purchases.
- Later Pro features can be evaluated after the core reminder workflow is validated.

## Testing

Unit tests:

- Expiry date calculation.
- Expiry status calculation.
- Reminder rule band selection.
- Health cycle next-date calculation.
- Notification identifier generation.

SwiftUI previews:

- Empty cabinet.
- Safe item.
- Warning item.
- Expired item.
- Search empty state.
- Health reminder due soon.
- Health reminder overdue.
- Notifications not authorized state.

Manual acceptance checks:

- Add a cabinet item and see it persisted after app restart.
- Edit item dates and see expiry status update.
- Search by item name.
- Mark item as used and confirm notifications are canceled.
- Delete item and confirm notifications are canceled.
- Edit a local rule group and apply it to an item.
- Complete a health reminder and confirm the next date rolls forward.
- Deny notifications and confirm the app shows a clear settings path.

## App Store Preparation

V1.0 submission needs:

- App icon.
- App display name.
- Privacy nutrition answers that reflect local-only storage.
- Screenshots for supported devices.
- App description that avoids promising cloud sync, scanning, or account recovery.
- Support URL and privacy policy URL if required for submission.

The App Store listing should clearly say that V1.0 stores data locally on the device.

## Open Decisions For Implementation Planning

- Minimum iOS version.
- Exact Chinese display name and English subtitle.
- App icon direction.
- Whether to include a short onboarding screen for notification permission context.
- Whether the first implementation should create a full Xcode project manually or use a project generator.
