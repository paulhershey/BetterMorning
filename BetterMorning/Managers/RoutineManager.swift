import Foundation
import SwiftData
import SwiftUI

@Observable
class RoutineManager {
    static let shared = RoutineManager()
    
    // Stored ModelContext for database operations
    private var modelContext: ModelContext?
    
    // Private initializer for singleton
    private init() {}
    
    // Time formatter for parsing celebrity task times
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    // MARK: - Configuration
    
    /// Configure the manager with a ModelContext. Call this once at app launch.
    func configure(with context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Routine Activation
    
    /// Activate a celebrity routine (creates a new Routine in SwiftData)
    func activate(celebrityRoutine: CelebrityRoutine) {
        guard let context = modelContext else { return }
        
        // 1. Deactivate any currently active routine
        deactivateCurrentRoutine()
        
        // 2. Create the new Routine in the Database
        let newRoutine = Routine(
            name: celebrityRoutine.name,
            type: .celebrity,
            isActive: true,
            bio: celebrityRoutine.bio,
            imageName: celebrityRoutine.imageName
        )
        
        // Set start date to Tomorrow
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            newRoutine.startDate = Calendar.current.startOfDay(for: tomorrow)
        }
        
        // 3. Convert and Add Tasks
        for (index, celebTask) in celebrityRoutine.tasks.enumerated() {
            // Parse the time string (e.g. "7:00 AM")
            let dateValues = Self.timeFormatter.date(from: celebTask.time) ?? Date()
            
            // Extract just the hour/minute components to create a generic "time"
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: dateValues)
            let taskTime = Calendar.current.date(from: timeComponents) ?? Date()
            
            let newTask = RoutineTask(
                title: celebTask.title,
                time: taskTime,
                orderIndex: index
            )
            
            newRoutine.tasks.append(newTask)
        }
        
        // 4. Save to Database
        context.insert(newRoutine)
        
