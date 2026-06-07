import Foundation

struct UserProfile: Codable, Equatable {
    enum Plan: String, Codable, CaseIterable, Identifiable {
        case free, spotter, collector, concours
        var id: String { rawValue }

        /// Higher = more access. Used to pick the best of StoreKit vs. server plan.
        var rank: Int {
            switch self {
            case .free: return 0
            case .spotter: return 1
            case .collector: return 2
            case .concours: return 3
            }
        }

        var displayName: String {
            switch self {
            case .free:      return "Free"
            case .spotter:   return "Spotter"
            case .collector: return "Collector"
            case .concours:  return "Concours"
            }
        }

        var monthlyPrice: String {
            switch self {
            case .free:      return "$0"
            case .spotter:   return "$6.99"
            case .collector: return "$14.99"
            case .concours:  return "$29.99"
            }
        }

        var yearlyPrice: String {
            switch self {
            case .free:      return "$0"
            case .spotter:   return "$59"
            case .collector: return "$129"
            case .concours:  return "$249"
            }
        }
    }

    let id: String
    var email: String
    var displayName: String?
    var plan: Plan = .free
    var freeScansUsed: Int = 0
    var stripeCustomerId: String?
    let createdAt: Date

    static let freeLimit = 3
}
