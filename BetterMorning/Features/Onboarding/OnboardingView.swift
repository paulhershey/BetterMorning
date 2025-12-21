//
//  OnboardingView.swift
//  BetterMorning
//
//  Multi-step onboarding carousel introducing the app to new users.
//

import Lottie
import SwiftUI

struct OnboardingView: View {
    
    @State private var viewModel = OnboardingViewModel()
    
    // Swipe gesture threshold
    private let swipeThreshold: CGFloat = CGFloat.swipeThreshold
    
    var body: some View {
        GeometryReader { geometry in
            // MARK: - Content Layer
            VStack(spacing: 0) {
                // Check if current step has a Lottie animation
                if let lottieAnimationName = viewModel.currentStep.lottieAnimationName {
                    // MARK: - Lottie Animation Layout (content anchored to bottom)
                    
                    // Flexible spacer pushes everything to the bottom
                    Spacer()
                    
                    // Lottie Animation
                    LottieView(animationName: lottieAnimationName, loopMode: .loop)
                        .frame(width: .emptyRoutineAnimationWidth, height: .onboardingAnimationHeight)
                        .id("lottie-\(viewModel.currentStepIndex)")
                        .transition(transitionForDirection)
                    
                    // Spacing between animation and content
                    Spacer()
                        .frame(height: .sp24)
                    
                    // Text Content (anchored above button)
                    ZStack(alignment: .topLeading) {
                        OnboardingContent(
                            title: viewModel.currentStep.title,
                            bodyText: viewModel.currentStep.bodyText
                        )
                        .id(viewModel.currentStepIndex)
                        .transition(transitionForDirection)
                    }
                    .frame(width: geometry.size.width - (.sp24 * 2), alignment: .leading)
                    .padding(.horizontal, .sp24)
                    
                    // Spacing between content and button
                    Spacer()
                        .frame(height: .sp48)
                    
                } else {
                    // MARK: - Standard Layout (gradient background, content image below)
                    
                    // Top spacer
                    Spacer()
                        .frame(height: geometry.size.height * 0.24)
                    
                    // Text Stage (ZStack)
                    ZStack(alignment: .topLeading) {
                        OnboardingContent(
                            title: viewModel.currentStep.title,
                            bodyText: viewModel.currentStep.bodyText
                        )
                        .id(viewModel.currentStepIndex)
                        .transition(transitionForDirection)
                    }
                    .frame(width: geometry.size.width - (.sp24 * 2), alignment: .leading)
                    .padding(.horizontal, .sp24)
                    
                    // Spacing
                    Spacer()
                        .frame(height: .sp24)
                    
                    // Image Stage (ZStack)
                    ZStack(alignment: .top) {
                        if let contentImageName = viewModel.currentStep.contentImageName {
                            Image(contentImageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 210)
                                .id("image-\(viewModel.currentStepIndex)")
                                .transition(transitionForDirection)
                        } else {
                            Color.clear
                                .frame(height: .sp0)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, .sp24)
                    
                    // Flexible spacer
                    Spacer()
                }
                
                // Bottom Button (always visible)
                BlockButton(viewModel.currentStep.buttonTitle) {
                    withAnimation(AppAnimations.slow) {
                        viewModel.continueAction()
                    }
                }
                .padding(.horizontal, .sp24)
                .padding(.bottom, .onboardingBottomPadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(swipeGesture)
        }
        // MARK: - Background Layer
        .background(
            ZStack {
                Color.colorNeutralWhite
                
                // Only show gradient background for steps without Lottie animation
                if !viewModel.currentStep.hasLottieAnimation {
                    Image(viewModel.currentStep.backgroundImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                }
            }
            .ignoresSafeArea()
        )
    }
    
    // MARK: - Swipe Gesture
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: swipeThreshold)
            .onEnded { value in
                let horizontalDistance = value.translation.width
                
                if horizontalDistance < -swipeThreshold {
                    // Swipe left → go forward
                    withAnimation(AppAnimations.slow) {
                        viewModel.continueAction()
                    }
                } else if horizontalDistance > swipeThreshold {
                    // Swipe right → go back
                    withAnimation(AppAnimations.slow) {
                        viewModel.goBack()
                    }
                }
            }
    }
    
    // MARK: - Transition Helper
    
    private var transitionForDirection: AnyTransition {
        switch viewModel.swipeDirection {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .backward:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }
}

// MARK: - Previews

#Preview("Onboarding - Full Flow") {
    OnboardingView()
}

// Helper for previewing specific steps
private struct OnboardingStepPreview: View {
    let step: Int
    @State private var viewModel = OnboardingViewModel()
    
    var body: some View {
        OnboardingView()
            .onAppear {
                viewModel.jumpToStep(step)
            }
    }
}
