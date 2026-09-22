class_name Ep04BaseBeat
extends Node2D

## Base Class for Episode 04 Beat Scenes: "Guys, I'm Scared."
## Provides:
## - Continuous lifelike character motion (organic idle breathing, natural blinks, micro-sways) to prevent ANY visual freezes.
## - Integrated cozy artist studio backdrop (warm sketchbook paper, desk, tablet, window, 2 AM night mode).
## - Hand-drawn live draw-on stroke helpers and comic expression FX.
## - Subtitle card sequencing (<= 5 words per card) and deterministic MovieWriter timing.

signal beat_finished()

const Episode04SubtitlesClass = preload("res://nemi/episodes/ep04_scared/Episode04Subtitles.gd")
const NemiDoodleDirectorClass = preload("res://nemi/world/doodles/NemiDoodleDirector.gd")
const Ep04DoodlesClass = preload("res://nemi/episodes/ep04_scared/Ep04Doodles.gd")
const Ep04StudioBackdropClass = preload("res://nemi/episodes/ep04_scared/Ep04StudioBackdrop.gd")

@export var is_standalone: bool = false
@export var beat_number: int = 1
@export var beat_name: String = "Beat"

@onready var nemi = get_node_or_null("Nemi")
@onready var camera = get_node_or_null("StoryCamera2D")
@onready var world = get_node_or_null("WorldSystem")
@onready var subtitle_label: Label = get_node_or_null("UI/Subtitle")
@onready var voice_player: AudioStreamPlayer = get_node_or_null("VoicePlayer")

var studio_backdrop: Ep04StudioBackdrop
var doodle_director: Node2D

# Lifelike character motion state
var enable_lifelike_breathing: bool = true
var _breath_time: float = 0.0
var _blink_timer: float = 2.5
var _nemi_base_torso_rot: float = 0.0
var _nemi_base_head_rot: float = 0.0
var _nemi_base_y: float = 480.0

func _ready() -> void:
	# 1. Remove default WorldSystem Environment so our illustrated studio backdrop renders!
	if world:
		var env = world.get_node_or_null("Environment")
		if env:
			env.visible = false
			env.queue_free()

	# 2. Spawn cozy artist studio backdrop
	studio_backdrop = Ep04StudioBackdropClass.new()
	studio_backdrop.name = "StudioBackdrop"
	studio_backdrop.z_index = -5
	add_child(studio_backdrop)
	move_child(studio_backdrop, 0)
	
	# Foreground desk (added to beat root at z_index = 5 so it sorts above Nemi's skirt/legs)
	if is_instance_valid(studio_backdrop.foreground_desk):
		add_child(studio_backdrop.foreground_desk)
	
	# 3. Spawn doodle director for hand-drawn accents
	doodle_director = NemiDoodleDirectorClass.new()
	doodle_director.name = "DoodleDirector"
	add_child(doodle_director)

	
	if subtitle_label:
		subtitle_label.visible = false
		subtitle_label.text = ""
		var font: FontFile = Ep04Doodles.get_handwriting_font(false)
		if font:
			subtitle_label.add_theme_font_override("font", font)
		subtitle_label.add_theme_font_size_override("font_size", 34)
		subtitle_label.add_theme_color_override("font_color", Color("#fffef5"))
		subtitle_label.add_theme_color_override("font_outline_color", Color("#200b14"))
		subtitle_label.add_theme_constant_override("outline_size", 7)
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		subtitle_label.z_index = 25
		
	if nemi:
		_nemi_base_y = nemi.position.y
		
	if is_standalone:
		call_deferred("start_beat")

