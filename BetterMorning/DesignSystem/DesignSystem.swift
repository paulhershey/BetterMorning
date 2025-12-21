//
//  DesignSystem.swift
//  BetterMorning
//
//  Created by Paul Hershey on 12/6/25.
//

import SwiftUI

// MARK: - 1. Color System
extension Color {
    static let colorNeutralWhite = Color(hex: "#FFFFFF")
    static let colorNeutralGrey1 = Color(hex: "#E3E3E3")
    static let colorNeutralGrey2 = Color(hex: "#858585")
    static let colorNeutralGrey3 = Color(hex: "#F5F5F5") // Light background
    static let colorNeutralBlack = Color(hex: "#000000")
    
    static let brandPrimary = Color(hex: "#592FEB")
    static let brandSecondary = Color(hex: "#C7B9F8")
    static let brandTertiary = Color(hex: "#ECE8FD")
    
    static let utilityDanger = Color(hex: "#EB4E2B")
    static let utilitySuccess = Color(hex: "#89DCB8")
    
    // Semantic colors for backgrounds
    static let backgroundPrimary = colorNeutralWhite
    static let backgroundSecondary = colorNeutralGrey3
    static let backgroundTertiary = colorNeutralGrey1
}

// MARK: - 2. Typography System V2
struct TextStyle {
    let name: String
    let fontName: String
    let size: CGFloat
    let weight: Font.Weight
    let tracking: CGFloat // Letter spacing
    let lineHeight: CGFloat // Target line height
    
    var font: Font {
        return Font.custom(fontName, size: size).weight(weight)
    }
    
    var extraLineSpacing: CGFloat {
        return lineHeight - size
    }
}

extension TextStyle {
    // Bricolage Grotesque
    static let pageTitle = TextStyle(name: "Page Title", fontName: "Bricolage Grotesque", size: 40, weight: .bold, tracking: -1, lineHeight: 40)
    static let heading1 = TextStyle(name: "Heading 1", fontName: "Bricolage Grotesque", size: 32, weight: .bold, tracking: -1, lineHeight: 32)
    static let display = TextStyle(name: "Display", fontName: "Bricolage Grotesque", size: 64, weight: .bold, tracking: -1, lineHeight: 0)
    
    // Inter
    static let heading4 = TextStyle(name: "Heading 4", fontName: "Inter", size: 16, weight: .bold, tracking: 0, lineHeight: 20)
    static let bodyLarge = TextStyle(name: "Body Large", fontName: "Inter", size: 20, weight: .semibold, tracking: 0, lineHeight: 16)
    static let bodyStrong = TextStyle(name: "Body Strong", fontName: "Inter", size: 16, weight: .bold, tracking: 0, lineHeight: 20)
    static let bodyRegular = TextStyle(name: "Body", fontName: "Inter", size: 16, weight: .regular, tracking: 0, lineHeight: 20)
    
    // Utility
    static let buttonText = TextStyle(name: "Button Text", fontName: "Inter", size: 16, weight: .semibold, tracking: 0, lineHeight: 16)
    static let overline = TextStyle(name: "Overline", fontName: "Inter", size: 12, weight: .bold, tracking: 0, lineHeight: 12)
    static let dataSmall = TextStyle(name: "Data", fontName: "Inter", size: 10, weight: .bold, tracking: 0, lineHeight: 10)
}

extension Text {
    func style(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .kerning(style.tracking)
            .lineSpacing(style.extraLineSpacing)
    }
}

// MARK: - 3. Spacing System
// Usage: .padding(CGFloat.sp16)
extension CGFloat {
    static let sp0: CGFloat = 0
    static let sp1: CGFloat = 1
    static let sp2: CGFloat = 2
    static let sp4: CGFloat = 4
    static let sp8: CGFloat = 8
    static let sp12: CGFloat = 12
    static let sp16: CGFloat = 16
    static let sp24: CGFloat = 24
    static let sp32: CGFloat = 32
    static let sp40: CGFloat = 40
    static let sp48: CGFloat = 48
    static let sp56: CGFloat = 56
    static let sp64: CGFloat = 64
    static let sp72: CGFloat = 72
    static let sp80: CGFloat = 80
    static let sp88: CGFloat = 88
    static let sp96: CGFloat = 96
    static let sp104: CGFloat = 104
    static let sp128: CGFloat = 128
}

