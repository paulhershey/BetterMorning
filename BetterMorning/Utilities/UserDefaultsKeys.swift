//
//  UserDefaultsKeys.swift
//  BetterMorning
//
//  Centralized UserDefaults key constants to prevent typos and enable easy maintenance.
//

import Foundation

/// Centralized UserDefaults keys for the app
enum UserDefaultsKeys {
    
    // MARK: - Onboarding
    
    /// Whether the user has completed the onboarding flow
    /// - Reset behavior: Cleared on "Reset all data"
    static let hasCompletedOnboarding = "com.bettermorning.hasCompletedOnboarding"
    
    // MARK: - Purchases
    
    /// Whether the user has purchased premium (custom routine creation)
    /// - Reset behavior: NOT cleared on "Reset all data"
    /// - Note: This is also verified via StoreKit restore
    static let hasPurchasedPremium = "com.bettermorning.hasPurchasedPremium"
    
    // MARK: - Notifications
    
    /// Whether in-app notifications are enabled
    /// - Reset behavior: Cleared on "Reset all data"
    static let notificationsEnabled = "com.bettermorning.notificationsEnabled"
    
    // MARK: - Day Finalization
    
    /// The last date when midnight check was performed
    /// - Used to determine if previous day needs to be finalized
    /// - Reset behavior: Cleared on "Reset all data"
    static let lastMidnightCheck = "com.bettermorning.lastMidnightCheck"
}

