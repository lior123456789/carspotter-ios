import Foundation
import StoreKit

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

    static var preview: StoreKitService {
        let s = StoreKitService()
        s.purchasedTier = .concours
        return s
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
            let result = try await product.purchase()
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

    /// Walks current entitlements and sets the highest active tier.
    func updatePurchasedTier() async {
        var best: UserProfile.Plan = .free
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
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
