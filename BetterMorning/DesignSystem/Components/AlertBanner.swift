//
//  AlertBanner.swift
//  BetterMorning
//
//  A dismissible alert banner with an action button.
//

import SwiftUI

// MARK: - Alert Banner View
struct AlertBanner: View {
    let message: String
    let actionTitle: String
    let action: () -> Void
    
    init(
        message: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) {
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        HStack {
            Text(message)
                .style(.heading4)
                .foregroundStyle(Color.colorNeutralBlack)
            
            Spacer()
            
            Button(action: action) {
                Text(actionTitle)
                    .style(.buttonText)
                    .foregroundStyle(Color.colorNeutralBlack)
            }
            .buttonStyle(.plain)
        }
        .padding(.sp24)
        .background(Color.utilityDanger)
        .clipShape(RoundedRectangle(cornerRadius: .sp16))
    }
}

// MARK: - Preview
#Preview("Alert Banner") {
    VStack(spacing: .sp24) {
        AlertBanner(
            message: "Routine Successfully Deleted",
            actionTitle: "Undo"
        ) {}
    }
    .padding(.sp24)
}

