class_name NemiTiming
extends RefCounted

## Master Production Timing & Pacing System for NEMI (V2 Temporal Rework)
## Calibrated specifically to match YouTube storytime animation acting:
## - Over 85% static holds (>85% stillness)
## - Attention leads movement: eyes establish focus before head turns
## - Delayed realization beats and comedic holds
## - Fast snappy pose transitions with subtle anticipation & overshoot
## - Priority hierarchy with safe interruption handling

enum Priority {
	IDLE = 0,
	SECONDARY_MOTION = 10,
	MICRO_ACTING = 20,
	MINOR_GESTURE = 30,
	MAJOR_BODY = 40,
	FACE_REACTION = 50
}

enum Speed {
	SNAP,   # 0.0s (0-frame instant cut)
	FAST,   # 0.08s - 0.12s (snappy illustrated action)
	NORMAL, # 0.18s - 0.24s (controlled storytelling acting)
	SLOW    # 0.40s - 0.55s (deliberate / awkward / somber)
}

enum Intensity {
	SUBTLE,      # 0.20x (micro-acting, conversational, understated)
	NORMAL,      # 0.50x (standard storytelling performance)
	STRONG,      # 0.80x (clear realization, decisive gesture)
	EXAGGERATED  # 1.00x (comedic shock, panic, full outrage)
}

enum TransitionStyle {
	SNAP,              # Instant 0-frame change
	NORMAL,            # Snappy smooth interpolation
	STEPPED,           # 2-3 discrete step jumps (animatics style)
	ANTICIPATED,       # Backward prep windup -> fast action -> settle
	OVERSHOOT_SETTLE   # Action overshoots target -> settles back
}

# Standard Hold Durations (Seconds) - Stillness is First-Class
const HOLD_INSTANT: float = 0.08    # Micro eye-dart hold
const HOLD_TINY: float = 0.15       # Brief visual processing beat between eye dart and head turn
const HOLD_BEAT: float = 0.30       # Story beat pause
const HOLD_COMEDIC: float = 0.50    # Comedic setup/punchline pause
const HOLD_AFTERMATH: float = 0.80  # Shock / realization landing pause
const HOLD_LONG: float = 1.20       # Deadpan / awkward silence hold

# Default Action Durations (Seconds)
const DURATION_EYE_DART: float = 0.06
const DURATION_BLINK_NORMAL: float = 0.16
const DURATION_BLINK_QUICK: float = 0.10
const DURATION_BLINK_DELAYED: float = 0.28
const DURATION_BLINK_DOUBLE: float = 0.18

const DURATION_HEAD_TURN_FAST: float = 0.12
const DURATION_HEAD_TURN_NORMAL: float = 0.20
const DURATION_HEAD_TILT: float = 0.18
const DURATION_NOD: float = 0.28
const DURATION_SHAKE_HEAD: float = 0.35

const DURATION_LEAN: float = 0.22
const DURATION_RECOIL: float = 0.16
const DURATION_POINT: float = 0.16
const DURATION_GESTURE: float = 0.24

## Translates Speed enum or String into seconds
static func get_duration_for_speed(speed: Variant, base_duration: float = 0.20) -> float:
	if speed is float or speed is int:
		return float(speed)
	if speed is String:
		match speed.to_lower():
			"snap", "instant": return 0.0
			"fast", "quick": return base_duration * 0.55
			"slow": return base_duration * 1.8
			_: return base_duration
	if speed is Speed:
		match speed:
			Speed.SNAP: return 0.0
			Speed.FAST: return base_duration * 0.55
			Speed.SLOW: return base_duration * 1.8
			_: return base_duration
	return base_duration

## Translates Intensity enum or String into float multiplier (0.2 to 1.0)
static func get_intensity_value(intensity: Variant) -> float:
	if intensity is float or intensity is int:
		return clampf(float(intensity), 0.05, 1.5)
	if intensity is String:
		match intensity.to_lower():
			"subtle", "low", "micro": return 0.20
			"normal", "mid", "default": return 0.50
			"strong", "high": return 0.80
			"exaggerated", "extreme", "max": return 1.00
			_: return 0.50
	if intensity is Intensity:
		match intensity:
			Intensity.SUBTLE: return 0.20
			Intensity.NORMAL: return 0.50
			Intensity.STRONG: return 0.80
			Intensity.EXAGGERATED: return 1.00
			_: return 0.50
	return 0.50

## Translates Priority enum or String into integer priority level
static func get_priority_value(priority: Variant) -> int:
	if priority is int:
		return priority
	if priority is Priority:
		return int(priority)
	if priority is String:
		match priority.to_upper():
			"FACE", "FACE_REACTION", "SHOCK": return Priority.FACE_REACTION
			"BODY", "MAJOR_BODY", "RECOIL": return Priority.MAJOR_BODY
			"GESTURE", "MINOR_GESTURE", "POINT": return Priority.MINOR_GESTURE
			"MICRO", "MICRO_ACTING", "BLINK": return Priority.MICRO_ACTING
			"SECONDARY", "HAIR": return Priority.SECONDARY_MOTION
			_: return Priority.IDLE
	return Priority.IDLE
