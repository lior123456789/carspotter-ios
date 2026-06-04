import SwiftUI
import FirebaseAuth

struct GarageView: View {
    @EnvironmentObject private var auth: AuthService
    @StateObject private var firestore = FirestoreService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterInk.ignoresSafeArea()

                if firestore.isLoadingScans {
                    ProgressView().tint(Color.spotterCyan)
                } else if firestore.myScans.isEmpty {
                    emptyState
                } else {
                    listState
                }
            }
            .navigationTitle("Garage")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task { await reload() }
            .refreshable { await reload() }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            BrandLogo(size: 64)
            Text("Your garage is empty")
                .font(.spotterTitle)
                .foregroundStyle(.white)
            Text("Snap your first car on the Scan tab —\nit'll land here automatically.")
                .multilineTextAlignment(.center)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color.spotterMute)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    private var listState: some View {
        ScrollView {
            // KPI tiles
            HStack(spacing: 10) {
                kpi("Cars", "\(firestore.myScans.count)")
                kpi("Avg rarity",
                    String(format: "%.1f", Double(firestore.myScans.map(\.rarity).reduce(0, +)) / Double(max(1, firestore.myScans.count))),
                    accent: true)
                kpi("Portfolio value", "$\((firestore.myScans.compactMap(\.valueRangeLow).reduce(0, +) / 1000))k")
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            LazyVStack(spacing: 8) {
                ForEach(firestore.myScans) { car in
                    NavigationLink {
                        ResultCardView(car: car, onScanAnother: {})
                            .toolbar(.hidden, for: .tabBar)
                    } label: {
                        GarageCarRow(car: car)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .padding(.top, 16)
        }
    }

    private func kpi(_ label: String, _ value: String, accent: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.spotterLabel)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(accent ? Color.spotterCyan : .white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(accent ? Color.spotterCyan.opacity(0.08) : Color.spotterPanel)
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(accent ? Color.spotterCyan.opacity(0.35) : Color.spotterLine))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func reload() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        await firestore.loadMyScans(userId: uid)
    }
}

private struct GarageCarRow: View {
    let car: CarInfo

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient.spotterBrand.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(Image(systemName: "car.fill")
                    .foregroundStyle(LinearGradient.spotterBrand))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(car.year.uppercased())
                        .font(.spotterLabel)
                    BadgePill(label: car.category, color: .spotterCyan)
                }
                Text("\(car.make) \(car.model)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(car.valueRange)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color.spotterMute)
            }

            Spacer()

            VStack(spacing: 2) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.yellow)
                Text("\(car.rarity)/10")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.spotterCyan)
            }
        }
        .padding(12)
        .background(Color.spotterPanel)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.spotterLine))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview { GarageView().environmentObject(AuthService.preview) }
