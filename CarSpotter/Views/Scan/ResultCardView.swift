import SwiftUI

struct ResultCardView: View {
    let car: CarInfo
    let onScanAnother: () -> Void
    @State private var showShare = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // ── Hero image ──
                if let data = car.imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 320)
                        .clipped()
                        .overlay(
                            LinearGradient(colors: [.clear, .spotterInk],
                                           startPoint: .center, endPoint: .bottom)
                        )
                } else {
                    LinearGradient.spotterBrand
                        .frame(height: 220)
                        .overlay(
                            Image(systemName: "car.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.white.opacity(0.4))
                        )
                }

                VStack(alignment: .leading, spacing: 18) {
                    // ── Title + badges ──
                    HStack(spacing: 6) {
                        BadgePill(label: "Identified", icon: "checkmark", color: .green)
                        BadgePill(label: car.year, color: .spotterMute)
                        BadgePill(label: car.category, color: .spotterCyan)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(car.make)
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.spotterMute)
                        Text(car.model)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(LinearGradient.spotterBrand)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                    }

                    // ── Spec grid ──
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        StatRow(label: "Original MSRP", value: car.msrp)
                        StatRow(label: "Value today", value: car.valueRange, accent: true)
                        StatRow(label: "Engine", value: car.engine)
                        StatRow(label: "Horsepower", value: car.horsepower)
                        StatRow(label: "0–60 mph", value: car.zeroToSixty)
                        StatRow(label: "Rarity", value: "\(car.rarity)/10",
                                bar: Double(car.rarity) / 10)
                        if let top = car.topSpeed { StatRow(label: "Top speed", value: top) }
                        if let dt = car.drivetrain { StatRow(label: "Drivetrain", value: dt) }
                        if let w = car.weight { StatRow(label: "Weight", value: w) }
                        if let tq = car.torque { StatRow(label: "Torque", value: tq) }
                        if let prod = car.productionCount {
                            StatRow(label: "Production", value: prod.formatted(), accent: true)
                        }
                    }

                    // ── Celebrity owner ──
                    if let celeb = car.celebrity {
                        HStack(spacing: 12) {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("CELEBRITY OWNER ON RECORD")
                                    .font(.spotterLabel)
                                Text(celeb)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.yellow.opacity(0.10))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.yellow.opacity(0.30), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // ── Recent auction sale ──
                    if let sale = car.recentSale {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("RECENT AUCTION SALE")
                                .font(.spotterLabel)
                            HStack {
                                Text("$\(sale.price.formatted())")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(LinearGradient.spotterBrand)
                                Spacer()
                                Text(sale.auction + " · " + sale.date)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(Color.spotterMute)
                            }
                        }
                        .padding(14)
                        .background(Color.spotterPanel)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.spotterLine, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // ── Fun fact ──
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(Color.spotterCyan)
                            Text("DID YOU KNOW")
                                .font(.spotterLabel)
                                .foregroundStyle(Color.spotterCyan)
                        }
                        Text(car.funFact)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(.white)
                            .lineSpacing(2)
                    }
                    .padding(14)
                    .background(Color.spotterPanel)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.spotterLine, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // ── Wiki blurb ──
                    if let wiki = car.wiki {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("DEEP DIVE")
                                .font(.spotterLabel)
                            Text(wiki)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(Color.spotterMute)
                                .lineSpacing(3)
                        }
                        .padding(.top, 6)
                    }

                    // ── Actions ──
                    VStack(spacing: 10) {
                        GradientButton(title: "Share to feed", icon: "paperplane.fill") {
                            showShare = true
                        }
                        GradientButton(title: "Save to garage",
                                       icon: "tray.and.arrow.down.fill",
                                       style: .ghost) {}
                        GradientButton(title: "Scan another",
                                       icon: "camera.viewfinder",
                                       style: .ghost) {
                            onScanAnother()
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(20)
            }
        }
        .background(Color.spotterInk.ignoresSafeArea())
        .sheet(isPresented: $showShare) {
            ComposePostView(car: car)
        }
    }
}

#Preview {
    ResultCardView(car: .mock, onScanAnother: {})
}
