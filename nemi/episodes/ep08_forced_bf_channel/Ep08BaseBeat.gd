class_name Ep08BaseBeat
extends Node2D

## Ep08BaseBeat — Master Authoritative Base Class for Episode 08 Beat Scenes
## "I FORCED MY BF TO CREATE A CHANNEL"
##
## Integrated production services:
## - Hand-drawn studio environment (Ep08Backdrop)
## - Hand-authored stroke-by-stroke ink doodles (Ep08Doodles)
## - Production SFX Audio System (NemiAudio)
## - Dynamic Storytelling Camera (StoryCamera)
## - Deterministic frame-accurate subtitle sequencer (<= 5 words per card)
## - Floor grounding & physics contact shadows at Y = 840.0
## - Seamless dual character orchestration (Nemi, Old ADB, New ADB)

signal beat_finished()

const Episode08SubtitlesClass = preload("res://nemi/episodes/ep08_forced_bf_channel/Episode08Subtitles.gd")
const Ep08BackdropClass = preload("res://nemi/episodes/ep08_forced_bf_channel/Ep08Backdrop.gd")
const Grounding = preload("res://common/storytime/production/ActingTimeline.gd")
const Ep08DoodlesClass = preload("res://nemi/episodes/ep08_forced_bf_channel/Ep08Doodles.gd")
const NemiAudioClass = preload("res://nemi/world/audio/NemiAudio.gd")
const StoryCameraClass = preload("res://common/engine/camera/StoryCamera.gd")

const NemiScene = preload("res://nemi/characters/nemi/nemi.tscn")
const OldADBScene = preload("res://nemi/characters/old_adb/OldADB.tscn")
const NewADBScene = preload("res://adb/characters/adb/ADB.tscn")

const INK_MAIN: Color = Color("#2b2623")
const INK_SOFT: Color = Color("#594f4b")
const INK_RED: Color = Color("#b84328")
const INK_GOLD: Color = Color("#d35400")
const INK_BLUE: Color = Color("#2980b9")

const FLOOR_Y: float = 840.0
const NEMI_BASE_Y: float = 586.25 # Scale 1.25 keeps feet at 840.0
const NEW_ADB_BASE_Y: float = 599.78 # Scale 1.25 keeps sneakers at 840.0
const OLD_ADB_BASE_Y: float = 582.6 # Existing shoe sole is local Y=195; scale 1.32 grounds it at 840.

@export var is_standalone: bool = true
@export var beat_number: int = 1
@export var beat_name: String = "Beat"

var nemi: Node2D
var old_adb: Node2D
var new_adb: Node2D

var camera: Camera2D
var backdrop: Node2D
var doodles: Node2D
var props_layer: Node2D
var fg_props_layer: Node2D
var audio_system: Node
var subtitle_label: Label
var floor_shadows: Node2D

var _grounding := Grounding.new()

var _beat_cards: Array[Dictionary] = []
var _beat_frame: int = -1
var _capture_frame: int = 0
var _beat_start: float = 0.0
var _live_elapsed: float = 0.0
var _sound_events: Array = []
var _sound_index: int = 0
var _next_blink: int = 0
const BLINKS: Array[float] = [2.4, 5.2, 8.3, 11.6, 15.0, 18.1]

# =============================================================================
# GROUND CONTACT SHADOWS (At Floor Y = 840.0)
# =============================================================================
class Ep08FloorShadows extends Node2D:
	var _beat: Ep08BaseBeat
	func _init(b: Ep08BaseBeat) -> void:
		_beat = b
	func _process(_delta: float) -> void:
		queue_redraw()
	func _draw() -> void:
		if not _beat:
			return

		# 1. Nemi shadow
		if is_instance_valid(_beat.nemi) and _beat.nemi.visible:
			var nx: float = _beat.nemi.position.x
			draw_set_transform(Vector2(nx, FLOOR_Y), 0.0, Vector2(1.0, 0.22))
			draw_circle(Vector2.ZERO, 52.0, Color(0.18, 0.12, 0.10, 0.15))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

		# 2. Old ADB shadow
		if is_instance_valid(_beat.old_adb) and _beat.old_adb.visible:
			var ox: float = _beat.old_adb.position.x
			draw_set_transform(Vector2(ox, FLOOR_Y), 0.0, Vector2(1.0, 0.22))
			draw_circle(Vector2.ZERO, 58.0, Color(0.18, 0.12, 0.10, 0.15))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

		# 3. New ADB shadow
		if is_instance_valid(_beat.new_adb) and _beat.new_adb.visible:
			var ax: float = _beat.new_adb.position.x
			draw_set_transform(Vector2(ax, FLOOR_Y), 0.0, Vector2(1.0, 0.24))
			draw_circle(Vector2.ZERO, 64.0, Color(0.18, 0.12, 0.10, 0.16))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# =============================================================================
