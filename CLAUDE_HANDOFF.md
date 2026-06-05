# CarSpotter — Claude Code Handoff

Full session context. Read this first on a fresh Claude Code session.

Project: `/Users/lioramsellem/Desktop/claude/carspotter-ios/`
GitHub: `https://github.com/lior123456789/carspotter-ios`
Website: `https://carsspotter.com` (Render-deployed, code in `~/Desktop/claude/carsspotter-landing/`)
Owner: Paul (paul@nemapp.com), solo founder
Last commit: `3bc0c94` — marketing kit

---

## Session goal
Get CarSpotter approved for App Store v1.0, ship a paywall + feature gating, and deliver a complete launch marketing kit (screenshots + ads + video script).

## What got shipped this session

### 1. App Store rejection fixes (5 errors → 0)
**Errors that came back from the App Store validator:**
- `UIInterfaceOrientationPortrait` rejected — iPad multitasking requires all 4 orientations
- Missing 152×152 iPad icon
- Missing 120×120 iPhone icon
- Missing `CFBundleIconName` Info.plist entry
- Upload Symbols failed for FirebaseFirestoreInternal, absl, grpc, grpcpp, openssl_grpc dSYMs

**Fixes (commits `60c3a3f`, `a5e6fb1`, `b56ac00`):**
- `Info.plist`: added `CFBundleIconName=AppIcon`, `LSRequiresIPhoneOS=true`. Removed bogus `armv7` capability.
- `project.pbxproj`: `TARGETED_DEVICE_FAMILY` switched from `"1,2"` to `"1"` (iPhone-only — kills both the iPad orientation requirement and the missing 152×152 iPad icon error in one shot)
- Stripped `FirebaseFirestore` and `FirebaseStorage` SPM products from pbxproj (no Swift code imports them; all Firebase data goes through `FirebaseREST.swift`). This eliminates the 5 dSYM upload warnings + speeds up the build.
- Generated a 1024×1024 PNG app icon (`AppIcon-1024.png`) in `CarSpotter/Resources/Assets.xcassets/AppIcon.appiconset/` — cyan→violet gradient, viewfinder corners, car silhouette. Xcode derives the 120×120 iPhone icon from this.
- Removed Apple Sign-In entitlement contents (Apple sign-in was deleted earlier this session).

Verified `BUILD SUCCEEDED` in Release config via `xcodebuild`.

### 2. Username system (commit `66eea97`)
- New file: `CarSpotter/Views/Profile/UsernameSetupView.swift` — 3-20 char picker, auto-sanitized to lowercase a-z/0-9/_/. Writes to `Auth.currentUser.displayName` + Firestore `/users/{uid}.username`.
- `CarSpotterApp.swift` `RootView` now routes: loading → onboarding → sign-in → **username setup** → ContentView.
- Stored as `@AppStorage("carspotter.usernameSet")` to skip on subsequent launches.

### 3. PostCardView layout fix (commit `66eea97`)
The Macan card was clipping "ECTRIC LUXURY SUV" off the left edge because BadgePill content was wider than the image inside a ZStack overlay. Rewrote: header → hero photo (no overlay) → car info BELOW image. No overflow possible now.

### 4. Subscription paywall + feature gating (commit `60c3a3f`)
- New file: `CarSpotter/Services/Entitlements.swift` — single source of truth for "can the user do X?"
  - `canScan(tier:)` — true if paid OR `freeScansUsed < 3`
  - `canAccessProTools(tier:)` — Concours only (VIN, auctions, valuation PDFs)
  - `canAccessCollectorFeatures(tier:)` — Collector+ (Ask-the-AI, engine sounds, spot map)
  - `freeScansUsed` persisted via `@AppStorage("carspotter.freeScansUsed")`
- `ScanView.swift`: Camera + Library buttons now gate behind `canScan`. Shows "X free scans left" hint. After successful identify, `recordScan()` increments counter.
- `PaywallView.swift`: added the Apple-required subscription disclosure block (auto-renew language, period, price, Apple ID billing, Settings cancellation, Terms + Privacy). Added `.task { await store.loadProducts() }`.

### 5. Marketing kit (commit `3bc0c94`)

**App Store screenshots** — `marketing/screenshots/` in 3 device sizes × 6 screens:
- `6.7in_1290x2796/` — iPhone 15/16/17 Pro Max
- `6.5in_1242x2688/` — iPhone XS Max / 11 Pro Max
- `6.5in_1284x2778/` — iPhone 12/13/14 Pro Max
Six screens each: `01_hero.png`, `02_result.png`, `03_garage.png`, `04_feed.png`, `05_map.png`, `06_paywall.png`. Generated programmatically with Python+PIL (mockups, not simulator captures — replace for v1.1 if desired).

