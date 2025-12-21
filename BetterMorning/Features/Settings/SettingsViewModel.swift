//
//  SettingsViewModel.swift
//  BetterMorning
//
//  ViewModel managing Settings sheet state: notifications and reset logic.
//

import SwiftUI
import SwiftData

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - State
    
    /// Whether notifications are enabled in-app (synced with AppStateManager)
    var notificationsEnabled: Bool {
        get { AppStateManager.shared.notificationsEnabled }
        set { AppStateManager.shared.notificationsEnabled = newValue }
    }
    
    /// Whether system-level notifications are denied (user must go to Settings)
    private(set) var systemNotificationsDenied: Bool = false
    
    /// Human-readable subtitle for the notification toggle when denied
    var notificationSubtitle: String? {
        systemNotificationsDenied ? "Open Settings to enable" : nil
    }
    
    // MARK: - Initialization
    
    init() {
        checkNotificationPermissions()
    }
    
    // MARK: - Notification Permissions
    
    /// Check the current system notification permission status
    ///
    /// Per Functional Spec 9.2: "Any in-app toggles related to notifications
    /// should appear **off**, reflecting that notifications aren't active."
    func checkNotificationPermissions() {
        NotificationManager.shared.checkAuthorizationStatus { [weak self] status in
            switch status {
            case .denied:
                self?.systemNotificationsDenied = true
                // Per spec: Toggle should appear OFF when system denied
                self?.notificationsEnabled = false
            case .authorized, .provisional, .ephemeral:
                self?.systemNotificationsDenied = false
            case .notDetermined:
                self?.systemNotificationsDenied = false
            @unknown default:
                self?.systemNotificationsDenied = false
            }
        }
    }
    
    /// Handle the notification toggle interaction
    /// - Parameter newValue: The desired toggle state
    func handleNotificationToggle(newValue: Bool) {
        if newValue {
            // User wants to enable notifications
            if systemNotificationsDenied {
                // Can't enable - system denied, need to go to Settings
                // The toggle will be disabled, but just in case:
                notificationsEnabled = false
            } else {
                // Request permission via NotificationManager (centralized)
                NotificationManager.shared.requestPermission { [weak self] granted in
                    // NotificationManager already updates AppStateManager.notificationsEnabled
                    if !granted {
                        self?.systemNotificationsDenied = true
                    }
                }
            }
        } else {
            // User wants to disable notifications
            notificationsEnabled = false
            // Note: We can't actually revoke system permission,
            // we just stop scheduling notifications in-app
        }
    }
    
    /// Open the app's Settings in the Settings app
    func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    // MARK: - Reset All Data
    
    /// Reset all app data (called after confirmation)
    /// - Parameter modelContext: The SwiftData model context
    /// - Returns: True if reset was successful
    @discardableResult
    func performReset(modelContext: ModelContext) -> Bool {
        // Cancel all scheduled notifications via NotificationManager
        NotificationManager.shared.cancelAllNotifications()
        
        // Delegate to AppStateManager for the actual reset
        return AppStateManager.shared.resetAllData(modelContext: modelContext)
    }
}

