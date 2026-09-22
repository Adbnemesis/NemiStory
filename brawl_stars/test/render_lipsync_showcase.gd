extends Node2D

@onready var leon_scene = preload("res://brawl_stars/characters/leon/Leon.tscn")
@onready var edgar_scene = preload("res://brawl_stars/characters/edgar/Edgar.tscn")

func _ready() -> void:
	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color(0.985, 0.97, 0.945)
	add_child(bg)
	
	# Instantiate Leon on the left
	var leon = leon_scene.instantiate()
	leon.position = Vector2(380, 530)
	leon.scale = Vector2(1.0, 1.0)
	add_child(leon)
	leon.set_expression("con_artist_persuasive")
	leon.set_pose("con_artist_pitch")
	leon.set_viseme("ae")
	leon.visual.face.mouth_openness = 0.85
	
	# Speech bubble for Leon
	var leon_bubble := _create_speech_bubble(
		Vector2(140, 150),
		Vector2(320, 100),
		"\"Wait! Come on, I'm telling you,\nit was a tactical retreat!\nPlus, the bush had free trophies!\"",
		Color("#166534"),
		Vector2(340, 260)
	)
	add_child(leon_bubble)
	
	# Instantiate Edgar on the right
	var edgar = edgar_scene.instantiate()
	edgar.position = Vector2(900, 530)
	edgar.scale = Vector2(1.0, 1.0)
	add_child(edgar)
	edgar.set_expression("toxic_smug")
	edgar.set_pose("phone_scroll")
	edgar.set_viseme("o_u")
	edgar.visual.face.mouth_openness = 0.8
	
	# Speech bubble for Edgar
	var edgar_bubble := _create_speech_bubble(
		Vector2(760, 150),
		Vector2(340, 95),
		"\"Yeah, whatever. You're level 50,\nI'm not wasting my Super on you.\nYou're on your own.\"",
		Color("#581c87"),
		Vector2(880, 260)
	)
	add_child(edgar_bubble)

	# UI Titles
	var title_box = VBoxContainer.new()
	title_box.position = Vector2(80, 35)
	add_child(title_box)
	
	var header = Label.new()
	header.text = "BRAWL STARS — LIVE ILLUSTRATIVE LIP-SYNC & SPEECH VISEMES"
	header.add_theme_font_size_override("font_size", 26)
	header.add_theme_color_override("font_color", Color(0.12, 0.12, 0.15))
	title_box.add_child(header)
	
	var subheader = Label.new()
	subheader.text = "Syllable-Aware Vowel Cadence (~12-15 FPS) • AudioStream Synchronization • Dynamic Expressions"
	subheader.add_theme_font_size_override("font_size", 15)
	subheader.add_theme_color_override("font_color", Color(0.42, 0.42, 0.50))
	title_box.add_child(subheader)

func _create_speech_bubble(pos: Vector2, size: Vector2, text: String, accent_color: Color, tail_target: Vector2) -> Control:
	var container := Control.new()
	container.position = pos
	
	# White rounded panel
	var panel := Panel.new()
	panel.size = size
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 1.0, 1.0, 0.95)
	sb.border_width_left = 3
	sb.border_width_top = 3
	sb.border_width_right = 3
	sb.border_width_bottom = 3
	sb.border_color = Color("#1c1624")
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.shadow_color = Color(0, 0, 0, 0.08)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(2, 4)
	panel.add_theme_stylebox_override("panel", sb)
	container.add_child(panel)
	
	var lbl := Label.new()
	lbl.position = Vector2(14, 12)
	lbl.size = size - Vector2(28, 24)
	lbl.text = text
	lbl.add_theme_color_override("font_color", Color("#18181b"))
	lbl.add_theme_font_size_override("font_size", 14)
	container.add_child(lbl)
	
	return container
