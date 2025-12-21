//
//  AppStateManager.swift
//  BetterMorning
//
//  Observable singleton managing app-wide state: onboarding, purchases, and settings.
//

import Foundation
import SwiftData
import SwiftUI

/// Error types for app state operations
enum AppStateError: LocalizedError {
    case resetFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .resetFailed:
            return "Failed to reset app data. Please try again."
        case .saveFailed:
            return "Failed to save changes. Please try again."
        }
    }
}

@MainActor
@Observable
final class AppStateManager {
    
    // MARK: - Singleton
    static let shared = AppStateManager()
    
    private init() {
        // Load persisted values on init
        loadPersistedState()
    }
    
    // MARK: - Navigation State
    
    /// Currently selected tab (not persisted)
    var selectedTab: AppTab = .explore
    
    /// Last error that occurred during an app state operation
    var lastError: AppStateError?
    
    // MARK: - Observable State
    
    /// Whether the user has completed onboarding (cleared on reset)
    var hasCompletedOnboarding: Bool = false {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        }
    }
    
    /// Whether the user has purchased premium/custom routines (NOT cleared on reset)
    var hasPurchasedPremium: Bool = false {
        didSet {
            UserDefaults.standard.set(hasPurchasedPremium, forKey: UserDefaultsKeys.hasPurchasedPremium)
        }
    }
    
    /// Whether notifications are enabled in-app (cleared on reset)
    var notificationsEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: UserDefaultsKeys.notificationsEnabled)
        }
    }
    
    /// Last time midnight check was performed (for day finalization logic)
    var lastMidnightCheck: Date? = nil {
        didSet {
            UserDefaults.standard.set(lastMidnightCheck, forKey: UserDefaultsKeys.lastMidnightCheck)
        }
    }
    
    // MARK: - Computed Properties
    
    /// The currently active routine (delegates to RoutineManager)
    var activeRoutine: Routine? {
        RoutineManager.shared.getActiveRoutine()
    }
    
    /// Whether there is an active routine
    var hasActiveRoutine: Bool {
        activeRoutine != nil
    }
    
    /// Whether the active routine starts today or earlier (user can interact with tasks)
    var isRoutineRunningToday: Bool {
        guard let routine = activeRoutine,
              let startDate = routine.startDate else {
            return false
        }
        return startDate <= Date()
    }
    
    /// Whether onboarding should be shown
    var shouldShowOnboarding: Bool {
        !hasCompletedOnboarding
    }
    
    // MARK: - Actions
    
    /// Mark onboarding as completed
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    /// Mark premium as purchased (called by StoreKit integration)
    func unlockPremium() {
        hasPurchasedPremium = true
    }
    
    /// Switch to a specific tab with animation
    func switchToTab(_ tab: AppTab) {
        withAnimation(AppAnimations.standard) {
            selectedTab = tab
        }
    }
    
    /// Reset all app data (called from Settings)
    /// Note: Does NOT reset hasPurchasedPremium per spec
    /// - Returns: True if reset was successful
    @discardableResult
    func resetAllData(modelContext: ModelContext) -> Bool {
        // 1. Clear UserDefaults (except purchase state)
        hasCompletedOnboarding = false
        notificationsEnabled = false // Reset to OFF - user can re-enable during onboarding
        lastMidnightCheck = nil
        
        // 2. Delete all SwiftData records
        do {
            // Delete all routines (cascades to tasks and day records)
            try modelContext.delete(model: Routine.self)
            try modelContext.save()
            lastError = nil
            return true
        } catch {
            lastError = .resetFailed
            return false
        }
        
        // 3. Cancel scheduled notifications
        // Note: Notification cancellation is handled by SettingsViewModel.performReset()
        // which calls this method after cancelling all notifications
    }
    
    /// Perform midnight check and finalize previous day if needed
    func performMidnightCheckIfNeeded(modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if we've already done the midnight check today
        if let lastCheck = lastMidnightCheck,
           Calendar.current.isDate(lastCheck, inSameDayAs: today) {
            return // Already checked today
        }
        
        // Finalize the previous day for the active routine
        if let routine = activeRoutine {
            finalizePreviousDay(for: routine, modelContext: modelContext)
        }
        
        // Update last check timestamp
        lastMidnightCheck = today
    }
    
    // MARK: - Private Helpers
    
    private func loadPersistedState() {
        let defaults = UserDefaults.standard
        hasCompletedOnboarding = defaults.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        hasPurchasedPremium = defaults.bool(forKey: UserDefaultsKeys.hasPurchasedPremium)
        notificationsEnabled = defaults.object(forKey: UserDefaultsKeys.notificationsEnabled) as? Bool ?? true
        lastMidnightCheck = defaults.object(forKey: UserDefaultsKeys.lastMidnightCheck) as? Date
    }
    
    private func finalizePreviousDay(for routine: Routine, modelContext: ModelContext) {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterdayStart = Calendar.current.startOfDay(for: yesterday)
        
        // Check if a DayRecord already exists for yesterday
        let existingRecords = routine.dayRecords.filter {
            Calendar.current.isDate($0.date, inSameDayAs: yesterdayStart)
        }
        
        guard existingRecords.isEmpty else {
            return // Already finalized
        }
        
        // Only create record if routine was active yesterday (startDate <= yesterday)
        guard let startDate = routine.startDate,
              startDate <= yesterdayStart else {
            return
        }
        
        // Count completed tasks
        let completedCount = routine.tasks.filter { $0.isCompleted }.count
        
        // Create the day record
        let dayRecord = DayRecord(
            date: yesterdayStart,
            completedTasksCount: completedCount,
            routine: routine
        )
        
        modelContext.insert(dayRecord)
        
        // Create TaskCompletion records for each task (for ✓/✕ display on past days)
        for task in routine.tasks {
            let completion = TaskCompletion(
                taskId: task.id,
                taskTitle: task.title,
                orderIndex: task.orderIndex,
                state: task.isCompleted ? .completed : .incomplete,
                dayRecord: dayRecord
            )
            modelContext.insert(completion)
            dayRecord.taskCompletions.append(completion)
        }
        
        // Reset task completion states for the new day
        for task in routine.tasks {
            task.isCompleted = false
        }
        
        do {
            try modelContext.save()
            lastError = nil
        } catch {
            lastError = .saveFailed
        }
    }
}

