class_name CosmoShowcase
extends Node2D

## Dedicated Showcase & Directorial Test Suite for COSMO (Brawl Stars)
## Demonstrates:
## - Full 14-expression vocabulary (Neutral through Realization)
## - Dynamic eye tracking, pill pupil deformations, blinks, and 4-slot teeth visemes
## - Arm gestures, pointing, Attractor gauntlet manipulations, and levitation float
## - TEST A: Cosmo looks through the telescope
## - TEST B: Cosmo notices something unusual in the sky
## - TEST C: Cosmo studies a hand-drawn orbital diagram
## - TEST D: Cosmo demonstrates gravity / magnetism concepts using doodles
## - TEST E: Cosmo has a scientific eureka realization
## - TEST F: Cosmo makes a completely deadpan reaction after something goes wrong
## - Full COLOR and MONOCHROME ink-wash storytelling mode switching

const CosmoScript = preload("res://brawl_stars/characters/cosmo/Cosmo.gd")
const CosmoStyle = preload("res://brawl_stars/characters/cosmo/CosmoStyle.gd")
const CosmoTelescopeScript = preload("res://brawl_stars/assets/props/CosmoTelescope.gd")
const CosmoCelestialOrbsScript = preload("res://brawl_stars/assets/props/CosmoCelestialOrbs.gd")
const CosmoDoodleDirectorScript = preload("res://brawl_stars/scripts/CosmoDoodleDirector.gd")

@onready var cosmo: Node2D = $Cosmo
@onready var telescope: Node2D = $CosmoTelescope
@onready var orbs: Node2D = $CosmoCelestialOrbs
@onready var doodles: Node2D = $DoodleDirector
@onready var status_label: Label = $CanvasLayer/UI/HeaderPanel/Margin/VBox/StatusLabel
@onready var step_label: Label = $CanvasLayer/UI/HeaderPanel/Margin/VBox/HBox/StepLabel
@onready var mode_label: Label = $CanvasLayer/UI/HeaderPanel/Margin/VBox/HBox/ModeLabel

var current_step_index: int = 0
var auto_play: bool = true
var step_duration: float = 1.4
var quit_on_finish: bool = false
var is_movie_mode: bool = false
var _step_timer: float = 0.0

var step_list: Array[Dictionary] = []

func _ready() -> void:
	is_movie_mode = OS.has_feature("movie")
	if is_movie_mode:
		quit_on_finish = true
		step_duration = 1.2
	
	var all_args := OS.get_cmdline_args()
	for arg in all_args:
		if arg.begins_with("--step-duration="):
			step_duration = arg.split("=")[1].to_float()
		elif arg == "--quit-on-finish":
			quit_on_finish = true
	
	_build_step_list()
	
	cosmo.position = Vector2(560, 540)
	telescope.position = Vector2(880, 540)
	orbs.position = Vector2(445, 410)
	
	execute_step(0)

func _process(delta: float) -> void:
	if auto_play:
		_step_timer += delta
		if _step_timer >= step_duration:
			_step_timer = 0.0
			next_step()

