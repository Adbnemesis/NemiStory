extends Node2D
class_name Beat06ChannelVision

## Beat 6: Channel Vision & What to Expect (01:45.18 - 01:54.14 | Duration: 8.96s)
## Visual Direction V3 (Expression FX Upgrade):
## - Slower, grounded, authentic contrast after the manic bridge rabbit hole
## - Warm centered medium shot (1.05x to 1.10x slow push)
## - DELIBERATE FX RESTRAINT: This is the calm beat. Only soft sparkle + relief sigh.
## - Visual Density: Empty → Minimal warmth (one sparkle, one sigh) → Sincere stillness
## - Open welcoming gesture → sincere hand-on-heart posture, warm smile, soft head tilt
## - All subtitles strictly <= 5 words via Episode00Subtitles
## - Live illustrative lip-sync active

signal beat_finished()

const Episode00Subtitles = preload("res://episodes/ep00_introduction/Episode00Subtitles.gd")

@export var is_standalone: bool = false

@onready var world_system: Node2D = $WorldSystem
@onready var camera: StoryCamera2D = $StoryCamera2D
@onready var nemi: Node2D = $Nemi
@onready var bg_rect: ColorRect = $Background
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

func _ready() -> void:
	if subtitle_label:
		subtitle_label.text = ""
	if is_standalone:
		call_deferred("start_beat")

func start_beat() -> void:
	print("--- BEAT 6 V2: CHANNEL VISION STARTED (01:45.18 - 01:54.14) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://animations/ep00_introduction/voiceover/voiceover.wav")
		voice_player.play(105.18)
	
	_run_beat6_choreography()

func _run_beat6_choreography() -> void:
	# -------------------------------------------------------------------------
	# SEGMENT 020 (01:45.18 - 01:54.14, pause 0.35s | Duration: 8.96s)
	# "I don't really know where this channel is going yet, but I want to have fun with it, get better at animation, and hopefully meet some cool people."
	# -------------------------------------------------------------------------
	if bg_rect:
		bg_rect.color = Color(0.98, 0.965, 0.945, 1.0) # Warm cream wash
		
	# Camera warm framing (1.05x with gentle slow push to 1.10x)
	if camera:
		if camera.has_method("apply_preset"):
			camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.2)
		if camera.has_method("punch_zoom"):
			camera.punch_zoom(1.05, 0.2)
			var tw_cam = create_tween()
			tw_cam.tween_property(camera, "zoom", Vector2(1.10, 1.10), 8.5)
		
	# Conversational open palm gesture & gentle warm smile
	nemi.position = Vector2(640, 390)
	nemi.set_pose("gesturing")
	nemi.set_expression("smile")
	
	if nemi.actor and nemi.actor.head and nemi.actor.head.has_method("tilt"):
		nemi.actor.head.tilt(3.5, 0.4)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("center")
		
	# Trigger 5-word subtitle cards with live lip-sync
	Episode00Subtitles.play_segment(subtitle_label, nemi, "020", self)
	
	# Wait until "get better at animation..." (~5.0s in)
	# Single soft excitement sparkle on "have fun with it" — warm, not manic
	await wait_seconds(3.2)
	nemi.fx("excitement", "head_left", 1, 2.5) # Soft, subdued sparkle — genuinely happy
	await wait_seconds(1.8)
	
	# Transition to sincere hand on chest / heart posture
	nemi.set_pose("hand_on_heart", 0.35)
	nemi.set_expression("warm_smile")
	nemi.fx("relief", "head_right", 1, 3.5) # Gentle warm sigh — sincerity, not comedy
	if nemi.actor and nemi.actor.head and nemi.actor.head.has_method("tilt"):
		nemi.actor.head.tilt(-2.0, 0.4)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("soft")
		
	await wait_seconds(1.6)
	# Conversational sincere blink & subtle head tilt shift
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("soft")
	if nemi.actor and nemi.actor.head and nemi.actor.head.has_method("tilt"):
		nemi.actor.head.tilt(1.5, 0.6)
	
	await wait_seconds(1.6)
	# Gentle affirming nod and natural blink
	if nemi.actor and nemi.actor.head and nemi.actor.head.has_method("nod"):
		nemi.actor.head.nod(0.6, 1)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("normal")
		
	await wait_seconds(0.76) # Dialogue finishes at 01:54.14
	
	# 0.35s quiet settle pause
	await wait_seconds(0.35) # Reaches 01:54.49
	
	nemi.clear_all_fx(true) # Clean sweep for outro
	print("--- BEAT 6 V3 COMPLETED (01:54.49 / 114.49s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.3)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	if DisplayServer.get_name() == "headless":
		await get_tree().create_timer(duration).timeout
	else:
		var frames: int = int(round(duration * 60.0))
		for i in range(frames):
			await RenderingServer.frame_post_draw
