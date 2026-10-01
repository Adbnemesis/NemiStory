class_name CarouselSlideStage
extends Node2D

## Master Slide Compositor Stage (1080x1350)
## Composes native vector characters, typography, props, doodles, and paper canvas.

const Typography = preload("res://carousel/common/scripts/CarouselTypography.gd")
const Doodles = preload("res://carousel/common/scripts/CarouselDoodles.gd")
const NemiProps = preload("res://carousel/nemi/props/NemiCarouselProps.gd")
const ADBProps = preload("res://carousel/adb/props/ADBCarouselProps.gd")

const NemiScene = preload("res://carousel/nemi/character/NemiCarouselCharacter.tscn")
const ADBScene = preload("res://carousel/adb/character/ADBCarouselCharacter.tscn")

var slide_data: Dictionary = {}
var brand: String = "nemi"
var total_slides: int = 7
var current_slide_num: int = 1

var character_node: Node2D = null

func setup_slide(brand_name: String, data: Dictionary, slide_num: int, total_count: int) -> void:
	brand = brand_name
	slide_data = data
	current_slide_num = slide_num
	total_slides = total_count
	
	_setup_character()
	queue_redraw()

func _setup_character() -> void:
	if character_node:
		character_node.queue_free()
		character_node = null
		
	if brand == "adb":
		character_node = ADBScene.instantiate()
	else:
		character_node = NemiScene.instantiate()
		
	add_child(character_node)
	
	# Extract character instructions
	var char_data: Dictionary = slide_data.get("character", {})
	var pose: String = char_data.get("pose", "relaxed_standing")
	var expr: String = char_data.get("expression", "neutral")
	var char_scale: float = char_data.get("scale", 1.2)
	
	character_node.call("set_pose", pose)
	character_node.call("set_expression", expr)
	character_node.scale = Vector2(char_scale, char_scale)
	
	# Spatial Placement based on archetype
	var arch: String = slide_data.get("archetype", "split_stage")
	match arch:
		"edge_peek":
			character_node.position = Vector2(540, 1260)
		"split_stage":
			character_node.position = Vector2(780, 780)
		"card_perch":
			character_node.position = Vector2(540, 360)
		"hero_closeup":
			character_node.scale = Vector2(char_scale * 1.35, char_scale * 1.35)
			character_node.position = Vector2(540, 960)
		"quote_card":
			character_node.scale = Vector2(char_scale * 0.9, char_scale * 0.9)
			character_node.position = Vector2(850, 1100)
		"sign_cta":
			character_node.position = Vector2(540, 815)
		_:
			character_node.position = Vector2(540, 800)

func _draw() -> void:
	# 1. Background Paper Canvas
	var bg_color := Color("#faf7f5") if brand == "nemi" else Color("#faf6ee")
	draw_rect(Rect2(0, 0, 1080, 1350), bg_color)
	
	# Faint Paper Texture / Dot Matrix
	if brand == "adb":
		_draw_dot_matrix()
	else:
		_draw_paper_fibers()
		
	# 2. Slide Numbering in Top-Right Safe Zone
	var num_str := "%02d / %02d" % [current_slide_num, total_slides]
	var meta_color := Color(0.35, 0.35, 0.4, 0.7)
	draw_string(Typography.FONT_PATRICK, Vector2(920, 85), num_str, HORIZONTAL_ALIGNMENT_RIGHT, -1, 24, meta_color)
	
	# Brand Watermark in Top-Left Safe Zone
	var brand_tag := "NEMI • STORYTIME" if brand == "nemi" else "ADB • STORIES"
	draw_string(Typography.FONT_PATRICK, Vector2(80, 85), brand_tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, meta_color)
	
	# 3. Archetype-Specific Layout Composition
	var arch: String = slide_data.get("archetype", "split_stage")
	match arch:
		"edge_peek":
			_draw_archetype_edge_peek()
		"split_stage":
			_draw_archetype_split_stage()
		"card_perch":
			_draw_archetype_card_perch()
		"hero_closeup":
			_draw_archetype_hero_closeup()
		"quote_card":
			_draw_archetype_quote_card()
		"sign_cta":
			_draw_archetype_sign_cta()
		_:
			_draw_archetype_split_stage()
			
	# 4. Draw Props
	var props: Array = slide_data.get("props", [])
	for p in props:
		_draw_prop_item(str(p))
		
	# 5. Draw Doodles
	var doodles: Array = slide_data.get("doodles", [])
	for d in doodles:
		_draw_doodle_item(str(d))

