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
	leon.position = Vector2(400, 520)
	leon.scale = Vector2(1.0, 1.0)
	add_child(leon)
	leon.set_expression("smug")
	leon.set_pose("holding_shurikens")
	leon.trigger_shuriken_spin(true)
	
	# Instantiate Edgar on the right
	var edgar = edgar_scene.instantiate()
	edgar.position = Vector2(880, 520)
	edgar.scale = Vector2(1.0, 1.0)
	add_child(edgar)
	edgar.set_expression("toxic_smug")
	edgar.set_pose("punch_ready")

	# UI Titles
	var title_box = VBoxContainer.new()
	title_box.position = Vector2(80, 40)
	add_child(title_box)
	
	var header = Label.new()
	header.text = "BRAWL STARS — PROCEDURAL 2D CHARACTER RIGS"
	header.add_theme_font_size_override("font_size", 28)
	header.add_theme_color_override("font_color", Color(0.12, 0.12, 0.15))
	title_box.add_child(header)
	
	var subheader = Label.new()
	subheader.text = "Leon (Sneaky Assassin) & Edgar (Sentient Scarf Brawler) • Hand-Drawn Storytime Vector Art"
	subheader.add_theme_font_size_override("font_size", 16)
	subheader.add_theme_color_override("font_color", Color(0.42, 0.42, 0.50))
	title_box.add_child(subheader)
