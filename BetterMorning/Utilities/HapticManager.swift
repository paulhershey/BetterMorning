//
//  HapticManager.swift
//  BetterMorning
//
//  Centralized haptic feedback management for consistent tactile responses.
//

import UIKit

/// Manages haptic feedback throughout the app
enum HapticManager {
    
    // MARK: - Feedback Generators (lazy initialization)
    
    private static let impactLight = UIImpactFeedbackGenerator(style: .light)
    private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let selectionFeedback = UISelectionFeedbackGenerator()
    private static let notificationFeedback = UINotificationFeedbackGenerator()
    
    // MARK: - Public Methods
    
    /// Light tap - for subtle interactions (toggles, selections)
    static func lightTap() {
        impactLight.impactOccurred()
    }
    
    /// Medium tap - for button presses
    static func mediumTap() {
        impactMedium.impactOccurred()
    }
    
    /// Heavy tap - for significant actions (completing tasks)
    static func heavyTap() {
        impactHeavy.impactOccurred()
    }
    
    /// Selection changed - for tab switching, picker changes
    static func selectionChanged() {
        selectionFeedback.selectionChanged()
    }
    
    /// Success notification - for completing routines, purchases
    static func success() {
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// Warning notification - for delete confirmations
    static func warning() {
        notificationFeedback.notificationOccurred(.warning)
    }
    
    /// Error notification - for failures
    static func error() {
        notificationFeedback.notificationOccurred(.error)
    }
    
    // MARK: - Prepare Methods (call before anticipated feedback)
    
    /// Prepare impact generator for upcoming feedback
    static func prepareImpact() {
        impactMedium.prepare()
    }
    
    /// Prepare selection generator for upcoming feedback
    static func prepareSelection() {
        selectionFeedback.prepare()
    }
    
    /// Prepare notification generator for upcoming feedback
    static func prepareNotification() {
        notificationFeedback.prepare()
    }
}

