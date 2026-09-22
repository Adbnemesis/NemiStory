extends Node2D

@onready var leon_scene = preload("res://brawl_stars/characters/leon/Leon.tscn")
@onready var edgar_scene = preload("res://brawl_stars/characters/edgar/Edgar.tscn")

func _ready() -> void:
	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color(0.985, 0.97, 0.945)
	add_child(bg)
	
	var visemes: Array[String] = ["closed", "small_open", "ae", "o_u", "wide"]
	
	# Row 1: Leon visemes
	var leon_header := Label.new()
	leon_header.position = Vector2(60, 30)
	leon_header.text = "LEON SPEECH VISEMES (Mischievous / Con-Artist Delivery)"
	leon_header.add_theme_font_size_override("font_size", 20)
	leon_header.add_theme_color_override("font_color", Color("#15803d"))
	add_child(leon_header)
	
	for i in range(visemes.size()):
		var v_name := visemes[i]
		var leon = leon_scene.instantiate()
		leon.position = Vector2(160 + i * 230, 270)
		leon.scale = Vector2(0.9, 0.9)
		add_child(leon)
		leon.set_expression("mischievous")
		leon.set_viseme(v_name)
		leon.visual.face.mouth_openness = 0.9 if v_name != "closed" else 0.0
		
		var lbl := Label.new()
		lbl.position = Vector2(100 + i * 230, 320)
		lbl.size = Vector2(120, 30)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.text = v_name.to_upper()
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color("#1f2937"))
		add_child(lbl)
	
	# Row 2: Edgar visemes
	var edgar_header := Label.new()
	edgar_header.position = Vector2(60, 380)
	edgar_header.text = "EDGAR SPEECH VISEMES (Cynical / Monotone Emo Delivery)"
	edgar_header.add_theme_font_size_override("font_size", 20)
	edgar_header.add_theme_color_override("font_color", Color("#6b21a8"))
	add_child(edgar_header)
	
	for i in range(visemes.size()):
		var v_name := visemes[i]
		var edgar = edgar_scene.instantiate()
		edgar.position = Vector2(160 + i * 230, 620)
		edgar.scale = Vector2(0.9, 0.9)
		add_child(edgar)
		edgar.set_expression("toxic_smug")
		edgar.set_viseme(v_name)
		edgar.visual.face.mouth_openness = 0.85 if v_name != "closed" else 0.0
		
		var lbl := Label.new()
		lbl.position = Vector2(100 + i * 230, 670)
		lbl.size = Vector2(120, 30)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.text = v_name.to_upper()
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color("#1f2937"))
		add_child(lbl)
