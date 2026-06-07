import { AbsoluteFill, Sequence, interpolate, useCurrentFrame } from 'remotion'
import { fadeInOut, slideUp, scaleIn } from './lib/anim'
import { Bg, Wordmark, Chip, MUTE, CYAN, VIOLET, BRAND_GRAD } from './lib/brand'

// Spot2 — "Guess the price". 12s = 360 frames @ 30fps.

// 0–4s: the challenge
function Guess() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 0, 120, 10, 12)
  const pulse = 1 + Math.sin(frame / 7) * 0.04
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity, padding: 80 }}>
      <div style={{ fontSize: 56, fontWeight: 800, color: '#fff', textAlign: 'center', letterSpacing: '-0.02em' }}>Guess how much</div>
      <div style={{ fontSize: 56, fontWeight: 800, color: '#fff', textAlign: 'center', letterSpacing: '-0.02em', marginBottom: 40 }}>this costs today 👇</div>
      <div style={{ marginBottom: 32 }}>
        <Chip label="JDM Legend · 1994" color={VIOLET} bg="rgba(168,85,247,0.10)" />
      </div>
      <div style={{ fontSize: 92, fontWeight: 800, color: '#fff', letterSpacing: '-0.03em', textAlign: 'center', lineHeight: 1 }}>Toyota Supra</div>
      <div style={{ fontSize: 44, color: MUTE, fontWeight: 700, marginTop: 16 }}>Mk IV Twin-Turbo</div>
      <div style={{ marginTop: 50, fontSize: 200, fontWeight: 900, backgroundImage: BRAND_GRAD, WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent', transform: `scale(${pulse})` }}>?</div>
    </AbsoluteFill>
  )
}

// 4–8s: the reveal
function Reveal() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 120, 250, 10, 10)
  const sc = scaleIn(frame, 120, 18, 0.8)
  const val = Math.round(interpolate(frame, [128, 188], [0, 182], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }))
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity }}>
      <div style={{ fontSize: 40, color: MUTE, fontWeight: 700, letterSpacing: '0.2em', marginBottom: 12 }}>TODAY&rsquo;S VALUE</div>
      <div style={{ fontSize: 180, fontWeight: 900, backgroundImage: BRAND_GRAD, WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent', transform: `scale(${sc})`, letterSpacing: '-0.03em' }}>
        ${val}K
      </div>
      <div style={{ marginTop: 24, display: 'flex', gap: 16 }}>
        <Chip label="★ Rarity 8/10" color={VIOLET} bg="rgba(168,85,247,0.10)" />
        <Chip label="↑ 240% since 2015" />
      </div>
      <div style={{ marginTop: 44, fontSize: 46, color: '#fff', fontWeight: 700 }}>were you close? 😅</div>
    </AbsoluteFill>
  )
}

// 8–12s: CTA
function CTA() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 250, 360, 12, 14)
  const y = slideUp(frame, 250, 20, 50)
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity }}>
      <div style={{ transform: `translateY(${y}px)`, textAlign: 'center' }}>
        <Wordmark size={72} />
        <div style={{ marginTop: 40, fontSize: 50, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em' }}>Know any car&rsquo;s value</div>
        <div style={{ fontSize: 50, fontWeight: 800, backgroundImage: BRAND_GRAD, WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent' }}>in 2 seconds.</div>
        <div style={{ marginTop: 44, display: 'inline-block', padding: '20px 44px', borderRadius: 999, background: BRAND_GRAD, color: '#05050B', fontWeight: 800, fontSize: 38, boxShadow: `0 14px 50px rgba(34,211,238,0.4)` }}>
          Free on the App Store
        </div>
      </div>
    </AbsoluteFill>
  )
}

export const Spot2: React.FC = () => (
  <AbsoluteFill>
    <Bg />
    <Sequence from={0}><Guess /></Sequence>
    <Sequence from={0}><Reveal /></Sequence>
    <Sequence from={0}><CTA /></Sequence>
  </AbsoluteFill>
)
