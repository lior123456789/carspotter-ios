import Foundation
import FirebaseAuth

/// Real garage-backed scan storage. Writes through to Firestore via
/// REST (no Firestore SDK needed). The /scans collection it writes to
/// is the SAME one the website's /dashboard reads from, so any car
/// saved here appears on the web instantly and vice versa.
@MainActor
final class FirestoreService: ObservableObject {
    @Published var myScans: [CarInfo] = []
    @Published var isLoadingScans = false
    @Published var lastError: String?

    /// Persist a scan to the user's Firestore /scans collection.
    /// Called from "Save to Garage" on the result card.
    func saveScan(_ car: CarInfo, userId: String) async throws {
        let now = Date()
        let data: [String: Any] = [
            "userId": userId,
            "make": car.make,
            "model": car.model,
            "year": car.year,
            "category": car.category,
            "msrp": car.msrp,
            "valueRange": car.valueRange,
            "valueRangeLow": car.valueRangeLow ?? 0,
            "valueRangeHigh": car.valueRangeHigh ?? 0,
            "engine": car.engine,
            "horsepower": car.horsepower,
            "torque": car.torque ?? "",
            "zeroToSixty": car.zeroToSixty,
            "topSpeed": car.topSpeed ?? "",
            "weight": car.weight ?? "",
            "drivetrain": car.drivetrain ?? "",
            "transmission": car.transmission ?? "",
            "rarity": car.rarity,
            "celebrity": car.celebrity ?? "",
            "funFact": car.funFact,
            "wiki": car.wiki ?? "",
            "spottedAt": now,
        ]
        try await FirestoreREST.createDoc(in: "scans", data: data)
        // Refresh local cache so Garage tab updates immediately
        await loadMyScans(userId: userId)
    }

    /// Load this user's scans from Firestore via REST (newest first).
    /// Uses runQuery with a `where userId == auth.uid` filter so Firestore
    /// security rules accept the list operation.
    func loadMyScans(userId: String) async {
        isLoadingScans = true
        defer { isLoadingScans = false }
        do {
            let docs = try await FirestoreREST.queryDocs(
                collection: "scans",
                whereField: "userId",
                equalToString: userId,
                orderByField: "spottedAt",
                descending: true,
                limit: 100
            )
            myScans = docs.compactMap { doc in
                let d = doc.data
                guard let make = d["make"] as? String,
                      let model = d["model"] as? String else { return nil }
                return CarInfo(
                    make: make,
                    model: model,
                    year: d["year"] as? String ?? "",
                    category: d["category"] as? String ?? "Daily",
                    msrp: d["msrp"] as? String ?? "—",
                    valueRange: d["valueRange"] as? String ?? "—",
                    valueRangeLow: d["valueRangeLow"] as? Int,
                    valueRangeHigh: d["valueRangeHigh"] as? Int,
                    engine: d["engine"] as? String ?? "",
                    horsepower: d["horsepower"] as? String ?? "",
                    torque: d["torque"] as? String,
                    zeroToSixty: d["zeroToSixty"] as? String ?? "",
                    topSpeed: d["topSpeed"] as? String,
                    weight: d["weight"] as? String,
                    drivetrain: d["drivetrain"] as? String,
                    transmission: d["transmission"] as? String,
                    productionCount: d["productionCount"] as? Int,
                    rarity: d["rarity"] as? Int ?? 5,
                    celebrity: (d["celebrity"] as? String).flatMap { $0.isEmpty ? nil : $0 },
                    funFact: d["funFact"] as? String ?? "",
                    recentSale: nil,
                    recalls: nil,
                    wiki: (d["wiki"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                )
            }
        } catch {
            lastError = error.localizedDescription
            print("[FirestoreService] loadMyScans error: \(error)")
        }
    }

    func upsertProfile(_ profile: UserProfile) async throws {
        let data: [String: Any] = [
            "email": profile.email,
            "displayName": profile.displayName ?? "",
            "plan": profile.plan.rawValue,
            "freeScansUsed": profile.freeScansUsed,
            "stripeCustomerId": profile.stripeCustomerId ?? "",
        ]
        try await FirestoreREST.setDoc(path: "users/\(profile.id)", data: data)
    }
}
