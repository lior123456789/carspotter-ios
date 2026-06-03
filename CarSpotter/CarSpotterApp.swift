import SwiftUI
import FirebaseCore

@main
struct CarSpotterApp: App {
    @StateObject private var auth = AuthService()
    @StateObject private var store = StoreKitService()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .tint(.spotterCyan)
        }
    }
}

private struct RootView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        Group {
            if auth.isLoading {
                ZStack {
                    Color.spotterInk.ignoresSafeArea()
                    ProgressView().tint(.spotterCyan)
                }
            } else if auth.user == nil {
                SignInView()
            } else {
                ContentView()
            }
        }
        .task { await auth.start() }
    }
}
