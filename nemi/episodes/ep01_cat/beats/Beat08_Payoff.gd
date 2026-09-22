extends Node2D
class_name Ep01Beat08Payoff

## Beat 8: The Payoff (67.32s – 75.12s | 7.80s)
## Dialogue Segments 016 - 017:
## "And finally... this really lovely family came in and adopted her on the spot."
## "Her name was Neeko."
## Visual Direction:
## - Search clutter resolves into ONE warm forever home drawing
## - Neeko trots happily into the doorway
## - Sincere eye contact & hand on heart on "Her name was Neeko"
## - Black ink title with pink heart: "NEEKO ♥ HOME"
## - Soft chime accent & quiet heartfelt pause hold

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
var neeko: Node2D
var sfx_player: AudioStreamPlayer

func _ready() -> void:
	doodle_director = NemiDoodleDirectorClass.new()
	doodle_director.name = "DoodleDirector"
	add_child(doodle_director)
	
	neeko = preload("res://nemi/characters/neeko/Neeko.tscn").instantiate()
	neeko.position = Vector2(680, 520)
	neeko.scale = Vector2(0.85, 0.85)
	add_child(neeko)
	neeko.set_state("happy_loaf")
	
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	if subtitle_label:
		subtitle_label.text = ""
	if is_standalone:
		call_deferred("start_beat")

func start_beat() -> void:
	print("--- EPISODE 01 BEAT 8: THE PAYOFF STARTED (67.32s - 75.12s) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://nemi/episodes/ep01_cat/audio/EP01_voice.wav")
		voice_player.play(67.32)
	
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	nemi.position = Vector2(490, 480)
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
	
	# SEGMENT 016 (5.68s + 0.40s pause = 6.08s)
	# "And finally..." (1.40s) / "this really lovely family" (1.50s) / "came in and" (1.00s) / "adopted her" (0.90s) / "on the spot." (0.88s)
	nemi.set_expression("happy")
	nemi.blink(0.3)
	
	# One warm forever home draws on in black ink with pink heart
	if doodle_director:
		doodle_director.house(Vector2(810, 390), 40.0, 0.30)
		doodle_director.heart(Vector2(810, 325), 24.0, 0.22)
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "016", self)
	
	await wait_seconds(2.90) # "And finally..." (1.40s) + "this really lovely family" (1.50s)
	
	# Neeko trots happily toward the home; Nemi beams with radiant joy
	nemi.set_expression("excited")
	nemi.show_sparkles("head_right", 2, 1.5)
	if neeko.has_method("trot_to"):
		neeko.trot_to(Vector2(775, 520), 1.6)
	
	await wait_seconds(2.78) # "came in and" (1.00s) + "adopted her" (0.90s) + "on the spot." (0.88s)
	await wait_seconds(0.40) # pause
	
	# SEGMENT 017 (1.12s + 0.60s pause = 1.72s)
	# "Her name was Neeko." (1.12s)
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(530, 410), 1.25, 0.20)
	
	# Hand gently on chest, soft sincere head tilt, tender loving eye contact
	nemi.hand_on_chest(0.20)
	nemi.set_expression("happy")
	nemi.look("center")
	nemi.head_tilt(5.0, 0.25)
	
	if doodle_director:
		doodle_director.label("NEEKO ♥ HOME", Vector2(740, 420), 0.22)
	
	if sfx_player:
		sfx_player.stream = load("res://common/audio/sfx/stings/sting_magic_sparkle_chime_01.wav")
		sfx_player.play()
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "017", self)
	
	await wait_seconds(1.12) # dialogue finishes
	
	# 0.60s quiet heartfelt pause hold
	nemi.freeze_stillness(0.60)
	await wait_seconds(0.60)
	
	if doodle_director:
		doodle_director.clear_all(0.20)
	
	print("--- BEAT 8 COMPLETED (7.80s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.1)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
