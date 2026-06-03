import Foundation
import CoreLocation

/// Mirror of `Spot` from the web project's `lib/spotData.ts`.
struct Spot: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let city: String
    let country: String
    let lng: Double
    let lat: Double
    let kind: Kind
    let blurb: String
    let recentCars: [String]
    let sightings: Int
    let bestTime: String?
    let tier: Tier

    enum Kind: String, Codable, CaseIterable, Identifiable {
        case concours = "Concours"
        case boulevard = "Boulevard"
        case auction = "Auction"
        case track = "Track"
        case resort = "Resort"
        case dealer = "Dealer"
        case show = "Show"

        var id: String { rawValue }

        /// Matches the hex tints used on the web Spot Map.
        var colorHex: UInt32 {
            switch self {
            case .concours:  return 0xFFB020
            case .boulevard: return 0x22D3EE
            case .auction:   return 0xA855F7
            case .track:     return 0xFF3D5A
            case .resort:    return 0x22D3EE
            case .dealer:    return 0x10B981
            case .show:      return 0xEC4899
            }
        }
    }

    enum Tier: String, Codable {
        case iconic, premium, regular
    }

    var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lng)
    }
}
