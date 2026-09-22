extends Node2D
class_name Ep01Beat03Discovery

## Beat 3: The Discovery (10.78s – 21.58s | 10.80s)
## Dialogue Segments 004 & 005
## Visual Direction:
## - Nemi staged left, crouching down to look at Neeko
## - PropCardboardBox with Neeko inside (scared, shivering)
## - Scale comparison gesture ("fit-in-my-pocket tiny")
## - Empathetic facial acting & gentle camera punch-in

signal beat_finished()

const Episode01Subtitles = preload("res://nemi/episodes/ep01_cat/Episode01Subtitles.gd")
const NemiDoodleDirectorClass = preload("res://nemi/world/doodles/NemiDoodleDirector.gd")
const NeekoClass = preload("res://nemi/characters/neeko/Neeko.gd")
const PropCardboardBoxClass = preload("res://nemi/episodes/ep01_cat/props/PropCardboardBox.gd")

@export var is_standalone: bool = false

@onready var nemi = $Nemi
@onready var camera = $StoryCamera2D
@onready var world = $WorldSystem
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

var doodle_director: Node2D
var cardboard_box: Node2D
var neeko: Node2D

func _ready() -> void:
	doodle_director = NemiDoodleDirectorClass.new()
	doodle_director.name = "DoodleDirector"
	add_child(doodle_director)
	
	# Instantiate cardboard box and Neeko inside it
	cardboard_box = PropCardboardBoxClass.new()
	cardboard_box.position = Vector2(760, 505)
	add_child(cardboard_box)
	
	neeko = preload("res://nemi/characters/neeko/Neeko.tscn").instantiate()
	neeko.position = Vector2(760, 485)
	neeko.scale = Vector2(0.85, 0.85)
	add_child(neeko)
	neeko.set_state("scared")
	
	if subtitle_label:
		subtitle_label.text = ""
	if is_standalone:
		call_deferred("start_beat")

func start_beat() -> void:
	print("--- EPISODE 01 BEAT 3: THE DISCOVERY STARTED (10.78s - 21.58s) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://nemi/episodes/ep01_cat/audio/EP01_voice.wav")
		voice_player.play(10.78)
	
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	# Start Nemi walking in from left
	nemi.position = Vector2(460, 480)
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
	
	# Discovery walking step: Nemi steps toward center, stops when noticing box
	var tw_walk := create_tween()
	tw_walk.tween_property(nemi, "position:x", 510.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# SEGMENT 004 (4.56s + 0.35s pause = 4.91s)
	# "She was tiny." (1.80s) / "Like, fit-in-my-pocket" (1.40s) / "tiny." (1.36s)
	nemi.set_expression("excited")
	nemi.set_eye_openness(1.2)
	nemi.look("down_right")
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "004", self)
	
	# "She was tiny." (1.80s)
	await wait_seconds(1.80)
	
	# On "Like, fit-in-my-pocket", hold fingers measuring tiny bracket, head tilts, blushing smile
	nemi.set_expression("happy")
	nemi.set_micro_accent("blush", true)
	nemi.head_tilt(-7.0, 0.25)
	nemi.gesture_tiny_scale(0.25)
	if doodle_director:
		doodle_director.bracket(Vector2(615, 445), 50.0, 0.20, false)
		doodle_director.bracket(Vector2(675, 445), 50.0, 0.20, true)
		doodle_director.label("TINY", Vector2(645, 405), 0.20)
	
	await wait_seconds(1.40) # "Like, fit-in-my-pocket"
	
	# On "tiny." (1.36s), soft smile, arrow to box
	nemi.set_expression("happy")
	if doodle_director:
		doodle_director.arrow(Vector2(650, 450), Vector2(740, 480), 0.25, true)
	
	await wait_seconds(1.36)
	if doodle_director:
		doodle_director.clear_all(0.15)
	await wait_seconds(0.35) # pause
	
	# SEGMENT 005 (3.04s + 0.45s pause = 3.49s)
	# "Just sitting inside" (1.10s) / "a damp cardboard box," (1.14s) / "shivering." (0.80s)
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(670, 460), 1.25, 0.30)
	
	# Nemi lowers down into crouch posture closer to box, extending gentle comforting palm
	var tw_crouch := create_tween().set_parallel(true)
	tw_crouch.tween_property(nemi, "position:y", 510.0, 0.30).set_trans(Tween.TRANS_QUAD)
	tw_crouch.tween_property(nemi, "position:x", 535.0, 0.30).set_trans(Tween.TRANS_QUAD)
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.lean(12.0, 0.30)
	nemi.gesture_open_palm("right", 0.30)
	nemi.set_expression("sad")
	nemi.look("down_right")
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "005", self)
	
	await wait_seconds(1.10) # "Just sitting inside"
	await wait_seconds(1.14) # "a damp cardboard box,"
	
	# On "shivering." (0.80s) Neeko shivers, Nemi worried empathy
	nemi.set_expression("sad")
	nemi.show_sweat("head_right", 1, 1.2)
	if neeko.has_method("set_state"):
		neeko.set_state("scared", 0.15)
	
	await wait_seconds(0.80)
	
	# 0.45s quiet empathetic hold
	await wait_seconds(0.45)
	
	if doodle_director:
		doodle_director.clear_all(0.20)
	
	print("--- BEAT 3 COMPLETED (8.40s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.1)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
