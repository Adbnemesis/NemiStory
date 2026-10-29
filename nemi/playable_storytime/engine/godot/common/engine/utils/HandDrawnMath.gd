class_name HandDrawnMath
extends RefCounted

## Utility library for hand-drawn timing, stepped interpolation, and deterministic imperfection.

# Signature line color from reference video analysis (#3e081e: dark burgundy/wine)
const LINE_COLOR: Color = Color(0.243, 0.031, 0.118, 1.0)
const BG_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)

## Quantize progress 't' [0.0, 1.0] into discrete steps (animating on 2s or 3s)
static func stepped(t: float, steps: int) -> float:
	if steps <= 1:
		return t
	return floor(clampf(t, 0.0, 1.0) * float(steps)) / float(steps)

## Overshoot ease-out (recoil / snap-in / pop-in with settle)
static func ease_out_back(t: float, c1: float = 1.70158) -> float:
	var c3: float = c1 + 1.0
	var p: float = clampf(t, 0.0, 1.0) - 1.0
	return 1.0 + c3 * pow(p, 3) + c1 * pow(p, 2)

## Anticipation ease-in-back (slight pull-back before moving)
static func ease_in_back(t: float, c1: float = 1.70158) -> float:
	var c3: float = c1 + 1.0
	var p: float = clampf(t, 0.0, 1.0)
	return c3 * pow(p, 3) - c1 * pow(p, 2)

## Stepped bounce: returns an offset alternating between 0 and -height on 2s/3s
static func stepped_bounce_offset(time_sec: float, height: float, hz: float = 6.0) -> Vector2:
	var phase: int = int(floor(time_sec * hz))
	if phase % 2 == 1:
		return Vector2(0.0, -height)
	return Vector2.ZERO

## Deterministic shake offset using trigonometric noise with decay
static func shake_offset(elapsed: float, trauma: float, max_offset: float = 15.0, freq: float = 35.0, seed_val: int = 1) -> Vector2:
	if trauma <= 0.001:
		return Vector2.ZERO
	var intensity: float = trauma * trauma # Non-linear decay feel
	var s: float = float(seed_val)
	var ox: float = sin(elapsed * freq + s * 17.3) * cos(elapsed * freq * 0.7 + s * 3.1)
	var oy: float = cos(elapsed * freq * 1.3 + s * 11.7) * sin(elapsed * freq * 0.9 + s * 7.5)
	return Vector2(ox, oy) * max_offset * intensity
