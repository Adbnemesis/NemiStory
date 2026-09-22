extends Node2D
class_name Ep01Beat06Shopkeeper

## Beat 6: The Shopkeeper (41.72s – 56.68s | 14.96s)
## Dialogue Segments 011 - 013:
## "I couldn't just leave her outside."
## "So I convinced the corner shopkeeper to let her stay behind the counter."
## "And for four days, she basically ran the register."
## Visual Direction:
## - Shop mini-scene with shelves, wooden counter, and shopkeeper
## - Nemi explains situation; shopkeeper blinks and nods in approval
## - Neeko perched on counter in "proud_boss" state like a store manager
## - "4 DAYS" black ink doodle sign
## - Brass service bell rings with acoustic doodle lines on "the register"

signal beat_finished()

const Episode01Subtitles = preload("res://nemi/episodes/ep01_cat/Episode01Subtitles.gd")
const NemiDoodleDirectorClass = preload("res://nemi/world/doodles/NemiDoodleDirector.gd")
const PropShopCounterClass = preload("res://nemi/episodes/ep01_cat/props/PropShopCounter.gd")

@export var is_standalone: bool = false

@onready var nemi = $Nemi
@onready var camera = $StoryCamera2D
@onready var world = $WorldSystem
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

var doodle_director: Node2D
var shop_counter: Node2D
var neeko: Node2D
var sfx_player: AudioStreamPlayer

func _ready() -> void:
	doodle_director = NemiDoodleDirectorClass.new()
	doodle_director.name = "DoodleDirector"
	add_child(doodle_director)
	
	shop_counter = PropShopCounterClass.new()
	shop_counter.position = Vector2(780, 480)
	add_child(shop_counter)
	
	neeko = preload("res://nemi/characters/neeko/Neeko.tscn").instantiate()
	neeko.position = Vector2(815, 420)
	neeko.scale = Vector2(0.78, 0.78)
	add_child(neeko)
	neeko.set_state("proud_boss")
	
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	if subtitle_label:
		subtitle_label.text = ""
	if is_standalone:
		call_deferred("start_beat")

func start_beat() -> void:
	print("--- EPISODE 01 BEAT 6: THE SHOPKEEPER STARTED (41.72s - 56.68s) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://nemi/episodes/ep01_cat/audio/EP01_voice.wav")
		voice_player.play(41.72)
	
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	nemi.position = Vector2(490, 480)
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.WIDE, 0.20)
	
	# SEGMENT 011 (1.84s + 0.30s pause = 2.14s)
	# "I couldn't just" (0.90s) / "leave her outside." (0.94s)
	nemi.shake_head(0.7, 2)
	nemi.set_expression("annoyed")
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "011", self)
	
	await wait_seconds(1.84) # dialogue finishes
	await wait_seconds(0.30) # pause
	
	# SEGMENT 012 (4.24s + 0.35s pause = 4.59s)
	# "So I convinced" (1.10s) / "the corner shopkeeper" (1.20s) / "to let her stay" (0.94s) / "behind the counter." (1.00s)
	nemi.point("right", "normal")
	nemi.set_expression("smug")
	nemi.show_lightbulb("head_top", 2, 1.2)
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "012", self)
	
	await wait_seconds(1.10) # "So I convinced"
	
	# On "the corner shopkeeper", shopkeeper blinks and nods approvingly at Neeko!
	if shop_counter and shop_counter.has_method("nod_shopkeeper"):
		shop_counter.nod_shopkeeper(0.7)
	nemi.set_expression("happy")
	
	await wait_seconds(1.20) # "the corner shopkeeper"
	
	# Tiny lightbulb idea doodle in black ink
	if doodle_director:
		doodle_director.circle(Vector2(530, 320), 22.0, 0.20)
	
	await wait_seconds(1.94) # "to let her stay" (0.94s) + "behind the counter." (1.00s)
	
	if doodle_director:
		doodle_director.clear_all(0.15)
		
	await wait_seconds(0.35) # pause
	
	# SEGMENT 013 (7.68s + 0.55s pause = 8.23s)
	# "And for four days," (2.40s) / "she basically ran" (2.40s) / "the register." (2.88s)
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(660, 420), 1.25, 0.25)
	
	if doodle_director:
		doodle_director.label("4 DAYS", Vector2(815, 325), 0.22)
	
	nemi.set_expression("happy")
	Episode01Subtitles.play_segment(subtitle_label, nemi, "013", self)
	
	await wait_seconds(2.40) # "And for four days,"
	
	# Highly amused smirk toward store-manager Neeko
	nemi.set_expression("smug")
	nemi.look("right")
	nemi.head_tilt(6.0, 0.20)
	
	await wait_seconds(2.40) # "she basically ran"
	
	# On "the register." counter bell rings!
	if shop_counter and shop_counter.has_method("ring_bell"):
		shop_counter.ring_bell()
	if doodle_director:
		doodle_director.direction_lines(Vector2(720, 430), 20.0, 0.18)
	if sfx_player:
		sfx_player.stream = load("res://common/audio/sfx/stings/sting_bell_notification_01.wav")
		sfx_player.play()
	
	await wait_seconds(2.88) # finishes dialogue
	
	# 0.55s pause hold: proud holding smirk
	nemi.freeze_stillness(0.55)
	await wait_seconds(0.55)
	
	if doodle_director:
		doodle_director.clear_all(0.20)
	
	print("--- BEAT 6 COMPLETED (14.96s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.1)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
