import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CarSpotterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var auth = AuthService()
    @StateObject private var store = StoreKitService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .tint(Color.spotterCyan)
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
                    ProgressView().tint(Color.spotterCyan)
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
