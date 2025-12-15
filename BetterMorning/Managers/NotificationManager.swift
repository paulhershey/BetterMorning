//
//  NotificationManager.swift
//  BetterMorning
//
//  Handles local notification scheduling, canceling, and permission management.
//  Per Functional Spec Section 9: One notification per day at the first task time.
//

import Foundation
import UserNotifications

// MARK: - Notification Manager

@Observable
final class NotificationManager {
    
    // MARK: - Singleton
    
    static let shared = NotificationManager()
    
    // MARK: - Properties
    
    /// The notification center instance
    private let notificationCenter = UNUserNotificationCenter.current()
    
    /// Prefix for routine notification identifiers
    private static let notificationPrefix = "com.bettermorning.routine."
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Permission
    
    /// Request notification permission from the user
    /// - Parameter completion: Called with the result (granted or not)
    func requestPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                // Update app state regardless of error
                AppStateManager.shared.notificationsEnabled = granted
                completion(granted)
            }
        }
    }
    
    /// Check current notification authorization status
    /// - Parameter completion: Called with the authorization status
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Schedule Notifications
    
    /// Schedule a daily notification for a routine at the first task time
    /// Per Functional Spec 9.1: "Fires at the **time of the first task** in the active routine"
    ///
    /// - Parameter routine: The routine to schedule notifications for
    func scheduleRoutineNotification(for routine: Routine) {
        // Guard: Only schedule if notifications are enabled
        guard AppStateManager.shared.notificationsEnabled else { return }
        
        // Guard: Need at least one task to determine notification time
        guard !routine.tasks.isEmpty else { return }
        
        // Get the earliest task time
        let sortedTasks = routine.tasks.sorted { $0.time < $1.time }
        guard let firstTask = sortedTasks.first else { return }
        
        // Extract hour and minute from the first task time
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: firstTask.time)
        let minute = calendar.component(.minute, from: firstTask.time)
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Good Morning! ☀️"
        content.body = "Time to start your \(routine.name) routine."
        content.sound = .default
        content.badge = 1
        
        // Create trigger for daily notification at the first task time
        // Per Functional Spec 9.3: "Schedule notification to start firing **from the routine's startDate onwards**"
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create unique identifier for this routine's notification
        let identifier = Self.notificationPrefix + routine.id.uuidString
        
        // Cancel any existing notification for this routine first
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // Create and schedule the request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { _ in
            // Notification scheduled (or failed silently)
        }
    }
    
    // MARK: - Cancel Notifications
    
    /// Cancel notifications for a specific routine
    /// Per Functional Spec 7: "Any old scheduled notifications for the previous routine are canceled"
    ///
    /// - Parameter routine: The routine to cancel notifications for
    func cancelRoutineNotification(for routine: Routine) {
        let identifier = Self.notificationPrefix + routine.id.uuidString
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Cancel notifications for a routine by its ID
    /// - Parameter routineId: The UUID of the routine
    func cancelRoutineNotification(routineId: UUID) {
        let identifier = Self.notificationPrefix + routineId.uuidString
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Cancel all scheduled notifications
    /// Per Functional Spec 11.2: "Cancel any scheduled notifications for the app" on reset
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    // MARK: - Badge Management
    
    /// Clear the app badge (call on app launch or when opening app)
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in
            // Badge cleared (or failed silently)
        }
    }
}

