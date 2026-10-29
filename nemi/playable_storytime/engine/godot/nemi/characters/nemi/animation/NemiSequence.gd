class_name NemiSequence
extends RefCounted

## Fluent Composable Action Sequencer for NEMI
## Allows chaining multi-step acting performances with holds, timing, and cancellation.

signal step_started(index: int, action_name: String)
signal step_finished(index: int, action_name: String)
signal sequence_completed()
signal sequence_cancelled()

var director: Node # Reference to NemiActingDirector
var _steps: Array[Dictionary] = []
var _is_running: bool = false
var _cancelled: bool = false

func _init(p_director: Node) -> void:
	director = p_director

## Adds a hold beat to the sequence
func hold(duration: float) -> NemiSequence:
	_steps.append({"action": "hold", "duration": duration})
	return self

## Adds eye look direction
func look(dir: Variant, speed: Variant = "fast") -> NemiSequence:
	_steps.append({"action": "look", "dir": dir, "speed": speed})
	return self

## Adds eye dart
func eye_dart(dir: Variant, hold_duration: float = 0.15) -> NemiSequence:
	_steps.append({"action": "eye_dart", "dir": dir, "hold_duration": hold_duration})
	return self

## Adds blink
func blink(mode: String = "normal") -> NemiSequence:
	_steps.append({"action": "blink", "mode": mode})
	return self

## Adds head turn
func head_turn(angle_deg: float, speed: Variant = "normal") -> NemiSequence:
	_steps.append({"action": "head_turn", "angle": angle_deg, "speed": speed})
	return self

## Adds head tilt
func head_tilt(angle_deg: float, duration: float = 0.2) -> NemiSequence:
	_steps.append({"action": "head_tilt", "angle": angle_deg, "duration": duration})
	return self

## Adds affirmative nod
func nod(intensity: float = 1.0, count: int = 1) -> NemiSequence:
	_steps.append({"action": "nod", "intensity": intensity, "count": count})
	return self

## Adds disbelief head shake
func shake_head(intensity: float = 1.0, count: int = 2) -> NemiSequence:
	_steps.append({"action": "shake_head", "intensity": intensity, "count": count})
	return self

## Adds torso lean
func lean(angle_deg: float, duration: float = 0.22) -> NemiSequence:
	_steps.append({"action": "lean", "angle": angle_deg, "duration": duration})
	return self

## Adds shock recoil
func recoil(intensity: float = 0.5, with_shake: bool = true) -> NemiSequence:
	_steps.append({"action": "recoil", "intensity": intensity, "with_shake": with_shake})
	return self

## Adds point gesture
func point(side: String = "right", speed: Variant = "fast") -> NemiSequence:
	_steps.append({"action": "point", "side": side, "speed": speed})
	return self

## Adds shrug gesture
func shrug(intensity: float = 1.0) -> NemiSequence:
	_steps.append({"action": "shrug", "intensity": intensity})
	return self

## Adds wave gesture
func wave(side: String = "right", cycles: int = 2) -> NemiSequence:
	_steps.append({"action": "wave", "side": side, "cycles": cycles})
	return self

## Adds hands together gesture
func hands_together() -> NemiSequence:
	_steps.append({"action": "hands_together"})
	return self

## Adds hands down gesture
func hands_down() -> NemiSequence:
	_steps.append({"action": "hands_down"})
	return self

## Adds expression transition
func set_expression(expr_name: String, transition: String = "normal") -> NemiSequence:
	_steps.append({"action": "expression", "name": expr_name, "transition": transition})
	return self

## Adds a pre-composed reaction
func reaction(reaction_name: String) -> NemiSequence:
	_steps.append({"action": "reaction", "name": reaction_name})
	return self

## Adds an instantaneous freeze frame
func freeze() -> NemiSequence:
	_steps.append({"action": "freeze"})
	return self

## Adds reset to baseline
func reset() -> NemiSequence:
	_steps.append({"action": "reset"})
	return self

## Adds a custom async callable step
func custom(callable: Callable) -> NemiSequence:
	_steps.append({"action": "custom", "callable": callable})
	return self

## Cancels ongoing sequence
func cancel() -> void:
	_cancelled = true
	sequence_cancelled.emit()

## Plays the sequence from start to finish
func play() -> void:
	if _is_running or not director:
		return
	_is_running = true
	_cancelled = false
	
	for i in range(_steps.size()):
		if _cancelled:
			break
		
		var step: Dictionary = _steps[i]
		var act: String = step.get("action", "")
		step_started.emit(i, act)
		
		match act:
			"hold":
				await director.hold(step.get("duration", 0.3))
			"look":
				await director.eyes.look(step.get("dir", Vector2.ZERO), step.get("speed", "fast"))
			"eye_dart":
				await director.eyes.eye_dart(step.get("dir", Vector2.ZERO), step.get("hold_duration", 0.15))
			"blink":
				await director.eyes.blink(step.get("mode", "normal"))
			"head_turn":
				await director.head.turn(step.get("angle", 0.0), step.get("speed", "normal"))
			"head_tilt":
				await director.head.tilt(step.get("angle", 0.0), step.get("duration", 0.2))
			"nod":
				await director.head.nod(step.get("intensity", 1.0), step.get("count", 1))
			"shake_head":
				await director.head.shake_head(step.get("intensity", 1.0), step.get("count", 2))
			"lean":
				await director.body.lean(step.get("angle", 0.0), step.get("duration", 0.22))
			"recoil":
				await director.body.recoil(step.get("intensity", 0.5), step.get("with_shake", true))
			"point":
				await director.body.point(step.get("side", "right"), step.get("speed", "fast"))
			"shrug":
				await director.body.shrug(step.get("intensity", 1.0))
			"wave":
				await director.body.wave(step.get("side", "right"), step.get("cycles", 2))
			"hands_together":
				await director.body.hands_together()
			"hands_down":
				await director.body.hands_down()
			"expression":
				await director.face.set_expression(step.get("name", "neutral"), step.get("transition", "normal"))
			"reaction":
				await director.reactions.call(step.get("name", "notice"))
			"freeze":
				director.freeze()
			"reset":
				await director.reset()
			"custom":
				var call: Callable = step.get("callable", Callable())
				if call.is_valid():
					var res: Variant = call.call()
					if res is Signal:
						await res
		
		step_finished.emit(i, act)
	
	_is_running = false
	sequence_completed.emit()