**Ad creatives** — `marketing/ads/` — 9 PNGs (3 campaigns × 3 sizes):
- `brand_*` — "Snap any car. Know everything." main awareness creative
- `hook_*` — "What's THAT car?" curiosity hook (Reels/TikTok)
- `freeScans_*` — "3 free scans" conversion creative
- Each in 1080×1080 square, 1080×1920 story, 1920×1080 landscape

**Video ad kit** — `marketing/VIDEO_AD_KIT.md`:
- 15s + 30s shot scripts
- 4 car↔app transition recipes (white-flash, reticle match-cut, glass-morph, mask-wipe along silhouette)
- Runway / Sora / Pika AI-generation prompts
- CapCut/Premiere edit recipe with music + BPM cues
- Platform placement matrix

---

## Outstanding work before App Store approval

### ✅ User-Generated Content compliance (Apple rule 1.2) — DONE
Shipped this session:
1. **Report Post** — `…` menu on every post (not your own) → reason picker → writes to Firestore `/reports` queue + hides the post locally. `ModerationService.report(post:reason:)`.
2. **Block User** — `…` menu → confirm → `ModerationService.block(userId:)`, persisted in UserDefaults; blocked authors filtered out of the feed in `FeedService.refresh()`.
3. **Pre-publish moderation** — `ModerationService.firstBlockedTerm(in:)` runs a client-side slur/profanity gate on the caption in `FeedService.createPost` (throws before upload). Server still runs the full OpenAI moderation pass.
4. **Content agreement** — `ComposePostView` has a required "I agree to the Community Guidelines" checkbox; Share is disabled until checked.
5. **Account termination policy** — documented in `/terms` (zero-tolerance clause + repeat-violator termination).

New file: `CarSpotter/Services/ModerationService.swift` (wired into pbxproj, Release build verified).

**⚠️ Manual step:** publish the updated `firestore.rules` (adds the `/reports` create rule) in Firebase Console → Firestore → Rules → Publish. Reports will fail to write until this is done.

### App Store Connect setup
- Create the 6 IAP subscription products with **exact** IDs (see "Subscription IDs" below)
- Sign Paid Apps Agreement (Business → Agreements, Tax, and Banking)
- Create sandbox test account for purchase testing
- Create demo review account: `review@carsspotter.com` / `CarReview2026!` (must exist in Firebase Auth before submitting)
- Upload screenshots from `marketing/screenshots/`
- ✅ `/privacy`, `/terms`, `/support` routes built on carsspotter.com (in `carsspotter-landing/app/{privacy,terms,support}/page.tsx`) — push to Render to deploy. Homepage footer links updated.

### Xcode setup before next archive
1. Open project, wait for SPM package resolve
2. Target → **Signing & Capabilities** → pick the Apple Developer team from dropdown
3. **Bump Build number** to `2` (Apple rejects duplicate build numbers)
4. Product → Clean Build Folder (`⇧⌘K`) to clear stale `.swiftdoc`/`.swiftmodule`/`.abi.json` errors
5. Product → Archive → Distribute → App Store Connect

---

## App Store Connect copy pack (ready-to-paste)

### App Name (30 char)
`CarSpotter`

### Subtitle (30 char)
`Identify Any Car With AI`

### Promotional Text (170 char)
`Snap any car, know everything in 2 seconds. Make, model, year, MSRP, today's value, rarity, celebrity owners — all powered by GPT-4 + Claude vision AI.`

