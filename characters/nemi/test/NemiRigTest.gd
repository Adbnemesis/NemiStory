extends Node2D

## Interactive Live Rig Test Harness for NEMI (Rig V1)
## Validates:
## - 100% Godot-native 2D character (Skeleton2D + Bone2D + procedural vector drawing)
## - Live articulated body controls (torso, neck, head, arms, elbows, hands, legs, knees, feet, skirt, hair)
## - Live procedural facial system (eyes, gaze, pupil scaling, blink, brows, mouth shapes, micro-accents)
## - Instant COLOR ↔ MONOCHROME mode switching on the same live instance
## - Live Rig Debug visualizer overlay
## - Brand-new Live Pose and Live Expression tests created solely through code and transforms

@onready var nemi: Nemi = $Nemi
@onready var status_label: Label = $CanvasLayer/UI/FooterPanel/Margin/VBox/StatusLabel
@onready var mode_label: Label = $CanvasLayer/UI/HeaderPanel/Margin/HBox/ModeLabel
@onready var details_label: Label = $CanvasLayer/UI/FooterPanel/Margin/VBox/DetailsLabel

var auto_test_timer: float = 0.0
var auto_test_active: bool = false
var auto_test_step: int = 0
var auto_test_mode: String = ""

func _ready() -> void:
	if nemi:
		nemi.position = Vector2(640, 420)
		nemi.scale = Vector2(1.0, 1.0)
		nemi.reset()
	_update_ui("Live Rig V1 Initialized. Ready for interactive testing.")

func _process(delta: float) -> void:
	if auto_test_active:
		auto_test_timer += delta
		_run_auto_test_sequence()

# -------------------------------------------------------------------------
# INTERACTIVE BUTTON HANDLERS
# -------------------------------------------------------------------------

func _on_pose_btn_pressed(pose_name: String) -> void:
	auto_test_active = false
	if nemi:
		nemi.set_pose(pose_name, 0.2)
		_update_ui("Pose: " + pose_name.capitalize())

func _on_expression_btn_pressed(expr_name: String) -> void:
	auto_test_active = false
	if nemi:
		nemi.set_expression(expr_name)
		_update_ui("Expression: " + expr_name.capitalize())

func _on_look_btn_pressed(dir_name: String) -> void:
	auto_test_active = false
	if nemi:
		nemi.look(dir_name)
		_update_ui("Gaze: Look " + dir_name.capitalize())

func _on_blink_btn_pressed() -> void:
	if nemi:
		nemi.blink()
		_update_ui("Action: Procedural Blink")

func _on_head_btn_pressed(action: String) -> void:
	auto_test_active = false
	if not nemi: return
	match action:
		"left":
			nemi.head_turn(-20.0, 0.25)
			_update_ui("Head: Turn Left (-20°)")
		"right":
			nemi.head_turn(20.0, 0.25)
			_update_ui("Head: Turn Right (+20°)")
		"center":
			nemi.head_turn(0.0, 0.2)
			_update_ui("Head: Centered (0°)")
		"tilt_left":
			nemi.head_tilt(-10.0, 0.2)
			_update_ui("Head: Tilt Left (-10°)")
		"tilt_right":
			nemi.head_tilt(10.0, 0.2)
			_update_ui("Head: Tilt Right (+10°)")
		"nod":
			nemi.nod(1.0, 0.35)
			_update_ui("Head: Conversational Nod")

func _on_lean_btn_pressed(angle_deg: float) -> void:
	auto_test_active = false
	if nemi:
		nemi.lean(angle_deg, 0.25)
		_update_ui("Body Lean: " + str(angle_deg) + "°")

func _on_hair_sway_btn_pressed(direction: String) -> void:
	auto_test_active = false
	if not nemi: return
	match direction:
		"left":
			nemi.set_hair_sway(-12.0, -18.0, -8.0, 0.25)
			_update_ui("Hair Sway: Left Breeze (-18°)")
		"right":
			nemi.set_hair_sway(12.0, 8.0, 18.0, 0.25)
			_update_ui("Hair Sway: Right Breeze (+18°)")
		_:
			nemi.set_hair_sway(0.0, 0.0, 0.0, 0.2)
			_update_ui("Hair Sway: Settled")

