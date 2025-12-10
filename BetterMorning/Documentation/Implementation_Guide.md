# Better Morning – Suggested Technical Implementation Guide

> This document proposes how to implement the app, based on modern iOS practices.
> 
> 
> It is advisory and can be changed, but it is internally consistent with the functional spec.
> 

---

## 1. Tech Stack & Version Targets

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Minimum iOS Version:** iOS 17+ (to leverage SwiftData; can be adjusted)
- **Architecture:** MVVM with feature-based modules
- **Persistence:**
    - Recommended: **SwiftData** (or Core Data if targeting broader OS range).
- **Notifications:** UserNotifications framework (`UNUserNotificationCenter`)
- **IAP:** StoreKit 2
- **Dependency Management:** SwiftPM only (no external dependencies required)

---

## 2. High-Level Architecture

### 2.1 App Structure

- Root `App` struct with:
    - `TabView` for 3 tabs.
    - A shared environment object, e.g. `AppState` or `RoutineStore`, that exposes:
        - Active routine.
        - All routines.
        - Day Records.
        - Purchase state.
        - Settings state (onboarding completed, etc.).

### 2.2 Modules / Feature Boundaries

Recommended feature modules (conceptually):

1. **OnboardingFeature**
    - Handles onboarding steps, flag for completion.
2. **ExploreFeature**
    - Displays celebrity routines.
    - Parallax gesture.
    - Celebrity profile view.
    - Activation of routines.
3. **RoutineFeature**
    - Daily routine tab.
    - Task completion interactions.
    - Date scroller logic.
    - Midnight reset handling (on app launch).
4. **DataFeature**
    - Data Card list.
    - Weekly chart.
    - Restart/Delete actions.
5. **SettingsFeature**
    - Reset all data.
6. **PurchaseFeature**
    - StoreKit integration.
    - Paywall presentation.
    - Purchase state handling.
7. **NotificationService**
    - Local notification scheduling, updating, canceling.
8. **PersistenceLayer**
    - Models, SwiftData (or Core Data) schema.
    - Load/save routines and Day Records.

---

## 3. Data Model (SwiftData/CoreData Example)

### 3.1 RoutineEntity

```swift
@Model
class RoutineEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: RoutineType // .celebrity, .custom
    var isActive: Bool
    var createdDate: Date
    var startDate: Date   // next start date when newly activated
    @Relationship(deleteRule: .cascade) var tasks: [TaskEntity]
    @Relationship(deleteRule: .cascade) var dayRecords: [DayRecordEntity]
}

```

`RoutineType` as a simple enum (String-backed):

```swift
enum RoutineType: String, Codable {
    case celebrity
    case custom
}

```

---

### 3.2 TaskEntity

```swift
@Model
class TaskEntity {
    var id: UUID
    var title: String
    var time: DateComponents // hour, minute (ignore date)
    var orderIndex: Int
    @Relationship(inverse: \RoutineEntity.tasks) var routine: RoutineEntity
}

```

Notes:

- `orderIndex` is maintained but derived from `time`.
- Sorting in UI by `time.hour`, `time.minute`.

---

### 3.3 DayRecordEntity

```swift
@Model
class DayRecordEntity {
    var id: UUID
    var date: Date // normalized to midnight
    var completedTasksCount: Int
    @Relationship(inverse: \RoutineEntity.dayRecords) var routine: RoutineEntity
}

```

Normalization:

- Ensure `date` is stored as "00:00 of that calendar day" in the user’s calendar/timezone.

---

### 3.4 AppSettingsEntity

```swift
@Model
class AppSettingsEntity {
    var id: UUID
    var onboardingCompleted: Bool
    var hasPurchasedCustomRoutines: Bool
    var lastMidnightCheck: Date?
}

```

Alternately, AppSettings can be stored in `UserDefaults`. SwiftData is used if a single row is simpler to manage.

---

## 4. Key Logic Flows (Implementation-Level)

### 4.1 On App Launch

1. Check `AppSettings.onboardingCompleted`:
    - If `false` → show Onboarding.
    - If `true` → show Tabs.
2. Ensure **at most one** routine has `isActive == true`:
    - If multiple (corrupt state), keep last used; set others false.
3. Run a **midnight check**:
    - Compare `lastMidnightCheck` date to today.
    - If different:
        - Finalize Day Record for yesterday:
            - Retrieve active routine as of yesterday.
            - Count ✓ tasks from stored completion state (if persisted; or assume tracked in memory during day).
            - Mark all non-completed tasks as X (in UI model).
            - Create or update the DayRecordEntity.
        - Reset today’s in-memory completion state to “all untouched."
        - Update `lastMidnightCheck` to now.

