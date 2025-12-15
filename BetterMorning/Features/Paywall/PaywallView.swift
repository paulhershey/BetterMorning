//
//  PaywallView.swift
//  BetterMorning
//
//  Paywall for unlocking custom routine creation.
//  Uses StoreKit 2 for in-app purchases.
//

import SwiftUI

struct PaywallView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    /// Callback when purchase is completed successfully
    let onPurchaseComplete: () -> Void
    
    /// Store manager for handling purchases
    private let storeManager = StoreManager.shared
    
    /// Whether a purchase/restore is in progress
    @State private var isLoading: Bool = false
    
    /// Whether we're showing the success state
    @State private var showingSuccess: Bool = false
    
    /// Error message to display (nil if no error)
    @State private var errorMessage: String?
    
    /// Whether to show the error alert
    @State private var showingError: Bool = false
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: .sp24) {
                // Header
                headerView
                
                Spacer()
                
                // Content
                VStack(spacing: .sp16) {
                    Text("Create Your Own Routine")
                        .style(.heading1)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .multilineTextAlignment(.center)
                    
                    Text(storeManager.productDescription)
                        .style(.bodyRegular)
                        .foregroundStyle(Color.colorNeutralGrey2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .sp24)
                    
                    // Price (from StoreKit)
                    Text(storeManager.formattedPrice)
                        .style(.display)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .padding(.top, .sp16)
                    
                    Text("One-time purchase")
                        .style(.bodyRegular)
                        .foregroundStyle(Color.colorNeutralGrey2)
                }
                
                Spacer()
                
                // Purchase Button with loading state
                purchaseButton
                    .padding(.horizontal, .sp24)
                
                // Restore Purchases Button
                Button {
                    restorePurchases()
                } label: {
                    Text("Restore Purchases")
                        .style(.bodyRegular)
                        .foregroundStyle(Color.colorNeutralGrey2)
                        .underline()
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
                .opacity(isLoading ? 0.5 : 1)
                .padding(.bottom, .sp32)
            }
            .background(Color.colorNeutralWhite)
            
            // Success overlay
            if showingSuccess {
                successOverlay
            }
        }
        .alert("Purchase Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "An unknown error occurred.")
        }
        .onAppear {
            // Fetch products if not already loaded
            Task {
                await storeManager.fetchProducts()
            }
        }
    }
    
    // MARK: - Purchase Button
    
    private var purchaseButton: some View {
        Button {
            purchasePremium()
        } label: {
            HStack(spacing: .sp12) {
                if isLoading {
                    ProgressView()
                        .tint(Color.colorNeutralBlack)
                        .scaleEffect(0.9)
                }
                
                Text(isLoading ? "Processing..." : "Unlock Custom Routines")
                    .style(.bodyStrong)
                    .foregroundStyle(Color.colorNeutralBlack)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.brandSecondary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
    
    // MARK: - Success Overlay
    
    private var successOverlay: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Success card
            VStack(spacing: .sp24) {
                // Checkmark circle
                ZStack {
                    Circle()
                        .fill(Color.brandSecondary)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color.colorNeutralBlack)
                }
                .scaleEffect(showingSuccess ? 1 : 0.5)
                .opacity(showingSuccess ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showingSuccess)
                
                Text("Purchase Complete!")
                    .style(.heading1)
                    .foregroundStyle(Color.colorNeutralBlack)
                
                Text("You can now create custom routines.")
                    .style(.bodyRegular)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
            .padding(.sp40)
            .background(Color.colorNeutralWhite)
            .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
            .padding(.horizontal, .sp40)
        }
        .transition(.opacity)
    }
    
    private var headerView: some View {
        ZStack {
            Text("Premium")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.colorNeutralBlack)
            
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
                .disabled(isLoading || showingSuccess)
            }
        }
        .padding(.horizontal, .sp16)
        .padding(.top, .sp16)
    }
    
    // MARK: - Actions
    
    private func purchasePremium() {
        isLoading = true
        
        Task {
            let success = await storeManager.purchasePremium()
            
            await MainActor.run {
                isLoading = false
                
                if success {
                    // Show success animation
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingSuccess = true
                    }
                    
                    // Dismiss after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                        onPurchaseComplete()
                    }
                } else {
                    // Check if it was a user cancellation (don't show error)
                    if case .failed(let error) = storeManager.purchaseState {
                        if let storeError = error as? StoreError, storeError == .userCancelled {
                            // User cancelled - just reset state, no error
                            storeManager.resetState()
                        } else {
                            // Show error
                            errorMessage = error.localizedDescription
                            showingError = true
                        }
                    }
                }
            }
        }
    }
    
    private func restorePurchases() {
        isLoading = true
        
        Task {
            let success = await storeManager.restorePurchases()
            
            await MainActor.run {
                isLoading = false
                
                if success {
                    // Show success animation for restore too
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingSuccess = true
                    }
                    
                    // Dismiss after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                        onPurchaseComplete()
                    }
                } else {
                    // No purchases to restore - show info message
                    errorMessage = "No previous purchases found to restore."
                    showingError = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Paywall") {
    PaywallView(onPurchaseComplete: {
        print("Purchase complete!")
    })
}

#Preview("Paywall - Success State") {
    PaywallSuccessPreview()
}

private struct PaywallSuccessPreview: View {
    @State private var showingSuccess = true
    
    var body: some View {
        ZStack {
            Color.colorNeutralWhite.ignoresSafeArea()
            
            // Success overlay preview
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: .sp24) {
                    ZStack {
                        Circle()
                            .fill(Color.brandSecondary)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color.colorNeutralBlack)
                    }
                    
                    Text("Purchase Complete!")
                        .style(.heading1)
                        .foregroundStyle(Color.colorNeutralBlack)
                    
                    Text("You can now create custom routines.")
                        .style(.bodyRegular)
                        .foregroundStyle(Color.colorNeutralGrey2)
                }
                .padding(.sp40)
                .background(Color.colorNeutralWhite)
                .clipShape(RoundedRectangle(cornerRadius: .radiusLarge))
                .padding(.horizontal, .sp40)
            }
        }
    }
}