func _draw_archetype_edge_peek() -> void:
	var ink_col := Color("#38101e") if brand == "nemi" else Color("#2b2623")
	var highlight_col := Color("#f8b4a055") if brand == "nemi" else Color("#2b262318")
	var h_words: Array = slide_data.get("highlight_words", [])
	
	# Big Standalone Hook Headline
	var headline: String = slide_data.get("headline", "")
	Typography.draw_wrapped_text(
		self, headline, Rect2(80, 160, 920, 420), Typography.FONT_PATRICK, 68, ink_col,
		HORIZONTAL_ALIGNMENT_CENTER, 14.0, h_words, highlight_col
	)
	
	# Subhead
	var subhead: String = slide_data.get("subhead", "")
	if not subhead.is_empty():
		Typography.draw_wrapped_text(
			self, subhead, Rect2(120, 460, 840, 250), Typography.FONT_PATRICK, 40, ink_col * 1.1,
			HORIZONTAL_ALIGNMENT_CENTER, 10.0
		)
		
	# Handwritten Note / Aside
	var note: String = slide_data.get("handwritten_note", "")
	if not note.is_empty():
		var note_col := Color("#d64937") if brand == "nemi" else Color("#4a5770")
		draw_string(Typography.FONT_CAVEAT, Vector2(140, 680), note, HORIZONTAL_ALIGNMENT_LEFT, -1, 38, note_col)
		# Small hand-drawn wavy underline
		draw_line(Vector2(140, 690), Vector2(380, 692), note_col, 2.5)

func _draw_archetype_split_stage() -> void:
	var ink_col := Color("#38101e") if brand == "nemi" else Color("#2b2623")
	var highlight_col := Color("#f8b4a055") if brand == "nemi" else Color("#2b262318")
	var h_words: Array = slide_data.get("highlight_words", [])
	
	# Headline (Left Column)
	var headline: String = slide_data.get("headline", "")
	Typography.draw_wrapped_text(
		self, headline, Rect2(80, 180, 520, 360), Typography.FONT_PATRICK, 54, ink_col,
		HORIZONTAL_ALIGNMENT_LEFT, 12.0, h_words, highlight_col
	)
	
	# Body Text (Left Column)
	var body_text: String = slide_data.get("body_text", "")
	if not body_text.is_empty():
		Typography.draw_wrapped_text(
			self, body_text, Rect2(80, 480, 480, 420), Typography.FONT_PATRICK, 36, ink_col * 1.1,
			HORIZONTAL_ALIGNMENT_LEFT, 10.0
		)
		
	# Handwritten Note (Bottom Left)
	var note: String = slide_data.get("handwritten_note", "")
	if not note.is_empty():
		var note_col := Color("#d64937") if brand == "nemi" else Color("#4a5770")
		draw_string(Typography.FONT_CAVEAT, Vector2(80, 920), note, HORIZONTAL_ALIGNMENT_LEFT, -1, 36, note_col)

func _draw_archetype_card_perch() -> void:
	var ink_col := Color("#38101e") if brand == "nemi" else Color("#2b2623")
	var card_bg := Color("#ffffff") if brand == "nemi" else Color("#f4eee2")
	var card_rect := Rect2(100, 560, 880, 560)
	
	# Framed Card
	draw_rect(card_rect, card_bg)
	draw_rect(card_rect, ink_col, false, 3.5)
	
	# Card Text
	var headline: String = slide_data.get("headline", "")
	Typography.draw_wrapped_text(
		self, headline, Rect2(140, 620, 800, 220), Typography.FONT_PATRICK, 52, ink_col,
		HORIZONTAL_ALIGNMENT_CENTER, 12.0
	)
	
	var body_text: String = slide_data.get("body_text", "")
	if not body_text.is_empty():
		Typography.draw_wrapped_text(
			self, body_text, Rect2(140, 780, 800, 280), Typography.FONT_PATRICK, 36, ink_col * 1.1,
			HORIZONTAL_ALIGNMENT_CENTER, 10.0
		)

func _draw_archetype_hero_closeup() -> void:
	var ink_col := Color("#38101e") if brand == "nemi" else Color("#2b2623")
	var headline: String = slide_data.get("headline", "")
	Typography.draw_wrapped_text(
		self, headline, Rect2(80, 160, 920, 320), Typography.FONT_PATRICK, 62, ink_col,
		HORIZONTAL_ALIGNMENT_CENTER, 12.0
	)
	
	var subhead: String = slide_data.get("subhead", "")
	if not subhead.is_empty():
		Typography.draw_wrapped_text(
			self, subhead, Rect2(100, 360, 880, 180), Typography.FONT_PATRICK, 38, ink_col * 1.1,
			HORIZONTAL_ALIGNMENT_CENTER, 8.0
		)

