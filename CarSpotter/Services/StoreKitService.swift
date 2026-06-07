import Foundation
import StoreKit
import CryptoKit

@MainActor
final class StoreKitService: ObservableObject {
    /// IDs must match the products you create in App Store Connect.
    static let productIDs: [String] = [
        "app.carsspotter.spotter.monthly",
        "app.carsspotter.spotter.yearly",
        "app.carsspotter.collector.monthly",
        "app.carsspotter.collector.yearly",
        "app.carsspotter.concours.monthly",
        "app.carsspotter.concours.yearly",
    ]

    @Published var products: [Product] = []
    @Published var purchasedTier: UserProfile.Plan = .free
    @Published var lastError: String?

    /// The signed-in account's StoreKit `appAccountToken`. A subscription is
    /// only granted to the account that bought it — this token is what ties an
    /// Apple-ID-level purchase to a specific CarSpotter (Firebase) account, so
    /// the tier no longer leaks to every account on the same Apple ID.
    private(set) var accountToken: UUID?

    static var preview: StoreKitService {
        let s = StoreKitService()
        s.purchasedTier = .concours
        return s
    }

    /// Deterministic, stable `appAccountToken` derived from a Firebase uid.
    /// Same uid → same UUID across launches/reinstalls, so entitlement
    /// matching survives. Returns nil for signed-out / empty uid.
    static func token(for uid: String?) -> UUID? {
        guard let uid, !uid.isEmpty else { return nil }
        var bytes = Array(SHA256.hash(data: Data(uid.utf8)).prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x50   // version 5
        bytes[8] = (bytes[8] & 0x3F) | 0x80   // RFC-4122 variant
        return bytes.withUnsafeBufferPointer { NSUUID(uuidBytes: $0.baseAddress) as UUID }
    }

    /// Called when the signed-in account changes. Rebinds the token and
    /// re-evaluates the tier for the new account (resets to free on sign-out).
    func setAccount(uid: String?) async {
        accountToken = Self.token(for: uid)
        await updatePurchasedTier()
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            // Stamp the purchase with the current account's token so the
            // entitlement belongs to THIS account, not every account on the
            // Apple ID.
            var options: Set<Product.PurchaseOption> = []
            if let accountToken { options.insert(.appAccountToken(accountToken)) }
            let result = try await product.purchase(options: options)
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await updatePurchasedTier()
                    return true
                }
            case .userCancelled, .pending: return false
            @unknown default: return false
            }
        } catch {
            lastError = error.localizedDescription
        }
        return false
    }

    func restore() async {
        try? await AppStore.sync()
        await updatePurchasedTier()
    }

    /// Walks current entitlements and sets the highest active tier that
    /// belongs to the signed-in account. Entitlements whose `appAccountToken`
    /// doesn't match this account are ignored, so a subscription bought on one
    /// account no longer unlocks features on another account that happens to
    /// share the same Apple ID.
    func updatePurchasedTier() async {
        // No signed-in account (or signed out) → nothing is unlocked.
        guard let accountToken else { purchasedTier = .free; return }
        var best: UserProfile.Plan = .free
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                // Only count purchases stamped for THIS account.
                guard transaction.appAccountToken == accountToken else { continue }
                let id = transaction.productID
                if id.contains(".concours") { best = .concours }
                else if id.contains(".collector"), best != .concours { best = .collector }
                else if id.contains(".spotter"), best == .free { best = .spotter }
            }
        }
        purchasedTier = best
    }

    /// Convenience filter helpers for paywall UI.
    func products(for tier: UserProfile.Plan) -> (monthly: Product?, yearly: Product?) {
        let monthly = products.first { $0.id == "app.carsspotter.\(tier.rawValue).monthly" }
        let yearly  = products.first { $0.id == "app.carsspotter.\(tier.rawValue).yearly"  }
        return (monthly, yearly)
    }
}
