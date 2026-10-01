class_name Ep07BaseBeat
extends Node2D

## Ep07BaseBeat - Authoritative Base Class for Episode 07 Beat Scenes
## "I GOT 0 MARKS IN MY EXAM"
##
## Provides full production services:
## - Multi-mode rich hand-drawn studio environment (Ep07Backdrop)
## - Integrated physical props library (NemiPropLibrary & HumanProps)
## - Integrated stroke-by-stroke ink doodles (Ep07Doodles)
## - Production Audio SFX System (NemiAudio)
## - Dynamic storytelling camera (StoryCamera2D)
## - Frame-accurate deterministic subtitle sequencer (<= 5 words per card)

signal beat_finished()

const Episode07SubtitlesClass = preload("res://nemi/episodes/ep07_zero_marks/Episode07Subtitles.gd")
const Ep07BackdropClass = preload("res://nemi/episodes/ep07_zero_marks/Ep07Backdrop.gd")
const Ep07DoodlesClass = preload("res://nemi/episodes/ep07_zero_marks/Ep07Doodles.gd")
const NemiAudioClass = preload("res://nemi/world/audio/NemiAudio.gd")
const NemiPropLibraryClass = preload("res://nemi/world/props/NemiPropLibrary.gd")
const HumanProps = preload("res://nemi/world/props/HumanProps.gd")
const StoryCamera2D = preload("res://nemi/world/camera/StoryCamera2D.gd")

const MODE_NORMAL_STUDIO: int = 0
const MODE_COVID_ONLINE: int = 1
const MODE_COLLEGE_HALLWAY: int = 2
const MODE_PROCRASTINATION: int = 3
const MODE_EMAIL_PANIC: int = 4
const MODE_MIDNIGHT_STUDY: int = 5
const MODE_EXAM_HALL: int = 6
const MODE_WRITING_FRENZY: int = 7
const MODE_ZERO_REVEAL: int = 8
const MODE_WARM_WRAPUP: int = 9

const INK_MAIN: Color = Color("#2e1822")
const INK_SOFT: Color = Color("#6b5763")
const INK_RED: Color = Color("#d63031")
const INK_GOLD: Color = Color("#d35400")
const INK_BLUE: Color = Color("#0984e3")
const INK_MINT: Color = Color("#009470")

@export var is_standalone: bool = false
@export var beat_number: int = 1
@export var beat_name: String = "Beat"

@onready var nemi = get_node_or_null("Nemi")
@onready var camera = get_node_or_null("StoryCamera2D")
@onready var subtitle_label: Label = get_node_or_null("UI/Subtitle")
@onready var voice_player: AudioStreamPlayer = get_node_or_null("VoicePlayer")

var backdrop: Node2D
var doodle_director: Node2D
var props_layer: Node2D
var bg_props_layer: Node2D
var fg_props_layer: Node2D
var floor_shadows: Node2D
var audio_system: Node

var r_hand: Node2D
var l_hand: Node2D

var _blink_timer: float = 2.4
var _nemi_base_y: float = 480.0

class Ep07FloorShadows extends Node2D:
	var _beat: Ep07BaseBeat
	func _init(b: Ep07BaseBeat) -> void:
		_beat = b
	func _process(_delta: float) -> void:
		queue_redraw()
	func _draw() -> void:
		if not _beat or not is_instance_valid(_beat.nemi):
			return
		var nx: float = _beat.nemi.position.x
		# Feet contact ground at base_y + 194
		var ny: float = _beat.nemi.position.y + 194.0
		draw_set_transform(Vector2(nx, ny), 0.0, Vector2(1.0, 0.26))
		draw_circle(Vector2.ZERO, 40.0, Color(0.18, 0.08, 0.12, 0.14))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _ready() -> void:
	var ws = get_node_or_null("WorldSystem")
	if ws:
		remove_child(ws)
		ws.queue_free()

	# 1. Audio System
	audio_system = NemiAudioClass.new()
	audio_system.name = "AudioSystem"
	add_child(audio_system)

	# 2. Backdrop Environment
	backdrop = Ep07BackdropClass.new()
	backdrop.name = "Backdrop"
	backdrop.z_index = -5
	add_child(backdrop)
	move_child(backdrop, 0)

	# 3. Background Props Layer (z = -1, behind Nemi)
	bg_props_layer = Node2D.new()
	bg_props_layer.name = "BGPropsLayer"
	bg_props_layer.z_index = -1
	add_child(bg_props_layer)
	props_layer = bg_props_layer

	# Floor Contact Shadows (z = 0)
	floor_shadows = Ep07FloorShadows.new(self)
	floor_shadows.name = "FloorShadows"
	floor_shadows.z_index = 0
	add_child(floor_shadows)

	# Foreground Props Layer (z = 15, in front of Nemi)
	fg_props_layer = Node2D.new()
	fg_props_layer.name = "FGPropsLayer"
	fg_props_layer.z_index = 15
	add_child(fg_props_layer)

	# 4. Doodles Layer (z = 25 in front of character)
	doodle_director = Ep07DoodlesClass.new()
	doodle_director.name = "Ep07Doodles"
	doodle_director.z_index = 25
	add_child(doodle_director)

	# 5. Hand Bones for Props
	if nemi:
		r_hand = nemi.right_hand_bone if ("right_hand_bone" in nemi and nemi.right_hand_bone) else nemi.get_node_or_null("Skeleton2D/RootBone/TorsoBone/RightUpperArmBone/RightLowerArmBone/RightHandBone")
		l_hand = nemi.left_hand_bone if ("left_hand_bone" in nemi and nemi.left_hand_bone) else nemi.get_node_or_null("Skeleton2D/RootBone/TorsoBone/LeftUpperArmBone/LeftLowerArmBone/LeftHandBone")
		_nemi_base_y = nemi.position.y

	# 6. Subtitle Styling
	if subtitle_label:
		subtitle_label.visible = false
		subtitle_label.text = ""
		subtitle_label.add_theme_font_size_override("font_size", 34)
		subtitle_label.add_theme_color_override("font_color", Color("#fffef5"))
		subtitle_label.add_theme_color_override("font_outline_color", Color("#1a0a10"))
		subtitle_label.add_theme_constant_override("outline_size", 10)
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		subtitle_label.z_index = 35
		subtitle_label.offset_top = -62.0
		subtitle_label.offset_bottom = -14.0

	if is_standalone:
		call_deferred("start_beat")

