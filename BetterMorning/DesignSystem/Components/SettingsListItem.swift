//
//  SettingsListItem.swift
//  BetterMorning
//
//  A settings row with a label and toggle switch.
//

import SwiftUI

// MARK: - Settings List Item View
struct SettingsListItem: View {
    let title: String
    @Binding var isOn: Bool
    
    init(
        title: String,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self._isOn = isOn
    }
    
    var body: some View {
        HStack {
            Text(title)
                .style(.heading4)
                .foregroundStyle(Color.colorNeutralBlack)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.brandSecondary)
        }
    }
}

// MARK: - Preview
#Preview("Settings List Item") {
    SettingsListItemPreview()
}

// Preview wrapper to enable interactive toggle
private struct SettingsListItemPreview: View {
    @State private var notificationsOn = true
    @State private var darkModeOn = false
    
    var body: some View {
        ZStack {
            Color.colorNeutralGrey1
                .ignoresSafeArea()
            
            VStack(spacing: .sp16) {
                SettingsListItem(
                    title: "Turn on notifications",
                    isOn: $notificationsOn
                )
            }
            .padding(.sp24)
        }
    }
}

