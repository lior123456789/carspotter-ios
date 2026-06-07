import { interpolate, Easing } from 'remotion'

// Smooth easing matching the Stitch palette feel
export const SMOOTH = Easing.bezier(0.16, 1, 0.3, 1)

/** Fade in over `duration` frames starting at `start` */
export const fadeIn = (frame: number, start: number, duration: number) =>
  interpolate(frame, [start, start + duration], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp', easing: SMOOTH })

/** Fade out over `duration` frames ending at `end` */
export const fadeOut = (frame: number, end: number, duration: number) =>
  interpolate(frame, [end - duration, end], [1, 0], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp', easing: SMOOTH })

/** Combined fade in/out across [start, end] with given durations */
export const fadeInOut = (frame: number, start: number, end: number, inDur = 12, outDur = 12) =>
  Math.min(fadeIn(frame, start, inDur), fadeOut(frame, end, outDur))

/** Translate Y from offset → 0 over fade-in window */
export const slideUp = (frame: number, start: number, duration: number, distance = 40) =>
  interpolate(frame, [start, start + duration], [distance, 0], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp', easing: SMOOTH })

/** Scale from `from` to 1 over duration */
export const scaleIn = (frame: number, start: number, duration: number, from = 0.85) =>
  interpolate(frame, [start, start + duration], [from, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp', easing: SMOOTH })

/** Blur (px) decreasing from `max` to 0 over duration */
export const blurIn = (frame: number, start: number, duration: number, max = 10) =>
  interpolate(frame, [start, start + duration], [max, 0], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp', easing: SMOOTH })

/** Linear progress 0→1 across [start, end] */
export const progress = (frame: number, start: number, end: number) =>
  interpolate(frame, [start, end], [0, 1], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' })

/** Frame-based typewriter: number of characters to show */
export const typedChars = (frame: number, start: number, charsPerSecond: number, fps: number, total: number) => {
  const elapsed = Math.max(0, frame - start)
  const c = Math.floor((elapsed / fps) * charsPerSecond)
  return Math.min(total, c)
}
