import './index.css'
import { Composition } from 'remotion'
import { Spot1 } from './Spot1'
import { Spot2 } from './Spot2'
import { Spot3 } from './Spot3'

// Vertical 9:16 for TikTok / Reels / Shorts.
const W = 1080
const H = 1920
const FPS = 30

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* "What's that car?" — scan → result card */}
      <Composition id="Spot1" component={Spot1} durationInFrames={13 * FPS} fps={FPS} width={W} height={H} />
      {/* "Guess the price" — reveal */}
      <Composition id="Spot2" component={Spot2} durationInFrames={12 * FPS} fps={FPS} width={W} height={H} />
      {/* Night Drive game promo */}
      <Composition id="Spot3" component={Spot3} durationInFrames={11 * FPS} fps={FPS} width={W} height={H} />
    </>
  )
}
