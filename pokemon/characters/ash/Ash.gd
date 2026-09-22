class_name Ash
extends Node2D

## Master Directorial Interface for ASH KETCHUM
## 100% Native 2D Godot Illustrated Character
## Controls all 20 expressions, anime eye gaze, eyebrows, viseme mouths,
## gestures, canonical Indigo League outfit, and cap orientation.

signal expression_changed(expr_name: String)
signal pose_changed(pose_name: String)

const AshStyle = preload("res://pokemon/characters/ash/AshStyle.gd")
const AshVisual = preload("res://pokemon/characters/ash/AshVisual.gd")

@onready var visual: Node2D = $AshVisual

var current_expression: String = "neutral"
var current_pose: String = "idle"

var _active_tween: Tween
var _blink_tween: Tween

func _ready() -> void:
	set_expression("neutral")
	set_pose("idle", 0.0)

# -------------------------------------------------------------------------
# DIRECTORIAL API: EXPRESSIONS (All 20 Required Expressions)
# -------------------------------------------------------------------------

func set_expression(expr: String) -> void:
	current_expression = expr.to_lower()
	if not visual or not visual.get("face"):
		return
	
	var face: Node2D = visual.face
	
	# Reset defaults
	face.set("show_blush", false)
	face.set("show_sweat", false)
	face.set("left_brow_offset", Vector2.ZERO)
	face.set("right_brow_offset", Vector2.ZERO)
	face.set("left_brow_tilt", 0.0)
	face.set("right_brow_tilt", 0.0)
	visual.head_tilt = 0.0
	
	match current_expression:
		"neutral":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.0)
			face.set("mouth_shape", "smile")
			face.set("gaze_direction", Vector2.ZERO)
		
		"happy":
			face.set("eye_state", "happy")
			face.set("eye_openness", 0.0)
			face.set("mouth_shape", "confident_grin")
			face.set("left_brow_offset", Vector2(0, -3))
			face.set("right_brow_offset", Vector2(0, -3))
		
		"excited":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.25)
			face.set("mouth_shape", "open_shout")
			face.set("left_brow_offset", Vector2(0, -6))
			face.set("right_brow_offset", Vector2(0, -6))
			face.set("left_brow_tilt", 0.15)
			face.set("right_brow_tilt", -0.15)
		
		"surprised":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.3)
			face.set("mouth_shape", "shock_o")
			face.set("left_brow_offset", Vector2(0, -8))
			face.set("right_brow_offset", Vector2(0, -8))
			face.set("left_brow_tilt", 0.2)
			face.set("right_brow_tilt", -0.2)
		
		"shocked":
			face.set("eye_state", "shock")
			face.set("eye_openness", 1.4)
			face.set("mouth_shape", "open_shout")
			face.set("left_brow_offset", Vector2(0, -10))
			face.set("right_brow_offset", Vector2(0, -10))
		
		"confused":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.9)
			face.set("gaze_direction", Vector2(-0.5, -0.2))
			face.set("mouth_shape", "wavy")
			face.set("left_brow_offset", Vector2(0, -8)) # One brow arched high
			face.set("right_brow_offset", Vector2(0, 3))  # Other lowered
			face.set("left_brow_tilt", 0.3)
			visual.head_tilt = 0.12
		
		"worried":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.85)
			face.set("mouth_shape", "wavy")
			face.set("show_sweat", true)
			face.set("left_brow_offset", Vector2(0, -2))
			face.set("right_brow_offset", Vector2(0, -2))
			face.set("left_brow_tilt", 0.35)
			face.set("right_brow_tilt", -0.35)
		
		"embarrassed":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.75)
			face.set("gaze_direction", Vector2(0.6, 0.2))
			face.set("mouth_shape", "wavy")
			face.set("show_blush", true)
			face.set("show_sweat", true)
			face.set("left_brow_offset", Vector2(0, -2))
			face.set("right_brow_offset", Vector2(0, -2))
			visual.head_tilt = -0.08
		
		"annoyed":
			face.set("eye_state", "squint")
			face.set("eye_openness", 0.5)
			face.set("mouth_shape", "dash")
			face.set("left_brow_offset", Vector2(0, 4))
			face.set("right_brow_offset", Vector2(0, 4))
			face.set("left_brow_tilt", -0.25)
			face.set("right_brow_tilt", 0.25)
		
		"angry":
			face.set("eye_state", "squint")
			face.set("eye_openness", 0.65)
			face.set("mouth_shape", "grit")
			face.set("left_brow_offset", Vector2(0, 6))
			face.set("right_brow_offset", Vector2(0, 6))
			face.set("left_brow_tilt", -0.45)
			face.set("right_brow_tilt", 0.45)
		
		"frustrated":
			face.set("eye_state", "happy")
			face.set("eye_openness", 0.0)
			face.set("mouth_shape", "grit")
			face.set("left_brow_offset", Vector2(0, 5))
			face.set("right_brow_offset", Vector2(0, 5))
			face.set("left_brow_tilt", -0.35)
			face.set("right_brow_tilt", 0.35)
		
		"scared":
			face.set("eye_state", "shock")
			face.set("eye_openness", 1.3)
			face.set("mouth_shape", "wavy")
			face.set("show_sweat", true)
			face.set("left_brow_offset", Vector2(0, -7))
			face.set("right_brow_offset", Vector2(0, -7))
		
		"suspicious":
			face.set("eye_state", "squint")
			face.set("eye_openness", 0.55)
			face.set("gaze_direction", Vector2(-0.7, 0.0))
			face.set("mouth_shape", "dash")
			face.set("left_brow_offset", Vector2(0, -5))
			face.set("right_brow_offset", Vector2(0, 3))
			visual.head_tilt = -0.08
		
		"smug":
			face.set("eye_state", "squint")
			face.set("eye_openness", 0.6)
			face.set("gaze_direction", Vector2(0.5, 0.0))
			face.set("mouth_shape", "confident_grin")
			face.set("left_brow_offset", Vector2(0, -4))
			face.set("right_brow_offset", Vector2(0, 2))
			visual.head_tilt = 0.08
		
		"exhausted":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.4)
			face.set("mouth_shape", "open_happy")
			face.set("show_sweat", true)
			face.set("left_brow_offset", Vector2(0, 2))
			face.set("right_brow_offset", Vector2(0, 2))
		
		"relieved":
			face.set("eye_state", "happy")
			face.set("eye_openness", 0.0)
			face.set("mouth_shape", "smile")
			face.set("show_sweat", true)
			face.set("left_brow_offset", Vector2(0, -1))
			face.set("right_brow_offset", Vector2(0, -1))
		
		"nervous":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.85)
			face.set("gaze_direction", Vector2(-0.6, 0.2))
			face.set("mouth_shape", "wavy")
			face.set("show_sweat", true)
		
		"determined":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.85)
			face.set("mouth_shape", "grit")
			face.set("left_brow_offset", Vector2(0, 4))
			face.set("right_brow_offset", Vector2(0, 4))
			face.set("left_brow_tilt", -0.35)
			face.set("right_brow_tilt", 0.35)
		
		"sad":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.75)
			face.set("mouth_shape", "frown")
			face.set("left_brow_offset", Vector2(0, -2))
			face.set("right_brow_offset", Vector2(0, -2))
			face.set("left_brow_tilt", 0.35)
			face.set("right_brow_tilt", -0.35)
		
		"deadpan":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.95)
			face.set("mouth_shape", "deadpan")
			face.set("gaze_direction", Vector2.ZERO)
			face.set("left_brow_offset", Vector2.ZERO)
			face.set("right_brow_offset", Vector2.ZERO)
		
		_:
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.0)
			face.set("mouth_shape", "smile")
	
	expression_changed.emit(current_expression)

