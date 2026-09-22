class_name Cosmo
extends Node2D

## Master Directorial Interface for COSMO (Brawl Stars)
## 100% Native 2D Godot Illustrated Storytelling Character
## Controls all 14+ emotional expressions, cyclops eye gaze & pupils, 4-segment teeth visemes,
## body poses, Attractor gauntlet manipulations, and levitation floating states.

signal expression_changed(expr_name: String)
signal pose_changed(pose_name: String)

const CosmoStyle = preload("res://brawl_stars/characters/cosmo/CosmoStyle.gd")
const CosmoVisual = preload("res://brawl_stars/characters/cosmo/CosmoVisual.gd")

@onready var visual: Node2D = $CosmoVisual

var current_expression: String = "neutral"
var current_pose: String = "idle"

var _active_tween: Tween
var _blink_tween: Tween
var _levitation_tween: Tween

var is_levitating: bool = false
var _levitation_time: float = 0.0

func _ready() -> void:
	set_expression("neutral")
	set_pose("idle", 0.0)

func _process(delta: float) -> void:
	if is_levitating and visual:
		_levitation_time += delta * 2.8
		var bob_y := sin(_levitation_time) * 3.5
		visual.head_floating_offset = Vector2(0, bob_y)

# -------------------------------------------------------------------------
# DIRECTORIAL API: EXPRESSIONS (All 14 Required Emotional States)
# -------------------------------------------------------------------------

func set_expression(expr: String) -> void:
	current_expression = expr.to_lower()
	if not visual or not visual.get("face"):
		return
	
	var face: Node2D = visual.face
	
	# Reset defaults
	face.set("show_sweat", false)
	face.set("show_sparkle", false)
	face.set("show_anger", false)
	face.set("pupil_tilt", 0.0)
	visual.head_tilt = 0.0
	
	match current_expression:
		"neutral":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.0)
			face.set("mouth_shape", "neutral")
			face.set("gaze_direction", Vector2.ZERO)
		
		"curious":
			face.set("eye_state", "curious")
			face.set("eye_openness", 1.1)
			face.set("gaze_direction", Vector2(0.45, -0.3))
			face.set("mouth_shape", "neutral")
			face.set("pupil_tilt", -0.15)
			visual.head_tilt = -0.12 # Inquisitive head tilt
		
		"analytical":
			face.set("eye_state", "analytical")
			face.set("eye_openness", 0.75)
			face.set("gaze_direction", Vector2(0.2, 0.4))
			face.set("mouth_shape", "deadpan")
			face.set("pupil_tilt", 0.08)
			visual.head_tilt = 0.08
		
		"happy":
			face.set("eye_state", "happy")
			face.set("eye_openness", 0.0)
			face.set("mouth_shape", "smile")
			face.set("gaze_direction", Vector2.ZERO)
		
		"excited":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.3)
			face.set("mouth_shape", "shout")
			face.set("show_sparkle", true)
			visual.head_tilt = -0.05
		
		"confused":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.9)
			face.set("gaze_direction", Vector2(-0.55, -0.2))
			face.set("mouth_shape", "wavy")
			visual.head_tilt = 0.16 # Pronounced confused head cock
		
		"surprised":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.35)
			face.set("mouth_shape", "shock_o")
			face.set("gaze_direction", Vector2(0.0, -0.2))
			visual.head_tilt = -0.08
		
		"shocked":
			face.set("eye_state", "shock")
			face.set("eye_openness", 1.4)
			face.set("mouth_shape", "open_talk")
			face.set("mouth_openness", 1.0)
			face.set("show_sweat", true)
			visual.head_floating_offset = Vector2(0, -6) # Head recoils upward
		
		"annoyed":
			face.set("eye_state", "analytical")
			face.set("eye_openness", 0.8)
			face.set("mouth_shape", "frown")
			face.set("gaze_direction", Vector2(-0.35, 0.1))
			face.set("show_anger", true)
			visual.head_tilt = 0.06
		
		"worried":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.85)
			face.set("mouth_shape", "wavy")
			face.set("show_sweat", true)
			visual.head_tilt = -0.1
		
		"smug":
			face.set("eye_state", "analytical")
			face.set("eye_openness", 0.8)
			face.set("mouth_shape", "smug")
			face.set("pupil_tilt", -0.2)
			face.set("gaze_direction", Vector2(0.4, -0.1))
			visual.head_tilt = 0.12
		
		"deadpan":
			face.set("eye_state", "deadpan")
			face.set("eye_openness", 0.6)
			face.set("mouth_shape", "deadpan")
			face.set("gaze_direction", Vector2.ZERO)
			visual.head_tilt = 0.0
			visual.head_floating_offset = Vector2.ZERO
		
		"fascinated":
			face.set("eye_state", "fascinated")
			face.set("eye_openness", 1.25)
			face.set("mouth_shape", "grin")
			face.set("show_sparkle", true)
			face.set("gaze_direction", Vector2(0.2, -0.3))
			visual.head_tilt = -0.08
		
		"realization":
			face.set("eye_state", "fascinated")
			face.set("eye_openness", 1.35)
			face.set("mouth_shape", "shock_o")
			face.set("show_sparkle", true)
			face.set("gaze_direction", Vector2(0.0, -0.4))
			visual.head_tilt = -0.04
		
		_:
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.0)
			face.set("mouth_shape", "neutral")
			face.set("gaze_direction", Vector2.ZERO)
	
	expression_changed.emit(current_expression)

