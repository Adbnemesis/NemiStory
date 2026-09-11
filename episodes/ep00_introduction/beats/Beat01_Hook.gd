extends Node2D
class_name Beat01Hook

## Beat 1: The Hook (0:00.00 – 0:14.20 | 14.70s total with pause)
## Dialogue Segments 001 - 004
## Visual Direction Overhaul V2:
## - Genuine attention interruption: eyes notice lens, blink, forward lean, open palm gesture
## - Punch-zoom 1.4x reframing Nemi and drawing gag
## - Deformed teacup sketchcard pops in with bounce and comedic wobble
## - Nemi looks at drawing on "angry ginger root", teacup wobbles, deadpan snap back to viewer
## - All subtitles strictly <= 5 words via Episode00Subtitles
## - Live illustrative lip-sync active

signal beat_finished()

const Episode00Subtitles = preload("res://episodes/ep00_introduction/Episode00Subtitles.gd")
const NemiDoodleDirectorClass = preload("res://world/doodles/NemiDoodleDirector.gd")
const DoodleInstanceClass = preload("res://world/doodles/DoodleInstance.gd")

@export var is_standalone: bool = false

@onready var nemi = $Nemi
@onready var camera = $StoryCamera2D
@onready var world = $WorldSystem
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

var teacup_prop: Node2D
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
	print("--- BEAT 1 V2: THE HOOK STARTED (00:00.00 - 00:14.70) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://animations/ep00_introduction/voiceover/voiceover.wav")
		voice_player.play(0.0)
	
	_run_beat1_choreography()

func _run_beat1_choreography() -> void:
	# -------------------------------------------------------------------------
	# SEGMENT 001 (00:00.00 - 00:02.00, pause 0.25s)
	# "Wait, wait, wait—" (1.05s) / "listen to me." (0.95s)
	# -------------------------------------------------------------------------
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.WIDE, 0.0)
	
	nemi.set_pose("neutral")
	nemi.set_expression("neutral")
	
	# Attention & Interruption event: Eyes notice camera lens, eye dart, forward lean + open palm
	nemi.set_pose("neutral")
	nemi.set_expression("neutral")
	
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("center")
	await wait_seconds(0.12)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("quick")
	
	# Slight forward lean + small conversational gesture on the interruption hook
	var tw_lean := create_tween().set_parallel(true)
	tw_lean.tween_property(nemi, "position:y", 468.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.lean(10.0, 0.22)
	nemi.gesture_open_palm("right", 0.25)
	
	# Run chunked subtitles with live lip sync
	Episode00Subtitles.play_segment(subtitle_label, nemi, "001", self)
	
	await wait_seconds(2.13) # 2.00s dialogue + 0.25s pause - 0.12s offset = 2.13s (Reaches 2.25s)
	
	# -------------------------------------------------------------------------
	# SEGMENT 002 (00:02.25 - 00:04.97, pause 0.40s)
	# "Please stop scrolling" (1.30s) / "for literally two seconds." (1.42s)
	# -------------------------------------------------------------------------
	nemi.set_expression("wide_eyes")
	Episode00Subtitles.play_segment(subtitle_label, nemi, "002", self)
	
	await wait_seconds(3.12) # 2.72s duration + 0.40s pause = 3.12s (Reaches 5.37s)
	
	# -------------------------------------------------------------------------
	# SEGMENT 003 (00:05.37 - 00:07.45, pause 0.35s)
	# "Look at this drawing" (1.05s) / "right here." (1.03s)
	# -------------------------------------------------------------------------
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(700, 330), 1.35, 0.05)
	
	teacup_prop = preload("res://episodes/ep00_introduction/props/PropDistortedTeacup.gd").new()
	teacup_prop.position = Vector2(850, 320)
	teacup_prop.scale = Vector2(0.85, 0.85)
	add_child(teacup_prop)
	teacup_prop.pop_in(0.25)
	
	# Hand-drawn arrow and circle doodle pointing to sketch on "Look at this drawing right here"
	if doodle_director:
		doodle_director.arrow(Vector2(730, 360), Vector2(805, 330), 0.22, true)
		doodle_director.circle(Vector2(850, 320), 44.0, 0.24)
	
	nemi.set_expression("skeptical")
	nemi.point("right", "fast")
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("down_right")
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "003", self)
	
	await wait_seconds(1.2)
	# Eyes snap back to viewer on "right here."
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("center")
	
	await wait_seconds(1.23) # Remainder reaches 7.80s
	
	# -------------------------------------------------------------------------
	# SEGMENT 004 (00:07.80 - 00:14.20, pause 0.50s)
	# "It is supposed to be" (1.4s) / "a hand holding a teacup." (1.8s) /
	# "It looks like" (1.2s) / "an angry ginger root." (2.0s)
	# -------------------------------------------------------------------------
	# Chunk 1 & 2: "It is supposed to be a hand holding a teacup."
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.tilt(7.0, 0.3)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "004", self)
	
	await wait_seconds(3.2) # Chunks 1 & 2 finish around 11.00s
	
	# Chunk 3: "It looks like" -> Nemi turns to look at the drawing in disbelief
	nemi.set_expression("deadpan")
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("down_right")
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.turn(14.0, "fast")
	if teacup_prop and teacup_prop.has_method("wobble"):
		teacup_prop.wobble(0.6)
		
	await wait_seconds(1.2) # Chunk 3 finishes
	
	# Chunk 4: "an angry ginger root." -> Teacup anger mark pops, head snaps back, small anger reaction mark
	if teacup_prop and teacup_prop.has_method("trigger_anger_mark"):
		teacup_prop.trigger_anger_mark()
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.10, 0.16)
		
	if doodle_director:
		doodle_director.label("GINGER ROOT?", Vector2(850, 395), 0.22, DoodleInstanceClass.StylePreset.COMEDIC)
	
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.turn(0.0, "fast")
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("center")
	nemi.set_expression("deadpan")
	# Small hand-drawn anger vein reaction mark (L2) - NO unwanted three dots!
	nemi.fx("anger", "head_right", 2, 1.8)
	
	await wait_seconds(2.0) # Chunk 4 finishes at 14.20s
	
	# Full deadpan stillness hold for 0.50s pause (reaches 14.70s)
	nemi.freeze_stillness(0.50)
	await wait_seconds(0.50)
	
	# Clean up doodles before next beat
	if doodle_director:
		doodle_director.clear_all(0.25)
	
	print("--- BEAT 1 V3 COMPLETED (14.70s) ---")
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

