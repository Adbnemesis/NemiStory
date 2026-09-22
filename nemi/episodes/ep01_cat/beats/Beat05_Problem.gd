extends Node2D
class_name Ep01Beat05Problem

## Beat 5: The Problem (32.25s – 41.72s | 9.47s)
## Dialogue Segments 009 - 010:
## "I wanted to keep her so badly."
## "Then my parents took one look and said: absolutely not."
## Visual Direction:
## - Sincere clutched hands with tiny pink heart & house sketch
## - Parental rejection: sudden camera punch 1.45x
## - Instant 0-frame posture collapse, horizontal dash mouth
## - Black ink cross-out over house with "NO PETS" label
## - 0.8s deadpan freeze in complete comedic silence

signal beat_finished()

const Episode01Subtitles = preload("res://nemi/episodes/ep01_cat/Episode01Subtitles.gd")
const NemiDoodleDirectorClass = preload("res://nemi/world/doodles/NemiDoodleDirector.gd")

@export var is_standalone: bool = false

@onready var nemi = $Nemi
@onready var camera = $StoryCamera2D
@onready var world = $WorldSystem
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

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
	print("--- EPISODE 01 BEAT 5: THE PROBLEM STARTED (32.25s - 41.72s) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://nemi/episodes/ep01_cat/audio/EP01_voice.wav")
		voice_player.play(32.25)
	
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	nemi.position = Vector2(600, 480)
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
	
	# SEGMENT 009 (3.76s + 0.35s pause = 4.11s)
	# "I wanted to keep her" (1.90s) / "so badly." (1.86s)
	nemi.hands_together()
	nemi.set_expression("sad")
	nemi.set_eye_openness(1.2)
	
	# Tiny pink heart & hand-drawn house sketch
	if doodle_director:
		doodle_director.heart(Vector2(750, 330), 26.0, 0.22)
		doodle_director.house(Vector2(810, 360), 36.0, 0.28)
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "009", self)
	
	await wait_seconds(1.90) # "I wanted to keep her"
	await wait_seconds(1.86) # "so badly."
	await wait_seconds(0.35) # pause
	
	# SEGMENT 010 (4.56s + 0.80s pause = 5.36s)
	# "Then my parents" (1.30s) / "took one look" (1.20s) / "and said:" (0.86s) / "absolutely not." (1.20s)
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(620, 370), 1.25, 0.20)
	
	# Nervous flustered hesitation on parents
	nemi.set_expression("embarrassed")
	nemi.look("left")
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "010", self)
	
	await wait_seconds(1.30) # "Then my parents"
	await wait_seconds(1.20) # "took one look"
	
	# On "and said:" posture stiffens in shock
	nemi.set_expression("shocked")
	nemi.look("center")
	
	await wait_seconds(0.86) # "and said:"
	
	# During "absolutely not." (1.20s):
	# Nemi delivers emphatic parental quotation with punchy mouth articulation
	nemi.set_expression("shocked")
	nemi.look("center")
	await wait_seconds(0.95) # "ab-so-lute-ly"
	
	# ON "NOT!" punch: Sudden camera punch, instant 0-frame collapse, big black cross!
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(640, 380), 1.45, 0.05)
		
	nemi.collapse(0.85, 0.12)
	
	if doodle_director:
		doodle_director.clear_all(0.08)
		doodle_director.house(Vector2(810, 360), 36.0, 0.10)
		doodle_director.cross(Vector2(810, 360), 44.0, 0.10)
		doodle_director.label("NO PETS", Vector2(810, 420), 0.12)
	
	# Level 2 sadness rain drop marks
	nemi.fx("sad", "head_top", 2, 2.0)
	
	await wait_seconds(0.25) # "not." concludes phrase (0.95s + 0.25s = 1.20s)
	
	# Speech finished: lock in pure deadpan expression (half-lidded unblinking eyes, flat dash mouth)
	nemi.stop_speech("neutral")
	nemi.set_expression("deadpan")
	
	# Complete deadpan stillness hold for 0.80s in pure comedic silence
	await wait_seconds(0.80)
	
	if doodle_director:
		doodle_director.clear_all(0.20)
	
	print("--- BEAT 5 COMPLETED (9.47s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.1)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
