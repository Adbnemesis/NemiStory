class_name NemiActingDirector
extends Node

## Master Production Acting Coordinator for NEMI (V2 Temporal Rework)
## Coordinates eye acting, head acting, body gestures, facial expressions, and reactions.
## Enforces the core illustrated acting principles:
## - Over 85% stillness holds
## - Attention leads movement (eyes establish gaze before head turns)
## - Priority hierarchy with safe interruption
## - Sparse, psychologically motivated micro-acting

signal action_started(action_name: String, intensity: float)
signal action_finished(action_name: String)
signal hold_started(duration: float)
signal hold_finished()
signal state_changed(new_state: String)

const NemiLipSync = preload("res://characters/nemi/animation/actions/NemiLipSync.gd")

var character: Node2D

var eyes: NemiEyeActing
var head: NemiHeadActing
var body: NemiBodyActing
var face: NemiFaceActing
var reactions: NemiReactions
var lipsync: NemiLipSync

var current_action: String = "IDLE"
var current_intensity: float = 0.5
var current_priority: int = NemiTiming.Priority.IDLE
var _active_action_token: int = 0

var acting_state: String = "IDLE": # "IDLE", "ACTING", "HOLDING", "FROZEN"
	set(val):
		acting_state = val
		state_changed.emit(val)

var action_elapsed: float = 0.0
var action_duration: float = 0.0

func _init(p_character: Node2D = null) -> void:
	if p_character:
		initialize(p_character)

func initialize(p_character: Node2D) -> void:
	character = p_character
	eyes = NemiEyeActing.new(character)
	head = NemiHeadActing.new(character)
	body = NemiBodyActing.new(character)
	face = NemiFaceActing.new(character)
	reactions = NemiReactions.new(self)
	lipsync = NemiLipSync.new(character)

func _process(delta: float) -> void:
	if acting_state != "IDLE":
		action_elapsed += delta

## Creates a new fluent sequence runner
func create_sequence() -> NemiSequence:
	return NemiSequence.new(self)

# -------------------------------------------------------------------------
# PRIORITY & INTERRUPTION SYSTEM
# -------------------------------------------------------------------------

## Requests execution of an action with priority check and interruption handling
func request_action(action_name: String, priority: int, intensity: float = 0.5, duration: float = 0.2) -> int:
	if priority < current_priority and acting_state == "ACTING":
		# Action denied: lower priority than active action
		return -1
	
	# Interrupt any lower or equal priority active action
	if character and character.get("_active_tween") and character._active_tween.is_valid():
		character._active_tween.kill()
	
	_active_action_token += 1
	var token: int = _active_action_token
	
	current_action = action_name
	current_priority = priority
	current_intensity = intensity
	action_duration = duration
	action_elapsed = 0.0
	acting_state = "ACTING"
	
	action_started.emit(action_name, intensity)
	return token

## Completes an action and releases priority
func finish_action(token: int) -> void:
	if token != _active_action_token:
		return # Superseded by newer action
	
	action_finished.emit(current_action)
	current_priority = NemiTiming.Priority.IDLE
	if acting_state != "HOLDING" and acting_state != "FROZEN":
		acting_state = "IDLE"
		current_action = "IDLE"

# -------------------------------------------------------------------------
# STILLNESS & FREEZE SYSTEM
# -------------------------------------------------------------------------

## First-class stillness hold primitive: guarantees motionless existence
func hold(duration: float) -> void:
	acting_state = "HOLDING"
	action_duration = duration
	action_elapsed = 0.0
	hold_started.emit(duration)
	
	# Clamp any residual secondary velocities to guarantee complete stillness
	if character:
		character.set("_shake_trauma", 0.0)
		character.set("_hair_sway_velocity", 0.0)
		character.set("_hair_sway_offset", 0.0)
	
	await NemiMotionPrimitives.hold(character.get_tree() if character else null, duration)
	hold_finished.emit()
	if acting_state == "HOLDING":
		acting_state = "IDLE"

## Immediately freezes character into an immovable stillness frame
func freeze(duration: float = -1.0) -> void:
	acting_state = "FROZEN"
	if character:
		NemiMotionPrimitives.freeze(character)
	if duration > 0.0:
		action_duration = duration
		action_elapsed = 0.0
		await NemiMotionPrimitives.hold(character.get_tree() if character else null, duration)
		if acting_state == "FROZEN":
			acting_state = "IDLE"

## Resets character rig, facial state, hair, and transforms to neutral baseline
func reset(duration: float = 0.0) -> void:
	var token: int = request_action("RESET", NemiTiming.Priority.FACE_REACTION, 0.5, duration)
	
	if character and character.has_method("reset"):
		character.reset()
	else:
		if head: await head.reset(duration)
		if body: await body.reset(duration)
		if face: face.reset(duration)
		if eyes: await eyes.reset(duration)
	
	finish_action(token)