Note: For a strictly offline app, some of this can be simplified to “finalize previous day on next app open.”

---

### 4.2 Routine Activation Flow (Celebrity or Restart/Creation)

```
Event: activateRoutine(newRoutine)

1. If there is an activeRoutine:
   - Finalize today's record for activeRoutine:
     - Determine completed tasks count.
     - Create DayRecordEntity(date: today, completedTasksCount: count, routine: activeRoutine).
   - Set activeRoutine.isActive = false

2. Set newRoutine.isActive = true
3. Set newRoutine.startDate = tomorrow (normalized)
4. Schedule daily notification for newRoutine:
   - At time of earliest TaskEntity.time, starting tomorrow.
5. Save changes.
6. On Routine tab:
   - Show empty state saying the new routine starts tomorrow.

```

---

### 4.3 Custom Routine Creation

1. Present a `CreateRoutineViewModel`.
2. Store intermediate state in memory and optionally in a temporary persistent store.
3. On each change (title, tasks), call:

```swift
viewModel.autoSaveDraft()

```

1. On final “Save”:
    - Validate:
        - Title non-empty.
        - At least 1 task.
        - ≤ 20 tasks.
    - Sort tasks by time and assign `orderIndex`.
    - Create `RoutineEntity` with:
        - `type = .custom`
        - `isActive = true`
        - `createdDate = now`
        - `startDate = tomorrow`
    - Save tasks as `TaskEntity` children.
    - Activate this routine (use activateRoutine flow).
    - Clear any draft data.
2. Lock routine:
    - Do not expose any editing UI for existing custom routines.

---

### 4.4 Task Completion Storage

Implementation options:

- Store today’s task completion state either:
    - In memory + persist only aggregated counts at day finalization, or
    - Persist a separate `TaskCompletionEntity` per (task, date).

Given the simplicity of analytics, recommended:

- **Track completion state in memory only for today**, and:
    - On finalization (midnight or routine switch), compute `completedTasksCount` and persist in `DayRecordEntity`.
    - For viewing past days in Routine tab:
        - Reconstruct ✓/X states from:
            - `completedTasksCount` and total tasks.
            - However, this loses per-task detail (which tasks exactly were completed).
        - If exact mapping is required, then you need per-task completion records.

You have visually ✓ and X per-task for past days, so for accuracy:

**Recommended additional model:**

```swift
@Model
class TaskCompletionEntity {
    var id: UUID
    var date: Date
    var taskId: UUID
    var state: TaskCompletionState // .completed, .incomplete
}

```

Then:

- For each day, you can render ✓ and X per task.
- `DayRecordEntity.completedTasksCount` is derived from TaskCompletionEntity where `state == .completed`.

This is an internal implementation detail; the functional spec is still satisfied.

---

### 4.5 Weekly Chart Calculation

To render a weekly chart:

1. Determine week range:
    - Use Calendar.current to get start/end of week.
2. Fetch `DayRecordEntity` for that routine with `date` in that week.
3. Construct 7 slots (or locale-based number of days).
4. For each day:
    - If a DayRecord exists:
        - Use `completedTasksCount` for bar height.
    - If no DayRecord:
        - Show **no bar** (represents “no data”).

This aligns with: “If user doesn’t complete any tasks that day, they see no bar on the card.”

---

### 4.6 Delete Routine Flow

1. Show confirmation.
2. If confirmed:
    - If routine.isActive:
        - Cancel notifications for this routine.
        - Set `activeRoutine = nil` in global state.
    - Delete:
        - RoutineEntity.
        - Related TaskEntities.
        - Related DayRecordEntities.
        - Related TaskCompletionEntities (if implemented).
3. Update UI:
    - Data tab:
        - If no routines left → show empty state.
        - Else → show remaining Data Cards.
    - Routine tab:
        - Show empty state (no active routine).

---

### 4.7 Reset All Data

1. Cancel all scheduled notifications in `UNUserNotificationCenter`.
2. Delete all:
    - RoutineEntity
    - TaskEntity
    - DayRecordEntity
    - TaskCompletionEntity
    - AppSettingsEntity (or reset fields)
3. Recreate default `AppSettingsEntity` with:
    - `onboardingCompleted = false`
    - `hasPurchasedCustomRoutines` unchanged, if stored separately, or restored from StoreKit later.
