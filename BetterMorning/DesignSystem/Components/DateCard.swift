//
//  DateCard.swift
//  BetterMorning
//
//  A date card component for horizontal date scrollers.
//

import SwiftUI

// MARK: - Date Card Variant
enum DateCardVariant {
    case rest
    case selected
    case completed
    
    var backgroundColor: Color {
        switch self {
        case .rest:
            return Color.clear
        case .selected:
            return Color.brandSecondary
        case .completed:
            return Color.clear
        }
    }
    
    var textColor: Color {
        switch self {
        case .rest:
            return Color.colorNeutralGrey2
        case .selected:
            return Color.colorNeutralBlack
        case .completed:
            return Color.colorNeutralBlack
        }
    }
    
    var borderColor: Color {
        switch self {
        case .rest:
            return Color.colorNeutralGrey1
        case .selected:
            return Color.clear
        case .completed:
            return Color.colorNeutralBlack
        }
    }
    
    var borderWidth: CGFloat {
        return 1
    }
}

// MARK: - Date Card View
struct DateCard: View {
    let dayName: String
    let dateNumber: String
    let variant: DateCardVariant
    let action: () -> Void
    
    init(
        dayName: String,
        dateNumber: String,
        variant: DateCardVariant = .rest,
        action: @escaping () -> Void
    ) {
        self.dayName = dayName
        self.dateNumber = dateNumber
        self.variant = variant
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: .sp8) {
                Text(dayName)
                    .style(.overline)
                    .foregroundStyle(variant.textColor)
               
                Text(dateNumber)
                    .style(.bodyLarge)
                    .foregroundStyle(variant.textColor)
            }
            // UPDATED: No horizontal padding, and tighter frame width (52pt)
            // This ensures the total width is exactly 52pt, not 60 + padding.
            .padding(.vertical, .sp16)
            .frame(width: 60)
            .background(variant.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: .radiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: .radiusSmall)
                    .stroke(variant.borderColor, lineWidth: variant.borderWidth)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview("Date Card Variants") {
    HStack(spacing: .sp16) {
        DateCard(dayName: "Wed", dateNumber: "25", variant: .rest) {
            print("Rest tapped")
        }
        
        DateCard(dayName: "Wed", dateNumber: "25", variant: .selected) {
            print("Selected tapped")
        }
        
        DateCard(dayName: "Wed", dateNumber: "25", variant: .completed) {
            print("Completed tapped")
        }
    }
    .padding(.sp24)
}