func _build_step_list() -> void:
	step_list = [
		# --- PART 1: 14 REQUIRED EXPRESSIONS ---
		{"id": "c_01_neutral", "title": "Expression 1/14: Neutral (Resting astronomer stand)", "method": "_step_c_01"},
		{"id": "c_02_curious", "title": "Expression 2/14: Curious (Head tilt -7°, gaze angled up-right)", "method": "_step_c_02"},
		{"id": "c_03_analytical", "title": "Expression 3/14: Analytical (Narrowed horizontal slit pupil)", "method": "_step_c_03"},
		{"id": "c_04_happy", "title": "Expression 4/14: Happy (Smiling crescent slit ^_^, smiling grill)", "method": "_step_c_04"},
		{"id": "c_05_excited", "title": "Expression 5/14: Excited (Wide glowing eye, dropped shout grill)", "method": "_step_c_05"},
		{"id": "c_06_confused", "title": "Expression 6/14: Confused (Asymmetric head cock 9°, wavy grill)", "method": "_step_c_06"},
		{"id": "c_07_surprised", "title": "Expression 7/14: Surprised (Widened lens, tall shock-O grill)", "method": "_step_c_07"},
		{"id": "c_08_shocked", "title": "Expression 8/14: Shocked (Constricted pin-dot pupil, head recoils)", "method": "_step_c_08"},
		{"id": "c_09_annoyed", "title": "Expression 9/14: Annoyed (Narrowed glare, grimace frown, anger mark)", "method": "_step_c_09"},
		{"id": "c_10_worried", "title": "Expression 10/14: Worried (Constricted lens, wavy mouth, sweat drop)", "method": "_step_c_10"},
		{"id": "c_11_smug", "title": "Expression 11/14: Smug (Half-closed diagonal slit, cocked smirk grill)", "method": "_step_c_11"},
		{"id": "c_12_deadpan", "title": "Expression 12/14: Deadpan (Total straight horizontal bar eye & grill)", "method": "_step_c_12"},
		{"id": "c_13_fascinated", "title": "Expression 13/14: Fascinated (Giant starry lens, cheerful open grill)", "method": "_step_c_13"},
		{"id": "c_14_realization", "title": "Expression 14/14: Realization (Widened lens, eureka star above dome)", "method": "_step_c_14"},
		
		# --- PART 2: ACTING, GAZE & GESTURES ---
		{"id": "act_01_blink", "title": "Acting 1/4: Organic Double-Blink & Saccadic Eye Lead", "method": "_step_act_01"},
		{"id": "act_02_look_around", "title": "Acting 2/4: Gaze Tracking (Left -> Right -> Sky)", "method": "_step_act_02"},
		{"id": "act_03_attractor_aim", "title": "Acting 3/4: Attractor Gauntlet Aim (Point forward)", "method": "_step_act_03"},
		{"id": "act_04_levitation", "title": "Acting 4/4: Anti-Gravity Floating Levitation Field Active", "method": "_step_act_04"},
		
		# --- PART 3: SIX REQUIRED COSMO STORYTELLING TESTS ---
		{"id": "test_a_telescope", "title": "TEST A: Cosmo looks into Observatory Telescope", "method": "_step_test_a"},
		{"id": "test_b_sky_notice", "title": "TEST B: Cosmo notices something unusual in the deep sky", "method": "_step_test_b"},
		{"id": "test_c_orbit_doodle", "title": "TEST C: Cosmo studies a hand-drawn orbital diagram", "method": "_step_test_c"},
		{"id": "test_d_gravity_pull", "title": "TEST D: Cosmo demonstrates Gravity & Magnetic Pull", "method": "_step_test_d"},
		{"id": "test_e_realization", "title": "TEST E: Cosmo has a sudden scientific eureka discovery", "method": "_step_test_e"},
		{"id": "test_f_deadpan_hold", "title": "TEST F: Comedic Deadpan Hold (0-motion freeze after failure)", "method": "_step_test_f"},
		
		# --- PART 4: FINISHED ART MODE SWITCH ---
		{"id": "art_monochrome", "title": "Art Mode: Finished Hand-Drawn Monochrome Ink-Wash Storytelling", "method": "_step_monochrome"}
	]

func execute_step(index: int) -> void:
	if index < 0 or index >= step_list.size():
		return
	current_step_index = index
	var step_info: Dictionary = step_list[current_step_index]
	
	if status_label:
		status_label.text = step_info["title"]
	if step_label:
		step_label.text = "Step %d / %d" % [current_step_index + 1, step_list.size()]
	
	call(step_info["method"])

func next_step() -> void:
	if current_step_index + 1 < step_list.size():
		execute_step(current_step_index + 1)
	else:
		if quit_on_finish:
			get_tree().quit()
		else:
			execute_step(0)

func prev_step() -> void:
	if current_step_index > 0:
		execute_step(current_step_index - 1)

# -------------------------------------------------------------------------
# STEP IMPLEMENTATIONS
# -------------------------------------------------------------------------

func _step_c_01() -> void:
	doodles.clear_all()
	cosmo.set_expression("neutral")
	cosmo.set_pose("idle")
	cosmo.set_art_mode(CosmoStyle.ArtMode.COLOR)
	telescope.is_discovering = false
	telescope.is_monochrome = false
	orbs.is_monochrome = false
	orbs.mode = "hover_palm"

func _step_c_02() -> void:
	cosmo.set_expression("curious")
	cosmo.set_pose("curious_lean")

func _step_c_03() -> void:
	cosmo.set_expression("analytical")
	cosmo.set_pose("observing")

func _step_c_04() -> void:
	cosmo.set_expression("happy")
	cosmo.set_pose("explaining")

func _step_c_05() -> void:
	cosmo.set_expression("excited")
	cosmo.set_pose("explaining")
	orbs.mode = "expand_orbit"

func _step_c_06() -> void:
	cosmo.set_expression("confused")
	cosmo.set_pose("idle")
	orbs.mode = "hover_palm"

func _step_c_07() -> void:
	cosmo.set_expression("surprised")
	cosmo.set_pose("recoil")

func _step_c_08() -> void:
	cosmo.set_expression("shocked")
	cosmo.set_pose("recoil")

func _step_c_09() -> void:
	cosmo.set_expression("annoyed")
	cosmo.set_pose("idle")

func _step_c_10() -> void:
	cosmo.set_expression("worried")
	cosmo.set_pose("recoil")

func _step_c_11() -> void:
	cosmo.set_expression("smug")
	cosmo.set_pose("explaining")

func _step_c_12() -> void:
	cosmo.set_expression("deadpan")
	cosmo.set_pose("deadpan_freeze")

