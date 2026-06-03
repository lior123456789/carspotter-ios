import SwiftUI
import MapKit

struct SpotMapView: View {
    @StateObject private var loader = SpotsLoader()
    @State private var selected: Spot?
    @State private var camera: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30, longitude: 10),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 90)
    ))

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterInk.ignoresSafeArea()

                Map(position: $camera, selection: $selected) {
                    ForEach(loader.spots) { spot in
                        Annotation(spot.name, coordinate: spot.coordinate) {
                            SpotPin(kind: spot.kind, tier: spot.tier)
                                .onTapGesture { selected = spot }
                        }
                        .tag(spot)
                    }

                    UserAnnotation()
                }
                .mapStyle(.standard(elevation: .realistic))
                .ignoresSafeArea(edges: [.bottom])

                if loader.spots.isEmpty {
                    ProgressView().tint(.spotterCyan)
                }
            }
            .navigationTitle("Spot Map")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task { await loader.load() }
            .sheet(item: $selected) { spot in
                SpotDetailSheet(spot: spot)
                    .presentationDetents([.medium, .large])
                    .presentationBackground(.regularMaterial)
            }
        }
    }
}

private struct SpotPin: View {
    let kind: Spot.Kind
    let tier: Spot.Tier

    var body: some View {
        ZStack {
            if tier == .iconic {
                Circle()
                    .stroke(Color(hex: kind.colorHex).opacity(0.6), lineWidth: 2)
                    .frame(width: 30, height: 30)
                    .blur(radius: 2)
            }
            Circle()
                .fill(Color(hex: kind.colorHex))
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(.white, lineWidth: 2))
                .shadow(color: Color(hex: kind.colorHex).opacity(0.7), radius: 6)
        }
    }
}

private struct SpotDetailSheet: View {
    let spot: Spot

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 6) {
                    BadgePill(label: spot.kind.rawValue, color: Color(hex: spot.kind.colorHex))
                    if spot.tier == .iconic {
                        BadgePill(label: "Iconic", icon: "star.fill", color: .yellow)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name)
                        .font(.spotterDisplay)
                        .foregroundStyle(.primary)
                    Text("\(spot.city), \(spot.country)")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Text(spot.blurb)
                    .font(.system(size: 15, design: .rounded))
                    .lineSpacing(3)

                if let best = spot.bestTime {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BEST TIME").font(.spotterLabel)
                        Text(best)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("RECENT SIGHTINGS").font(.spotterLabel)
                    ForEach(spot.recentCars, id: \.self) { car in
                        HStack(spacing: 6) {
                            Image(systemName: "circle.fill").font(.system(size: 4))
                            Text(car).font(.system(size: 14, design: .rounded))
                        }
                    }
                }

                Text("\(spot.sightings.formatted()) community sightings logged")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)

                Spacer(minLength: 30)
            }
            .padding(24)
        }
    }
}

@MainActor
final class SpotsLoader: ObservableObject {
    @Published var spots: [Spot] = []

    func load() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: API.url(.spots))
            struct Envelope: Decodable { let spots: [Spot] }
            let env = try JSONDecoder().decode(Envelope.self, from: data)
            spots = env.spots
        } catch {
            print("[SpotsLoader] error: \(error)")
        }
    }
}

#Preview { SpotMapView() }
