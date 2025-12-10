# Better Morning – Functional Specification (Source of Truth)

> This document describes what the app does and does not do, in precise functional terms.
> 
> 
> It is implementation-agnostic and is intended as the single source of truth for product behavior.
> 

---

## 1. Product Overview

**Name:** Better Morning

**Platform:** iOS (iPhone)

**Orientation:** Portrait

**Theme:** Light mode only

**Language:** English only (no localization)

**Purpose:**

Better Morning is a focused iOS app that helps users start their day with clarity and consistency by following **one structured morning routine** at a time.

Users can:

- Choose a pre-defined morning routine from well-known people (“celebrity routines”), or
- Create their own custom routine (premium, behind a one-time purchase),
- Check off tasks each day,
- See weekly progress via charts.

The app is intentionally small and opinionated: **one active routine, one daily reminder, simple tracking.**

There are:

- **No accounts**
- **No syncing**
- **No sharing**
- **No back-end**
- **No streaks or gamification beyond weekly charts**

---

## 2. Core Concepts & Entities

### 2.1 Routine

A **Routine** is a named, ordered list of **Tasks** scheduled at specific times in the morning.

Attributes:

- `id` (internal)
- `name` (string, non-empty)
- `type` (enum: `celebrity` | `custom`)
- `tasks` (list of Task objects)
- `isActive` (bool) – at most one routine has `isActive = true` at a time
- `createdDate` (date) – the date the user first activated or created the routine
- `startDate` (date) – the next date on which the routine is scheduled to start (for active routines, this is “tomorrow” when newly activated)
- `historicalUsage` – implied via daily records/analytics (not stored directly as field)

Constraints:

- There can be **unlimited routines** stored (until device storage is full).
- Exactly **one routine** can be active at any given time.
- Each routine has **at most 20 tasks**.
- There are two routine types:
    - **Celebrity routines** – predefined, static, non-editable by the user.
    - **Custom routines** – created by the user, editable **only during creation**, then locked.

---

### 2.2 Task

A **Task** is a single step in a routine (e.g., “Drink water”, “Meditate”).

Attributes:

- `id` (internal)
- `routineId` (parent)
- `title` (string, non-empty)
- `time` (time of day; 24-hour or 12-hour display, but functionally a time)
- `orderIndex` (integer, for display order; derived from time)

Constraints:

- Tasks must be associated with exactly **one** routine.
- Tasks are scheduled at times with **5-minute increments**.
- Tasks are automatically sorted by `time` ascending. The user cannot manually reorder.
- During routine creation, if the user adds a task with an earlier time than existing tasks:
    - The list must reorder **immediately** to maintain chronological order.
- Max tasks per routine: 20.
- Tasks **cannot** be duplicated across routines.

---

### 2.3 Day Record / Daily Result

A **Day Record** captures the outcome of one routine on one date.

Attributes:

- `date` (calendar date)
- `routineId`
- `completedTasksCount` (integer: 0…N)
- (Implicit) All tasks that are not completed by end-of-day are considered incomplete.

Rules:

- Only **one Day Record per (routineId, date)**.
- Day Record stores:
    - **Only** the number of completed tasks (no timestamps, no per-task history needed beyond completion state for that day).
- Day Record is finalized:
    - At **midnight**, conceptually:
        - All untouched tasks become “incomplete/X”.
        - `completedTasksCount` is the number of tasks with ✓.
    - Or at mid-day routine switch (see Routine switching rules).

---

### 2.4 Data Card (Routine Analytics Card)

A **Data Card** represents the analytics history for one Routine on the **Data tab**.

Attributes:

- `routineId`
- `displayName` (same as routine name)
- `isActive` (reflects routine’s active state)
- `weeklyView` (current week’s data: bars per day)

Behavior:

- One Data Card per **unique routine** (celebrity or custom).
- A Data Card persists across multiple activations and deactivations of the same routine.
- If a routine is deleted, its Data Card and all associated data are removed.

