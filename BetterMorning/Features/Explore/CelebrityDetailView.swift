//
//  CelebrityDetailView.swift
//  BetterMorning
//
//  Profile screen for a celebrity routine.
//

import SwiftUI

struct CelebrityDetailView: View {
    let routine: CelebrityRoutine
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Content
            ScrollView {
                VStack(spacing: .sp24) {
                    // MARK: - Header Section
                    headerSection
                    
                    // MARK: - Task List Section
                    taskListSection
                }
                .padding(.horizontal, .sp24)
                .padding(.top, .sp48) // Extra top padding for close button
                .padding(.bottom, .sp96) // Extra padding for sticky button
            }
            .safeAreaInset(edge: .bottom) {
                stickyButtonSection
            }
            
            // Close Button (top right)
            Button {
                HapticManager.lightTap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: .iconXSmall, weight: .semibold))
                    .foregroundStyle(Color.colorNeutralGrey2)
                    .frame(width: .iconLarge, height: .iconLarge)
                    .background(Color.colorNeutralGrey1.opacity(CGFloat.opacityStrong))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
            .padding(.top, .sp16)
            .padding(.trailing, .sp24)
        }
        .background(Color.colorNeutralWhite)
        .navigationBarHidden(true)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: .sp16) {
            // Theme (above avatar)
            Text(routine.theme)
                .style(.overline)
                .foregroundStyle(Color.colorNeutralBlack)
            
            // Avatar using design system component
            Avatar(
                imageName: routine.imageName,
                size: .profileMedium
            )
            
            // Name
            Text(routine.name)
                .style(.heading1)
                .foregroundStyle(Color.colorNeutralBlack)
            
            // Title (below name)
            Text(routine.title)
                .style(.overline)
                .foregroundStyle(Color.colorNeutralBlack)
            
            // Bio
            Text(routine.bio)
                .style(.bodyRegular)
                .foregroundStyle(Color.colorNeutralGrey2)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Task List Section
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: .sp16) {
            // Section Title
            Text("Routine")
                .style(.heading4)
                .foregroundStyle(Color.colorNeutralBlack)
            
            // Task Rows using TaskItem component (completed state to show checkmarks)
            VStack(spacing: .sp8) {
                ForEach(routine.tasks) { task in
                    TaskItem(
                        time: task.time,
                        title: task.title,
                        variant: .constant(.rest),
                        action: { }
                    )
                    .allowsHitTesting(false) // Display only, not clickable
                }
            }
        }
    }
    
    // MARK: - Sticky Button Section
    private var stickyButtonSection: some View {
        VStack(spacing: 0) {
            // Gradient fade for smooth transition
            LinearGradient(
                colors: [
                    Color.colorNeutralWhite.opacity(0),
                    Color.colorNeutralWhite
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: .sp24)
            
            // Button container
            VStack {
                BlockButton("Choose this Routine") {
                    // Activate the routine (RoutineManager is pre-configured with context)
                    RoutineManager.shared.activate(celebrityRoutine: routine)
                    
                    // Dismiss the modal
                    dismiss()
                    
                    // After modal dismisses, switch to Routine tab to show "Starts Tomorrow" state
                    Task {
                        // Wait for dismiss animation to complete (~300ms)
                        try? await Task.sleep(for: .milliseconds(400))
                        await MainActor.run {
                            AppStateManager.shared.switchToTab(.routine)
                        }
                    }
                }
            }
            .padding(.horizontal, .sp24)
            .padding(.bottom, .sp24)
            .background(Color.colorNeutralWhite)
        }
    }
}

// MARK: - Preview
#Preview("Celebrity Detail View") {
    NavigationStack {
        CelebrityDetailView(
            routine: RoutineData.celebrityRoutines[1] // Oprah
        )
    }
}

