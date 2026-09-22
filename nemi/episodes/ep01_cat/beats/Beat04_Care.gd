extends Node2D
class_name Ep01Beat04Care

## Beat 4: The Care (20.46s – 32.25s | 11.79s)
## Dialogue Segments 006 - 008:
## "So naturally, I brought her a little bowl of warm milk."
## "At first, she hissed at my shoelaces."
## "But ten minutes later? Purring like a tiny lawnmower."
## Visual Direction:
## - Milk bottle doodle & ceramic milk saucer slides in gently
## - Neeko approaches curiously, sniffing
## - Hiss at shoelaces with cute jump
## - 10-minute clock doodle
## - Neeko drinks milk, moves to folded blanket, curls into happy loaf with purr soundwaves
## - Nemi hand on heart with fond cheek blush

signal beat_finished()

const Episode01Subtitles = preload("res://nemi/episodes/ep01_cat/Episode01Subtitles.gd")
const NemiDoodleDirectorClass = preload("res://nemi/world/doodles/NemiDoodleDirector.gd")
const PropMilkBowlClass = preload("res://nemi/episodes/ep01_cat/props/PropMilkBowl.gd")
const PropBlanketClass = preload("res://nemi/episodes/ep01_cat/props/PropBlanket.gd")

@export var is_standalone: bool = false

@onready var nemi = $Nemi
@onready var camera = $StoryCamera2D
@onready var world = $WorldSystem
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

var doodle_director: Node2D
var milk_bowl: Node2D
var blanket: Node2D
var neeko: Node2D

func _ready() -> void:
	doodle_director = NemiDoodleDirectorClass.new()
	doodle_director.name = "DoodleDirector"
	add_child(doodle_director)
	
	blanket = PropBlanketClass.new()
	blanket.position = Vector2(765, 525)
	add_child(blanket)
	
	milk_bowl = PropMilkBowlClass.new()
	milk_bowl.position = Vector2(665, 525)
	add_child(milk_bowl)
	
	neeko = preload("res://nemi/characters/neeko/Neeko.tscn").instantiate()
	neeko.position = Vector2(780, 515)
	neeko.scale = Vector2(0.85, 0.85)
	add_child(neeko)
	neeko.set_state("curious")
	
	if subtitle_label:
		subtitle_label.text = ""
	if is_standalone:
		call_deferred("start_beat")

func start_beat() -> void:
	print("--- EPISODE 01 BEAT 4: THE CARE STARTED (20.46s - 32.25s) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://nemi/episodes/ep01_cat/audio/EP01_voice.wav")
		voice_player.play(20.46)
	
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	nemi.position = Vector2(500, 500)
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
	
	# SEGMENT 006 (3.60s + 0.35s pause = 3.95s)
	# "So naturally," (1.00s) / "I brought her" (0.90s) / "a little bowl" (0.85s) / "of warm milk." (0.85s)
	nemi.set_expression("happy")
	nemi.look("down_right")
	
	# Milk bottle doodle draws on
	if doodle_director:
		doodle_director.milk_bottle(Vector2(585, 430), 28.0, 0.22)
	
	# Slide milk bowl in gently
	var tw_bowl := create_tween()
	tw_bowl.tween_property(milk_bowl, "position:x", 650.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "006", self)
	
	await wait_seconds(1.90) # "So naturally," (1.00s) + "I brought her" (0.90s)
	
	# On "a little bowl of warm milk." Neeko approaches bowl curiously
	if neeko.has_method("trot_to"):
		neeko.trot_to(Vector2(695, 520), 1.2)
	
	await wait_seconds(1.70) # "a little bowl" (0.85s) + "of warm milk." (0.85s)
	
	if doodle_director:
		doodle_director.clear_all(0.15)
		
	await wait_seconds(0.35) # pause
	
	# SEGMENT 007 (3.04s + 0.30s pause = 3.34s)
	# "At first," (1.00s) / "she hissed" (0.94s) / "at my shoelaces." (1.10s)
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(620, 470), 1.25, 0.20)
	
	Episode01Subtitles.play_segment(subtitle_label, nemi, "007", self)
	
	await wait_seconds(1.00) # "At first,"
	
	# On "she hissed", Neeko arches back briefly with cute hiss
	# Nemi recoils in comedic cartoon shock!
	if neeko.has_method("set_state"):
		neeko.set_state("scared", 0.12)
	nemi.set_expression("shocked")
	nemi.show_shock_lines("head_top", 2, 0.8)
	nemi.look("down_right")
	
	await wait_seconds(2.04) # "she hissed" (0.94s) + "at my shoelaces." (1.10s)
	await wait_seconds(0.30) # pause
	
	# SEGMENT 008 (4.00s + 0.50s pause = 4.50s)
	# "But ten minutes later?" (1.60s) / "Purring like" (1.10s) / "a tiny lawnmower." (1.30s)
	Episode01Subtitles.play_segment(subtitle_label, nemi, "008", self)
	
	# On "ten minutes later": playful amused smirk & head tilt
	nemi.set_expression("smug")
	nemi.head_tilt(6.0, 0.20)
	if doodle_director:
		doodle_director.circle(Vector2(640, 280), 28.0, 0.20)
		doodle_director.label("10 MIN LATER", Vector2(640, 325), 0.20)
	
	await wait_seconds(1.60) # "But ten minutes later?"
	
	if doodle_director:
		doodle_director.clear_all(0.15)
	
	# Neeko drinks from bowl, then steps onto blanket
	if neeko.has_method("set_state"):
		neeko.set_state("drinking", 0.15)
	
	await wait_seconds(1.10) # "Purring like"
	
	# On "a tiny lawnmower." Neeko curls onto blanket into happy loaf!
	# Nemi melts with beaming joy and soft cheek blush
	if neeko.has_method("trot_to"):
		neeko.trot_to(Vector2(765, 520), 0.6)
	if blanket and blanket.has_method("squish"):
		blanket.squish(0.12, 0.4)
	if neeko.has_method("curl_into_loaf"):
		neeko.curl_into_loaf(0.35)
	
	# Purring soundwave lines doodle
	if doodle_director:
		doodle_director.direction_lines(Vector2(765, 490), 24.0, 0.20)
	
	nemi.hand_on_chest(0.25)
	nemi.set_expression("happy")
	nemi.show_blush(3, 2.0)
	
	await wait_seconds(1.30) # "a tiny lawnmower."
	
	# 0.50s quiet fond hold
	nemi.freeze_stillness(0.50)
	await wait_seconds(0.50)
	
	if doodle_director:
		doodle_director.clear_all(0.20)
	
	print("--- BEAT 4 COMPLETED (11.79s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.1)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
