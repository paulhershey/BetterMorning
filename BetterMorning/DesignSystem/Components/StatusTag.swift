//
//  StatusTag.swift
//  BetterMorning
//
//  A flexible pill-shaped status indicator.
//

import SwiftUI

struct StatusTag: View {
    let text: String
    let color: Color
    
    // Default to 'Success' green if no color is specified
    init(_ text: String, color: Color = .utilitySuccess) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .style(.dataSmall) // Using your bold style
            .foregroundStyle(Color.colorNeutralBlack)
            .padding(.horizontal, .sp16)
            .padding(.vertical, .sp8)
            .background(color)
            .clipShape(Capsule()) // Perfect pill shape
    }
}

// MARK: - Preview
#Preview("Status Tag") {
    VStack(spacing: .sp24) {
        
        // The one from your design
        StatusTag("Active", color: .utilitySuccess)
    }
    .padding(.sp40)
}
