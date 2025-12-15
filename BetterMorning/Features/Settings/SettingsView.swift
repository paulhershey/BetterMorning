//
//  SettingsView.swift
//  BetterMorning
//
//  Settings sheet with notification toggle and reset data option.
//  Presented as an anchored sheet from the bottom.
//

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    /// ViewModel managing settings state and logic
    @State private var viewModel = SettingsViewModel()
    
    /// Whether to show the reset confirmation alert
    @State private var showingResetConfirmation: Bool = false
    
    /// Binding for the notifications toggle that handles the logic via ViewModel
    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { viewModel.notificationsEnabled },
            set: { newValue in
                viewModel.handleNotificationToggle(newValue: newValue)
            }
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Spacer()
            
            // Settings Content
            VStack(spacing: .sp40) {
                // Notifications Toggle
                SettingsListItem(
                    title: "Turn on notifications",
                    isOn: notificationsBinding,
                    subtitle: viewModel.notificationSubtitle,
                    isDisabled: viewModel.systemNotificationsDenied,
                    onSubtitleTap: viewModel.systemNotificationsDenied ? {
                        viewModel.openAppSettings()
                    } : nil
                )
                .padding(.horizontal, .sp24)
                
                // Delete All Data Button
                BlockButton("Delete all data", variant: .danger) {
                    showingResetConfirmation = true
                }
                .padding(.horizontal, .sp24)
            }
            .padding(.bottom, .sp32)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .onAppear {
            // Refresh notification permission status when sheet appears
            viewModel.checkNotificationPermissions()
        }
        .alert("Reset All Data?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Everything", role: .destructive) {
                viewModel.performReset(modelContext: modelContext)
                dismiss()
            }
        } message: {
            Text("This will delete all your routines, progress data, and settings. This action cannot be undone.")
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        ZStack {
            // Title centered
            Text("Settings")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.colorNeutralBlack)
            
            // Close button on the right
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, .sp16)
        .padding(.top, .sp16)
        .padding(.bottom, .sp24)
    }
}

// MARK: - Preview

#Preview("Settings View") {
    SettingsView()
        .presentationDetents([.medium])
}

#Preview("Settings View - In Sheet") {
    Color.colorNeutralWhite
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            SettingsView()
                .presentationDetents([.height(298)])
                .presentationDragIndicator(.visible)
        }
}

