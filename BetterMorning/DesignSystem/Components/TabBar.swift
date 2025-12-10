//
//  TabBar.swift
//  BetterMorning
//
//  A floating tab bar with animated selection indicator.
//

import SwiftUI

// MARK: - App Tab Enum
enum AppTab: String, CaseIterable {
    case explore
    case routine
    case data
    
    var iconName: String {
        switch self {
        case .explore:
            return "icon_explore_black"
        case .routine:
            return "icon_routine_black"
        case .data:
            return "icon_data_black"
        }
    }
}

// MARK: - Tab Bar View
struct TabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var namespace
    
    var body: some View {
        // UPDATED: Added .sp24 spacing between tabs
        HStack(spacing: .sp16) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.sp8)
        .background(
            Capsule()
                .fill(Color.colorNeutralWhite)
        )
        .applyShadow(AppShadows.default)
    }
    
    // MARK: - Tab Button
    @ViewBuilder
    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        
        Button {
            withAnimation(.snappy) {
                selectedTab = tab
            }
        } label: {
            ZStack {
                // Background - animated sliding pill
                if isSelected {
                    Capsule()
                        .fill(Color.colorNeutralBlack)
                        .matchedGeometryEffect(id: "activeBackground", in: namespace)
                } else {
                    Color.clear
                }
                
                // Icon overlay
                Image(tab.iconName)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(isSelected ? Color.colorNeutralWhite : Color.colorNeutralBlack)
            }
            .frame(width: .sp104, height: 56)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview("Tab Bar") {
    TabBarPreview()
}

// Preview wrapper with @State for interactive selection
private struct TabBarPreview: View {
    @State private var selectedTab: AppTab = .explore
    
    var body: some View {
        ZStack {
            Color.colorNeutralGrey1
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                TabBar(selectedTab: $selectedTab)
                    .padding(.bottom, .sp8)
            }
        }
    }
}
