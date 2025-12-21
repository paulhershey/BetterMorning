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
            // Background
            Color.colorNeutralWhite
                .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Lottie Animation
                LottieView(animationName: "Paywall")
                    .frame(
                        width: .emptyRoutineAnimationWidth,
                        height: .emptyRoutineAnimationHeight
                    )
                    .padding(.top, .sp24)
                
                // Make-A-Wish logo
                Image("Make-A-Wish")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: .makeAWishLogoHeight)
                    .padding(.top, .sp16)
                
                // Info content
                VStack(spacing: .sp16) {
                    Text("Unlock your perfect morning for a one time charge of $0.99")
                        .style(.heading1)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .multilineTextAlignment(.center)
                    
                    Text("Create custom routines built around your goals, your timing, and your life. One small upgrade for you, one giant impact for others: 100% of all proceeds go directly to Make-A-Wish.")
                        .style(.bodyRegular)
                        .foregroundStyle(Color.colorNeutralBlack)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, .sp24)
                .padding(.top, .sp16)
                
                Spacer()
                
                // Purchase button
                purchaseButton
                    .padding(.horizontal, .sp24)
                    .padding(.bottom, .sp16)
                
                // Restore Purchases
                Button {
                    HapticManager.lightTap()
                    restorePurchases()
                } label: {
                    Text("Restore Purchase")
                        .style(.bodyRegular)
                        .foregroundStyle(Color.colorNeutralBlack)
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
                .opacity(isLoading ? CGFloat.opacityStrong : 1)
                .padding(.bottom, .sp32)
            }
            
            // Success overlay
            if showingSuccess {
                successOverlay
            }
        }
        .navigationBarHidden(true)
        .alert(errorMessage == "No previous purchases found to restore." ? "No Purchases Found" : "Purchase Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "Something went wrong. Please try again.")
        }
    }
    
    // MARK: - Purchase Button
    
    private var purchaseButton: some View {
        Group {
            if isLoading {
                // Loading state
                HStack(spacing: .sp12) {
                    ProgressView()
                        .tint(Color.colorNeutralWhite)
                        .scaleEffect(.scaleSmall)
                    
                    Text("Processing...")
                        .style(.buttonText)
                        .foregroundStyle(Color.colorNeutralWhite)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, .sp24)
                .background(Color.colorNeutralBlack)
                .clipShape(Capsule())
            } else {
                BlockButton("Purchase") {
                    purchasePremium()
                }
            }
        }
    }
    
    // MARK: - Success Overlay
    
    private var successOverlay: some View {
        ZStack {
            // Dimmed background
            AppShadows.modalBackdrop
                .ignoresSafeArea()
            
            // Success card
            VStack(spacing: .sp24) {
                // Checkmark circle
                ZStack {
                    Circle()
                        .fill(Color.brandSecondary)
                        .frame(width: .successCircleSize, height: .successCircleSize)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: .iconXLarge, weight: .bold))
                        .foregroundStyle(Color.colorNeutralBlack)
                }
                .scaleEffect(showingSuccess ? 1 : 0.5)
                .opacity(showingSuccess ? 1 : 0)
                .animation(AppAnimations.spring, value: showingSuccess)
                
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
    
    // MARK: - Actions
    
    private func purchasePremium() {
        isLoading = true
        
        Task {
            let success = await storeManager.purchasePremium()
            
            await MainActor.run {
                isLoading = false
                
                if success {
                    // Haptic feedback for success
                    HapticManager.success()
                    
                    // Show success animation
                    withAnimation(AppAnimations.standard) {
                        showingSuccess = true
                    }
                    
                    // Dismiss after delay
                    Task {
                        try? await Task.sleep(for: .milliseconds(1500))
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
                    // Haptic feedback for success
                    HapticManager.success()
                    
                    // Show success animation for restore too
                    withAnimation(AppAnimations.standard) {
                        showingSuccess = true
                    }
                    
                    // Dismiss after delay
                    Task {
                        try? await Task.sleep(for: .milliseconds(1500))
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
    PaywallView(onPurchaseComplete: {})
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
                AppShadows.modalBackdrop
                    .ignoresSafeArea()
                
                VStack(spacing: .sp24) {
                    ZStack {
                        Circle()
                            .fill(Color.brandSecondary)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: .iconXLarge, weight: .bold))
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
