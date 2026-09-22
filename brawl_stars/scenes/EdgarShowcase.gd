class_name EdgarShowcase
extends Node2D

## Dedicated Showcase & Directorial Test Suite for EDGAR (Brawl Stars)
## Demonstrates:
## - Full 14-expression vocabulary (Deadpan, Emo Despair, Shock, Toxic Smug, Explosive Shout)
## - Blank white emo eyes, heavy winged eyeliner, fatigue bags, and mouth visemes
## - Living sentient striped scarf actions (fists crossed, punch ready, toxic thumbs-down)
## - TEST A: Giant Scarf Punch with action lines & "WHAM!" doodle
## - TEST B: Toxic Thumbs Down badge with salt sprinkles doodle
## - TEST C: Super Jump Trajectory arc into disaster landing doodle
## - TEST D: Emo Stormcloud with rain drizzle doodle
## - TEST E: Full COLOR and MONOCHROME ink-wash storytelling mode switching

const EdgarScript = preload("res://brawl_stars/characters/edgar/Edgar.gd")
const EdgarStyle = preload("res://brawl_stars/characters/edgar/EdgarStyle.gd")
const EdgarDoodleDirectorScript = preload("res://brawl_stars/scripts/EdgarDoodleDirector.gd")

@onready var edgar: Node2D = $Edgar
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
	
	edgar.position = Vector2(640, 420)
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
		{"name": "01. Deadpan (Unbothered Flat Stare Baseline)"},
		{"name": "02. Curious (Skeptical Brow Cock)"},
		{"name": "03. Analytical (Calculated Cynicism)"},
		{"name": "04. Happy (Subtle Sarcastic Smirk)"},
		{"name": "05. Excited (Cynical Amusement)"},
		{"name": "06. Confused (Disbelieving Brow)"},
		{"name": "07. Surprised (Blank Eyes Widen)"},
		{"name": "08. Shocked (Tiny Pinprick Pupils & Sweat)"},
		{"name": "09. Annoyed (Anger Cross & Brow Furrow)"},
		{"name": "10. Worried (Sweat Drop & Frown)"},
		{"name": "11. Toxic Smug (Half-Lidded Mocking Gaze)"},
		{"name": "12. Explosive Shout ('WHY WOULD YOU DO THAT?!')"},
		{"name": "13. Emo Despair (Vertical Raincloud Gloom)"},
		{"name": "14. Pose: Phone Scroll (Ignoring Teammate)"},
		{"name": "15. Pose: Scarf Fists Punch Ready"},
		{"name": "16. Gaze Tracking & Double Blink"},
		{"name": "17. Dialogue Syllable Visemes"},
		{"name": "18. TEST A: Scarf Punch 'WHAM!' Doodle"},
		{"name": "19. TEST B: Toxic Thumbs Down Doodle"},
		{"name": "20. TEST C: Super Jump Trajectory Doodle"},
		{"name": "21. TEST D: Emo Stormcloud Doodle"},
		{"name": "22. TEST E: Monochrome Storytelling Mode"},
		{"name": "23. Return to Full Color Mode"}
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
			edgar.set_expression("deadpan")
			edgar.set_pose("idle_slouch")
		1:
			edgar.set_expression("curious")
			edgar.set_gaze(Vector2(0.5, -0.2))
		2:
			edgar.set_expression("analytical")
			edgar.set_gaze(Vector2(0.3, 0.2))
		3:
			edgar.set_expression("happy")
		4:
			edgar.set_expression("excited")
			edgar.set_pose("arms_crossed")
		5:
			edgar.set_expression("confused")
			edgar.set_gaze(Vector2(-0.4, 0.2))
		6:
			edgar.set_expression("surprised")
			edgar.blink()
		7:
			edgar.set_expression("shocked")
		8:
			edgar.set_expression("annoyed")
			edgar.set_pose("arms_crossed")
		9:
			edgar.set_expression("worried")
		10:
			edgar.set_expression("toxic_smug")
			edgar.set_pose("toxic_thumbs_down")
		11:
			edgar.set_expression("explosive_shout")
			edgar.set_pose("shrug")
		12:
			edgar.set_expression("emo_despair")
			edgar.set_pose("idle_slouch")
		13:
			edgar.set_expression("deadpan")
			edgar.set_pose("phone_scroll")
		14:
			edgar.set_expression("annoyed")
			edgar.set_pose("punch_ready")
		15:
			edgar.set_expression("neutral")
			edgar.set_pose("idle_slouch")
			edgar.look_at_point(Vector2(200, 200))
			edgar.double_blink()
		16:
			edgar.set_expression("deadpan")
			edgar.talk_syllable("talk_open", 0.4)
		17:
			edgar.set_expression("annoyed")
			edgar.set_pose("punch_ready")
			doodles.doodle_scarf_punch(Vector2(600, 380), Vector2(300, 360), 2.0)
		18:
			edgar.set_expression("toxic_smug")
			edgar.set_pose("toxic_thumbs_down")
			doodles.doodle_toxic_thumbs_down(Vector2(780, 380), 2.2)
		19:
			edgar.set_expression("deadpan")
			edgar.set_pose("idle_slouch")
			doodles.doodle_jump_arc(Vector2(640, 420), Vector2(850, 240), Vector2(1050, 420), 2.4)
		20:
			edgar.set_expression("emo_despair")
			edgar.set_pose("idle_slouch")
			doodles.doodle_emo_stormcloud(Vector2(640, 290), 2.4)
		21:
			edgar.toggle_art_mode()
			edgar.set_expression("deadpan")
			edgar.set_pose("deadpan_freeze")
		22:
			edgar.toggle_art_mode()
			edgar.set_expression("happy")
			edgar.set_pose("arms_crossed")
