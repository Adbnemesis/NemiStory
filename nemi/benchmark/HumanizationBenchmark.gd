class_name HumanizationBenchmark
extends Node2D

## Humanization Benchmark Test for NEMI
## Target Length: 11.5 seconds @ 30 FPS progressive
## Voice: Sohee canonical voice ("seven views / from my own phone" slice)
## Tests:
## - SHOT A (0.00s - 1.20s): Grounded Conversational Baseline
## - SHOT B (1.20s - 2.40s): Eye Dart / Attention Leads Head
## - SHOT C (2.40s - 3.80s): Asymmetric Weight Shift & Contrapposto
## - SHOT D (3.80s - 5.00s): Storytelling Staging & Live Imperfect Doodle Reveal
## - SHOT E (5.00s - 6.20s): Comedic Shock Anticipation & Recoil
## - SHOT F (6.20s - 7.50s): Expressive Hand Gesture Climax (FINGER_COUNT_THREE)
## - SHOT G (7.50s - 8.80s): Embarrassed Confession & Splay
## - SHOT H (8.80s - 10.00s): Settle & Secondary Motion
## - SHOT I (10.00s - 11.00s): Sustained Stillness Hold (>85% stillness)
## - SHOT J (11.00s - 11.50s): Subtle Human Micro-reaction

@onready var world_system: WorldSystemDirector = $WorldSystem
@onready var camera: StoryCamera2D = $StoryCamera2D
@onready var nemi: Node2D = $Nemi
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var subtitle_label: Label = $UI/Subtitle
@onready var human_doodles: Node2D = $HumanDoodlesLayer

const TOTAL_DURATION: float = 11.50
var elapsed: float = 0.0
var is_running: bool = false

func _ready() -> void:
	# Ensure audio stream is loaded
	if voice_player and not voice_player.stream:
		if ResourceLoader.exists("res://nemi/benchmark/benchmark_voice.wav"):
			voice_player.stream = load("res://nemi/benchmark/benchmark_voice.wav")

	# Set up world environment to studio workspace
	if world_system:
		world_system.set_environment(2, 2) # Workspace, normal density

	run_benchmark()

func set_sub(text: String) -> void:
	if subtitle_label:
		subtitle_label.text = text

func wait_sec(sec: float) -> void:
	await get_tree().create_timer(sec).timeout

