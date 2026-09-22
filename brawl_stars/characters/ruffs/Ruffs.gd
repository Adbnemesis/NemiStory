class_name Ruffs
extends Node2D

## Master Directorial Interface for COLONEL RUFFS (Brawl Stars)
## 100% Native 2D Godot Illustrated Storytelling Character Rig
## Directs all 14+ emotional expressions, single eye gaze & brow angles,
## canine floppy ear physics, double-breasted officer uniform stances,
## crisp military salutes, and comedic canine behavior states.

signal expression_changed(expr_name: String)
signal pose_changed(pose_name: String)

const RuffsStyle = preload("res://brawl_stars/characters/ruffs/RuffsStyle.gd")
const RuffsVisual = preload("res://brawl_stars/characters/ruffs/RuffsVisual.gd")

@onready var visual: Node2D = $RuffsVisual

var current_expression: String = "neutral"
var current_pose: String = "parade_rest"

var _active_tween: Tween
var _blink_tween: Tween
var _ear_tween: Tween

func _ready() -> void:
	set_expression("neutral")
	set_pose("parade_rest", 0.0)

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
	face.set("brow_tilt", 0.0)
	face.set("brow_offset", Vector2.ZERO)
	visual.head_tilt = 0.0
	visual.head_offset = Vector2.ZERO
	
	match current_expression:
		"neutral":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.0)
			face.set("mouth_shape", "neutral")
			face.set("mouth_openness", 0.0)
			face.set("gaze_direction", Vector2.ZERO)
			visual.left_ear_angle = 0.0
			visual.right_ear_angle = 0.0
		
		"curious":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.1)
			face.set("gaze_direction", Vector2(0.4, -0.2))
			face.set("mouth_shape", "neutral")
			face.set("brow_tilt", -0.18)
			visual.head_tilt = -0.14 # Inquisitive canine head cock
			visual.left_ear_angle = -0.15 # Right ear perked slightly
			visual.right_ear_angle = 0.05
		
		"analytical":
			face.set("eye_state", "analytical")
			face.set("eye_openness", 0.72)
			face.set("gaze_direction", Vector2(0.3, 0.2))
			face.set("mouth_shape", "deadpan")
			face.set("brow_tilt", 0.22) # Furrowed military calculation
			visual.head_tilt = 0.06
			visual.left_ear_angle = 0.0
			visual.right_ear_angle = 0.0
		
		"happy":
			face.set("eye_state", "happy")
			face.set("eye_openness", 0.0)
			face.set("mouth_shape", "smirk")
			face.set("mouth_openness", 0.0)
			face.set("gaze_direction", Vector2.ZERO)
			visual.left_ear_angle = 0.1
			visual.right_ear_angle = -0.1
		
		"excited":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.3)
			face.set("mouth_shape", "panting") # Happy canine panting!
			face.set("mouth_openness", 0.8)
			face.set("show_sparkle", true)
			visual.head_tilt = -0.06
			visual.left_ear_angle = -0.22 # Alert perked ears
			visual.right_ear_angle = 0.22
		
		"confused":
			face.set("eye_state", "suspicious")
			face.set("eye_openness", 0.85)
			face.set("gaze_direction", Vector2(-0.4, -0.15))
			face.set("mouth_shape", "deadpan")
			face.set("brow_tilt", -0.25)
			visual.head_tilt = 0.2 # Pronounced quizzical head tilt
			visual.left_ear_angle = 0.18
			visual.right_ear_angle = -0.12
		
		"surprised":
			face.set("eye_state", "shock")
			face.set("eye_openness", 1.35)
			face.set("mouth_shape", "bark")
			face.set("mouth_openness", 0.6)
			face.set("gaze_direction", Vector2(0.0, -0.2))
			visual.head_tilt = -0.06
			visual.left_ear_angle = -0.3 # Ears shoot outward in surprise
			visual.right_ear_angle = 0.3
		
		"shocked":
			face.set("eye_state", "shock")
			face.set("eye_openness", 1.45)
			face.set("mouth_shape", "bark")
			face.set("mouth_openness", 0.9)
			face.set("show_sweat", true)
			visual.head_offset = Vector2(0, -6)
			visual.left_ear_angle = 0.25 # Ears droop in dismay
			visual.right_ear_angle = -0.25
		
		"annoyed":
			face.set("eye_state", "analytical")
			face.set("eye_openness", 0.8)
			face.set("mouth_shape", "growl") # Bared teeth growl!
			face.set("mouth_openness", 0.4)
			face.set("gaze_direction", Vector2(-0.25, 0.1))
			face.set("brow_tilt", 0.3)
			face.set("show_anger", true)
			visual.head_tilt = 0.05
		
		"worried":
			face.set("eye_state", "suspicious")
			face.set("eye_openness", 0.88)
			face.set("mouth_shape", "neutral")
			face.set("brow_tilt", -0.22)
			face.set("show_sweat", true)
			visual.head_tilt = -0.08
			visual.left_ear_angle = 0.22 # Drooping worried hound ears
			visual.right_ear_angle = -0.22
		
		"smug":
			face.set("eye_state", "analytical")
			face.set("eye_openness", 0.78)
			face.set("mouth_shape", "smirk")
			face.set("mouth_openness", 0.0)
			face.set("gaze_direction", Vector2(0.35, -0.1))
			face.set("brow_tilt", -0.12)
			visual.head_tilt = 0.1 # Confident officer head tilt
			visual.left_ear_angle = -0.1
			visual.right_ear_angle = 0.05
		
		"deadpan":
			face.set("eye_state", "deadpan")
			face.set("eye_openness", 0.55)
			face.set("mouth_shape", "deadpan")
			face.set("mouth_openness", 0.0)
			face.set("gaze_direction", Vector2.ZERO)
			face.set("brow_tilt", 0.0)
			visual.head_tilt = 0.0
			visual.left_ear_angle = 0.0
			visual.right_ear_angle = 0.0
		
		"disciplined":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.05)
			face.set("mouth_shape", "neutral")
			face.set("mouth_openness", 0.0)
			face.set("gaze_direction", Vector2.ZERO)
			face.set("brow_tilt", 0.15) # Strict military brow
			visual.head_tilt = 0.0
			visual.left_ear_angle = 0.0
			visual.right_ear_angle = 0.0
		
		"mission_accomplished":
			face.set("eye_state", "happy")
			face.set("eye_openness", 0.0)
			face.set("mouth_shape", "smirk")
			face.set("mouth_openness", 0.0)
			face.set("show_sparkle", true)
			visual.head_tilt = -0.04
			visual.left_ear_angle = -0.12
			visual.right_ear_angle = 0.12
		
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
	var target_arm_pose: String = "parade_rest"
	var target_leg_stance: String = "attention"
	
	match current_pose:
		"parade_rest":
			target_torso_lean = 0.0
			target_arm_pose = "parade_rest"
			target_leg_stance = "attention"
		
		"salute":
			target_torso_lean = -0.04 # Snapping rigid military posture
			target_arm_pose = "salute"
			target_leg_stance = "attention"
		
		"aim_blaster":
			target_torso_lean = 0.12
			target_arm_pose = "aim_blaster"
			target_leg_stance = "confident"
		
		"command_point":
			target_torso_lean = 0.08
			target_arm_pose = "command_point"
			target_leg_stance = "confident"
		
		"on_hip":
			target_torso_lean = -0.06
			target_arm_pose = "on_hip"
			target_leg_stance = "parade_rest"
		
		"recoil":
			target_torso_lean = -0.22
			target_arm_pose = "recoil"
			target_leg_stance = "recoil"
		
		"curious_lean":
			target_torso_lean = 0.16
			target_arm_pose = "command_point"
			target_leg_stance = "parade_rest"
		
		_:
			target_torso_lean = 0.0
			target_arm_pose = "parade_rest"
			target_leg_stance = "attention"
	
	if visual.right_arm:
		visual.right_arm.arm_pose = target_arm_pose
	if visual.limbs:
		visual.limbs.leg_stance = target_leg_stance
	
	if duration <= 0.001:
		visual.torso_lean = target_torso_lean
	else:
		_active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_active_tween.tween_property(visual, "torso_lean", target_torso_lean, duration)
	
	pose_changed.emit(current_pose)

