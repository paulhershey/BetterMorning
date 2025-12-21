//
//  DataViewModel.swift
//  BetterMorning
//
//  ViewModel managing the Data tab state and interactions.
//  Handles: routine list, week navigation, chart data calculation, restart/delete actions.
//

import SwiftUI
import SwiftData

// MARK: - Week Data

/// Represents the data for a single week's chart display
struct WeekData {
    /// Formatted date range string (e.g., "Nov 16-22")
    let dateRange: String
    
    /// Completed task counts for each day of the week (7 values, Sunday-Saturday)
    let dataPoints: [Int]
    
    /// Whether earlier weeks exist (can navigate back)
    let canNavigateBack: Bool
    
    /// Whether we're not at the current week (can navigate forward)
    let canNavigateForward: Bool
    
    /// The start date of this week
    let weekStart: Date
    
    /// The end date of this week
    let weekEnd: Date
}

// MARK: - Data ViewModel

@MainActor
@Observable
final class DataViewModel {
    
    // MARK: - State
    
    /// Whether data is currently loading (for skeleton states)
    var isLoading: Bool = true
    
    /// Whether initial load has completed (prevents re-showing skeleton on tab switches)
    private var hasCompletedInitialLoad: Bool = false
    
    /// All routines with historical data (fetched from RoutineManager)
    private(set) var routines: [Routine] = []
    
    /// Per-routine week offset (0 = current week, -1 = last week, etc.)
    /// Key: Routine ID, Value: Week offset
    private var weekOffsets: [UUID: Int] = [:]
    
    // MARK: - Computed Properties
    
    /// Whether any routines exist
    var hasRoutines: Bool {
        !routines.isEmpty
    }
    
    /// Routines sorted with active routine first, then by createdDate (most recent first)
    var sortedRoutines: [Routine] {
        routines.sorted { r1, r2 in
            // Active routine always comes first
            if r1.isActive && !r2.isActive { return true }
            if !r1.isActive && r2.isActive { return false }
            // Then sort by creation date (most recent first)
            return r1.createdDate > r2.createdDate
        }
    }
    
    // MARK: - Initialization
    
    init() {
        // Don't call refreshData here - let onViewAppear handle initial load with skeleton
    }
    
    // MARK: - View Lifecycle
    