# -------------------------------------------------------------------------
# DIRECTORIAL API: BODY POSING & STAGING
# -------------------------------------------------------------------------

func set_pose(pose: String, duration: float = 0.2) -> void:
	current_pose = pose.to_lower()
	if not visual:
		return
	
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	
	var target_torso_lean: float = 0.0
	var target_arm_pose: String = "palm_up_hover"
	var target_left_arm_pose: String = "on_hip"
	var target_leg_stance: String = "neutral"
	
	match current_pose:
		"idle":
			target_torso_lean = 0.0
			target_arm_pose = "palm_up_hover"
			target_left_arm_pose = "on_hip"
			target_leg_stance = "neutral"
		
		"observing":
			target_torso_lean = 0.14
			target_arm_pose = "point_forward"
			target_left_arm_pose = "on_hip"
			target_leg_stance = "lean"
		
		"explaining":
			target_torso_lean = -0.06
			target_arm_pose = "explain_gesture"
			target_left_arm_pose = "gesturing"
			target_leg_stance = "wide"
		
		"operating_telescope":
			target_torso_lean = 0.22
			target_arm_pose = "operate_device"
			target_left_arm_pose = "pointing_left"
			target_leg_stance = "lean"
		
		"realization_freeze":
			target_torso_lean = -0.08
			target_arm_pose = "explain_gesture"
			target_left_arm_pose = "on_hip"
			target_leg_stance = "wide"
		
		"deadpan_freeze":
			target_torso_lean = 0.0
			target_arm_pose = "clenched_fist"
			target_left_arm_pose = "relaxed_side"
			target_leg_stance = "neutral"
		
		"recoil":
			target_torso_lean = -0.22
			target_arm_pose = "recoil"
			target_left_arm_pose = "relaxed_side"
			target_leg_stance = "recoil"
		
		"curious_lean":
			target_torso_lean = 0.18
			target_arm_pose = "point_forward"
			target_left_arm_pose = "gesturing"
			target_leg_stance = "lean"
		
		_:
			target_torso_lean = 0.0
			target_arm_pose = "palm_up_hover"
			target_left_arm_pose = "on_hip"
			target_leg_stance = "neutral"
	
	if visual.attractor_arm:
		visual.attractor_arm.arm_pose = target_arm_pose
	if visual.limbs:
		visual.limbs.left_arm_pose = target_left_arm_pose
		visual.limbs.leg_stance = target_leg_stance
	
	if duration <= 0.001:
		visual.torso_lean = target_torso_lean
	else:
		_active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_active_tween.tween_property(visual, "torso_lean", target_torso_lean, duration)
	
	pose_changed.emit(current_pose)

