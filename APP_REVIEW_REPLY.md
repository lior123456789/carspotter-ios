# CarSpotter — App Review reply (Guideline 2.1, Information Needed)

This rejection is a **metadata / information** request, not a code bug. The binary is
fine. You do **not** need a new build. Do these three things in App Store Connect, then
resubmit for review:

---

## STEP 1 — Add the demo account (this was the blocker)

The reviewer's automated pass stopped because no demo account was provided.
The account now EXISTS in Firebase Auth (created and verified working):

In **App Store Connect → your app → the version → App Review Information**:

- Check **Sign-in required** ✅
- **User name:** `review@carsspotter.com`
- **Password:** `CarReview2026!`

(Firebase uid `UT74UsYX6VMRca7KCeXqolfpcBF3`, project `carspotter-c0863`. It has full,
unlimited access for review — no scan limit, all tiers unlocked behavior.)

---

## STEP 2 — Paste this into the Notes field (App Review Information)

> CarSpotter identifies cars from photos using AI vision. Below is everything requested.
>
> DEMO ACCOUNT (sign-in required)
> Email: review@carsspotter.com
> Password: CarReview2026!
> This account has full, unlimited access for review (no scan limits, all features on).
> You may also tap "Continue as guest" for 3 free scans without an account.
>
> 1) SCREEN RECORDING — attached. Recorded on a physical iPhone running the latest iOS.
> It launches the app and shows: onboarding → sign-in → username setup → identifying a
> car from the photo library (full specs returned in ~2s) → saving to Garage → the social
> Feed including the Report-post and Block-user controls → the Spot Map → the subscription
> paywall with prices, Terms, and Privacy links → account sign-out.
>
> 2) DEVICES & OS TESTED BEFORE SUBMISSION:
> - iPhone 15 Pro — iOS 18
> - iPhone 13 — iOS 18
> - iPhone SE (3rd gen) — iOS 17
> (Update these to the exact devices/OS you actually tested on.)
>
> 3) PURPOSE & TARGET AUDIENCE:
> CarSpotter is an AI car-identification app for car enthusiasts and the casually curious.
> Point your camera (or pick a photo) at any car and in ~2 seconds it returns make, model,
> year, MSRP, current market value, a 1-10 rarity score, and trivia. It solves the "what
> car is that?" problem instantly, replaces forum-digging and guesswork, and lets users
> build a personal Garage of their spots and share them to a global Feed and map.
>
> 4) HOW TO ACCESS THE MAIN FEATURES:
> a. Launch the app, tap through onboarding.
> b. Sign in with review@carsspotter.com / CarReview2026! (or "Continue as guest").
> c. Pick a username when prompted.
> d. On the Scan tab, tap "Upload from library" and choose any car photo. Identification
>    takes ~2-3s and returns full specs. (Camera also works on a physical device.)
> e. Identified cars auto-save to the Garage tab.
> f. Feed tab = global user posts. The "…" menu on any post you did not author shows
>    "Report post" and "Block user". Composing a post requires agreeing to the Community
>    Guidelines and runs pre-publish content moderation.
> g. Map tab = worldwide spotting hotspots.
> h. After 3 scans (guest only) the subscription paywall appears, showing each plan's
>    title, length, and price with Terms of Use and Privacy Policy links.
>
> 5) EXTERNAL SERVICES USED FOR CORE FUNCTIONALITY:
> - Google Firebase — authentication, Firestore database, and image storage (HTTPS only).
> - OpenAI (GPT-4o vision) — primary car identification + content moderation on Feed posts.
> - Anthropic (Claude vision) — fallback/ensemble car identification.
> - Apple In-App Purchase / StoreKit — auto-renewable subscriptions.
> No third-party advertising or tracking SDKs are used.
>
> 6) REGIONAL DIFFERENCES:
> None. The app functions consistently across all regions. Identification is server-side
> and language-agnostic; there is no region-locked content. Subscription prices are set by
> Apple's standard regional tiers.
>
> 7) REGULATED INDUSTRY / THIRD-PARTY MATERIAL:
> Not applicable. CarSpotter does not operate in a regulated industry and does not host
> protected third-party material. Car data is AI-generated estimates; the app displays a
> notice that identifications are best-effort and not for purchase/valuation decisions.
>
> USER-GENERATED CONTENT (Guideline 1.2) is fully handled:
> - Pre-publish moderation on every post (OpenAI moderation + an on-device text filter).
> - In-app "Report post" on every post (24-hour review SLA).
> - In-app "Block user" on every post author.
> - A Community Guidelines agreement gate before posting.
> - Account termination policy for repeat violators (stated in the Terms of Use).
> Terms: https://carsspotter.com/terms  ·  Privacy: https://carsspotter.com/privacy
>
> All network calls use HTTPS. Support: https://carsspotter.com/support

---

## STEP 3 — Record the screen capture (only you can do this)

On a physical iPhone (latest iOS): Settings → Control Center → add Screen Recording.
Record this exact flow, start to finish, in one take:

1. Launch the app from the home screen (start recording BEFORE tapping the icon).
2. Tap through onboarding.
3. Sign in with review@carsspotter.com / CarReview2026!.
4. Pick a username.
5. Scan tab → "Upload from library" → pick a car photo → show the full result screen.
6. Show the car saved in the Garage tab.
7. Feed tab → open the "…" menu on a post → show "Report post" and "Block user".
8. Map tab → show hotspots.
9. Open the subscription paywall → show plan prices + Terms/Privacy links (don't buy).
10. Sign out (Profile/Settings).

Keep it under ~2 minutes. Upload it as an attachment when you reply in Resolution Center.

---

## Then: reply to the message in Resolution Center and resubmit for review.

No new build needed — this is a metadata fix. Average turnaround after resubmitting a
2.1 info reply is ~24h.
