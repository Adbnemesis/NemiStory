extends Node2D
class_name Beat03Struggle

## Beat 3: The Animation Struggle (00:31.54 – 00:50.51 | 19.77s total with pause)
## Dialogue Segments 009 - 012
## Visual Direction Overhaul V2:
## - "As it turns out: extraordinarily hard." -> Instant comedic posture collapse
## - Stylus prop in hand -> skeptical inspection
## - "three invisible banana peels" -> Visual Cutaway (CutawayBananaPeels doodle slips 3 times)
## - "...In slow motion." -> Snap camera zoom into deadpan Nemi, 0.80s absolute unmoving stillness freeze
## - All subtitles strictly <= 5 words via Episode00Subtitles
## - Live illustrative lip-sync active

signal beat_finished()

const Episode00Subtitles = preload("res://episodes/ep00_introduction/Episode00Subtitles.gd")
const CutawayBananaPeelsClass = preload("res://episodes/ep00_introduction/cutaways/CutawayBananaPeels.gd")
const NemiDoodleDirectorClass = preload("res://world/doodles/NemiDoodleDirector.gd")
const DoodleInstanceClass = preload("res://world/doodles/DoodleInstance.gd")

@export var is_standalone: bool = false

@onready var nemi = $Nemi
@onready var camera = $StoryCamera2D
@onready var world = $WorldSystem
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var bg_rect: ColorRect = $Background

var stylus_prop: Node2D
var banana_cutaway: Node2D
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
	print("--- BEAT 3 V2: ANIMATION STRUGGLE STARTED (00:31.54 - 00:51.31) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://animations/ep00_introduction/voiceover/voiceover.wav")
		voice_player.play(31.54)
	
	_run_beat3_choreography()

func _run_beat3_choreography() -> void:
	# -------------------------------------------------------------------------
	# INITIAL STAGING & COOL GRAY DESATURATED BACKGROUND
	# -------------------------------------------------------------------------
	if bg_rect:
		bg_rect.color = Color("#e2e5ea")
	
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(640, 370), 1.15, 0.2)
	
	# -------------------------------------------------------------------------
	# SEGMENT 009 (00:31.54 - 00:34.50, pause 0.35s)
	# "As it turns out:" (1.30s) / "extraordinarily hard." (1.66s)
	# -------------------------------------------------------------------------
	# Instant 0-frame comedic posture collapse
	nemi.position.y = 495.0
	nemi.set_expression("frown")
	nemi.collapse(1.2, 0.22)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "009", self)
	
	await wait_seconds(3.31) # 2.96s duration + 0.35s pause = 3.31s (Reaches 34.85s)
	
	# -------------------------------------------------------------------------
	# SEGMENT 010 (00:34.85 - 00:45.01, pause 0.35s)
	# "I spent four hours" / "yesterday inbetweening" / "an arm movement." /
	# "And by the end," / "my character" / "wasn't walking."
	# -------------------------------------------------------------------------
	# Stylus prop pops into hand
	stylus_prop = preload("res://episodes/ep00_introduction/props/PropStylus.gd").new()
	stylus_prop.position = Vector2(560, 480)
	add_child(stylus_prop)
	stylus_prop.pop_in(0.2)
	
	# Hand-drawn animation timeline & arm sketch doodle
	if doodle_director:
		doodle_director.underline(Vector2(430, 400), 130.0, 0.25)
		doodle_director.arrow(Vector2(440, 440), Vector2(510, 400), 0.22)
		doodle_director.label("FRAME 14", Vector2(440, 465), 0.20, DoodleInstanceClass.StylePreset.SUBTLE)
	
	# Nemi sketches intensely, looking down with deep concentration then skepticism
	nemi.set_expression("skeptical")
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.tilt(-8.0, 0.3)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("down_left")
	
	# Frustration & sweat drop on "four hours inbetweening"
	nemi.fx("sweat", "head_right", 2, 2.5)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "010", self)
	
	await wait_seconds(4.5)
	# Weary frustration on "my character wasn't walking" -> wavy mouth, head shake, scribbled cross doodle
	nemi.set_expression("wavy")
	nemi.fx("anger", "head_right", 2, 2.2)
	if doodle_director:
		doodle_director.cross(Vector2(490, 410), 34.0, 0.20)
	if nemi.actor and nemi.actor.head and nemi.actor.head.has_method("shake"):
		nemi.actor.head.shake(0.6, 2)
	
	await wait_seconds(6.01) # Remainder reaches 45.36s
	
	# Clear doodles before cutaway starts
	if doodle_director:
		doodle_director.clear_all(0.20)
	
	# -------------------------------------------------------------------------
	# SEGMENT 011 (00:45.36 - 00:49.04, pause 0.35s)
	# "It looked like" / "they were slipping" / "on three" / "invisible banana peels."
	# -------------------------------------------------------------------------
	# CUTAWAY SCENE: Failed walk cycle doodle slips on 3 banana peels!
	banana_cutaway = CutawayBananaPeelsClass.new()
	banana_cutaway.position = Vector2(640, 340)
	add_child(banana_cutaway)
	
	# Fade Nemi slightly to highlight illustrated cutaway
	var tw_nemi := create_tween()
	tw_nemi.tween_property(nemi, "modulate:a", 0.25, 0.2)
	
	# Play the hilarious cutaway sequence
	banana_cutaway.play_sequence(3.68)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "011", self)
	
	await wait_seconds(3.68) # Dialogue duration reaches 49.04s
	
	# 0.35s pause hold
	await wait_seconds(0.35) # Reaches 49.39s
	
	# -------------------------------------------------------------------------
	# SEGMENT 012 (00:49.39 - 00:50.51, pause 0.80s)
	# "...In slow motion." (1.12s)
	# -------------------------------------------------------------------------
	# Dismiss cutaway and bring Nemi back with tight reaction closeup (1.60x)
	if is_instance_valid(banana_cutaway):
		banana_cutaway.queue_free()
	
	var tw_nemi_back := create_tween().set_parallel(true)
	tw_nemi_back.tween_property(nemi, "modulate:a", 1.0, 0.12)
	if camera and camera.has_method("reaction_closeup"):
		camera.reaction_closeup(nemi.global_position, 1.60, 0.12)
	elif camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(640, 360), 1.60, 0.0)
	
	# Head straight, eyes snap directly into viewer, absolute deadpan stare
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.turn(0.0, "fast")
		nemi.actor.head.tilt(0.0, 0.1)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("center")
	
	nemi.set_expression("deadpan")
	# Hard Rule: Restrained deadpan - NO unnecessary FX, NO three-dot ellipsis
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "012", self)
	
	await wait_seconds(1.12) # Reaches 50.51s
	
	# 0.80s ABSOLUTE UNMOVING STILLNESS FREEZE
	# Zero hair sway, zero breathing, zero camera motion. Silence is the punchline.
	nemi.freeze_stillness(0.80)
	await wait_seconds(0.80) # Reaches 51.31s
	
	if is_instance_valid(stylus_prop):
		stylus_prop.queue_free()
	
	print("--- BEAT 3 V3 COMPLETED (51.31s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.5)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	if DisplayServer.get_name() == "headless":
		await get_tree().create_timer(duration).timeout
	else:
		var frames: int = int(round(duration * 60.0))
		for i in range(frames):
			await RenderingServer.frame_post_draw