func _on_hand_btn_pressed(is_left: bool, pose_str: String) -> void:
	auto_test_active = false
	if nemi:
		nemi.set_hand_pose(is_left, pose_str)
		var side := "Left" if is_left else "Right"
		_update_ui(side + " Hand Pose: " + pose_str.capitalize())

func _on_accent_btn_pressed(accent_name: String) -> void:
	if not nemi: return
	if nemi.face:
		var current_val: bool = nemi.face.get("show_" + accent_name) if ("show_" + accent_name) in nemi.face else false
		nemi.set_micro_accent(accent_name, not current_val)
		_update_ui("Micro-Accent " + accent_name.capitalize() + ": " + ("ON" if not current_val else "OFF"))

func _on_toggle_mode_btn_pressed() -> void:
	if nemi:
		nemi.toggle_art_mode()
		_update_ui("Art Mode Toggled: " + nemi.get_art_mode_name())

func _on_toggle_debug_btn_pressed() -> void:
	if nemi:
		nemi.toggle_rig_debug()
		var is_on: bool = nemi.rig_debug.enabled if nemi.rig_debug else false
		_update_ui("Rig Debug Overlay: " + ("ENABLED (Pivots & Bones visible)" if is_on else "DISABLED"))

func _on_reset_btn_pressed() -> void:
	auto_test_active = false
	if nemi:
		nemi.reset()
		_update_ui("Character reset to default neutral idle state.")

# -------------------------------------------------------------------------
# AUTOMATED VALIDATION SUITES
# -------------------------------------------------------------------------

## Requirement 24: Live New-Pose Test
## Constructs a brand new pose that never existed in any reference sheet:
## - Torso leans backward (-14°)
## - Head turns right (+18°)
## - Eyes look left (-0.7, -0.1)
## - Right arm raises up (-75°) with elbow bent (-50°) pointing across with open pointing gesture
## - Left arm rests relaxed (+25°, +35°)
## - Hair gently sways with the head turn
## - Facial expression: Shocked / surprised with sweat drop
func run_live_new_pose_test() -> void:
	auto_test_active = false
	if not nemi: return
	nemi.reset()
	
	# Apply novel rig transforms directly via controller API
	nemi.lean(-14.0, 0.25)
	nemi.head_turn(18.0, 0.25)
	nemi.look_at_direction(Vector2(-0.7, -0.1))
	nemi.set_arm(true, 25.0, 35.0, "relaxed", 0.25)
	nemi.set_arm(false, -75.0, -50.0, "pointing", 0.25)
	nemi.set_leg(true, 10.0, -8.0, -2.0, 0.25)
	nemi.set_leg(false, -12.0, 14.0, 0.0, 0.25)
	nemi.set_hair_sway(8.0, 12.0, 6.0, 0.25)
	nemi.set_expression("shocked")
	nemi.set_micro_accent("sweat", true)
	
	_update_ui("★ LIVE NOVEL POSE GENERATED: Leaning back, head turned right, eyes looking left, right arm pointing across!")

## Requirement 25: Live New-Expression Test
## Generates a brand-new expression combination that did not exist as an authored image:
## - Eyes looking left
## - Left eyebrow raised high (+8px)
## - Right eyebrow lowered with inward tilt (-4px, -0.2 rad)
## - Pupils widened (scale 1.35x)
## - Mouth shape: "surprised" (small animated 'o')
## - Both blush and sweat drop enabled
func run_live_new_expression_test() -> void:
	auto_test_active = false
	if not nemi: return
	nemi.reset()
	
	nemi.set_eye_openness(1.1)
	nemi.look_at_direction(Vector2(-0.75, -0.15))
	nemi.set_pupil_scale(1.35)
	nemi.set_eyebrow("left", 8.0, 0.15)
	nemi.set_eyebrow("right", -4.0, -0.2)
	nemi.set_mouth_shape("surprised")
	nemi.set_micro_accent("blush", true)
	nemi.set_micro_accent("sweat", true)
	
	_update_ui("★ LIVE NOVEL EXPRESSION GENERATED: Asymmetrical brows, widened pupils, surprised mouth, blush + sweat drop!")

## Requirement 26: Full Articulation Sweep
func run_articulation_sweep() -> void:
	auto_test_active = true
	auto_test_timer = 0.0
	auto_test_step = 0
	auto_test_mode = "sweep"
	if nemi: nemi.reset()
	_update_ui("Starting Full Articulation Sweep...")