func _process(delta: float) -> void:
	if not enable_lifelike_breathing or not is_instance_valid(nemi):
		return
		
	_breath_time += delta
	
	# 1. Subtle rhythmic chest/torso breathing cycle (~2.2s gentle sine wave)
	var breath_phase: float = sin(_breath_time * 2.8)
	var breath_bob: float = breath_phase * 1.6 # subtle 1.6px vertical breathing rise/fall
	nemi.position.y = _nemi_base_y + breath_bob
	
	# Micro torso & head compensation (subtle 0.015 rad rotation)
	if nemi.torso_bone:
		nemi.torso_bone.rotation += breath_phase * 0.008 * delta
	if nemi.head_bone:
		nemi.head_bone.rotation += -breath_phase * 0.005 * delta
		
	# 2. Natural automatic blinking cycle (every 2.8 to 4.2 seconds)
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_blink_timer = randf_range(2.8, 4.2)
		if nemi.has_method("blink"):
			nemi.blink(0.14)

func start_beat() -> void:
	print("--- EPISODE 04 BEAT %d: %s STARTED ---" % [beat_number, beat_name.to_upper()])
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	pass

func end_beat() -> void:
	if doodle_director:
		doodle_director.clear_all(0.20)
	if subtitle_label:
		subtitle_label.text = ""
		subtitle_label.visible = false
	print("--- EPISODE 04 BEAT %d: %s COMPLETED at frame %d ---" % [beat_number, beat_name.to_upper(), Engine.get_process_frames()])
	beat_finished.emit()
	if is_standalone:
		await wait_seconds(0.2)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	var frames: int = maxi(1, int(round(duration * 30.0)))
	for i in range(frames):
		await get_tree().process_frame

func play_segment(seg_id: String) -> void:
	Episode04SubtitlesClass.play_segment(subtitle_label, nemi, seg_id, self)

func _run_subtitle_cards(label: Label, character: Node2D, cards: Array) -> void:
	for c in cards:
		var dur: float = c["duration"]
		var emo: String = c.get("emotion", "normal")
		if label and is_instance_valid(label):
			label.visible = true
			label.text = c["text"]
		if character and is_instance_valid(character) and character.has_method("speak"):
			character.speak(c["text"], dur, emo)
		await wait_seconds(dur)
	if label and is_instance_valid(label):
		label.visible = false
		label.text = ""

# -----------------------------------------------------------------------------
# DYNAMIC CAMERA HELPERS
# -----------------------------------------------------------------------------

func cam_preset(preset: StoryCamera2D.ShotPreset, dur: float = 0.25, target: Node2D = null) -> void:
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(preset, dur, target)

func cam_punch(arg1: Variant = null, arg2: Variant = null, arg3: Variant = null) -> void:
	if not camera:
		return
	if arg1 is StoryCamera2D.ShotPreset:
		var dur: float = 0.15
		if arg2 is float:
			dur = arg2
		if camera.has_method("apply_preset"):
			camera.apply_preset(arg1, dur)
	elif arg1 is Vector2:
		var target_pos: Vector2 = camera.position + arg1
		var zoom_mult: float = 1.2
		var dur: float = 0.2
		if arg2 is float:
			zoom_mult = arg2
		if arg3 is float:
			dur = arg3
		if camera.has_method("punch_in"):
			camera.punch_in(target_pos, zoom_mult, dur)
		elif camera.has_method("apply_preset"):
			camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, dur)
	else:
		if camera.has_method("apply_preset"):
			camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, 0.15)

func cam_push_in(amount: float = 0.20, dur: float = 3.0) -> void:
	if camera and camera.has_method("push_in"):
		camera.push_in(amount, dur)

func cam_shake(intensity: float = 6.0, dur: float = 0.35, freq: float = 20.0) -> void:
	if camera and camera.has_method("shake"):
		camera.shake(intensity, dur)

func cam_dutch(angle_deg: float = 4.5, dur: float = 0.25) -> void:
	if camera:
		var tw := create_tween()
		tw.tween_property(camera, "rotation", deg_to_rad(angle_deg), dur).set_trans(Tween.TRANS_QUAD)

func cam_reset(dur: float = 0.3) -> void:
	if camera:
		var tw := create_tween().set_parallel(true)
		tw.tween_property(camera, "rotation", 0.0, dur)
		if camera.has_method("apply_preset"):
			camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, dur)

