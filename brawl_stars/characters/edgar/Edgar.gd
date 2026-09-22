class_name Edgar
extends Node2D

## Master Directorial Interface for EDGAR (Brawl Stars)
## 100% Native 2D Godot Illustrated Storytelling Character
## Controls all 14+ emotional expressions, blank white emo eyes, heavy eyeliner,
## living sentient scarf fist actions, cynical deadpan body poses, and talk visemes.

signal expression_changed(expr_name: String)
signal pose_changed(pose_name: String)

const EdgarStyle = preload("res://brawl_stars/characters/edgar/EdgarStyle.gd")
const EdgarVisual = preload("res://brawl_stars/characters/edgar/EdgarVisual.gd")
const BrawlLipSync = preload("res://brawl_stars/scripts/BrawlLipSync.gd")

@onready var visual: Node2D = $EdgarVisual

var lip_sync: BrawlLipSync
var voice_player: AudioStreamPlayer

var current_expression: String = "deadpan"
var current_pose: String = "idle_slouch"

var _active_tween: Tween
var _blink_tween: Tween
var _talk_tween: Tween

# Micro-acting timers
var _blink_timer: float = 0.0
var _next_blink_time: float = 4.0
var _idle_time: float = 0.0

func _ready() -> void:
	if not visual:
		visual = get_node_or_null("EdgarVisual")
	
	voice_player = get_node_or_null("VoicePlayer") as AudioStreamPlayer
	if not voice_player:
		voice_player = AudioStreamPlayer.new()
		voice_player.name = "VoicePlayer"
		add_child(voice_player)
	
	if visual and visual.get("face"):
		lip_sync = BrawlLipSync.new(self, visual.face, "edgar")
		lip_sync.set_audio_player(voice_player)
	
	set_expression("deadpan")
	set_pose("idle_slouch", 0.0)

func _process(delta: float) -> void:
	_idle_time += delta
	if visual:
		# Slow atmospheric scarf undulation
		visual.scarf_sway = sin(_idle_time * 1.6) * 0.35
		
		# Slouched breathing drift
		if current_pose == "idle_slouch":
			visual.head_offset = Vector2(0, sin(_idle_time * 2.0) * 1.2)
	
	# Procedural unbothered blinking
	_blink_timer += delta
	if _blink_timer >= _next_blink_time:
		_blink_timer = 0.0
		_next_blink_time = randf_range(3.2, 5.5)
		if current_expression != "deadpan":
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
	face.set("show_dark_lines", false)
	face.set("show_toxic_sparkle", false)
	visual.head_tilt = 0.0
	
	match current_expression:
		"neutral":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.95)
			face.set("mouth_shape", "deadpan")
			face.set("gaze_direction", Vector2.ZERO)
		
		"curious":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.1)
			face.set("gaze_direction", Vector2(0.4, -0.1))
			face.set("mouth_shape", "deadpan")
			visual.head_tilt = -0.10
		
		"analytical":
			face.set("eye_state", "toxic_smug")
			face.set("eye_openness", 0.75)
			face.set("gaze_direction", Vector2(0.3, 0.2))
			face.set("mouth_shape", "deadpan")
			visual.head_tilt = 0.05
		
		"happy":
			# Edgar's rare cynical amusement
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.85)
			face.set("mouth_shape", "smirk")
		
		"excited":
			face.set("eye_state", "normal")
			face.set("eye_openness", 1.2)
			face.set("mouth_shape", "smirk")
			face.set("show_toxic_sparkle", true)
		
		"confused":
			face.set("eye_state", "normal")
			face.set("eye_openness", 0.9)
			face.set("gaze_direction", Vector2(-0.4, 0.2))
			face.set("mouth_shape", "sarcastic_frown")
			visual.head_tilt = 0.12
		
		"surprised":
			face.set("eye_state", "shock")
			face.set("eye_openness", 1.25)
			face.set("mouth_shape", "deadpan")
			visual.head_tilt = -0.06
		
		"shocked":
			# Complete disbelief at teammate's throw
			face.set("eye_state", "shock")
			face.set("eye_openness", 1.4)
			face.set("mouth_shape", "shout")
			face.set("show_sweat", true)
		
		"annoyed":
			face.set("eye_state", "annoyed")
			face.set("eye_openness", 0.8)
			face.set("gaze_direction", Vector2(-0.3, 0.1))
			face.set("mouth_shape", "sarcastic_frown")
			face.set("show_anger", true)
			visual.head_tilt = 0.06
		
		"worried":
			face.set("eye_state", "shock")
			face.set("eye_openness", 1.0)
			face.set("mouth_shape", "sarcastic_frown")
			face.set("show_sweat", true)
			visual.head_tilt = -0.08
		
		"smug", "toxic_smug":
			# Arrogant half-lidded smirk
			face.set("eye_state", "toxic_smug")
			face.set("eye_openness", 0.8)
			face.set("gaze_direction", Vector2(0.4, -0.1))
			face.set("mouth_shape", "smirk")
			face.set("show_toxic_sparkle", true)
			visual.head_tilt = 0.08
		
		"deadpan":
			# Canonical Edgar baseline: flat unbothered stare
			face.set("eye_state", "deadpan")
			face.set("eye_openness", 0.6)
			face.set("mouth_shape", "deadpan")
			face.set("gaze_direction", Vector2.ZERO)
		
		"explosive_shout":
			# "WHY WOULD YOU DO THAT?!"
			face.set("eye_state", "shock")
			face.set("eye_openness", 1.45)
			face.set("mouth_shape", "shout")
			face.set("show_anger", true)
			face.set("show_sweat", true)
			visual.head_tilt = -0.05
		
		"emo_despair":
			# Raincloud gloom
			face.set("eye_state", "deadpan")
			face.set("eye_openness", 0.5)
			face.set("mouth_shape", "sarcastic_frown")
			face.set("show_dark_lines", true)
			visual.head_tilt = 0.14
		
		_:
			face.set("eye_state", "deadpan")
			face.set("mouth_shape", "deadpan")
	
	face.queue_redraw()
	expression_changed.emit(current_expression)

