//
//  AppSheetModifiers.swift
//  BetterMorning
//
//  Shared view modifiers for presenting common sheets (Settings, CreateRoutine, Paywall).
//  Reduces code duplication across views that need these sheet presentations.
//

import SwiftUI

// MARK: - Settings Sheet Modifier

/// A view modifier that handles the Settings sheet presentation
struct SettingsSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                SettingsView()
                    .presentationDetents([.height(298)])
                    .presentationDragIndicator(.visible)
            }
    }
}

// MARK: - Create Routine Sheet Modifier

/// A view modifier that handles the Create Routine full-screen modal presentation
struct CreateRoutineSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                CreateRoutineView()
            }
    }
}

// MARK: - Paywall Sheet Modifier

/// A view modifier that handles the Paywall sheet presentation
struct PaywallSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let onPurchaseComplete: () -> Void
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                PaywallView(onPurchaseComplete: onPurchaseComplete)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Presents the Settings sheet when the binding is true
    func settingsSheet(isPresented: Binding<Bool>) -> some View {
        modifier(SettingsSheetModifier(isPresented: isPresented))
    }
    
    /// Presents the Create Routine full-screen modal when the binding is true
    func createRoutineSheet(isPresented: Binding<Bool>) -> some View {
        modifier(CreateRoutineSheetModifier(isPresented: isPresented))
    }
    
    /// Presents the Paywall sheet when the binding is true
    func paywallSheet(isPresented: Binding<Bool>, onPurchaseComplete: @escaping () -> Void = {}) -> some View {
        modifier(PaywallSheetModifier(isPresented: isPresented, onPurchaseComplete: onPurchaseComplete))
    }
}

