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
    @Binding var isTitleFocused: Bool
    let isSaveEnabled: Bool
    let onSave: () -> Void
    let onTitleSubmit: (() -> Void)?
    
    @FocusState private var internalFocus: Bool
    
    init(
        title: Binding<String>,
        isTitleFocused: Binding<Bool> = .constant(false),
        isSaveEnabled: Bool,
        onSave: @escaping () -> Void,
        onTitleSubmit: (() -> Void)? = nil
    ) {
        self._title = title
        self._isTitleFocused = isTitleFocused
        self.isSaveEnabled = isSaveEnabled
        self.onSave = onSave
        self.onTitleSubmit = onTitleSubmit
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
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .autocorrectionDisabled(false)
                    .focused($internalFocus)
                    .onChange(of: isTitleFocused) { _, newValue in
                        // Sync external focus state to internal
                        internalFocus = newValue
                    }
                    .onChange(of: internalFocus) { _, newValue in
                        // Sync internal focus state to external
                        isTitleFocused = newValue
                    }
                    .onChange(of: title) { oldValue, newValue in
                        // Intercept newline (Enter key) and treat as submit
                        if newValue.contains("\n") {
                            // Remove the newline
                            title = newValue.replacingOccurrences(of: "\n", with: "")
                            // Trigger submit if title is valid
                            if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onTitleSubmit?()
                            }
                            return
                        }
                        
                        // Enforce 20 character limit
                        if newValue.count > 20 {
                            title = String(newValue.prefix(20))
                        }
                    }
                    // Note: .onSubmit doesn't work with multi-line TextField (axis: .vertical)
                    // We handle Enter key via newline interception in .onChange above
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // UPDATE 3: Ensure title takes priority in width calculations
            .layoutPriority(1)
            
            Spacer(minLength: .sp16)
            
            // Right: Create button
            TextButton(
                "Create",
                variant: isSaveEnabled ? .branded : .disabled,
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
                onSave: {}
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
