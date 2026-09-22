class_name Leon
extends Node2D

## Master Directorial Interface for LEON (Brawl Stars)
## 100% Native 2D Godot Illustrated Storytelling Character
## Controls all 14+ emotional expressions, eye gaze & blinks, tooth smirk & speech visemes,
## body poses, con-artist persuasive gesturing, and fidget spinner shurikens.

signal expression_changed(expr_name: String)
signal pose_changed(pose_name: String)

const LeonStyle = preload("res://brawl_stars/characters/leon/LeonStyle.gd")
const LeonVisual = preload("res://brawl_stars/characters/leon/LeonVisual.gd")
const BrawlLipSync = preload("res://brawl_stars/scripts/BrawlLipSync.gd")

@onready var visual: Node2D = $LeonVisual

var lip_sync: BrawlLipSync
var voice_player: AudioStreamPlayer

var current_expression: String = "neutral"
var current_pose: String = "idle"

var _active_tween: Tween
var _blink_tween: Tween
var _talk_tween: Tween

# Micro-acting timers
var _blink_timer: float = 0.0
var _next_blink_time: float = 3.0
var _idle_time: float = 0.0

func _ready() -> void:
	if not visual:
		visual = get_node_or_null("LeonVisual")
	
	voice_player = get_node_or_null("VoicePlayer") as AudioStreamPlayer
	if not voice_player:
		voice_player = AudioStreamPlayer.new()
		voice_player.name = "VoicePlayer"
		add_child(voice_player)
	
	if visual and visual.get("face"):
		lip_sync = BrawlLipSync.new(self, visual.face, "leon")
		lip_sync.set_audio_player(voice_player)
	
	set_expression("neutral")
	set_pose("idle", 0.0)

func _process(delta: float) -> void:
	_idle_time += delta
	if visual:
		# Subtle procedural tail wag
		visual.tail_wag = sin(_idle_time * 2.2) * 0.4
		
		# Micro breathing
		if current_pose == "idle":
			visual.head_offset = Vector2(0, sin(_idle_time * 2.5) * 1.5)
	
	# Procedural blinking
	_blink_timer += delta
	if _blink_timer >= _next_blink_time:
		_blink_timer = 0.0
		_next_blink_time = randf_range(2.6, 4.5)
		if current_expression != "deadpan" and current_expression != "screaming_panic":
			blink()

# -------------------------------------------------------------------------
# DIRECTORIAL API: EXPRESSIONS (14+ Emotional States)
# -------------------------------------------------------------------------