---

## 3. App Structure & Navigation

### 3.1 Tabs

The app uses 3 primary tabs:

1. **Tab 1 – Explore**
    - Browse celebrity routines.
    - Access Settings (gear icon).
    - Entry point after onboarding.
2. **Tab 2 – Routine**
    - Shows the currently active routine’s tasks for the current day.
    - Includes date scroller (only dates since the active routine’s start).
    - Used for checking off tasks during the day.
    - Shows empty states if no active routine or new routine starts tomorrow.
3. **Tab 3 – Data**
    - Shows Data Cards (one per routine with historical data).
    - Lets the user restart or delete routines.
    - Allows navigation by week for each Data Card.

### 3.2 Settings

- Accessible via a **gear icon** in the header where it appears in the UI (at least on Explore, and any other screen that uses that shared header).
- Settings functions include:
    - “Reset all data” action.
    - The ability to turn on and off notifications for the app
- There is **no dedicated Settings tab**.

---

## 4. Onboarding

### 4.1 Behavior

On first app launch:

- Show a **multi-step onboarding carousel** that introduces:
    1. Inspiration (celebrity routines)
    2. Personalization (custom routine)
    3. Accountability (notifications)
    4. Progress tracking (analytics)
    5. A CTA to start using the app.

User flow:

- After completing onboarding, the user lands on **Tab 1: Explore**.
- At this point:
    - **No active routine exists**.
    - Routine tab and Data tab show **empty states**.

### 4.2 Re-showing Onboarding

Onboarding is shown:

- On **first ever launch**, and
- Again **after a full app reset** (via Settings → Reset all data).

Onboarding is **not** shown in other situations.

---

## 5. Explore Tab – Celebrity Routines

### 5.1 Layout

- Grid/mosaic of celebrity avatars.
- Each avatar:
    - Circular image.
    - Tap → open that celebrity’s routine profile.
- Press-and-hold behavior:
    - On Explore tab, a **press-and-hold-and-move** interaction triggers a **parallax effect** on the avatars:
        - All avatar images move slightly as a single layer relative to the finger movement.
        - Avatars remain circular; no stretching or distortion.
    - This effect:
        - Happens **only** on the Explore page.
        - Only when touching/holding an avatar (not empty space).
        - Does not appear on other tabs.

### 5.2 Celebrity Routine Profile Screen

When user taps an avatar:

- Show:
    - Profile photo.
    - Name
    - Short bio.
    - List of routine tasks, each with:
        - Time.
        - Title.
- A button: **“Choose this routine”**.

Behavior:

- Celebrity routines are **static** and **non-editable**:
    - The user cannot change task titles, times, order, or delete tasks.
- Upon tapping **“Choose this routine”**:
    - If no other routine is currently active:
        - This routine becomes the **active routine**.
        - **Start date** for this new routine is **tomorrow**.
        - Today’s date is unaffected (no day record created for this routine yet).
        - Routine tab shows an empty state: “Your new routine will start tomorrow” (exact copy provided by design).
    - If another routine is already active:
        - See **Routine Switching rules**.

Celebrity routines:

- May have different numbers of tasks.
- Are free to view and activate (no purchase needed).

---

## 6. Custom Routine Creation (Premium)

### 6.1 Access & Paywall

On any screen where a “Create” action exists (e.g., Explore tab header, empty states):

- When the user taps **+ Create**:
    - If the user has **not yet purchased** the premium unlock:
        - Show a **paywall** for a one-time purchase of **$0.99**.
        - If purchase succeeds:
            - Mark purchase as owned.
            - Proceed to the **Create Routine** flow.
        - If purchase is canceled or fails:
            - Return to previous screen; do not start creation.
    - If the user **has purchased**:
        - Directly open the **Create Routine** flow.

The purchase state:

- Is **restored across reinstalls** via StoreKit.
- Is **not cleared** by “Reset all data.”

### 6.2 Create Routine Flow

