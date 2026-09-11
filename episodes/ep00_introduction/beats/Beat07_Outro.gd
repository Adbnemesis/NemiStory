extends Node2D
class_name Beat07Outro

## Beat 7: Understated Outro (01:54.49 - 02:05.10 | Duration: 10.61s)
## Visual Direction V3 (Expression FX Upgrade):
## - Intimate medium framing, grounded sincere presence
## - Segment 021: Warm sparkle on "I'd love it if you stayed" + relief sigh on sincere tilt
## - Segment 022: Final excitement burst + face exaggerate on "Bye!" — last visual impression
## - Visual Density: Empty → Single warm accent → Final burst → Clean fade
## - Outro Settle (02:04.60 - 02:05.10): 0.5s gentle fade to warm paper cream
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
@onready var fade_rect: ColorRect = $UI/FadeRect

func _ready() -> void:
	if subtitle_label:
		subtitle_label.text = ""
	if fade_rect:
		fade_rect.modulate.a = 0.0
	if is_standalone:
		call_deferred("start_beat")

func start_beat() -> void:
	print("--- BEAT 7 V2: UNDERSTATED OUTRO STARTED (01:54.49 - 02:05.10) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://animations/ep00_introduction/voiceover/voiceover.wav")
		voice_player.play(114.49)
	
	_run_beat7_choreography()

func _run_beat7_choreography() -> void:
	# -------------------------------------------------------------------------
	# SEGMENT 021 (01:54.49 - 02:00.57, pause 0.35s | Duration: 6.08s)
	# "So, if any of that sounds like something you’d enjoy... I’d love it if you stayed."
	# -------------------------------------------------------------------------
	if bg_rect:
		bg_rect.color = Color(0.98, 0.97, 0.95, 1.0)
		
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.2)
		
	nemi.position = Vector2(640, 390)
	nemi.set_pose("neutral")
	nemi.set_expression("smile")
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("center")
		
	Episode00Subtitles.play_segment(subtitle_label, nemi, "021", self)
	
	await wait_seconds(1.5)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("soft")
	await wait_seconds(1.5) # "...something you'd enjoy..."
	
	# Sincere tilt & warm smile on "I'd love it if you stayed."
	nemi.set_expression("warm_smile")
	nemi.fx("excitement", "head_left", 1, 3.0) # Single soft warm sparkle — emotional peak
	nemi.fx("relief", "head_right", 1, 2.5) # Gentle sigh of sincerity
	if nemi.actor and nemi.actor.head and nemi.actor.head.has_method("tilt"):
		nemi.actor.head.tilt(3.0, 0.35)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("soft")
		
	await wait_seconds(1.6)
	if nemi.actor and nemi.actor.head and nemi.actor.head.has_method("nod"):
		nemi.actor.head.nod(0.5, 1)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("soft")
	await wait_seconds(1.48) # Reaches 02:00.57
	
	# 0.35s pause breath hold before outro wave
	await wait_seconds(0.35) # Reaches 02:00.92
	
	# -------------------------------------------------------------------------
	# SEGMENT 022 (02:00.92 - 02:04.60 | Duration: 3.68s)
	# "Thank you for watching my very first video. See you in the next one. Bye!"
	# -------------------------------------------------------------------------
	nemi.clear_all_fx() # Clear sincerity FX for fresh burst
	nemi.set_pose("casual_wave", 0.2)
	nemi.set_expression("cheerful_smile")
	if nemi.actor and nemi.actor.head and nemi.actor.head.has_method("tilt"):
		nemi.actor.head.tilt(-4.0, 0.25)
	
	# Active conversational wave
	nemi.wave("right", 2)
		
	Episode00Subtitles.play_segment(subtitle_label, nemi, "022", self)
	
	await wait_seconds(1.5)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("normal")
	await wait_seconds(1.6) # Right up to "Bye!"
	
	# Friendly blink, wave pulse, and cheerful grin on "Bye!" — FINAL visual impression of entire episode
	nemi.wave("right", 1)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("normal")
	nemi.fx("excitement", "head_left", 3, 1.2) # Celebratory sparkle burst
	nemi.face_exaggerate("excitement", 2, 0.8) # Bright-eyed cheerful widening
	
	# Camera subtle punch for the final "Bye!" emphasis
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.05, 0.12)
		
	await wait_seconds(0.58) # Reaches 02:04.60
	
	# -------------------------------------------------------------------------
	# OUTRO SETTLE & FADE (02:04.60 - 02:05.10 | 0.50s)
	# -------------------------------------------------------------------------
	nemi.clear_all_fx(true) # Clean sweep before fade
	if fade_rect:
		var tw_fade = create_tween()
		tw_fade.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
		
	await wait_seconds(0.50) # Reaches 02:05.10 master end
	
	print("--- BEAT 7 V3 COMPLETED (02:05.10 / 125.10s) ---")
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

