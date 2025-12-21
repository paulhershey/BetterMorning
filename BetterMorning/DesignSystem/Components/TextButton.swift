//
//  TextButton.swift
//  BetterMorning
//
//  A pill-shaped button with an icon and text label.
//

import SwiftUI

// MARK: - Text Button Variant
enum TextButtonVariant {
    case branded
    case primary
    case secondary
    case disabled
    
    var backgroundColor: Color {
        switch self {
        case .branded:
            return Color.brandSecondary
        case .primary:
            return Color.colorNeutralBlack
        case .secondary:
            return Color.colorNeutralGrey1
        case .disabled:
            return Color.colorNeutralGrey1
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .branded:
            return Color.colorNeutralBlack
        case .primary:
            return Color.colorNeutralWhite
        case .secondary:
            return Color.colorNeutralGrey2
        case .disabled:
            return Color.colorNeutralGrey2
        }
    }
    
    var iconName: String {
        switch self {
        case .branded:
            return "icon_add_black"
        case .primary:
            return "icon_add_white"
        case .secondary, .disabled:
            return "icon_add_black"
        }
    }
}

// MARK: - Text Button View
struct TextButton: View {
    let text: String
    let variant: TextButtonVariant
    let iconName: String?
    let action: () -> Void
    
    init(
        _ text: String,
        variant: TextButtonVariant = .branded,
        iconName: String? = nil,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.variant = variant
        self.iconName = iconName
        self.action = action
    }
    
    private var resolvedIconName: String {
        iconName ?? variant.iconName
    }
    
    var body: some View {
        Button {
            HapticManager.mediumTap()
            action()
        } label: {
            HStack(spacing: .sp4) {
                Image(resolvedIconName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(variant.foregroundColor)
                    .frame(width: .sp24, height: .sp24)
                
                Text(text)
                    .style(.buttonText)
                    .foregroundStyle(variant.foregroundColor)
            }
            .padding(.leading, .sp16)
            .padding(.trailing, .sp24)
            .padding(.vertical, .sp16)
            .background(variant.backgroundColor)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
    }
}

// MARK: - Preview
#Preview("Text Button Variants") {
    VStack(spacing: .sp16) {
        TextButton("Add Task", variant: .branded) {}
        
        TextButton("Add Task", variant: .primary) {}
        
        TextButton("Add Task", variant: .secondary) {}
    }
    .padding(.sp24)
}

