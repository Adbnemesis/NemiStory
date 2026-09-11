extends Node2D
class_name Beat04Hobbies

## Beat 4: Hobbies as Story Fuel (00:51.31 – 01:17.37 | 26.41s total with pause)
## Dialogue Segments 013 - 015
## Visual Direction V3 (Expression FX Upgrade):
## - Gym mini comedy sketch:
##   CONFIDENCE (excitement sparkles) -> OVERCONFIDENCE (anime hero, face_exaggerate excitement)
##   -> STRUGGLE (sweat FX, tremor) -> PANIC (panic FX + anger marks) -> DEFEAT (collapse, DOMS ACTIVATED)
## - Car singing sketch:
##   PropCarEnvironment with rolling window
##   Over-the-top operatic singing with eyes closed & hand on heart (relief sigh FX)
##   Window rolls down, mail carrier doodle appears
##   High G vibrato -> mail carrier shock lines -> camera reaction_closeup
##   -> Nemi shock FX + embarrassment blush + face_exaggerate + mortification freeze
## - All subtitles strictly <= 5 words via Episode00Subtitles
## - Live illustrative lip-sync active
## - Visual Density: Calm (singing) -> Active (gym) -> Peak (mortification) -> Empty (freeze)

signal beat_finished()

const Episode00Subtitles = preload("res://episodes/ep00_introduction/Episode00Subtitles.gd")
const PropCarEnvironmentClass = preload("res://episodes/ep00_introduction/cutaways/PropCarEnvironment.gd")
const NemiDoodleDirectorClass = preload("res://world/doodles/NemiDoodleDirector.gd")
const DoodleInstanceClass = preload("res://world/doodles/DoodleInstance.gd")

@export var is_standalone: bool = false

@onready var nemi = $Nemi
@onready var camera = $StoryCamera2D
@onready var world = $WorldSystem
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var bg_rect: ColorRect = $Background

var dumbbell_prop: Node2D
var car_env: Node2D
var doms_badge: Node2D
var doodle_director: Node2D

func _ready() -> void:
	doodle_director = NemiDoodleDirectorClass.new()
	doodle_director.name = "DoodleDirector"
	add_child(doodle_director)
	if subtitle_label:
		subtitle_label.text = ""
	if is_standalone:
		call_deferred("start_beat")

func start_beat() -> void:
	print("--- BEAT 4 V2: HOBBIES AS STORY FUEL STARTED (00:51.31 - 01:17.72) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://animations/ep00_introduction/voiceover/voiceover.wav")
		voice_player.play(51.31)
	
	_run_beat4_choreography()

