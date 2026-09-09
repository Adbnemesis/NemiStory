extends Node2D
class_name IntroductionDirector

## Choreography Director for Nemi's Debut Introduction Video
## Title: "Wait, Listen to Me" (ep00_introduction)
## Target Duration: 1:52 (112 seconds)
## Synchronizes audio, Nemi acting, camera punch-zooms, background mood swaps, and subtitles.

@onready var nemi = $Nemi
@onready var world = $WorldSystem
@onready var camera = $StoryCamera2D
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

func _ready() -> void:
	if subtitle_label:
		subtitle_label.text = ""
	call_deferred("_start_introduction")

func _start_introduction() -> void:
	print("--- NEMI DEBUT INTRODUCTION VIDEO STARTED ---")
	
	if voice_player and voice_player.stream:
		voice_player.play()
	
	_run_introduction_timeline()

func _run_introduction_timeline() -> void:
	# =========================================================================
	# BEAT 1: The Hook (0:00 - 0:06 | 6.0s)
	# "Wait, wait, wait—listen to me. Please stop scrolling..."
	# =========================================================================
	print("[Beat 1] The Hook (0:00 - 0:06)")
	nemi.set_pose("neutral")
	nemi.set_expression("talking")
	set_subtitle("Wait, wait, wait—listen to me.")
	await wait_seconds(1.8)
	
	set_subtitle("Please stop scrolling for literally two seconds.")
	nemi.set_expression("wide_eyes")
	await wait_seconds(1.7)
	
	# Snap Punch-Zoom into drawing/face
	if camera and camera.has_method("punch_zoom"):
		camera.punch_zoom(1.4, 0.1)
	nemi.set_expression("deadpan")
	set_subtitle("It looks like an angry ginger root.")
	await wait_seconds(2.5)
	
	# =========================================================================
	# BEAT 2: Identity & Premise (0:06 - 0:20 | 14.0s)
	# "Hi. I'm Nemi. I'm 24. And apparently... I'm making YouTube videos now."
	# =========================================================================
	print("[Beat 2] Identity & Premise (0:06 - 0:20)")
	if camera and camera.has_method("reset_zoom"):
		camera.reset_zoom(0.3)
	nemi.set_pose("gesturing")
	nemi.set_expression("smile")
	set_subtitle("Hi. I’m Nemi. I’m 24.")
	await wait_seconds(2.5)
	
	set_subtitle("And apparently... I am making animated YouTube videos now.")
	nemi.set_expression("talking")
	await wait_seconds(3.5)
	
	set_subtitle("I’ve spent years watching storytime creators talk about their lives...")
	nemi.set_expression("thinking")
	await wait_seconds(5.0)
	
	nemi.set_expression("smug")
	set_subtitle("\"How hard could that possibly be?\"")
	await wait_seconds(3.0)
	
	# =========================================================================
	# BEAT 3: The Animation Struggle (0:20 - 0:40 | 20.0s)
	# "As it turns out: extraordinarily hard... 24 frames of humiliation"
	# =========================================================================
	print("[Beat 3] Animation Struggle (0:20 - 0:40)")
	nemi.set_pose("exhausted")
	nemi.set_expression("grimace")
	set_subtitle("As it turns out: extraordinarily hard.")
	await wait_seconds(3.0)
	
	set_subtitle("Nobody warns you that 24 frames a second means twenty-four chances to humiliate yourself.")
	nemi.set_expression("talking")
	await wait_seconds(7.0)
	
	set_subtitle("I spent four hours yesterday inbetweening an arm movement...")
	nemi.set_expression("concerned")
	await wait_seconds(5.5)
	
	set_subtitle("It looked like slipping on three invisible banana peels.")
	nemi.set_expression("shocked")
	await wait_seconds(2.5)
	
	# Deadpan pause: stillness hold
	clear_subtitle()
	nemi.set_pose("neutral")
	nemi.set_expression("deadpan")
	await wait_seconds(1.0)
	
	set_subtitle("...In slow motion.")
	await wait_seconds(1.0)
	
	# =========================================================================
	# BEAT 4: Hobbies as Story Fuel (0:40 - 1:04 | 24.0s)
	# Gym heroics -> Late night anime -> Car singing
	# =========================================================================
	print("[Beat 4] Hobbies as Story Fuel (0:40 - 1:04)")
	nemi.set_pose("gesturing")
	nemi.set_expression("talking")
	set_subtitle("Normally, when I’m not breaking my wrist, I have a disciplined routine.")
	await wait_seconds(5.0)
	
	# Gym beat
	if world and world.has_method("set_environment"):
		world.set_environment(1) # Dramatic mood
	nemi.set_pose("heroic_pose")
	nemi.set_expression("sparkle")
	set_subtitle("I walk into the gym like an anime hero... and leave paralyzed by leg day.")
	await wait_seconds(6.5)
	
	# Anime binge beat
	nemi.set_pose("thinking")
	nemi.set_expression("wide_eyes")
	set_subtitle("\"Just one episode before bed,\" and suddenly birds are chirping.")
	await wait_seconds(5.5)
	
	# Car singing beat
	if world and world.has_method("set_environment"):
		world.set_environment(0) # Return to neutral
	nemi.set_pose("gesturing")
	nemi.set_expression("embarrassed")
	set_subtitle("A mail carrier heard me hit a high note with absolute vibrato.")
	await wait_seconds(7.0)
	
	# =========================================================================
	# BEAT 5: Comedic Escalation & The Rabbit Hole (1:04 - 1:28 | 24.0s)
	# 6 hours researching Victorian bridge tension for half a second
	# =========================================================================
	print("[Beat 5] Comedic Escalation (1:04 - 1:28)")
	nemi.set_pose("gesturing")
	nemi.set_expression("talking")
	set_subtitle("I have all these weird situations in my life, and keeping them inside feels dangerous.")
	await wait_seconds(6.5)
	
	set_subtitle("I spent six entire hours researching the structural tension of Victorian bridges...")
	nemi.set_expression("thinking")
	await wait_seconds(5.5)
	
	set_subtitle("...to draw one background that is on screen for half a second.")
	nemi.set_expression("annoyed")
	await wait_seconds(3.5)
	
	# Snap zoom into eyes on "Half. A. Second."
	if camera and camera.has_method("punch_zoom"):
		camera.punch_zoom(1.4, 0.08)
	nemi.set_pose("neutral")
	nemi.set_expression("deadpan")
	set_subtitle("Half. A. Second.")
	await wait_seconds(2.0)
	
	# Deadpan hold for 1.8s
	clear_subtitle()
	await wait_seconds(1.8)
	
	set_subtitle("My posture was ruined. But the bridge was architecturally sound.")
	nemi.set_expression("smug")
	await wait_seconds(4.7)
	
	# =========================================================================
	# BEAT 6: Channel Vision & Expectations (1:28 - 1:44 | 16.0s)
	# Awkward stories, art journey, shared connection
	# =========================================================================
	print("[Beat 6] Channel Vision (1:28 - 1:44)")
	if camera and camera.has_method("reset_zoom"):
		camera.reset_zoom(0.3)
	nemi.set_pose("gesturing")
	nemi.set_expression("warm_smile")
	set_subtitle("Stories about awkward encounters, creative rabbit holes, and gym blunders.")
	await wait_seconds(8.0)
	
	set_subtitle("I want to have fun with it, get better at animation, and meet cool people.")
	nemi.set_expression("smile")
	await wait_seconds(8.0)
	
	# =========================================================================
	# BEAT 7: Understated Outro & Posture Callout (1:44 - 1:52 | 8.0s)
	# "Straighten your posture right now. Yes, you."
	# =========================================================================
	print("[Beat 7] Understated Outro (1:44 - 1:52)")
	set_subtitle("If that sounds like something you’d enjoy... I’d love it if you stayed.")
	await wait_seconds(3.5)
	
	# Point at camera for posture callout
	nemi.set_pose("pointing")
	nemi.set_expression("playful_smirk")
	set_subtitle("Also—straighten your posture right now. Yes, you.")
	await wait_seconds(2.5)
	
	nemi.set_pose("casual_wave")
	nemi.set_expression("cheerful_smile")
	set_subtitle("Thank you for watching my very first video. Bye!")
	await wait_seconds(2.0)
	
	# =========================================================================
	# BEAT 8: Post-Credit Stinger (1:52 - 1:59 | 7.0s)
	# Panic stepped run cycle: "Was my gain at 200%?!"
	# =========================================================================
	print("[Beat 8] Post-Credit Stinger (1:52 - 1:59)")
	clear_subtitle()
	await wait_seconds(0.5)
	
	nemi.set_pose("panic")
	nemi.set_expression("terrified")
	set_subtitle("Wait—did I leave the microphone gain at 200%?!")
	await wait_seconds(2.5)
	
	clear_subtitle()
	await wait_seconds(1.0)
	
	nemi.set_expression("deadpan")
	set_subtitle("...It was. Cool.")
	await wait_seconds(2.0)
	
	clear_subtitle()
	print("--- NEMI DEBUT INTRODUCTION TIMELINE COMPLETED ---")

# --- Helper Methods ---

func set_subtitle(text: String) -> void:
	if subtitle_label:
		subtitle_label.text = text

func clear_subtitle() -> void:
	if subtitle_label:
		subtitle_label.text = ""

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
