//
//  StoreManager.swift
//  BetterMorning
//
//  StoreKit 2 integration for in-app purchases.
//  Handles product fetching, purchasing, restoring, and entitlement verification.
//

import Foundation
import StoreKit

// MARK: - Product Identifiers

/// Product identifiers for StoreKit
enum StoreProductID {
    /// Non-consumable product for unlocking custom routine creation
    static let premium = "com.paulhershey.bettermorning.premium"
}

// MARK: - Purchase State

enum PurchaseState {
    case idle
    case loading
    case purchasing
    case purchased
    case failed(Error)
    case restored
}

// MARK: - Store Error

enum StoreError: LocalizedError, Equatable {
    case productNotFound
    case purchaseFailed
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found. Please try again later."
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        case .userCancelled:
            return "Purchase was cancelled."
        case .pending:
            return "Purchase is pending approval."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// MARK: - Store Manager

@MainActor
@Observable
final class StoreManager {
    
    // MARK: - Singleton
    
    static let shared = StoreManager()
    
    // MARK: - Properties
    
    /// The premium product (fetched from StoreKit)
    private(set) var premiumProduct: Product?
    
    /// Current purchase state
    private(set) var purchaseState: PurchaseState = .idle
    
    /// Whether the user has purchased premium
    var hasPurchasedPremium: Bool {
        AppStateManager.shared.hasPurchasedPremium
    }
    
    /// Formatted price string for the premium product
    var formattedPrice: String {
        premiumProduct?.displayPrice ?? "$0.99"
    }
    
    /// Product display name
    var productDisplayName: String {
        premiumProduct?.displayName ?? "Unlock Custom Routines"
    }
    
    /// Product description
    var productDescription: String {
        premiumProduct?.description ?? "Create your own personalized morning routines."
    }
    
    /// Task for listening to transaction updates
    /// Note: Cannot cancel from deinit because @Observable classes don't support nonisolated properties.
    /// This is acceptable since StoreManager is a singleton that persists for the app's lifetime.
    private var transactionListener: Task<Void, Error>?
    
    // MARK: - Initialization
    
    private init() {
        // Start listening for transaction updates
        transactionListener = listenForTransactions()
        
        // Fetch products on init
        Task {
            await fetchProducts()
        }
    }
    
    // Note: deinit removed - StoreManager is a singleton that persists for app lifetime,
    // so cancellation in deinit is not necessary. If needed in the future, we can add
    // an explicit cleanup method.
    
    // MARK: - Product Fetching
    
    /// Fetches available products from the App Store
    @MainActor
    func fetchProducts() async {
        do {
            let products = try await Product.products(for: [StoreProductID.premium])
            
            if let premium = products.first {
                self.premiumProduct = premium
            }
        } catch {
            // Product fetch failed - will retry when needed
        }
    }
    
    // MARK: - Purchase
    
    /// Initiates a purchase for the premium product
    /// - Returns: True if purchase was successful
    @MainActor
    func purchasePremium() async -> Bool {
        guard let product = premiumProduct else {
            purchaseState = .failed(StoreError.productNotFound)
            return false
        }
        
        purchaseState = .purchasing
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)
                
                // Grant entitlement
                await grantPremiumAccess()
                
                // Finish the transaction
                await transaction.finish()
                
                purchaseState = .purchased
                return true
                
            case .userCancelled:
                purchaseState = .failed(StoreError.userCancelled)
                return false
                
            case .pending:
                purchaseState = .failed(StoreError.pending)
                return false
                
            @unknown default:
                purchaseState = .failed(StoreError.unknown)
                return false
            }
        } catch {
            purchaseState = .failed(error)
            return false
        }
    }
    
    // MARK: - Restore Purchases
    
    /// Restores previous purchases
    /// - Returns: True if a purchase was restored
    @MainActor
    func restorePurchases() async -> Bool {
        purchaseState = .loading
        
        do {
            // Sync with App Store to get latest transactions
            try await AppStore.sync()
            
            // Check current entitlements
            let hasEntitlement = await checkCurrentEntitlements()
            
            if hasEntitlement {
                purchaseState = .restored
                return true
            } else {
                purchaseState = .idle
                return false
            }
        } catch {
            purchaseState = .failed(error)
            return false
        }
    }
    
    // MARK: - Entitlement Verification
    
    /// Checks current entitlements on app launch
    /// This also handles refund detection - if user had premium but no entitlement exists,
    /// their access is revoked.
    @MainActor
    func checkCurrentEntitlements() async -> Bool {
        // Iterate through all current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if this is our premium product
                if transaction.productID == StoreProductID.premium {
                    // Verify it hasn't been revoked (refunded)
                    if transaction.revocationDate == nil {
                        await grantPremiumAccess()
                        return true
                    } else {
                        // Transaction was revoked (refund)
                        await revokePremiumAccess()
                        return false
                    }
                }
            } catch {
                // Transaction verification failed
            }
        }
        
        // No valid entitlement found
        // If user previously had premium (stored in UserDefaults), revoke it
        // This handles refunds that occurred while the app wasn't running
        if AppStateManager.shared.hasPurchasedPremium {
            await revokePremiumAccess()
        }
        
        return false
    }
    
    // MARK: - Transaction Listener
    
    /// Listens for transaction updates (purchases, restores, refunds)
    private func listenForTransactions() -> Task<Void, Error> {
        // Capture product ID before entering detached task (Swift 6 actor isolation)
        let premiumProductID = StoreProductID.premium
        
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Handle the transaction
                    if transaction.productID == premiumProductID {
                        if transaction.revocationDate == nil {
                            // Valid purchase
                            await self.grantPremiumAccess()
                        } else {
                            // Revoked (refund)
                            await self.revokePremiumAccess()
                        }
                    }
                    
                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    // Transaction verification failed
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    
    /// Verifies a transaction result
    /// - Note: nonisolated to allow calling from detached Task
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    /// Grants premium access to the user
    @MainActor
    private func grantPremiumAccess() async {
        AppStateManager.shared.unlockPremium()
    }
    
    /// Revokes premium access (for refunds/revocations)
    @MainActor
    private func revokePremiumAccess() async {
        AppStateManager.shared.hasPurchasedPremium = false
    }
    
    // MARK: - Reset State
    
    /// Resets the purchase state to idle
    @MainActor
    func resetState() {
        purchaseState = .idle
    }
}