# -------------------------------------------------------------------------
# FIRST-CLASS ATTENTION SYSTEM (EYES LEAD HEAD)
# -------------------------------------------------------------------------

## Reusable attention behavior:
## STEP 1: Eyes move toward target
## STEP 2: Brief processing hold
## STEP 3: Head begins turning toward target
## STEP 4: Optional subtle eyebrow response
## STEP 5: Eyes stabilize & head settles
## STEP 6: Sustained attention hold
func look_at_target(direction: Variant, speed: Variant = "fast", hold_before_head: float = 0.15, with_eyebrow: bool = false) -> void:
	var token: int = request_action("ATTENTION", NemiTiming.Priority.MINOR_GESTURE, 0.5, 0.6)
	
	# 1. Eyes move first
	await eyes.look(direction, speed)
	
	# 2. Brief processing pause
	if hold_before_head > 0.0:
		await hold(hold_before_head)
	
	# 3. Head turns to follow
	var head_angle: float = 0.0
	if direction is String:
		match direction.to_lower():
			"right", "down_right", "up_right": head_angle = 15.0
			"left", "down_left", "up_left": head_angle = -15.0
			_: head_angle = 0.0
	elif direction is Vector2:
		head_angle = direction.x * 16.0
	
	if with_eyebrow and face:
		face.set_eyebrows("both", 4.0, 0.1, 0.12)
	
	await head.turn(head_angle, speed)
	finish_action(token)

# -------------------------------------------------------------------------
# MICRO-ACTING LAYER (SPARSE & COMPOSABLE)
# -------------------------------------------------------------------------

func eye_dart(dir: Variant, hold_duration: float = 0.15) -> void:
	var token: int = request_action("EYE_DART", NemiTiming.Priority.MICRO_ACTING, 0.4, hold_duration + 0.06)
	await eyes.eye_dart(dir, hold_duration)
	finish_action(token)

func blink(mode: String = "normal") -> void:
	var token: int = request_action("BLINK", NemiTiming.Priority.MICRO_ACTING, 0.3, 0.16)
	await eyes.blink(mode)
	finish_action(token)

func eyebrow_twitch(side: String = "both", amount_px: float = 6.0, duration: float = 0.15) -> void:
	var token: int = request_action("EYEBROW_TWITCH", NemiTiming.Priority.MICRO_ACTING, 0.3, duration * 2.0)
	await face.set_eyebrows(side, amount_px, 0.15, duration)
	await face.set_eyebrows(side, 0.0, 0.0, duration)
	finish_action(token)

func head_tilt(angle_deg: float, duration: float = 0.18) -> void:
	var token: int = request_action("HEAD_TILT", NemiTiming.Priority.MICRO_ACTING, absf(angle_deg) / 10.0, duration)
	await head.tilt(angle_deg, duration)
	finish_action(token)

func shoulder_shift(intensity: float = 0.3, duration: float = 0.15) -> void:
	var token: int = request_action("SHOULDER_SHIFT", NemiTiming.Priority.MICRO_ACTING, intensity, duration)
	await body.shoulder_shift(intensity, duration)
	finish_action(token)

func posture_correct(duration: float = 0.25) -> void:
	var token: int = request_action("POSTURE_CORRECT", NemiTiming.Priority.MICRO_ACTING, 0.3, duration)
	await body.posture_correct(duration)
	finish_action(token)

# -------------------------------------------------------------------------
# DIRECT GESTURES & ACTIONS
# -------------------------------------------------------------------------

func look(dir: Variant, speed: Variant = "fast") -> void:
	var token: int = request_action("LOOK", NemiTiming.Priority.MINOR_GESTURE, 0.5, NemiTiming.get_duration_for_speed(speed, 0.08))
	await eyes.look(dir, speed)
	finish_action(token)

func head_turn(angle_deg: float, speed: Variant = "normal") -> void:
	var dur: float = NemiTiming.get_duration_for_speed(speed, 0.18)
	var token: int = request_action("HEAD_TURN", NemiTiming.Priority.MINOR_GESTURE, absf(angle_deg) / 25.0, dur)
	await head.turn(angle_deg, speed)
	finish_action(token)

func nod(intensity: float = 1.0, count: int = 1) -> void:
	var token: int = request_action("NOD", NemiTiming.Priority.MINOR_GESTURE, intensity, 0.28 * count)
	await head.nod(intensity, count)
	finish_action(token)

func shake_head(intensity: float = 1.0, count: int = 2) -> void:
	var token: int = request_action("SHAKE_HEAD", NemiTiming.Priority.MINOR_GESTURE, intensity, 0.35 * count)
	await head.shake_head(intensity, count)
	finish_action(token)

