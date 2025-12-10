//
//  OnboardingContent.swift
//  BetterMorning
//
//  A text content block for onboarding screens.
//

import SwiftUI

// MARK: - Onboarding Content View
struct OnboardingContent: View {
    let title: String
    // FIXED: Renamed 'body' to 'bodyText' so it doesn't crash SwiftUI
    let bodyText: String
    
    init(
        title: String,
        bodyText: String
    ) {
        self.title = title
        self.bodyText = bodyText
    }
    
    // This is the required SwiftUI body
    var body: some View {
        VStack(alignment: .leading, spacing: .sp16) {
            Text(title)
                .style(.display)
                .foregroundStyle(Color.colorNeutralBlack)
            
            // Usage updated here
            Text(bodyText)
                .style(.bodyLarge)
                .foregroundStyle(Color.colorNeutralBlack)
        }
    }
}

// MARK: - Preview
#Preview("Onboarding Content") {
    OnboardingContent(
        title: "Start with inspiration",
        bodyText: "Pick a proven morning routine from someone successful to jump-start your day."
    )
    .padding(.sp24)
}
