//
//  IconButton.swift
//  BetterMorning
//
//  A circular icon button for actions.
//

import SwiftUI

// MARK: - Icon Button View
struct IconButton: View {
    let iconName: String
    let action: () -> Void
    
    init(_ iconName: String, action: @escaping () -> Void) {
        self.iconName = iconName
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(iconName)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.colorNeutralWhite)
                .frame(width: .sp24, height: .sp24)
                .padding(.sp16)
                .background(Color.colorNeutralBlack)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview("Icon Button") {
    VStack(spacing: .sp24) {
        // Settings icon
        IconButton("icon_settings_white") {
            print("Settings tapped")
        }
    }
    .padding(.sp40)
}


