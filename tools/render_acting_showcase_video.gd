extends SceneTree

## Dedicated Video Production Script for NEMI Acting & Animation Language V1
## Renders a complete 1280x720 30FPS master video demonstrating all 9 acting sequences,
## stillness holds, micro-acting, comedic timing, and dual color/monochrome modes.

const NemiScene = preload("res://characters/nemi/nemi.tscn")
const HudScene = preload("res://characters/nemi/test/NemiTimingHUD.tscn")

var root_vp: Window
var nemi: Nemi
var hud: NemiTimingHUD
var banner_label: Label
var subtitle_label: Label

func _init() -> void:
	print("--- Starting Nemi Acting Video Production ---")
	root_vp = root
	_setup_scene()
	_play_video_performance()

func _setup_scene() -> void:
	# 1. Warm cream paper background
	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color("#faf7f5")
	root_vp.add_child(bg)
	
	# 2. Floor line
	var floor_line := Line2D.new()
	floor_line.points = PackedVector2Array([Vector2(60, 640), Vector2(1220, 640)])
	floor_line.width = 2.0
	floor_line.default_color = Color(0.24, 0.03, 0.12, 0.35)
	root_vp.add_child(floor_line)
	
	# 3. Nemi instance
	nemi = NemiScene.instantiate()
	nemi.position = Vector2(640, 420)
	nemi.scale = Vector2(1.15, 1.15)
	root_vp.add_child(nemi)
	
	# 4. Top-Right Timing HUD
	hud = HudScene.instantiate()
	root_vp.add_child(hud)
	hud.setup(nemi)
	hud.visible = true
	
	# 5. Bottom Director Action Banner
	var canvas_ui := CanvasLayer.new()
	root_vp.add_child(canvas_ui)
	
	var panel := PanelContainer.new()
	panel.offset_left = 60
	panel.offset_right = 920
	panel.offset_top = 20
	panel.offset_bottom = 85
	
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color(0.12, 0.08, 0.14, 0.90)
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.42, 0.28, 0.48, 1.0)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_right = 8
	style_box.corner_radius_bottom_left = 8
	panel.add_theme_stylebox_override("panel", style_box)
	canvas_ui.add_child(panel)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)
	
	banner_label = Label.new()
	banner_label.text = "NEMI — ACTING & ANIMATION LANGUAGE V1"
	banner_label.add_theme_color_override("font_color", Color("#f6d365"))
	banner_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(banner_label)
	
	subtitle_label = Label.new()
	subtitle_label.text = "YouTube Storytime Illustrated Acting System (Godot 4 Native)"
	subtitle_label.add_theme_color_override("font_color", Color("#dfd9e2"))
	subtitle_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(subtitle_label)

func _set_banner(title: String, subtitle: String) -> void:
	if banner_label: banner_label.text = title
	if subtitle_label: subtitle_label.text = subtitle

