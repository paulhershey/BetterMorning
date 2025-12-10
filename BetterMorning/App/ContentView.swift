//
//  ContentView.swift
//  BetterMorning
//
//  Created by Paul Hershey on 12/5/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                // MARK: - Header
                Text("Design System V2")
                    .style(.pageTitle) // New Syntax
                    .foregroundStyle(Color.brandPrimary)
                    .padding(.top)
                
                // MARK: - 1. Colors
                VStack(alignment: .leading, spacing: 12) {
                    Text("1. Colors")
                        .style(.heading1)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ColorSwatch(name: "Primary", color: .brandPrimary)
                        ColorSwatch(name: "Secondary", color: .brandSecondary)
                        ColorSwatch(name: "Tertiary", color: .brandTertiary)
                        ColorSwatch(name: "Success", color: .utilitySuccess)
                        ColorSwatch(name: "Danger", color: .utilityDanger)
                        ColorSwatch(name: "Black", color: .colorNeutralBlack)
                        ColorSwatch(name: "Grey 1", color: .colorNeutralGrey1)
                        ColorSwatch(name: "Grey 2", color: .colorNeutralGrey2)
                        ColorSwatch(name: "White", color: .colorNeutralWhite, hasBorder: true)
                    }
                }
                
                Divider()
                
                // MARK: - 2. Typography
                VStack(alignment: .leading, spacing: 16) {
                    Text("2. Typography")
                        .style(.heading1)
                        .foregroundStyle(Color.brandPrimary)
                    
                    Group {
                        // Note the tighter line height and spacing on these
                        Text("Display (64/60)").style(.display)
                        Text("Page Title (40/Auto)").style(.pageTitle)
                        Text("Heading 1 (32/Auto)").style(.heading1)
                        Text("Heading 4 (16/20)").style(.heading4)
                        
                        Text("Body Large (20/28)").style(.bodyLarge)
                        Text("Body Strong (16/20)").style(.bodyStrong)
                        Text("Body Regular (16/20)").style(.bodyRegular)
                        
                        Text("Button Text (16)").style(.buttonText)
                        Text("Overline (12)").style(.overline)
                        Text("Data Small (10)").style(.dataSmall)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Divider()
                
                // MARK: - 3. Icons
                VStack(alignment: .leading, spacing: 16) {
                    Text("3. Icons")
                        .style(.heading1)
                        .foregroundStyle(Color.brandPrimary)
                    
                    Text("Black Variants")
                        .style(.overline)
                        .foregroundStyle(Color.colorNeutralGrey2)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 20) {
                        IconPreview(name: "icon_add_black")
                        IconPreview(name: "icon_check_black")
                        IconPreview(name: "icon_settings_black")
                        IconPreview(name: "icon_routine_black")
                    }
                }
            }
            .padding(24)
        }
    }
}

// Helper View for Color Swatches (No changes)
struct ColorSwatch: View {
    let name: String
    let color: Color
    var hasBorder: Bool = false
    
    var body: some View {
        VStack {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.colorNeutralGrey1, lineWidth: hasBorder ? 1 : 0)
                )
                .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
            
            Text(name)
                .style(.dataSmall)
                .foregroundStyle(Color.colorNeutralBlack)
        }
    }
}

// Helper View for Icons (No changes)
struct IconPreview: View {
    let name: String
    
    var body: some View {
        VStack {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            
            Text(name.replacingOccurrences(of: "icon_", with: ""))
                .font(.system(size: 8))
                .lineLimit(1)
        }
    }
}

#Preview {
    ContentView()
}
