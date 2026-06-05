# CarSpotter — Video Ad Kit

Two ad cuts. The 15s is for TikTok / Reels / YouTube Shorts. The 30s is for
Instagram feed, X video, YouTube pre-roll. Both share footage so you only
shoot once.

---

## 15-second cut — "What's THAT car?"

| t | Frame | What happens | How to get the footage |
|---|---|---|---|
| 0.0–1.5s | Real-world | Friend points across the street: "Yo what's that?" Camera whips toward a parked exotic (911 GT3 RS / SF90 / Huracán). Slight handheld shake. | iPhone slow-mo 240fps, hold horizontal, whip-pan in. |
| 1.5–3.0s | Real-world close | Hand raises iPhone, viewfinder reticle overlays the car. Reticle snaps to corners. | Same shot, longer hold, light overlay added in CapCut. |
| 3.0–3.5s | **Transition** | Reticle white flash → screen-recording of CarSpotter scan-progress animation. | CapCut "Flash white" transition between phone footage and screen recording. |
| 3.5–6.0s | App screen | ResultCard pops in: "2023 Porsche 911 GT3 RS · $290–360k · Rarity 7/10". Numbers tick up. | Use a screen recording from the iOS simulator running CarSpotter. |
| 6.0–8.0s | Garage flick | Quick swipe through Garage view, then Feed view, then Map view (each ~0.6s). | Screen recording, edited tight. |
| 8.0–10.0s | Real-world | Cut back to the street. Friend leans in: "Damn." | Continuation of opening shot. |
| 10.0–13.0s | Logo + tagline | CarSpotter wordmark fades up over the still parked car. Tagline: **"Snap any car. Know everything."** | Add over real photo. |
| 13.0–15.0s | App Store badge | "Free on the App Store" + download badge. | Use Apple's official `app-store-badge` SVG. |

**Voiceover / on-screen text**
- 0.0s: "What's that car?"
- 3.5s: "In 2 seconds…"
- 8.0s: "You'll know."
- 13.0s: "CarSpotter. Free on the App Store."

---

## 30-second cut — Full story

Add to the 15s above between t=6s and t=8s:

| t | Frame | What happens |
|---|---|---|
| 6.0–9.0s | Multi-spot montage | 3 quick cuts of different exotic cars getting scanned: red Ferrari (Rodeo Drive), green Lamborghini (Miami at night), white McLaren (garage). |
| 9.0–14.0s | Social proof | Stack of in-app Feed posts scrolls upward, "@username · Monaco · 32s ago" — feels alive. |
| 14.0–18.0s | Paywall flash | Quick beat on Collector tier card with "Unlimited IDs · Ask the AI · global Spot Map · $14.99/mo". |
| 18.0–22.0s | Real-world | Driver pulls up to valet in a Bugatti. Bystander pulls phone. CarSpotter scan flash. ResultCard: "2025 Bugatti Tourbillon · $4.0M+ · Rarity 10/10." |
| 22.0–26.0s | Tagline | "Every car. Every spec. Every spot." |
| 26.0–30.0s | Outro + badge | CTA: "Start free." App Store badge. |

---

## Car-to-app, app-to-car transitions (the part you asked about)

These are the four that always feel cinematic and pro:

1. **White-flash flash-cut** — most reliable. Frame ends on hand-held viewfinder, single frame of full-screen white, next frame is the app's scan animation already at 50% progress. Brain reads it as "the camera fired." (CapCut: *Effects → Glitch → Flash*, duration 0.1s.)

2. **Match-cut on the reticle corners** — your AppIcon already has four viewfinder corners. Frame ends with iPhone camera UI showing yellow autofocus corners aligned to the car's headlight + grille. Next frame opens on the AppIcon's white corners in the same screen position. Eye reads it as the same shape. Hold for 0.4s. Then zoom out to the full app.

3. **Glass-morph blur transition** — last real-world frame fades into a heavy Gaussian blur (16px → 32px → 64px over 0.3s), then the app launches from blurred background, frosted glass card slides up = scan result. Polished, premium.