# -------------------------------------------------------------------------
# DIRECTORIAL API: EYE & GAZE CONTROLS
# -------------------------------------------------------------------------

func look(dir_name: String) -> void:
	if not visual or not visual.get("face"):
		return
	match dir_name.to_lower():
		"camera", "center":
			visual.face.set("gaze_direction", Vector2.ZERO)
		"left":
			visual.face.set("gaze_direction", Vector2(-0.8, 0.0))
		"right":
			visual.face.set("gaze_direction", Vector2(0.8, 0.0))
		"up":
			visual.face.set("gaze_direction", Vector2(0.0, -0.6))
		"down":
			visual.face.set("gaze_direction", Vector2(0.0, 0.6))
		"up_left":
			visual.face.set("gaze_direction", Vector2(-0.6, -0.5))
		"up_right":
			visual.face.set("gaze_direction", Vector2(0.6, -0.5))
		"down_left", "pikachu_left":
			visual.face.set("gaze_direction", Vector2(-0.7, 0.6))
		"down_right", "pikachu_right":
			visual.face.set("gaze_direction", Vector2(0.7, 0.6))

func look_at_direction(dir: Vector2) -> void:
	if visual and visual.get("face"):
		visual.face.set("gaze_direction", dir)

func look_at_target(target_pos: Vector2) -> void:
	if not visual or not visual.get("face"):
		return
	var diff := target_pos - (global_position + Vector2(0, -145))
	var dir := diff.normalized()
	visual.face.set("gaze_direction", Vector2(clampf(dir.x * 1.2, -1.0, 1.0), clampf(dir.y * 1.2, -1.0, 1.0)))

