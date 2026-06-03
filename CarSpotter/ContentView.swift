import SwiftUI

struct ContentView: View {
    @State private var tab: Tab = .scan

    enum Tab: Hashable { case scan, garage, map, profile }

    var body: some View {
        TabView(selection: $tab) {
            ScanView()
                .tabItem { Label("Scan", systemImage: "camera.viewfinder") }
                .tag(Tab.scan)

            GarageView()
                .tabItem { Label("Garage", systemImage: "car.2.fill") }
                .tag(Tab.garage)

            SpotMapView()
                .tabItem { Label("Map", systemImage: "mappin.and.ellipse") }
                .tag(Tab.map)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(Tab.profile)
        }
        .tint(.spotterCyan)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService.preview)
        .environmentObject(StoreKitService.preview)
}