The creation flow allows the user to define:

1. **Routine title**
2. **Tasks (up to 20)** with times

### 6.2.1 Routine Title

- User must enter a non-empty string.
- The routine title has a max character count of 20
- Title is used as the routine’s display name and Data Card name.

### 6.2.2 Adding Tasks

For each task:

- User taps “Add Task” or similar.
- User can:
    - Type the task name (non-empty).
    - Task names have a max character count of 70
    - Select the **time** using a system time picker:
        - Time increments: **5 minutes**.
    - Save the task.

On saving:

- The task is added to the routine.
- The task list is automatically sorted by time ascending.
- If the new task’s time is earlier than an existing one, it appears **above it immediately**.

Constraints:

- Max **20 tasks**:
    - After the 20th task is created:
        - Show an **alert banner** indicating the maximum has been reached.
        - Disable the UI control for creating new tasks.
- Deleting a task during creation:
    - Is **permanent**, with **no undo**.
- Task order:
    - Cannot be manually reordered; it is purely chronological.

### 6.2.3 Auto-Save / Crash Recovery

- During creation, user-entered data (title & tasks) should be **auto-saved** incrementally.
- If the app crashes or is terminated during creation:
    - Reopening the app and entering creation again should restore the **partially created routine** to its last auto-saved state.

### 6.2.4 Finalizing Creation

When the user confirms/saves the full routine:

- A new **custom Routine** is created with:
    - `type = custom`
    - `isActive = true`
    - `startDate = tomorrow`
- The routine is **locked**:
    - The user **cannot edit**:
        - Title
        - Tasks
        - Times
    - The only management actions available later are:
        - Restart (via Data tab, which affects analytics and activation)
        - Delete (via Data tab or reset all data)
- Today’s date:
    - The new routine does **not** apply for the current day.
    - Routine tab shows empty state indicating it starts tomorrow.

---

## 7. Routine Switching Rules

When a user activates a new routine (celebrity or custom) **while another routine is active**, the following steps happen:

1. **Lock current day of old active routine**:
    - The day associated with the currently active routine and today’s date is finalized:
        - All tasks with ✓ remain completed.
        - All untouched/incomplete tasks immediately become **X**.
        - A Day Record is written:
            - `completedTasksCount` = number of ✓ tasks today for that old routine.
    - The user can no longer interact with that routine’s tasks for today.
2. **Deactivate old routine**:
    - The old routine’s `isActive` is set to **false**.
    - Its Data Card remains on the Data tab with its historical data.
3. **Activate new routine**:
    - The selected routine’s `isActive` is set to **true**.
    - Its `startDate` is set to **tomorrow** (the next calendar day).
    - No Day Record is created for this routine for today.
4. **Routine Tab behavior**:
    - For the rest of today:
        - The Routine tab shows an **empty state** indicating that the new routine starts tomorrow.
    - The user cannot complete tasks for the new routine until tomorrow.
5. **Notifications**:
    - Any old scheduled notifications for the previous routine are canceled.
    - A new notification schedule is set up so that the **first notification for the new routine fires tomorrow** at the time of its first task.

Result:

- Today’s analytics are recorded for the old routine.
- The new routine begins cleanly tomorrow.

---

## 8. Daily Routine Tab Behavior (Tab 2)

### 8.1 General Behavior

The Routine tab shows:

- A **date scroller** for the active routine’s date range.
- The list of tasks for the **active routine** for the currently selected date.
- Interaction for today’s date; read-only for past dates.

If there is **no active routine**:

- The Routine tab shows an **empty state** with:
    - Informative copy (per design).
    - Two buttons:
        - **Explore** → switches to Explore tab.
        - **Create** → triggers custom routine creation (with paywall if needed).

### 8.2 Date Scroller