# SETUP
# =============================================================================
func _ready() -> void:
	_setup_environment()
	_setup_characters()
	_setup_camera()
	_setup_subtitles()
	_beat_cards = Episode08SubtitlesClass.get_cards_for_beat(beat_number)
	_grounding.bind(nemi, "nemi")
	nemi.face.exaggeration_mouth_scale = 0.85
	RenderingServer.frame_pre_draw.connect(_plant_nemi_feet)
	get_tree().process_frame.connect(_advance_capture_clock)

	if is_standalone:
		call_deferred("start_beat")

func _setup_environment() -> void:
	# 1. Audio System
	audio_system = NemiAudioClass.new()
	audio_system.name = "AudioSystem"
	add_child(audio_system)

	# 2. Backdrop Environment (z = -10)
	backdrop = Ep08BackdropClass.new()
	backdrop.name = "Backdrop"
	backdrop.z_index = -10
	add_child(backdrop)

	# 3. Floor Shadows (z = -2)
	floor_shadows = Ep08FloorShadows.new(self)
	floor_shadows.name = "FloorShadows"
	floor_shadows.z_index = -2
	add_child(floor_shadows)

	# 4. Background Props Layer (z = 4)
	props_layer = Node2D.new()
	props_layer.name = "PropsLayer"
	props_layer.z_index = 4
	add_child(props_layer)

	# 5. Foreground Props Layer (z = 15)
	fg_props_layer = Node2D.new()
	fg_props_layer.name = "FGPropsLayer"
	fg_props_layer.z_index = 15
	add_child(fg_props_layer)

	# 6. Doodles Layer (z = 25)
	doodles = Ep08DoodlesClass.new()
	doodles.name = "Doodles"
	doodles.z_index = 25
	add_child(doodles)

func _setup_characters() -> void:
	# Nemi rig (z = 5)
	nemi = NemiScene.instantiate()
	nemi.name = "Nemi"
	nemi.scale = Vector2(1.25, 1.25)
	nemi.position = Vector2(680, NEMI_BASE_Y)
	nemi.z_index = 5
	add_child(nemi)

func setup_old_adb(initial_pos: Vector2 = Vector2(1280, OLD_ADB_BASE_Y)) -> Node2D:
	if not old_adb:
		old_adb = OldADBScene.instantiate()
		old_adb.name = "OldADB"
		old_adb.scale = Vector2(1.32, 1.32)
		old_adb.position = initial_pos
		old_adb.z_index = 4
		add_child(old_adb)
	return old_adb

func setup_new_adb(initial_pos: Vector2 = Vector2(1280, NEW_ADB_BASE_Y)) -> Node2D:
	if not new_adb:
		new_adb = NewADBScene.instantiate()
		new_adb.name = "NewADB"
		new_adb.scale = Vector2(1.25, 1.25)
		new_adb.position = initial_pos
		new_adb.z_index = 4
		add_child(new_adb)
	return new_adb

func _setup_camera() -> void:
	camera = StoryCameraClass.new()
	camera.name = "StoryCamera"
	camera.position = Vector2(960, 540)
	add_child(camera)
	camera.make_current()

func _setup_subtitles() -> void:
	var ui_canvas := CanvasLayer.new()
	ui_canvas.name = "UI"
	ui_canvas.layer = 30
	add_child(ui_canvas)

	subtitle_label = Label.new()
	subtitle_label.name = "SubtitleLabel"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle_label.anchor_left = 0.0
	subtitle_label.anchor_right = 1.0
	subtitle_label.anchor_top = 1.0
	subtitle_label.anchor_bottom = 1.0
	subtitle_label.offset_left = 120
	subtitle_label.offset_right = -120
	subtitle_label.offset_top = -120
	subtitle_label.offset_bottom = -40

	subtitle_label.add_theme_font_size_override("font_size", 52)
	subtitle_label.add_theme_color_override("font_color", Color("#ffffff"))
	subtitle_label.add_theme_color_override("font_outline_color", INK_MAIN)
	subtitle_label.add_theme_constant_override("outline_size", 7)
	subtitle_label.text = ""

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

func _plant_nemi_feet() -> void:
	if is_instance_valid(nemi): _grounding.plant_feet(nemi, "nemi")

func _advance_capture_clock() -> void:
	if _beat_frame >= 0: _capture_frame += 1
	if "--ep08-export" in OS.get_cmdline_user_args():
		RenderingServer.force_draw.call_deferred(false,1.0/30.0)

func _process(delta: float) -> void:
	if _beat_frame < 0:
		return
	_live_elapsed += delta
	var elapsed := float(_capture_frame) / 30.0 if "--ep08-export" in OS.get_cmdline_user_args() else _live_elapsed
	while _sound_index < _sound_events.size() and float(_sound_events[_sound_index].at) <= _beat_start + elapsed:
		var cue: Dictionary = _sound_events[_sound_index]
		_sound_index += 1
		# Offline mux uses this exact schedule; avoid a second audio path during capture.
		if "--ep08-export" not in OS.get_cmdline_user_args():
			var player = audio_system.play(cue.sfx_id, float(cue.gain_db) - audio_system.sfx_volume_db, 1.0)
			if is_instance_valid(player):
				var stop := create_tween()
				stop.tween_interval(float(cue.duration))
				stop.tween_callback(func():
					if is_instance_valid(player): player.stop()
				)
	if _next_blink < BLINKS.size() and elapsed >= BLINKS[_next_blink]:
		_next_blink += 1
		if is_instance_valid(nemi): nemi.blink(0.12)
		if is_instance_valid(new_adb): new_adb.blink(0.12)