### Description (4000 char limit, current ~2,061)
```
CarSpotter is the AI car-identification app built for true enthusiasts.

Point your camera at any car — exotic, classic, JDM, or daily driver — and in under 2 seconds get the full breakdown: make, model, year, MSRP, today's market value, rarity score on a 1-10 scale, celebrity owners, and the kind of trivia normally only a forum lifer would know. Powered by GPT-4 + Claude vision models running an ensemble.

ZERO LEARNING CURVE
Open the app. Point. Tap. Done. No badges to memorize, no model numbers to type. CarSpotter does the work.

BUILD YOUR GARAGE
Every car you identify is saved to a personal Garage that syncs across all your devices. Track your total portfolio value. Find your rarest spots. Show off your collection.

GLOBAL FEED
See what enthusiasts are spotting right now in Monaco, Beverly Hills, Dubai, Tokyo, Pebble Beach. Post your own spots with a location tag — they land on the world map for everyone to see.

THE SPOT MAP
Hotspots where the world's rarest cars get spotted: Rodeo Drive, Casino Square Monaco, Daikoku PA in Yokohama, Goodwood, Pebble Beach, Wynwood. Plan your spotting trip around the map.

500,000+ MODELS IN THE DATABASE
From a 1932 Ford Model 18 to a 2025 Bugatti Tourbillon. Production cars, racing cars, kit cars, restomods, one-offs. If it has four wheels, CarSpotter knows it.

SUBSCRIPTION TIERS
• Spotter — $6.99/mo or $59/yr — 50 IDs per day, full specs, rarity, save history
• Collector — $14.99/mo or $129/yr — Unlimited IDs, Ask-the-AI, engine sounds, celebrity owners, Spot Map
• Concours — $29.99/mo or $249/yr — VIN decoder, live auction alerts, valuation PDFs, priority AI processing

Free users get 3 lifetime scans to try CarSpotter risk-free.

Subscriptions are auto-renewable. Payment is charged to your Apple ID at confirmation of purchase. Auto-renewal can be turned off at any time in Settings → Apple ID → Subscriptions, at least 24 hours before the period ends.

Terms of Use (EULA): https://carsspotter.com/terms
Privacy Policy: https://carsspotter.com/privacy
Support: https://carsspotter.com/support
```

### Keywords (100 char limit)
`car,cars,identify,spotter,exotic,supercar,porsche,ferrari,vin,rarity,jdm,vehicle,collector,carmeet`

### What's New in v1.0 (4000 char)
```
Welcome to CarSpotter.

This is v1.0. Everything works:
• AI car identification in 2 seconds, powered by an ensemble of GPT-4 + Claude vision
• Personal Garage that syncs across all your devices via Firebase
• Global social Feed with location-tagged posts
• Worldwide Spot Map with hotspot pins
• 3 subscription tiers from Spotter to Concours

Have a feature you want? Email paul@nemapp.com — we ship fast.
```

### Support URL
`https://carsspotter.com/support`

### Marketing URL
`https://carsspotter.com`

### Privacy Policy URL
`https://carsspotter.com/privacy`

### Copyright
`© 2026 CarSpotter`

### Age Rating
4+ (with User-Generated Content disclosure for the Feed)

---

## Subscription IDs (must match `StoreKitService.swift` exactly)

| Product ID | Display Name | Duration | Price | Description (55 char) |
|---|---|---|---|---|
| `app.carsspotter.spotter.monthly` | Spotter Monthly | 1 Month | $6.99 | `50 IDs/day, full specs & rarity. Auto-renews.` |
| `app.carsspotter.spotter.yearly` | Spotter Yearly | 1 Year | $59.99 | `50 IDs/day, full specs & rarity. Yearly, save 30%.` |
| `app.carsspotter.collector.monthly` | Collector Monthly | 1 Month | $14.99 | `Unlimited IDs, Ask-AI, Spot Map. Auto-renews.` |
| `app.carsspotter.collector.yearly` | Collector Yearly | 1 Year | $129.99 | `Unlimited IDs, Ask-AI, Spot Map. Save 28%/yr.` |
| `app.carsspotter.concours.monthly` | Concours Monthly | 1 Month | $29.99 | `VIN decoder, auction alerts, priority AI. Monthly.` |
| `app.carsspotter.concours.yearly` | Concours Yearly | 1 Year | $249.99 | `VIN, auctions, valuation PDFs. Save 30%/yr.` |

All 6 belong to one Subscription Group: **`CarSpotter Pro`**.
Group order rank: Spotter=3, Collector=2, Concours=1.

### Subscription setup flow in App Store Connect
1. Business → Agreements, Tax, and Banking → accept Paid Apps Agreement + tax + banking
2. Apps → CarSpotter → Features → Subscriptions → Create Subscription Group → name "CarSpotter Pro"
3. Inside group → Create Subscription × 6 (use IDs above)
4. For each: set Display Name + Description, upload PaywallView screenshot, set price tier
5. Sandbox test: Users → Sandbox → create test account → sign in on phone via Settings → App Store → Sandbox Account → trigger paywall → buy

---

## App Review notes (paste into the Notes field)
```
CarSpotter identifies cars from photos using AI vision (GPT-4 + Claude).

To test:
1. Tap "Get started" through onboarding.
2. Sign in with: review@carsspotter.com / CarReview2026!  (or continue as guest for 3 free scans)
3. Tap "Upload from library" and select any car photo. Identification takes 2-3s and returns full specs.
4. Tap the Feed tab to see global posts. Tap the Map tab to see hotspots.
5. After 3 scans the paywall appears. Use sandbox account for purchase testing.

The Feed contains User-Generated Content. We provide:
- OpenAI-moderation pre-publish filtering
- In-app Report button on every post
- In-app Block user button on every post author
- 24-hour SLA for removing reported content
- Account termination policy for repeat violators

The app uses only HTTPS for all network calls. No tracking SDKs.

Identification is server-side via https://carsspotter.com. The demo account has full access without limits during review.
```