func _draw_archetype_quote_card() -> void:
	var ink_col := Color("#38101e") if brand == "nemi" else Color("#2b2623")
	var card_col := Color("#f1ece3")
	var card_rect := Rect2(80, 220, 920, 720)
	
	draw_rect(card_rect, card_col)
	draw_rect(card_rect, ink_col, false, 4.0)
	
	# "TAKEAWAY" Tag
	var tag_col := Color("#d64937") if brand == "nemi" else Color("#4a5770")
	draw_string(Typography.FONT_PATRICK, Vector2(120, 300), "✦ KEY TAKEAWAY:", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, tag_col)
	
	var headline: String = slide_data.get("headline", "")
	Typography.draw_wrapped_text(
		self, headline, Rect2(120, 360, 840, 240), Typography.FONT_PATRICK, 56, ink_col,
		HORIZONTAL_ALIGNMENT_LEFT, 12.0
	)
	
	var body_text: String = slide_data.get("body_text", "")
	if not body_text.is_empty():
		Typography.draw_wrapped_text(
			self, body_text, Rect2(120, 580, 840, 300), Typography.FONT_PATRICK, 36, ink_col * 1.1,
			HORIZONTAL_ALIGNMENT_LEFT, 10.0
		)

func _draw_archetype_sign_cta() -> void:
	var ink_col := Color("#38101e") if brand == "nemi" else Color("#2b2623")
	
	# Prompt Headline
	var headline: String = slide_data.get("headline", "")
	Typography.draw_wrapped_text(
		self, headline, Rect2(80, 180, 920, 300), Typography.FONT_PATRICK, 58, ink_col,
		HORIZONTAL_ALIGNMENT_CENTER, 12.0
	)
	
	# Signboard held by character
	var sign_rect := Rect2(160, 480, 760, 240)
	draw_rect(sign_rect, Color("#ffffff"))
	draw_rect(sign_rect, ink_col, false, 3.5)
	
	var cta_text: String = slide_data.get("cta_text", "Drop your thoughts in the comments! ➔")
	Typography.draw_wrapped_text(
		self, cta_text, Rect2(180, 520, 720, 180), Typography.FONT_PATRICK, 42, ink_col,
		HORIZONTAL_ALIGNMENT_CENTER, 10.0
	)

func _draw_prop_item(prop_name: String) -> void:
	if brand == "nemi":
		match prop_name:
			"drawing_tablet":
				NemiProps.draw_prop(self, "drawing_tablet", Vector2(320, 1080), 1.2)
			"coffee_mug":
				NemiProps.draw_prop(self, "coffee_mug", Vector2(180, 1140), 1.2)
			"timeline_scrubber":
				NemiProps.draw_prop(self, "timeline_scrubber", Vector2(540, 480), 1.1)
			"sketchbook":
				NemiProps.draw_prop(self, "sketchbook", Vector2(240, 1100), 1.1)
	else:
		match prop_name:
			"gaming_controller":
				ADBProps.draw_prop(self, "gaming_controller", Vector2(260, 1180), 1.2)
			"mechanical_keyboard":
				ADBProps.draw_prop(self, "mechanical_keyboard", Vector2(540, 1140), 1.1)
			"matte_coffee_mug":
				ADBProps.draw_prop(self, "matte_coffee_mug", Vector2(180, 1140), 1.1)
			"smartphone":
				ADBProps.draw_prop(self, "smartphone", Vector2(260, 1120), 1.1)

func _draw_doodle_item(doodle_name: String) -> void:
	match doodle_name:
		"sparkles", "copper_star", "pixel_stars":
			Doodles.draw_doodle(self, brand, doodle_name, Vector2(140, 240), 1.3)
			Doodles.draw_doodle(self, brand, doodle_name, Vector2(920, 280), 1.1)
		"curved_arrow":
			Doodles.draw_doodle(self, brand, "curved_arrow", Vector2(780, 1160), 1.2)
		"sweat_drop":
			Doodles.draw_doodle(self, brand, "sweat_drop", Vector2(460, 680), 1.3)
		"cat_paw":
			Doodles.draw_doodle(self, brand, "cat_paw", Vector2(980, 1120), 1.2)
		"deadpan_dots":
			Doodles.draw_doodle(self, brand, "deadpan_dots", Vector2(520, 480), 1.2)
		"terminal_brackets":
			Doodles.draw_doodle(self, brand, "terminal_brackets", Vector2(540, 490), 1.3)

func _draw_dot_matrix() -> void:
	var dot_col := Color(0.2, 0.22, 0.28, 0.04)
	for x in range(80, 1000, 60):
		for y in range(100, 1240, 60):
			draw_circle(Vector2(x, y), 1.8, dot_col)

func _draw_paper_fibers() -> void:
	var fiber_col := Color(0.22, 0.1, 0.15, 0.035)
	for i in range(16):
		var fx := 100.0 + (i * 59) % 860
		var fy := 120.0 + (i * 73) % 1080
		draw_line(Vector2(fx, fy), Vector2(fx + 25, fy + 8), fiber_col, 1.2)
