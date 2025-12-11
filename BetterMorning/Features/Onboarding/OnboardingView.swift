//
//  OnboardingView.swift
//  BetterMorning
//
//  Multi-step onboarding carousel introducing the app to new users.
//

import SwiftUI

struct OnboardingView: View {
    
    var body: some View {
        VStack(spacing: .sp24) {
            Spacer()
            
            // Placeholder content
            VStack(spacing: .sp16) {
                Image(systemName: "sunrise.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.brandPrimary)
                
                Text("Welcome to Better Morning")
                    .style(.heading1)
                    .foregroundStyle(Color.colorNeutralBlack)
                    .multilineTextAlignment(.center)
                
                Text("Start your day with clarity and consistency by following one structured morning routine at a time.")
                    .style(.bodyRegular)
                    .foregroundStyle(Color.colorNeutralGrey2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .sp24)
            }
            
            Spacer()
            
            // Get Started button
            BlockButton("Get Started") {
                AppStateManager.shared.completeOnboarding()
            }
            .padding(.horizontal, .sp24)
            .padding(.bottom, .sp40)
        }
        .background(Color.colorNeutralWhite)
    }
}

// MARK: - Preview
#Preview("Onboarding View") {
    OnboardingView()
}