func _play_video_performance() -> void:
	# Initial settle
	for f in range(15):
		await process_frame
	
	# =========================================================================
	# INTRO TITLE (1.2s)
	# =========================================================================
	_set_banner("NEMI — ACTING & ANIMATION LANGUAGE V1", "Core Principle: Stillness is First-Class (No Constant Fidgeting / Bobbing)")
	nemi.reset_state()
	await nemi.hold(1.2)
	
	# =========================================================================
	# 1. MICRO ACTING (Test 1)
	# =========================================================================
	_set_banner("1. MICRO ACTING & THINKING", "Stillness Hold → Eye Dart Right → Organic Blink → Inquisitive 4° Head Tilt")
	nemi.reset_state()
	await nemi.hold(0.6)
	await nemi.actor.eyes.look("right", "fast")
	await nemi.hold(0.3)
	await nemi.actor.eyes.blink("normal")
	await nemi.actor.head.tilt(4.0, 0.18)
	await nemi.hold(0.8)
	
	# =========================================================================
	# 2. CONVERSATIONAL DIALOGUE (Test 2)
	# =========================================================================
	_set_banner("2. CONVERSATIONAL FLOW", "Eyes Lead Right → Head Follows → Eyebrow Pop → Warm Smile → Thoughtful Look Away")
	nemi.reset_state()
	await nemi.hold(0.4)
	await nemi.actor.eyes.look("right", "fast")
	await nemi.hold(0.12)
	await nemi.actor.head.turn(14.0, "fast")
	nemi.actor.face.set_eyebrows("both", 6.0, 0.12)
	nemi.actor.face.set_mouth("smile")
	await nemi.hold(0.8)
	await nemi.actor.eyes.look("left", "fast")
	await nemi.hold(0.4)
	await nemi.actor.eyes.look(Vector2.ZERO, "fast")
	await nemi.actor.head.turn(0.0, "fast")
	await nemi.hold(0.5)
	
	# =========================================================================
	# 3. COGNITIVE CONFUSION (Test 3)
	# =========================================================================
	_set_banner("3. COGNITIVE CONFUSION", "Up-Left Processing Glance → Asymmetric Brows → 4.5° Tilt → Question Mark")
	nemi.reset_state()
	await nemi.hold(0.3)
	await nemi.actor.eyes.look("up_left", "fast")
	await nemi.hold(0.25)
	nemi.actor.face.set_eyebrows("left", 8.0, 0.25)
	nemi.actor.face.set_eyebrows("right", -2.0, 0.10)
	await nemi.actor.head.tilt(4.5, 0.18)
	nemi.actor.face.set_expression("confused", "snap")
	await nemi.hold(1.0)
	
	# =========================================================================
	# 4. REALIZATION (Test 4)
	# =========================================================================
	_set_banner("4. GRADUATED REALIZATION", "Notice Glance → Pupils Widen → Brows Rise → Open Gasp & Sparkles → Head Lift")
	nemi.reset_state()
	await nemi.hold(0.3)
	await nemi.actor.eyes.look("right", "fast")
	await nemi.hold(0.15)
	nemi.actor.eyes.widen(1.22, 0.10)
	await nemi.hold(0.20)
	nemi.actor.face.set_eyebrows("both", 8.0, 0.15)
	nemi.actor.face.set_mouth("open_excited")
	nemi.actor.face.set_accent("sparkles", true)
	await nemi.actor.head.turn(10.0, "fast")
	await nemi.hold(1.0)
	
	# =========================================================================
	# 5. COMEDIC TIMING (Test 7)
	# =========================================================================
	_set_banner("5. COMEDIC TIMING & PUNCHLINE", "Setup ('Everything is fine!') → Silence Pause → Realization Glance → Shock Recoil & Freeze → Aftermath Hold")
	nemi.reset_state()
	# Step 1: Confident smiling setup
	nemi.actor.face.set_expression("happy", "snap")
	await nemi.actor.body.point("right", "fast", true)
	await nemi.hold(0.7)
	# Step 2: Complete silence pause
	await nemi.hold(0.5)
	# Step 3: Realization glance
	await nemi.actor.eyes.look("left", "fast")
	nemi.actor.face.set_eyebrows("left", 5.0, 0.2)
	await nemi.hold(0.3)
	# Step 4: Instant shock snap & violent recoil
	nemi.actor.face.set_expression("shocked", "snap")
	await nemi.actor.body.recoil(0.9, true)
	nemi.freeze()
	# Step 5: Aftermath hold (allowing joke to land)
	await nemi.hold(1.0)
	
	# =========================================================================
	# 6. DEADPAN CONTRAST (Test 6)
	# =========================================================================
	_set_banner("6. DEADPAN COMEDIC CONTRAST", "Unamused Side-Glance → 3° Head Tilt → Flat Line Mouth → 1.5s Unmoving Silence Hold")
	nemi.reset_state()
	await nemi.hold(0.3)
	await nemi.actor.eyes.look(Vector2(0.65, 0.0), "fast")
	await nemi.hold(0.3)
	await nemi.actor.head.tilt(3.0, 0.20)
	nemi.actor.face.set_expression("deadpan", "snap")
	await nemi.hold(1.5)
	
	# =========================================================================
	# 7. EXAGGERATED ACTION (Test 8)
	# =========================================================================
	_set_banner("7. EXAGGERATED ACTION & CONTRAST", "Anticipation Crouch → Snappy Point with +6° Overshoot → Settle → Recoil → Freeze")
	nemi.reset_state()
	await nemi.hold(0.3)
	nemi.actor.body.lean(-4.0, 0.12)
	await nemi.hold(0.12)
	await nemi.actor.body.point("right", "fast", true)
	await nemi.hold(0.5)
	nemi.actor.face.set_expression("shocked", "snap")
	await nemi.actor.body.recoil(1.0, true)
	nemi.freeze()
	await nemi.hold(0.8)
	
	# =========================================================================
	# 8. NOVEL MULTI-JOINT COMBINATION (Test 9)
	# =========================================================================
	_set_banner("8. NOVEL MULTI-JOINT COMPOSITION", "Backward Lean (-14°) + Head Turned Right (+16°) + Eyes Left (-1.0) + Pointing Up")
	nemi.reset_state()
	await nemi.hold(0.3)
	nemi.actor.body.lean(-14.0, 0.18)
	nemi.actor.head.turn(16.0, "normal")
	nemi.actor.eyes.look("left", "fast")
	nemi.actor.face.set_eyebrows("left", 8.0, 0.22)
	nemi.actor.face.set_mouth("open_excited")
	await nemi.actor.body.point("right", "fast", true)
	await nemi.hold(1.0)
	
	# =========================================================================
	# 9. FINISHED MONOCHROME MODE & OUTRO
	# =========================================================================
	_set_banner("9. FINISHED MONOCHROME INK MODE", "Instant Style Toggle on Identical Geometry → Pure Burgundy Ink Lines → Wave Goodbye")
	nemi.set_art_mode(NemiStyle.ArtMode.MONOCHROME)
	nemi.actor.face.set_expression("happy", "snap")
	await nemi.actor.head.nod(1.0, 1)
	await nemi.hold(0.3)
	await nemi.actor.body.wave("right", 2)
	await nemi.hold(0.8)
	
	print("--- All Showcase Sequences Finished Successfully! ---")
	quit(0)