func start_beat() -> void:
	_beat_frame = Engine.get_process_frames()
	_live_elapsed = 0.0
	_capture_frame = 0
	_beat_start = float(_beat_cards[0].start)
	var sound_plan: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://nemi/episodes/ep08_forced_bf_channel/sfx_cues.json"))
	for cue in sound_plan.events:
		if int(cue.beat) == beat_number: _sound_events.append(cue)
	print("--- EPISODE 08 BEAT %d: %s STARTED ---" % [beat_number, beat_name.to_upper()])
	if camera:
		camera.make_current()
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	pass

func end_beat() -> void:
	if subtitle_label:
		subtitle_label.text = ""
		subtitle_label.visible = false
	print("--- EPISODE 08 BEAT %d: %s COMPLETED at frame %d ---" % [beat_number, beat_name.to_upper(), _capture_frame])
	beat_finished.emit()
	if is_standalone:
		await wait_seconds(0.2)
		get_tree().quit(0)

# =============================================================================
# DETERMINISTIC TIMING & SUBTITLE SYNCHRONIZATION
# =============================================================================
func wait_seconds(duration: float) -> void:
	if duration <= 0.001: return
	for i in range(maxi(1, int(round(duration * 30.0)))):
		await get_tree().process_frame

func wait_until(scene_time: float) -> void:
	var target := int(round((scene_time - _beat_start) * 30.0))
	if "--ep08-export" in OS.get_cmdline_user_args():
		while _capture_frame < target:
			await get_tree().process_frame
	else:
		while _live_elapsed < scene_time - _beat_start:
			await get_tree().process_frame

func cue_card(card: Dictionary) -> void:
	# Clear the previous mouth/caption during the original pause, then act ON the new cue.
	subtitle_label.text = ""
	subtitle_label.visible = false
	if is_instance_valid(nemi): nemi.stop_speech()
	if is_instance_valid(new_adb): new_adb.stop_speaking()
	await wait_until(float(card.start))

func _run_card(card: Dictionary) -> void:
	var dur: float = card["end"] - card["start"]
	var mood: String = card.get("mood", "normal")
	var speaker: String = card.get("speaker", "nemi")

	if subtitle_label and is_instance_valid(subtitle_label):
		subtitle_label.visible = true
		subtitle_label.text = card["text"]

	if speaker == "adb":
		if new_adb and is_instance_valid(new_adb) and new_adb.has_method("start_speaking"):
			new_adb.start_speaking(dur)
	else:
		if nemi and is_instance_valid(nemi) and nemi.has_method("speak"):
			nemi.speak(card["text"], dur, mood)

	await wait_until(float(card.end))

func play_card_sync(card: Dictionary, current_time: float) -> float:
	var c_start: float = card["start"]
	var c_end: float = card["end"]
	print("[CARD] (frame %d) Playing card '%s' [%.3f - %.3f]" % [_capture_frame, card["text"], c_start, c_end])

	if c_start > current_time + 0.005:
		var gap: float = c_start - current_time
		if subtitle_label and is_instance_valid(subtitle_label):
			subtitle_label.visible = false
			subtitle_label.text = ""
		if nemi and is_instance_valid(nemi) and nemi.has_method("stop_speech"):
			nemi.stop_speech()
		if new_adb and is_instance_valid(new_adb) and new_adb.has_method("stop_speaking"):
			new_adb.stop_speaking()
		await wait_until(c_start)

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
		if new_adb and is_instance_valid(new_adb) and new_adb.has_method("stop_speaking"):
			new_adb.stop_speaking()
		await wait_until(beat_end_time)
	end_beat()

# =============================================================================
# AUDIO SFX API
# =============================================================================
func play_sfx(sfx_id: String, vol_offset: float = 0.0, pitch: float = 1.0) -> void:
	if audio_system and audio_system.has_method("play"):
		audio_system.play(sfx_id, vol_offset, pitch)

# =============================================================================
# CAMERA HELPERS
# =============================================================================
func cam_punch(zoom_mult: float = 1.25, snap: bool = true, target_pos: Vector2 = Vector2.INF) -> void:
	if camera and camera.has_method("punch_in"):
		camera.punch_in(zoom_mult, snap, target_pos)

func cam_push(zoom_mult: float = 1.15, duration: float = 2.5) -> void:
	if camera and camera.has_method("slow_push"):
		camera.slow_push(zoom_mult, duration)

func cam_pan(target_pos: Vector2, duration: float = 0.4, snap: bool = false) -> void:
	if camera and camera.has_method("pan_to"):
		camera.pan_to(target_pos, duration, snap)

func cam_reset(duration: float = 0.25) -> void:
	if camera and camera.has_method("reset_framing"):
		camera.reset_framing(duration)

func cam_shake(trauma: float = 0.5, decay: float = 3.5) -> void:
	if camera and camera.has_method("shake"):
		camera.shake(trauma, decay)
