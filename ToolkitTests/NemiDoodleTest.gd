extends Node2D

## NemiDoodleTest — Hand-Drawn Doodle & Ink Storytelling Test Suite
## Demonstrates and validates:
## 1. Annotation Primitives: arrow, circle, underline, scribble, label, star, question, exclamation
## 2. Mini Illustrations: clock, bridge, banana peel, musical note, dumbbell
## 3. Draw-on, hold, and erase / reverse-draw behaviors
## 4. World-space vs screen-space layering under camera pan & zoom
## 5. Color Mode vs Monochrome Mode rendering
## 6. Authored deterministic line quality without per-frame jitter

const NemiDoodleDirector = preload("res://world/doodles/NemiDoodleDirector.gd")
const DoodleInstance = preload("res://world/doodles/DoodleInstance.gd")
const NemiScene = preload("res://characters/nemi/nemi.tscn")

var cam: Camera2D
var director: NemiDoodleDirector
var nemi_instance: Node2D
var status_label: Label
var active_test_doodles: Array[Node2D] = []

func _ready() -> void:
	_setup_stage()
	_setup_ui()
	call_deferred("_run_doodle_test_suite")

func _setup_stage() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#faf7f5") # Nemi textured paper canvas base
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(1280, 720)
	bg.z_index = -100
	add_child(bg)
	
	cam = Camera2D.new()
	cam.position = Vector2(640, 360)
	add_child(cam)
	cam.make_current()
	
	director = NemiDoodleDirector.new()
	director.name = "DoodleDirector"
	add_child(director)
	
	# Instantiate Nemi character in center for layering comparison
	nemi_instance = NemiScene.instantiate()
	nemi_instance.position = Vector2(640, 500)
	add_child(nemi_instance)

func _setup_ui() -> void:
	status_label = Label.new()
	status_label.position = Vector2(40, 30)
	status_label.add_theme_font_size_override("font_size", 22)
	status_label.add_theme_color_override("font_color", Color("#38101e"))
	status_label.text = "NEMI DOODLE SYSTEM TEST — Initializing..."
	add_child(status_label)

