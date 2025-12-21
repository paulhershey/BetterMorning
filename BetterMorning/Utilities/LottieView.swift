//
//  LottieView.swift
//  BetterMorning
//
//  SwiftUI wrapper for Lottie animations with accessibility support.
//

import SwiftUI
import Lottie

/// A SwiftUI view that displays a Lottie animation
struct LottieView: UIViewRepresentable {
    
    /// The name of the Lottie JSON file (without extension)
    let animationName: String
    
    /// Whether the animation should loop infinitely
    var loopMode: LottieLoopMode = .loop
    
    /// Animation speed (1.0 = normal)
    var animationSpeed: CGFloat = 1.0
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        
        // Respect Reduce Motion accessibility setting
        if !UIAccessibility.isReduceMotionEnabled {
            animationView.play()
        } else {
            // Show the first frame as a static image
            animationView.currentProgress = 0
        }
        
        // Set compression resistance to maintain size
        animationView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        animationView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        // Handle Reduce Motion changes
        if !UIAccessibility.isReduceMotionEnabled {
            if !uiView.isAnimationPlaying {
                uiView.play()
            }
        } else {
            uiView.stop()
            uiView.currentProgress = 0
        }
    }
}

// MARK: - Preview

#Preview("Lottie Animation") {
    LottieView(animationName: "Empty-Routine")
        .frame(width: .emptyRoutineAnimationWidth, height: .emptyRoutineAnimationHeight)
}

