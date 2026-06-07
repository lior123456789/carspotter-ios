import { AbsoluteFill, Audio, Sequence, staticFile, useCurrentFrame } from 'remotion'
import { fadeInOut, slideUp, scaleIn } from './lib/anim'
import { Bg, Wordmark, Chip, PANEL, LINE, CYAN, VIOLET, MUTE, BRAND_GRAD } from './lib/brand'

// CarSpotter explainer — what it is, features, pricing. 17s = 510 frames @ 30fps.

function Intro() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 0, 90, 8, 10)
  const sc = scaleIn(frame, 0, 20, 0.85)
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity, padding: 80 }}>
      <div style={{ transform: `scale(${sc})`, textAlign: 'center' }}>
        <Wordmark size={70} />
        <div style={{ marginTop: 36, fontSize: 56, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em', lineHeight: 1.1 }}>
          The app that knows
        </div>
        <div style={{ fontSize: 56, fontWeight: 800, backgroundImage: BRAND_GRAD, WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent', letterSpacing: '-0.02em' }}>
          every car.
        </div>
      </div>
    </AbsoluteFill>
  )
}

const FEATURES: [string, string, string][] = [
  ['camera', 'Snap any car', 'Make, model, year, value + rarity in 2 seconds'],
  ['garage', 'Build your Garage', 'Every car you ID, saved & synced'],
  ['feed', 'Global feed + map', "See what's being spotted worldwide"],
  ['decoder', 'VIN + plate decoder', 'Full specs from a plate or VIN'],
  ['ai', 'Ask the AI', 'Chat with a car expert about any car'],
]

function Features() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 90, 330, 10, 10)
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity, padding: 70 }}>
      <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 18 }}>
        {FEATURES.map((f, i) => {
          const start = 100 + i * 38
          const y = slideUp(frame, start, 16, 50)
          const o = fadeInOut(frame, start, 330, 16, 10)
          return (
            <div key={f[1]} style={{ display: 'flex', alignItems: 'center', gap: 20, opacity: o, transform: `translateY(${y}px)`, background: PANEL, border: `2px solid ${LINE}`, borderRadius: 24, padding: '22px 26px' }}>
              <div style={{ width: 60, height: 60, borderRadius: 16, background: 'rgba(34,211,238,0.12)', border: `1px solid ${CYAN}55`, display: 'grid', placeItems: 'center', flexShrink: 0 }}>
                <Glyph kind={f[0]} />
              </div>
              <div>
                <div style={{ fontSize: 34, fontWeight: 800, color: '#fff', letterSpacing: '-0.01em' }}>{f[1]}</div>
                <div style={{ fontSize: 24, color: MUTE, fontWeight: 600, marginTop: 2 }}>{f[2]}</div>
              </div>
            </div>
          )
        })}
      </div>
    </AbsoluteFill>
  )
}

function Glyph({ kind }: { kind: string }) {
  const c = CYAN
  if (kind === 'camera') return <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2"><circle cx="12" cy="13" r="4" /><path d="M3 8h3l2-3h8l2 3h3v11H3z" /></svg>
  if (kind === 'garage') return <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2"><path d="M3 11l9-6 9 6v9H3z" /><path d="M7 20v-5h10v5" /></svg>
  if (kind === 'feed') return <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2"><circle cx="12" cy="10" r="7" /><path d="M5 21c1.5-3 4-5 7-5s5.5 2 7 5" /></svg>
  if (kind === 'decoder') return <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2"><rect x="3" y="6" width="18" height="12" rx="2" /><path d="M7 10v4M11 10v4M15 10v4M18 10v4" /></svg>
  return <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2"><path d="M12 3l2 5 5 2-5 2-2 5-2-5-5-2 5-2z" /></svg>
}

function Pricing() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 330, 440, 12, 10)
  const tiers: [string, string, string][] = [
    ['Spotter', '$6.99/mo', '50 IDs/day · full specs'],
    ['Collector', '$14.99/mo', 'Unlimited · AI chat · map'],
    ['Concours', '$29.99/mo', 'VIN/plate decoder · pro'],
  ]
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity, padding: 70 }}>
      <Chip label="★ Free to start — 3 scans" color={CYAN} />
      <div style={{ width: '100%', marginTop: 28, display: 'flex', flexDirection: 'column', gap: 14 }}>
        {tiers.map((t, i) => {
          const y = slideUp(frame, 340 + i * 16, 16, 40)
          return (
            <div key={t[0]} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', transform: `translateY(${y}px)`, background: PANEL, border: `2px solid ${i === 1 ? CYAN + '66' : LINE}`, borderRadius: 22, padding: '20px 26px' }}>
              <div>
                <div style={{ fontSize: 34, fontWeight: 800, color: '#fff' }}>{t[0]}</div>
                <div style={{ fontSize: 22, color: MUTE, fontWeight: 600 }}>{t[2]}</div>
              </div>
              <div style={{ fontSize: 32, fontWeight: 800, backgroundImage: BRAND_GRAD, WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent' }}>{t[1]}</div>
            </div>
          )
        })}
      </div>
    </AbsoluteFill>
  )
}

function CTA() {
  const frame = useCurrentFrame()
  const opacity = fadeInOut(frame, 440, 510, 12, 16)
  const y = slideUp(frame, 440, 18, 44)
  return (
    <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center', opacity }}>
      <div style={{ transform: `translateY(${y}px)`, textAlign: 'center' }}>
        <Wordmark size={74} />
        <div style={{ marginTop: 40, fontSize: 52, fontWeight: 800, color: '#fff' }}>Snap any car.</div>
        <div style={{ fontSize: 52, fontWeight: 800, backgroundImage: BRAND_GRAD, WebkitBackgroundClip: 'text', backgroundClip: 'text', color: 'transparent' }}>Know everything.</div>
        <div style={{ marginTop: 40, display: 'inline-block', padding: '20px 46px', borderRadius: 999, background: BRAND_GRAD, color: '#05050B', fontWeight: 800, fontSize: 38, boxShadow: '0 14px 50px rgba(34,211,238,0.4)' }}>
          Free on the App Store
        </div>
      </div>
    </AbsoluteFill>
  )
}

export const ExplainerSpot: React.FC = () => (
  <AbsoluteFill>
    <Audio src={staticFile('audio/house.m4a')} volume={0.7} />
    <Bg />
    <Sequence from={0}><Intro /></Sequence>
    <Sequence from={0}><Features /></Sequence>
    <Sequence from={0}><Pricing /></Sequence>
    <Sequence from={0}><CTA /></Sequence>
  </AbsoluteFill>
)
