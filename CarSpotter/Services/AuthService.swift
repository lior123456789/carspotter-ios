import Foundation
import FirebaseAuth

@MainActor
final class AuthService: NSObject, ObservableObject {
    @Published var user: User? = nil
    @Published var isLoading: Bool = true
    @Published var lastError: String?

    private var handle: AuthStateDidChangeListenerHandle?

    static var preview: AuthService {
        let s = AuthService()
        s.isLoading = false
        return s
    }

    func start() async {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
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

    // ── Anonymous guest mode ─────────────────────────────────────────────

    func signInAnonymously() async {
        do {
            try await Auth.auth().signInAnonymously()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
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
