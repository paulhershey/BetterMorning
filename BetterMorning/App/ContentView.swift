//
//  ContentView.swift
//  BetterMorning
//
//  Root view that routes between Onboarding and MainTabView based on app state.
//

import SwiftUI

struct ContentView: View {
    
    // Observe app state for reactive updates
    private var appState = AppStateManager.shared
    
    var body: some View {
        Group {
            if appState.shouldShowOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
    }
}

// MARK: - Preview
#Preview("Content View - Main App") {
    ContentView()
}

#Preview("Content View - Onboarding") {
    // Reset onboarding state for preview
    let _ = {
        AppStateManager.shared.hasCompletedOnboarding = false
    }()
    return ContentView()
}
