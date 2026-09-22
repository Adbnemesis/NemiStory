class_name Pikachu
extends Node2D

## Master Directorial Interface for PIKACHU
## 100% Native 2D Godot Illustrated Character
## Controls all facial acting, 20 expressions, ear articulation, lightning tail, poses, and squash/stretch.

signal expression_changed(expr_name: String)
signal pose_changed(pose_name: String)

const PikachuStyle = preload("res://pokemon/characters/pikachu/PikachuStyle.gd")
const PikachuVisual = preload("res://pokemon/characters/pikachu/PikachuVisual.gd")

@onready var visual: Node2D = $PikachuVisual

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
	if not visual or not visual.get("face") or not visual.get("ears") or not visual.get("tail"):
		return
	
	var face: Node2D = visual.face
	var ears: Node2D = visual.ears
	var tail: Node2D = visual.tail
	
	# Reset defaults
	face.set("show_blush", false)
	face.set("show_sweat", false)
	face.set("is_sparking", false)
	tail.set("is_zapping", false)
	tail.set("is_drooped", false)
	ears.set("ear_droop", 0.0)
	ears.set("left_ear_angle", -0.45)
	ears.set("right_ear_angle", 0.52)
	visual.head_tilt = 0.0
	
	match current_expression:
		"neutral":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.0)
			face.set("mouth_shape", "cat")
			face.set("gaze_direction", Vector2.ZERO)
		
		"happy":
			face.set("eye_state", "happy")
			face.set("eye_openness", 0.0)
			face.set("mouth_shape", "open_happy")
			face.set("gaze_direction", Vector2.ZERO)
			ears.set("left_ear_angle", -0.55)
			ears.set("right_ear_angle", 0.62)
			tail.set("wag_frequency", 8.0)
			tail.set("wag_amplitude", 0.25)
		
		"excited":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.2)
			face.set("mouth_shape", "open_shout")
			face.set("gaze_direction", Vector2(0.0, -0.2))
			ears.set("left_ear_angle", -0.25)
			ears.set("right_ear_angle", 0.25)
			tail.set("is_zapping", true)
			tail.set("wag_frequency", 12.0)
			tail.set("wag_amplitude", 0.35)
		
		"surprised":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.3)
			face.set("mouth_shape", "shock_o")
			ears.set("left_ear_angle", -0.15)
			ears.set("right_ear_angle", 0.15)
		
		"shocked":
			face.set("eye_state", "shock")
			face.set("eye_openness", 1.4)
			face.set("mouth_shape", "open_shout")
			ears.set("left_ear_angle", -0.65)
			ears.set("right_ear_angle", 0.65)
			tail.set("is_zapping", true)
		
		"confused":
			face.set("eye_state", "spiral")
			face.set("eye_openness", 1.0)
			face.set("mouth_shape", "wavy")
			face.set("gaze_direction", Vector2(-0.4, -0.2))
			ears.set("left_ear_angle", -0.15)
			ears.set("right_ear_angle", 0.75)
			visual.head_tilt = 0.15
		
		"worried":
			face.set("eye_state", "sad")
			face.set("eye_openness", 0.85)
			face.set("mouth_shape", "wavy")
			face.set("show_sweat", true)
			ears.set("ear_droop", 0.4)
		
		"embarrassed":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.75)
			face.set("gaze_direction", Vector2(0.5, 0.3))
			face.set("mouth_shape", "smile")
			face.set("show_blush", true)
			ears.set("ear_droop", 0.35)
			ears.set("left_ear_angle", -0.6)
			ears.set("right_ear_angle", 0.6)
		
		"annoyed":
			face.set("eye_state", "squint")
			face.set("eye_openness", 0.5)
			face.set("mouth_shape", "dash")
			ears.set("left_ear_angle", -0.7)
			ears.set("right_ear_angle", 0.7)
		
		"angry":
			face.set("eye_state", "squint")
			face.set("eye_openness", 0.65)
			face.set("mouth_shape", "grit")
			face.set("is_sparking", true)
			tail.set("is_zapping", true)
			ears.set("left_ear_angle", -0.75)
			ears.set("right_ear_angle", 0.75)
		
		"frustrated":
			face.set("eye_state", "happy")
			face.set("eye_openness", 0.0)
			face.set("mouth_shape", "grit")
			ears.set("left_ear_angle", -0.7)
			ears.set("right_ear_angle", 0.7)
			ears.set("ear_twitch", 0.1)
		
		"scared":
			face.set("eye_state", "shock")
			face.set("eye_openness", 1.25)
			face.set("mouth_shape", "wavy")
			face.set("show_sweat", true)
			ears.set("ear_droop", 0.7)
			tail.set("is_drooped", true)
		
		"suspicious":
			face.set("eye_state", "squint")
			face.set("eye_openness", 0.55)
			face.set("gaze_direction", Vector2(-0.7, 0.0))
			face.set("mouth_shape", "dash")
			visual.head_tilt = -0.1
		
		"smug":
			face.set("eye_state", "squint")
			face.set("eye_openness", 0.6)
			face.set("gaze_direction", Vector2(0.5, 0.0))
			face.set("mouth_shape", "smile")
			ears.set("left_ear_angle", -0.2)
			ears.set("right_ear_angle", 0.6)
			visual.head_tilt = 0.08
		
		"exhausted":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.4)
			face.set("mouth_shape", "open_happy")
			face.set("show_sweat", true)
			ears.set("ear_droop", 0.9)
			tail.set("is_drooped", true)
		
		"relieved":
			face.set("eye_state", "happy")
			face.set("eye_openness", 0.0)
			face.set("mouth_shape", "smile")
			face.set("show_sweat", true)
			ears.set("ear_droop", 0.2)
		
		"nervous":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.85)
			face.set("gaze_direction", Vector2(-0.6, 0.2))
			face.set("mouth_shape", "wavy")
			face.set("show_sweat", true)
			ears.set("ear_twitch", 0.08)
		
		"determined":
			face.set("eye_state", "squint")
			face.set("eye_openness", 0.8)
			face.set("mouth_shape", "grit")
			ears.set("left_ear_angle", -0.3)
			ears.set("right_ear_angle", 0.3)
			tail.set("is_zapping", true)
		
		"sad":
			face.set("eye_state", "sad")
			face.set("eye_openness", 0.75)
			face.set("mouth_shape", "frown")
			ears.set("ear_droop", 0.8)
			tail.set("is_drooped", true)
		
		"deadpan":
			face.set("eye_state", "deadpan")
			face.set("eye_openness", 1.0)
			face.set("mouth_shape", "deadpan")
			face.set("gaze_direction", Vector2.ZERO)
			ears.set("left_ear_angle", -0.45)
			ears.set("right_ear_angle", 0.45)
		
		_:
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.0)
			face.set("mouth_shape", "cat")
	
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
		"down_left":
			visual.face.set("gaze_direction", Vector2(-0.6, 0.5))
		"down_right":
			visual.face.set("gaze_direction", Vector2(0.6, 0.5))

