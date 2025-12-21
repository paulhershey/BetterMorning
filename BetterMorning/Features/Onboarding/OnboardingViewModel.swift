//
//  OnboardingViewModel.swift
//  BetterMorning
//
//  ViewModel managing the onboarding carousel state and content.
//

import SwiftUI

// MARK: - Onboarding Step Data

/// Represents a single step in the onboarding carousel
struct OnboardingStep: Identifiable {
    let id: Int
    let title: String
    let bodyText: String
    let backgroundImageName: String
    let contentImageName: String?
    let lottieAnimationName: String?
    let buttonTitle: String
    
    /// Whether this is the final step
    var isFinalStep: Bool {
        id == 5
    }
    
    /// Whether this step uses a Lottie animation (above content, no gradient)
    var hasLottieAnimation: Bool {
        lottieAnimationName != nil
    }
}

// MARK: - Onboarding ViewModel

@MainActor
@Observable
final class OnboardingViewModel {
    
    // MARK: - State
    
    /// Current step index (1-5)
    private(set) var currentStepIndex: Int = 1
    
    /// Total number of steps
    let totalSteps: Int = 5
    
    // MARK: - Step Content (from Figma)
    
    /// All onboarding steps with content from Figma designs
    let steps: [OnboardingStep] = [
        OnboardingStep(
            id: 1,
            title: "Start with inspiration",
            bodyText: "Start your day with a proven morning routine inspired by people who are already successful.",
            backgroundImageName: "onboarding_bg_1",
            contentImageName: nil, // Using Lottie animation instead
            lottieAnimationName: "Onboarding-1",
            buttonTitle: "Continue (1/5)"
        ),
        OnboardingStep(
            id: 2,
            title: "Build your own path",
            bodyText: "Create a routine tailored to you and stay accountable as your habits evolve over time.",
            backgroundImageName: "onboarding_bg_2",
            contentImageName: nil,
            lottieAnimationName: "Onboarding-2",
            buttonTitle: "Continue (2/5)"
        ),
        OnboardingStep(
            id: 3,
            title: "Stay on track",
            bodyText: "Receive gentle reminders each morning that help you follow through without pressure.",
            backgroundImageName: "onboarding_bg_3",
            contentImageName: nil,
            lottieAnimationName: "Onboarding-3",
            buttonTitle: "Continue (3/5)"
        ),
        OnboardingStep(
            id: 4,
            title: "See your progress",
            bodyText: "Track habits, measure progress, and celebrate consistency as small wins add up daily.",
            backgroundImageName: "onboarding_bg_4",
            contentImageName: nil,
            lottieAnimationName: "Onboarding-4",
            buttonTitle: "Continue (4/5)"
        ),
        OnboardingStep(
            id: 5,
            title: "Transform your life",
            bodyText: "Build confidence as better mornings create momentum for better days and a better you.",
            backgroundImageName: "onboarding_bg_5",
            contentImageName: nil,
            lottieAnimationName: "Onboarding-5",
            buttonTitle: "Let's get started!"
        )
    ]
    
    // MARK: - Computed Properties
    
    /// The current step data
    var currentStep: OnboardingStep {
        steps[currentStepIndex - 1]
    }
    
    /// Whether we're on the final step
    var isOnFinalStep: Bool {
        currentStepIndex == totalSteps
    }
    
    /// Whether we can go to the next step
    var canAdvance: Bool {
        currentStepIndex < totalSteps
    }
    
    /// Whether we can go to the previous step
    var canGoBack: Bool {
        currentStepIndex > 1
    }
    
    /// Track swipe direction for proper transition animation
    private(set) var swipeDirection: SwipeDirection = .forward
    
    enum SwipeDirection {
        case forward, backward
    }
    
    // MARK: - Actions
    
    /// Advance to the next step, or complete onboarding if on final step
    func continueAction() {
        if isOnFinalStep {
            completeOnboarding()
        } else if currentStepIndex == 3 {
            // Step 3: Request notification permissions, then advance
            requestNotificationPermissions()
        } else {
            advanceToNextStep()
        }
    }
    
    /// Move to the next step (internal)
    private func advanceToNextStep() {
        guard canAdvance else { return }
        swipeDirection = .forward
        withAnimation(AppAnimations.standard) {
            currentStepIndex += 1
        }
    }
    
    /// Go back to the previous step
    func goBack() {
        guard canGoBack else { return }
        swipeDirection = .backward
        withAnimation(AppAnimations.standard) {
            currentStepIndex -= 1
        }
    }
    
    /// Complete onboarding and transition to main app
    private func completeOnboarding() {
        AppStateManager.shared.completeOnboarding()
    }
    
    /// Request notification permissions (Step 3)
    /// Uses NotificationManager for centralized permission handling
    private func requestNotificationPermissions() {
        NotificationManager.shared.requestPermission { _ in
            // Advance to step 4 regardless of permission result
            self.advanceToNextStep()
        }
    }
    
    // MARK: - Preview Helpers
    
    /// Jump to a specific step (for previews/testing only)
    func jumpToStep(_ step: Int) {
        guard step >= 1 && step <= totalSteps else { return }
        currentStepIndex = step
    }
}