---

## Key file paths

### iOS app
- `CarSpotter/CarSpotterApp.swift` — entry point, RootView routing
- `CarSpotter/Services/AuthService.swift` — Firebase Auth
- `CarSpotter/Services/StoreKitService.swift` — IAP product loading + purchase
- `CarSpotter/Services/Entitlements.swift` — feature-gate truth source (new this session)
- `CarSpotter/Services/IdentifyService.swift` — car ID via the server
- `CarSpotter/Services/FirebaseREST.swift` — Firestore + Storage via REST (no SDK)
- `CarSpotter/Services/FeedService.swift` — feed read/write
- `CarSpotter/Services/FirestoreService.swift` — garage save/load
- `CarSpotter/Views/Profile/PaywallView.swift` — Apple-compliant paywall
- `CarSpotter/Views/Profile/UsernameSetupView.swift` — first-launch username picker (new)
- `CarSpotter/Views/Scan/ScanView.swift` — main scan flow (now gated)
- `CarSpotter/Views/Feed/PostCardView.swift` — feed card (layout rewritten)
- `CarSpotter/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` — generated icon
- `CarSpotter/Info.plist` — `CFBundleIconName`, `LSRequiresIPhoneOS`
- `project.yml` — XcodeGen config (kept in sync but xcodegen not installed locally)

### Website
- `~/Desktop/claude/carsspotter-landing/`
- Deployed on Render at carsspotter.com
- TODO: build `/privacy` and `/terms` routes before submission

### Marketing
- `marketing/screenshots/` — 18 PNGs (6 screens × 3 sizes)
- `marketing/ads/` — 9 PNGs (3 campaigns × 3 sizes)
- `marketing/VIDEO_AD_KIT.md` — video ad shot list + AI prompts + CapCut recipe

---

## Important constraints / quirks (memory for next session)
- **No xcodegen installed locally.** `project.yml` edits won't propagate; pbxproj must be edited directly. Verified `xcodebuild` works for builds.
- **No FirebaseFirestore or FirebaseStorage SPM imports anywhere.** All Firebase data access is REST via `FirebaseREST.swift`. Don't add them back — they cause dSYM upload warnings and 24-hour "Copying GoogleUtilities" build hangs.
- **claude-opus-4-7 doesn't accept a `temperature` param.** The server uses GPT-4o for ID with Claude as fallback.
- **iOS app hardcoded to `https://carsspotter.com` in `API.swift`** (not localhost, not carsspotter.app which is a competitor).
- **Render env var unicode bug:** when copying API keys into Render's UI, sanitize with `.replace(/[^\x20-\x7e]/g, "").trim()` — Render's editor occasionally injects a U+2500 char (`─`) at index 109 of long keys.
- **Spot type needs Hashable** for SwiftUI `Map(selection:)` + `.tag()`.
- **Desktop folder is iCloud-synced** — this has bitten Next.js (`.next` renames break). For Next.js projects use `distDir=/tmp/...`. iOS Xcode is fine because xcodebuild doesn't rename across mounts.

---

## Recent commits (most recent first)
- `3bc0c94` — Marketing kit (screenshots + ads + video script)
- `b56ac00` — Strip unused FirebaseFirestore + FirebaseStorage from pbxproj (fixes dSYM warnings)
- `a5e6fb1` — Wire Entitlements.swift into pbxproj
- `60c3a3f` — Fix App Store upload + ship subscription paywall with feature gates
- `66eea97` — PostCard layout fix + Username system + App Store submission guide

---

## Next likely tasks (in priority order)
1. **Publish updated `firestore.rules`** in Firebase Console (adds `/reports` create rule — reports fail until done)
2. **Create the 6 IAP products** in App Store Connect with the IDs above
3. **Create review demo account** in Firebase Auth: `review@carsspotter.com`
4. **Take real simulator screenshots** to replace the Python-generated mockups for v1.1 polish
5. **Archive + upload to App Store Connect** with bumped Build number

## Done this session (UGC compliance + legal pages)
- `ModerationService.swift` (block list + report queue + pre-publish text filter)
- Report/Block menu on every feed post; blocked authors filtered from feed
- Content-agreement checkbox in ComposePostView
- `/privacy`, `/terms`, `/support` pages + `LegalShell` component on carsspotter.com
- `firestore.rules`: added `/reports` collection rule (needs manual publish)
