import Foundation
import FirebaseAuth

/// Web-API-backed replacement for Firestore. Calls the same /api/*
/// endpoints the web app uses, so iOS doesn't need the heavy Firestore
/// SDK (which was hanging Xcode builds for hours).
@MainActor
final class FirestoreService: ObservableObject {
    @Published var myScans: [CarInfo] = []
    @Published var isLoadingScans = false

    func saveScan(_ car: CarInfo, userId: String) async throws {
        // The server records the scan when /api/identify or /api/car-info is
        // called. Nothing else to do here — kept for API parity.
    }

    func loadMyScans(userId: String) async {
        isLoadingScans = true
        defer { isLoadingScans = false }
        do {
            var req = URLRequest(url: API.url(.me))
            if let token = try? await Auth.auth().currentUser?.getIDToken() {
                req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, _) = try await URLSession.shared.data(for: req)
            struct Envelope: Decodable { let scans: [CarInfo] }
            let env = try JSONDecoder().decode(Envelope.self, from: data)
            myScans = env.scans
        } catch {
            print("[FirestoreService] loadMyScans error: \(error)")
        }
    }

    func upsertProfile(_ profile: UserProfile) async throws {
        // Server-side profile sync happens via the /api/auth/sync cookie
        // set by AuthService after sign-in. No action needed here.
    }
}