func blink(duration: float = 0.12) -> void:
	if not visual or not visual.get("face"):
		return
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	
	var orig_openness: float = visual.face.get("eye_openness")
	_blink_tween = create_tween()
	_blink_tween.tween_property(visual.face, "eye_openness", 0.0, duration * 0.4)
	_blink_tween.tween_property(visual.face, "eye_openness", orig_openness, duration * 0.6)

func double_blink() -> void:
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	var orig_openness: float = visual.face.get("eye_openness") if visual and visual.get("face") else 1.0
	_blink_tween = create_tween()
	_blink_tween.tween_property(visual.face, "eye_openness", 0.0, 0.06)
	_blink_tween.tween_property(visual.face, "eye_openness", orig_openness, 0.07)
	_blink_tween.tween_interval(0.06)
	_blink_tween.tween_property(visual.face, "eye_openness", 0.0, 0.06)
	_blink_tween.tween_property(visual.face, "eye_openness", orig_openness, 0.08)

func set_mouth(mouth_shape: String) -> void:
	if visual and visual.get("face"):
		visual.face.set("mouth_shape", mouth_shape)

# -------------------------------------------------------------------------
# DIRECTORIAL API: POSES & ACTING
# -------------------------------------------------------------------------

func set_pose(pose_name: String, duration: float = 0.2) -> void:
	current_pose = pose_name.to_lower()
	if not visual or not visual.get("limbs"):
		return
	
	var limbs: Node2D = visual.limbs
	var torso: Node2D = visual.torso
	
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	
	var target_arm_pose := "rest"
	var target_torso_lean: float = 0.0
	var target_head_tilt: float = 0.0
	
	match current_pose:
		"idle":
			target_arm_pose = "rest"
			target_torso_lean = 0.0
			target_head_tilt = 0.0
		
		"confident", "confident_fist":
			target_arm_pose = "confident"
			target_torso_lean = 0.04
			target_head_tilt = -0.06
		
		"point", "point_forward":
			target_arm_pose = "point"
			target_torso_lean = 0.06
			target_head_tilt = 0.0
		
		"crossed", "arms_crossed":
			target_arm_pose = "crossed"
			target_torso_lean = -0.02
			target_head_tilt = 0.04
		
		"hold_ball", "holding_pokeball":
			target_arm_pose = "hold_ball"
			target_torso_lean = 0.02
			target_head_tilt = -0.04
		
		"scratch_head":
			target_arm_pose = "scratch_head"
			target_torso_lean = -0.03
			target_head_tilt = 0.1
		
		"shrug":
			target_arm_pose = "shrug"
			target_torso_lean = 0.0
			target_head_tilt = 0.08
		
		"shock_recoil":
			target_arm_pose = "recoil"
			target_torso_lean = -0.1
			target_head_tilt = -0.08
		
		"deadpan_freeze":
			target_arm_pose = "rest"
			target_torso_lean = 0.0
			target_head_tilt = 0.0
		
		"look_at_pikachu":
			target_arm_pose = "rest"
			target_torso_lean = 0.05
			target_head_tilt = 0.16
			look("down_right")
	
	limbs.set("arm_pose", target_arm_pose)
	
	if duration <= 0.001:
		torso.set("torso_lean", target_torso_lean)
		visual.head_tilt = target_head_tilt
	else:
		_active_tween = create_tween()
		_active_tween.tween_property(torso, "torso_lean", target_torso_lean, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_active_tween.parallel().tween_property(visual, "head_tilt", target_head_tilt, duration)
	
	pose_changed.emit(current_pose)

func turn_cap(backward: bool) -> void:
	if visual and visual.get("head"):
		visual.head.set("is_cap_backward", backward)

func set_bag_visible(is_visible: bool) -> void:
	if visual and visual.get("torso"):
		visual.torso.set("show_bag", is_visible)

func is_bag_visible() -> bool:
	if visual and visual.get("torso"):
		return visual.torso.get("show_bag")
	return true

func freeze_stillness(duration: float = 1.5) -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()

func set_art_mode(mode: int) -> void:
	if visual and visual.get("style"):
		visual.style.set_mode(mode)

func get_art_mode_name() -> String:
	if visual and visual.get("style"):
		return "COLOR" if visual.style.current_mode == AshStyle.ArtMode.COLOR else "MONOCHROME"
	return "UNKNOWN"
