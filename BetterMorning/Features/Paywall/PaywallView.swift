//
//  PaywallView.swift
//  BetterMorning
//
//  Paywall for unlocking custom routine creation.
//  This is a placeholder - replace with StoreKit integration later.
//

import SwiftUI

struct PaywallView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    /// Callback when purchase is completed successfully
    let onPurchaseComplete: () -> Void
    
    var body: some View {
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
                
                Text("Unlock the ability to create custom morning routines tailored to your lifestyle.")
                    .style(.bodyRegular)
                    .foregroundStyle(Color.colorNeutralGrey2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .sp24)
                
                // Price
                Text("$0.99")
                    .style(.display)
                    .foregroundStyle(Color.colorNeutralBlack)
                    .padding(.top, .sp16)
                
                Text("One-time purchase")
                    .style(.bodyRegular)
                    .foregroundStyle(Color.colorNeutralGrey2)
            }
            
            Spacer()
            
            // Purchase Button
            BlockButton("Unlock Custom Routines") {
                purchasePremium()
            }
            .padding(.horizontal, .sp24)
            
            // Restore Purchases Button (per Functional Spec Section 12)
            Button {
                restorePurchases()
            } label: {
                Text("Restore Purchases")
                    .style(.bodyRegular)
                    .foregroundStyle(Color.colorNeutralGrey2)
                    .underline()
            }
            .buttonStyle(.plain)
            .padding(.bottom, .sp32)
        }
        .background(Color.colorNeutralWhite)
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
            }
        }
        .padding(.horizontal, .sp16)
        .padding(.top, .sp16)
    }
    
    private func purchasePremium() {
        // TODO: Implement StoreKit 2 purchase flow
        // For now, just unlock and proceed
        AppStateManager.shared.unlockPremium()
        dismiss()
        onPurchaseComplete()
    }
    
    private func restorePurchases() {
        // TODO: Implement StoreKit 2 restore flow
        // For now, check if already purchased and proceed
        if AppStateManager.shared.hasPurchasedPremium {
            dismiss()
            onPurchaseComplete()
        } else {
            // In production, this would call StoreKit to restore
            print("No purchases to restore")
        }
    }
}

// MARK: - Preview

#Preview("Paywall") {
    PaywallView(onPurchaseComplete: {
        print("Purchase complete!")
    })
}