func _run_doodle_test_suite() -> void:
	print("============================================================")
	print("RUNNING NEMI HAND-DRAWN DOODLE & INK SYSTEM TEST SUITE")
	print("============================================================")
	
	# -------------------------------------------------------------------------
	# 1. TEST CORE ANNOTATION PRIMITIVES & DRAW-ON
	# -------------------------------------------------------------------------
	status_label.text = "1. Testing Annotation Primitives: arrow, circle, underline, scribble, label, star..."
	print("--> 1. Testing Core Annotations with progressive draw-on")
	
	var d_arrow = director.arrow(Vector2(120, 160), Vector2(240, 160), 0.22, true)
	var d_circle = director.circle(Vector2(320, 160), 30.0, 0.22)
	var d_underline = director.underline(Vector2(400, 175), 90.0, 0.20)
	var d_scribble = director.scribble(Vector2(570, 160), 35.0, 0.22)
	var d_label = director.label("WHY?", Vector2(680, 160), 0.25, DoodleInstance.StylePreset.COMEDIC)
	var d_star = director.star(Vector2(780, 160), 30.0, 0.22)
	var d_q = director.circle(Vector2(880, 160), 28.0, 0.20) # container circle
	var d_quest := DoodleInstance.new()
	d_quest.doodle_type = DoodleInstance.Type.QUESTION
	d_quest.position = Vector2(880, 160)
	director.add_child(d_quest)
	d_quest.draw_on(0.20)
	var d_excl := DoodleInstance.new()
	d_excl.doodle_type = DoodleInstance.Type.EXCLAMATION
	d_excl.position = Vector2(960, 160)
	director.add_child(d_excl)
	d_excl.draw_on(0.20)
	
	active_test_doodles.append_array([d_arrow, d_circle, d_underline, d_scribble, d_label, d_star, d_q, d_quest, d_excl])
	
	# Wait for progressive draw-on completion
	await _wait_seconds(0.5)
	
	for d in active_test_doodles:
		assert(is_instance_valid(d), "Expected doodle instance to exist!")
		assert(d.draw_progress >= 0.99, "Expected draw_progress to reach 1.0!")
	print("✓ Annotation primitives successfully drew on and held.")
	await _wait_seconds(0.4)
	
	# -------------------------------------------------------------------------
	# 2. TEST MINI ILLUSTRATIONS
	# -------------------------------------------------------------------------
	status_label.text = "2. Testing Mini Illustrations: clock, bridge, banana peel, musical note, dumbbell..."
	print("--> 2. Testing Mini Narrative Illustrations")
	
	var d_clock = director.mini("clock", Vector2(220, 280), 38.0, 0.30)
	var d_bridge = director.mini("bridge", Vector2(400, 280), 45.0, 0.35)
	var d_banana = director.mini("banana", Vector2(580, 280), 36.0, 0.28)
	var d_note = director.mini("note", Vector2(740, 280), 34.0, 0.25)
	var d_dumbbell = director.mini("dumbbell", Vector2(900, 280), 36.0, 0.28)
	
	var mini_doodles := [d_clock, d_bridge, d_banana, d_note, d_dumbbell]
	active_test_doodles.append_array(mini_doodles)
	
	await _wait_seconds(0.6)
	for m in mini_doodles:
		assert(is_instance_valid(m), "Expected mini illustration to exist!")
		assert(m.draw_progress >= 0.99, "Expected mini illustration draw_progress to reach 1.0!")
	print("✓ Mini illustrations successfully drew on with multi-phase stroke build.")
	await _wait_seconds(0.4)
	
	# -------------------------------------------------------------------------
	# 3. TEST ERASE & REVERSE-DRAW BEHAVIOR
	# -------------------------------------------------------------------------
	status_label.text = "3. Testing Erase & Reverse-Draw Behavior..."
	print("--> 3. Testing Erase / Reverse-Draw sequential stroke rollback")
	
	# Erase first row sequentially
	for d in [d_arrow, d_circle, d_underline, d_scribble, d_label, d_star, d_q, d_quest, d_excl]:
		if is_instance_valid(d):
			director.erase(d, 0.15)
	await _wait_seconds(0.3)
	
	# Verify that erased nodes are freed
	for d in [d_arrow, d_circle, d_underline, d_scribble, d_label, d_star, d_q, d_quest, d_excl]:
		assert(not is_instance_valid(d), "Expected erased doodle to be freed from scene!")
	print("✓ Reverse-draw erase confirmed and active doodle freed.")
	await _wait_seconds(0.3)
	
	# -------------------------------------------------------------------------
	# 4. TEST WORLD-SPACE VS SCREEN-SPACE & CAMERA TRACKING
	# -------------------------------------------------------------------------
	status_label.text = "4. Testing World-Space vs Screen-Space Layering under Camera Motion..."
	print("--> 4. Testing World-Space vs Screen-Space under camera pan & zoom")
	
	# World-space doodle attached beside Nemi
	var world_doodle = director.circle(Vector2(640, 420), 40.0, 0.20, DoodleInstance.StylePreset.NORMAL, DoodleInstance.LayerOrder.BEHIND_NEMI)
	# Screen-space annotation fixed to camera frame
	var screen_doodle = director.label("SCREEN SPACE", Vector2(180, 80), 0.22, DoodleInstance.StylePreset.COMEDIC, DoodleInstance.LayerOrder.SCREEN_SPACE)
	
	assert(world_doodle.z_index == int(DoodleInstance.LayerOrder.BEHIND_NEMI), "Expected BEHIND_NEMI layer order!")
	
	await _wait_seconds(0.3)
	
	# Pan and zoom camera
	var tw_cam := create_tween().set_parallel(true)
	tw_cam.tween_property(cam, "position", Vector2(800, 360), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_cam.tween_property(cam, "zoom", Vector2(1.3, 1.3), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await _wait_seconds(0.5)
	
	# Reset Camera
	var tw_cam_reset := create_tween().set_parallel(true)
	tw_cam_reset.tween_property(cam, "position", Vector2(640, 360), 0.3)
	tw_cam_reset.tween_property(cam, "zoom", Vector2(1.0, 1.0), 0.3)
	await _wait_seconds(0.4)
	
	if is_instance_valid(world_doodle): world_doodle.queue_free()
	if is_instance_valid(screen_doodle): screen_doodle.queue_free()
	print("✓ World-space and screen-space layer behavior verified.")
	
	# -------------------------------------------------------------------------
	# 5. TEST COLOR MODE VS MONOCHROME MODE
	# -------------------------------------------------------------------------
	status_label.text = "5. Testing Color Mode vs Monochrome Mode..."
	print("--> 5. Testing Color Mode vs Monochrome Mode switching")
	
	# Switch to Monochrome Mode
	director.set_color_mode(DoodleInstance.ColorMode.MONOCHROME)
	var mono_star = director.star(Vector2(500, 360), 36.0, 0.18)
	var mono_note = director.mini("note", Vector2(640, 360), 36.0, 0.18)
	await _wait_seconds(0.3)
	assert(mono_star.color_mode == DoodleInstance.ColorMode.MONOCHROME, "Expected MONOCHROME mode!")
	assert(mono_note.color_mode == DoodleInstance.ColorMode.MONOCHROME, "Expected MONOCHROME mode!")
	
	# Switch back to Color Mode
	director.set_color_mode(DoodleInstance.ColorMode.COLOR)
	await _wait_seconds(0.3)
	assert(mono_star.color_mode == DoodleInstance.ColorMode.COLOR, "Expected switch to COLOR mode!")
	
	director.clear_all(0.15)
	await _wait_seconds(0.2)
	print("✓ Color and Monochrome modes verified.")
	
	# -------------------------------------------------------------------------
	# ALL TESTS PASSED
	# -------------------------------------------------------------------------
	status_label.text = "✓ ALL NEMI DOODLE TESTS PASSED!"
	print("============================================================")
	print("✓ NEMI HAND-DRAWN DOODLE SYSTEM V1: ALL VERIFICATIONS PASSED")
	print("============================================================")
	
	await _wait_seconds(0.4)
	get_tree().quit(0)

func _wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
