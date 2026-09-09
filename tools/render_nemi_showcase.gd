extends SceneTree

const NemiStyleScript = preload("res://characters/nemi/NemiStyle.gd")
const NemiScene = preload("res://characters/nemi/nemi.tscn")
const OverlayScript = preload("res://characters/nemi/test/NemiProportionOverlay.gd")

func _init() -> void:
	print("--- Starting Nemi Visual Showcase Renderer ---")
	var root_viewport := root
	
	# Root container
	var stage := Node2D.new()
	stage.name = "ShowcaseStage"
	root_viewport.add_child(stage)
	
	# Clean warm storytelling background
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.z_index = -100
	bg.size = Vector2(1280, 720)
	bg.color = Color("#faf7f5")
	stage.add_child(bg)
	
	# Floor line at y = 640
	var floor_line := Line2D.new()
	floor_line.name = "FloorLine"
	floor_line.z_index = -50
	floor_line.points = PackedVector2Array([Vector2(60, 640), Vector2(1220, 640)])
	floor_line.width = 2.0
	floor_line.default_color = Color(0.24, 0.03, 0.12, 0.35)
	stage.add_child(floor_line)
	
	# Instantiate Nemi
	var nemi: Node2D = NemiScene.instantiate()
	nemi.name = "Nemi"
	stage.add_child(nemi)
	
	# Proportion Overlay
	var overlay := Node2D.new()
	overlay.name = "ProportionOverlay"
	overlay.z_index = 100
	overlay.set_script(OverlayScript)
	overlay.set("target_nemi", nemi)
	overlay.visible = false
	stage.add_child(overlay)
	
	# UI Canvas for minimal, non-intrusive annotations
	var canvas_layer := CanvasLayer.new()
	stage.add_child(canvas_layer)
	
	var ui := Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(ui)
	
	# Title card in bottom-left
	var title_panel := PanelContainer.new()
	title_panel.position = Vector2(40, 655)
	ui.add_child(title_panel)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	title_panel.add_child(margin)
	
	var title_label := Label.new()
	title_label.name = "TitleLabel"
	title_label.add_theme_font_size_override("font_size", 15)
	title_label.add_theme_color_override("font_color", Color("#3e081e"))
	margin.add_child(title_label)
	
	# Mode badge in top-right
	var mode_panel := PanelContainer.new()
	mode_panel.position = Vector2(1040, 25)
	ui.add_child(mode_panel)
	
	var mode_margin := MarginContainer.new()
	mode_margin.add_theme_constant_override("margin_left", 14)
	mode_margin.add_theme_constant_override("margin_right", 14)
	mode_margin.add_theme_constant_override("margin_top", 6)
	mode_margin.add_theme_constant_override("margin_bottom", 6)
	mode_panel.add_child(mode_margin)
	
	var mode_label := Label.new()
	mode_label.name = "ModeLabel"
	mode_label.add_theme_font_size_override("font_size", 14)
	mode_label.add_theme_color_override("font_color", Color("#3e081e"))
	mode_margin.add_child(mode_label)
	
	# Top-left project branding badge
	var brand_label := Label.new()
	brand_label.position = Vector2(40, 25)
	brand_label.add_theme_font_size_override("font_size", 13)
	brand_label.add_theme_color_override("font_color", Color(0.4, 0.35, 0.35))
	brand_label.text = "NEMI • 100% GODOT 2D RIGGED VECTOR CHARACTER • ZERO TEXTURES"
	ui.add_child(brand_label)
	
	var output_dir := "res://characters/nemi/renders/"
	DirAccess.make_dir_recursive_absolute(output_dir)
	
	var shots: Array[Dictionary] = [
		{
			"filename": "01_nemi_fullbody_idle_color.png",
			"title": "1. Master Idle Pose — Full Body (Color Mode)",
			"shot": "full",
			"pose": "idle",
			"expr": "neutral",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2.ZERO,
			"overlay": false
		},
		{
			"filename": "02_nemi_fullbody_idle_monochrome.png",
			"title": "2. Master Idle Pose — Full Body (Finished Monochrome Ink)",
			"shot": "full",
			"pose": "idle",
			"expr": "neutral",
			"mode": NemiStyleScript.ArtMode.MONOCHROME,
			"gaze": Vector2.ZERO,
			"overlay": false
		},
		{
			"filename": "03_nemi_storytime_bust_color.png",
			"title": "3. Storytime Medium Shot — Waist-Up Framing (Color Mode)",
			"shot": "bust",
			"pose": "idle",
			"expr": "neutral",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2(0.4, -0.1),
			"overlay": false
		},
		{
			"filename": "04_nemi_storytime_bust_monochrome.png",
			"title": "4. Storytime Medium Shot — Waist-Up Framing (Monochrome Ink)",
			"shot": "bust",
			"pose": "idle",
			"expr": "neutral",
			"mode": NemiStyleScript.ArtMode.MONOCHROME,
			"gaze": Vector2(0.4, -0.1),
			"overlay": false
		},
		{
			"filename": "05_nemi_face_closeup_color.png",
			"title": "5. Procedural Facial System — Extreme Close-Up (Color Mode)",
			"shot": "face",
			"pose": "idle",
			"expr": "neutral",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2.ZERO,
			"overlay": false
		},
		{
			"filename": "06_nemi_face_closeup_monochrome.png",
			"title": "6. Procedural Facial System — Extreme Close-Up (Monochrome Ink)",
			"shot": "face",
			"pose": "idle",
			"expr": "neutral",
			"mode": NemiStyleScript.ArtMode.MONOCHROME,
			"gaze": Vector2.ZERO,
			"overlay": false
		},
		{
			"filename": "07_nemi_pose_pointing_color.png",
			"title": "7. Pointing Presentation Pose (Color Mode)",
			"shot": "full",
			"pose": "pointing",
			"expr": "happy",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2(-0.5, 0.0),
			"overlay": false
		},
		{
			"filename": "08_nemi_pose_thinking_color.png",
			"title": "8. Thinking / Contemplative Pose (Storytime Bust)",
			"shot": "bust",
			"pose": "thinking",
			"expr": "confused",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2(-0.4, -0.5),
			"overlay": false
		},
		{
			"filename": "09_nemi_pose_excited_color.png",
			"title": "9. Excited Cheering Pose (Storytime Bust)",
			"shot": "bust",
			"pose": "excited",
			"expr": "excited",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2(0.0, -0.3),
			"overlay": false
		},
		{
			"filename": "10_nemi_pose_recoiling_color.png",
			"title": "10. Comedic Shock Recoil (Storytime Bust)",
			"shot": "bust",
			"pose": "recoiling",
			"expr": "shocked",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2.ZERO,
			"overlay": false
		},
		{
			"filename": "11_nemi_novel_rig_pose_color.png",
			"title": "11. DEFINITIVE SUCCESS TEST: Novel Rig-Generated Pose (Color)",
			"shot": "full",
			"pose": "novel_pose",
			"expr": "shocked",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2(0.6, -0.2),
			"overlay": false
		},
		{
			"filename": "12_nemi_novel_rig_pose_monochrome.png",
			"title": "12. DEFINITIVE SUCCESS TEST: Novel Rig-Generated Pose (Monochrome)",
			"shot": "full",
			"pose": "novel_pose",
			"expr": "shocked",
			"mode": NemiStyleScript.ArtMode.MONOCHROME,
			"gaze": Vector2(0.6, -0.2),
			"overlay": false
		},
		{
			"filename": "13_nemi_proportion_debug_overlay.png",
			"title": "13. Proportion Verification Overlay (Head: 94x112, Cheeks: 92, Hair: 118)",
			"shot": "full",
			"pose": "idle",
			"expr": "neutral",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2.ZERO,
			"overlay": true
		}
	]
	
	for i in range(shots.size()):
		var s: Dictionary = shots[i]
		
		# Set framing
		match s["shot"]:
			"full":
				nemi.position = Vector2(640, 396)
				nemi.scale = Vector2(1.22, 1.22)
				floor_line.visible = true
			"bust":
				nemi.position = Vector2(640, 540)
				nemi.scale = Vector2(2.0, 2.0)
				floor_line.visible = false
			"face":
				nemi.position = Vector2(640, 785)
				nemi.scale = Vector2(3.2, 3.2)
				floor_line.visible = false
		
		# Set state
		nemi.call("set_art_mode", s["mode"])
		nemi.call("set_pose", s["pose"], 0.0)
		nemi.call("set_expression", s["expr"])
		if "gaze" in s:
			nemi.call("look_at_direction", s["gaze"])
		
		# Overlay
		overlay.visible = s.get("overlay", false)
		if overlay.visible:
			overlay.queue_redraw()
		
		# Update annotations
		title_label.text = s["title"]
		mode_label.text = "MODE: " + ("COLOR" if s["mode"] == NemiStyleScript.ArtMode.COLOR else "MONOCHROME")
		
		# Let renderer process & flush
		for f in range(4):
			await process_frame
		
		var img: Image = root_viewport.get_texture().get_image()
		var save_path: String = output_dir + str(s["filename"])
		img.save_png(save_path)
		print("Rendered: ", save_path)
	
	# Generate 00_nemi_showcase_overview.png contact sheet
	_build_overview_contact_sheet(output_dir)
	
	print("--- All Nemi Showcase Renders Successfully Completed! ---")
	quit(0)

