import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var mode: Mode = .signin
    @State private var email = ""
    @State private var password = ""
    @State private var busy = false

    enum Mode { case signin, signup }

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient.spotterBackdrop.ignoresSafeArea()
            RadialGradient(
                colors: [.spotterCyan.opacity(0.30), .clear],
                center: .top,
                startRadius: 10,
                endRadius: 420
            ).ignoresSafeArea()
            RadialGradient(
                colors: [.spotterViolet.opacity(0.20), .clear],
                center: .bottom,
                startRadius: 10,
                endRadius: 380
            ).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    BrandWordmark(size: 22)
                        .padding(.top, 60)

                    VStack(alignment: .leading, spacing: 8) {
                        BadgePill(label: mode == .signin ? "Welcome back" : "Create account",
                                  icon: "sparkles", color: .spotterCyan)

                        Text(mode == .signin ? "Sign in to CarSpotter" : "Get started with CarSpotter")
                            .font(.spotterDisplay)
                            .foregroundStyle(.white)

                        Text(mode == .signin
                             ? "Pick up where you left off — your garage syncs across devices."
                             : "Free forever for 3 scans. No card needed.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(Color.spotterMute)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Sign in with Apple — native, no Firebase config needed
                    SignInWithAppleButton(.continue, onRequest: { req in
                        let appleRequest = auth.startAppleSignIn()
                        req.requestedScopes = appleRequest.requestedScopes
                        req.nonce = appleRequest.nonce
                    }, onCompletion: { result in
                        if case .success(let authorization) = result {
                            Task { await auth.handleAppleAuthorization(authorization) }
                        }
                    })
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    GradientButton(title: "Continue as guest",
                                   icon: "person.fill.questionmark",
                                   style: .ghost) {
                        Task { await auth.signInAnonymously() }
                    }

                    HStack {
                        Rectangle().fill(Color.spotterLine).frame(height: 1)
                        Text("or with email")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.spotterMute)
                            .padding(.horizontal, 10)
                        Rectangle().fill(Color.spotterLine).frame(height: 1)
                    }

                    VStack(spacing: 12) {
                        TextField("", text: $email, prompt: Text("you@example.com").foregroundColor(.spotterMute))
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 14)
                            .frame(height: 52)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.spotterPanel))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.spotterLine, lineWidth: 1))
                            .foregroundStyle(.white)

                        SecureField("", text: $password, prompt: Text("Password (min 6)").foregroundColor(.spotterMute))
                            .padding(.horizontal, 14)
                            .frame(height: 52)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.spotterPanel))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.spotterLine, lineWidth: 1))
                            .foregroundStyle(.white)

                        if let err = auth.lastError {
                            Text(err)
                                .font(.system(size: 13))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GradientButton(
                            title: mode == .signin ? "Sign in" : "Create account",
                            icon: "arrow.right",
                            loading: busy
                        ) {
                            Task {
                                busy = true
                                if mode == .signin {
                                    await auth.signIn(email: email, password: password)
                                } else {
                                    await auth.signUp(email: email, password: password)
                                }
                                busy = false
                            }
                        }
                        .disabled(email.isEmpty || password.count < 6)
                        .opacity(email.isEmpty || password.count < 6 ? 0.5 : 1)
                    }

                    Button(action: { mode = (mode == .signin) ? .signup : .signin }) {
                        Text(mode == .signin
                             ? "Don't have an account? **Sign up**"
                             : "Already have one? **Sign in**")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Color.spotterMute)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthService.preview)
}