func set_expression(expr: String) -> void:
	current_expression = expr.to_lower()
	if not visual or not visual.get("face"):
		return
	
	var face: Node2D = visual.face
	
	# Reset defaults
	face.set("show_sweat", false)
	face.set("show_anger", false)
	face.set("show_sparkle", false)
	face.set("show_shock_lines", false)
	face.set("has_lollipop", true)
	visual.head_tilt = 0.0
	
	match current_expression:
		"neutral":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.0)
			face.set("mouth_shape", "smirk")
			face.set("gaze_direction", Vector2.ZERO)
		
		"curious":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.15)
			face.set("gaze_direction", Vector2(0.5, -0.2))
			face.set("mouth_shape", "talk_narrow")
			visual.head_tilt = -0.14 # Inquisitive head tilt
		
		"analytical":
			face.set("eye_state", "smug")
			face.set("eye_openness", 0.8)
			face.set("gaze_direction", Vector2(0.3, 0.3))
			face.set("mouth_shape", "deadpan")
			visual.head_tilt = 0.06
		
		"happy":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.9)
			face.set("mouth_shape", "smile")
			face.set("show_sparkle", true)
		
		"excited":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.25)
			face.set("mouth_shape", "smirk")
			face.set("show_sparkle", true)
			visual.head_tilt = -0.06
		
		"confused":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.95)
			face.set("gaze_direction", Vector2(-0.4, 0.1))
			face.set("mouth_shape", "frown")
			visual.head_tilt = 0.16
		
		"surprised":
			face.set("eye_state", "wide_shock")
			face.set("eye_openness", 1.3)
			face.set("mouth_shape", "talk_open")
			visual.head_tilt = -0.08
		
		"shocked":
			face.set("eye_state", "wide_shock")
			face.set("eye_openness", 1.45)
			face.set("mouth_shape", "shout")
			face.set("show_sweat", true)
			face.set("show_shock_lines", true)
		
		"annoyed":
			face.set("eye_state", "smug")
			face.set("eye_openness", 0.75)
			face.set("gaze_direction", Vector2(-0.35, 0.1))
			face.set("mouth_shape", "frown")
			face.set("show_anger", true)
			visual.head_tilt = 0.06
		
		"worried":
			face.set("eye_state", "wide_shock")
			face.set("eye_openness", 1.05)
			face.set("mouth_shape", "frown")
			face.set("show_sweat", true)
			visual.head_tilt = -0.08
		
		"smug":
			face.set("eye_state", "smug")
			face.set("eye_openness", 0.85)
			face.set("gaze_direction", Vector2(0.4, -0.1))
			face.set("mouth_shape", "smirk")
			face.set("show_sparkle", true)
			visual.head_tilt = 0.12
		
		"deadpan":
			face.set("eye_state", "deadpan")
			face.set("eye_openness", 0.6)
			face.set("mouth_shape", "deadpan")
			face.set("gaze_direction", Vector2.ZERO)
		
		"screaming_panic":
			# Maximum comedy breakdown: wide eyes, jaw unhinged shout, sweat, shaking
			face.set("eye_state", "wide_shock")
			face.set("eye_openness", 1.5)
			face.set("mouth_shape", "shout")
			face.set("show_sweat", true)
			face.set("show_shock_lines", true)
			face.set("has_lollipop", false)
			visual.head_tilt = -0.05
		
		"con_artist_persuasive":
			# Fast-talking justification pitch
			face.set("eye_state", "smug")
			face.set("eye_openness", 1.1)
			face.set("gaze_direction", Vector2(0.3, 0.0))
			face.set("mouth_shape", "talk_open")
			face.set("show_sparkle", true)
			visual.head_tilt = -0.08
		
		_:
			face.set("eye_state", "normal")
			face.set("mouth_shape", "smirk")
	
	face.queue_redraw()
	expression_changed.emit(current_expression)

# -------------------------------------------------------------------------
# DIRECTORIAL API: BODY POSES
# -------------------------------------------------------------------------

func set_pose(pose_name: String, duration: float = 0.2) -> void:
	current_pose = pose_name.to_lower()
	if not visual:
		return
	
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var limbs: Node2D = visual.limbs
	var shurikens: Node2D = visual.shurikens
	
	match current_pose:
		"idle":
			_active_tween.tween_property(visual, "torso_lean", 0.0, duration)
			_active_tween.tween_property(visual, "head_tilt", 0.0, duration)
			limbs.set("arm_pose", "in_pockets")
			shurikens.set("show_shuriken", false)
		
		"con_artist_pitch":
			# Lean forward into viewer's personal space, right arm out
			_active_tween.tween_property(visual, "torso_lean", 0.12, duration)
			_active_tween.tween_property(visual, "head_tilt", -0.08, duration)
			limbs.set("arm_pose", "gesture_pitch")
			shurikens.set("show_shuriken", false)
		
		"stealth_crouch":
			# Sneaky low crouch
			_active_tween.tween_property(visual, "torso_lean", 0.22, duration)
			_active_tween.tween_property(visual, "head_tilt", -0.15, duration)
			limbs.set("arm_pose", "in_pockets")
			shurikens.set("show_shuriken", false)
		
		"panic_flail":
			# Arms up in the air flailing
			_active_tween.tween_property(visual, "torso_lean", -0.14, duration)
			_active_tween.tween_property(visual, "head_tilt", 0.05, duration)
			limbs.set("arm_pose", "panic_flail")
			shurikens.set("show_shuriken", false)
		
		"holding_shurikens":
			# Display spinning fidget spinner shurikens
			_active_tween.tween_property(visual, "torso_lean", 0.05, duration)
			limbs.set("arm_pose", "gesture_pitch")
			shurikens.set("show_shuriken", true)
			shurikens.set("is_spinning", true)
		
		"proud_smug":
			# Hands on hips, chest out
			_active_tween.tween_property(visual, "torso_lean", -0.08, duration)
			_active_tween.tween_property(visual, "head_tilt", 0.10, duration)
			limbs.set("arm_pose", "on_hips")
			shurikens.set("show_shuriken", false)
		
		"deadpan_freeze":
			# 0-motion freeze
			_active_tween.tween_property(visual, "torso_lean", 0.0, 0.05)
			_active_tween.tween_property(visual, "head_tilt", 0.0, 0.05)
			limbs.set("arm_pose", "in_pockets")
			shurikens.set("show_shuriken", false)
	
	limbs.queue_redraw()
	pose_changed.emit(current_pose)