# -------------------------------------------------------------------------
# DIRECTORIAL API: CANINE EAR DYNAMICS & TWITCHES
# -------------------------------------------------------------------------

func twitch_ears() -> void:
	if not visual:
		return
	if _ear_tween and _ear_tween.is_valid():
		_ear_tween.kill()
	
	var base_l: float = visual.left_ear_angle
	var base_r: float = visual.right_ear_angle
	
	_ear_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	_ear_tween.tween_property(visual, "left_ear_angle", base_l - 0.24, 0.07)
	_ear_tween.parallel().tween_property(visual, "right_ear_angle", base_r + 0.24, 0.07)
	_ear_tween.tween_property(visual, "left_ear_angle", base_l + 0.08, 0.06)
	_ear_tween.parallel().tween_property(visual, "right_ear_angle", base_r - 0.08, 0.06)
	_ear_tween.tween_property(visual, "left_ear_angle", base_l, 0.08)
	_ear_tween.parallel().tween_property(visual, "right_ear_angle", base_r, 0.08)

func perk_ears() -> void:
	if not visual:
		return
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(visual, "left_ear_angle", -0.28, 0.15)
	tw.parallel().tween_property(visual, "right_ear_angle", 0.28, 0.15)

func droop_ears() -> void:
	if not visual:
		return
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(visual, "left_ear_angle", 0.28, 0.2)
	tw.parallel().tween_property(visual, "right_ear_angle", -0.28, 0.2)

