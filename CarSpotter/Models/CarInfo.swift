import Foundation

/// Mirror of `EnrichedCarInfo` from the web project's `lib/carData.ts`.
/// JSON shape returned by POST `/api/car-info`.
struct CarInfo: Codable, Identifiable, Equatable {
    var id = UUID()

    let make: String
    let model: String
    let year: String
    let category: String
    let msrp: String
    let valueRange: String
    let valueRangeLow: Int?
    let valueRangeHigh: Int?
    let engine: String
    let horsepower: String
    let torque: String?
    let zeroToSixty: String
    let topSpeed: String?
    let weight: String?
    let drivetrain: String?
    let transmission: String?
    let productionCount: Int?
    let rarity: Int
    let celebrity: String?
    let funFact: String
    let recentSale: AuctionSale?
    let recalls: Int?
    let wiki: String?

    /// Local-only fields — not in the API payload.
    var spottedAt: Date = .init()
    var imageData: Data? = nil

    enum CodingKeys: String, CodingKey {
        case make, model, year, category, msrp, valueRange, valueRangeLow,
             valueRangeHigh, engine, horsepower, torque, zeroToSixty, topSpeed,
             weight, drivetrain, transmission, productionCount, rarity,
             celebrity, funFact, recentSale, recalls, wiki
    }
}

struct AuctionSale: Codable, Equatable {
    let auction: String
    let date: String
    let price: Int
}

extension CarInfo {
    static let mock = CarInfo(
        make: "Ferrari",
        model: "SF90 Stradale",
        year: "2020–2023",
        category: "Supercar",
        msrp: "$507,000",
        valueRange: "$550k – $750k",
        valueRangeLow: 550_000,
        valueRangeHigh: 750_000,
        engine: "4.0L Twin-Turbo V8 PHEV",
        horsepower: "986 hp",
        torque: "590 lb-ft",
        zeroToSixty: "2.5 s",
        topSpeed: "211 mph",
        weight: "3,461 lbs",
        drivetrain: "AWD",
        transmission: "8-speed F1 DCT",
        productionCount: nil,
        rarity: 8,
        celebrity: "David Beckham",
        funFact: "First production Ferrari to use a plug-in hybrid powertrain. The V8 alone makes 769 hp.",
        recentSale: .init(auction: "BaT", date: "2026-04-12", price: 612_500),
        recalls: 0,
        wiki: nil
    )
}