func lean(angle_deg: float, duration: float = 0.22) -> void:
	var token: int = request_action("LEAN", NemiTiming.Priority.MAJOR_BODY, absf(angle_deg) / 20.0, duration)
	await body.lean(angle_deg, duration)
	finish_action(token)

func recoil(intensity: float = 0.5, with_shake: bool = true) -> void:
	var token: int = request_action("RECOIL", NemiTiming.Priority.MAJOR_BODY, intensity, 0.16)
	await body.recoil(intensity, with_shake)
	finish_action(token)

func point(side: String = "right", speed: Variant = "fast") -> void:
	var dur: float = NemiTiming.get_duration_for_speed(speed, 0.16)
	var token: int = request_action("POINT", NemiTiming.Priority.MINOR_GESTURE, 0.7, dur)
	await body.point(side, speed)
	finish_action(token)

func shrug(intensity: float = 1.0) -> void:
	var token: int = request_action("SHRUG", NemiTiming.Priority.MINOR_GESTURE, intensity, 0.28)
	await body.shrug(intensity)
	finish_action(token)

func wave(side: String = "right", cycles: int = 2) -> void:
	var token: int = request_action("WAVE", NemiTiming.Priority.MINOR_GESTURE, 0.6, 0.4 + cycles * 0.2)
	await body.wave(side, cycles)
	finish_action(token)

func hands_together() -> void:
	var token: int = request_action("HANDS_TOGETHER", NemiTiming.Priority.MINOR_GESTURE, 0.4, 0.22)
	await body.hands_together()
	finish_action(token)

func hands_down() -> void:
	var token: int = request_action("HANDS_DOWN", NemiTiming.Priority.MINOR_GESTURE, 0.3, 0.18)
	await body.hands_down()
	finish_action(token)

func set_expression(expr_name: String, transition: String = "normal") -> void:
	var token: int = request_action("EXPRESSION:" + expr_name.to_upper(), NemiTiming.Priority.FACE_REACTION, 0.5, 0.12)
	await face.set_expression(expr_name, transition)
	finish_action(token)

# -------------------------------------------------------------------------
# HIGH-LEVEL ACTING API CONVENIENCES
# -------------------------------------------------------------------------

func notice(target: Variant = "right") -> void:
	await reactions.test_a_attention()

func confused() -> void:
	await reactions.test_c_confusion()

func realize() -> void:
	await reactions.test_d_realization()

func shocked(intensity: float = 1.0) -> void:
	await reactions.test_e_shock()

func deadpan() -> void:
	await reactions.test_f_deadpan()

func awkward() -> void:
	await reactions.awkward_pause()

func embarrassed() -> void:
	await reactions.embarrassment()

func speak(text: String, duration: float, emotion: String = "normal") -> void:
	if lipsync:
		await lipsync.speak_phrase(text, duration, emotion)

func gesture_self(duration: float = 0.22) -> void:
	var token: int = request_action("GESTURE_SELF", NemiTiming.Priority.MINOR_GESTURE, 0.5, duration)
	await body.gesture_self(duration)
	finish_action(token)

func gesture_open_palm(side: String = "right", duration: float = 0.22) -> void:
	var token: int = request_action("GESTURE_OPEN_PALM", NemiTiming.Priority.MINOR_GESTURE, 0.5, duration)
	await body.gesture_open_palm(side, duration)
	finish_action(token)

func gesture_thinking(duration: float = 0.24) -> void:
	var token: int = request_action("GESTURE_THINKING", NemiTiming.Priority.MINOR_GESTURE, 0.6, duration)
	await body.gesture_thinking(duration)
	finish_action(token)

func chest_puff(duration: float = 0.25) -> void:
	var token: int = request_action("CHEST_PUFF", NemiTiming.Priority.MAJOR_BODY, 0.7, duration)
	await body.gesture_chest_puff(duration)
	finish_action(token)

func collapse(intensity: float = 1.0, duration: float = 0.25) -> void:
	var token: int = request_action("COLLAPSE", NemiTiming.Priority.MAJOR_BODY, intensity, duration)
	await body.gesture_collapse(intensity, duration)
	finish_action(token)

func hand_on_chest(duration: float = 0.22) -> void:
	var token: int = request_action("HAND_ON_CHEST", NemiTiming.Priority.MINOR_GESTURE, 0.5, duration)
	await body.gesture_hand_on_chest(duration)
	finish_action(token)

func tremble(intensity: float = 0.5, duration: float = 1.0) -> void:
	await body.tremble(intensity, duration)

func freeze_stillness(duration: float) -> void:
	await body.freeze_stillness(duration)
