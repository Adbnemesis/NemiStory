class_name RuffsShowcase
extends Node2D

## Dedicated Showcase & Directorial Test Suite for COLONEL RUFFS (Brawl Stars)
## Demonstrates:
## - Full 14-expression vocabulary (Neutral through Mission Accomplished)
## - Single eye gaze tracking, brow tilts, blinks, and canine visemes (including panting tongue & growl)
## - Canine floppy basset hound ear physics (twitches, alert perks, sad droops)
## - Stances: Parade rest, attention, swagger on hip, commanding point
## - TEST A: Military Attention & Crisp Salute
## - TEST B: Tactical Laser Bounce Assessment (Twin Ricochet Lasers)
## - TEST C: Calling Starr Force Supply Drop & Golden Bone Power-Up
## - TEST D: Military Briefing Strategy Doodles (Flanking arrows & LZ circles)
## - TEST E: Canine Instinct vs Military Composure (Bone thought bubble & ear twitch)
## - TEST F: Comedic Deadpan Hold (0-motion freeze after absurdity)
## - Full COLOR and MONOCHROME ink-wash storytelling mode switching

const RuffsScript = preload("res://brawl_stars/characters/ruffs/Ruffs.gd")
const RuffsStyle = preload("res://brawl_stars/characters/ruffs/RuffsStyle.gd")
const RuffsBlasterScript = preload("res://brawl_stars/assets/props/RuffsBlaster.gd")
const RuffsSupplyDropScript = preload("res://brawl_stars/assets/props/RuffsSupplyDrop.gd")
const RuffsDoodleDirectorScript = preload("res://brawl_stars/scripts/RuffsDoodleDirector.gd")

@onready var ruffs: Node2D = $Ruffs
@onready var blaster: Node2D = $RuffsBlaster
@onready var supply_drop: Node2D = $RuffsSupplyDrop
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
	
	ruffs.position = Vector2(560, 520)
	blaster.position = Vector2(495, 460)
	blaster.visible = false
	supply_drop.position = Vector2(920, 500)
	supply_drop.visible = false
	
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
		{"id": "r_01_neutral", "title": "Expression 1/14: Neutral (Stoic Commander Resting Stance)", "method": "_step_r_01"},
		{"id": "r_02_curious", "title": "Expression 2/14: Curious (Head cock -8°, ear perked, brow tilted)", "method": "_step_r_02"},
		{"id": "r_03_analytical", "title": "Expression 3/14: Analytical (Narrowed eye, calculating ricochet trajectory)", "method": "_step_r_03"},
		{"id": "r_04_happy", "title": "Expression 4/14: Happy (Smiling crescent eye, upturned cream jowls)", "method": "_step_r_04"},
		{"id": "r_05_excited", "title": "Expression 5/14: Excited (Wide glowing eye, perked ears, panting tongue!)", "method": "_step_r_05"},
		{"id": "r_06_confused", "title": "Expression 6/14: Confused (Asymmetric hound ear drop, brow tilted)", "method": "_step_r_06"},
		{"id": "r_07_surprised", "title": "Expression 7/14: Surprised (Wide pupil, ears flying outward, open shout)", "method": "_step_r_07"},
		{"id": "r_08_shocked", "title": "Expression 8/14: Shocked (Constricted pupil, sweat drop, dismayed ear droop)", "method": "_step_r_08"},
		{"id": "r_09_annoyed", "title": "Expression 9/14: Annoyed (Anger mark FX, bared teeth growl, stern command glare)", "method": "_step_r_09"},
		{"id": "r_10_worried", "title": "Expression 10/14: Worried (Drooping ears, sweat drop, nervous muzzle)", "method": "_step_r_10"},
		{"id": "r_11_smug", "title": "Expression 11/14: Smug (Half-closed eye, cocky officer smirk, chin raised)", "method": "_step_r_11"},
		{"id": "r_12_deadpan", "title": "Expression 12/14: Deadpan (Total flat horizontal stare & mouth line, zero emotion)", "method": "_step_r_12"},
		{"id": "r_13_disciplined", "title": "Expression 13/14: Disciplined (Strict military focus, heels clicked, straight spine)", "method": "_step_r_13"},
		{"id": "r_14_mission_accomplished", "title": "Expression 14/14: Mission Accomplished (Proud grinning commander, chest puffed)", "method": "_step_r_14"},
		
		# --- PART 2: ACTING, CANINE DYNAMICS & MILITARY MECHANICS ---
		{"id": "act_01_blink", "title": "Acting 1/4: Organic Double-Blink & Single Eye Tracking", "method": "_step_act_01"},
		{"id": "act_02_ear_twitch", "title": "Acting 2/4: Canine Instinct Ear Twitch & Perked Alert", "method": "_step_act_02"},
		{"id": "act_03_aim_blaster", "title": "Acting 3/4: Double-Barrel Blaster Draw & Twin Laser Burst", "method": "_step_act_03"},
		{"id": "act_04_attention_salute", "title": "Acting 4/4: Snappy Military Attention & Crisp Salute", "method": "_step_act_04"},
		
		# --- PART 3: SIX DEDICATED RUFFS STORYTELLING TESTS ---
		{"id": "test_a_salute", "title": "TEST A: Military Attention & Crisp Salute", "method": "_step_test_a"},
		{"id": "test_b_ricochet", "title": "TEST B: Tactical Laser Bounce Assessment (Twin Ricochet)", "method": "_step_test_b"},
		{"id": "test_c_supply_drop", "title": "TEST C: Calling Starr Force Supply Drop (Airstrike LZ & Power-Up)", "method": "_step_test_c"},
		{"id": "test_d_briefing", "title": "TEST D: Military Briefing Strategy Doodles (Flanking arrows & LZ)", "method": "_step_test_d"},
		{"id": "test_e_canine_instinct", "title": "TEST E: Canine Instinct vs Military Composure (Bone thought & ear twitch)", "method": "_step_test_e"},
		{"id": "test_f_deadpan_hold", "title": "TEST F: Comedic Deadpan Hold ('...YOU GOTTA BE KIDDING.')", "method": "_step_test_f"},
		
		# --- PART 4: FINISHED ART MODE SWITCH ---
		{"id": "art_monochrome", "title": "Art Mode: Finished Hand-Drawn Monochrome Ink-Wash Storytelling", "method": "_step_monochrome"}
	]

