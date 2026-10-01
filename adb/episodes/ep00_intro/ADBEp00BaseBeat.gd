class_name ADBEp00BaseBeat
extends Node2D

## ADBEp00BaseBeat — Authoritative Base Class for ADB Episode 00 Beat Scenes
## Provides complete production architecture for ADB's independent channel:
## - Full ADB character rig instance (ADB.tscn)
## - Dynamic Storytelling Camera (StoryCamera.gd)
## - Integrated hand-drawn background system (ADBIntroBackdrop.gd)
## - Stroke-by-stroke authored doodles (ADBIntroDoodles.gd)
## - Production SFX audio player (ADBAudio.gd)
## - Frame-accurate deterministic subtitle sequencer (<= 5 words per card)
## - Floor grounding and physical contact shadows

signal beat_finished()

const Episode00SubtitlesClass = preload("res://adb/episodes/ep00_intro/Episode00Subtitles.gd")
const ADBIntroBackdropClass = preload("res://adb/episodes/ep00_intro/ADBIntroBackdrop.gd")
const ADBIntroDoodlesClass = preload("res://adb/episodes/ep00_intro/ADBIntroDoodles.gd")
const ADBIntroPropsClass = preload("res://adb/episodes/ep00_intro/props/ADBIntroProps.gd")
const ADBAudioClass = preload("res://adb/audio/ADBAudio.gd")
const StoryCameraClass = preload("res://common/engine/camera/StoryCamera.gd")
const ADBScene = preload("res://adb/characters/adb/ADB.tscn")

const INK_MAIN: Color = Color("#2b2623")
const INK_SOFT: Color = Color("#594f4b")
const INK_RED: Color = Color("#d63031")
const INK_GOLD: Color = Color("#e67e22")
const INK_BLUE: Color = Color("#0984e3")
const INK_CYAN: Color = Color("#00cec9")
const INK_MINT: Color = Color("#00b894")
const INK_PURPLE: Color = Color("#6c5ce7")

@export var is_standalone: bool = false
@export var beat_number: int = 1
@export var beat_name: String = "Beat"

var adb: Node2D
var camera: Camera2D
var backdrop: Node2D
var doodles: Node2D
var props_layer: Node2D
var fg_props_layer: Node2D
var audio_system: Node
var subtitle_label: Label

var _beat_cards: Array[Dictionary] = []
var _current_card_idx: int = -1
var _blink_timer: float = 2.5
var _base_adb_y: float = 619.0 # Firmly grounded: sneaker soles at y = 840 (619.0 + 192.0*1.15 = 839.8 ≈ 840.0)

