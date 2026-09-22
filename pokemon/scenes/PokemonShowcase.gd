class_name PokemonShowcase
extends Node2D

## Dedicated Showcase & Test Harness for PIKACHU and ASH KETCHUM
## Demonstrates:
## - Full 20-expression vocabulary on both characters
## - Natural scale & staging (Pikachu beside Ash)
## - Gaze tracking, mutual eye contact, and object focus
## - Snappy acting, anticipation -> action -> reaction, and secondary motion
## - Comedic deadpan hold (total freeze)
## - Interactive Poké Ball prop manipulation
## - Progressive hand-drawn ink doodles (arrows, focus circles, annotations)
## - Instant 100% geometry-preserving Color / Monochrome switching

const PikachuScript = preload("res://pokemon/characters/pikachu/Pikachu.gd")
const AshScript = preload("res://pokemon/characters/ash/Ash.gd")
const PokeBallScript = preload("res://pokemon/assets/props/PokeBall.gd")
const DoodleDirectorScript = preload("res://pokemon/scripts/PokemonDoodleDirector.gd")

@onready var ash: Node2D = $Ash
@onready var pikachu: Node2D = $Pikachu
@onready var pokeball: Node2D = $PokeBall
@onready var doodles: Node2D = $DoodleDirector
@onready var status_label: Label = $CanvasLayer/UI/HeaderPanel/Margin/VBox/StatusLabel
@onready var step_label: Label = $CanvasLayer/UI/HeaderPanel/Margin/VBox/HBox/StepLabel
@onready var mode_label: Label = $CanvasLayer/UI/HeaderPanel/Margin/VBox/HBox/ModeLabel

var current_step_index: int = 0
var auto_play: bool = true
var step_duration: float = 1.2
var quit_on_finish: bool = false
var is_movie_mode: bool = false
var _step_timer: float = 0.0

var step_list: Array[Dictionary] = []

func _ready() -> void:
	is_movie_mode = OS.has_feature("movie")
	if is_movie_mode:
		quit_on_finish = true
		step_duration = 1.2
		print("MovieWriter detected: auto-terminating after 1 complete cycle.")
	
	# Parse command line args
	var all_args := OS.get_cmdline_args()
	for arg in all_args:
		if arg.begins_with("--step-duration="):
			step_duration = arg.split("=")[1].to_float()
		elif arg == "--quit-on-finish":
			quit_on_finish = true
	
	_build_step_list()
	
	ash.position = Vector2(480, 560)
	pikachu.position = Vector2(760, 560)
	pokeball.position = Vector2(640, 520)
	
	execute_step(0)

func _process(delta: float) -> void:
	if auto_play:
		_step_timer += delta
		if _step_timer >= step_duration:
			_step_timer = 0.0
			next_step()

