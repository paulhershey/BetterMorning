//
//  TabItem.swift
//  BetterMorning
//
//  A capsule-shaped tab bar item component.
//

import SwiftUI

// MARK: - Tab Item View
struct TabItem: View {
    let iconName: String
    let isActive: Bool
    let action: () -> Void
    
    init(
        iconName: String,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.isActive = isActive
        self.action = action
    }
    
    private var backgroundColor: Color {
        isActive ? Color.colorNeutralBlack : Color.colorNeutralWhite
    }
    
    private var iconColor: Color {
        isActive ? Color.colorNeutralWhite : Color.colorNeutralBlack
    }
    
    var body: some View {
        Button(action: action) {
            Image(iconName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: .iconMedium, height: .iconMedium)
                .foregroundStyle(iconColor)
                .padding(.vertical, .sp16)
                // UPDATED: Fixed width of 104pt (using your system variable)
                .frame(width: .sp104)
                .background(backgroundColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview("Tab Item Variants") {
    ZStack {
        Color.colorNeutralGrey1
            .ignoresSafeArea()
        
        HStack(spacing: .sp8) {
            TabItem(
                iconName: "icon_explore_black",
                isActive: true
            ) {}
            
            TabItem(
                iconName: "icon_routine_black",
                isActive: false
            ) {}
            
            TabItem(
                iconName: "icon_data_black",
                isActive: false
            ) {}
        }
        .padding(.sp24)
    }
}