func run_benchmark() -> void:
	is_running = true
	elapsed = 0.0

	# Start audio
	if voice_player and voice_player.stream:
		voice_player.play(0.0)

	print("============================================================")
	print("NEMI HUMANIZATION BENCHMARK: 10-SHOT PERFORMANCE TEST (11.5s)")
	print("============================================================")

	# -------------------------------------------------------------------------
	# SHOT A (0.00s - 1.20s): Grounded Conversational Baseline
	# -------------------------------------------------------------------------
	print("[BENCHMARK] SHOT A: Conversational Baseline (t=0.00s)")
	nemi.reset()
	nemi.set_pose("conversational_open_one", 0.0)
	nemi.shift_weight("right", 0.0)
	nemi.set_expression("candid")
	nemi.look("center")
	set_sub("Because literally last week,")

	await wait_sec(1.20)

	# -------------------------------------------------------------------------
	# SHOT B (1.20s - 2.40s): Eye Dart / Attention Leads Head
	# -------------------------------------------------------------------------
	print("[BENCHMARK] SHOT B: Attention Leads Movement (t=1.20s)")
	# 1. Gaze shifts first to upper-left
	nemi.look("up_left")
	await wait_sec(0.12)

	# 2. Head follows gaze with natural tilt
	nemi.head_tilt(-5.5, 0.20)
	await wait_sec(0.18)

	# 3. Body gesture follows head: transitions to conversational pointing/counting
	set_sub("I was refreshing")
	nemi.transition_pose("conversational_point_low", 0.26, true, true)
	await wait_sec(0.90)

	# -------------------------------------------------------------------------
	# SHOT C (2.40s - 3.80s): Asymmetric Weight Shift & Contrapposto
	# -------------------------------------------------------------------------
	print("[BENCHMARK] SHOT C: Weight Shift & Contrapposto (t=2.40s)")
	set_sub("at two in the morning,")
	# Shift weight over to left hip, counter-balance torso
	nemi.shift_weight("left", 0.32)
	nemi.transition_pose("thinking_chin_tap", 0.30, true, true)
	nemi.set_expression("thinking")
	nemi.look("center")
	await wait_sec(1.40)

	# -------------------------------------------------------------------------
	# SHOT D (3.80s - 5.00s): Storytelling Staging & Live Imperfect Doodle Reveal
	# -------------------------------------------------------------------------
	print("[BENCHMARK] SHOT D: Live Imperfect Doodle Reveal (t=3.80s)")
	set_sub("staring at seven views...")
	nemi.transition_pose("point_down_subtle", 0.25, true, true)
	nemi.set_expression("deadpan")

	# Camera subtle punch-in
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(640, 360), 1.08, 0.20)

	# Live hand-drawn vector doodle: "7 VIEWS" + overlapping organic circle
	var doodle_center := Vector2(850, 240)
	human_doodles.spawn_handwritten_text(doodle_center + Vector2(-65, 0), "7 VIEWS", 1.15, 0.30)
	human_doodles.spawn_imperfect_circle(doodle_center, 46.0, 0.26)

	await wait_sec(1.20)

	# -------------------------------------------------------------------------
	# SHOT E (5.00s - 6.20s): Comedic Shock Anticipation & Recoil
	# -------------------------------------------------------------------------
	print("[BENCHMARK] SHOT E: Shock Anticipation & Recoil (t=5.00s)")
	set_sub("And honestly?")
	human_doodles.clear_all(0.18)

	# Anticipation dip
	await wait_sec(0.20)

	# Comedic shock recoil backwards!
	nemi.react("shocked", 3, 0.7)
	nemi.transition_pose("scared_recoil", 0.16, false, true)
	nemi.set_expression("shocked")
	if camera and camera.has_method("shake"):
		camera.shake(4.0, 0.22)

	await wait_sec(1.00)

	# -------------------------------------------------------------------------
	# SHOT F (6.20s - 7.50s): Expressive Hand Gesture Climax
	# -------------------------------------------------------------------------
	print("[BENCHMARK] SHOT F: Expressive Hand Climax (Three Fingers) (t=6.20s)")
	set_sub("Three of those were")
	# Return camera zoom to 1.0 for full conversational clarity
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(640, 360), 1.0, 0.20)
	# Lean into counting_three with distinct FINGER_COUNT_THREE hand pose
	nemi.transition_pose("counting_three", 0.28, true, true)
	nemi.set_expression("candid")
	nemi.look("center")
	await wait_sec(1.30)

	# -------------------------------------------------------------------------
	# SHOT G (7.50s - 8.80s): Embarrassed Confession & Splay
	# -------------------------------------------------------------------------
	print("[BENCHMARK] SHOT G: Embarrassed Confession (t=7.50s)")
	set_sub("from my own phone!")
	nemi.shift_weight("right", 0.28)
	nemi.transition_pose("shy_confession", 0.26, true, true)
	nemi.set_expression("blush")
	human_doodles.spawn_wobbly_underline(Vector2(470, 700), 330.0, 0.22)
	await wait_sec(1.30)

	# -------------------------------------------------------------------------
	# SHOT H (8.80s - 10.00s): Settle & Secondary Motion
	# -------------------------------------------------------------------------
	print("[BENCHMARK] SHOT H: Settle & Secondary Physics (t=8.80s)")
	set_sub("")
	human_doodles.clear_all(0.20)
	# Weight returns to center, posture exhales and relaxes
	nemi.shift_weight("center", 0.35)
	nemi.transition_pose("conversational_open_one", 0.38, false, true)
	nemi.set_expression("candid")
	await wait_sec(1.20)

	# -------------------------------------------------------------------------
	# SHOT I (10.00s - 11.00s): Sustained Stillness Hold (>85% stillness hold)
	# -------------------------------------------------------------------------
	print("[BENCHMARK] SHOT I: Sustained Stillness Hold (t=10.00s)")
	# 1.0 second of rock-solid stillness hold holding eye contact
	if nemi.performance_director:
		nemi.performance_director.hold(1.0)
	await wait_sec(1.00)

	# -------------------------------------------------------------------------
	# SHOT J (11.00s - 11.50s): Subtle Human Micro-reaction
	# -------------------------------------------------------------------------
	print("[BENCHMARK] SHOT J: Subtle Micro-reaction (t=11.00s)")
	nemi.blink(0.18)
	nemi.head_tilt(1.4, 0.18)
	nemi.set_expression("warm_smile")
	await wait_sec(0.50)

	print("[BENCHMARK] Benchmark Complete at t=11.50s!")
	is_running = false

func _process(delta: float) -> void:
	if is_running:
		elapsed += delta
		if elapsed >= TOTAL_DURATION:
			is_running = false
			print("[BENCHMARK] Exiting engine at end of benchmark.")
			get_tree().quit(0)
