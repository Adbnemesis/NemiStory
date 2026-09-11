extends Node2D
class_name IntroductionDirector

## Choreography Director for Nemi's Debut Introduction Video
## Title: "Wait, Listen to Me" (ep00_introduction)
## Master Duration: 2:05 (125.1 seconds)
## Synchronizes audio, Nemi acting, camera punch-zooms, background mood swaps, subtitles, and curated SFX.

const NemiAudioScript = preload("res://world/audio/NemiAudio.gd")

@onready var nemi = $Nemi
@onready var world = $WorldSystem
@onready var camera = $StoryCamera2D
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

var audio_mgr: Node = null

func _ready() -> void:
	if subtitle_label:
		subtitle_label.text = ""
	_setup_audio_manager()
	call_deferred("_start_introduction")

func _setup_audio_manager() -> void:
	audio_mgr = NemiAudioScript.new()
	add_child(audio_mgr)
	if audio_mgr.has_method("_ready"):
		audio_mgr._ready()

func play_sfx(sfx_id: String, volume_offset_db: float = 0.0) -> void:
	if audio_mgr and audio_mgr.has_method("play"):
		audio_mgr.play(sfx_id, volume_offset_db)

func _start_introduction() -> void:
	print("--- NEMI DEBUT INTRODUCTION VIDEO STARTED ---")
	
	if voice_player and voice_player.stream:
		voice_player.play()
	
	_run_introduction_timeline()

