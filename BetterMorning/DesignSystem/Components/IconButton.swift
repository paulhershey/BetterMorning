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
    let accessibilityLabel: String
    let action: () -> Void
    
    init(_ iconName: String, accessibilityLabel: String? = nil, action: @escaping () -> Void) {
        self.iconName = iconName
        // Derive accessibility label from icon name if not provided
        self.accessibilityLabel = accessibilityLabel ?? Self.deriveLabel(from: iconName)
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
        .accessibilityLabel(accessibilityLabel)
    }
    
    /// Derives a readable label from the icon name
    private static func deriveLabel(from iconName: String) -> String {
        // Convert "icon_settings_white" to "Settings"
        let cleaned = iconName
            .replacingOccurrences(of: "icon_", with: "")
            .replacingOccurrences(of: "_white", with: "")
            .replacingOccurrences(of: "_black", with: "")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
        return cleaned
    }
}

// MARK: - Preview
#Preview("Icon Button") {
    VStack(spacing: .sp24) {
        // Settings icon
        IconButton("icon_settings_white") {}
    }
    .padding(.sp40)
}


