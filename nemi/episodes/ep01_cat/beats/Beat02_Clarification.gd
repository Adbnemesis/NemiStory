extends Node2D
class_name Ep01Beat02Clarification

## Beat 2: The Clarification (2.96s – 10.78s | 7.82s)
## Dialogue Segments 002 & 003
## Visual Direction:
## - Defensive shrug on "Okay—not like that."
## - Head shake on "I didn't buy one."
## - Eye shift recalling memory, pointing gesture
## - Mailbox sketch doodle with arrow pointing behind

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
	print("--- EPISODE 01 BEAT 2: THE CLARIFICATION STARTED (2.96s - 10.78s) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://nemi/episodes/ep01_cat/audio/EP01_voice.wav")
		voice_player.play(2.96)
	
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.WIDE, 0.20)
	
	# SEGMENT 002 (2.00s + 0.30s pause = 2.30s)
	# "Okay—not like that." (1.10s) / "I didn't buy one." (0.90s)
	nemi.shrug(0.7)
	nemi.set_expression("annoyed")
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "002", self)
	
	# Wait for "Okay—not like that." (1.10s)
	await wait_seconds(1.10)
	
	# On "I didn't buy one.", emphatic head shake, deadpan horizontal dash mouth
	nemi.shake_head(0.5, 2)
	nemi.set_expression("deadpan")
	
	await wait_seconds(0.90) # dialogue ends
	
	# 0.30s pause between segments: transition to memory
	await wait_seconds(0.30)
	
	# SEGMENT 003 (6.24s + 0.40s pause = 6.64s)
	# "I was sixteen" (1.60s) / "when I found her," (1.50s) / "abandoned behind" (1.50s) / "a row of mailboxes." (1.64s)
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(600, 360), 1.15, 0.20)
	
	# On "I was sixteen", warm nostalgic smile, dark ink "AGE 16" annotation draws on with arrow
	nemi.set_expression("happy")
	nemi.head_tilt(4.0, 0.20)
	if doodle_director:
		doodle_director.label("AGE 16", Vector2(490, 310), 0.22)
		doodle_director.arrow(Vector2(490, 335), Vector2(560, 375), 0.20, true)
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "003", self)
	
	await wait_seconds(1.60) # "I was sixteen"
	
	# Nemi eyes look up-right remembering, points right on "when I found her"
	nemi.look("up_right")
	nemi.point("right", "normal")
	
	await wait_seconds(1.50) # "when I found her,"
	
	# On "abandoned behind...", expression shifts to tender, sorrowful empathy
	nemi.set_expression("sad")
	nemi.look("right")
	if doodle_director:
		doodle_director.arrow(Vector2(680, 370), Vector2(820, 330), 0.25, true)
		doodle_director.label("MAILBOXES", Vector2(850, 310), 0.22)
	
	await wait_seconds(3.14) # "abandoned behind" (1.50s) + "a row of mailboxes." (1.64s)
	
	# 0.40s pause hold: holding empathetic gaze
	nemi.freeze_stillness(0.40)
	await wait_seconds(0.40)
	
	if doodle_director:
		doodle_director.clear_all(0.20)
	
	print("--- BEAT 2 COMPLETED (8.94s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.1)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