func execute_step(index: int) -> void:
	if index < 0 or index >= step_list.size():
		return
	current_step_index = index
	var step_info: Dictionary = step_list[current_step_index]
	print("EXEC STEP ", index, ": ", step_info["title"], " -> ", step_info["method"])
	
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

func _step_r_01() -> void:
	doodles.clear_all()
	ruffs.set_expression("neutral")
	ruffs.set_pose("parade_rest")
	ruffs.set_art_mode(RuffsStyle.ArtMode.COLOR)
	blaster.visible = false
	blaster.is_firing = false
	blaster.is_monochrome = false
	supply_drop.visible = false
	supply_drop.is_monochrome = false
	if mode_label:
		mode_label.text = "Art Mode: COLOR"

func _step_r_02() -> void:
	ruffs.set_expression("curious")
	ruffs.set_pose("curious_lean")

func _step_r_03() -> void:
	ruffs.set_expression("analytical")
	ruffs.set_pose("command_point")

func _step_r_04() -> void:
	ruffs.set_expression("happy")
	ruffs.set_pose("on_hip")

func _step_r_05() -> void:
	ruffs.set_expression("excited")
	ruffs.set_pose("on_hip")

func _step_r_06() -> void:
	ruffs.set_expression("confused")
	ruffs.set_pose("parade_rest")

func _step_r_07() -> void:
	ruffs.set_expression("surprised")
	ruffs.set_pose("recoil")

func _step_r_08() -> void:
	ruffs.set_expression("shocked")
	ruffs.set_pose("recoil")

func _step_r_09() -> void:
	ruffs.set_expression("annoyed")
	ruffs.set_pose("on_hip")

func _step_r_10() -> void:
	ruffs.set_expression("worried")
	ruffs.set_pose("recoil")

func _step_r_11() -> void:
	ruffs.set_expression("smug")
	ruffs.set_pose("on_hip")

func _step_r_12() -> void:
	ruffs.set_expression("deadpan")
	ruffs.set_pose("parade_rest")

func _step_r_13() -> void:
	ruffs.set_expression("disciplined")
	ruffs.set_pose("parade_rest")

func _step_r_14() -> void:
	ruffs.set_expression("mission_accomplished")
	ruffs.set_pose("on_hip")

# Acting steps
func _step_act_01() -> void:
	ruffs.set_expression("neutral")
	ruffs.set_pose("parade_rest")
	ruffs.double_blink()
	var tw := create_tween()
	tw.tween_interval(0.3)
	tw.tween_callback(func(): ruffs.set_gaze(Vector2(-0.7, -0.2)))
	tw.tween_interval(0.4)
	tw.tween_callback(func(): ruffs.set_gaze(Vector2(0.7, -0.3)))

func _step_act_02() -> void:
	ruffs.set_expression("curious")
	ruffs.twitch_ears()
	var tw := create_tween()
	tw.tween_interval(0.4)
	tw.tween_callback(func(): ruffs.perk_ears())

