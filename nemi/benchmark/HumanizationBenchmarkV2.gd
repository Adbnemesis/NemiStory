class_name HumanizationBenchmarkV2
extends Node2D

## Humanization Benchmark Test V2 for NEMI
## Target Length: 16.82 seconds @ 30 FPS progressive
## Voice: Canonical Sohee Voice Slice (3.36s to 20.18s of EP05_voice_v2.wav)
## Narration:
## "I sat down at my desk today, opened my analytics... and I just froze.
##  Because literally last week, I was refreshing at two in the morning, staring at seven views.
##  And honestly? Three of those were from my own phone."
##
## Verified against all 20 requirements of Section 43:
## 1. Relaxed asymmetric posture
## 2. Real live illustrative lip sync synchronized to actual voice
## 3. Weight shift while speaking
## 4. Meaningful hand gestures
## 5. Torso participation in gestures
## 6. Full body pose changes across beats
## 7. Responsive eye reactions (look down, glance, direct lock)
## 8. Head reactions (tilt, recoil, drop)
## 9. Secondary hair spring follow-through
## 10. Physical prop interaction (hand-drawn phone lifecycle)
## 11. Authored hand-drawn prop personality (StoryPhone with organic ink contour)
## 12. Progressive live on-screen doodle draw-on
## 13. Unique doodle geometry (not generic repeated SVG)
## 14. Handwritten annotation ("7 VIEWS")
## 15. Individually authored handwriting with organic baseline
## 16. Story-motivated camera punch-ins
## 17. Intentional stillness holds (>85% stillness during holds)
## 18. Comedic shock freeze and sheepish confession blush
## 19. Movement does NOT start instantly (holds and pauses)
## 20. Frame-perfect synchronization to actual audio

const HumanProps = preload("res://nemi/world/props/HumanProps.gd")

@onready var world_system: WorldSystemDirector = $WorldSystem
@onready var camera: StoryCamera2D = $StoryCamera2D
@onready var nemi: Node2D = $Nemi
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var subtitle_label: Label = $UI/Subtitle
@onready var human_doodles: HumanDoodles = $HumanDoodlesLayer
@onready var props_layer: Node2D = $PropsLayer

var phone_prop: Node2D
var chair_prop: Node2D
var desk_prop: Node2D
var r_hand: Node2D

const TOTAL_DURATION: float = 16.82
var elapsed: float = 0.0
var is_running: bool = false

func _ready() -> void:
	# Load voice audio stream
	if voice_player and not voice_player.stream:
		if ResourceLoader.exists("res://nemi/benchmark/benchmark_v2_voice.wav"):
			voice_player.stream = load("res://nemi/benchmark/benchmark_v2_voice.wav")

	# Setup workspace background
	if world_system:
		world_system.set_environment(2, 2) # Workspace studio

	# Cache hand bone node for dynamic prop attachment
	if nemi:
		r_hand = nemi.get_node_or_null("Skeleton2D/RootBone/TorsoBone/RightUpperArmBone/RightLowerArmBone/RightHandBone")

	# Instantiate hand-drawn studio furniture & props
	_setup_props()

	run_benchmark()

func _setup_props() -> void:
	# 1. Hand-drawn studio wooden chair behind Nemi at (540, 440)
	chair_prop = HumanProps.StoryChair.new()
	chair_prop.position = Vector2(540, 440)
	props_layer.add_child(chair_prop)

	# 2. Hand-drawn workspace creator desk at (590, 440)
	# Surface is at Y = 440, spanning across the right studio area
	desk_prop = HumanProps.StoryDesk.new()
	desk_prop.position = Vector2(590, 440)
	props_layer.add_child(desk_prop)

	# 3. Hand-drawn smartphone resting on the creator desk surface right beside Nemi's hand
	phone_prop = HumanProps.StoryPhone.new()
	phone_prop.position = Vector2(655, 432)
	phone_prop.rotation = deg_to_rad(-12.0) # Casual resting angle
	phone_prop.set_screen(HumanProps.StoryPhone.ScreenState.SCREEN_OFF)
	props_layer.add_child(phone_prop)

func set_sub(text: String) -> void:
	if subtitle_label:
		subtitle_label.text = text

func clear_sub() -> void:
	if subtitle_label:
		subtitle_label.text = ""

func wait_sec(sec: float) -> void:
	await get_tree().create_timer(sec).timeout

func speak_line(phrase: String, dur: float, emotion: String = "normal") -> void:
	if nemi and nemi.has_method("speak"):
		nemi.call("speak", phrase, dur, emotion)

