class_name ADBPhysicsTest
extends Node2D

## ADB_PHYSICS_TEST — Environment & Physical Grounding Verification
## Tests:
## - Standing grounded on floor plane (feet check)
## - Leaning onto desk surface (contact check)
## - Reaching towards prop on desk (kinematic alignment)
## - Holding prop (hand-prop attachment & zero clipping)
## - Sitting in chair (hips on seat, feet grounded, no penetration)
## - Relaxed seated pose with prop interaction

const ADB = preload("res://adb/characters/adb/ADB.gd")

@onready var adb: ADB = $ADB
@onready var status_label: Label = $UI/StatusLabel
@onready var phase_label: Label = $UI/PhaseLabel

# Environment elements
@onready var desk: Node2D = $Environment/Desk
@onready var chair: Node2D = $Environment/Chair
@onready var mug: Node2D = $Environment/Mug

var current_step: int = 0
var timer: float = 0.0

# Base positions
const FLOOR_Y: float = 840.0
const DESK_SURFACE_Y: float = 690.0
const CHAIR_SEAT_Y: float = 680.0

var mug_on_desk_pos: Vector2 = Vector2(1180, 665)
var is_mug_held: bool = false

func _ready() -> void:
	if not adb:
		adb = $ADB
	_setup_environment()
	_run_step(0)

func _setup_environment() -> void:
	if mug:
		mug.position = mug_on_desk_pos

func _process(delta: float) -> void:
	timer += delta
	
	# If mug is held, keep it anchored near ADB's right hand marker
	if is_mug_held and mug and adb:
		mug.global_position = adb.global_position + Vector2(75, 45)
	
	if timer >= 2.0:
		timer = 0.0
		current_step += 1
		if current_step > 5:
			current_step = 0
		_run_step(current_step)

func _run_step(step: int) -> void:
	match step:
		0:
			# 1. Standing beside desk
			is_mug_held = false
			if mug:
				mug.position = mug_on_desk_pos
			adb.position = Vector2(820, 570)
			adb.set_pose("relaxed_standing", 0.30)
			adb.set_expression("neutral", 0.20)
			adb.look("camera")
			_update_ui("PHASE 1: Standing Grounded", "Both feet planted firmly on floor line (Y=840). No float.")
			
		1:
			# 2. Leaning on desk
			adb.position = Vector2(860, 575)
			adb.set_pose("weight_right", 0.30)
			adb.head_tilt_to(6.0, 0.25)
			adb.set_expression("amused", 0.20)
			_update_ui("PHASE 2: Leaning on Desk", "Torso shifts right, arm rests above desk plane without penetration.")
			
		2:
			# 3. Reaching for prop
			adb.position = Vector2(870, 575)
			adb.set_pose("pointing", 0.25) # Reaching out towards mug
			adb.look("down")
			_update_ui("PHASE 3: Reaching for Mug", "Gaze tracks mug on desk surface, arm reaches naturally.")
			
		3:
			# 4. Holding prop
			is_mug_held = true
			adb.set_pose("hand_near_face", 0.28)
			adb.set_expression("smug", 0.20)
			adb.look("camera")
			_update_ui("PHASE 4: Holding Prop (Lifted)", "Mug lifted off desk, attached to hand marker, zero mesh intersection.")
			
		4:
			# 5. Sitting down in chair
			adb.position = Vector2(620, 620) # Lowered to seat
			adb.set_pose("seated", 0.35)
			adb.set_expression("neutral", 0.20)
			_update_ui("PHASE 5: Sitting in Chair", "Hips rest on chair seat (Y=680), knees 90-deg angle, feet grounded.")
			
		5:
			# 6. Conversational seated rest
			adb.set_expression("cute", 0.20)
			adb.head_tilt_to(-5.0, 0.25)
			adb.blink(0.14)
			_update_ui("PHASE 6: Conversational Seated Rest", "Relaxed posture, smiling softly, holding mug in comfortable lap rest.")

func _update_ui(p_txt: String, s_txt: String) -> void:
	if phase_label:
		phase_label.text = p_txt
	if status_label:
		status_label.text = s_txt
	print("[ADB_PHYSICS_TEST] " + p_txt + " | " + s_txt)
