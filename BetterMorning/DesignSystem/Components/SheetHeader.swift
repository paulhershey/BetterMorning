//
//  SheetHeader.swift
//  BetterMorning
//
//  A reusable header component for modal sheets with centered title and close button.
//

import SwiftUI

// MARK: - Sheet Header View

struct SheetHeader: View {
    let title: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Title centered
            Text(title)
                .style(.bodyStrong)
                .foregroundStyle(Color.colorNeutralBlack)
            
            // Close button on the right
            HStack {
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: .iconLarge))
                        .foregroundStyle(Color.colorNeutralGrey2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
        }
        .padding(.horizontal, .sp16)
        .padding(.top, .sp16)
        .padding(.bottom, .sp24)
    }
}

// MARK: - Preview

#Preview("Sheet Header") {
    VStack {
        SheetHeader(title: "Settings", onDismiss: {})
        
        Spacer()
    }
    .background(Color.backgroundSecondary)
}

#Preview("Sheet Header - In Sheet") {
    Color.colorNeutralWhite
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            VStack {
                SheetHeader(title: "Settings", onDismiss: {})
                Spacer()
            }
            .background(Color.backgroundSecondary)
            .presentationDetents([.height(298)])
            .presentationDragIndicator(.visible)
        }
}

