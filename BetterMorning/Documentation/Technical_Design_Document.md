# Technical Design Document: Better Morning

## 1. Project Overview
**App Name:** Better Morning
**Bundle Identifier:** com.bettermorning.BetterMorning
**Platform:** iOS (Target: iOS 18.0+)
**Device Support:** iPhone (Portrait orientation locked)
**Goal:** A proof-of-concept morning routine optimization app allowing users to create, manage, and execute morning routines.

## 2. Technical Stack
* **Language:** Swift 6
* **UI Framework:** SwiftUI
* **Data Persistence:** SwiftData (Local database for CRUD)
* **Architecture:** MVVM (Model-View-ViewModel)
* **Testing:** Swift Testing framework
* **Version Control:** Git
* **External Dependencies:** None (Strictly native Apple frameworks)

## 3. Architecture Guidelines
We will follow a strict MVVM pattern to ensure separation of concerns and testability.

### Layers:
1.  **Models (Data Layer):** * `@Model` classes using SwiftData.
    * Defines the schema for Routines and Steps.
2.  **ViewModels (Business Logic):** * `@Observable` classes.
    * Handle data manipulation, state management, and interaction with the `ModelContext`.
    * Views **must not** modify data directly; they must call ViewModel functions.
3.  **Views (Presentation):** * Pure SwiftUI views.
    * Driven by state derived from ViewModels.
4.  **Services:**
    * `NotificationManager`: Handles scheduling local notification triggers.
    * `StoreManager`: Handles StoreKit 2 interactions (In-App Purchases) - *Phase 2 Implementation*.

## 4. Data Models (SwiftData Schema)

### Model: `Routine`
Represents a singular routine (e.g., "Weekday Grind" or "Lazy Sunday").

```swift
@Model
class Routine {
    var id: UUID
    var title: String
    var iconSymbol: String // SF Symbol name
    var colorHex: String // Hex code for customization
    var targetStartTime: Date
    @Relationship(deleteRule: .cascade) var steps: [RoutineStep]
    var createdAt: Date

    init(title: String, iconSymbol: String = "sun.max.fill", colorHex: String = "#FF9500", targetStartTime: Date) {
        self.id = UUID()
        self.title = title
        self.iconSymbol = iconSymbol
        self.colorHex = colorHex
        self.targetStartTime = targetStartTime
        self.steps = []
        self.createdAt = Date()
    }
}

```swift
@Model
class RoutineStep {
    var id: UUID
    var title: String
    var durationMinutes: Int
    var sortOrder: Int
    var isCompleted: Bool // For tracking active session state
    var routine: Routine? // Inverse Relationship

    init(title: String, durationMinutes: Int, sortOrder: Int) {
        self.id = UUID()
        self.title = title
        self.durationMinutes = durationMinutes
        self.sortOrder = sortOrder
        self.isCompleted = false
    }
}

## 5. UI/UX Hierarchy & Key Views

### A. Dashboard (Home View)
* **Purpose:** Lists all user routines.
* **Components:**
    * `RoutineCardView`: Displays routine name, total duration, and start button.
    * `AddRoutineButton`: Floating action button or NavigationBar item to create a new routine.

### B. Routine Editor (CRUD View)
* **Purpose:** Create or Edit a routine.
* **Features:**
    * TextField for Title.
    * Color picker / Icon picker.
    * Time picker for start time.
    * List of Steps (Add/Delete/Reorder capability).

### C. Active Session View (Run Mode)
* **Purpose:** The screen the user sees while actually doing the routine.
* **Features:**
    * Timer countdown for the current step.
    * "Next Step" button.
    * Progress bar indicating routine completion.
    * Confetti/Success screen upon completion.

### D. Settings / Paywall
* **Purpose:** Manage app preferences and IAP.
* **Features:**
    * Toggle for Notifications.
    * "Unlock Premium" banner (Placeholder for IAP logic).

## 6. Implementation Phases

### Phase 1: The Skeleton (Current Priority)
* Setup Xcode Project.
* Configure SwiftData Container (`App` struct).
* Build the `Routine` and `RoutineStep` models.

### Phase 2: CRUD Functionality
* Build `RoutineViewModel`.
* Implement "Add Routine" sheet.
* Implement "Delete Routine" capability.
* Display list of routines on Dashboard.

### Phase 3: The Runner
* Build the `ActiveSessionView`.
* Implement timer logic.
* Handle state changes (Step completion).

### Phase 4: Polish & IAP
* Implement StoreKit 2 for In-App Purchases.
* Add Local Notifications.
* Apply "Pixel Perfect" styling from Figma design system.

## 7. Development Guidelines for AI Agents
* **Don't** use Third-Party libraries (CocoaPods/SPM) unless explicitly requested. Stick to native frameworks.
* **Always** create a Preview for every SwiftUI view.
* **Always** mark classes as `final` unless inheritance is required.
* **Use** `Extension` files to break up large models or views.
* **Error Handling:** Fail gracefully. If data is missing, show an Empty State view, do not crash.