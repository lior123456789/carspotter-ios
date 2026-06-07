import { AbsoluteFill, useCurrentFrame } from 'remotion'

// CarSpotter synthwave palette (matches the app + NIGHT DRIVE game).
export const INK = '#05050B'
export const PANEL = '#0E0E18'
export const LINE = '#1A1A28'
export const CYAN = '#22D3EE'
export const VIOLET = '#A855F7'
export const MUTE = '#8A8A95'
export const BRAND_GRAD = `linear-gradient(135deg, ${CYAN} 0%, ${VIOLET} 100%)`

/** Animated synthwave backdrop: deep ink, cyan/violet blooms, perspective grid, sun glow. */
export const Bg: React.FC<{ grid?: boolean }> = ({ grid = true }) => {
  const frame = useCurrentFrame()
  const drift = (frame % 180) / 180
  return (
    <AbsoluteFill style={{ background: INK }}>
      <AbsoluteFill style={{ background: `radial-gradient(ellipse 70% 50% at 50% 18%, rgba(34,211,238,0.20), transparent 70%)` }} />
      <AbsoluteFill style={{ background: `radial-gradient(ellipse 70% 50% at 50% 90%, rgba(168,85,247,0.18), transparent 70%)` }} />
      {/* sun glow near top */}
      <AbsoluteFill style={{ background: `radial-gradient(circle at 50% 30%, rgba(255,140,90,0.12), transparent 45%)` }} />
      {grid && (
        <div
          style={{
            position: 'absolute',
            left: '-20%',
            right: '-20%',
            bottom: 0,
            height: '46%',
            backgroundImage:
              'linear-gradient(rgba(34,211,238,0.35) 1px, transparent 1px), linear-gradient(90deg, rgba(34,211,238,0.18) 1px, transparent 1px)',
            backgroundSize: `100% 64px, 7% 100%`,
            backgroundPosition: `0px ${drift * 64}px, 0 0`,
            transform: 'perspective(420px) rotateX(72deg)',
            transformOrigin: 'bottom',
            maskImage: 'linear-gradient(to top, #000 10%, transparent 95%)',
            WebkitMaskImage: 'linear-gradient(to top, #000 10%, transparent 95%)',
            opacity: 0.7,
          }}
        />
      )}
      {/* vignette */}
      <AbsoluteFill style={{ boxShadow: 'inset 0 0 320px 80px rgba(0,0,0,0.65)' }} />
    </AbsoluteFill>
  )
}

/** CarSpotter wordmark with camera glyph. */
export const Wordmark: React.FC<{ size?: number }> = ({ size = 64 }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: size * 0.28 }}>
    <div
      style={{
        width: size * 1.15,
        height: size * 1.15,
        borderRadius: size * 0.32,
        background: BRAND_GRAD,
        display: 'grid',
        placeItems: 'center',
        boxShadow: `0 0 ${size * 0.6}px rgba(34,211,238,0.45)`,
      }}
    >
      <div style={{ width: size * 0.42, height: size * 0.42, borderRadius: '50%', border: `${size * 0.07}px solid #05050B` }} />
    </div>
    <div style={{ fontSize: size, fontWeight: 800, color: '#fff', letterSpacing: '-0.03em' }}>CarSpotter</div>
  </div>
)

export const Chip: React.FC<{ label: string; color?: string; bg?: string }> = ({ label, color = CYAN, bg }) => (
  <div
    style={{
      display: 'inline-flex',
      alignItems: 'center',
      padding: '12px 22px',
      borderRadius: 999,
      fontSize: 30,
      fontWeight: 700,
      color,
      letterSpacing: '0.02em',
      background: bg ?? 'rgba(34,211,238,0.10)',
      border: `2px solid ${color}55`,
    }}
  >
    {label}
  </div>
)
