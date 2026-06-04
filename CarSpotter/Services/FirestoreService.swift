import Foundation
import FirebaseFirestore

@MainActor
final class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()

    // ── Scans ────────────────────────────────────────────────────────────

    @Published var myScans: [CarInfo] = []
    @Published var isLoadingScans = false

    func saveScan(_ car: CarInfo, userId: String) async throws {
        let payload: [String: Any] = [
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
            "zeroToSixty": car.zeroToSixty,
            "rarity": car.rarity,
            "celebrity": car.celebrity ?? NSNull(),
            "funFact": car.funFact,
            "spottedAt": FieldValue.serverTimestamp(),
        ]
        _ = try await db.collection("scans").addDocument(data: payload)
    }

    func loadMyScans(userId: String) async {
        isLoadingScans = true
        defer { isLoadingScans = false }
        do {
            let snap = try await db.collection("scans")
                .whereField("userId", isEqualTo: userId)
                .order(by: "spottedAt", descending: true)
                .limit(to: 100)
                .getDocuments()

            myScans = snap.documents.compactMap { doc in
                let d = doc.data()
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
                    celebrity: d["celebrity"] as? String,
                    funFact: d["funFact"] as? String ?? "",
                    recentSale: nil,
                    recalls: nil,
                    wiki: nil
                )
            }
        } catch {
            print("[FirestoreService] loadMyScans error: \(error)")
        }
    }

    // ── User profile ─────────────────────────────────────────────────────

    func upsertProfile(_ profile: UserProfile) async throws {
        try await db.collection("users").document(profile.id).setData([
            "email": profile.email,
            "displayName": profile.displayName ?? "",
            "plan": profile.plan.rawValue,
            "freeScansUsed": profile.freeScansUsed,
            "stripeCustomerId": profile.stripeCustomerId ?? "",
            "updatedAt": FieldValue.serverTimestamp(),
        ], merge: true)
    }
}