func _build_step_list() -> void:
	step_list = [
		{"id": "pika_01_neutral", "title": "Pikachu Test 1/10: Neutral", "method": "_step_pika_01"},
		{"id": "pika_02_happy", "title": "Pikachu Test 2/10: Happy (Smiling arcs, ear perk, tail wag)", "method": "_step_pika_02"},
		{"id": "pika_03_curious", "title": "Pikachu Test 3/10: Curious (Head cock 12°, one ear up)", "method": "_step_pika_03"},
		{"id": "pika_04_confused", "title": "Pikachu Test 4/10: Confused (Spiral eyes, wavy mouth)", "method": "_step_pika_04"},
		{"id": "pika_05_surprised", "title": "Pikachu Test 5/10: Surprised (Widened pupils, small 'o' mouth)", "method": "_step_pika_05"},
		{"id": "pika_06_shocked", "title": "Pikachu Test 6/10: Shocked (Constricted pupil, ears rigid, dropped jaw)", "method": "_step_pika_06"},
		{"id": "pika_07_annoyed", "title": "Pikachu Test 7/10: Annoyed (Narrowed glare, flat mouth, ears back)", "method": "_step_pika_07"},
		{"id": "pika_08_excited", "title": "Pikachu Test 8/10: Excited (Cheering arms, sparking tail, open shout)", "method": "_step_pika_08"},
		{"id": "pika_09_sad", "title": "Pikachu Test 9/10: Sad (Large dewy eyes, drooped ears & tail)", "method": "_step_pika_09"},
		{"id": "pika_10_deadpan", "title": "Pikachu Test 10/10: Deadpan (Horizontal dash mouth, total stillness)", "method": "_step_pika_10"},
		
		{"id": "ash_01_neutral", "title": "Ash Test 1/10: Neutral (Relaxed athletic stand)", "method": "_step_ash_01"},
		{"id": "ash_02_happy", "title": "Ash Test 2/10: Happy (Confident grin, fist pump)", "method": "_step_ash_02"},
		{"id": "ash_03_curious", "title": "Ash Test 3/10: Curious (Asymmetric brows, head tilt)", "method": "_step_ash_03"},
		{"id": "ash_04_confused", "title": "Ash Test 4/10: Confused (One brow arched, wavy mouth)", "method": "_step_ash_04"},
		{"id": "ash_05_surprised", "title": "Ash Test 5/10: Surprised (Arched high brows, widened eyes)", "method": "_step_ash_05"},
		{"id": "ash_06_shocked", "title": "Ash Test 6/10: Shocked (Pin-dot pupils, jaw dropped, recoil posture)", "method": "_step_ash_06"},
		{"id": "ash_07_embarrassed", "title": "Ash Test 7/10: Embarrassed (Cheek blush, sweat drop, sheepish grin)", "method": "_step_ash_07"},
		{"id": "ash_08_excited", "title": "Ash Test 8/10: Excited (Toothy cheering mouth, determined brows)", "method": "_step_ash_08"},
		{"id": "ash_09_worried", "title": "Ash Test 9/10: Worried (Knitted inward brows, sweat, tight mouth)", "method": "_step_ash_09"},
		{"id": "ash_10_deadpan", "title": "Ash Test 10/10: Deadpan (Signature straight horizontal dash mouth)", "method": "_step_ash_10"},
		
		{"id": "inter_01_eye_contact", "title": "Interaction 1/8: Ash looks at Pikachu -> Pikachu looks up at Ash", "method": "_step_inter_01"},
		{"id": "inter_02_pika_reacts", "title": "Interaction 2/8: Pikachu reacts excitedly while Ash remains still", "method": "_step_inter_02"},
		{"id": "inter_03_ash_points", "title": "Interaction 3/8: Ash points at target -> Pikachu takes battle stance", "method": "_step_inter_03"},
		{"id": "inter_04_prop", "title": "Interaction 4/8: Prop Interaction (Poké Ball drops in, both focus eyes)", "method": "_step_inter_04"},
		{"id": "inter_05_doodle", "title": "Interaction 5/8: Hand-Drawn Doodle System (Organic circle & arrow)", "method": "_step_inter_05"},
		{"id": "inter_06_open_ball", "title": "Interaction 6/8: Poké Ball opens with spark release", "method": "_step_inter_06"},
		{"id": "inter_07_deadpan_hold", "title": "Interaction 7/8: Comedic Deadpan Hold (Total simultaneous freeze)", "method": "_step_inter_07"},
		{"id": "inter_08_monochrome", "title": "Interaction 8/8: Finished Monochrome Ink-Wash Storytelling Mode", "method": "_step_inter_08"}
	]

func execute_step(idx: int) -> void:
	if step_list.is_empty():
		return
	current_step_index = idx
	var s: Dictionary = step_list[current_step_index]
	status_label.text = s["title"]
	step_label.text = "Step %d / %d" % [current_step_index + 1, step_list.size()]
	print("[Showcase Step %02d/28] %s" % [current_step_index + 1, s["title"]])
	call(s["method"])

func next_step() -> void:
	if current_step_index + 1 >= step_list.size():
		if quit_on_finish or is_movie_mode:
			print("All 28 showcase steps completed successfully. Quitting.")
			get_tree().quit(0)
			return
		execute_step(0)
	else:
		execute_step(current_step_index + 1)

func prev_step() -> void:
	var prev_idx := (current_step_index - 1 + step_list.size()) % step_list.size()
	execute_step(prev_idx)

# --- PIKACHU STEP IMPLEMENTATIONS ---
func _step_pika_01() -> void:
	pikachu.call("set_expression", "neutral")
	pikachu.call("set_pose", "idle", 0.2)
	ash.call("set_expression", "neutral")
	ash.call("set_pose", "idle", 0.2)

func _step_pika_02() -> void:
	pikachu.call("set_expression", "happy")
	pikachu.call("set_pose", "happy_bounce", 0.2)

func _step_pika_03() -> void:
	pikachu.call("set_expression", "confused")
	pikachu.call("set_pose", "curious_tilt", 0.2)

func _step_pika_04() -> void:
	pikachu.call("set_expression", "confused")

func _step_pika_05() -> void:
	pikachu.call("set_expression", "surprised")
	pikachu.call("squash_stretch", Vector2(0.92, 1.12), 0.2)

func _step_pika_06() -> void:
	pikachu.call("set_expression", "shocked")
	pikachu.call("set_pose", "shock_recoil", 0.2)

func _step_pika_07() -> void:
	pikachu.call("set_expression", "annoyed")
	pikachu.call("set_pose", "pout_slump", 0.2)

func _step_pika_08() -> void:
	pikachu.call("set_expression", "excited")
	pikachu.call("set_pose", "cheering", 0.2)

