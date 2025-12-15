//
//  RoutineViewModel.swift
//  BetterMorning
//
//  ViewModel managing the Routine tab state and interactions.
//  Source of truth: AppStateManager.shared for activeRoutine
//  Data operations: RoutineManager.shared for database actions
//

import SwiftUI
import SwiftData

@Observable
final class RoutineViewModel {
    
    // MARK: - State
    
    /// Currently selected date in the date scroller
    var selectedDate: Date
    
    /// Array of dates to display in the date scroller
    var dates: [Date] = []
    
    // MARK: - Computed Properties
    
    /// The currently active routine (delegates to AppStateManager)
    var activeRoutine: Routine? {
        AppStateManager.shared.activeRoutine
    }
    
    /// Whether there is an active routine
    var hasActiveRoutine: Bool {
        activeRoutine != nil
    }
    
    /// Whether the active routine is running today (startDate <= today)
    var isRoutineRunningToday: Bool {
        AppStateManager.shared.isRoutineRunningToday
    }
    
    /// Tasks for the active routine, sorted by orderIndex
    /// Falls back to preview tasks when no active routine exists (for Canvas previews)
    var tasks: [RoutineTask] {
        guard let routine = activeRoutine else {
            // Return preview tasks for Canvas
            return previewTasks
        }
        return routine.tasks.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    /// Routine name for display
    /// Falls back to preview name when no active routine exists
    var routineName: String {
        activeRoutine?.name ?? "Tim Ferriss Routine"
    }
    
    /// Preview tasks for Canvas when no active routine exists
    private var previewTasks: [RoutineTask] {
        let calendar = Calendar.current
        let today = Date()
        
        // Create sample tasks with times throughout the morning
        let taskData: [(String, Int, Int)] = [
            ("Wake up and make the bed", 6, 0),
            ("Meditate (often ~20 minutes)", 6, 15),
            ("Drink strong tea (often with added ingredients) or water", 6, 45),
            ("Journal for 5–10 minutes (gratitude, planning, or free writing)", 7, 0),
            ("Have a small breakfast", 7, 15),
            ("Do 20–90 minutes of exercise (kettlebells, strength, or other training)", 7, 45)
        ]
        
        return taskData.enumerated().map { index, data in
            var components = calendar.dateComponents([.year, .month, .day], from: today)
            components.hour = data.1
            components.minute = data.2
            let time = calendar.date(from: components) ?? today
            
            return RoutineTask(
                title: data.0,
                time: time,
                orderIndex: index,
                isCompleted: false
            )
        }
    }
    
    /// Whether the selected date is today
    var isSelectedDateToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    /// Whether the selected date is in the past (before today)
    var isSelectedDateInPast: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: selectedDate)
        return selected < today
    }
    
    // MARK: - Initialization
    
    init() {
        self.selectedDate = Date()
        generateDates()
    }
    
    // MARK: - View Lifecycle
    
    /// Called when the Routine view appears
    /// Performs midnight check and refreshes dates
    func onViewAppear() {
        // 1. Perform midnight check (finalizes previous day if needed)
        RoutineManager.shared.performMidnightCheck()
        
        // 2. Refresh dates to ensure we're showing current data
        generateDates()
        
        // 3. Ensure selected date is today after a potential reset
        let today = Calendar.current.startOfDay(for: Date())
        if selectedDate != today {
            selectedDate = today
        }
    }
    
    /// Refresh dates when view appears or routine changes
    /// Call this from the View's `.onAppear` to ensure dates are current
    @available(*, deprecated, renamed: "onViewAppear")
    func refreshDates() {
        generateDates()
    }
    
    /// Generate the array of dates for the date scroller
    ///
    /// **Functional Spec 8.2 Requirements:**
    /// - Shows dates from the **active routine's startDate** up to **today + 2 weeks**
    /// - User cannot scroll earlier than the active routine's start date
    ///
    /// **Date Range:**
    /// - Start: `activeRoutine.startDate` (required for valid dates)
    /// - End: Today + 14 days (2 weeks into the future)
    ///
    /// **Normalization:**
    /// - All dates normalized to midnight (start of day) to avoid time-zone bugs
    func generateDates() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Guard: If no active routine or no startDate, return empty array
        // The view should handle this case (show empty state)
        guard let routine = activeRoutine,
              let routineStartDate = routine.startDate else {
            // Fallback for previews: show 3 days back to 14 days forward
            dates = generatePreviewDates(calendar: calendar, today: today)
            selectedDate = today
            return
        }
        
        // Normalize start date to midnight
        let startDate = calendar.startOfDay(for: routineStartDate)
        
        // End date: today + 14 days (2 weeks into the future)
        guard let endDate = calendar.date(byAdding: .day, value: 14, to: today) else {
            dates = []
            return
        }
        
        // Generate all dates in range (startDate...endDate)
        var generatedDates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            generatedDates.append(currentDate)
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        dates = generatedDates
        
        // Set selected date to today (or startDate if today is before start)
        if today >= startDate {
            selectedDate = today
        } else {
            selectedDate = startDate
        }
    }
    
    /// Generate preview dates when no active routine exists
    /// Used for Canvas previews and testing
    private func generatePreviewDates(calendar: Calendar, today: Date) -> [Date] {
        var previewDates: [Date] = []
        
        // Generate 3 days in past + today + 14 days future
        for offset in -3...14 {
            if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                previewDates.append(date)
            }
        }
        
        return previewDates
    }
    
    // MARK: - Task Interactions
    
    /// Toggle the completion state of a task
    ///
    /// **Functional Spec 8.3 Requirements (Today):**
    /// - User can tap an untouched task → mark as ✓ completed
    /// - User can tap a ✓ task → un-complete it (return to untouched state)
    ///
    /// **Persistence:**
    /// - Creates/deletes TaskCompletion records in SwiftData
    /// - Completion state persists across app restarts
    ///
    /// - Parameter task: The RoutineTask to toggle
    func toggleTaskCompletion(task: RoutineTask) {
        // Only allow toggling for today's date
        guard isSelectedDateToday else {
            return // Past and future dates are read-only
        }
        
        // Delegate to RoutineManager for persistence
        RoutineManager.shared.toggleCompletion(for: task, on: selectedDate)
    }
    
    /// Check if a task is completed for the selected date
    ///
    /// **Logic:**
    /// - Checks TaskCompletion records in SwiftData for all dates
    /// - Works for today, past days, and (theoretically) future days
    ///
    /// - Parameter task: The RoutineTask to check
    /// - Returns: Whether the task is completed for the selected date
    func isTaskCompleted(_ task: RoutineTask) -> Bool {
        // For future days: tasks are not available yet
        if !isSelectedDateToday && !isSelectedDateInPast {
            return false
        }
        
        // For today and past days: check TaskCompletion records via RoutineManager
        return RoutineManager.shared.isTaskCompleted(task, on: selectedDate)
    }
}

