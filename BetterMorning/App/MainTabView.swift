//
//  MainTabView.swift
//  BetterMorning
//
//  Main navigation container with custom floating tab bar and swipe navigation.
//

import SwiftUI

struct MainTabView: View {
    
    /// Reference to the observable app state manager for tab selection
    @Bindable private var appState = AppStateManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Swipeable tab content using TabView with page style
            // Provides native iOS swipe behavior with bounce at edges
            TabView(selection: $appState.selectedTab) {
                NavigationStack {
                    ExploreView()
                }
                .tag(AppTab.explore)
                
                NavigationStack {
                    RoutineView()
                }
                .tag(AppTab.routine)
                
                NavigationStack {
                    DataView()
                }
                .tag(AppTab.data)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .onChange(of: appState.selectedTab) { _, _ in
                // Haptic feedback when swiping between tabs
                HapticManager.selectionChanged()
            }
            
            // Floating Tab Bar (overlays the swipeable content)
            TabBar(selectedTab: $appState.selectedTab)
                .padding(.bottom, .sp8)
        }
    }
}

// MARK: - Preview
#Preview("Main Tab View") {
    MainTabView()
}