func _process(delta: float) -> void:
	if not is_instance_valid(nemi):
		return
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_blink_timer = randf_range(2.4, 4.0)
		if nemi.has_method("blink"):
			nemi.blink(0.14)

func start_beat() -> void:
	print("--- EPISODE 07 BEAT %d: %s STARTED ---" % [beat_number, beat_name.to_upper()])
	if camera:
		camera.make_current()
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	pass

func end_beat() -> void:
	if subtitle_label:
		subtitle_label.text = ""
		subtitle_label.visible = false
	print("--- EPISODE 07 BEAT %d: %s COMPLETED at frame %d ---" % [beat_number, beat_name.to_upper(), Engine.get_process_frames()])
	beat_finished.emit()
	if is_standalone:
		await wait_seconds(0.2)
		get_tree().quit(0)

# -----------------------------------------------------------------------------
# AUDIO SFX API
# -----------------------------------------------------------------------------
func play_sfx(sfx_id: String, vol_offset: float = 0.0, pitch: float = 1.0) -> void:
	if audio_system and audio_system.has_method("play"):
		audio_system.play(sfx_id, vol_offset, pitch)

# -----------------------------------------------------------------------------
# PROPS API
# -----------------------------------------------------------------------------
func spawn_prop(prop_id: String, pos: Vector2, parent_layer: Node2D = null, is_foreground: bool = false) -> Node2D:
	var p: Node2D = NemiPropLibraryClass.create_prop(prop_id)
	if not p:
		return null
	p.position = pos
	var target_parent = parent_layer if parent_layer else (fg_props_layer if is_foreground else bg_props_layer)
	target_parent.add_child(p)
	return p

# -----------------------------------------------------------------------------
# ENVIRONMENT TRANSITION
# -----------------------------------------------------------------------------
func transition_backdrop(m: int, dur: float = 0.35) -> void:
	if backdrop and backdrop.has_method("set_mode"):
		backdrop.set_mode(m, dur)

# -----------------------------------------------------------------------------
# DETERMINISTIC FRAME-ACCURATE TIMING
# -----------------------------------------------------------------------------
func wait_seconds(duration: float) -> void:
	var frames: int = maxi(1, int(round(duration * 30.0)))
	for i in range(frames):
		await get_tree().process_frame

func _run_card(card: Dictionary) -> void:
	var dur: float = card["end"] - card["start"]
	var mood: String = card.get("mood", "normal")
	if subtitle_label and is_instance_valid(subtitle_label):
		subtitle_label.visible = true
		subtitle_label.text = card["text"]
	if nemi and is_instance_valid(nemi) and nemi.has_method("speak"):
		nemi.speak(card["text"], dur, mood)
	await wait_seconds(dur)

func play_card_sync(card: Dictionary, current_time: float) -> float:
	var c_start: float = card["start"]
	var c_end: float = card["end"]
	if c_start > current_time + 0.005:
		var gap: float = c_start - current_time
		if subtitle_label and is_instance_valid(subtitle_label):
			subtitle_label.visible = false
			subtitle_label.text = ""
		if nemi and is_instance_valid(nemi) and nemi.has_method("stop_speech"):
			nemi.stop_speech()
		await wait_seconds(gap)
	await _run_card(card)
	return c_end

func finish_beat_sync(current_time: float, beat_end_time: float) -> void:
	if beat_end_time > current_time + 0.005:
		var tail: float = beat_end_time - current_time
		if subtitle_label and is_instance_valid(subtitle_label):
			subtitle_label.visible = false
			subtitle_label.text = ""
		if nemi and is_instance_valid(nemi) and nemi.has_method("stop_speech"):
			nemi.stop_speech()
		await wait_seconds(tail)
	end_beat()

# -----------------------------------------------------------------------------
# CAMERA HELPERS
# -----------------------------------------------------------------------------
func cam_preset(preset: StoryCamera2D.ShotPreset, dur: float = 0.25, target: Node2D = null) -> void:
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(preset, dur, target)

func cam_punch(target_offset: Vector2 = Vector2.ZERO, zoom_mult: float = 1.25, dur: float = 0.18) -> void:
	if camera and camera.has_method("punch_in"):
		camera.punch_in(camera.position + target_offset, zoom_mult, dur)
	elif camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, dur)

func cam_push_in(zoom_delta: float = 0.12, dur: float = 2.5) -> void:
	if camera and camera.has_method("push_in"):
		camera.push_in(zoom_delta, dur)

func cam_shake(intensity: float = 6.0, dur: float = 0.35) -> void:
	if camera and camera.has_method("shake"):
		camera.shake(intensity, dur)

func cam_reset(dur: float = 0.3) -> void:
	if camera:
		var tw := create_tween().set_parallel(true)
		tw.tween_property(camera, "rotation", 0.0, dur)
		if camera.has_method("apply_preset"):
			camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, dur)
