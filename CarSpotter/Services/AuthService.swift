import Foundation
import FirebaseAuth

@MainActor
final class AuthService: NSObject, ObservableObject {
    @Published var user: User? = nil
    @Published var isLoading: Bool = true
    @Published var lastError: String?
    /// Local guest session — lets users into the app without a Firebase
    /// account even when Anonymous auth is unavailable. Persisted so it
    /// survives relaunch.
    @Published var isGuest = false

    private let guestKey = "carspotter.isGuest"
    private var handle: AuthStateDidChangeListenerHandle?

    static var preview: AuthService {
        let s = AuthService()
        s.isLoading = false
        return s
    }

    func start() async {
        isGuest = UserDefaults.standard.bool(forKey: guestKey)
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                // A real account supersedes a local guest session.
                if user != nil { self?.isGuest = false; UserDefaults.standard.set(false, forKey: self?.guestKey ?? "carspotter.isGuest") }
                self?.isLoading = false
                if let user { await self?.syncCookie(uid: user.uid, email: user.email) }
            }
        }
    }

    // ── Email / password ─────────────────────────────────────────────────
    // Uses the SAME Firebase Auth user pool (project carspotter-c0863)
    // as the website, so accounts created at carsspotter.com sign-in
    // here, and accounts created in the iOS app sign-in on the web.

    func signIn(email: String, password: String) async {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func signUp(email: String, password: String) async {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            lastError = error.localizedDescription
        }
    }

    // ── Guest mode ───────────────────────────────────────────────────────
    // Tries Firebase Anonymous auth; if that's disabled or fails for any
    // reason, falls back to a purely local guest session so "Continue as
    // guest" ALWAYS works and never shows an error.

    func continueAsGuest() async {
        do {
            try await Auth.auth().signInAnonymously()
        } catch {
            isGuest = true
            UserDefaults.standard.set(true, forKey: guestKey)
            isLoading = false
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        isGuest = false
        UserDefaults.standard.set(false, forKey: guestKey)
    }

    /// Permanently delete the signed-in account (App Store guideline 5.1.1(v)).
    /// Returns an error message on failure, or nil on success.
    func deleteAccount() async -> String? {
        guard let current = Auth.auth().currentUser else {
            isGuest = false
            UserDefaults.standard.set(false, forKey: guestKey)
            return nil
        }
        // Best-effort: remove the user's stored scans before deleting the account.
        await FirestoreService.deleteAllData(for: current.uid)
        do {
            try await current.delete()
            isGuest = false
            UserDefaults.standard.set(false, forKey: guestKey)
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    // ── Cookie sync (mirrors web behavior) ───────────────────────────────

    private func syncCookie(uid: String, email: String?) async {
        var req = URLRequest(url: API.url(.authSync))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: [
            "uid": uid,
            "email": email ?? "",
        ])
        _ = try? await URLSession.shared.data(for: req)
    }

}