// MARK: - 4. Radii & Effects
extension CGFloat {
    // Standardizing your requested values
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusXlarge: CGFloat = 32
    static let radiusFull: CGFloat = 999
    
    // Border widths
    static let borderWidthThin: CGFloat = 1
    static let borderWidthMedium: CGFloat = 2
    
    // Opacity values
    static let opacitySubtle: CGFloat = 0.1
    static let opacityLight: CGFloat = 0.3
    static let opacityMedium: CGFloat = 0.4
    static let opacityStrong: CGFloat = 0.5
    static let opacityHeavy: CGFloat = 0.8
}

// MARK: - 5. Icon Sizes
extension CGFloat {
    static let iconXSmall: CGFloat = 16
    static let iconSmall: CGFloat = 20
    static let iconMedium: CGFloat = 24
    static let iconLarge: CGFloat = 30
    static let iconXLarge: CGFloat = 40
}

// MARK: - 6. Layout Constants
extension CGFloat {
    /// Height for background hero images in empty states
    static let heroImageHeight: CGFloat = 594
    
    /// Bottom padding/spacer height to account for floating tab bar
    static let tabBarSpacerHeight: CGFloat = 120
    
    /// Lottie animation dimensions for empty routine state
    static let emptyRoutineAnimationWidth: CGFloat = 382
    static let emptyRoutineAnimationHeight: CGFloat = 344
    
    /// Lottie animation height for custom routine empty state
    static let customEmptyAnimationHeight: CGFloat = 150
    
    /// Lottie animation height for onboarding screens
    static let onboardingAnimationHeight: CGFloat = 426
    
    /// Height for Make-A-Wish logo on paywall
    static let makeAWishLogoHeight: CGFloat = 49
    
    /// Bottom padding for onboarding screens
    static let onboardingBottomPadding: CGFloat = 150
    
    /// Standard divider height
    static let dividerHeight: CGFloat = 1
    
    /// Y-axis label width in data charts
    static let yAxisLabelWidth: CGFloat = 16
    
    /// Success circle size for paywall overlay
    static let successCircleSize: CGFloat = 80
    
    /// Swipe gesture threshold for onboarding
    static let swipeThreshold: CGFloat = 50
    
    /// Scale effect for loading indicators
    static let scaleSmall: CGFloat = 0.9
    
    /// Keyboard scroll spacer height
    static let keyboardScrollSpacerHeight: CGFloat = 300
    
    /// Skeleton placeholder dimensions
    static let skeletonTimeWidth: CGFloat = 60
    static let skeletonTimeHeight: CGFloat = 12
    static let skeletonTitleHeight: CGFloat = 18
    static let skeletonAvatarSize: CGFloat = 32
    static let skeletonTextWidth: CGFloat = 80
    static let skeletonTextHeight: CGFloat = 14
    static let skeletonNameWidth: CGFloat = 120
    static let skeletonNameHeight: CGFloat = 16
    static let skeletonChartHeight: CGFloat = 200
    static let skeletonRoutineNameWidth: CGFloat = 180
    static let skeletonRoutineNameHeight: CGFloat = 20
    
    /// DateCard width for date scroller (shows ~5 cards with 6th peeking)
    static let dateCardWidth: CGFloat = 56
}

// MARK: - 8. Animation System
struct AppAnimations {
    static let fast = Animation.easeOut(duration: 0.2)
    static let standard = Animation.easeInOut(duration: 0.3)
    static let slow = Animation.easeInOut(duration: 0.4)
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let shimmer = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
}

struct AppShadows {
    // Your specific drop shadow from variables.json
    static let `default` = ShadowStyle(color: Color.colorNeutralBlack.opacity(CGFloat.opacitySubtle), radius: 8, x: 0, y: 4)
    
    /// Modal overlay backdrop color
    static let modalBackdrop = Color.colorNeutralBlack.opacity(CGFloat.opacityMedium)
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func applyShadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

// MARK: - 7. Hex Code Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
