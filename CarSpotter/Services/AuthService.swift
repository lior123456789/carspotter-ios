import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

@MainActor
final class AuthService: NSObject, ObservableObject {
    @Published var user: User? = nil
    @Published var isLoading: Bool = true
    @Published var lastError: String?

    private var handle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

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

    // ── Sign in with Apple ───────────────────────────────────────────────

    func startAppleSignIn() -> ASAuthorizationAppleIDRequest {
        let nonce = randomNonceString()
        currentNonce = nonce
        let provider = ASAuthorizationAppleIDProvider()
        let req = provider.createRequest()
        req.requestedScopes = [.fullName, .email]
        req.nonce = sha256(nonce)
        return req
    }

    func handleAppleAuthorization(_ authorization: ASAuthorization) async {
        guard let cred = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = cred.identityToken,
              let token = String(data: tokenData, encoding: .utf8),
              let nonce = currentNonce
        else {
            lastError = "Apple sign-in failed."
            return
        }
        let credential = OAuthProvider.appleCredential(
            withIDToken: token,
            rawNonce: nonce,
            fullName: cred.fullName
        )
        do {
            try await Auth.auth().signIn(with: credential)
        } catch {
            lastError = error.localizedDescription
        }
    }

    // ── Email / password ─────────────────────────────────────────────────

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

    // ── Nonce helpers (Apple Sign-In requirement) ────────────────────────

    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var bytes = [UInt8](repeating: 0, count: 16)
            _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            for byte in bytes where remaining > 0 {
                if byte < charset.count {
                    result.append(charset[Int(byte)])
                    remaining -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