4. **Mask-wipe along the car silhouette** — trace the car's outline, use it as a mask, wipe from car → app. Hardest, but the most "I made an Apple ad" moment. Use After Effects or DaVinci Resolve.

---

## AI-generation prompts (paste into Runway Gen-3 / Sora / Pika 1.5)

You said you want car-to-app transitions with real-life feel. If you can't shoot real footage, generate with these:

### Runway Gen-3 / Sora — opening car shot
```
Cinematic 4K handheld shot, golden hour, valet entrance of a luxury hotel.
A bright orange McLaren 765LT slowly rolls up. Camera whips from the bystander
holding an iPhone to the car. Shallow depth of field. Lens flare. Photoreal,
85mm lens, color graded warm. 3 second clip, slight motion blur on whip pan.
```

### Runway — reticle-snap moment
```
Macro shot of an iPhone screen, the user's POV. The camera viewfinder is up,
yellow autofocus reticle corners snap precisely onto the headlight and front
grille of an exotic supercar in the background. Background is heavily out of
focus. Crisp UI overlay. 2 second clip. Photoreal, 4K.
```

### Pika 1.5 — app-to-car morph
```
A glowing cyan-to-violet rounded-square app icon dissolves and reforms into the
silhouette of a Ferrari SF90 Stradale. The four white corner brackets inside
the icon expand outward to become the car's body lines. Cinematic, dark
background, glowing edges. Smooth 24fps, 3 second clip.
```

### Sora — closing wide shot
```
Wide cinematic dusk shot in Monaco, Casino Square. Three exotic cars parked in
a row — a black Bugatti Chiron, a red Ferrari F12, a silver Pagani Huayra. A
hand raises an iPhone into frame, foreground blurred. Lights of the casino
behind. Film grain, anamorphic lens, golden hour fading to blue hour. 4 second
clip, gentle dolly forward.
```

---

## CapCut / Premiere edit recipe

1. New project, 1080×1920, 30fps.
2. Drop screen recording (iOS simulator) on **track V2**.
3. Drop b-roll (real or AI-generated) on **track V1**.
4. Music: pick a 110–120 BPM cinematic build. Royalty-free options: *Epidemic Sound — "Spectra"*, *Artlist — "Kinetic"*, or YouTube Audio Library — "Dystopia."
5. Beat-match every cut to the kick drum. Hold no shot longer than 1.6s.
6. Apply **white flash** transition (0.1s) at every car→app crossover.
7. Color grade real footage with a warm-shadow / teal-highlight LUT.
8. Add captioned text overlays — Apple system font, 1.2 line height, animate up 8px on each line.
9. End card: AppIcon center, "CarSpotter" wordmark below, App Store badge bottom.
10. Export H.264 1080p VBR 12 Mbps. For TikTok: same but bake the safe zones in (top 230px / bottom 480px of vertical).

---

## Where to place the ads

| Platform | Format | Size to use |
|---|---|---|
| Instagram feed | Image / 1:1 video | `ads/*_1080x1080_square.png`, 15s video |
| Instagram Story / Reels | Vertical 9:16 | `ads/*_1080x1920_story.png`, 15s video |
| TikTok | 9:16 video | 15s video |
| YouTube Shorts | 9:16 video | 15s video |
| YouTube pre-roll | 16:9 video | 30s video |
| X / Twitter | 16:9 image or video | `ads/*_1920x1080_landscape.png` |
| Reddit (r/cars, r/spotted, r/JDM) | 1:1 or 16:9 | `ads/*_1080x1080_square.png` |
| Facebook feed | Square | `ads/*_1080x1080_square.png` |

---

## Shot-list if you film with your own iPhone

You can shoot the entire 15s ad in 20 minutes with just your iPhone:

1. Find a parking lot with at least one cool car (any showy enthusiast meet on a Sunday morning works).
2. Shot A — wide: friend points across the lot.
3. Shot B — reaction: friend says "yo, what's that?".
4. Shot C — POV: phone rises, reticle aligns to car.
5. Shot D — screen record: open CarSpotter, snap, watch result.
6. Shot E — wide hold: car in golden-hour light.

Total assets needed: 5 clips × 3s each. CapCut handles the rest.
