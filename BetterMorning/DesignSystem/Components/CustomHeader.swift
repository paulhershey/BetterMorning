//
//  CustomHeader.swift
//  BetterMorning
//
//  A header with an editable title field and save button.
//

import SwiftUI

// MARK: - Custom Header View
struct CustomHeader: View {
    @Binding var title: String
    let isSaveEnabled: Bool
    let onSave: () -> Void
    
    init(
        title: Binding<String>,
        isSaveEnabled: Bool,
        onSave: @escaping () -> Void
    ) {
        self._title = title
        self.isSaveEnabled = isSaveEnabled
        self.onSave = onSave
    }
    
    var body: some View {
        // UPDATE 1: Align centers so the text floats perfectly in the middle of the button height
        HStack(alignment: .center) {
            // Left: Title input with placeholder
            ZStack(alignment: .topLeading) {
                // Placeholder
                if title.isEmpty {
                    Text("Add a title")
                        .style(.heading1)
                        .foregroundStyle(Color.colorNeutralGrey1)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
                
                // Text field
                TextField("", text: $title, axis: .vertical)
                    .font(TextStyle.heading1.font)
                    .foregroundStyle(Color.colorNeutralBlack)
                    // UPDATE 2: Strict 2-line limit
                    .lineLimit(2)
                    // Note: TextField truncation (...) only appears when not focused in some iOS versions,
                    // but lineLimit ensures it never grows beyond 2 lines height.
                    .textInputAutocapitalization(.sentences)
                    .onChange(of: title) { oldValue, newValue in
                        if newValue.count > 20 {
                            title = String(newValue.prefix(20))
                        }
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // UPDATE 3: Ensure title takes priority in width calculations
            .layoutPriority(1)
            
            Spacer(minLength: .sp16)
            
            // Right: Save button
            TextButton(
                "Save",
                variant: isSaveEnabled ? .branded : .secondary,
                action: {
                    if isSaveEnabled {
                        onSave()
                    }
                }
            )
            .allowsHitTesting(isSaveEnabled)
            // Fix button size so it doesn't get crushed
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, .sp24)
    }
}

// MARK: - Preview
#Preview("Custom Header") {
    CustomHeaderPreview()
}

// Preview wrapper with @State for interactive testing
private struct CustomHeaderPreview: View {
    @State private var title = ""
    @State private var isSaveEnabled = false
    
    var body: some View {
        VStack(spacing: .sp32) {
            CustomHeader(
                title: $title,
                isSaveEnabled: isSaveEnabled,
                onSave: {
                    print("Save tapped with title: \(title)")
                }
            )
            
            Divider()
                .padding(.horizontal, .sp24)
            
            // Controls for testing
            VStack(alignment: .leading, spacing: .sp16) {
                Text("Preview Controls")
                    .style(.heading4)
                    .foregroundStyle(Color.colorNeutralBlack)
                
                Toggle("Save Enabled", isOn: $isSaveEnabled)
                    .tint(Color.brandSecondary)
                
                Text("Title: \"\(title)\"")
                    .style(.bodyRegular)
                    .foregroundStyle(Color.colorNeutralGrey2)
                
                Text("Characters: \(title.count)/20")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
            .padding(.horizontal, .sp24)
            
            Spacer()
        }
        .padding(.top, .sp24)
    }
}
