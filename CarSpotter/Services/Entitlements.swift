import Foundation
import SwiftUI

/// Single source of truth for "what can the user do right now?"
/// Reads the current subscription tier from StoreKitService and a
/// per-account free-scan counter from UserDefaults.
@MainActor
final class Entitlements: ObservableObject {
    static let shared = Entitlements()

    /// Free users get this many lifetime scans before the paywall hits.
    static let freeScanQuota = 3

    /// The free-scan counter is scoped to the signed-in account so it doesn't
    /// leak across accounts on the same device. Defaults to "anon" (guest).
    private var accountKey = "anon"
    private var scanKey: String { "carspotter.freeScansUsed.\(accountKey)" }

    /// Free scans used by the CURRENT account. Read-only to views; mutate via
    /// recordScan()/reset().
    @Published private(set) var freeScansUsed: Int = 0

    /// Switch the active account and load its own scan count.
    func setAccount(uid: String?) {
        accountKey = (uid?.isEmpty == false) ? uid! : "anon"
        freeScansUsed = UserDefaults.standard.integer(forKey: scanKey)
    }

    /// Whether the user is currently entitled to a paid feature.
    func canScan(tier: UserProfile.Plan) -> Bool {
        if tier != .free { return true }
        return freeScansUsed < Self.freeScanQuota
    }

    /// Concours-only: VIN decoder, auction alerts, valuation PDFs.
    func canAccessProTools(tier: UserProfile.Plan) -> Bool {
        tier == .concours
    }

    /// Collector+: Ask-the-AI, engine sounds, celebrity owners, spot map.
    func canAccessCollectorFeatures(tier: UserProfile.Plan) -> Bool {
        tier == .collector || tier == .concours
    }

    func recordScan() {
        freeScansUsed += 1
        UserDefaults.standard.set(freeScansUsed, forKey: scanKey)
    }

    func reset() {
        freeScansUsed = 0
        UserDefaults.standard.set(0, forKey: scanKey)
    }
}