4. On next app launch:
    - Onboarding triggered again.

---

## 5. Notifications Implementation Notes

- Request notification permission at an appropriate time (likely after first onboarding slide describing reminders).
- Use `UNCalendarNotificationTrigger` for daily scheduling:
    - Components: hour, minute, repeats: true.
    - Only schedule one notification per day.
- When:
    - Routine’s first task time changes (not allowed after creation) OR
    - Routine is changed (switch, restart, delete):
        - Cancel old notification(s).
        - Reschedule for new active routine.

Edge Cases:

- System time changes:
    - iOS automatically adjusts scheduled calendar notifications.
- User disabling notifications in System Settings:
    - Calls to schedule may still “succeed” but never fire. That’s acceptable per spec.

---

## 6. UI Implementation Details (Per Tab)

### 6.1 Explore Tab

- SwiftUI `ScrollView` with `LazyVGrid` for celebrity avatars.
- Parallax:
    - On `LongPressGesture` combined with `DragGesture`.
    - Use a shared offset `@State` applied to entire avatar grid.
- Tap vs long-press:
    - Recognize quick tap → open profile.
    - Recognize long-press → parallax only, do not open profile.

### 6.2 Routine Tab

- Top: horizontal date scroller:
    - Use `ScrollView(.horizontal)` with `HStack`.
    - Show days from activeRoutine.startDate to today.
    - Highlight selected date.
- Below: list of tasks:
    - For today:
        - Tappable cells with visual state:
            - Untouched.
            - Completed (✓).
            - Incomplete (X — only shown after locking).
    - For past days:
        - Same layout, but `.disabled(true)` / no tap handling.

---

### 6.3 Data Tab

- `ScrollView` vertical:
    - For each RoutineEntity → Data Card view.
- Inside Data Card:
    - A `TabView` or custom page control for weeks:
        - Horizontal swiping.
        - Left/right arrows wired to `currentWeekIndex += 1` or `1`.
    - Bar chart:
        - Build with `GeometryReader` + `Rectangle` views.
        - Each bar’s height is proportional to `completedTasksCount / maxTasksCount`.

---

## 7. Testing Strategy

- **Unit Tests**:
    - Routine activation logic.
    - Routine switching mid-day.
    - Day finalization logic at midnight.
    - Restart routine behavior.
    - Delete routine behavior.
    - Data aggregation (weekly bar chart data).
- **UI Tests**:
    - Onboarding flow.
    - Explore tab interactions (tap, long-press parallax).
    - Paywall display on Create.
    - Custom routine creation flow.
    - Daily completion flow.
    - Data tab behavior across weeks.
    - Reset all data.

---

## 8. Performance & Limits

- Routines: unbounded; assume typical user has < 20.
- Tasks: max 20 per routine, trivial scale.
- Day records: 1 per routine per day; even across years, trivial size.
- All storage is local; no heavy network or CPU operations.

---

# 📄 DOCUMENT 3: **Better Morning – Textual Diagrams & State Flows**

> These are diagram-style descriptions in text form for AI agents and humans to reason about flows and states.
> 

---

## 1. Navigation Map

```
[App Launch]
   |
   ├─ if onboardingCompleted == false
   |      └─ [Onboarding Carousel]
   |             └─ [Tabs Root]
   |
   └─ if onboardingCompleted == true
          └─ [Tabs Root]

[Tabs Root] (TabView)
   ├─ [Tab 1: Explore]
   |     ├─ [Celebrity Grid]
   |     |     └─ tap avatar → [Celebrity Profile + "Choose this routine"]
   |     ├─ tap "Settings" gear → [Settings]
   |     └─ tap "+ Create" → [Paywall or Create Routine Flow]
   |
   ├─ [Tab 2: Routine]
   |     ├─ if no active routine → [Empty State: Explore | Create]
   |     ├─ if active routine & today < startDate → [Empty State: starts tomorrow]
   |     └─ if active routine & today >= startDate
   |             └─ [Date Scroller + Tasks List]
   |
   └─ [Tab 3: Data]
         ├─ if no routines → [Empty State: Explore | Create]
         └─ [Data Card List]
               └─ each card:
                     ├─ [Weekly Chart (swipe/arrow)]
                     └─ [••• Menu → Restart | Delete]

[Settings]
   └─ [Reset All Data] → confirmation → reset → next launch shows onboarding

```

---

## 2. Routine State Machine