# Physical contact floor shadow (grounded at floor Y = 840)
class ADBFloorShadow extends Node2D:
	var _beat: Node2D
	func _init(b: Node2D) -> void:
		_beat = b
	func _process(_delta: float) -> void:
		queue_redraw()
	func _draw() -> void:
		if not _beat or not is_instance_valid(_beat.adb):
			return
		var char_adb = _beat.adb
		var s_x: float = char_adb.scale.x
		var ax: float = char_adb.position.x
		var floor_y: float = 840.0
		
		# 1. Broad ambient room occlusion pool under character
		draw_set_transform(Vector2(ax, floor_y), 0.0, Vector2(1.0, 0.22))
		draw_circle(Vector2.ZERO, 62.0 * s_x, Color(0.14, 0.11, 0.10, 0.12))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		
		# 2. Left sneaker direct contact shadow (tracks left foot offset & lift)
		var l_lift: float = char_adb.left_foot_offset.y if "left_foot_offset" in char_adb else 0.0
		var l_alpha: float = clampf(0.24 - l_lift * 0.015, 0.06, 0.26)
		var l_size: float = clampf(28.0 * s_x - l_lift * 0.5, 14.0, 32.0)
		var lx: float = ax + (-22.0 + (char_adb.left_foot_offset.x if "left_foot_offset" in char_adb else 0.0)) * s_x
		draw_set_transform(Vector2(lx, floor_y), 0.0, Vector2(1.0, 0.25))
		draw_circle(Vector2.ZERO, l_size, Color(0.12, 0.10, 0.09, l_alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

		# 3. Right sneaker direct contact shadow (tracks right foot offset & lift)
		var r_lift: float = char_adb.right_foot_offset.y if "right_foot_offset" in char_adb else 0.0
		var r_alpha: float = clampf(0.24 - r_lift * 0.015, 0.06, 0.26)
		var r_size: float = clampf(28.0 * s_x - r_lift * 0.5, 14.0, 32.0)
		var rx: float = ax + (22.0 + (char_adb.right_foot_offset.x if "right_foot_offset" in char_adb else 0.0)) * s_x
		draw_set_transform(Vector2(rx, floor_y), 0.0, Vector2(1.0, 0.25))
		draw_circle(Vector2.ZERO, r_size, Color(0.12, 0.10, 0.09, r_alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _ready() -> void:
	_setup_environment()
	_setup_adb()
	_setup_camera()
	_setup_subtitles()
	_load_subtitles()

func _setup_environment() -> void:
	# 1. Background Environment (z = -10)
	backdrop = ADBIntroBackdropClass.new()
	backdrop.name = "Backdrop"
	backdrop.z_index = -10
	add_child(backdrop)

	# 2. Doodles Layer (z = 25 in front of character)
	doodles = ADBIntroDoodlesClass.new()
	doodles.name = "Doodles"
	doodles.z_index = 25
	add_child(doodles)

	# 3. Props Layers
	props_layer = Node2D.new()
	props_layer.name = "PropsLayer"
	props_layer.z_index = 4
	add_child(props_layer)

	fg_props_layer = Node2D.new()
	fg_props_layer.name = "FGPropsLayer"
	fg_props_layer.z_index = 15
	add_child(fg_props_layer)

	# 4. Audio System
	audio_system = ADBAudioClass.new()
	audio_system.name = "AudioSystem"
	add_child(audio_system)

func _setup_adb() -> void:
	# Floor Shadow (z = -2)
	var shadow := ADBFloorShadow.new(self)
	shadow.name = "FloorShadow"
	shadow.z_index = -2
	add_child(shadow)

	# ADB Character Rig (z = 0)
	adb = ADBScene.instantiate() as ADB
	adb.name = "ADB"
	# Canonical scale matching Nemi's animations: 1.15 scale gives ADB ~481px height, canonically ~5% taller than Nemi (446px)
	adb.scale = Vector2(1.15, 1.15)
	adb.position = Vector2(960, _base_adb_y)
	add_child(adb)

func _setup_camera() -> void:
	camera = StoryCameraClass.new()
	camera.name = "StoryCamera"
	camera.position = Vector2(960, 540)
	add_child(camera)
	camera.make_current()

func _setup_subtitles() -> void:
	var ui_canvas := CanvasLayer.new()
	ui_canvas.name = "UI"
	ui_canvas.layer = 20
	add_child(ui_canvas)

	subtitle_label = Label.new()
	subtitle_label.name = "SubtitleLabel"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle_label.anchor_left = 0.0
	subtitle_label.anchor_right = 1.0
	subtitle_label.anchor_top = 1.0
	subtitle_label.anchor_bottom = 1.0
	subtitle_label.offset_left = 80
	subtitle_label.offset_right = -80
	subtitle_label.offset_top = -115
	subtitle_label.offset_bottom = -35

	# Typography: Clean readable sans with thick charcoal outline
	subtitle_label.add_theme_font_size_override("font_size", 38)
	subtitle_label.add_theme_color_override("font_color", Color("#ffffff"))
	subtitle_label.add_theme_color_override("font_outline_color", Color("#23211f"))
	subtitle_label.add_theme_constant_override("outline_size", 10)
	subtitle_label.text = ""

	# Load preferred font if available
	var font_paths := [
		"res://assets/fonts/PatrickHand-Regular.ttf",
		"res://assets/fonts/Caveat-Bold.ttf",
		"res://assets/fonts/GochiHand-Regular.ttf"
	]
	for p in font_paths:
		if ResourceLoader.exists(p):
			subtitle_label.add_theme_font_override("font", load(p))
			break

	ui_canvas.add_child(subtitle_label)

func _load_subtitles() -> void:
	_beat_cards = Episode00SubtitlesClass.get_cards_for_beat(beat_number)

func _process(delta: float) -> void:
	# Subtle eye blinks during storytelling
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_blink_timer = randf_range(2.8, 4.2)
		if is_instance_valid(adb):
			adb.blink(0.12)

# =============================================================================
# PRODUCTION CAMERA HELPERS
# =============================================================================
func cam_punch(zoom_mult: float = 1.25, snap: bool = false, target_pos: Vector2 = Vector2.INF) -> void:
	if camera and camera.has_method("punch_in"):
		camera.punch_in(zoom_mult, snap, target_pos)

func cam_shake(trauma: float = 0.6, decay: float = 3.5) -> void:
	if camera and camera.has_method("shake"):
		camera.shake(trauma, decay)

func cam_push(zoom_mult: float = 1.15, duration: float = 3.0) -> void:
	if camera and camera.has_method("slow_push"):
		camera.slow_push(zoom_mult, duration)

func cam_pan(target_pos: Vector2, duration: float = 0.5, snap: bool = false) -> void:
	if camera and camera.has_method("pan_to"):
		camera.pan_to(target_pos, duration, snap)

func cam_reset(duration: float = 0.0) -> void:
	if camera and camera.has_method("reset_framing"):
		camera.reset_framing(duration)

# =============================================================================
# SFX HELPER
# =============================================================================
func play_sfx(sfx_id: String, vol_offset: float = 0.0) -> void:
	if audio_system and audio_system.has_method("play"):
		audio_system.play(sfx_id, vol_offset)

# =============================================================================
# DOODLE HELPER SHORTCUTS
# =============================================================================
func spawn_speech_bubble(pos: Vector2, text: String, col: Color = INK_MAIN, flip_tail: bool = false, dur: float = 0.20) -> Node2D:
	if doodles and doodles.has_method("spawn_speech_bubble"):
		return doodles.spawn_speech_bubble(pos, text, col, flip_tail, dur)
	return null

func spawn_action_burst(pos: Vector2, text: String, col: Color = INK_RED, dur: float = 0.18) -> Node2D:
	if doodles and doodles.has_method("spawn_action_burst"):
		return doodles.spawn_action_burst(pos, text, col, dur)
	return null

func spawn_sweat_drops(pos: Vector2, count: int = 3, dur: float = 0.25) -> Node2D:
	if doodles and doodles.has_method("spawn_sweat_drops"):
		return doodles.spawn_sweat_drops(pos, count, dur)
	return null

func spawn_push_dust(pos: Vector2, dur: float = 0.25) -> Node2D:
	if doodles and doodles.has_method("spawn_push_dust"):
		return doodles.spawn_push_dust(pos, dur)
	return null

func spawn_sparkles(pos: Vector2, count: int = 4, dur: float = 0.22) -> Node2D:
	if doodles and doodles.has_method("spawn_sparkles"):
		return doodles.spawn_sparkles(pos, count, dur)
	return null

func spawn_confusion_marks(pos: Vector2, dur: float = 0.25) -> Node2D:
	if doodles and doodles.has_method("spawn_confusion_marks"):
		return doodles.spawn_confusion_marks(pos, dur)
	return null

func spawn_handwritten_note(text_str: String, pos: Vector2, font_sz: int = 24, col: Color = INK_MAIN, tilt: float = -3.0, underline: bool = true) -> Node2D:
	if doodles and doodles.has_method("spawn_handwritten_note"):
		return doodles.spawn_handwritten_note(text_str, pos, font_sz, col, tilt, underline)
	return null

## Updates subtitles based on audio master playback time
func update_subtitles_for_time(audio_time: float) -> void:
	var active_card: Dictionary = {}
	for c in _beat_cards:
		if audio_time >= c["start"] and audio_time <= c["end"]:
			active_card = c
			break

	if not active_card.is_empty():
		if subtitle_label.text != active_card["text"]:
			subtitle_label.text = active_card["text"]
	else:
		# Spoken pause: clear subtitles immediately (no drift!)
		if subtitle_label.text != "":
			subtitle_label.text = ""

func finish_beat() -> void:
	if subtitle_label:
		subtitle_label.text = ""
	beat_finished.emit()