# -------------------------------------------------------------------------
# DIRECTORIAL API: BODY POSES & SCARF ACTIONS
# -------------------------------------------------------------------------

func set_pose(pose_name: String, duration: float = 0.2) -> void:
	current_pose = pose_name.to_lower()
	if not visual:
		return
	
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var limbs: Node2D = visual.limbs
	var scarf: Node2D = visual.scarf
	
	match current_pose:
		"idle_slouch":
			# Relaxed slouch
			_active_tween.tween_property(visual, "torso_lean", 0.04, duration)
			_active_tween.tween_property(visual, "head_tilt", 0.02, duration)
			limbs.set("arm_pose", "idle_slouch")
			scarf.set("scarf_pose", "idle_drape")
		
		"arms_crossed":
			# Sentient scarf arms tightly crossed over chest
			_active_tween.tween_property(visual, "torso_lean", -0.04, duration)
			_active_tween.tween_property(visual, "head_tilt", 0.06, duration)
			limbs.set("arm_pose", "idle_slouch")
			scarf.set("scarf_pose", "crossed")
		
		"phone_scroll":
			# Looking down at phone
			_active_tween.tween_property(visual, "torso_lean", 0.10, duration)
			_active_tween.tween_property(visual, "head_tilt", 0.16, duration)
			limbs.set("arm_pose", "phone_scroll")
			scarf.set("scarf_pose", "idle_drape")
			set_gaze(Vector2(0.2, 0.6))
		
		"toxic_thumbs_down":
			# Scarf fist giving thumbs-down
			_active_tween.tween_property(visual, "torso_lean", -0.06, duration)
			_active_tween.tween_property(visual, "head_tilt", 0.08, duration)
			limbs.set("arm_pose", "idle_slouch")
			scarf.set("scarf_pose", "thumbs_down")
		
		"punch_ready":
			# Raised boxing fists
			_active_tween.tween_property(visual, "torso_lean", 0.08, duration)
			_active_tween.tween_property(visual, "head_tilt", -0.06, duration)
			limbs.set("arm_pose", "idle_slouch")
			scarf.set("scarf_pose", "punch_ready")
		
		"shrug":
			# Palms up shrug
			_active_tween.tween_property(visual, "torso_lean", 0.0, duration)
			_active_tween.tween_property(visual, "head_tilt", 0.10, duration)
			limbs.set("arm_pose", "shrug")
			scarf.set("scarf_pose", "idle_drape")
		
		"deadpan_freeze":
			# 0-motion freeze
			_active_tween.tween_property(visual, "torso_lean", 0.0, 0.05)
			_active_tween.tween_property(visual, "head_tilt", 0.0, 0.05)
			limbs.set("arm_pose", "idle_slouch")
			scarf.set("scarf_pose", "crossed")
	
	limbs.queue_redraw()
	scarf.queue_redraw()
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

func blink(duration: float = 0.16) -> void:
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
	get_tree().create_timer(0.2).timeout.connect(func(): blink(0.15))

# -------------------------------------------------------------------------
# DIRECTORIAL API: DIALOGUE VISEMES & SPEECH
# -------------------------------------------------------------------------

## Synchronizes live illustrative lip-sync mouth animation to spoken dialogue phrase
func speak(text: String, duration: float = -1.0, emotion: String = "normal") -> void:
	if not lip_sync and visual and visual.face:
		lip_sync = BrawlLipSync.new(self, visual.face, "edgar")
		lip_sync.set_audio_player(voice_player)
	if lip_sync:
		await lip_sync.speak_phrase(text, duration, emotion)

## Plays an AudioStream voice track and drives synchronized illustrative mouth movement
func speak_audio(audio_path_or_stream: Variant, text: String = "", emotion: String = "normal") -> void:
	if not lip_sync and visual and visual.face:
		lip_sync = BrawlLipSync.new(self, visual.face, "edgar")
		lip_sync.set_audio_player(voice_player)
	if lip_sync:
		await lip_sync.speak_audio(audio_path_or_stream, text, emotion)

## Stops speech immediately and snaps mouth shut to rest/deadpan
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

func set_mouth_viseme(viseme: String) -> void:
	set_viseme(viseme)

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