        do {
            try context.save()
            
            // Schedule notifications for the new routine
            // Per Functional Spec 9.3: Schedule notification from startDate onwards
            scheduleNotificationsForRoutine(newRoutine)
        } catch {
            // Save failed - routine activation incomplete
        }
    }
    
    // MARK: - Routine Deactivation
    
    /// Deactivate the current active routine
    /// Per Functional Spec 7.1: Finalize today's DayRecord before switching
    /// Per Functional Spec 7.5: Cancel notifications for the old routine when switching
    func deactivateCurrentRoutine() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<Routine>(
            predicate: #Predicate { $0.isActive == true }
        )
        
        do {
            let activeRoutines = try context.fetch(descriptor)
            let today = Calendar.current.startOfDay(for: Date())
            
            for routine in activeRoutines {
                // Per Func Spec 7.1: Finalize today's data before deactivating
                // Only finalize if routine was active today (startDate <= today)
                if let startDate = routine.startDate, startDate <= today {
                    finalizeDay(for: routine, on: today)
                }
                
                // Cancel notifications for this routine before deactivating
                cancelNotificationsForRoutine(routine)
                routine.isActive = false
            }
            try context.save()
        } catch {
            // Deactivation failed - will retry on next operation
        }
    }
    
    // MARK: - Query Helpers
    
    /// Get the currently active routine
    func getActiveRoutine() -> Routine? {
        guard let context = modelContext else { return nil }
        
        let descriptor = FetchDescriptor<Routine>(
            predicate: #Predicate { $0.isActive == true }
        )
        
        do {
            return try context.fetch(descriptor).first
        } catch {
            return nil
        }
    }
    
    /// Get all routines
    func getAllRoutines() -> [Routine] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<Routine>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            return []
        }
    }
    
    // MARK: - Task Completion
    
    /// Toggle the completion state of a task for a specific date
    ///
    /// **Logic:**
    /// - If a TaskCompletion record exists → delete it (un-check)
    /// - If no TaskCompletion record exists → create one with state = .completed (check)
    ///
    /// - Parameters:
    ///   - task: The RoutineTask to toggle
    ///   - date: The date to toggle completion for (normalized to midnight)
    func toggleCompletion(for task: RoutineTask, on date: Date) {
        guard let context = modelContext else { return }
        
        guard let routine = task.routine else { return }
        
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        // Get or create the DayRecord for this date
        let dayRecord = getOrCreateDayRecord(for: routine, on: normalizedDate)
        
        // Check if a TaskCompletion already exists for this task on this date
        if let existingCompletion = findTaskCompletion(taskId: task.id, in: dayRecord) {
            // Toggle: If completed, set to incomplete (or delete)
            // Per spec, unchecking returns to "untouched" state, so we delete the record
            context.delete(existingCompletion)
            dayRecord.completedTasksCount = max(0, dayRecord.completedTasksCount - 1)
        } else {
            // Create a new TaskCompletion record
            let completion = TaskCompletion(
                taskId: task.id,
                taskTitle: task.title,
                orderIndex: task.orderIndex,
                state: .completed,
                dayRecord: dayRecord
            )
            context.insert(completion)
            dayRecord.taskCompletions.append(completion)
            dayRecord.completedTasksCount += 1
        }
        
        // Also update the in-memory task.isCompleted for immediate UI feedback
        task.isCompleted.toggle()
        
        // Save changes
        do {
            try context.save()
        } catch {
            // Task completion save failed - UI state may be out of sync
        }
    }
    
    /// Check if a task is completed for a specific date
    ///
    /// - Parameters:
    ///   - task: The RoutineTask to check
    ///   - date: The date to check completion for
    /// - Returns: Whether the task was completed on that date
    func isTaskCompleted(_ task: RoutineTask, on date: Date) -> Bool {
        guard let routine = task.routine else { return false }
        
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        // Find the DayRecord for this date
        guard let dayRecord = routine.dayRecords.first(where: { record in
            calendar.isDate(record.date, inSameDayAs: normalizedDate)
        }) else {
            return false
        }
        
        // Find the TaskCompletion for this task
        let completion = dayRecord.taskCompletions.first { $0.taskId == task.id }
        return completion?.state == .completed
    }
    
    // MARK: - Private Helpers
    
    /// Get or create a DayRecord for a specific date and routine
    private func getOrCreateDayRecord(for routine: Routine, on date: Date) -> DayRecord {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        // Check if a DayRecord already exists for this date
        if let existingRecord = routine.dayRecords.first(where: { record in
            calendar.isDate(record.date, inSameDayAs: normalizedDate)
        }) {
            return existingRecord
        }
        
        // Create a new DayRecord
        let newRecord = DayRecord(
            date: normalizedDate,
            completedTasksCount: 0,
            routine: routine
        )
        
        guard let context = modelContext else { return newRecord }
        
        context.insert(newRecord)
        routine.dayRecords.append(newRecord)
        
        do {
            try context.save()
        } catch {
            // DayRecord creation failed
        }
        
        return newRecord
    }
    
    /// Find a TaskCompletion record for a specific task in a DayRecord
    private func findTaskCompletion(taskId: UUID, in dayRecord: DayRecord) -> TaskCompletion? {
        return dayRecord.taskCompletions.first { $0.taskId == taskId }
    }
    
    // MARK: - Midnight Check / Day Finalization
    
    /// Perform midnight check and finalize previous day if needed
    ///
    /// **Functional Spec 8.4 Requirements:**
    /// - At midnight, all tasks not marked ✓ become ✕ (incomplete)
    /// - A DayRecord is finalized for that date
    /// - User wakes to fresh, untouched tasks for the new day
    ///
    /// Call this on app launch and when RoutineView appears.
    func performMidnightCheck() {
        guard modelContext != nil else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we've already done the midnight check today
        let lastCheck = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastMidnightCheck) as? Date
        if let lastCheck = lastCheck, calendar.isDate(lastCheck, inSameDayAs: today) {
            return // Already checked today
        }
        
        // Get the active routine
        guard let routine = getActiveRoutine() else {
            // No active routine, just update the timestamp
            UserDefaults.standard.set(today, forKey: UserDefaultsKeys.lastMidnightCheck)
            AppStateManager.shared.lastMidnightCheck = today
            return
        }
        
        // Calculate yesterday
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) else {
            return
        }
        
        // Check if routine was active yesterday
        if let startDate = routine.startDate,
           calendar.startOfDay(for: startDate) <= calendar.startOfDay(for: yesterday) {
            
            // Finalize yesterday's data
            finalizeDay(for: routine, on: yesterday)
            
            // Reset task.isCompleted for today (fresh start)
            resetTasksForNewDay(routine: routine)
        }
        
        // Update last check timestamp
        UserDefaults.standard.set(today, forKey: UserDefaultsKeys.lastMidnightCheck)
        AppStateManager.shared.lastMidnightCheck = today
    }
    
    /// Finalize a specific day's data for a routine
    ///
    /// **Functional Spec 2.3 Requirements:**
    /// - Only one DayRecord per (routineId, date)
    /// - completedTasksCount = number of ✓ tasks that day
    ///
    /// This function is reusable for:
    /// - Midnight reset (finalize yesterday)
    /// - Routine switching (finalize current day for old routine)
    ///
    /// - Parameters:
    ///   - routine: The Routine to finalize
    ///   - date: The date to finalize (will be normalized to midnight)
    func finalizeDay(for routine: Routine, on date: Date) {
        guard let context = modelContext else { return }
        
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        // Check if a DayRecord already exists for this date (upsert logic)
        let existingRecord = routine.dayRecords.first { record in
            calendar.isDate(record.date, inSameDayAs: normalizedDate)
        }
        
        // Count completed tasks from TaskCompletion records in the database
        let completedCount = countCompletedTasks(for: routine, on: normalizedDate)
        
        if let existingRecord = existingRecord {
            // UPDATE: Record already exists, update the count
            existingRecord.completedTasksCount = completedCount
        } else {
            // INSERT: Create new DayRecord
            let dayRecord = DayRecord(
                date: normalizedDate,
                completedTasksCount: completedCount,
                routine: routine
            )
            
            context.insert(dayRecord)
            routine.dayRecords.append(dayRecord)
            
            // Create TaskCompletion records for each task (for ✓/✕ display on past days)
            // Only if they don't already exist
            createTaskCompletionRecords(for: routine, dayRecord: dayRecord)
        }
        
        // Save changes
        do {
            try context.save()
        } catch {
            // Day finalization failed - will retry on next check
        }
    }
    
    /// Count completed tasks from TaskCompletion records in the database
    ///
    /// - Parameters:
    ///   - routine: The Routine to check
    ///   - date: The date to count completions for (normalized)
    /// - Returns: Number of completed tasks
    private func countCompletedTasks(for routine: Routine, on date: Date) -> Int {
        let calendar = Calendar.current
        
        // First, check if there's an existing DayRecord with TaskCompletions
        if let dayRecord = routine.dayRecords.first(where: { record in
            calendar.isDate(record.date, inSameDayAs: date)
        }) {
            // Count from saved TaskCompletion records
            return dayRecord.taskCompletions.filter { $0.state == .completed }.count
        }
        
        // Fallback: If no DayRecord exists yet, count from task.isCompleted
        // (This happens during first finalization of a day)
        return routine.tasks.filter { $0.isCompleted }.count
    }
    
    /// Create TaskCompletion records for each task in a routine
    ///
    /// - Parameters:
    ///   - routine: The Routine with tasks
    ///   - dayRecord: The DayRecord to attach completions to
    private func createTaskCompletionRecords(for routine: Routine, dayRecord: DayRecord) {
        guard let context = modelContext else { return }
        
        for task in routine.tasks {
            // Check if completion already exists
            let existingCompletion = dayRecord.taskCompletions.first { $0.taskId == task.id }
            
            if existingCompletion == nil {
                let completion = TaskCompletion(
                    taskId: task.id,
                    taskTitle: task.title,
                    orderIndex: task.orderIndex,
                    state: task.isCompleted ? .completed : .incomplete,
                    dayRecord: dayRecord
                )
                context.insert(completion)
                dayRecord.taskCompletions.append(completion)
            }
        }
    }
    
    /// Reset all task.isCompleted flags for a new day
    ///
    /// - Parameter routine: The Routine to reset
    private func resetTasksForNewDay(routine: Routine) {
        guard let context = modelContext else { return }
        
        for task in routine.tasks {
            task.isCompleted = false
        }
        
        do {
            try context.save()
        } catch {
            // Task reset failed
        }
    }
    
    // MARK: - Restart Routine
    
    /// Restart an existing routine (makes it active, starts tomorrow)
    ///
    /// **Functional Spec Requirements:**
    /// - Only one routine can be active at a time
    /// - Restarting preserves historical data
    /// - New period starts tomorrow with fresh tasks
    ///
    /// - Parameter routine: The Routine to restart
    func restartRoutine(_ routine: Routine) {
        guard let context = modelContext else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 1. Handle currently active routine (if any, and if different from target)
        if let currentActive = getActiveRoutine(), currentActive.id != routine.id {
            // Finalize today's data for the old routine before deactivating
            finalizeDay(for: currentActive, on: today)
            
            // Deactivate the old routine
            currentActive.isActive = false
        }
        
        // 2. Set the target routine as active
        routine.isActive = true
        
        // 3. Set startDate to tomorrow
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
            routine.startDate = tomorrow
        }
        
        // 4. Reset all task completion states (fresh start)
        for task in routine.tasks {
            task.isCompleted = false
        }
        
        // 5. Schedule notifications
        scheduleNotificationsForRoutine(routine)
        
        // 6. Save changes
        do {
            try context.save()
        } catch {
            // Restart failed
        }
    }
    
    // MARK: - Delete Routine
    
    /// Delete a routine and all its associated data
    ///
    /// **Functional Spec 10.4 Requirements:**
    /// - Permanently delete the routine, all Day Records, all Task Completions
    /// - If the deleted routine was active:
    ///   - Set active routine to nil
    ///   - Cancel scheduled notifications
    ///   - Routine tab shows empty state
    ///
    /// - Parameter routine: The Routine to delete
    func deleteRoutine(_ routine: Routine) {
        guard let context = modelContext else { return }
        
        let wasActive = routine.isActive
        
        // 1. If this was the active routine, cancel notifications
        if wasActive {
            cancelNotificationsForRoutine(routine)
        }
        
        // 2. Delete the routine (SwiftData cascade handles related entities)
        context.delete(routine)
        
        // 3. Save changes
        do {
            try context.save()
        } catch {
            // Deletion failed
        }
    }
    
    // MARK: - Notifications
    
    /// Schedule notifications for a routine
    /// Delegates to NotificationManager for actual scheduling
    ///
    /// - Parameter routine: The Routine to schedule notifications for
    func scheduleNotificationsForRoutine(_ routine: Routine) {
        NotificationManager.shared.scheduleRoutineNotification(for: routine)
    }
    
    /// Cancel notifications for a routine
    /// Delegates to NotificationManager for actual cancellation
    ///
    /// - Parameter routine: The Routine to cancel notifications for
    private func cancelNotificationsForRoutine(_ routine: Routine) {
        NotificationManager.shared.cancelRoutineNotification(for: routine)
    }
}
