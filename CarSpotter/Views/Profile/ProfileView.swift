import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthService
    @EnvironmentObject private var store: StoreKitService
    @StateObject private var entitlements = Entitlements.shared
    @State private var showPaywall = false
    @State private var showPlateDecoder = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterInk.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // ── Identity card ──
                        VStack(spacing: 14) {
                            BrandLogo(size: 64)
                            VStack(spacing: 4) {
                                Text(auth.user?.email ?? "Guest")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(auth.user?.isAnonymous == true ? "Guest mode · syncs after sign-in" : "Signed in")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(Color.spotterMute)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient.spotterBackdrop)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.spotterLine))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        // ── Current plan ──
                        VStack(alignment: .leading, spacing: 12) {
                            Text("YOUR PLAN").font(.spotterLabel)

                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(store.purchasedTier.displayName)
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(LinearGradient.spotterBrand)
                                    Text(store.purchasedTier == .free
                                         ? "3 free scans"
                                         : "Unlimited scans · all features")
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundStyle(Color.spotterMute)
                                }
                                Spacer()
                                Image(systemName: store.purchasedTier == .free ? "lock.fill" : "checkmark.seal.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(LinearGradient.spotterBrand)
                            }

                            if store.purchasedTier == .free {
                                GradientButton(title: "Upgrade", icon: "crown.fill") {
                                    showPaywall = true
                                }
                                .padding(.top, 6)
                            } else {
                                GradientButton(title: "Manage subscription",
                                               icon: "arrow.right.circle.fill",
                                               style: .ghost) {
                                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .padding(.top, 6)
                            }
                        }
                        .padding(20)
                        .background(Color.spotterPanel)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.spotterLine))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        // ── Pro tools (Concours) ──
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("PRO TOOLS").font(.spotterLabel)
                                Spacer()
                                if !entitlements.canAccessProTools(tier: store.purchasedTier) {
                                    Text("CONCOURS").font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.spotterViolet)
                                }
                            }
                            .padding(.horizontal, 18).padding(.top, 14).padding(.bottom, 6)

                            settingsRow("License plate decoder",
                                        icon: entitlements.canAccessProTools(tier: store.purchasedTier)
                                            ? "textformat.123" : "lock.fill") {
                                if entitlements.canAccessProTools(tier: store.purchasedTier) {
                                    showPlateDecoder = true
                                } else {
                                    showPaywall = true
                                }
                            }
                        }
                        .background(Color.spotterPanel)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.spotterLine))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        // ── Settings list ──
                        VStack(spacing: 0) {
                            settingsRow("Restore purchases", icon: "arrow.clockwise.circle.fill") {
                                Task { await store.restore() }
                            }
                            divider
                            settingsRow("Privacy policy", icon: "hand.raised.fill") {
                                openURL("https://carsspotter.com/privacy")
                            }
                            divider
                            settingsRow("Terms of service", icon: "doc.text.fill") {
                                openURL("https://carsspotter.com/terms")
                            }
                            divider
                            settingsRow("Contact support", icon: "envelope.fill") {
                                openURL("mailto:hi@carsspotter.com")
                            }
                        }
                        .background(Color.spotterPanel)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.spotterLine))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        // ── Sign out ──
                        Button(role: .destructive) {
                            auth.signOut()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign out").font(.system(size: 16, weight: .medium, design: .rounded))
                            }
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.10))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.red.opacity(0.3)))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Text("CarSpotter v1.0.0")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.spotterMute)
                            .padding(.top, 4)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(isPresented: $showPlateDecoder) { PlateDecoderView() }
            .task { await store.loadProducts(); await store.refreshEntitlements() }
        }
    }

    private var divider: some View {
        Rectangle().fill(Color.spotterLine).frame(height: 1).padding(.leading, 52)
    }

    private func settingsRow(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .foregroundStyle(Color.spotterCyan)
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.spotterMute)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
    }

    private func openURL(_ s: String) {
        if let url = URL(string: s) { UIApplication.shared.open(url) }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService.preview)
        .environmentObject(StoreKitService.preview)
}
