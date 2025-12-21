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
    @Environment(\.scenePhase) private var scenePhase
    
    /// ViewModel managing settings state and logic
    @State private var viewModel = SettingsViewModel()
    
    /// Whether to show the reset confirmation alert
    @State private var showingResetConfirmation: Bool = false
    
    /// Whether to show the error alert
    @State private var showingErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
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
        .background(Color.backgroundSecondary)
        .onAppear {
            // Refresh notification permission status when sheet appears
            viewModel.checkNotificationPermissions()
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Re-check permissions when returning from Settings app
            // This handles the case where user enables notifications in System Settings
            if newPhase == .active {
                viewModel.checkNotificationPermissions()
            }
        }
        .alert("Reset All Data?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Everything", role: .destructive) {
                let success = viewModel.performReset(modelContext: modelContext)
                if success {
                    dismiss()
                } else {
                    errorMessage = AppStateManager.shared.lastError?.localizedDescription ?? "Failed to reset data"
                    showingErrorAlert = true
                }
            }
        } message: {
            Text("This will delete all your routines, progress data, and settings. This action cannot be undone.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        SheetHeader(title: "Settings", onDismiss: { dismiss() })
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