func _step_act_03() -> void:
	ruffs.set_expression("analytical")
	ruffs.set_pose("aim_blaster")
	blaster.visible = true
	blaster.position = Vector2(480, 460)
	blaster.is_firing = true

func _step_act_04() -> void:
	blaster.visible = false
	blaster.is_firing = false
	ruffs.set_expression("disciplined")
	ruffs.set_pose("salute", 0.15)

# Story Tests
func _step_test_a() -> void:
	# TEST A: Military Attention & Crisp Salute
	doodles.clear_all()
	blaster.visible = false
	ruffs.set_expression("disciplined")
	ruffs.set_pose("salute", 0.12)
	doodles.spawn_annotation(Vector2(650, 360), "ATTENTION! SALUTE.", 0.2, 1.4, 0.3)

func _step_test_b() -> void:
	# TEST B: Tactical Laser Bounce Assessment
	doodles.clear_all()
	ruffs.set_expression("analytical")
	ruffs.set_pose("aim_blaster", 0.2)
	blaster.visible = true
	blaster.position = Vector2(480, 460)
	blaster.is_firing = false
	ruffs.set_gaze(Vector2(-0.8, -0.3))
	
	# Spawn ricochet doodle: from blaster muzzle (430, 450) to wall (240, 320) to target (380, 180)
	doodles.spawn_ricochet_trajectory(Vector2(430, 450), Vector2(240, 320), Vector2(380, 180), 0.35, 1.6, 0.3)
	doodles.spawn_annotation(Vector2(140, 240), "RICOCHET ANGLE CALCULATED", 0.2, 1.5, 0.3)

func _step_test_c() -> void:
	# TEST C: Calling Starr Force Supply Drop
	doodles.clear_all()
	blaster.visible = false
	ruffs.set_expression("smug")
	ruffs.set_pose("command_point", 0.2)
	supply_drop.visible = true
	supply_drop.position = Vector2(920, 500)
	
	# Targeting LZ doodle
	doodles.spawn_lz_target(Vector2(920, 520), 70.0, 0.3, 1.8, 0.3)
	doodles.spawn_annotation(Vector2(780, 320), "SUPPLY POD DEPLOYED!", 0.2, 1.5, 0.3)

func _step_test_d() -> void:
	# TEST D: Military Briefing Strategy Doodles
	doodles.clear_all()
	supply_drop.visible = false
	ruffs.set_expression("analytical")
	ruffs.set_pose("command_point", 0.2)
	
	# Flanking maneuver arrows and objective circles
	doodles.spawn_arrow(Vector2(320, 480), Vector2(180, 340), 0.25, 1.4, 0.3)
	doodles.spawn_arrow(Vector2(180, 340), Vector2(360, 240), 0.25, 1.4, 0.3)
	doodles.spawn_circle(Vector2(360, 240), 40.0, 0.25, 1.4, 0.3)
	doodles.spawn_annotation(Vector2(120, 260), "OBJECTIVE ALPHA: FLANK ENEMY", 0.2, 1.5, 0.3)

func _step_test_e() -> void:
	# TEST E: Canine Instinct vs Military Composure
	doodles.clear_all()
	ruffs.set_expression("curious")
	ruffs.set_pose("parade_rest", 0.2)
	ruffs.twitch_ears()
	
	# Thought bubble of dog bone appearing
	doodles.spawn_bone_thought(Vector2(560, 420), 0.3, 1.8, 0.3)
	doodles.spawn_annotation(Vector2(680, 320), "MUST MAINTAIN... COMPOSURE.", 0.2, 1.5, 0.3)
	
	var tw := create_tween()
	tw.tween_interval(0.4)
	tw.tween_callback(func():
		ruffs.set_expression("excited") # Panting tongue peeks out!
	)
	tw.tween_interval(0.5)
	tw.tween_callback(func():
		ruffs.set_expression("disciplined") # Snaps back to military focus!
	)

func _step_test_f() -> void:
	# TEST F: Comedic Deadpan Hold
	doodles.clear_all()
	ruffs.set_expression("deadpan")
	ruffs.set_pose("parade_rest", 0.04) # Instant 0-motion snap
	doodles.spawn_annotation(Vector2(450, 240), "...YOU GOTTA BE KIDDING.", 0.2, 1.8, 0.3)

func _step_monochrome() -> void:
	doodles.clear_all()
	ruffs.set_art_mode(RuffsStyle.ArtMode.MONOCHROME)
	blaster.is_monochrome = true
	supply_drop.is_monochrome = true
	if mode_label:
		mode_label.text = "Art Mode: MONOCHROME INK-WASH"
	ruffs.set_expression("disciplined")
	ruffs.set_pose("salute")
