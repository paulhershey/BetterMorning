//
//  MainTabView.swift
//  BetterMorning
//
//  Main navigation container with custom floating tab bar.
//

import SwiftUI

struct MainTabView: View {
    
    /// Reference to the observable app state manager for tab selection
    @Bindable private var appState = AppStateManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected tab
            Group {
                switch appState.selectedTab {
                case .explore:
                    NavigationStack {
                        ExploreView()
                    }
                case .routine:
                    NavigationStack {
                        RoutineView()
                    }
                case .data:
                    NavigationStack {
                        DataView()
                    }
                }
            }
            
            // Floating Tab Bar
            TabBar(selectedTab: $appState.selectedTab)
                .padding(.bottom, .sp8)
        }
    }
}

// MARK: - Preview
#Preview("Main Tab View") {
    MainTabView()
}

