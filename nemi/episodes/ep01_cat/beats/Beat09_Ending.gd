extends Node2D
class_name Ep01Beat09Ending

## Beat 9: Ending (75.12s – 81.33s | 6.21s)
## Dialogue Segments 018 - 019:
## "I still think about her sometimes."
## "I'm just really glad I got to help."
## Visual Direction:
## - Reflective upward glance on memory
## - Direct eye contact with viewer on closing line
## - Gentle nod, sincere soft smile into holding stillness into black
## - Zero moralizing, authentic emotional payoff

signal beat_finished()

const Episode01Subtitles = preload("res://nemi/episodes/ep01_cat/Episode01Subtitles.gd")

@export var is_standalone: bool = false

@onready var nemi = $Nemi
@onready var camera = $StoryCamera2D
@onready var world = $WorldSystem
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

func _ready() -> void:
	if subtitle_label:
		subtitle_label.text = ""
	if is_standalone:
		call_deferred("start_beat")

func start_beat() -> void:
	print("--- EPISODE 01 BEAT 9: THE ENDING STARTED (75.12s - 81.33s) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://nemi/episodes/ep01_cat/audio/EP01_voice.wav")
		voice_player.play(75.12)
	
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	nemi.position = Vector2(640, 480)
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
	
	# SEGMENT 018 (2.16s + 0.35s pause = 2.51s)
	# "I still think about" (1.10s) / "her sometimes." (1.06s)
	nemi.look("up_left")
	nemi.head_tilt(-5.0, 0.3)
	nemi.set_expression("happy")
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "018", self)
	
	await wait_seconds(2.16) # dialogue finishes
	await wait_seconds(0.35) # pause
	
	# SEGMENT 019 (3.20s + 0.50s pause = 3.70s)
	# "I'm just really glad" (1.60s) / "I got to help." (1.60s)
	nemi.look("center")
	nemi.head_tilt(0.0, 0.2)
	nemi.set_expression("happy")
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "019", self)
	
	await wait_seconds(1.60) # "I'm just really glad"
	
	# Gentle sincere nod on "I got to help."
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.nod(4.0, 0.3)
	
	await wait_seconds(1.60) # "I got to help."
	
	# Final quiet heartfelt stillness hold
	nemi.freeze_stillness(0.50)
	await wait_seconds(0.50)
	
	print("--- BEAT 9 COMPLETED (6.21s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.1)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