    /// Called when the Data view appears
    /// Shows skeleton on first load, then refreshes data
    func onViewAppear() {
        if !hasCompletedInitialLoad {
            isLoading = true
            
            // Brief delay to show skeleton (visual polish)
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                
                // Fetch data
                performRefresh()
                
                // Complete loading with animation
                withAnimation(AppAnimations.fast) {
                    isLoading = false
                }
                hasCompletedInitialLoad = true
            }
        } else {
            // Subsequent appearances: just refresh without skeleton
            performRefresh()
        }
    }
    
    // MARK: - Data Fetching
    
    /// Refresh the list of routines from RoutineManager
    func refreshData() {
        // For pull-to-refresh: show brief loading, then refresh
        isLoading = true
        
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(200))
            performRefresh()
            
            withAnimation(AppAnimations.fast) {
                isLoading = false
            }
        }
    }
    
    /// Internal refresh without loading state management
    private func performRefresh() {
        routines = RoutineManager.shared.getAllRoutines()
        
        // Initialize week offsets for any new routines
        for routine in routines {
            if weekOffsets[routine.id] == nil {
                weekOffsets[routine.id] = 0 // Start at current week
            }
        }
    }
    
    // MARK: - Week Navigation
    
    /// Get the current week offset for a routine
    func getWeekOffset(for routineId: UUID) -> Int {
        weekOffsets[routineId] ?? 0
    }
    
    /// Navigate to a different week for a specific routine
    /// - Parameters:
    ///   - routineId: The routine's ID
    ///   - direction: `.previous` (go back) or `.next` (go forward)
    func navigateWeek(for routineId: UUID, direction: Direction) {
        let currentOffset = weekOffsets[routineId] ?? 0
        
        // Find the routine to check navigation boundaries
        guard let routine = routines.first(where: { $0.id == routineId }) else {
            return
        }
        
        let calendar = Calendar.current
        let today = Date()
        let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        switch direction {
        case .previous:
            // Calculate what the target week would be
            guard let targetWeekStart = calendar.date(byAdding: .weekOfYear, value: currentOffset - 1, to: currentWeekStart) else {
                return
            }
            
            // Check if we can navigate backward (target week >= routine's start week)
            if canNavigateBackward(routine: routine, currentWeekStart: targetWeekStart) || isInStartWeek(routine: routine, weekStart: targetWeekStart) {
                weekOffsets[routineId] = currentOffset - 1
            }
            
        case .next:
            // Go forward in time (toward 0), but don't go past current week
            if currentOffset < 0 {
                weekOffsets[routineId] = currentOffset + 1
            }
        }
    }
    
    /// Check if a week contains the routine's start date
    private func isInStartWeek(routine: Routine, weekStart: Date) -> Bool {
        guard let startDate = routine.startDate else { return false }
        
        let calendar = Calendar.current
        let routineStartWeek = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start ?? startDate
        
        return calendar.isDate(weekStart, inSameDayAs: routineStartWeek)
    }
    
    // MARK: - Week Data Calculation
    
    /// Calculate the week data for a routine at its current week offset
    /// - Parameter routine: The routine to calculate data for
    /// - Returns: WeekData containing date range, data points, and navigation flags
    func getWeekData(for routine: Routine) -> WeekData {
        let calendar = Calendar.current
        let offset = weekOffsets[routine.id] ?? 0
        
        // Calculate the week boundaries
        let today = Date()
        let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        // Apply offset to get target week
        guard let targetWeekStart = calendar.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart) else {
            return createEmptyWeekData()
        }
        
        guard let targetWeekEnd = calendar.date(byAdding: .day, value: 6, to: targetWeekStart) else {
            return createEmptyWeekData()
        }
        
        // Calculate date range string (e.g., "Nov 16-22")
        let dateRange = formatDateRange(start: targetWeekStart, end: targetWeekEnd)
        
        // Calculate data points (completed tasks per day)
        let dataPoints = calculateDataPoints(for: routine, weekStart: targetWeekStart)
        
        // Determine navigation flags
        let canNavigateBack = canNavigateBackward(routine: routine, currentWeekStart: targetWeekStart)
        let canNavigateForward = offset < 0 // Can only go forward if we're in the past
        
        return WeekData(
            dateRange: dateRange,
            dataPoints: dataPoints,
            canNavigateBack: canNavigateBack,
            canNavigateForward: canNavigateForward,
            weekStart: targetWeekStart,
            weekEnd: targetWeekEnd
        )
    }
    
    /// Calculate completed task counts for each day of a week
    /// - Parameters:
    ///   - routine: The routine to check
    ///   - weekStart: The start of the week (Sunday)
    /// - Returns: Array of 7 integers representing completed tasks for each day
    private func calculateDataPoints(for routine: Routine, weekStart: Date) -> [Int] {
        let calendar = Calendar.current
        var dataPoints: [Int] = []
        
        for dayOffset in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else {
                dataPoints.append(0)
                continue
            }
            
            // Find the DayRecord for this date
            let dayRecord = routine.dayRecords.first { record in
                calendar.isDate(record.date, inSameDayAs: dayDate)
            }
            
            // If record exists, use its completed count; otherwise 0
            let completedCount = dayRecord?.completedTasksCount ?? 0
            dataPoints.append(completedCount)
        }
        
        return dataPoints
    }
    
    /// Check if we can navigate backward (earlier weeks exist)
    private func canNavigateBackward(routine: Routine, currentWeekStart: Date) -> Bool {
        guard let startDate = routine.startDate else { return false }
        
        let calendar = Calendar.current
        let routineStartWeek = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start ?? startDate
        
        // Can go back if the current week is after the routine's start week
        return currentWeekStart > routineStartWeek
    }
    
    /// Format the date range string (e.g., "Nov 16-22")
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let calendar = Calendar.current
        let startMonth = calendar.component(.month, from: start)
        let endMonth = calendar.component(.month, from: end)
        
        if startMonth == endMonth {
            // Same month: "Nov 16-22"
            let endDay = calendar.component(.day, from: end)
            return "\(formatter.string(from: start))-\(endDay)"
        } else {
            // Different months: "Nov 30-Dec 6"
            return "\(formatter.string(from: start))-\(formatter.string(from: end))"
        }
    }
    
    /// Create empty week data for error cases
    private func createEmptyWeekData() -> WeekData {
        return WeekData(
            dateRange: "",
            dataPoints: [0, 0, 0, 0, 0, 0, 0],
            canNavigateBack: false,
            canNavigateForward: false,
            weekStart: Date(),
            weekEnd: Date()
        )
    }
    
    // MARK: - Actions
    
    /// Restart a routine (makes it active, sets startDate to tomorrow)
    ///
    /// **Behavior:**
    /// - Deactivates current active routine (if any)
    /// - Sets this routine as active with startDate = tomorrow
    /// - Resets task completion states
    /// - Schedules notifications
    /// - Refreshes the data list
    ///
    /// - Parameter routine: The routine to restart
    func restartRoutine(_ routine: Routine) {
        // Delegate to RoutineManager for the actual data operation
        RoutineManager.shared.restartRoutine(routine)
        
        // Refresh data to update the UI
        refreshData()
    }
    
    /// Delete a routine and all its data
    ///
    /// **Behavior (per Functional Spec 10.4):**
    /// - Confirmation dialog is handled in the View (Task 4.9)
    /// - Permanently deletes routine, Day Records, Task Completions
    /// - If active: cancels notifications, Routine tab shows empty state
    /// - Refreshes the data list
    ///
    /// - Parameter routine: The routine to delete
    func deleteRoutine(_ routine: Routine) {
        // Delegate to RoutineManager for the actual data operation
        RoutineManager.shared.deleteRoutine(routine)
        
        // Refresh data to update the UI
        refreshData()
    }
}