func _step_pika_09() -> void:
	pikachu.call("set_expression", "sad")
	pikachu.call("set_pose", "pout_slump", 0.2)

func _step_pika_10() -> void:
	pikachu.call("set_expression", "deadpan")
	pikachu.call("set_pose", "deadpan_freeze", 0.0)

# --- ASH STEP IMPLEMENTATIONS ---
func _step_ash_01() -> void:
	ash.call("set_expression", "neutral")
	ash.call("set_pose", "idle", 0.2)
	pikachu.call("set_expression", "neutral")
	pikachu.call("set_pose", "idle", 0.2)

func _step_ash_02() -> void:
	ash.call("set_expression", "happy")
	ash.call("set_pose", "confident_fist", 0.2)

func _step_ash_03() -> void:
	ash.call("set_expression", "confused")
	ash.call("look", "up_left")

func _step_ash_04() -> void:
	ash.call("set_expression", "confused")
	ash.call("set_pose", "scratch_head", 0.2)

func _step_ash_05() -> void:
	ash.call("set_expression", "surprised")

func _step_ash_06() -> void:
	ash.call("set_expression", "shocked")
	ash.call("set_pose", "shock_recoil", 0.2)

func _step_ash_07() -> void:
	ash.call("set_expression", "embarrassed")
	ash.call("set_pose", "scratch_head", 0.2)

func _step_ash_08() -> void:
	ash.call("set_expression", "excited")
	ash.call("set_pose", "confident_fist", 0.2)

func _step_ash_09() -> void:
	ash.call("set_expression", "worried")
	ash.call("set_pose", "recoil", 0.2)

func _step_ash_10() -> void:
	ash.call("set_expression", "deadpan")
	ash.call("set_pose", "deadpan_freeze", 0.0)

# --- INTERACTION STEP IMPLEMENTATIONS ---
func _step_inter_01() -> void:
	ash.call("set_pose", "look_at_pikachu", 0.25)
	ash.call("set_expression", "happy")
	pikachu.call("look", "up_left")
	pikachu.call("set_expression", "happy")
	pikachu.call("set_pose", "happy_bounce", 0.25)

func _step_inter_02() -> void:
	ash.call("set_pose", "idle", 0.2)
	ash.call("set_expression", "neutral")
	pikachu.call("set_expression", "excited")
	pikachu.call("set_pose", "cheering", 0.2)
	pikachu.call("trigger_spark_fx", 1.0)

func _step_inter_03() -> void:
	ash.call("turn_cap", true)
	ash.call("set_expression", "determined")
	ash.call("set_pose", "point_forward", 0.2)
	pikachu.call("set_expression", "determined")
	pikachu.call("set_pose", "battle_stance", 0.2)
	pikachu.call("look", "right")

func _step_inter_04() -> void:
	pokeball.position = Vector2(640, 520)
	pokeball.call("pop_in", 0.25)
	pokeball.call("bounce", 24.0, 0.35)
	ash.call("look_at_target", Vector2(640, 520))
	ash.call("set_expression", "surprised")
	pikachu.call("look_at_pos", Vector2(640, 520))
	pikachu.call("set_expression", "surprised")

func _step_inter_05() -> void:
	doodles.call("clear_all_doodles", 0.1)
	doodles.call("draw_doodle_circle", Vector2(640, 520), 32.0, 0.35)
	doodles.call("draw_doodle_arrow", Vector2(520, 420), Vector2(610, 500), 0.3)
	doodles.call("draw_doodle_label", "POKÉ BALL", Vector2(460, 400), 0.25)
	doodles.call("draw_doodle_question", Vector2(760, 430), 0.3)
	pikachu.call("set_expression", "confused")
	ash.call("set_expression", "smug")

func _step_inter_06() -> void:
	pokeball.call("open_ball", 0.2)
	pikachu.call("set_expression", "excited")
	pikachu.call("set_pose", "cheering", 0.2)
	pikachu.call("trigger_spark_fx", 0.8)
	ash.call("set_expression", "excited")

func _step_inter_07() -> void:
	doodles.call("clear_all_doodles", 0.1)
	pokeball.call("close_ball", 0.15)
	ash.call("turn_cap", false)
	ash.call("set_expression", "deadpan")
	ash.call("set_pose", "deadpan_freeze", 0.0)
	pikachu.call("set_expression", "deadpan")
	pikachu.call("set_pose", "deadpan_freeze", 0.0)

func _step_inter_08() -> void:
	ash.call("set_art_mode", 1)
	pikachu.call("set_art_mode", 1)
	mode_label.text = "Art Mode: MONOCHROME"
	ash.call("set_expression", "happy")
	ash.call("set_pose", "confident_fist", 0.2)
	pikachu.call("set_expression", "happy")
	pikachu.call("set_pose", "happy_bounce", 0.2)