# -----------------------------------------------------------------------------
# NEW STORYTIME PROPS & DOODLE SPAWN HELPERS
# -----------------------------------------------------------------------------

func panic_meter(pos: Vector2 = Vector2(750, 220), dur: float = 2.2) -> Ep04Doodles.DoodlePanicMeter:
	return Ep04DoodlesClass.spawn_panic_meter(self, pos, dur)

func sticky_note(arg1: Variant, arg2: Variant = null, arg3: Variant = null, dur: float = 3.5) -> Ep04Doodles.DoodleStickyNote:
	var pos := Vector2(760, 180)
	var text := "TODO"
	var col := Color("#fff3b0")
	if arg1 is Vector2:
		pos = arg1
		if arg2 is String:
			text = arg2
		if arg3 is Color:
			col = arg3
	elif arg1 is String:
		text = arg1
		if arg2 is Vector2:
			pos = arg2
		if arg3 is Color:
			col = arg3
	return Ep04DoodlesClass.spawn_sticky_note(self, pos, text, col, dur)

func action_bubble(arg1: Variant, arg2: Variant = null, col: Color = Color("#d93b2b"), dur: float = 1.0) -> Ep04Doodles.DoodleActionBubble:
	var pos := Vector2(250, 150)
	var text := "*GASP*"
	if arg1 is Vector2:
		pos = arg1
		if arg2 is String:
			text = arg2
	elif arg1 is String:
		text = arg1
		if arg2 is Vector2:
			pos = arg2
	return Ep04DoodlesClass.spawn_action_bubble(self, pos, text, col, dur)

func heart_burst(pos: Vector2, dur: float = 2.0) -> Ep04Doodles.DoodleHeartBurst:
	return Ep04DoodlesClass.spawn_heart_burst(self, pos, dur)

func facepalm_chibi(pos: Vector2 = Vector2(820, 260), dur: float = 2.4) -> Ep04Doodles.DoodleFacepalmChibi:
	return Ep04DoodlesClass.spawn_facepalm_chibi(self, pos, dur)

func coffee_mug(pos: Vector2 = Vector2(480, 500), dur: float = 4.0) -> Ep04Doodles.DoodleCoffeeMug:
	return Ep04DoodlesClass.spawn_coffee_mug(self, pos, dur)

func notification_buzz(pos: Vector2 = Vector2(800, 380), dur: float = 2.0) -> Ep04Doodles.DoodleNotificationBuzz:
	return Ep04DoodlesClass.spawn_notification_buzz(self, pos, dur)

func cat_mascot(pos: Vector2 = Vector2(380, 520), dur: float = 4.0) -> Node2D:
	return Ep04DoodlesClass.spawn_cat_mascot(self, pos)


# -----------------------------------------------------------------------------
# HIGH-LEVEL COMIC FX & LIVE DRAWING HELPERS
# -----------------------------------------------------------------------------

## Spawn a comic sweat droplet on Nemi's head that pops and drips down
func comic_sweat(local_offset: Vector2 = Vector2(28, -100), dur: float = 1.4) -> Ep04Doodles.ComicSweatDrop:
	if not is_instance_valid(nemi):
		return null
	return Ep04DoodlesClass.spawn_sweat_drop(nemi, local_offset, dur)

## Spawn a bouncing question mark over Nemi's head
func comic_question(local_offset: Vector2 = Vector2(0, -135), dur: float = 1.1) -> Ep04Doodles.ComicQuestionMark:
	if not is_instance_valid(nemi):
		return null
	return Ep04DoodlesClass.spawn_question_mark(nemi, local_offset, dur)

## Spawn comic stress/dread lines down forehead
func comic_stress(local_offset: Vector2 = Vector2(0, -85), dur: float = 1.4) -> Ep04Doodles.ComicStressLines:
	if not is_instance_valid(nemi):
		return null
	return Ep04DoodlesClass.spawn_stress_lines(nemi, local_offset, dur)

