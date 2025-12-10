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
    static let colorNeutralBlack = Color(hex: "#000000")
    
    static let brandPrimary = Color(hex: "#665AC0")
    static let brandSecondary = Color(hex: "#D8D9FE")
    static let brandTertiary = Color(hex: "#E8E9FF")
    
    static let utilityDanger = Color(hex: "#FB748A")
    static let utilitySuccess = Color(hex: "#74FBA6")
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
        return max(lineHeight - size, 0)
    }
}

extension TextStyle {
    // Bricolage Grotesque
    static let pageTitle = TextStyle(name: "Page Title", fontName: "Bricolage Grotesque", size: 40, weight: .bold, tracking: -1, lineHeight: 40)
    static let heading1 = TextStyle(name: "Heading 1", fontName: "Bricolage Grotesque", size: 32, weight: .bold, tracking: -1, lineHeight: 32)
    static let display = TextStyle(name: "Display", fontName: "Bricolage Grotesque", size: 64, weight: .bold, tracking: -1, lineHeight: 60)
    
    // Inter
    static let heading4 = TextStyle(name: "Heading 4", fontName: "Inter", size: 16, weight: .bold, tracking: 0, lineHeight: 20)
    static let bodyLarge = TextStyle(name: "Body Large", fontName: "Inter", size: 20, weight: .semibold, tracking: 0, lineHeight: 28)
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
}

struct AppShadows {
    // Your specific drop shadow from variables.json
    static let `default` = ShadowStyle(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
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

// MARK: - 5. Hex Code Support
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