# -------------------------------------------------------------------------
# DIRECTORIAL API: GAZE & EYE TRACKING
# -------------------------------------------------------------------------

func set_gaze(direction: Vector2) -> void:
	if visual and visual.face:
		visual.face.gaze_direction = direction

func look_at_point(target_global_pos: Vector2) -> void:
	if not visual or not visual.head_pivot:
		return
	var eye_world_pos: Vector2 = visual.head_pivot.global_position + Vector2(0, -22)
	var diff := target_global_pos - eye_world_pos
	var norm_diff := diff.normalized()
	set_gaze(norm_diff)

func look_into_telescope(telescope: Node2D) -> void:
	if not telescope:
		return
	var eyepiece_pos: Vector2 = telescope.global_position + Vector2(-65, -75)
	look_at_point(eyepiece_pos)
	if visual:
		visual.head_tilt = 0.12
		if visual.face:
			visual.face.eye_state = "analytical"
			visual.face.eye_openness = 0.8

func blink() -> void:
	if not visual or not visual.face:
		return
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	
	var initial_openness: float = visual.face.eye_openness
	_blink_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	_blink_tween.tween_property(visual.face, "eye_openness", 0.0, 0.06)
	_blink_tween.tween_property(visual.face, "eye_openness", initial_openness, 0.08)

func double_blink() -> void:
	if not visual or not visual.face:
		return
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	
	var initial_openness: float = visual.face.eye_openness
	_blink_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	_blink_tween.tween_property(visual.face, "eye_openness", 0.0, 0.05)
	_blink_tween.tween_property(visual.face, "eye_openness", initial_openness, 0.06)
	_blink_tween.tween_interval(0.06)
	_blink_tween.tween_property(visual.face, "eye_openness", 0.0, 0.05)
	_blink_tween.tween_property(visual.face, "eye_openness", initial_openness, 0.07)

# -------------------------------------------------------------------------
# DIRECTORIAL API: MOUTH VISEMES FOR SPEECH
# -------------------------------------------------------------------------

func set_mouth_viseme(viseme: String) -> void:
	if not visual or not visual.face:
		return
	
	match viseme:
		"closed":
			visual.face.mouth_shape = "neutral"
			visual.face.mouth_openness = 0.0
		"slight_open":
			visual.face.mouth_shape = "neutral"
			visual.face.mouth_openness = 0.2
		"talk_a":
			visual.face.mouth_shape = "open_talk"
			visual.face.mouth_openness = 0.6
		"talk_o":
			visual.face.mouth_shape = "shock_o"
			visual.face.mouth_openness = 0.8
		"smile":
			visual.face.mouth_shape = "smile"
			visual.face.mouth_openness = 0.0
		"frown":
			visual.face.mouth_shape = "frown"
			visual.face.mouth_openness = 0.0
		"shout":
			visual.face.mouth_shape = "shout"
			visual.face.mouth_openness = 1.0
		"deadpan":
			visual.face.mouth_shape = "deadpan"
			visual.face.mouth_openness = 0.0
		_:
			visual.face.mouth_shape = viseme

# -------------------------------------------------------------------------
# DIRECTORIAL API: ART MODE & SPECIAL CONTROLS
# -------------------------------------------------------------------------

func set_art_mode(mode: CosmoStyle.ArtMode) -> void:
	if visual:
		visual.set_art_mode(mode)

func trigger_levitation_bob(enable: bool) -> void:
	is_levitating = enable
	if not enable and visual:
		visual.head_floating_offset = Vector2.ZERO

func show_expression_fx(fx_type: String) -> void:
	if not visual or not visual.face:
		return
	match fx_type:
		"sweat":
			visual.face.show_sweat = true
		"sparkle":
			visual.face.show_sparkle = true
		"anger":
			visual.face.show_anger = true
		"clear":
			visual.face.show_sweat = false
			visual.face.show_sparkle = false
			visual.face.show_anger = false