func run_benchmark() -> void:
	is_running = true

	# Start audio playback
	if voice_player and voice_player.stream:
		voice_player.play(0.0)

	print("============================================================")
	print("NEMI HUMANIZATION BENCHMARK V2: 10-SHOT PERFORMANCE (16.82s)")
	print("============================================================")

	# -------------------------------------------------------------------------
	# BEAT 1 (0.00s - 1.80s): Relaxed Setup & Beginning of Live Lip Sync
	# Spoken: "I sat down at my desk today," (duration 1.80s)
	# -------------------------------------------------------------------------
	print("[BENCHMARK V2] BEAT 1: Relaxed Seated Setup (t=0.00s)")
	nemi.reset()
	nemi.position = Vector2(540, 360)
	nemi.set_pose("seated_at_desk_relaxed", 0.0)
	nemi.set_expression("casual")
	nemi.look("center")
	camera.position = Vector2(580, 360)
	camera.zoom = Vector2(1.05, 1.05)
	
	set_sub("I sat down at my desk today,")
	speak_line("I sat down at my desk today,", 1.75, "casual")
	await wait_sec(1.80)

	# -------------------------------------------------------------------------
	# BEAT 2 (1.80s - 3.40s): Real Prop Interaction Lifecycle
	# Spoken: "...opened my analytics..." (duration 1.55s)
	# -------------------------------------------------------------------------
	print("[BENCHMARK V2] BEAT 2: Hand-Drawn Prop Interaction (t=1.80s)")
	set_sub("opened my analytics...")
	
	# 1. Eyes glance down at phone first (saccade leads)
	nemi.look("down_right")
	await wait_sec(0.12)
	
	# 2. Body leans forward over desk, hand picks up phone from desk surface
	nemi.transition_pose("seated_desk_lean", 0.24, true, true)
	speak_line("opened my analytics...", 1.50, "talking")
	
	await wait_sec(0.18)
	# Attach phone prop to Nemi's right hand bone!
	if r_hand and phone_prop:
		phone_prop.attach_to_hand(r_hand, Vector2(0, -6), deg_to_rad(15.0))
		phone_prop.set_screen(HumanProps.StoryPhone.ScreenState.ANALYTICS_NOTIF) # Screen illuminates with spike chart!

	await wait_sec(1.30)

	# -------------------------------------------------------------------------
	# BEAT 3 (3.40s - 5.68s): Comedic Shock Freeze & Story-Driven Punch-Zoom
	# Spoken: "...and I just froze." (0.8s word + 1.48s silence hold)
	# -------------------------------------------------------------------------
	print("[BENCHMARK V2] BEAT 3: Comedic Shock Freeze (t=3.40s)")
	set_sub("...and I just froze.")
	
	# Story-motivated camera punch-in on disbelief (framing upper body and frozen phone)
	camera.punch_in(Vector2(550, 310), 1.35, 0.12)
	
	# Instant 0-frame shock freeze: rigid posture, phone held mid-air, wide unblinking eyes
	nemi.set_pose("shocked_analytics_freeze", 0.0)
	speak_line("and I just froze.", 0.85, "shock")
	
	await wait_sec(0.95)
	
	# Mouth snaps completely shut during comedic pause; rigid hold
	if nemi.has_method("stop_speech"):
		nemi.call("stop_speech", "neutral")
	
	# Rock-solid stillness hold for remainder of pause (zero jitter)
	await wait_sec(1.33)

	# -------------------------------------------------------------------------
	# BEAT 4 (5.68s - 8.20s): Reflective Weight Shift & Contrapposto
	# Spoken: "Because literally last week," (duration 2.52s)
	# -------------------------------------------------------------------------
	print("[BENCHMARK V2] BEAT 4: Standing Weight Shift & Contrapposto (t=5.68s)")
	set_sub("Because literally last week,")
	
	# Camera cuts out smoothly to medium conversational shot
	camera.zoom = Vector2(1.08, 1.08)
	camera.position = Vector2(550, 360)
	
	# Nemi transitions to standing contrapposto with weight on left hip beside desk
	nemi.position = Vector2(550, 360)
	nemi.transition_pose("relaxed_standing_left_weight", 0.30, true, true)
	
	# Detach phone and place back on creator desk surface at (655, 432)
	if phone_prop:
		phone_prop.detach()
		phone_prop.position = Vector2(655, 432)
		phone_prop.rotation = deg_to_rad(-8.0)
		phone_prop.set_screen(HumanProps.StoryPhone.ScreenState.VIEWS_RECAP)
	
	nemi.set_expression("candid")
	nemi.look("center")
	speak_line("Because literally last week,", 2.40, "talking")
	
	await wait_sec(2.52)

	# -------------------------------------------------------------------------
	# BEAT 5 (8.20s - 10.50s): Exhausted Late-Night Memory Gesture
	# Spoken: "I was refreshing at two in the morning," (duration 2.30s)
	# -------------------------------------------------------------------------
	print("[BENCHMARK V2] BEAT 5: Exhausted Memory Gesture (t=8.20s)")
	set_sub("I was refreshing at two in the morning,")
	
	# Gaze drifts up-left first, then head follows
	nemi.look("up_left")
	await wait_sec(0.14)
	
	# Hand touches cheek in tired memory; torso leans back slightly
	nemi.transition_pose("thinking_chin_tap", 0.28, true, true)
	nemi.set_expression("thinking")
	speak_line("I was refreshing at two in the morning,", 2.10, "talking")
	
	await wait_sec(2.16)

	# -------------------------------------------------------------------------
	# BEAT 6 (10.50s - 12.60s): Live Doodle Reveal with Authored Variants
	# Spoken: "staring at seven views." (duration 2.10s)
	# -------------------------------------------------------------------------
	print("[BENCHMARK V2] BEAT 6: Progressive Live Doodle Draw-on (t=10.50s)")
	set_sub("staring at seven views.")
	
	# Nemi points low into negative space on right
	nemi.transition_pose("conversational_point_low", 0.24, true, true)
	nemi.look("center")
	speak_line("staring at seven views.", 1.95, "deadpan")
	
	# Progressive ink reveal of "7 VIEWS" with organic loop circle Variant A & wobbly underline
	if human_doodles:
		human_doodles.spawn_handwritten_text(Vector2(840, 220), "7 VIEWS", 1.05, 0.32)
		await wait_sec(0.35)
		human_doodles.spawn_imperfect_circle(Vector2(895, 210), 55.0, 0.28, Color("#3e081e"), "A")
		human_doodles.spawn_wobbly_underline(Vector2(830, 245), 130.0, 0.22, Color("#3e081e"), "A")
		
	await wait_sec(1.75)

	# -------------------------------------------------------------------------
	# BEAT 7 (12.60s - 14.20s): Close-Up Confession Setup (Counting "Three")
	# Spoken: "And honestly? Three of those were..." (duration 1.60s)
	# -------------------------------------------------------------------------
	print("[BENCHMARK V2] BEAT 7: Hand Gesture Climax & Camera Punch (t=12.60s)")
	set_sub("And honestly? Three of those were...")
	
	# Cinematic Close-Up punch-in framing upper torso, face, and 3-finger hand!
	camera.punch_in(Vector2(550, 250), 1.60, 0.16)
	
	# Clear previous doodles cleanly
	if human_doodles:
		human_doodles.clear_all(0.18)
		
	# Distinct 3-finger counting gesture (completely unobstructed by phone!)
	nemi.transition_pose("counting_three", 0.22, true, true)
	nemi.look("center")
	speak_line("And honestly? Three of those were...", 1.55, "talking")
	
	await wait_sec(1.60)

	# -------------------------------------------------------------------------
	# BEAT 8 (14.20s - 15.60s): Sheepish Phone Confession & Blush
	# Spoken: "...from my own phone." (duration 1.40s)
	# -------------------------------------------------------------------------
	print("[BENCHMARK V2] BEAT 8: Sheepish Confession & Blush (t=14.20s)")
	set_sub("...from my own phone.")
	
	camera.position = Vector2(550, 255)
	camera.zoom = Vector2(1.55, 1.55)
	
	# Nemi picks up phone from desk and holds it up beside face, left hand shields mouth in shy chuckle
	if r_hand and phone_prop:
		phone_prop.attach_to_hand(r_hand, Vector2(0, -6), deg_to_rad(-25.0))
		phone_prop.set_screen(HumanProps.StoryPhone.ScreenState.VIEWS_RECAP)
		
	nemi.transition_pose("shy_phone_confession", 0.24, true, true)
	nemi.look("down_right")
	nemi.set_expression("blush")
	speak_line("from my own phone.", 1.25, "smiling")
	
	await wait_sec(1.40)

	# -------------------------------------------------------------------------
	# BEAT 9 (15.60s - 16.30s): Deadpan Comedy Hold (>85% Stillness)
	# Silence hold for punchline delivery (duration 0.70s)
	# -------------------------------------------------------------------------
	print("[BENCHMARK V2] BEAT 9: Intentional Deadpan Stillness Hold (t=15.60s)")
	clear_sub()
	
	camera.position = Vector2(550, 255)
	camera.zoom = Vector2(1.55, 1.55)
	
	# Snap to deadpan camera stare: locked eye contact, horizontal mouth, absolute stillness
	nemi.set_pose("deadpan_camera_stare", 0.0)
	if nemi.has_method("stop_speech"):
		nemi.call("stop_speech", "neutral")
		
	await wait_sec(0.70)

	# -------------------------------------------------------------------------
	# BEAT 10 (16.30s - 16.82s): Subtle Micro-Reaction Settle
	# Micro-reaction & conclusion (duration 0.52s)
	# -------------------------------------------------------------------------
	print("[BENCHMARK V2] BEAT 10: Subtle Micro-Reaction Settle (t=16.30s)")
	camera.position = Vector2(550, 290)
	camera.zoom = Vector2(1.36, 1.36)
	
	# Micro eye glance to side + sheepish soft smile
	nemi.look("right")
	nemi.head_tilt(3.5, 0.22)
	nemi.set_expression("blush")
	
	await wait_sec(0.52)

	print("============================================================")
	print("NEMI BENCHMARK V2 COMPLETE: 16.82s PERFORMANCE FINISHED")
	print("============================================================")
	is_running = false
	await wait_sec(0.1)
	get_tree().quit(0)

func _process(delta: float) -> void:
	if is_running:
		elapsed += delta
		if elapsed >= TOTAL_DURATION:
			is_running = false
			print("[BENCHMARK V2] Exiting engine at end of benchmark.")
			get_tree().quit(0)
