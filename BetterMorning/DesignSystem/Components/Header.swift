//
//  Header.swift
//  BetterMorning
//
//  A page header with title and action buttons.
//

import SwiftUI

// MARK: - Header View
struct Header: View {
    let title: String
    let settingsAction: () -> Void
    let createAction: () -> Void
    
    init(
        title: String,
        settingsAction: @escaping () -> Void,
        createAction: @escaping () -> Void
    ) {
        self.title = title
        self.settingsAction = settingsAction
        self.createAction = createAction
    }
    
    var body: some View {
        HStack(alignment: .center) {
            // Left: Title
            // We allow the title to shrink slightly if the screen is very narrow,
            // rather than crushing the buttons.
            Text(title)
                .style(.pageTitle)
                .foregroundStyle(Color.colorNeutralBlack)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            // Right: Action buttons
            HStack(spacing: .sp8) {
                IconButton("icon_settings_white", action: settingsAction)
                
                TextButton("Create", variant: .branded, action: createAction)
                    // FIX 1: Prevent the button text from ever wrapping
                    .fixedSize(horizontal: true, vertical: false)
            }
            // FIX 2: Give the buttons higher priority.
            // SwiftUI will calculate their size FIRST, then give the leftover space to the Title.
            .layoutPriority(1)
        }
        .padding(.horizontal, .sp24)
    }
}

// MARK: - Preview
#Preview("Header") {
    ZStack {
        Color.colorNeutralGrey1
            .ignoresSafeArea()
        
        VStack {
            Header(
                title: "Explore",
                settingsAction: {
                    print("Settings tapped")
                },
                createAction: {
                    print("Create tapped")
                }
            )
            .padding(.top, .sp32)
            
            Spacer()
        }
    }
}