## Spawn an animated brain storm cloud / doubt spiral over Nemi
func comic_brain_spiral(local_offset: Vector2 = Vector2(0, -145), dur: float = 2.2) -> Ep04Doodles.ComicBrainSpiral:
	if not is_instance_valid(nemi):
		return null
	return Ep04DoodlesClass.spawn_brain_spiral(nemi, local_offset, dur)

## Spawn an anime throbbing stress/irritation vein 💢
func comic_vein(local_offset: Vector2 = Vector2(30, -115), dur: float = 1.3) -> Ep04Doodles.ComicVeinMark:
	if not is_instance_valid(nemi):
		return null
	return Ep04DoodlesClass.spawn_vein_mark(nemi, local_offset, dur)

## Spawn an exclamation mark (! or ?!)
func comic_exclamation(local_offset: Vector2 = Vector2(0, -135), has_question: bool = false, is_double: bool = false, dur: float = 1.0) -> Ep04Doodles.ComicExclamation:
	if not is_instance_valid(nemi):
		return null
	return Ep04DoodlesClass.spawn_exclamation(nemi, local_offset, has_question, is_double, dur)

## Spawn twinkling sparkles ✨
func comic_sparkles(pos: Vector2, dur: float = 1.4) -> Ep04Doodles.ComicSparkles:
	return Ep04DoodlesClass.spawn_sparkles(self, pos, dur)

## Spawn radiating comic speed/shock rays around Nemi
func comic_burst_rays(pos: Vector2, dur: float = 0.8) -> Ep04Doodles.ComicBurstRays:
	return Ep04DoodlesClass.spawn_burst_rays(self, pos, dur)

## Spawn cute wobbly soul floating out of mouth (for 2 AM exhaustion/cringe)
func comic_soul(local_offset: Vector2 = Vector2(5, -60), dur: float = 2.0) -> Ep04Doodles.ComicSoulFloat:
	if not is_instance_valid(nemi):
		return null
	return Ep04DoodlesClass.spawn_soul_float(nemi, local_offset, dur)

## Spawn a hand-drawn comic emoticon bubble (>_<, -_-, O_O)
func comic_emoticon(pos: Vector2, face_str: String = ">_<", dur: float = 1.3) -> Ep04Doodles.ComicEmoticonBubble:
	return Ep04DoodlesClass.spawn_emoticon(self, pos, face_str, dur)

## Spawn a cartoon inspiration lightbulb 💡
func comic_lightbulb(local_offset: Vector2 = Vector2(0, -145), dur: float = 1.3) -> Ep04Doodles.ComicLightbulb:
	if not is_instance_valid(nemi):
		return null
	return Ep04DoodlesClass.spawn_lightbulb(nemi, local_offset, dur)

## Quick trigger for Nemi's built-in facial reaction + Bone recoil system
func nemi_react(reaction_name: String, intensity: int = 3, duration: float = 1.3) -> void:
	if is_instance_valid(nemi) and nemi.has_method("react"):
		nemi.react(reaction_name, intensity, duration)

## Draw an organic hand-drawn wavy underline live onto the screen
func draw_live_wavy_underline(start_pt: Vector2, width: float, dur: float = 0.3) -> Ep04Doodles.HandDrawnStroke:
	var pts := PackedVector2Array()
	var waves: int = maxi(3, int(width / 16.0))
	for i in range(waves * 4):
		var frac: float = float(i) / float(waves * 4)
		var x: float = start_pt.x + frac * width
		var y: float = start_pt.y + sin(frac * float(waves) * TAU) * 4.5
		pts.append(Vector2(x, y))
	var stroke := Ep04Doodles.HandDrawnStroke.new(pts, Color("#d93b2b"), 3.2, 1.8)
	add_child(stroke)
	stroke.animate_draw_on(dur)
	return stroke

## Switch studio backdrop into 2:00 AM dark blue night mode
func set_night_mode(enabled: bool, dur: float = 0.5) -> Signal:
	if studio_backdrop and studio_backdrop.has_method("set_night_mode"):
		return studio_backdrop.set_night_mode(enabled, dur)
	return get_tree().process_frame

