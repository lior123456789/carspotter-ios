import './index.css'
import { Composition } from 'remotion'
import { Spot1 } from './Spot1'
import { Spot2 } from './Spot2'
import { Spot3 } from './Spot3'
import { ScanSpot, type ScanSpotProps } from './ScanSpot'
import { ExplainerSpot } from './ExplainerSpot'

// Vertical 9:16 for TikTok / Reels / Shorts.
const W = 1080
const H = 1920
const FPS = 30

const CARS: Record<string, ScanSpotProps> = {
  Huracan: { category: 'Supercar', rarity: 8, year: '2022', make: 'Lamborghini', model: 'Huracán', valueLo: 230, valueHi: 290, stats: [['631', 'HP'], ['2.9s', '0-60'], ['202', 'TOP MPH']] },
  Ferrari: { category: 'Supercar', rarity: 8, year: '2019', make: 'Ferrari', model: '488 GTB', valueLo: 250, valueHi: 310, stats: [['661', 'HP'], ['3.0s', '0-60'], ['205', 'TOP MPH']] },
  GTR:     { category: 'JDM Icon', rarity: 7, year: '2021', make: 'Nissan', model: 'GT-R', valueLo: 110, valueHi: 140, stats: [['565', 'HP'], ['2.9s', '0-60'], ['196', 'TOP MPH']] },
  McLaren: { category: 'Supercar', rarity: 8, year: '2020', make: 'McLaren', model: '720S', valueLo: 230, valueHi: 300, stats: [['710', 'HP'], ['2.8s', '0-60'], ['212', 'TOP MPH']] },
  Bugatti:  { category: 'Hypercar', rarity: 10, year: '2021', make: 'Bugatti', model: 'Chiron', valueLo: 3000, valueHi: 3500, stats: [['1479', 'HP'], ['2.4s', '0-60'], ['261', 'TOP MPH']] },
  Aston:    { category: 'Grand Tourer', rarity: 7, year: '2020', make: 'Aston Martin', model: 'DB11', valueLo: 140, valueHi: 180, stats: [['528', 'HP'], ['3.7s', '0-60'], ['200', 'TOP MPH']] },
  Corvette: { category: 'Sports Car', rarity: 6, year: '2023', make: 'Chevrolet', model: 'Corvette', valueLo: 70, valueHi: 95, stats: [['490', 'HP'], ['2.9s', '0-60'], ['194', 'TOP MPH']] },
  Rolls:    { category: 'Ultra Luxury', rarity: 8, year: '2022', make: 'Rolls-Royce', model: 'Ghost', valueLo: 340, valueHi: 400, stats: [['563', 'HP'], ['4.6s', '0-60'], ['155', 'TOP MPH']] },
}

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition id="Spot1" component={Spot1} durationInFrames={13 * FPS} fps={FPS} width={W} height={H} />
      <Composition id="Spot2" component={Spot2} durationInFrames={12 * FPS} fps={FPS} width={W} height={H} />
      <Composition id="Spot3" component={Spot3} durationInFrames={11 * FPS} fps={FPS} width={W} height={H} />
      {/* New "what's that car?" spots with house music — different exotic each */}
      <Composition id="Car1" component={ScanSpot} durationInFrames={13 * FPS} fps={FPS} width={W} height={H} defaultProps={CARS.Huracan} />
      <Composition id="Car2" component={ScanSpot} durationInFrames={13 * FPS} fps={FPS} width={W} height={H} defaultProps={CARS.Ferrari} />
      <Composition id="Car3" component={ScanSpot} durationInFrames={13 * FPS} fps={FPS} width={W} height={H} defaultProps={CARS.GTR} />
      <Composition id="Car4" component={ScanSpot} durationInFrames={13 * FPS} fps={FPS} width={W} height={H} defaultProps={CARS.McLaren} />
      <Composition id="Car5" component={ScanSpot} durationInFrames={13 * FPS} fps={FPS} width={W} height={H} defaultProps={CARS.Bugatti} />
      <Composition id="Car6" component={ScanSpot} durationInFrames={13 * FPS} fps={FPS} width={W} height={H} defaultProps={CARS.Aston} />
      <Composition id="Car7" component={ScanSpot} durationInFrames={13 * FPS} fps={FPS} width={W} height={H} defaultProps={CARS.Corvette} />
      <Composition id="Car8" component={ScanSpot} durationInFrames={13 * FPS} fps={FPS} width={W} height={H} defaultProps={CARS.Rolls} />
      {/* App explainer — what it is, features, pricing */}
      <Composition id="Explainer" component={ExplainerSpot} durationInFrames={17 * FPS} fps={FPS} width={W} height={H} />
    </>
  )
}
