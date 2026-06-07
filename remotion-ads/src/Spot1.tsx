import { AbsoluteFill, Sequence, interpolate, useCurrentFrame, useVideoConfig } from 'remotion'
import { fadeInOut, slideUp, scaleIn, typedChars, progress } from './lib/anim'
import { Bg, Wordmark, Chip, PANEL, LINE, CYAN, VIOLET, MUTE, BRAND_GRAD } from './lib/brand'

// Spot1 — "What's that car?" → scan → result card. 13s = 390 frames @ 30fps.

// 0–3s: hook typewriter
function Hook() {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()
  const text = "What's that car?"
  const chars = typedChars(frame, 8, 12, fps, text.length)
  const blink = frame % 30 < 15
  const opacity = fadeInOut(frame, 0, 90, 8, 10)
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity, padding: 80 }}>
      <div style={{ fontSize: 100, fontWeight: 800, color: '#fff', letterSpacing: '-0.03em', textAlign: 'center', lineHeight: 1.05 }}>
        {text.slice(0, chars)}
        <span style={{ color: CYAN, opacity: blink ? 1 : 0 }}>_</span>
      </div>
      <div style={{ marginTop: 28, fontSize: 34, color: MUTE, fontWeight: 600 }}>point. scan. know.</div>
    </AbsoluteFill>
  )
}

// 3–6s: scanning reticle over a car silhouette
function Scan() {
  const frame = useCurrentFrame()
  const local = frame - 90
  const opacity = fadeInOut(frame, 90, 185, 10, 10)
  const sweep = progress(frame, 100, 165)
  const bracket = interpolate(local, [0, 18], [40, 0], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' })
  const corner = (pos: React.CSSProperties): React.CSSProperties => ({
    position: 'absolute',
    width: 90,
    height: 90,
    borderColor: CYAN,
    boxShadow: `0 0 24px ${CYAN}66`,
    ...pos,
  })
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity }}>
      <div style={{ position: 'relative', width: 760, height: 520 }}>
        {/* car silhouette */}
        <svg viewBox="0 0 200 110" width="640" height="352" style={{ position: 'absolute', left: 60, top: 90, opacity: 0.92 }}>
          <path
            d="M10 78 Q14 60 34 56 L60 40 Q78 30 110 30 L150 32 Q172 36 184 56 L190 60 Q196 64 196 74 L196 82 Q196 88 188 88 L172 88 A14 14 0 0 0 144 88 L70 88 A14 14 0 0 0 42 88 L18 88 Q10 88 10 82 Z"
            fill="url(#g)" stroke={CYAN} strokeWidth="1.4"
          />
          <defs>
            <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0" stopColor="#13344a" />
              <stop offset="1" stopColor="#1b1330" />
            </linearGradient>
          </defs>
          <circle cx="56" cy="88" r="13" fill="#0a0916" stroke={CYAN} strokeWidth="1.2" />
          <circle cx="158" cy="88" r="13" fill="#0a0916" stroke={CYAN} strokeWidth="1.2" />
        </svg>
        {/* reticle corners */}
        <div style={{ ...corner({ top: -bracket, left: -bracket, borderTop: `6px solid ${CYAN}`, borderLeft: `6px solid ${CYAN}`, borderTopLeftRadius: 12 }) }} />
        <div style={{ ...corner({ top: -bracket, right: -bracket, borderTop: `6px solid ${CYAN}`, borderRight: `6px solid ${CYAN}`, borderTopRightRadius: 12 }) }} />
        <div style={{ ...corner({ bottom: -bracket, left: -bracket, borderBottom: `6px solid ${CYAN}`, borderLeft: `6px solid ${CYAN}`, borderBottomLeftRadius: 12 }) }} />
        <div style={{ ...corner({ bottom: -bracket, right: -bracket, borderBottom: `6px solid ${CYAN}`, borderRight: `6px solid ${CYAN}`, borderBottomRightRadius: 12 }) }} />
        {/* scan line */}
        <div style={{ position: 'absolute', left: 0, right: 0, top: `${sweep * 100}%`, height: 5, background: BRAND_GRAD, boxShadow: `0 0 28px ${CYAN}`, opacity: sweep > 0 && sweep < 1 ? 1 : 0 }} />
      </div>
      <div style={{ marginTop: 48, fontSize: 36, color: CYAN, fontWeight: 700, letterSpacing: '0.25em' }}>IDENTIFYING…</div>
    </AbsoluteFill>
  )
}