func look_at_direction(dir: Vector2) -> void:
	if visual and visual.get("face"):
		visual.face.set("gaze_direction", dir)

func look_at_pos(global_pos: Vector2) -> void:
	if not visual or not visual.get("face"):
		return
	var diff := global_pos - global_position
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
	var ears: Node2D = visual.ears
	var tail: Node2D = visual.tail
	
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	
	var target_arm_pose := "rest"
	var target_lean: float = 0.0
	var target_scale := Vector2.ONE
	var target_tilt: float = 0.0
	var target_ear_l: float = ears.get("left_ear_angle")
	var target_ear_r: float = ears.get("right_ear_angle")
	
	match current_pose:
		"idle":
			target_arm_pose = "rest"
			target_lean = 0.0
			target_scale = Vector2.ONE
			target_tilt = 0.0
			tail.set("wag_frequency", 4.0)
			tail.set("wag_amplitude", 0.12)
		
		"happy_bounce":
			target_arm_pose = "cheer"
			target_scale = Vector2(1.08, 0.94)
			target_ear_l = -0.55
			target_ear_r = 0.62
			tail.set("wag_frequency", 10.0)
			tail.set("wag_amplitude", 0.3)
		
		"curious_tilt":
			target_arm_pose = "rest"
			target_tilt = 0.18
			target_lean = 0.05
			target_ear_l = -0.15
			target_ear_r = 0.65
		
		"cheering":
			target_arm_pose = "cheer"
			target_scale = Vector2(0.95, 1.08)
			target_ear_l = -0.25
			target_ear_r = 0.25
			tail.set("wag_frequency", 12.0)
			tail.set("wag_amplitude", 0.35)
		
		"alert_stand":
			target_arm_pose = "point"
			target_scale = Vector2(0.96, 1.06)
			target_ear_l = -0.18
			target_ear_r = 0.18
		
		"shock_recoil":
			target_arm_pose = "recoil"
			target_lean = -0.12
			target_scale = Vector2(1.12, 0.88)
			target_ear_l = -0.7
			target_ear_r = 0.7
		
		"pout_slump":
			target_arm_pose = "rest"
			target_lean = 0.06
			target_scale = Vector2(1.1, 0.9)
			ears.set("ear_droop", 0.65)
			tail.set("is_drooped", true)
		
		"battle_stance":
			target_arm_pose = "point"
			target_lean = 0.1
			target_scale = Vector2(1.08, 0.92)
			target_ear_l = -0.6
			target_ear_r = 0.6
			tail.set("is_zapping", true)
		
		"deadpan_freeze":
			target_arm_pose = "rest"
			target_lean = 0.0
			target_scale = Vector2.ONE
			target_tilt = 0.0
			tail.set("wag_amplitude", 0.0)
		
		"wave":
			target_arm_pose = "wave"
			target_scale = Vector2.ONE
			target_ear_l = -0.45
			target_ear_r = 0.55
		
		"hold_prop":
			target_arm_pose = "hold"
			target_scale = Vector2.ONE
	
	limbs.set("arm_pose", target_arm_pose)
	
	if duration <= 0.001:
		limbs.set("body_lean", target_lean)
		limbs.set("body_scale", target_scale)
		visual.head_tilt = target_tilt
		ears.set("left_ear_angle", target_ear_l)
		ears.set("right_ear_angle", target_ear_r)
	else:
		_active_tween = create_tween()
		_active_tween.tween_property(limbs, "body_lean", target_lean, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_active_tween.parallel().tween_property(limbs, "body_scale", target_scale, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_active_tween.parallel().tween_property(visual, "head_tilt", target_tilt, duration)
		_active_tween.parallel().tween_property(ears, "left_ear_angle", target_ear_l, duration)
		_active_tween.parallel().tween_property(ears, "right_ear_angle", target_ear_r, duration)
	
	pose_changed.emit(current_pose)

func set_ear_angles(left_deg: float, right_deg: float, duration: float = 0.2) -> void:
	if not visual or not visual.get("ears"):
		return
	var l_rad := deg_to_rad(left_deg)
	var r_rad := deg_to_rad(right_deg)
	if duration <= 0.001:
		visual.ears.set("left_ear_angle", l_rad)
		visual.ears.set("right_ear_angle", r_rad)
	else:
		var tw := create_tween()
		tw.tween_property(visual.ears, "left_ear_angle", l_rad, duration)
		tw.parallel().tween_property(visual.ears, "right_ear_angle", r_rad, duration)

func wag_tail(intensity: float = 1.0, speed: float = 8.0) -> void:
	if visual and visual.get("tail"):
		visual.tail.set("wag_amplitude", 0.25 * intensity)
		visual.tail.set("wag_frequency", speed)

func stop_wag_tail() -> void:
	if visual and visual.get("tail"):
		visual.tail.set("wag_amplitude", 0.0)

func squash_stretch(factor: Vector2, duration: float = 0.2) -> void:
	if not visual or not visual.get("limbs"):
		return
	var tw := create_tween()
	tw.tween_property(visual.limbs, "body_scale", factor, duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(visual.limbs, "body_scale", Vector2.ONE, duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func freeze_stillness(duration: float = 1.5) -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	if visual and visual.get("tail"):
		visual.tail.set("wag_amplitude", 0.0)

func trigger_spark_fx(duration: float = 0.8) -> void:
	if not visual or not visual.get("face") or not visual.get("tail"):
		return
	visual.face.set("is_sparking", true)
	visual.tail.set("is_zapping", true)
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func():
		if visual and visual.get("face"):
			visual.face.set("is_sparking", false)
		if visual and visual.get("tail"):
			visual.tail.set("is_zapping", false)
	)

func set_art_mode(mode: int) -> void:
	if visual and visual.get("style"):
		visual.style.set_mode(mode)

func get_art_mode_name() -> String:
	if visual and visual.get("style"):
		return "COLOR" if visual.style.current_mode == PikachuStyle.ArtMode.COLOR else "MONOCHROME"
	return "UNKNOWN"
