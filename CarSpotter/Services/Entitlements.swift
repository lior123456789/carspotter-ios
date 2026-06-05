import Foundation
import SwiftUI

/// Single source of truth for "what can the user do right now?"
/// Reads the current subscription tier from StoreKitService and a
/// local free-scan counter from UserDefaults.
@MainActor
final class Entitlements: ObservableObject {
    static let shared = Entitlements()

    /// Free users get this many lifetime scans before the paywall hits.
    static let freeScanQuota = 3

    @AppStorage("carspotter.freeScansUsed") var freeScansUsed: Int = 0

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
    }

    func reset() {
        freeScansUsed = 0
    }
}
