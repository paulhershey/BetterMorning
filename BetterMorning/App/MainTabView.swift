//
//  MainTabView.swift
//  BetterMorning
//
//  Main navigation container with custom floating tab bar.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .explore
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected tab
            Group {
                switch selectedTab {
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
            TabBar(selectedTab: $selectedTab)
                .padding(.bottom, .sp8)
        }
    }
}

// MARK: - Preview
#Preview("Main Tab View") {
    MainTabView()
}

