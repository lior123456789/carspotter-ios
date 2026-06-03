# CarSpotter — iOS app (SwiftUI)

Native iOS 17+ app for **carsspotter.app**. Calls the same `/api/car-info`,
`/api/spots`, and Firebase Auth + Firestore as the website. App Store IAP
subscriptions mirror the web Stripe tiers (Spotter / Collector / Concours).

## Open in Xcode — first time

1. **Create a new Xcode project**
   - File → New → Project → iOS → App
   - Product Name: `CarSpotter`
   - Team: your Apple Developer account
   - Bundle Identifier: `app.carsspotter` (or whatever matches your provisioning)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**
   - Save the new `.xcodeproj` somewhere — then close Xcode.

2. **Replace the generated files with this folder's content**
   - In Finder, navigate to the Xcode-created `CarSpotter/CarSpotter/` folder.
   - Delete the auto-generated `CarSpotterApp.swift` and `ContentView.swift`.
   - Drag in everything under `~/Desktop/claude/carspotter-ios/CarSpotter/` — Xcode will ask to "Copy items if needed", check it.

3. **Add Firebase iOS SDK via Swift Package Manager**
   - File → Add Package Dependencies
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Choose: `FirebaseAuth`, `FirebaseFirestore`, `FirebaseFirestoreSwift`, `FirebaseStorage`, `FirebaseAnalytics`

4. **Download GoogleService-Info.plist**
   - https://console.firebase.google.com/project/carspotter-c0863/settings/general/
   - Scroll to "Your apps" → Add app → iOS → enter bundle ID `app.carsspotter`
   - Download the `GoogleService-Info.plist` — drag into Xcode project root, ensure "Copy items if needed".

5. **Set Info.plist permissions** (or use the keys from `Resources/Info.plist.template`)
   - `NSCameraUsageDescription` — "CarSpotter uses the camera to identify cars instantly."
   - `NSPhotoLibraryUsageDescription` — "Pick a photo from your library to identify the car."
   - `NSLocationWhenInUseUsageDescription` — "Show car-spotting hotspots near you."

6. **Sign in with Apple capability**
   - Project → Signing & Capabilities → + → Sign in with Apple

7. **Build target**
   - iOS 17.0+, Swift 5.9+
   - Run on a real device or iPhone 15 Pro simulator for best results.

## What's included

| Tab | View | Notes |
| --- | --- | --- |
| Scan | `ScanView` + `ResultCardView` | Camera + library + drag-to-scan, 4-stage progress animation, full premium result card |
| Garage | `GarageView` | Personal collection synced via Firestore |
| Map | `MapView` | All 50+ spotting hotspots, native MapKit |
| Profile | `ProfileView` + `PaywallView` | Plan management, sign out, IAP upgrades |

`Services/API.swift` — switches between `http://localhost:3004` (DEBUG) and `https://carsspotter.app` (RELEASE).

## Bundle ID, signing, App Store
- Bundle: `app.carsspotter`
- Display name: `CarSpotter`
- App Store category: Lifestyle (Automotive sub-category)
- Subscription group: `CarSpotter Plus`
- Products to create in App Store Connect (must match `StoreKitService.swift`):
  - `app.carsspotter.spotter.monthly` — $6.99
  - `app.carsspotter.spotter.yearly` — $59.00
  - `app.carsspotter.collector.monthly` — $14.99
  - `app.carsspotter.collector.yearly` — $129.00
  - `app.carsspotter.concours.monthly` — $29.99
  - `app.carsspotter.concours.yearly` — $249.00