func reset_ears() -> void:
	if not visual:
		return
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(visual, "left_ear_angle", 0.0, 0.15)
	tw.parallel().tween_property(visual, "right_ear_angle", 0.0, 0.15)

# -------------------------------------------------------------------------
# DIRECTORIAL API: GAZE & EYE TRACKING
# -------------------------------------------------------------------------

func set_gaze(direction: Vector2) -> void:
	if visual and visual.face:
		visual.face.gaze_direction = direction

func look_at_point(target_global_pos: Vector2) -> void:
	if not visual or not visual.head_pivot:
		return
	var eye_world_pos: Vector2 = visual.head_pivot.global_position + Vector2(-22, -8)
	var diff := target_global_pos - eye_world_pos
	var norm_diff := diff.normalized()
	set_gaze(norm_diff)

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
# DIRECTORIAL API: MOUTH VISEMES FOR SPEECH & CANINE SOUNDS
# -------------------------------------------------------------------------

func set_mouth_viseme(viseme: String) -> void:
	if not visual or not visual.face:
		return
	
	match viseme:
		"closed":
			visual.face.mouth_shape = "neutral"
			visual.face.mouth_openness = 0.0
		"bark":
			visual.face.mouth_shape = "bark"
			visual.face.mouth_openness = 0.75
		"growl":
			visual.face.mouth_shape = "growl"
			visual.face.mouth_openness = 0.35
		"smirk":
			visual.face.mouth_shape = "smirk"
			visual.face.mouth_openness = 0.0
		"deadpan":
			visual.face.mouth_shape = "deadpan"
			visual.face.mouth_openness = 0.0
		"panting":
			visual.face.mouth_shape = "panting"
			visual.face.mouth_openness = 0.85
		"talk_a":
			visual.face.mouth_shape = "bark"
			visual.face.mouth_openness = 0.5
		"talk_o":
			visual.face.mouth_shape = "bark"
			visual.face.mouth_openness = 0.8
		_:
			visual.face.mouth_shape = viseme

# -------------------------------------------------------------------------
# DIRECTORIAL API: ART MODE & SPECIAL CONTROLS
# -------------------------------------------------------------------------

func set_art_mode(mode: RuffsStyle.ArtMode) -> void:
	if visual:
		visual.set_art_mode(mode)

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
