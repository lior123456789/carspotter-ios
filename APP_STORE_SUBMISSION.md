# App Store Submission Checklist — CarSpotter

Full step-by-step from "the app builds in Xcode" to "live on the App Store."
Realistic timeline: **3–7 days** total (mostly waiting on Apple Review).

---

## Phase 0 — Apple Developer enrollment ($99/yr)

If you don't have a paid Apple Developer account yet:

1. https://developer.apple.com/programs/enroll/
2. Sign in with your Apple ID → enroll as Individual (or Company)
3. Pay $99 → activation usually ~24h, sometimes instant
4. Once active, you get access to App Store Connect + can ship apps

---

## Phase 1 — Asset prep (1 hour)

### 1.1 App Icon (1024×1024)

Apple requires a 1024×1024 PNG with no transparency. Drop it into:

```
CarSpotter/Resources/Assets.xcassets/AppIcon.appiconset/
```

Recommended design: gradient cyan→violet rounded square with the camera-target glyph (matches the brand). Use Figma/Photoshop/even Pages to generate. **No text overlay** (Apple rejects icons with words).

### 1.2 Screenshots (required sizes)

Apple requires at least one set. Take these inside Xcode's simulator:
- **6.9" iPhone (iPhone 16 Pro Max)** — 1320×2868
- **6.5" iPhone (iPhone 15 Pro Max)** — 1290×2796
- **5.5" iPhone** (optional, for older device support)

Recommended set (5 screenshots, in order):
1. **Onboarding slide 1** — "Snap any car"
2. **Scan in progress** — circular progress with "Cross-referencing 500k models…"
3. **Result card** — Porsche 911 with full spec grid
4. **Feed** — community spots with locations
5. **Map** — global spot map with pins

Tip: use the simulator's `Device → Screenshot` (⌘S) to capture. Save at native resolution.

### 1.3 App preview video (optional but boosts conversion ~25%)

15–30 seconds, .mov or .mp4. Run through the core loop: open → scan → identify → save. Apple's Reality Composer Pro or even iPhone screen recording works.

---

## Phase 2 — App Store Connect setup (20 minutes)

1. https://appstoreconnect.apple.com → **My Apps** → **+** → **New App**
2. Fill in:
   - **Platform**: iOS
   - **Name**: `CarSpotter`
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: `app.carsspotter` (pick from dropdown — must be registered first)
   - **SKU**: `carspotter-ios-001`
   - **User Access**: Full Access

If the Bundle ID isn't in the dropdown, register it first:
- https://developer.apple.com/account/resources/identifiers/list
- **+** → **App IDs** → **App** → Description: `CarSpotter`, Bundle ID: explicit `app.carsspotter`
- Enable Capabilities: **Sign in with Apple** (if you re-add it), **Push Notifications** (later)
- Register

### 2.1 App Information

Under **App Information**:
- **Category**: Lifestyle (primary), Reference (secondary)
- **Content Rights**: ✅ "I do not own or have rights to use third-party content"

Under **Pricing and Availability**:
- **Price**: Free (the in-app subscriptions handle revenue)
- **Available in all territories**

### 2.2 App Privacy

Under **App Privacy** → **Get Started** → answer:
- **Do you collect data?** Yes
- For each data type, mark **Used** (Auth/Functionality + Analytics):
  - **Email Address** → Sign-in
  - **User ID** (Firebase UID) → Sign-in + Functionality
  - **Photos** → App Functionality (cars they scan)
  - **Coarse Location** (if/when added) → App Functionality
- **Are you tracking users across other apps/websites?** No

### 2.3 Privacy Policy URL

You need a public privacy policy. Copy this template, customize, and host it:

```
https://carsspotter.com/privacy
```

(I can scaffold this as a `/privacy` route on the website if you want — say the word.)

---

## Phase 3 — In-App Purchases (10 minutes)

In App Store Connect → **In-App Purchases** → **+** → **Auto-Renewable Subscription**.

Create a **Subscription Group**: `CarSpotter Plus`.

Then add 6 subscriptions matching `StoreKitService.productIDs`:

| Product ID | Display Name | Duration | Price |
| --- | --- | --- | --- |
| `app.carsspotter.spotter.monthly`   | Spotter (Monthly)   | 1 month | $6.99 |
| `app.carsspotter.spotter.yearly`    | Spotter (Yearly)    | 1 year  | $59.00 |
| `app.carsspotter.collector.monthly` | Collector (Monthly) | 1 month | $14.99 |
| `app.carsspotter.collector.yearly`  | Collector (Yearly)  | 1 year  | $129.00 |
| `app.carsspotter.concours.monthly`  | Concours (Monthly)  | 1 month | $29.99 |
| `app.carsspotter.concours.yearly`   | Concours (Yearly)   | 1 year  | $249.00 |

For each: add a localized name + description, screenshot of the paywall, and set "Ready to Submit."

---

## Phase 4 — Upload the build (30 minutes)

### 4.1 Increment version + bundle (every submission)

In `project.yml` → `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`:

```yaml
MARKETING_VERSION: "1.0.0"
CURRENT_PROJECT_VERSION: "1"
```

For each new build to TestFlight, bump `CURRENT_PROJECT_VERSION` (1 → 2 → 3...).

### 4.2 Archive in Xcode

1. In Xcode top bar, choose destination **Any iOS Device (arm64)** (not a simulator!)
2. **Product → Archive** (⌘B if grayed out, try Clean Build Folder first)
3. Wait ~3-5 min for the archive
4. Organizer window opens automatically when done

### 4.3 Distribute App

In Organizer:
1. Select the new archive → **Distribute App**
2. **App Store Connect** → Next
3. **Upload** → Next
4. **Automatically manage signing** → Next
5. Review summary → **Upload**
6. Wait ~10 min for processing + email from Apple

### 4.4 Submit for Review

Back in App Store Connect:
1. Your app → top section, click **Submit for Review**
2. **+ Version or Platform** → iOS → Version: 1.0
3. Fill in **What's New in This Version** for the first submission: "Initial release"
4. Under **Build**, click **+** → select the build you just uploaded (it'll appear ~10 min after upload)
5. Save → **Add for Review** → **Submit for Review**

---

## Phase 5 — Apple Review (1–7 days)

Most apps get reviewed in 24–48 hours. CarSpotter risks:

- **AI identification accuracy** — Apple sometimes asks to demo. Make sure GPT-4o is reliably working before submitting.
- **User-generated content (feed)** — Apple requires:
  - Block / report functionality (add a "Report post" menu item — todo)
  - Terms of service that prohibit objectionable content
  - Filter mechanism for inappropriate posts (currently none — add before Review or expect rejection)
- **Subscription terms** — link to Apple's standard EULA + your terms

If rejected, you get a Resolution Center message. Fix → resubmit (no charge for resubmissions).

---

## Phase 6 — Going live

Once approved:
- **Manual release**: you click "Release this version" in App Store Connect
- **Automatic release**: live globally the moment review approves

After live:
- Marketing: push to social, ProductHunt, Hacker News, car enthusiast subreddits (r/cars, r/Porsche, r/JDM, etc.)
- Set up App Store Connect Analytics + Sales reports
- Respond to reviews within 48h (Apple highlights apps that engage)

---

## Quick checklist before you submit

- [ ] Apple Developer Program enrolled + active
- [ ] App icon 1024×1024 in `AppIcon.appiconset/`
- [ ] 5 screenshots for at least the 6.9" iPhone size
- [ ] Privacy policy published at a public URL
- [ ] App Store Connect app record created
- [ ] All 6 in-app subscriptions created in App Store Connect, marked "Ready to Submit"
- [ ] Bundle version `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` set
- [ ] Archive uploaded via Xcode → appears in App Store Connect → selected
- [ ] "Submit for Review" clicked

---

## Want me to help with any of these?

I can scaffold:
- `/privacy` and `/terms` routes on the website (full legal text)
- "Report post" + block-user UI on the feed (Apple requires it)
- Higher-res App Icon (just describe what you want)
- App Store screenshot mockups in Figma-style

Tell me which and I'll ship it.
