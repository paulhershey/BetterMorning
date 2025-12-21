//
//  TaskButton.swift
//  BetterMorning
//
//  A pill-shaped button with branded styling for task-related actions.
//

import SwiftUI

// MARK: - Task Button View
struct TaskButton: View {
    let text: String
    let action: () -> Void
    
    init(
        _ text: String,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Button {
            HapticManager.mediumTap()
            action()
        } label: {
            Text(text)
                .style(.buttonText)
                .foregroundStyle(Color.brandPrimary)
                .padding(.sp16)
                .background(Color.brandTertiary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
    }
}

// MARK: - Preview
#Preview("Task Button") {
    VStack(spacing: .sp24) {
        TaskButton("Save") {}
        
        TaskButton("Add Task") {}
        
        TaskButton("Done") {}
    }
    .padding(.sp24)
}

