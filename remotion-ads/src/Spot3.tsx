import { AbsoluteFill, Sequence, interpolate, useCurrentFrame } from 'remotion'
import { fadeInOut, slideUp, scaleIn } from './lib/anim'
import { Bg, MUTE, CYAN, VIOLET, BRAND_GRAD } from './lib/brand'

// Spot3 — NIGHT DRIVE game promo. 11s = 330 frames @ 30fps.

// 0–4s: the flex
function Intro() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 0, 120, 10, 12)
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity, padding: 80 }}>
      <div style={{ fontSize: 58, fontWeight: 800, color: '#fff', textAlign: 'center', letterSpacing: '-0.02em', lineHeight: 1.1 }}>
        we built a <span style={{ color: CYAN }}>game</span>
      </div>
      <div style={{ fontSize: 58, fontWeight: 800, color: '#fff', textAlign: 'center', letterSpacing: '-0.02em', lineHeight: 1.1 }}>
        while making a car app
      </div>
      <div style={{ marginTop: 36, fontSize: 40, color: MUTE, fontWeight: 700 }}>🏎️💨 no download. just vibes.</div>
    </AbsoluteFill>
  )
}

// 4–8s: the title reveal
function Title() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 120, 240, 12, 10)
  const sc = scaleIn(frame, 120, 20, 0.8)
  const glow = 30 + Math.sin(frame / 6) * 14
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity }}>
      <div style={{ transform: `scale(${sc})`, textAlign: 'center' }}>
        <div style={{ fontSize: 150, fontWeight: 900, color: '#fff', letterSpacing: '-0.04em', lineHeight: 0.9, textShadow: `0 0 ${glow}px ${CYAN}` }}>NIGHT</div>
        <div style={{ fontSize: 150, fontWeight: 900, backgroundImage: BRAND_GRAD, WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent', letterSpacing: '-0.04em', lineHeight: 0.95 }}>DRIVE</div>
      </div>
      <div style={{ marginTop: 44, display: 'flex', gap: 18 }}>
        {['synthwave', 'endless', 'free'].map((t) => (
          <div key={t} style={{ padding: '12px 26px', borderRadius: 999, fontSize: 30, fontWeight: 700, color: VIOLET, border: `2px solid ${VIOLET}55`, background: 'rgba(168,85,247,0.08)' }}>{t}</div>
        ))}
      </div>
    </AbsoluteFill>
  )
}

// 8–11s: CTA url
function CTA() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 240, 330, 12, 14)
  const y = slideUp(frame, 240, 20, 50)
  const carX = interpolate(frame, [240, 330], [-40, 40], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' })
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity }}>
      <div style={{ transform: `translateY(${y}px)`, textAlign: 'center' }}>
        <div style={{ fontSize: 52, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em' }}>Beat my score 👇</div>
        <div style={{ marginTop: 36, transform: `translateX(${carX}px)`, fontSize: 90 }}>🏎️</div>
        <div style={{ marginTop: 28, display: 'inline-block', padding: '22px 46px', borderRadius: 999, background: BRAND_GRAD, color: '#05050B', fontWeight: 800, fontSize: 44, boxShadow: `0 14px 50px rgba(34,211,238,0.4)` }}>
          carsspotter.com/drive
        </div>
        <div style={{ marginTop: 32, fontSize: 32, color: MUTE, fontWeight: 700 }}>and grab the app while you&rsquo;re there</div>
      </div>
    </AbsoluteFill>
  )
}

export const Spot3: React.FC = () => (
  <AbsoluteFill>
    <Bg />
    <Sequence from={0}><Intro /></Sequence>
    <Sequence from={0}><Title /></Sequence>
    <Sequence from={0}><CTA /></Sequence>
  </AbsoluteFill>
)
