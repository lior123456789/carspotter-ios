import SwiftUI

/// Three-slide intro shown on first launch before sign-in.
/// Walks the user through the core loop: Scan → Save → Share.
struct OnboardingView: View {
    @State private var page = 0
    let onDone: () -> Void

    private let slides: [OnboardingSlide] = [
        .init(
            icon: "camera.viewfinder",
            iconColors: [Color(hex: 0x22D3EE), Color(hex: 0xA855F7)],
            eyebrow: "Step 1",
            title: "Snap any car",
            subtitle: "Open the camera or pick from your library. Our AI identifies the make, model, year, MSRP, today's value, rarity, even celebrity owners — in 2 seconds.",
            decorations: [
                .badge(label: "PORSCHE 911 GT3 RS · 2023", color: 0x22D3EE),
                .stat(label: "MSRP", value: "$241,300"),
                .stat(label: "VALUE TODAY", value: "$290k – $360k"),
                .stat(label: "RARITY", value: "7/10"),
            ]
        ),
        .init(
            icon: "car.2.fill",
            iconColors: [Color(hex: 0xA855F7), Color(hex: 0x06B6D4)],
            eyebrow: "Step 2",
            title: "Build your garage",
            subtitle: "Save every car you spot to a personal collection that syncs across all your devices. Track your portfolio value, find your rarest spots, share your stats.",
            decorations: [
                .row(year: "2023", make: "Porsche", model: "911 GT3 RS", rarity: 7),
                .row(year: "2021", make: "Ferrari", model: "SF90 Stradale", rarity: 8),
                .row(year: "1990", make: "BMW", model: "M3 E30", rarity: 9),
            ]
        ),
        .init(
            icon: "globe.americas.fill",
            iconColors: [Color(hex: 0x22D3EE), Color(hex: 0xEC4899)],
            eyebrow: "Step 3",
            title: "Share with the world",
            subtitle: "Post a spot with a location, like a friend's find, see what's being spotted in Monaco, Dubai, Tokyo — every car community member's sighting lands on the global map in real time.",
            decorations: [
                .feed(name: "Alex M.", location: "Rodeo Drive · LA", car: "Ferrari SF90"),
                .feed(name: "Sara K.", location: "Casino Sq. · Monaco", car: "Pagani Huayra"),
                .feed(name: "Hiro T.", location: "Daikoku · Tokyo", car: "Nissan R34 GT-R"),
            ]
        ),
    ]

    var body: some View {
        ZStack {
            // Animated brand backdrop
            LinearGradient.spotterBackdrop.ignoresSafeArea()
            RadialGradient(
                colors: [.spotterCyan.opacity(0.30), .clear],
                center: .topLeading, startRadius: 10, endRadius: 500
            ).ignoresSafeArea()
            RadialGradient(
                colors: [.spotterViolet.opacity(0.25), .clear],
                center: .bottomTrailing, startRadius: 10, endRadius: 480
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: wordmark + skip
                HStack {
                    BrandWordmark(size: 16)
                    Spacer()
                    if page < slides.count - 1 {
                        Button("Skip") {
                            withAnimation(.spring()) { page = slides.count - 1 }
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.spotterMute)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)

                Spacer()

                // Slides
                TabView(selection: $page) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { idx, slide in
                        OnboardingSlideView(slide: slide)
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: page)

                Spacer()

                // Dots
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? LinearGradient.spotterBrand : LinearGradient(colors: [Color.spotterLine, Color.spotterLine], startPoint: .leading, endPoint: .trailing))
                            .frame(width: i == page ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: page)
                    }
                }
                .padding(.bottom, 18)

                // Buttons
                VStack(spacing: 10) {
                    GradientButton(
                        title: page == slides.count - 1 ? "Get started" : "Next",
                        icon: page == slides.count - 1 ? "arrow.right.circle.fill" : "arrow.right",
                    ) {
                        if page == slides.count - 1 {
                            UserDefaults.standard.set(true, forKey: "carspotter.hasSeenOnboarding")
                            onDone()
                        } else {
                            withAnimation(.spring()) { page += 1 }
                        }
                    }
                    if page == slides.count - 1 {
                        Text("You'll be asked to sign in next so your garage syncs across devices.")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.spotterMute)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let icon: String
    let iconColors: [Color]
    let eyebrow: String
    let title: String
    let subtitle: String
    let decorations: [Decoration]

    enum Decoration {
        case badge(label: String, color: UInt32)
        case stat(label: String, value: String)
        case row(year: String, make: String, model: String, rarity: Int)
        case feed(name: String, location: String, car: String)
    }
}

private struct OnboardingSlideView: View {
    let slide: OnboardingSlide

    var body: some View {
        VStack(spacing: 28) {
            // Big gradient icon medallion
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: slide.iconColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                    .shadow(color: slide.iconColors.first?.opacity(0.5) ?? .clear, radius: 30, x: 0, y: 12)
                Image(systemName: slide.icon)
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.top, 10)

            VStack(spacing: 8) {
                Text(slide.eyebrow.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(Color.spotterCyan)
                Text(slide.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(slide.subtitle)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(Color.spotterMute)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 8)
            }

            // Visual mockup of the feature
            VStack(spacing: 8) {
                ForEach(0..<slide.decorations.count, id: \.self) { i in
                    decorationView(slide.decorations[i])
                }
            }
        }
        .padding(.horizontal, 28)
    }

    @ViewBuilder private func decorationView(_ d: OnboardingSlide.Decoration) -> some View {
        switch d {
        case .badge(let label, let color):
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(Color(hex: color))
                Text(label)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(12)
            .background(Color.spotterPanel)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spotterLine))
            .clipShape(RoundedRectangle(cornerRadius: 12))

        case .stat(let label, let value):
            HStack {
                Text(label)
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(Color.spotterMute)
                Spacer()
                Text(value)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LinearGradient.spotterBrand)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.spotterPanel)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.spotterLine))
            .clipShape(RoundedRectangle(cornerRadius: 10))

        case .row(let year, let make, let model, let rarity):
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient.spotterBrand.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(Image(systemName: "car.fill").foregroundStyle(LinearGradient.spotterBrand))
                VStack(alignment: .leading, spacing: 1) {
                    Text(year.uppercased())
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(Color.spotterMute)
                    Text("\(make) \(model)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Spacer()
                HStack(spacing: 3) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow)
                    Text("\(rarity)/10")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.spotterCyan)
                }
            }
            .padding(10)
            .background(Color.spotterPanel)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spotterLine))
            .clipShape(RoundedRectangle(cornerRadius: 12))

        case .feed(let name, let location, let car):
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(LinearGradient.spotterBrand)
                    Text(name.prefix(1))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Color.spotterCyan)
                        Text(location)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.spotterMute)
                    }
                }
                Spacer()
                Text(car)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(LinearGradient.spotterBrand)
            }
            .padding(10)
            .background(Color.spotterPanel)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spotterLine))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    OnboardingView(onDone: {})
}
