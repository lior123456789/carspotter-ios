import SwiftUI
import FirebaseAuth

/// First-launch username picker. Shown after sign-in when the user
/// has no displayName set. Writes to Firebase Auth profile + Firestore
/// /users/{uid}.username so feed posts show "@username" instead of
/// the email prefix.
struct UsernameSetupView: View {
    let onDone: () -> Void

    @EnvironmentObject private var auth: AuthService
    @State private var username = ""
    @State private var busy = false
    @State private var err: String?

    var body: some View {
        ZStack {
            LinearGradient.spotterBackdrop.ignoresSafeArea()
            RadialGradient(colors: [Color.spotterCyan.opacity(0.30), .clear],
                           center: .top, startRadius: 10, endRadius: 420).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(LinearGradient.spotterBrand)
                        .frame(width: 84, height: 84)
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 6) {
                    Text("Pick your username")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("This is how the community sees you when you post a spot.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(Color.spotterMute)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                HStack(spacing: 0) {
                    Text("@")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.spotterMute)
                        .padding(.leading, 14)
                    TextField("", text: $username, prompt:
                        Text("yourname").foregroundColor(Color.spotterMute))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 8)
                        .foregroundStyle(.white)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .onChange(of: username) { _, new in
                            // Strip invalid chars: keep a-z, 0-9, _ . max 20 chars
                            let cleaned = new.lowercased()
                                .replacingOccurrences(of: " ", with: "")
                                .filter { "abcdefghijklmnopqrstuvwxyz0123456789_.".contains($0) }
                            if cleaned != username {
                                username = String(cleaned.prefix(20))
                            }
                        }
                }
                .background(Color.spotterPanel)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.spotterLine))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)

                Text("3–20 characters · letters, numbers, _ and .")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.spotterMute)

                if let err {
                    Text(err)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 24)
                }

                Spacer()

                GradientButton(
                    title: "Continue",
                    icon: "arrow.right",
                    loading: busy
                ) {
                    Task { await save() }
                }
                .disabled(username.count < 3 || busy)
                .opacity(username.count < 3 ? 0.5 : 1)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() async {
        busy = true
        defer { busy = false }
        err = nil

        guard let user = Auth.auth().currentUser else {
            err = "Not signed in."
            return
        }

        do {
            // 1. Update Firebase Auth displayName so it's available across the app
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            try await changeRequest.commitChanges()

            // 2. Write to Firestore /users/{uid}.username for global lookup
            try await FirestoreREST.setDoc(
                path: "users/\(user.uid)",
                data: [
                    "username": username,
                    "email": user.email ?? "",
                    "displayName": username,
                ]
            )
            UserDefaults.standard.set(true, forKey: "carspotter.usernameSet")
            onDone()
        } catch {
            err = error.localizedDescription
        }
    }
}

#Preview {
    UsernameSetupView(onDone: {})
        .environmentObject(AuthService.preview)
}