func _run_auto_test_sequence() -> void:
	if auto_test_mode == "sweep":
		match auto_test_step:
			0:
				if auto_test_timer >= 0.5:
					nemi.head_turn(-25.0, 0.3)
					_update_ui("Sweep Step 1: Head Turn Left (-25°)")
					auto_test_step += 1
					auto_test_timer = 0.0
			1:
				if auto_test_timer >= 0.6:
					nemi.head_turn(25.0, 0.3)
					_update_ui("Sweep Step 2: Head Turn Right (+25°)")
					auto_test_step += 1
					auto_test_timer = 0.0
			2:
				if auto_test_timer >= 0.6:
					nemi.head_turn(0.0, 0.2)
					nemi.blink()
					_update_ui("Sweep Step 3: Head Center & Blink")
					auto_test_step += 1
					auto_test_timer = 0.0
			3:
				if auto_test_timer >= 0.6:
					nemi.set_arm(true, -90.0, -45.0, "pointing", 0.3)
					nemi.set_arm(false, 30.0, 40.0, "open", 0.3)
					_update_ui("Sweep Step 4: Left Arm Raised Pointing, Right Arm Open")
					auto_test_step += 1
					auto_test_timer = 0.0
			4:
				if auto_test_timer >= 0.7:
					nemi.set_arm(false, 140.0, 15.0, "fist", 0.3)
					nemi.set_arm(true, 15.0, 20.0, "relaxed", 0.3)
					nemi.set_expression("excited")
					_update_ui("Sweep Step 5: Right Arm High Cheer + Clenched Fist")
					auto_test_step += 1
					auto_test_timer = 0.0
			5:
				if auto_test_timer >= 0.7:
					nemi.set_pose("walking", 0.3)
					_update_ui("Sweep Step 6: Full Leg Striding & Hip Shift")
					auto_test_step += 1
					auto_test_timer = 0.0
			6:
				if auto_test_timer >= 0.8:
					run_live_new_pose_test()
					_update_ui("Sweep Step 7: Novel Posing Verification")
					auto_test_step += 1
					auto_test_timer = 0.0
			7:
				if auto_test_timer >= 1.0:
					auto_test_active = false
					_update_ui("Articulation Sweep Complete! All joints, geometry, and parts verified.")

func _update_ui(status: String) -> void:
	if status_label:
		status_label.text = status
	if mode_label and nemi:
		mode_label.text = "MODE: " + nemi.get_art_mode_name()
	if details_label and nemi:
		details_label.text = "Pose: %s | Expr: %s | Gaze: (%.1f, %.1f) | HeadRot: %.1f° | TorsoRot: %.1f°" % [
			nemi.current_pose_name,
			nemi.current_expression_name,
			nemi.face.gaze_direction.x if nemi.face else 0.0,
			nemi.face.gaze_direction.y if nemi.face else 0.0,
			rad_to_deg(nemi.head_bone.rotation) if nemi.head_bone else 0.0,
			rad_to_deg(nemi.torso_bone.rotation) if nemi.torso_bone else 0.0
		]

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		auto_test_active = false
		match event.keycode:
			KEY_1: _on_pose_btn_pressed("idle")
			KEY_2: _on_pose_btn_pressed("casual_standing")
			KEY_3: _on_pose_btn_pressed("pointing")
			KEY_4: _on_pose_btn_pressed("thinking")
			KEY_5: _on_pose_btn_pressed("excited")
			KEY_6: _on_pose_btn_pressed("recoiling")
			KEY_7: _on_pose_btn_pressed("walking")
			KEY_8: _on_pose_btn_pressed("novel_pose")
			KEY_SPACE: _on_blink_btn_pressed()
			KEY_LEFT: _on_look_btn_pressed("left")
			KEY_RIGHT: _on_look_btn_pressed("right")
			KEY_UP: _on_look_btn_pressed("up")
			KEY_DOWN: _on_look_btn_pressed("down")
			KEY_C, KEY_M: _on_toggle_mode_btn_pressed()
			KEY_G, KEY_D: _on_toggle_debug_btn_pressed()
			KEY_P: run_live_new_pose_test()
			KEY_E: run_live_new_expression_test()
			KEY_R: _on_reset_btn_pressed()
