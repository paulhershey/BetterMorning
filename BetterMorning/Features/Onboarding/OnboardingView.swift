//
//  OnboardingView.swift
//  BetterMorning
//
//  Multi-step onboarding carousel introducing the app to new users.
//

import SwiftUI

struct OnboardingView: View {
    
    @State private var viewModel = OnboardingViewModel()
    
    // Swipe gesture threshold
    private let swipeThreshold: CGFloat = 50
    
    var body: some View {
        GeometryReader { geometry in
            // MARK: - Content Layer
            VStack(spacing: 0) {
                // Top spacer
                Spacer()
                    .frame(height: geometry.size.height * 0.24)
                
                // MARK: - Text Stage (ZStack)
                // FIX: Changing this to ZStack prevents the "narrowing" glitch.
                // It allows the outgoing/incoming text to overlap during the slide
                // instead of fighting for horizontal space.
                ZStack(alignment: .topLeading) {
                    OnboardingContent(
                        title: viewModel.currentStep.title,
                        bodyText: viewModel.currentStep.bodyText
                    )
                    // The ID and Transition belong to the content inside the stage
                    .id(viewModel.currentStepIndex)
                    .transition(transitionForDirection)
                }
                // Force ZStack to always take full width (screen width minus 48pt padding)
                .frame(width: geometry.size.width - (.sp24 * 2), alignment: .leading)
                .padding(.horizontal, .sp24) // Apply padding to the STAGE
                
                // Spacing
                Spacer()
                    .frame(height: .sp24)
                
                // MARK: - Image Stage (ZStack)
                ZStack(alignment: .top) {
                    if let contentImageName = viewModel.currentStep.contentImageName {
                        Image(contentImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 210)
                            .id("image-\(viewModel.currentStepIndex)")
                            .transition(transitionForDirection)
                    } else {
                        // Keeps the ZStack "alive" and sized correctly even when empty
                        Color.clear
                            .frame(height: 0)
                    }
                }
                .frame(maxWidth: .infinity) // Ensure stage is full width
                .padding(.horizontal, .sp24)
                
                // Flexible spacer
                Spacer()
                
                // Bottom Button
                BlockButton(viewModel.currentStep.buttonTitle) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewModel.continueAction()
                    }
                }
                .padding(.horizontal, .sp24)
                .padding(.bottom, .sp24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle()) // Make entire area tappable for gesture
            .gesture(swipeGesture)
        }
        // MARK: - Background Layer
        .background(
            ZStack {
                Color.colorNeutralWhite
                
                Image(viewModel.currentStep.backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
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
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewModel.continueAction()
                    }
                } else if horizontalDistance > swipeThreshold {
                    // Swipe right → go back
                    withAnimation(.easeInOut(duration: 0.4)) {
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
