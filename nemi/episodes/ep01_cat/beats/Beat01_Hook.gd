extends Node2D
class_name Ep01Beat01Hook

## Beat 1: The Hook (0:00.00 – 0:02.96 | 2.96s)
## Dialogue Segment 001: "Wait. I used to have a cat."
## Visual Direction:
## - Eyes dart from off-screen directly into lens, quick blink
## - Forward lean + open palm gesture on hook interruption
## - Subtle doodle cat silhouette outline on "a cat."
## - Strict <= 5 words per subtitle card

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
	print("--- EPISODE 01 BEAT 1: THE HOOK STARTED (0:00.00 - 0:02.96) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://nemi/episodes/ep01_cat/audio/EP01_voice.wav")
		voice_player.play(0.0)
	
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.WIDE, 0.0)
	
	nemi.set_pose("neutral")
	nemi.set_expression("confused")
	nemi.look("center")
	
	# Attention hook: eyes dart to camera, quick blink
	await wait_seconds(0.10)
	nemi.blink(0.15)
	
	# Forward lean on "Wait." with excited/alert eyes
	var tw_lean := create_tween().set_parallel(true)
	tw_lean.tween_property(nemi, "position:y", 468.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.lean(8.0, 0.22)
	nemi.gesture_open_palm("right", 0.25)
	nemi.set_expression("excited")
	
	# Subtitles & Lip-Sync (Segment 001)
	Episode01Subtitles.play_segment(subtitle_label, nemi, "001", self)
	
	# Wait for "Wait." (0.75s)
	await wait_seconds(0.75)
	
	# On "I used to have" -> subtle teasing smirk and head tilt
	nemi.set_expression("smug")
	nemi.head_tilt(5.0, 0.20)
	
	await wait_seconds(0.90) # remaining "I used to have"
	
	# At "a cat." head tilts more, warm happy expression, black ink cat silhouette doodle draws on
	nemi.set_expression("happy")
	nemi.head_tilt(8.0, 0.20)
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.12, 0.18)
	if doodle_director:
		doodle_director.cat_silhouette(Vector2(780, 310), 36.0, 0.24)
	
	# Remaining dialogue time ("a cat.", 0.97s)
	await wait_seconds(0.97)
	
	# 0.40s pause hold: smug knowing stillness with eyes locked on camera
	nemi.set_expression("smug")
	nemi.look("center")
	nemi.freeze_stillness(0.40)
	await wait_seconds(0.40)
	
	if doodle_director:
		doodle_director.clear_all(0.20)
	
	print("--- BEAT 1 COMPLETED (3.12s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.1)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