func _run_introduction_timeline() -> void:
	# =========================================================================
	# BEAT 1: The Hook (0:00.00 - 0:14.20 | 14.2s)
	# Segments 001 - 004
	# =========================================================================
	print("[Beat 1] The Hook (0:00.00 - 0:14.20)")
	nemi.set_pose("neutral")
	nemi.set_expression("talking")
	set_subtitle("Wait, wait, wait—listen to me.")
	await wait_seconds(0.15)
	play_sfx("movement_cloth_rustle_01", -12.0)
	await wait_seconds(2.10) # 2.25s total
	
	set_subtitle("Please stop scrolling for literally two seconds.")
	nemi.set_expression("wide_eyes")
	await wait_seconds(3.12)
	
	# Snap Punch-Zoom into drawing/face at 05.37s
	if camera and camera.has_method("punch_zoom"):
		camera.punch_zoom(1.4, 0.08)
	play_sfx("whoosh_gesture_soft_02", -8.0)
	play_sfx("cartoon_pop_bubble_01", -4.0)
	nemi.set_expression("deadpan")
	set_subtitle("Look at this drawing right here.")
	await wait_seconds(2.43)
	
	set_subtitle("It is supposed to be a hand holding a teacup. It looks like an angry ginger root.")
	nemi.set_expression("talking")
	await wait_seconds(2.70)
	play_sfx("cartoon_wobble_comic_01", -6.0) # Wobble on teacup
	await wait_seconds(1.80)
	play_sfx("ui_blip_comic_01", -6.0) # Comic blip on angry ginger root
	await wait_seconds(2.40)
	
	# =========================================================================
	# BEAT 2: Identity & Premise (0:14.70 - 0:31.19 | 16.5s)
	# Segments 005 - 008
	# =========================================================================
	print("[Beat 2] Identity & Premise (0:14.70 - 0:31.19)")
	if camera and camera.has_method("reset_zoom"):
		camera.reset_zoom(0.3)
	play_sfx("whoosh_gesture_soft_02", -10.0)
	nemi.set_pose("gesturing")
	nemi.set_expression("smile")
	set_subtitle("Hi. I’m Nemi. I’m 24.")
	await wait_seconds(2.35)
	
	set_subtitle("And apparently... I am making animated YouTube videos now.")
	nemi.set_expression("talking")
	await wait_seconds(1.45)
	play_sfx("movement_cloth_rustle_02", -12.0)
	await wait_seconds(3.62)
	
	set_subtitle("I’ve spent years watching storytime creators talk about their lives, and recently my brain had a terrible idea:")
	nemi.set_expression("thinking")
	await wait_seconds(5.68)
	play_sfx("sting_question_chime_01", -6.0) # Question chime on 'terrible idea'
	await wait_seconds(1.47)
	
	nemi.set_expression("smug")
	set_subtitle("\"How hard could that possibly be?\"")
	play_sfx("sting_magic_sparkle_chime_01", -8.0)
	await wait_seconds(1.85)
	play_sfx("comedic_record_scratch_01", -4.0) # Record scratch stop on famous last words
	await wait_seconds(0.42)
	
	# =========================================================================
	# BEAT 3: The Animation Struggle (0:31.54 - 0:50.51 | 19.0s)
	# Segments 009 - 012
	# =========================================================================
	print("[Beat 3] Animation Struggle (0:31.54 - 0:50.51)")
	nemi.set_pose("exhausted")
	nemi.set_expression("grimace")
	play_sfx("impact_soft_thud_01", -6.0) # Slump thud
	set_subtitle("As it turns out: extraordinarily hard.")
	await wait_seconds(3.31)
	
	set_subtitle("I spent four hours yesterday inbetweening an arm movement. And by the end of it, my character wasn't walking.")
	nemi.set_expression("concerned")
	await wait_seconds(1.15)
	play_sfx("drawing_pencil_sketch_01", -8.0) # 1.2s sketching burst
	await wait_seconds(5.50)
	play_sfx("computer_laptop_typing_fast_01", -10.0) # Timeline typing burst
	await wait_seconds(3.86)
	
	set_subtitle("It looked like they were slipping on three invisible banana peels.")
	nemi.set_expression("shocked")
	await wait_seconds(1.44)
	play_sfx("cartoon_slide_whistle_01", -4.0) # Banana peel slide whistle
	await wait_seconds(2.59)
	
	# Deadpan hold: Pure Silence
	nemi.set_pose("neutral")
	nemi.set_expression("deadpan")
	set_subtitle("...In slow motion.")
	await wait_seconds(1.12)
	clear_subtitle()
	await wait_seconds(0.80) # 0.80s pure deadpan pause
	
	# =========================================================================
	# BEAT 4: Hobbies as Story Fuel (0:51.31 - 1:17.37 | 26.1s)
	# Segments 013 - 015
	# =========================================================================
	print("[Beat 4] Hobbies as Story Fuel (0:51.31 - 1:17.37)")
	# Gym beat
	if world and world.has_method("set_environment"):
		world.set_environment(1) # Crimson / dramatic mood
	play_sfx("gym_metal_plate_clank_01", -4.0)
	nemi.set_pose("heroic_pose")
	nemi.set_expression("sparkle")
	set_subtitle("I go to the gym. Where I walk in with the confidence of an anime hero in a tournament arc... and walk out two sets later completely paralyzed by leg day.")
	await wait_seconds(2.19)
	play_sfx("sting_achievement_bell_01", -6.0) # Anime hero confidence
	await wait_seconds(3.70)
	play_sfx("cartoon_wobble_comic_01", -6.0) # Trembling legs
	await wait_seconds(2.00)
	play_sfx("gym_dumbbell_pins_01", -2.0) # Dumbbell crash
	play_sfx("impact_wood_heavy_01", -4.0) # Floor thud
	await wait_seconds(1.20)
	play_sfx("cartoon_pop_bubble_tiny_02", -4.0) # DOMS ACTIVATED pop
	await wait_seconds(1.18)
	
	# Car singing beat
	if world and world.has_method("set_environment"):
		world.set_environment(0) # Return to neutral pale wash
	play_sfx("ambience_room_tone_quiet_01", -18.0)
	nemi.set_pose("gesturing")
	nemi.set_expression("talking")
	set_subtitle("And I sing. Mostly in my car with the windows rolled up.")
	await wait_seconds(2.42)
	play_sfx("car_driveby_fast_01", -14.0) # Muffled passby
	await wait_seconds(4.49)
	
	nemi.set_expression("embarrassed")
	set_subtitle("...Except last Tuesday when the window was not rolled up, and a mail carrier heard me hit a high G with absolute vibrato.")
	await wait_seconds(1.51)
	play_sfx("ui_toggle_switch_01", -8.0) # Window switch
	await wait_seconds(2.80)
	play_sfx("ui_confirm_chime_02", -6.0) # High G ping
	await wait_seconds(1.40)
	play_sfx("whoosh_gesture_soft_02", -6.0) # Sharp head turn
	play_sfx("sting_bell_dramatic_01", -4.0) # Mail carrier shock sting
	await wait_seconds(3.52) # Frozen mortification silence
	
	# =========================================================================
	# BEAT 5: Comedic Escalation & The Rabbit Hole (1:17.72 - 1:44.38 | 26.7s)
	# Segments 016 - 019
	# =========================================================================
	print("[Beat 5] Comedic Escalation (1:17.72 - 1:44.38)")
	nemi.set_pose("gesturing")
	nemi.set_expression("talking")
	set_subtitle("Like last week, when I spent six entire hours researching the exact structural tension of Victorian iron bridges...")
	await wait_seconds(0.78)
	play_sfx("computer_laptop_typing_fast_01", -10.0) # Typing burst
	await wait_seconds(2.50)
	play_sfx("paper_slide_desk_01", -8.0) # Reference sheet slide
	await wait_seconds(2.20)
	play_sfx("drawing_scratch_scribble_01", -6.0) # Formula scribble
	await wait_seconds(2.30)
	play_sfx("paper_page_flip_01", -6.0) # Notebook flip
	play_sfx("computer_mouse_fast_double_01", -8.0) # Tab double click
	await wait_seconds(2.01)
	
	set_subtitle("...just to draw one single background that is on screen for half a second.")
	nemi.set_expression("annoyed")
	await wait_seconds(0.49)
	play_sfx("drawing_pencil_write_short_01", -6.0) # Single background pencil stroke
	await wait_seconds(2.50)
	play_sfx("whoosh_camera_punch_03", -4.0) # Camera rush into eyes
	await wait_seconds(2.80)
	
	# Snap zoom into eyes on "Half. A. Second."
	if camera and camera.has_method("punch_zoom"):
		camera.punch_zoom(1.4, 0.08)
	nemi.set_pose("neutral")
	nemi.set_expression("deadpan")
	set_subtitle("Half. A. Second.")
	play_sfx("ui_tick_subtle_01", -8.0) # Half.
	await wait_seconds(0.70)
	play_sfx("ui_tick_subtle_02", -8.0) # A.
	await wait_seconds(0.70)
	play_sfx("ui_button_snap_01", -4.0) # Second.
	await wait_seconds(0.68)
	
	# 1.8s deadpan pause hold: ABSOLUTE SILENCE
	clear_subtitle()
	await wait_seconds(1.80)
	
	if camera and camera.has_method("reset_zoom"):
		camera.reset_zoom(0.3)
	play_sfx("whoosh_gesture_soft_02", -10.0)
	nemi.set_expression("smug")
	set_subtitle("...My posture was ruined. My tea was ice cold. But the bridge was architecturally sound.")
	await wait_seconds(2.62)
	play_sfx("food_glasses_clinking_01", -8.0) # Ice cold tea clink
	await wait_seconds(2.70)
	play_sfx("ui_confirm_chime_01", -6.0) # Architecturally sound chime
	await wait_seconds(2.68)
	
	# =========================================================================
	# BEAT 6: Channel Vision & Expectations (1:45.18 - 1:54.14 | 9.0s)
	# Segment 020
	# =========================================================================
	print("[Beat 6] Channel Vision (1:45.18 - 1:54.14)")
	play_sfx("ambience_room_tone_quiet_01", -20.0) # Gentle room bed
	nemi.set_pose("gesturing")
	nemi.set_expression("warm_smile")
	set_subtitle("I don't really know where this channel is going yet, but I want to have fun with it, get better at animation, and hopefully meet some cool people.")
	await wait_seconds(4.82)
	play_sfx("sting_sparkle_whoosh_01", -12.0) # Gentle animation shimmer
	await wait_seconds(4.49)
	
	# =========================================================================
	# BEAT 7: Understated Outro (1:54.49 - 2:04.60 | 10.1s)
	# Segments 021 - 022
	# =========================================================================
	print("[Beat 7] Understated Outro (1:54.49 - 2:04.60)")
	set_subtitle("So, if any of that sounds like something you’d enjoy... I’d love it if you stayed.")
	await wait_seconds(6.43)
	
	nemi.set_pose("casual_wave")
	nemi.set_expression("cheerful_smile")
	set_subtitle("Thank you for watching my very first video. See you in the next one. Bye!")
	await wait_seconds(2.58)
	play_sfx("sting_happy_bells_01", -8.0) # Outro greeting bells on 'Bye!'
	await wait_seconds(1.10)
	
	clear_subtitle()
	play_sfx("cartoon_pop_bubble_01", -6.0) # Soft outro closing pop
	await wait_seconds(0.50)
	print("--- NEMI DEBUT INTRODUCTION TIMELINE COMPLETED (125.10s / 2:05) ---")

# --- Helper Methods ---

func set_subtitle(text: String) -> void:
	if subtitle_label:
		subtitle_label.text = text

func clear_subtitle() -> void:
	if subtitle_label:
		subtitle_label.text = ""

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
