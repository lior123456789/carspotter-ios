import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var store: StoreKitService
    @Environment(\.dismiss) private var dismiss
    @State private var billing: Billing = .yearly
    @State private var selected: UserProfile.Plan = .collector
    @State private var busy = false

    enum Billing: String, CaseIterable { case monthly = "Monthly", yearly = "Yearly" }

    var body: some View {
        ZStack {
            LinearGradient.spotterBackdrop.ignoresSafeArea()
            RadialGradient(colors: [.spotterCyan.opacity(0.18), .clear], center: .top, startRadius: 0, endRadius: 400).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    // close
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }

                    BrandLogo(size: 56)

                    VStack(spacing: 8) {
                        Text("Unlock every car")
                            .font(.spotterDisplay)
                            .foregroundStyle(.white)
                        Text("Pick the plan that fits — cancel anytime.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Color.spotterMute)
                    }

                    // Monthly / Yearly toggle
                    HStack(spacing: 4) {
                        ForEach(Billing.allCases, id: \.self) { b in
                            Button {
                                withAnimation(.easeOut(duration: 0.2)) { billing = b }
                            } label: {
                                Text(b.rawValue)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .background(billing == b ? AnyShapeStyle(LinearGradient.spotterBrand) : AnyShapeStyle(Color.clear))
                                    .foregroundStyle(billing == b ? Color.white : Color.spotterMute)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(4)
                    .background(Color.spotterPanel)
                    .overlay(Capsule().stroke(Color.spotterLine))
                    .clipShape(Capsule())

                    VStack(spacing: 10) {
                        ForEach([UserProfile.Plan.spotter, .collector, .concours], id: \.self) { tier in
                            tierRow(tier)
                        }
                    }

                    GradientButton(
                        title: ctaTitle,
                        icon: "crown.fill",
                        loading: busy
                    ) {
                        guard let product = currentProduct else { return }
                        Task {
                            busy = true
                            let ok = await store.purchase(product)
                            busy = false
                            if ok { dismiss() }
                        }
                    }
                    .padding(.top, 4)

                    // ── Apple-required subscription disclosure ──
                    VStack(spacing: 10) {
                        Text(legalBlurb)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.spotterMute)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 6)

                        HStack(spacing: 16) {
                            Button("Restore") { Task { await store.restore() } }
                            Text("·")
                            Button("Terms of Use") { open("https://carsspotter.com/terms") }
                            Text("·")
                            Button("Privacy Policy") { open("https://carsspotter.com/privacy") }
                        }
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .task { await store.loadProducts() }
    }

    /// Apple requires this exact information on the paywall:
    /// title + length + price of subscription, auto-renewal language,
    /// cancellation instructions, links to Terms (EULA) + Privacy.
    private var legalBlurb: String {
        let period = billing == .monthly ? "month" : "year"
        let price = currentProduct?.displayPrice
            ?? (billing == .monthly ? selected.monthlyPrice : selected.yearlyPrice)
        return """
        \(selected.displayName) — auto-renewable subscription, \(price) per \(period).
        Payment is charged to your Apple ID at confirmation of purchase. \
        Your subscription auto-renews unless you turn off auto-renew at least 24 hours \
        before the end of the current period. Manage or cancel any time in Settings → Apple ID → Subscriptions.
        """
    }

    private func tierRow(_ tier: UserProfile.Plan) -> some View {
        let isSelected = selected == tier
        return Button { selected = tier } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color.spotterCyan : Color.spotterMute)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(tier.displayName)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        if tier == .collector {
                            BadgePill(label: "Most popular", color: .spotterCyan)
                        }
                        Spacer()
                        Text(billing == .monthly ? "\(tier.monthlyPrice)/mo" : "\(tier.yearlyPrice)/yr")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(LinearGradient.spotterBrand)
                    }
                    Text(tierBlurb(tier))
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color.spotterMute)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(14)
            .background(isSelected ? Color.spotterCyan.opacity(0.06) : Color.spotterPanel)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.spotterCyan : Color.spotterLine))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func tierBlurb(_ tier: UserProfile.Plan) -> String {
        switch tier {
        case .free:      return ""
        case .spotter:   return "50 IDs/day · full specs · rarity score · save history"
        case .collector: return "Unlimited · Ask the AI · engine sounds · celebrity owners · Spot Map"
        case .concours:  return "Everything + VIN decoder · auction alerts · valuation PDFs · priority Claude"
        }
    }

    private var currentProduct: Product? {
        let (m, y) = store.products(for: selected)
        return billing == .monthly ? m : y
    }

    private var ctaTitle: String {
        if let p = currentProduct {
            return "Start \(selected.displayName) · \(p.displayPrice)"
        }
        return "Start \(selected.displayName)"
    }

    private func open(_ s: String) { if let u = URL(string: s) { UIApplication.shared.open(u) } }
}

#Preview { PaywallView().environmentObject(StoreKitService.preview) }
