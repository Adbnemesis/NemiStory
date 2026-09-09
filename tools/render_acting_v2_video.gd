extends SceneTree

## Dedicated Video Production Script for NEMI Acting & Animation Language V2
## Records a deterministic 1280x720 30FPS master video demonstrating all 10 Authoritative Tests (A through J),
## stillness holds (>85%), eye-lead attention, micro-acting, comedic timing, and dual color/monochrome modes.

const NemiScene = preload("res://characters/nemi/nemi.tscn")
const HudScene = preload("res://characters/nemi/test/NemiTimingHUD.tscn")

var root_vp: Window
var nemi: Nemi
var hud: NemiTimingHUD
var banner_label: Label
var subtitle_label: Label

func _init() -> void:
	print("--- Starting Nemi Acting V2 Video Production ---")
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
	panel.offset_left = 40
	panel.offset_right = 880
	panel.offset_top = 20
	panel.offset_bottom = 85
	
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color(0.12, 0.08, 0.14, 0.92)
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
	banner_label.text = "NEMI — ACTING & ANIMATION LANGUAGE V2"
	banner_label.add_theme_color_override("font_color", Color("#f6d365"))
	banner_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(banner_label)
	
	subtitle_label = Label.new()
	subtitle_label.text = "Temporal & Micro-Acting Rework (YouTube Storytime Animated Style)"
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
	
	# Initial settle hold
	_set_banner("NEMI — ACTING LANGUAGE V2", "Baseline Stillness: Over 85% held poses, no random idle bobbing")
	await nemi.hold(0.8)
	
	# ---------------------------------------------------------------------
	# 1. TEST A: ATTENTION (EYE-LEAD)
	# ---------------------------------------------------------------------
	_set_banner("TEST A — ATTENTION (EYE-LEAD)", "Eyes move first (0.00s) -> Hold (0.15s) -> Head follows (0.24s)")
	await nemi.actor.reactions.test_a_attention()
	await nemi.hold(0.4)
	
	# ---------------------------------------------------------------------
	# 2. TEST B: CONVERSATIONAL
	# ---------------------------------------------------------------------
	_set_banner("TEST B — CONVERSATIONAL", "Small eye shift -> Brow raise -> Tiny head tilt -> Soft smile")
	await nemi.actor.reactions.test_b_conversational()
	await nemi.hold(0.3)
	
	# ---------------------------------------------------------------------
	# 3. TEST C: CONFUSION (THINKING)
	# ---------------------------------------------------------------------
	_set_banner("TEST C — CONFUSION (THINKING)", "Attention -> Pause -> Asymmetric brows -> Inquisitive tilt -> Hold")
	await nemi.actor.reactions.test_c_confusion()
	await nemi.hold(0.3)
	
	# ---------------------------------------------------------------------
	# 4. TEST D: REALIZATION (DELAYED BEAT)
	# ---------------------------------------------------------------------
	_set_banner("TEST D — REALIZATION (DELAYED BEAT)", "Notice -> Cognitive delay -> Eyes widen -> Brows rise -> Head turns")
	await nemi.actor.reactions.test_d_realization()
	await nemi.hold(0.4)
	
	# ---------------------------------------------------------------------
	# 5. TEST E: SHOCK & RECOIL (FREEZE)
	# ---------------------------------------------------------------------
	_set_banner("TEST E — SHOCK & RECOIL (FREEZE)", "Anticipation -> Fast recoil -> Secondary hair -> Absolute freeze frame")
	await nemi.actor.reactions.test_e_shock()
	await nemi.hold(0.4)
	
	# ---------------------------------------------------------------------
	# 6. TEST F: DEADPAN (STILLNESS HOLD)
	# ---------------------------------------------------------------------
	_set_banner("TEST F — DEADPAN (STILLNESS HOLD)", "Understated side-eye -> Tiny 3° tilt -> 1.0s unmoving silence hold")
	await nemi.actor.reactions.test_f_deadpan()
	await nemi.hold(0.3)
	
	# ---------------------------------------------------------------------
	# 7. TEST G: EXAGGERATED COMEDIC ACTION
	# ---------------------------------------------------------------------
	_set_banner("TEST G — EXAGGERATED ACTION", "Anticipation -> Fast point (+6° overshoot) -> Hold -> Sudden recoil")
	await nemi.actor.reactions.test_g_exaggerated_action()
	await nemi.hold(0.4)
	
	# ---------------------------------------------------------------------
	# 8. TEST H: NOVEL COMBINATION
	# ---------------------------------------------------------------------
	_set_banner("TEST H — NOVEL COMBINATION", "Eyes left, head right, brow up, lean back, arm up point (Zero new artwork)")
	await nemi.actor.reactions.test_h_novel_combination()
	await nemi.hold(0.4)
	
	# ---------------------------------------------------------------------
	# 9. TEST I: MULTI-STAGE REACTION (CORE TEST)
	# ---------------------------------------------------------------------
	_set_banner("TEST I — MULTI-STAGE REACTION (CORE)", "Normal -> Notice -> Confusion -> Realization -> Shock -> Aftermath")
	await nemi.actor.reactions.test_i_multistage_reaction()
	await nemi.hold(0.5)
	
	# ---------------------------------------------------------------------
	# 10. TEST J: THREE INTENSITIES
	# ---------------------------------------------------------------------
	_set_banner("TEST J — THREE INTENSITIES", "Recoil scaled at Subtle (0.2x) -> Normal (0.5x) -> Exaggerated (1.0x)")
	await nemi.actor.reactions.test_j_three_intensities()
	await nemi.hold(0.4)
	
	# ---------------------------------------------------------------------
	# 11. MONOCHROME ART MODE PARITY
	# ---------------------------------------------------------------------
	_set_banner("MONOCHROME ART MODE PARITY", "Identical acting language running on ink illustration mode")
	nemi.set_art_mode(NemiStyle.ArtMode.MONOCHROME)
	await nemi.actor.reactions.test_a_attention()
	await nemi.hold(0.5)
	
	# Final neutral rest
	_set_banner("NEMI ACTING SYSTEM V2 APPROVED", "Live Godot 4 Character Rig — 100% Vector Procedural Acting")
	nemi.set_art_mode(NemiStyle.ArtMode.COLOR)
	await nemi.actor.reset()
	await nemi.hold(0.8)
	
	print("--- Video Performance Sequence Completed ---")
	quit(0)
