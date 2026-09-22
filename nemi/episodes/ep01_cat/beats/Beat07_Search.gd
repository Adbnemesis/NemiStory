extends Node2D
class_name Ep01Beat07Search

## Beat 7: The Search (56.68s – 67.32s | 10.64s)
## Dialogue Segments 014 - 015:
## "Meanwhile, I was texting everyone I knew, putting up little drawings..."
## "and asking every single customer who walked into the shop."
## Visual Direction:
## - VISUAL PEAK: Hand-drawn Search Montage drawing itself in black ink!
## - Phone prop held with screen tapping
## - Message bubble "CAT??" -> House 1 -> Arrow -> House 2 -> Arrow -> House 3
## - Adoption flyer with little cat head doodle
## - Nemi counting fingers & communicative shrug

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
var phone_prop: Node2D

func _ready() -> void:
	doodle_director = NemiDoodleDirectorClass.new()
	doodle_director.name = "DoodleDirector"
	add_child(doodle_director)
	
	if subtitle_label:
		subtitle_label.text = ""
	if is_standalone:
		call_deferred("start_beat")

func start_beat() -> void:
	print("--- EPISODE 01 BEAT 7: THE SEARCH STARTED (56.68s - 67.32s) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://nemi/episodes/ep01_cat/audio/EP01_voice.wav")
		voice_player.play(56.68)
	
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	nemi.position = Vector2(490, 480)
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.WIDE, 0.20)
	
	# SEGMENT 014 (5.04s + 0.35s pause = 5.39s)
	# "Meanwhile, I was texting" (1.70s) / "everyone I knew," (1.54s) / "putting up little drawings..." (1.80s)
	nemi.set_expression("confused")
	nemi.look("down_right")
	
	# Nemi holds hand up as if tapping phone
	nemi.point("right", "fast")
	
	# Spawn phone & message doodle
	if doodle_director:
		doodle_director.arrow(Vector2(530, 420), Vector2(620, 360), 0.22, true)
		doodle_director.label("CAT??", Vector2(645, 345), 0.20)
		
	Episode01Subtitles.play_segment(subtitle_label, nemi, "014", self)
	
	await wait_seconds(1.70) # "Meanwhile, I was texting"
	
	# House 1 & 2 draw onto scene in black ink
	if doodle_director:
		doodle_director.house(Vector2(730, 290), 30.0, 0.24)
		doodle_director.arrow(Vector2(760, 290), Vector2(815, 310), 0.20, false)
		doodle_director.house(Vector2(845, 310), 30.0, 0.24)
	
	await wait_seconds(1.54) # "everyone I knew,"
	
	# On "putting up little drawings..." adoption flyer with cat head doodle draws on!
	# Nemi face lights up with bright artistic excitement
	nemi.set_expression("excited")
	nemi.look("up_right")
	nemi.point("right", "normal")
	
	if doodle_director:
		doodle_director.cat_silhouette(Vector2(720, 420), 28.0, 0.22)
		doodle_director.label("HOME?", Vector2(720, 460), 0.18)
		doodle_director.arrow(Vector2(760, 420), Vector2(815, 420), 0.20, false)
		doodle_director.house(Vector2(845, 420), 30.0, 0.24)
	
	await wait_seconds(1.80) # "putting up little drawings..."
	await wait_seconds(0.35) # pause
	
	# SEGMENT 015 (4.80s + 0.45s pause = 5.25s)
	# "and asking every" (1.20s) / "single customer" (1.20s) / "who walked into" (1.10s) / "the shop." (1.30s)
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(580, 400), 1.18, 0.20)
	
	# Communicative, pleading expression
	nemi.set_expression("confused")
	nemi.look("center")
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "015", self)
	
	await wait_seconds(1.20) # "and asking every"
	await wait_seconds(1.20) # "single customer"
	await wait_seconds(1.10) # "who walked into"
	
	# Flustered shrug with fond smile on "the shop."
	nemi.set_expression("smug")
	nemi.shrug(0.6)
	
	await wait_seconds(1.30) # "the shop."
	
	# 0.45s pause hold
	nemi.freeze_stillness(0.45)
	await wait_seconds(0.45)
	
	if doodle_director:
		doodle_director.clear_all(0.20)
	
	print("--- BEAT 7 COMPLETED (10.64s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.1)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