- Shows dates only from the **active routine’s startDate** up to **today as well as two weeks worth of dates into the future**.
- The user **cannot** scroll earlier than the active routine’s start date.
- The scroller:
    - Displays ~5 days fully, with the 6th day partially visible (peeking).
    - Scrolls **horizontally** only.
    - Does **not** use week-locking behavior (no snapping by week).

### 8.3 Day Modes

For the **active routine**, days behave as follows:

- **Today**:
    - User can interact with tasks:
        - Mark complete (✓).
        - Toggle between ✓ and uncompleted state.
    - Tasks start the day as:
        - All **untouched** (no icon).
    - During the day:
        - User can:
            - Tap an untouched task → mark as **✓ completed** or provide direct ✓ toggle.
            - Tap a ✓ task → un-complete it (return to untouched state).
    - End-of-day behavior:
        - At midnight:
            - All tasks that are **not ✓** are treated as **incomplete**, shown with a red X.
            - A Day Record is finalized for that date.
- **Past days (after they are locked)**:
    - The user can scroll to previous days (since routine’s startDate).
    - These days are **view-only**:
        - Task states (✓ or X) are displayed.
        - User cannot change any completion states.
- **Future days**:
    - Are not interactable and typically shown in the scroller as disabled.

### 8.4 Midnight Reset

Conceptual functional behavior:

- At **00:00 (midnight)** device time:
    - The current day for the active routine is finalized:
        - All unchecked tasks become incomplete (X).
        - A Day Record is saved with the count of ✓ tasks.
    - A new day begins:
        - The Routine tab for today shows the active routine with all tasks untouched.

From user perspective:

- If the user opens the app after midnight (e.g., 12:01 AM):
    - They see a new day where:
        - All tasks are untouched.
        - Yesterday’s tasks appear as ✓/X when viewing that previous date.

---

## 9. Notifications

### 9.1 General Behavior

- The app sends **one local notification per day**, only if:
    - There is an **active routine**, and
    - System-level notifications are allowed for the app.

Notification:

- Fires at the **time of the first task** in the active routine.
- Example: If the earliest task is 7:00 AM, notification fires at 7:00 AM.
- If the first task is at **12:00 AM**, notification fires exactly at midnight.

### 9.2 Conditions

- If the user has **no active routine**:
    - **No notifications** are scheduled or fired.
- If the user has disabled notifications at system level:
    - The app’s notification functionality will effectively **silently fail**.
    - Any in-app toggles related to notifications (if present) should appear **off**, reflecting that notifications aren’t active.
    - No explicit warning is required.

### 9.3 Routine Activation & Notification Scheduling

- On **routine activation** (including Restart):
    - Schedule notification to start firing **from the routine’s startDate onwards**.
    - If activated today and startDate = tomorrow:
        - First notification fires tomorrow at the routine’s first task time.
- On **routine deletion**:
    - Cancel scheduled notifications if that routine was active.
- On **reset all data**:
    - Cancel all notification schedules.

---

## 10. Data Tab (Analytics) – Tab 3

### 10.1 Layout & Cards

- Tab 3 shows a **vertical list of Data Cards**, each representing one routine (celebrity or custom) that has historical or current data.
- The **currently active routine’s Data Card** is always pinned at the **top**, even if it has zero data yet.
- Other routines appear below, sorted in a consistent order (e.g., most recently active first – left for implementation choice, but must be deterministic).

### 10.2 Data Card Contents

Each Data Card displays:

- Routine name.
- An “Active” indicator (if this is the active routine).
- A weekly bar chart:
    - Days of the week: follow the device’s locale and week conventions.
    - For weeks where the routine first becomes active mid-week:
        - Days before the routine started show no bars (no data).
    - For each day:
        - If 1+ tasks were completed:
            - Show a bar whose height corresponds to **number of tasks completed that day**.
        - If **no tasks** were completed:
            - All tasks for that routine on that date are X.
            - The chart shows **no bar** or explicit “no data” for that day (i.e., the bar is omitted).
- Week navigation controls:
    - The user can:
        - Swipe horizontally on the chart area to move between weeks.
        - OR tap left/right arrows to move between weeks.
    - Both interactions are supported.