func _build_overview_contact_sheet(dir_path: String) -> void:
	var images_to_include := [
		"01_nemi_fullbody_idle_color.png",
		"02_nemi_fullbody_idle_monochrome.png",
		"03_nemi_storytime_bust_color.png",
		"04_nemi_storytime_bust_monochrome.png",
		"05_nemi_face_closeup_color.png",
		"06_nemi_face_closeup_monochrome.png",
		"07_nemi_pose_pointing_color.png",
		"08_nemi_pose_thinking_color.png",
		"09_nemi_pose_excited_color.png",
		"10_nemi_pose_recoiling_color.png",
		"11_nemi_novel_rig_pose_color.png",
		"12_nemi_novel_rig_pose_monochrome.png"
	]
	
	var cols := 4
	var rows := 3
	var thumb_w := 300
	var thumb_h := int(thumb_w * 720.0 / 1280.0) # 168
	var pad_x := 20
	var pad_y := 40
	var margin_top := 60
	var margin_left := 30
	var margin_bottom := 30
	
	var total_w := margin_left * 2 + cols * thumb_w + (cols - 1) * pad_x
	var total_h := margin_top + rows * (thumb_h + pad_y) + margin_bottom
	
	var sheet := Image.create(total_w, total_h, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#faf7f5"))
	
	for idx in range(images_to_include.size()):
		var fname: String = images_to_include[idx]
		var c := idx % cols
		var r := idx / cols
		var x := margin_left + c * (thumb_w + pad_x)
		var y := margin_top + r * (thumb_h + pad_y)
		
		var img_path: String = dir_path + fname
		if FileAccess.file_exists(img_path):
			var src := Image.load_from_file(img_path)
			if src:
				src.resize(thumb_w, thumb_h, Image.INTERPOLATE_LANCZOS)
				src.convert(Image.FORMAT_RGBA8)
				sheet.blit_rect(src, Rect2i(0, 0, thumb_w, thumb_h), Vector2i(x, y))
	
	var overview_save: String = dir_path + "00_nemi_showcase_overview.png"
	sheet.save_png(overview_save)
	print("Rendered Contact Sheet: ", overview_save)
