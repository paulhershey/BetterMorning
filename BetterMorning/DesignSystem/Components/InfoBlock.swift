//
//  InfoBlock.swift
//  BetterMorning
//
//  An information card with title, body, and optional nested component.
//

import SwiftUI

// MARK: - Info Block Variant
enum InfoBlockVariant {
    case basic
    case settings(itemTitle: String, isOn: Binding<Bool>)
    case action(
        secondaryTitle: String,
        secondaryAction: () -> Void,
        primaryTitle: String,
        primaryAction: () -> Void
    )
}

// MARK: - Info Block View
struct InfoBlock: View {
    let title: String
    let bodyText: String
    let variant: InfoBlockVariant
    
    init(
        title: String,
        bodyText: String,
        variant: InfoBlockVariant = .basic
    ) {
        self.title = title
        self.bodyText = bodyText
        self.variant = variant
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: .sp16) {
            // Title
            Text(title)
                .style(.heading1)
                .foregroundStyle(Color.colorNeutralBlack)
                .multilineTextAlignment(.center)
            
            // Body
            Text(bodyText)
                .style(.bodyRegular)
                .foregroundStyle(Color.colorNeutralBlack)
                .multilineTextAlignment(.center)
            
            // Nested component based on variant
            switch variant {
            case .basic:
                EmptyView()
                
            case .settings(let itemTitle, let isOn):
                SettingsListItem(
                    title: itemTitle,
                    isOn: isOn
                )
                
            case .action(let secondaryTitle, let secondaryAction, let primaryTitle, let primaryAction):
                HStack(spacing: .sp40) {
                    TextButton(secondaryTitle, variant: .primary, iconName: "icon_arrow_left_white", action: secondaryAction)
                    TextButton(primaryTitle, variant: .branded, action: primaryAction)
                }
            }
        }
        .padding(.sp24)
        .background(Color.colorNeutralWhite)
        .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
    }
}

// MARK: - Preview
#Preview("Info Block Variants") {
    InfoBlockPreview()
}

// Preview wrapper with @State for interactive toggle
private struct InfoBlockPreview: View {
    @State private var notificationsOn = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: .sp24) {
                // Basic variant
                InfoBlock(
                    title: "Welcome to the app",
                    bodyText: "This is a basic info block with just a title and body text. No additional components.",
                    variant: .basic
                )
                
                // Settings variant
                InfoBlock(
                    title: "Stay informed",
                    bodyText: "Enable notifications to receive reminders about your morning routine.",
                    variant: .settings(
                        itemTitle: "Turn on notifications",
                        isOn: $notificationsOn
                    )
                )
                
                // Action variant
                InfoBlock(
                    title: "Start your mornings with intention",
                    bodyText: "Explore routines from world-class performers or create your own rhythm—and begin building the habits that move you toward your best self.",
                    variant: .action(
                        secondaryTitle: "Explore",
                        secondaryAction: {},
                        primaryTitle: "Create",
                        primaryAction: {}
                    )
                )
            }
        }
    }
}

