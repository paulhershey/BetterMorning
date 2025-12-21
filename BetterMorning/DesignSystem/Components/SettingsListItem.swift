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
    var subtitle: String? = nil
    var isDisabled: Bool = false
    var onSubtitleTap: (() -> Void)? = nil
    
    init(
        title: String,
        isOn: Binding<Bool>,
        subtitle: String? = nil,
        isDisabled: Bool = false,
        onSubtitleTap: (() -> Void)? = nil
    ) {
        self.title = title
        self._isOn = isOn
        self.subtitle = subtitle
        self.isDisabled = isDisabled
        self.onSubtitleTap = onSubtitleTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .sp8) {
            HStack {
                Text(title)
                    .style(.heading4)
                    .foregroundStyle(isDisabled ? Color.colorNeutralGrey2 : Color.colorNeutralBlack)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { isOn },
                    set: { newValue in
                        HapticManager.lightTap()
                        isOn = newValue
                    }
                ))
                    .labelsHidden()
                    .tint(Color.brandSecondary)
                    .disabled(isDisabled)
                    .accessibilityLabel(title)
                    .accessibilityValue(isOn ? "On" : "Off")
                    .accessibilityHint(isDisabled ? "This setting is currently disabled" : "Double tap to toggle")
            }
            
            // Optional subtitle (e.g., "Open Settings to enable")
            if let subtitle = subtitle {
                if let onSubtitleTap = onSubtitleTap {
                    Button(action: onSubtitleTap) {
                        Text(subtitle)
                            .style(.overline)
                            .foregroundStyle(Color.brandPrimary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(subtitle)
                        .style(.overline)
                        .foregroundStyle(Color.colorNeutralGrey2)
                }
            }
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