### 10.3 Restart Option (••• Menu)

Each Data Card has an overflow menu (e.g., “•••”) with:

- **Restart routine**
- **Delete routine**

**Restart behavior:**

When the user selects "Restart":

1. The routine becomes the **active routine**.
2. The routine’s `startDate` is set to **tomorrow**.
3. For the **current week**:
    - If restarting mid-week:
        - No data will be shown for previous days of this week for this newly restarted period.
    - Historical weeks for this routine (e.g., from 6 months ago) remain intact and can be accessed by scrolling backwards in time on the Data Card.
4. Tasks and routine metadata remain unchanged (no edits to tasks/times).
5. Notification schedule is updated:
    - Old schedules (for previous active routine, if any) are canceled.
    - New notification schedule set for this routine starting tomorrow.

### 10.4 Delete Option

When the user selects "Delete" on a Data Card:

- Show a confirmation dialog.
- If confirmed:
    - Permanently delete:
        - The routine.
        - All its Day Records.
        - Its Data Card.
- If the deleted routine was **active**:
    1. Set active routine to `nil`.
    2. Stop any scheduled notifications for that routine.
    3. The Routine tab switches to **empty state** (“no active routine”).
    4. The Data tab:
        - If other routines exist:
            - Shows their historical Data Cards (none marked as active).
        - If no routines remain:
            - Shows the **empty state** for the Data tab.

---

## 11. Settings & Reset All Data

### 11.1 Settings

Accessible via gear icon. At minimum includes:

- **Reset all data**
- **Turn on notifications**

### 11.2 Reset All Data

When user selects “Reset all data” and confirms:

- The app performs:
    - Delete all routines (celebrity instances and custom):
        - Note: The static *definitions* of celebrity routines are not “deleted,” only user data and references.
    - Delete all Day Records.
    - Delete all Data Cards.
    - Reset all daily check states.
    - Clear all app settings (e.g., notification preferences, scroll positions).
    - Reset the “onboarding completed” flag so onboarding will show again on next launch.
    - Cancel any scheduled notifications for the app.
- **Do not delete:**
    - The purchase state:
        - If user bought the $0.99 unlock, they still own it after reset.

On next app launch after reset:

- Onboarding is shown again.
- The user lands on Explore afterward with:
    - No active routine.
    - Routine and Data tabs in empty states.

### 11.3 Turn on notifications

The user can toggle notifications on or off for the app

---

## 12. Purchase & Monetization Rules

- One-time IAP: **$0.99**
    - Unlocks:
        - Custom routine creation.
        - Access to the creation flow when pressing “Create.”
- Celebrity routines:
    - Fully free to:
        - View.
        - Activate.
        - Follow.
        - Track progress.
- Reset all data:
    - Does **not** revoke purchase.
- Reinstall:
    - The purchase must be restorable via App Store’s standard restore mechanism.

---

## 13. Non-Features / Explicit “Does Not”

Better Morning **DOES NOT**:

- Support multiple active routines at the same time.
- Allow editing a routine (title, tasks, times) **after it has been created**.
- Allow users to:
    - Reorder tasks manually.
    - Duplicate tasks across routines.
    - Edit celebrity routines in any way (no rename, no delete tasks, no time changes).
- Support:
    - User accounts.
    - Authentication.
    - Cloud sync.
    - Cross-device sync.
    - Social sharing.
- Track:
    - Exact completion timestamps.
    - Exact switch times between routines.
    - Any analytics beyond “completed task count per day per routine.”
- Provide:
    - More than one notification per day.
    - Per-task notifications.
    - Adjustable notification times in-app.
- Support:
    - Dark mode.
    - Localization / multiple languages.
- Include:
    - Ads.
    - Subscriptions.
    - Multiple IAP tiers.

This list is important so AI/engineers do not “helpfully” add complexity that isn’t desired.
