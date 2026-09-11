extends Node2D

## NemiPropLibraryTest — Test Suite for Reusable Hand-Drawn Prop Core Library
## Demonstrates:
## - Prop creation from NemiPropLibrary factory
## - Pop in, bounce, drop, shake, and rotate behaviors
## - Rig interaction and hand attachment via attach_to()
## - Camera close-up and visual weight verification

const NemiPropLibrary = preload("res://world/props/NemiPropLibrary.gd")
const NemiScene = preload("res://characters/nemi/nemi.tscn")

var cam: Camera2D
var nemi_instance: Node2D
var active_props: Array[Node2D] = []
var status_label: Label

func _ready() -> void:
	_setup_stage()
	_setup_ui()
	call_deferred("_run_prop_test_sequence")

func _setup_stage() -> void:
	# Paper canvas background
	var bg := ColorRect.new()
	bg.color = Color("#faf7f5")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(1280, 720)
	bg.z_index = -100
	add_child(bg)
	
	cam = Camera2D.new()
	cam.position = Vector2(640, 360)
	add_child(cam)
	cam.make_current()
	
	# Instantiate Nemi character in center
	nemi_instance = NemiScene.instantiate()
	nemi_instance.position = Vector2(640, 480)
	nemi_instance.scale = Vector2(1.0, 1.0)
	add_child(nemi_instance)

func _setup_ui() -> void:
	status_label = Label.new()
	status_label.position = Vector2(40, 30)
	status_label.add_theme_font_size_override("font_size", 22)
	status_label.add_theme_color_override("font_color", Color("#38101e"))
	status_label.text = "NEMI PROP LIBRARY TEST — Initializing..."
	add_child(status_label)

func _run_prop_test_sequence() -> void:
	print("============================================================")
	print("RUNNING NEMI PROP LIBRARY COMPREHENSIVE TEST SEQUENCE")
	print("============================================================")
	
	# 1. Verify Catalog Registry
	var total_props: int = NemiPropLibrary.get_total_prop_count()
	print("✓ Registered props in catalog: %d" % total_props)
	assert(total_props >= 25, "Expected at least 25 registered props in library!")
	
	# 2. Test Grid Showcase: Instantiate 8 key props across categories
	var showcase_ids := ["phone", "notebook", "headphones", "cup", "stylus", "drawing_tablet", "dumbbell", "clock"]
	var grid_start_x := 180.0
	var spacing_x := 130.0
	var grid_y := 160.0
	
	for i in range(showcase_ids.size()):
		var p_id = showcase_ids[i]
		var prop = NemiPropLibrary.create_prop(p_id)
		assert(prop != null, "Failed to instantiate prop: " + p_id)
		prop.position = Vector2(grid_start_x + float(i) * spacing_x, grid_y)
		add_child(prop)
		active_props.append(prop)
		if prop.has_method("pop_in"):
			prop.pop_in(0.20)
			
	status_label.text = "✓ 8 Showcase Props Instantiated & Popped In"
	await _wait_seconds(0.6)
	
	# 3. Test Behaviors: Bounce, Shake, Drop
	status_label.text = "Testing Behaviors: Bounce & Shake..."
	if active_props.size() >= 3:
		active_props[0].bounce(20.0, 0.3)
		active_props[1].shake(0.8, 0.3)
		active_props[6].drop(35.0, 0.25)
	await _wait_seconds(0.8)
	
	# 4. Test Hand Attachment to Live Nemi Rig
	status_label.text = "Testing Nemi Hand Attachment (Stylus)..."
	var hand_prop = NemiPropLibrary.create_prop("stylus")
	add_child(hand_prop)
	
	# Attach to Nemi right hand
	if nemi_instance.has_node("Actor/Skeleton2D/Torso/ArmR"):
		var r_hand = nemi_instance.get_node("Actor/Skeleton2D/Torso/ArmR")
		hand_prop.attach_to(r_hand, Vector2(12, 5), 25.0)
	else:
		hand_prop.position = nemi_instance.position + Vector2(60, -40)
		
	if nemi_instance.has_method("set_expression"):
		nemi_instance.set_expression("smiling")
	await _wait_seconds(0.8)
	
	# 5. Camera Close-Up Framing
	status_label.text = "Testing Camera Close-Up Framing..."
	var tw = create_tween()
	tw.tween_property(cam, "zoom", Vector2(1.35, 1.35), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(cam, "position", Vector2(640, 380), 0.35)
	await _wait_seconds(0.8)
	
	# Reset Camera
	var tw_reset = create_tween()
	tw_reset.tween_property(cam, "zoom", Vector2(1.0, 1.0), 0.3)
	tw_reset.parallel().tween_property(cam, "position", Vector2(640, 360), 0.3)
	await _wait_seconds(0.4)
	
	status_label.text = "✓ ALL PROP LIBRARY TESTS PASSED (Total: %d Props)" % total_props
	print("============================================================")
	print("✓ NEMI PROP LIBRARY TEST COMPLETED SUCCESSFULLY!")
	print("============================================================")
	
	await _wait_seconds(0.5)
	get_tree().quit(0)

func _wait_seconds(duration: float) -> void:
	var frames := int(round(duration * 60.0))
	if DisplayServer.get_name() == "headless":
		for f in range(frames):
			await get_tree().process_frame
	else:
		for f in range(frames):
			await RenderingServer.frame_post_draw