# -------------------------------------------------------------------------
# DIRECTORIAL API: GAZE & BLINKS
# -------------------------------------------------------------------------

func set_gaze(direction: Vector2) -> void:
	if visual and visual.face:
		visual.face.set("gaze_direction", direction.clamp(Vector2(-1, -1), Vector2(1, 1)))
		visual.face.queue_redraw()

func look_at_point(global_pos: Vector2) -> void:
	var local_target := to_local(global_pos) - Vector2(0, -60)
	var dir := local_target.normalized()
	set_gaze(dir)

func blink(duration: float = 0.14) -> void:
	if not visual or not visual.face:
		return
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	
	_blink_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_blink_tween.tween_property(visual.face, "blink_ratio", 1.0, duration * 0.45)
	_blink_tween.tween_callback(func(): visual.face.queue_redraw())
	_blink_tween.tween_property(visual.face, "blink_ratio", 0.0, duration * 0.55)
	_blink_tween.tween_callback(func(): visual.face.queue_redraw())

func double_blink() -> void:
	blink(0.12)
	get_tree().create_timer(0.18).timeout.connect(func(): blink(0.14))

# -------------------------------------------------------------------------
# DIRECTORIAL API: DIALOGUE VISEMES & SPEECH
# -------------------------------------------------------------------------

## Synchronizes live illustrative lip-sync mouth animation to spoken dialogue phrase
func speak(text: String, duration: float = -1.0, emotion: String = "normal") -> void:
	if not lip_sync and visual and visual.face:
		lip_sync = BrawlLipSync.new(self, visual.face, "leon")
		lip_sync.set_audio_player(voice_player)
	if lip_sync:
		await lip_sync.speak_phrase(text, duration, emotion)

## Plays an AudioStream voice track and drives synchronized illustrative mouth movement
func speak_audio(audio_path_or_stream: Variant, text: String = "", emotion: String = "normal") -> void:
	if not lip_sync and visual and visual.face:
		lip_sync = BrawlLipSync.new(self, visual.face, "leon")
		lip_sync.set_audio_player(voice_player)
	if lip_sync:
		await lip_sync.speak_audio(audio_path_or_stream, text, emotion)

## Stops speech immediately and snaps mouth shut to rest/smirk
func stop_speech(rest_shape: String = "") -> void:
	if lip_sync:
		lip_sync.stop_speech(rest_shape)

func is_speaking() -> bool:
	return lip_sync.is_speaking if lip_sync else false

func set_viseme(viseme: String) -> void:
	if not visual or not visual.face:
		return
	visual.face.set("mouth_shape", viseme)
	visual.face.queue_redraw()

func talk_syllable(viseme: String = "small_open", duration: float = 0.15) -> void:
	if not visual or not visual.face:
		return
	if _talk_tween and _talk_tween.is_valid():
		_talk_tween.kill()
	
	var prev_shape: String = visual.face.get("mouth_shape")
	visual.face.set("mouth_shape", viseme)
	visual.face.set("mouth_openness", 1.0)
	visual.face.queue_redraw()
	
	_talk_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_talk_tween.tween_interval(duration)
	_talk_tween.tween_callback(func():
		if visual and visual.face:
			visual.face.set("mouth_shape", prev_shape)
			visual.face.set("mouth_openness", 0.0)
			visual.face.queue_redraw()
	)

# -------------------------------------------------------------------------
# DIRECTORIAL API: STYLE & MONOCHROME
# -------------------------------------------------------------------------

func toggle_art_mode() -> void:
	if visual and visual.style:
		visual.style.toggle_mode()

# -------------------------------------------------------------------------
# DIRECTORIAL API: SPECIAL ASSASSIN CAPABILITIES
# -------------------------------------------------------------------------

func trigger_shuriken_spin(active: bool = true) -> void:
	if visual and visual.shurikens:
		visual.shurikens.set("show_shuriken", active)
		visual.shurikens.set("is_spinning", active)
		visual.shurikens.queue_redraw()

func set_stealth_alpha(target_alpha: float, duration: float = 0.3) -> void:
	var tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", target_alpha, duration)

func set_mouth_viseme(viseme: String) -> void:
	set_viseme(viseme)
