//
//  TaskItem.swift
//  BetterMorning
//
//  A task item card component with multiple states.
//

import SwiftUI

// MARK: - Task Item Variant
enum TaskItemVariant {
    case active
    case completed
    case failed
    case rest
    
    // Logic: Only Rest and Completed are interactive toggle states.
    // Active and Failed are display-only states.
    var isInteractive: Bool {
        switch self {
        case .rest, .completed:
            return true
        case .active, .failed:
            return false
        }
    }
    
    var borderColor: Color {
        switch self {
        case .active:
            return Color.brandSecondary // Purple highlight
        case .completed, .failed, .rest:
            return Color.colorNeutralGrey1 // Subtle grey border
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .active:
            return 2 // Thicker for active state
        case .completed, .failed, .rest:
            return 1 // Standard hairline border
        }
    }
    
    var iconName: String? {
        switch self {
        case .completed:
            return "icon_check_black"
        case .failed:
            return "icon_close_red"
        case .active, .rest:
            return nil
        }
    }
}

// MARK: - Task Item View
struct TaskItem: View {
    let time: String
    let title: String
    @Binding var variant: TaskItemVariant
    let action: () -> Void
    
    init(
        time: String,
        title: String,
        variant: Binding<TaskItemVariant>,
        action: @escaping () -> Void
    ) {
        self.time = time
        self.title = title
        self._variant = variant
        self.action = action
    }
    
    var body: some View {
        // Condition: If interactive, wrap in Button. If not, just show content.
        if variant.isInteractive {
            Button {
                toggleState()
            } label: {
                cardContent
            }
            .buttonStyle(.plain)
        } else {
            // Display Only (No Button wrapper)
            cardContent
        }
    }
    
    // MARK: - Visual Content
    private var cardContent: some View {
        HStack(spacing: .sp16) {
            // Left side: Time and Title stacked vertically
            VStack(alignment: .leading, spacing: .sp4) {
                Text(time.uppercased())
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
                
                Text(title)
                    .style(.bodyRegular)
                    .foregroundStyle(Color.colorNeutralBlack)
            }
            
            Spacer()
            
            // Right side: Icon (if needed)
            if let iconName = variant.iconName {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    // Animation for icon appearing/disappearing
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.sp16)
        .background(Color.colorNeutralWhite)
        .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: .radiusLarge)
                .stroke(variant.borderColor, lineWidth: variant.borderWidth)
        )
    }
    
    // MARK: - Toggle Logic
    private func toggleState() {
        // 1. Trigger Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // 2. Perform Toggle (Strictly Rest <-> Completed)
        withAnimation(.snappy) {
            switch variant {
            case .rest:
                variant = .completed
            case .completed:
                variant = .rest
            default:
                break // Active and Failed do not toggle
            }
        }
        
        // 3. Call external action
        action()
    }
}

// MARK: - Preview
#Preview("Task Item Interactive") {
    TaskItemPreviewWrapper()
}

// Wrapper to hold state for the preview
private struct TaskItemPreviewWrapper: View {
    @State private var activeState: TaskItemVariant = .active
    @State private var restState: TaskItemVariant = .rest
    @State private var completedState: TaskItemVariant = .completed
    @State private var failedState: TaskItemVariant = .failed
    
    var body: some View {
        ZStack {
            Color.colorNeutralGrey1.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: .sp16) {
                Text("Interactive (Tap to toggle)")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
                
                TaskItem(
                    time: "6:30AM",
                    title: "Rest Task",
                    variant: $restState
                ) {
                    print("Toggled Rest")
                }
                
                TaskItem(
                    time: "7:00AM",
                    title: "Completed Task",
                    variant: $completedState
                ) {
                    print("Toggled Completed")
                }
                
                Divider()
                
                Text("Display Only (Cannot tap)")
                    .style(.dataSmall)
                    .foregroundStyle(Color.colorNeutralGrey2)
                
                TaskItem(
                    time: "6:00AM",
                    title: "Active Task",
                    variant: $activeState
                ) {
                    print("Should not print")
                }
                
                TaskItem(
                    time: "8:00AM",
                    title: "Failed Task",
                    variant: $failedState
                ) {
                    print("Should not print")
                }
            }
            .padding(.sp24)
        }
    }
}