```
States:
  - NoActiveRoutine
  - RoutineActive(waitingToStart)       // startDate in the future (e.g. tomorrow)
  - RoutineActive(runningToday)         // startDate <= today
  - RoutineInactiveWithHistory          // not active, has data

Events:
  - CreateCustomRoutine
  - ActivateCelebrityRoutine
  - RestartRoutine
  - SwitchToAnotherRoutine
  - DeleteRoutine
  - ResetAllData
  - DayRollsOver (midnight)

Transitions:

NoActiveRoutine
  ├─ CreateCustomRoutine → finalize → RoutineActive(waitingToStart)
  ├─ ActivateCelebrityRoutine → RoutineActive(waitingToStart)
  └─ ResetAllData → NoActiveRoutine (no change)

RoutineActive(waitingToStart)
  ├─ DayRollsOver & today == startDate → RoutineActive(runningToday)
  ├─ SwitchToAnotherRoutine → RoutineActive(waitingToStart) [new routine], previous becomes RoutineInactiveWithHistory
  ├─ DeleteRoutine → NoActiveRoutine (if no other routines created)
  └─ ResetAllData → NoActiveRoutine

RoutineActive(runningToday)
  ├─ DayRollsOver → finalize today's DayRecord, stay RoutineActive(runningToday) for new day
  ├─ SwitchToAnotherRoutine → finalize today's DayRecord for current routine,
  |                            new routine → RoutineActive(waitingToStart),
  |                            current → RoutineInactiveWithHistory
  ├─ RestartRoutine (same routine) → RoutineActive(waitingToStart)
  ├─ DeleteRoutine → NoActiveRoutine (if no other routine promoted)
  └─ ResetAllData → NoActiveRoutine

RoutineInactiveWithHistory
  ├─ RestartRoutine → RoutineActive(waitingToStart)
  ├─ DeleteRoutine → (Routine removed from system)
  └─ ResetAllData → NoActiveRoutine

```

---

## 3. Daily Lifecycle Diagram

```
For a given active routine:

[MORNING: Start of Day]
  - RoutineActive(runningToday)
  - All tasks default to "untouched"

[DAYTIME: User Interaction]
  - User taps tasks to mark as ✓
  - Re-tap ✓ to revert to untouched

[EVENING: Before Midnight]
  - Some tasks ✓, some untouched

[MIDNIGHT EVENT]
  - For each untouched task → mark as X (incomplete)
  - Count completed tasks:
       completedTasksCount = number of ✓
  - Create or update DayRecord for (routine, date)
  - Reset in-memory states for next day:
       all tasks → untouched
  - If routine remains active:
       tomorrow → RoutineActive(runningToday)

```

In practice, this logic runs the next time the app is active after midnight, but functionally the user sees this effect as if it occurred at midnight.

---

## 4. Routine Switch Flow Diagram

```
[User chooses new routine (celebrity or custom)]
     |
     V
[Is there an active routine today?]
     |
     ├─ NO
     |    └─ newRoutine.isActive = true
     |       newRoutine.startDate = tomorrow
     |       schedule notification for tomorrow
     |       Routine Tab → "starts tomorrow" empty state
     |
     └─ YES (currentRoutine)
           ├─ Finalize today for currentRoutine:
           |     - Mark untouched tasks as X
           |     - Count ✓ tasks
           |     - Save DayRecord
           |     - currentRoutine.isActive = false
           |
           ├─ Activate newRoutine:
           |     - isActive = true
           |     - startDate = tomorrow
           |
           ├─ Update notifications:
           |     - cancel for currentRoutine
           |     - schedule for newRoutine starting tomorrow
           |
           └─ Routine Tab → "new routine starts tomorrow" empty state

```

---

## 5. Data Tab – Card Behavior Flow

```
[Data Tab]
   |
   ├─ if (no routines) → show Empty State
   |
   └─ else:
         [Show cards for each routine]
             |
             ├─ Tap card → expand weekly chart
             |      ├─ swipe left/right -> change week
             |      └─ tap arrows -> change week
             |
             └─ Tap ••• menu
                    ├─ Restart
                    |      ├─ call activateRoutine(routine)
                    |      └─ this routine becomes Active at the top card
                    |
                    └─ Delete
                           ├─ confirm
                           ├─ if routine.isActive:
                           |      - cancel notifications
                           |      - set activeRoutine = nil
                           |      - Routine tab: Empty State
                           └─ remove the routine and its card

```
