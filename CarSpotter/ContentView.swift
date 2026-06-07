import SwiftUI

struct ContentView: View {
    @State private var tab: Tab = .feed

    enum Tab: Hashable, CaseIterable { case feed, scan, garage, map, profile }

    var body: some View {
        ZStack {
            Color.spotterInk.ignoresSafeArea()
            currentView
                .safeAreaInset(edge: .bottom) {
                    LiquidGlassTabBar(selection: $tab)
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                }
        }
        .tint(Color.spotterCyan)
    }

    @ViewBuilder private var currentView: some View {
        switch tab {
        case .feed:    FeedView()
        case .scan:    ScanView()
        case .garage:  GarageView()
        case .map:     SpotMapView()
        case .profile: ProfileView()
        }
    }
}

/// Floating frosted-glass tab bar (Liquid Glass aesthetic).
private struct LiquidGlassTabBar: View {
    @Binding var selection: ContentView.Tab

    private let items: [(tab: ContentView.Tab, label: String, icon: String)] = [
        (.feed,    "Feed",    "newspaper.fill"),
        (.scan,    "Scan",    "camera.viewfinder"),
        (.garage,  "Garage",  "car.2.fill"),
        (.map,     "Map",     "mappin.and.ellipse"),
        (.profile, "Profile", "person.crop.circle"),
    ]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(items, id: \.tab) { item in
                TabBarButton(
                    label: item.label,
                    icon: item.icon,
                    isSelected: selection == item.tab
                ) {
                    let g = UIImpactFeedbackGenerator(style: .soft); g.impactOccurred()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                        selection = item.tab
                    }
                }
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 22, x: 0, y: 10)
    }
}

private struct TabBarButton: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 19, weight: .semibold))
                Text(label).font(.system(size: 9.5, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(fg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(highlight)
        }
        .buttonStyle(.plain)
    }

    private var fg: AnyShapeStyle {
        isSelected ? AnyShapeStyle(LinearGradient.spotterBrand) : AnyShapeStyle(Color.spotterMute)
    }

    @ViewBuilder private var highlight: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.spotterCyan.opacity(0.35), lineWidth: 1)
                )
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService.preview)
        .environmentObject(StoreKitService.preview)
}
