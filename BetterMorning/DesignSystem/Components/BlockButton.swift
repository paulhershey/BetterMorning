//
//  BlockButton.swift
//  BetterMorning
//
//  A full-width pill-shaped action button.
//

import SwiftUI

// MARK: - Block Button Variant
enum BlockButtonVariant {
    case `default`
    case danger
    
    var backgroundColor: Color {
        switch self {
        case .default:
            return Color.colorNeutralBlack
        case .danger:
            return Color.utilityDanger
        }
    }
    
    var textColor: Color {
        // Both variants use white text
        return Color.colorNeutralWhite
    }
}

// MARK: - Block Button View
struct BlockButton: View {
    let text: String
    let variant: BlockButtonVariant
    let action: () -> Void
    
    init(
        _ text: String,
        variant: BlockButtonVariant = .default,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.variant = variant
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .style(.buttonText)
                .foregroundStyle(variant.textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, .sp16)
                .background(variant.backgroundColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview("Block Button Variants") {
    VStack(spacing: .sp24) {
        BlockButton("Continue", variant: .default) {
            print("Default tapped")
        }
        
        BlockButton("Delete Routine", variant: .danger) {
            print("Danger tapped")
        }
    }
    .padding(.sp24)
}

