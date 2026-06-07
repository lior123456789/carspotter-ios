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
    @EnvironmentObject private var store: StoreKitService
    @AppStorage("carspotter.hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("carspotter.usernameSet") private var usernameSet = false

    var body: some View {
        Group {
            if auth.isLoading {
                ZStack {
                    Color.spotterInk.ignoresSafeArea()
                    ProgressView().tint(Color.spotterCyan)
                }
            } else if !hasSeenOnboarding {
                OnboardingView(onDone: { hasSeenOnboarding = true })
            } else if auth.user == nil {
                SignInView()
            } else if !usernameSet && (auth.user?.displayName ?? "").isEmpty {
                UsernameSetupView(onDone: { usernameSet = true })
            } else {
                ContentView()
            }
        }
        .task { await auth.start() }
        // Rebind subscription + free-scan entitlements whenever the signed-in
        // account changes, so a tier never carries over to another account.
        .task(id: auth.user?.uid) {
            Entitlements.shared.setAccount(uid: auth.user?.uid)
            await store.setAccount(uid: auth.user?.uid)
        }
    }
}