func _step_c_13() -> void:
	cosmo.set_expression("fascinated")
	cosmo.set_pose("curious_lean")

func _step_c_14() -> void:
	cosmo.set_expression("realization")
	cosmo.set_pose("realization_freeze")

# Acting steps
func _step_act_01() -> void:
	cosmo.set_expression("neutral")
	cosmo.set_pose("idle")
	cosmo.double_blink()

func _step_act_02() -> void:
	cosmo.set_expression("analytical")
	cosmo.set_gaze(Vector2(-0.8, -0.6))
	var tw := create_tween()
	tw.tween_interval(0.4)
	tw.tween_callback(func(): cosmo.set_gaze(Vector2(0.8, -0.4)))

func _step_act_03() -> void:
	cosmo.set_expression("analytical")
	cosmo.set_pose("observing")
	if cosmo.visual and cosmo.visual.attractor_arm:
		cosmo.visual.attractor_arm.arm_pose = "point_forward"

func _step_act_04() -> void:
	cosmo.set_expression("neutral")
	cosmo.set_pose("idle")
	cosmo.trigger_levitation_bob(true)

# Story Tests
func _step_test_a() -> void:
	# TEST A: Cosmo looks through telescope
	doodles.clear_all()
	cosmo.trigger_levitation_bob(false)
	cosmo.set_pose("operating_telescope", 0.3)
	cosmo.look_into_telescope(telescope)
	telescope.is_discovering = true
	doodles.spawn_annotation(Vector2(700, 340), "OBSERVING STARR SKY", 0.2, 1.4, 0.3)

func _step_test_b() -> void:
	# TEST B: Cosmo notices something unusual in the sky
	doodles.clear_all()
	telescope.is_discovering = false
	cosmo.set_expression("curious")
	cosmo.set_pose("curious_lean", 0.25)
	cosmo.set_gaze(Vector2(-0.7, -0.8)) # Looking high into sky
	doodles.spawn_circle(Vector2(260, 200), 45.0, 0.25, 1.2, 0.3)
	doodles.spawn_arrow(Vector2(320, 260), Vector2(280, 220), 0.25, 1.2, 0.3)
	doodles.spawn_annotation(Vector2(200, 140), "ANOMALY DETECTED", 0.2, 1.2, 0.3)

func _step_test_c() -> void:
	# TEST C: Cosmo studies a hand-drawn orbital diagram
	doodles.clear_all()
	cosmo.set_expression("analytical")
	cosmo.set_pose("explaining", 0.2)
	cosmo.set_gaze(Vector2(-0.6, 0.1))
	doodles.spawn_orbit_diagram(Vector2(260, 420), 85.0, 36.0, 0.3, 1.6, 0.3)
	doodles.spawn_annotation(Vector2(160, 340), "ORBIT RADIUS R=3.8m", 0.2, 1.5, 0.3)

func _step_test_d() -> void:
	# TEST D: Cosmo demonstrates gravity / magnetic pull using doodles
	doodles.clear_all()
	cosmo.set_expression("excited")
	cosmo.set_pose("explaining", 0.2)
	orbs.mode = "expand_orbit"
	doodles.spawn_gravity_concept(Vector2(250, 420), 0.3, 1.5, 0.3)
	doodles.spawn_magnetic_pull(Vector2(440, 410), Vector2(250, 420), 0.3, 1.5, 0.3)
	doodles.spawn_annotation(Vector2(160, 340), "GRAVITATIONAL PULL", 0.2, 1.5, 0.3)

func _step_test_e() -> void:
	# TEST E: Cosmo has a scientific eureka realization
	doodles.clear_all()
	cosmo.set_expression("realization")
	cosmo.set_pose("realization_freeze", 0.15)
	orbs.mode = "hover_palm"
	doodles.spawn_circle(Vector2(600, 240), 30.0, 0.2, 1.4, 0.3)
	doodles.spawn_annotation(Vector2(550, 190), "EUREKA!", 0.2, 1.4, 0.3)

func _step_test_f() -> void:
	# TEST F: Cosmo makes a completely deadpan reaction after something goes wrong
	doodles.clear_all()
	cosmo.set_expression("deadpan")
	cosmo.set_pose("deadpan_freeze", 0.05) # Instant snap to 0-motion freeze
	orbs.mode = "idle"
	doodles.spawn_annotation(Vector2(200, 320), "...CALCULATION ERROR.", 0.2, 1.6, 0.3)

func _step_monochrome() -> void:
	doodles.clear_all()
	cosmo.set_art_mode(CosmoStyle.ArtMode.MONOCHROME)
	telescope.is_monochrome = true
	orbs.is_monochrome = true
	if mode_label:
		mode_label.text = "Art Mode: MONOCHROME INK-WASH"
	cosmo.set_expression("analytical")
	cosmo.set_pose("explaining")
