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
    private var currentUid: String?
    private var updatesTask: Task<Void, Never>?

    init() {
        // Listen for transactions that complete outside the direct purchase
        // flow — renewals, Ask-to-Buy approvals, purchases finished on another
        // device, or interrupted purchases. Without this, subscriptions can be
        // missed (StoreKit warns about exactly this).
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
    }

    deinit { updatesTask?.cancel() }

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
        currentUid = (uid?.isEmpty == false) ? uid : nil
        accountToken = Self.token(for: uid)
        await refreshEntitlements()
    }

    /// Full entitlement refresh: StoreKit purchases AND the server plan
    /// (web/Stripe subscriptions written to Firestore). Takes the higher tier.
    func refreshEntitlements() async {
        await updatePurchasedTier()   // Apple / StoreKit
        await mergeServerPlan()       // web / Stripe via Firestore
    }

    /// Reads /users/{uid}.plan (set by a Stripe purchase on the website) and
    /// upgrades the tier if the server plan is higher than what StoreKit shows.
    private func mergeServerPlan() async {
        guard let uid = currentUid else { return }
        do {
            if let data = try await FirestoreREST.getDoc(path: "users/\(uid)"),
               let planStr = data["plan"] as? String,
               let serverPlan = UserProfile.Plan(rawValue: planStr),
               serverPlan.rank > purchasedTier.rank {
                purchasedTier = serverPlan
            }
        } catch {
            // Network/permission error — keep the StoreKit tier, don't downgrade.
        }
    }

    /// Mirror an Apple purchase to Firestore so the website (and other devices)
    /// recognize it too.
    private func syncTierToServer() async {
        guard let uid = currentUid, purchasedTier != .free else { return }
        try? await FirestoreREST.setDoc(path: "users/\(uid)", data: ["plan": purchasedTier.rawValue])
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
                    await syncTierToServer()
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
        await refreshEntitlements()
    }

    /// Walks current StoreKit entitlements and sets the highest active tier for
    /// this account. A transaction counts if it's stamped for THIS account
    /// (appAccountToken match) OR is untagged (nil) — StoreKit/sandbox doesn't
    /// always populate appAccountToken, so the nil fallback prevents a real
    /// purchase from going unrecognized. Tagged purchases keep tiers from
    /// leaking to other accounts on the same Apple ID.
    func updatePurchasedTier() async {
        var best: UserProfile.Plan = .free
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                let tok = transaction.appAccountToken
                guard tok == accountToken || tok == nil else { continue }
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
