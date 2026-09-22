class_name LeonShowcase
extends Node2D

## Dedicated Showcase & Directorial Test Suite for LEON (Brawl Stars)
## Demonstrates:
## - Full 14-expression vocabulary (Neutral through Con-Artist Persuasive & Screaming Panic)
## - Dynamic eye tracking, tooth smirk visemes, blinks, and chameleon tail wag
## - Con-artist sales pitching, frantic panic flailing, and fidget-spinner shurikens
## - TEST A: Shuriken Barrage with speed streak doodles
## - TEST B: Smoke Bomb Invisibility with puffy cloud and "POOF!" doodle
## - TEST C: Bush Camping with sketchy grass outline and hidden eyes
## - TEST D: Con-Artist Pitch with emphasis arrow and "FREE TROPHIES!" caption
## - TEST E: Full COLOR and MONOCHROME ink-wash storytelling mode switching

const LeonScript = preload("res://brawl_stars/characters/leon/Leon.gd")
const LeonStyle = preload("res://brawl_stars/characters/leon/LeonStyle.gd")
const LeonDoodleDirectorScript = preload("res://brawl_stars/scripts/LeonDoodleDirector.gd")

@onready var leon: Node2D = $Leon
@onready var doodles: Node2D = $DoodleDirector
@onready var status_label: Label = $CanvasLayer/UI/HeaderPanel/Margin/VBox/StatusLabel
@onready var step_label: Label = $CanvasLayer/UI/HeaderPanel/Margin/VBox/HBox/StepLabel
@onready var mode_label: Label = $CanvasLayer/UI/HeaderPanel/Margin/VBox/HBox/ModeLabel

var current_step_index: int = 0
var auto_play: bool = true
var step_duration: float = 1.3
var quit_on_finish: bool = false
var _step_timer: float = 0.0

var step_list: Array[Dictionary] = []

func _ready() -> void:
	var all_args := OS.get_cmdline_args()
	for arg in all_args:
		if arg.begins_with("--step-duration="):
			step_duration = arg.split("=")[1].to_float()
		elif arg == "--quit-on-finish":
			quit_on_finish = true
	
	_build_step_list()
	
	leon.position = Vector2(640, 420)
	execute_step(0)

func _process(delta: float) -> void:
	if not auto_play:
		return
	
	_step_timer += delta
	if _step_timer >= step_duration:
		_step_timer = 0.0
		current_step_index += 1
		if current_step_index >= step_list.size():
			if quit_on_finish:
				get_tree().quit(0)
			else:
				current_step_index = 0
		execute_step(current_step_index)

func _build_step_list() -> void:
	step_list = [
		{"name": "01. Neutral (Mischievous Smirk Baseline)"},
		{"name": "02. Curious (Inquisitive Head Cock)"},
		{"name": "03. Analytical (Calculated Angle)"},
		{"name": "04. Happy (Cheeky Tooth Grin)"},
		{"name": "05. Excited (Con-Artist Hype)"},
		{"name": "06. Confused (Baffled Disbelief)"},
		{"name": "07. Surprised (Wide Sclera Pop)"},
		{"name": "08. Shocked (Sweat Drop & Recoil)"},
		{"name": "09. Annoyed (Anger Cross & Displeasure)"},
		{"name": "10. Worried (Nervous Justification)"},
		{"name": "11. Smug (Cocky Eye Slant)"},
		{"name": "12. Deadpan (Flat Unbothered Slits)"},
		{"name": "13. Screaming Panic (Jaw Unhinged Shout)"},
		{"name": "14. Con-Artist Persuasive Pitch"},
		{"name": "15. Pose: Stealth Crouch"},
		{"name": "16. Pose: Fidget Spinner Shurikens"},
		{"name": "17. Gaze Tracking & Double Blink"},
		{"name": "18. Dialogue Syllable Visemes"},
		{"name": "19. TEST A: Shuriken Barrage Doodle"},
		{"name": "20. TEST B: Smoke Bomb Invisibility Doodle"},
		{"name": "21. TEST C: Bush Camping Doodle"},
		{"name": "22. TEST D: Con-Artist Pitch Arrow Doodle"},
		{"name": "23. TEST E: Monochrome Storytelling Mode"},
		{"name": "24. Return to Full Color Mode"}
	]

func execute_step(index: int) -> void:
	if index < 0 or index >= step_list.size():
		return
	var item: Dictionary = step_list[index]
	if status_label:
		status_label.text = item.get("name", "")
	if step_label:
		step_label.text = "Step %d / %d" % [index + 1, step_list.size()]
	
	match index:
		0:
			leon.set_expression("neutral")
			leon.set_pose("idle")
		1:
			leon.set_expression("curious")
			leon.set_gaze(Vector2(0.6, -0.3))
		2:
			leon.set_expression("analytical")
			leon.set_gaze(Vector2(0.4, 0.4))
		3:
			leon.set_expression("happy")
		4:
			leon.set_expression("excited")
			leon.set_pose("proud_smug")
		5:
			leon.set_expression("confused")
			leon.set_gaze(Vector2(-0.5, 0.2))
		6:
			leon.set_expression("surprised")
			leon.blink()
		7:
			leon.set_expression("shocked")
		8:
			leon.set_expression("annoyed")
			leon.set_pose("proud_smug")
		9:
			leon.set_expression("worried")
		10:
			leon.set_expression("smug")
			leon.set_pose("proud_smug")
		11:
			leon.set_expression("deadpan")
			leon.set_pose("deadpan_freeze")
		12:
			leon.set_expression("screaming_panic")
			leon.set_pose("panic_flail")
		13:
			leon.set_expression("con_artist_persuasive")
			leon.set_pose("con_artist_pitch")
		14:
			leon.set_expression("analytical")
			leon.set_pose("stealth_crouch")
			leon.set_gaze(Vector2(0.5, 0.1))
		15:
			leon.set_expression("smug")
			leon.set_pose("holding_shurikens")
		16:
			leon.set_expression("neutral")
			leon.set_pose("idle")
			leon.look_at_point(Vector2(1000, 200))
			leon.double_blink()
		17:
			leon.set_expression("con_artist_persuasive")
			leon.talk_syllable("talk_open", 0.4)
		18:
			leon.set_expression("excited")
			leon.set_pose("holding_shurikens")
			doodles.doodle_shuriken_barrage(Vector2(700, 420), Vector2(1050, 380), 2.0)
		19:
			leon.set_expression("smug")
			leon.set_pose("idle")
			doodles.doodle_smoke_bomb(Vector2(640, 420), 2.2)
		20:
			leon.set_expression("stealth_crouch")
			leon.set_pose("stealth_crouch")
			doodles.doodle_bush(Vector2(420, 460), 2.2)
		21:
			leon.set_expression("con_artist_persuasive")
			leon.set_pose("con_artist_pitch")
			doodles.doodle_con_artist_arrow(Vector2(850, 350), Vector2(720, 420), "FREE TROPHIES!", 2.2)
		22:
			leon.toggle_art_mode()
			leon.set_expression("deadpan")
			leon.set_pose("deadpan_freeze")
		23:
			leon.toggle_art_mode()
			leon.set_expression("happy")
			leon.set_pose("idle")