// 6–10s: result card
function Result() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 185, 305, 12, 10)
  const y = slideUp(frame, 185, 22, 80)
  const sc = scaleIn(frame, 185, 22, 0.92)
  // value counts up
  const lo = Math.round(interpolate(frame, [200, 250], [0, 290], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }))
  const hi = Math.round(interpolate(frame, [200, 250], [0, 360], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }))
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity }}>
      <div
        style={{
          width: 860,
          background: PANEL,
          border: `2px solid ${LINE}`,
          borderRadius: 40,
          padding: 56,
          transform: `translateY(${y}px) scale(${sc})`,
          boxShadow: `0 30px 90px rgba(0,0,0,0.6), 0 0 120px rgba(34,211,238,0.10)`,
        }}
      >
        <div style={{ display: 'flex', gap: 16, marginBottom: 28 }}>
          <Chip label="Sports Coupe" />
          <Chip label="★ Rarity 7/10" color={VIOLET} bg="rgba(168,85,247,0.10)" />
        </div>
        <div style={{ fontSize: 34, color: MUTE, fontWeight: 700 }}>2023</div>
        <div style={{ fontSize: 76, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em', lineHeight: 1.02 }}>Porsche 911</div>
        <div style={{ fontSize: 76, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em', lineHeight: 1.02, marginBottom: 28 }}>GT3 RS</div>
        <div style={{ fontSize: 30, color: MUTE, fontWeight: 700, letterSpacing: '0.16em' }}>TODAY&rsquo;S VALUE</div>
        <div style={{ fontSize: 70, fontWeight: 800, backgroundImage: BRAND_GRAD, WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent' }}>
          ${lo}K&ndash;${hi}K
        </div>
        <div style={{ height: 2, background: LINE, margin: '32px 0' }} />
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          {[['525', 'HP'], ['3.2s', '0-60'], ['296', 'TOP MPH']].map(([v, k]) => (
            <div key={k}>
              <div style={{ fontSize: 50, fontWeight: 800, color: '#fff' }}>{v}</div>
              <div style={{ fontSize: 26, color: MUTE, fontWeight: 700, letterSpacing: '0.12em' }}>{k}</div>
            </div>
          ))}
        </div>
      </div>
      <div style={{ marginTop: 40, fontSize: 40, color: '#fff', fontWeight: 700 }}>…in 2 seconds. 🤯</div>
    </AbsoluteFill>
  )
}

// 10–13s: CTA
function CTA() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 305, 390, 12, 14)
  const y = slideUp(frame, 305, 20, 50)
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity }}>
      <div style={{ transform: `translateY(${y}px)`, textAlign: 'center' }}>
        <Wordmark size={72} />
        <div style={{ marginTop: 40, fontSize: 54, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em' }}>Snap any car.</div>
        <div style={{ fontSize: 54, fontWeight: 800, backgroundImage: BRAND_GRAD, WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent' }}>Know everything.</div>
        <div style={{ marginTop: 44, display: 'inline-block', padding: '20px 44px', borderRadius: 999, background: BRAND_GRAD, color: '#05050B', fontWeight: 800, fontSize: 38, boxShadow: '0 14px 50px rgba(34,211,238,0.4)' }}>
          Free on the App Store
        </div>
      </div>
    </AbsoluteFill>
  )
}

export const Spot1: React.FC = () => (
  <AbsoluteFill>
    <Bg />
    <Sequence from={0}><Hook /></Sequence>
    <Sequence from={0}><Scan /></Sequence>
    <Sequence from={0}><Result /></Sequence>
    <Sequence from={0}><CTA /></Sequence>
  </AbsoluteFill>
)