func _run_beat4_choreography() -> void:
	# -------------------------------------------------------------------------
	# SEGMENT 013 (00:51.31 - 01:01.23, pause 0.35s)
	# Gym Comedy Sketch:
	# "I go to the gym." (1.4s) / "Where I walk in" (1.1s) / "with the confidence" (1.1s) /
	# "of an anime hero" (1.3s) / "in a tournament arc..." (1.3s) /
	# "and walk out" (1.0s) / "two sets later" (1.0s) / "completely paralyzed" (0.82s) / "by leg day." (0.9s)
	# -------------------------------------------------------------------------
	# 1. Background swap to Solid Crimson #753239
	if bg_rect:
		bg_rect.color = Color("#753239")
	
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(640, 370), 1.15, 0.2)
	
	# Dumbbell drops next to Nemi
	dumbbell_prop = preload("res://episodes/ep00_introduction/props/PropDumbbell.gd").new()
	dumbbell_prop.position = Vector2(780, 580)
	add_child(dumbbell_prop)
	dumbbell_prop.drop_in(580.0, 0.28)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "013", self)
	
	# Chunk 1: "I go to the gym." -> Nemi glances at dumbbell
	nemi.set_expression("neutral")
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("down_right")
	await wait_seconds(1.4)
	
	# Chunks 2-5: Anime hero overconfidence! Excitement sparkles + face exaggeration
	nemi.chest_puff(0.25)
	nemi.set_expression("smug")
	nemi.fx("excitement", "head_left", 3, 4.5) # Radiant sparkles for entire hero moment
	nemi.face_exaggerate("excitement", 2, 3.0) # Subtle confident eye widening
	if nemi.actor and nemi.actor.face:
		nemi.actor.face.set_accent("sparkles", true)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("center")
	
	# Camera slow push during confidence buildup
	if camera and camera.has_method("push_in"):
		camera.push_in(0.08, 4.5)
	await wait_seconds(4.8) # Through tournament arc...
	
	if nemi.actor and nemi.actor.face:
		nemi.actor.face.set_accent("sparkles", false)
	
	# Chunks 6-7: "and walk out two sets later" -> Initial struggle & tremor
	nemi.set_expression("wavy")
	nemi.fx("sweat", "head_right", 2, 2.5) # Nervous sweat drops appear
	nemi.tremble(0.4, 2.0)
	await wait_seconds(2.0)
	
	# Chunks 8-9: "completely paralyzed by leg day." -> Severe tremor, posture collapses, dumbbell drops!
	nemi.set_expression("frown")
	nemi.fx("panic", "head_top", 3, 1.5) # Panic lines radiate outward
	nemi.fx("shock", "head_top", 4, 0.9) # Impact shock lines on drop/collapse
	nemi.fx("anger", "head_right", 2, 1.5) # Frustration cross marks
	nemi.face_exaggerate("panic", 3, 1.0) # Eyes go wide, brows compress
	nemi.collapse(1.3, 0.22)
	nemi.tremble(0.8, 1.72)
	
	# Camera subtle punch on the punchline
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.08, 0.18)
		
	# Hand-drawn leg day strain marks and label
	if doodle_director:
		doodle_director.shake_marks(Vector2(600, 530), 28.0, 0.20)
		doodle_director.shake_marks(Vector2(680, 530), 28.0, 0.20)
		doodle_director.label("LEG DAY", Vector2(460, 520), 0.20, DoodleInstanceClass.StylePreset.COMEDIC)
	
	doms_badge = _create_badge("*DOMS ACTIVATED*", Vector2(360, 320), Color("#992030"))
	add_child(doms_badge)
	nemi.fx("stress", "head_left", 2, 1.5) # Small comedic reaction mark on DOMS ACTIVATED
	
	await wait_seconds(1.72) # Reaches 1:01.23
	
	# Pause hold
	await wait_seconds(0.35) # Reaches 1:01.58
	
	# -------------------------------------------------------------------------
	# SEGMENT 014 (01:01.58 - 01:08.14, pause 0.35s)
	# Car Singing:
	# "And I sing." (1.3s) / "Mostly in my car" (1.7s) / "with the windows" (1.6s) / "rolled up." (1.96s)
	# -------------------------------------------------------------------------
	# Clean up gym props and doodles
	if is_instance_valid(dumbbell_prop): dumbbell_prop.queue_free()
	if is_instance_valid(doms_badge): doms_badge.queue_free()
	if doodle_director: doodle_director.clear_all(0.20)
	
	# Return background to Pale Cream Wash
	if bg_rect: bg_rect.color = Color("#faf7f5")
	
	# Reset Nemi posture
	nemi.position.y = 480.0
	nemi.set_pose("neutral")
	
	# Spawn Car Environment (door, window, steering wheel)
	car_env = PropCarEnvironmentClass.new()
	car_env.position = Vector2(500, 380)
	add_child(car_env)
	
	# Camera shifts slightly to frame car & Nemi
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(620, 360), 1.2, 0.3)
	
	# Operatic singing: Hand on chest, eyes closed passionately
	nemi.hand_on_chest(0.25)
	nemi.set_expression("smile")
	nemi.fx("relief", "head_right", 2, 5.5) # Gentle sigh/relief aura during passionate singing
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("normal")
		
	# Floating musical notes while singing
	if doodle_director:
		doodle_director.mini("note", Vector2(450, 270), 28.0, 0.35)
		doodle_director.mini("note", Vector2(495, 230), 24.0, 0.35)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "014", self)
	
	# Gentle continuous singing sway with the music throughout the 6.56s phrase (4 sway cycles of 1.64s each)
	for i in range(4):
		var target_head_rot: float = 6.0 if i % 2 == 0 else -6.0
		var target_body_lean: float = 1.5 if i % 2 == 0 else -1.5
		if nemi.actor and nemi.actor.head:
			nemi.actor.head.tilt(target_head_rot, 1.4)
		if nemi.actor and nemi.actor.body:
			nemi.actor.body.lean(target_body_lean, 1.4)
		if i == 2 and nemi.actor and nemi.actor.eyes:
			nemi.actor.eyes.blink("soft")
		await wait_seconds(1.64)
	
	# 0.35s pause reaches 1:08.49
	await wait_seconds(0.35)
	
	# -------------------------------------------------------------------------
	# SEGMENT 015 (01:08.49 - 01:17.37, pause 0.35s)
	# "...Except last Tuesday" (1.5s) / "when the window" (1.1s) / "was not rolled up," (1.2s) /
	# "and a mail carrier" (1.2s) / "heard me hit" (1.0s) / "a high G" (1.0s) / "with absolute vibrato." (1.88s)
	# -------------------------------------------------------------------------
	Episode00Subtitles.play_segment(subtitle_label, nemi, "015", self)
	
	# Window rolls down smoothly while Nemi is singing passionately
	if is_instance_valid(car_env):
		car_env.roll_down_window(2.5)
	
	await wait_seconds(3.8) # Through "was not rolled up,"
	
	# "and a mail carrier" -> Mail carrier doodle appears outside
	await wait_seconds(1.2)
	
	# "heard me hit a high G with absolute vibrato."
	# Mail carrier gets shocked!
	if is_instance_valid(car_env):
		car_env.shock_mail_carrier()
		
	# Vibrato swirl doodle on high G
	if doodle_director:
		doodle_director.swirl(Vector2(535, 240), 28.0, 0.22)
	
	# Camera snaps to reaction closeup for the mortification reveal
	if camera and camera.has_method("reaction_closeup"):
		camera.reaction_closeup(nemi.global_position, 1.55, 0.14)
		
	# Clear musical doodles on shock snap
	if doodle_director:
		doodle_director.clear_all(0.18)
		
	# Nemi realizes, head snaps sharply left, eyes wide, mortification freeze!
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.turn(-18.0, "fast")
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("left")
	nemi.set_expression("shocked")
	nemi.fx("shock", "head_top", 4, 1.8) # Impact shock lines
	nemi.fx("sweat", "head_right", 2, 2.2) # Realization sweat drop
	nemi.fx("embarrassment", "cheeks", 3, 3.5) # Deep mortification blush
	nemi.face_exaggerate("shock", 3, 1.5) # Maximum eyes-wide, brow compression
	if nemi.actor and nemi.actor.face:
		nemi.actor.face.set_accent("blush", true)
	
	# Comedic shock freeze hold (pure disbelief)
	await wait_seconds(1.5)
	
	# Settle into sheepish mortification: eyes dart back to camera, quick embarrassed blink
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("center")
		nemi.actor.eyes.blink("quick")
	# Hard Rule: Restrained mortification hold - NO random three dots
	nemi.fx("sweat", "head_right", 2, 1.8) # Fresh sweat bead trickle
	
	await wait_seconds(1.1)
	
	# Slight guilty head tilt slump
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.tilt(-6.0, 0.35)
	nemi.set_expression("deadpan")
	
	await wait_seconds(1.28) # Reaches 1:17.37
	
	# 0.35s pause hold
	clear_subtitle()
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("soft")
	await wait_seconds(0.35) # Reaches 1:17.72
	
	if is_instance_valid(car_env):
		car_env.queue_free()
	
	nemi.clear_all_fx(true) # Clean up any lingering FX
	print("--- BEAT 4 V3 COMPLETED (1:17.72 / 77.72s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.5)
		get_tree().quit(0)

# --- Helper Methods ---

func clear_subtitle() -> void:
	if subtitle_label:
		subtitle_label.text = ""

func _create_badge(text_content: String, pos: Vector2, accent_color: Color) -> Node2D:
	var badge := Node2D.new()
	badge.position = pos
	badge.scale = Vector2(0.2, 0.2)
	badge.modulate.a = 0.0
	
	var label := Label.new()
	label.text = text_content
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("#ffffff"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	label.add_theme_constant_override("shadow_offset_y", 2)
	
	var panel := PanelContainer.new()
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = accent_color
	style_box.border_width_bottom = 3
	style_box.border_width_top = 2
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_color = Color("#2b111e")
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	style_box.content_margin_left = 18.0
	style_box.content_margin_right = 18.0
	style_box.content_margin_top = 8.0
	style_box.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", style_box)
	
	panel.add_child(label)
	badge.add_child(panel)
	panel.position = Vector2(-100, -20)
	
	var tw := badge.create_tween().set_parallel(true)
	tw.tween_property(badge, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(badge, "modulate:a", 1.0, 0.15)
	return badge

func wait_seconds(duration: float) -> void:
	if DisplayServer.get_name() == "headless":
		await get_tree().create_timer(duration).timeout
	else:
		var frames: int = int(round(duration * 60.0))
		for i in range(frames):
			await RenderingServer.frame_post_draw
