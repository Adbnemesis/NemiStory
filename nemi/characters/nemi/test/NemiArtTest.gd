extends Node2D

## Character Art & Proportion Evaluation Test Harness for NEMI
## Verifies:
## 1. Soft, youthful curved face (Head width 94, Cheeks 92, Rounded chin)
## 2. Vertical cascading hair silhouette (Max width 118, NOT bulging wide)
## 3. Hand-drawn illustrated line aesthetics (Curve2D Bézier splines)
## 4. Toggleable Proportion Debug Overlay proving anatomical ratios
## 5. Dual Color & Finished Monochrome modes on identical geometry
## 6. Live Skeleton2D / Bone2D rig posing

@onready var nemi: Node2D = $Nemi
@onready var overlay: Node2D = $ProportionOverlay
@onready var status_label: Label = $CanvasLayer/UI/StatusLabel
@onready var mode_label: Label = $CanvasLayer/UI/ModeLabel
@onready var overlay_label: Label = $CanvasLayer/UI/OverlayLabel

var show_overlay: bool = false:
	set(val):
		show_overlay = val
		if overlay:
			overlay.visible = show_overlay
		_update_ui()

enum TestView {
	FULL_BODY_IDLE,
	STORYTIME_BUST,
	FACE_CLOSEUP,
	NOVEL_RIG_POSE
}

var current_view: TestView = TestView.FULL_BODY_IDLE

func _ready() -> void:
	if nemi:
		nemi.position = Vector2(640, 440)
		nemi.scale = Vector2(1.0, 1.0)
		nemi.set_pose("idle", 0.0)
		nemi.set_expression("neutral")
	
	if overlay:
		overlay.visible = show_overlay
	
	_apply_view(TestView.FULL_BODY_IDLE)

func _apply_view(view: TestView) -> void:
	current_view = view
	match view:
		TestView.FULL_BODY_IDLE:
			nemi.position = Vector2(640, 440)
			nemi.scale = Vector2(1.0, 1.0)
			nemi.set_pose("idle", 0.15)
			nemi.set_expression("neutral")
			nemi.look_at_direction(Vector2.ZERO)
		
		TestView.STORYTIME_BUST:
			nemi.position = Vector2(640, 590)
			nemi.scale = Vector2(1.8, 1.8)
			nemi.set_pose("casual_standing", 0.15)
			nemi.set_expression("happy")
			nemi.look_at_direction(Vector2(0.4, -0.1))
		
		TestView.FACE_CLOSEUP:
			nemi.position = Vector2(640, 770)
			nemi.scale = Vector2(2.8, 2.8)
			nemi.set_pose("idle", 0.15)
			nemi.set_expression("neutral")
			nemi.look_at_direction(Vector2.ZERO)
		
		TestView.NOVEL_RIG_POSE:
			nemi.position = Vector2(640, 440)
			nemi.scale = Vector2(1.0, 1.0)
			nemi.set_pose("novel_pose", 0.2)
			nemi.look_at_direction(Vector2(0.6, -0.2))
	
	if overlay:
		overlay.queue_redraw()
	_update_ui()

func _update_ui() -> void:
	if status_label:
		match current_view:
			TestView.FULL_BODY_IDLE:
				status_label.text = "View: Full Body Idle (Feet planted on floor at y = 640)"
			TestView.STORYTIME_BUST:
				status_label.text = "View: Storytime Medium Bust Shot (Waist-up framing)"
			TestView.FACE_CLOSEUP:
				status_label.text = "View: Face Extreme Close-Up (Procedural lash wings & double highlights)"
			TestView.NOVEL_RIG_POSE:
				status_label.text = "View: Novel Rig-Generated Pose (Demonstrating live skeletal articulation)"
	
	if mode_label and nemi:
		mode_label.text = "Mode: " + nemi.get_art_mode_name()
	
	if overlay_label:
		overlay_label.text = "Proportion Overlay: " + ("ON [Press O to toggle]" if show_overlay else "OFF [Press O to toggle]")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_apply_view(TestView.FULL_BODY_IDLE)
			KEY_2:
				_apply_view(TestView.STORYTIME_BUST)
			KEY_3:
				_apply_view(TestView.FACE_CLOSEUP)
			KEY_4:
				_apply_view(TestView.NOVEL_RIG_POSE)
			KEY_O:
				show_overlay = not show_overlay
			KEY_M, KEY_C:
				if nemi:
					nemi.toggle_art_mode()
					_update_ui()
			KEY_SPACE:
				if nemi:
					nemi.blink()
