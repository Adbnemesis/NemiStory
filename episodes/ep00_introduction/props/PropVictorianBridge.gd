@tool
extends Node2D
class_name PropVictorianBridge

## Hand-drawn sketchcard/blueprint of an excessively detailed Victorian Iron Bridge
## Displays structural tension arches, intricate cross-bracing trusses, measurement arrows,
## and humorous technical annotations ("STRUCTURAL TENSION", "6 HOURS OF RESEARCH", "ON SCREEN: 0.5s").

var progress: float = 0.0
var bg_color: Color = Color(0.95, 0.93, 0.88, 0.95)
var ink_color: Color = Color(0.18, 0.15, 0.14, 0.9)
var blue_ink: Color = Color(0.15, 0.35, 0.65, 0.85)
var red_accent: Color = Color(0.82, 0.25, 0.22, 0.9)

func _ready() -> void:
	var tw = create_tween()
	tw.tween_property(self, "progress", 1.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.4).from(Vector2(0.2, 0.2))

func _draw() -> void:
	# Outer blueprint card (width 500, height 300)
	var w: float = 520.0
	var h: float = 280.0
	var rect = Rect2(-w * 0.5, -h * 0.5, w, h)
	
	# Drop shadow
	draw_rect(rect.grow(4.0), Color(0.1, 0.1, 0.1, 0.12), true)
	# Card base (blueprint tinted ivory/parchment)
	draw_rect(rect, bg_color, true)
	draw_rect(rect, ink_color, false, 3.0)
	# Inner technical border
	draw_rect(rect.grow(-8.0), blue_ink, false, 1.2)
	
	# Blueprint grid lines
	for x in range(-240, 250, 40):
		draw_line(Vector2(x, -h * 0.5 + 10), Vector2(x, h * 0.5 - 10), Color(blue_ink.r, blue_ink.g, blue_ink.b, 0.15), 1.0)
	for y in range(-120, 130, 40):
		draw_line(Vector2(-w * 0.5 + 10, y), Vector2(w * 0.5 - 10, y), Color(blue_ink.r, blue_ink.g, blue_ink.b, 0.15), 1.0)
		
	# Water line below bridge
	draw_line(Vector2(-230, 85), Vector2(230, 85), Color(blue_ink.r, blue_ink.g, blue_ink.b, 0.4), 2.0)
	draw_line(Vector2(-210, 95), Vector2(210, 95), Color(blue_ink.r, blue_ink.g, blue_ink.b, 0.25), 1.5)
	
	# Bridge piers / stone abutments
	draw_rect(Rect2(-210, 10, 35, 75), ink_color, false, 2.5)
	draw_rect(Rect2(-210, 10, 35, 75), Color(0.7, 0.68, 0.65, 0.5), true)
	draw_rect(Rect2(175, 10, 35, 75), ink_color, false, 2.5)
	draw_rect(Rect2(175, 10, 35, 75), Color(0.7, 0.68, 0.65, 0.5), true)
	
	# Central piers
	draw_rect(Rect2(-60, 25, 25, 60), ink_color, false, 2.0)
	draw_rect(Rect2(35, 25, 25, 60), ink_color, false, 2.0)
	
	# Main road deck
	draw_line(Vector2(-230, 15), Vector2(230, 15), ink_color, 4.0)
	draw_line(Vector2(-230, 22), Vector2(230, 22), ink_color, 2.0)
	
	# Victorian wrought-iron arched trusses
	var arch_points: PackedVector2Array = PackedVector2Array()
	for i in range(25):
		var t_val = float(i) / 24.0
		var px = lerp(-175.0, 175.0, t_val)
		var py = -65.0 * sin(t_val * PI) + 15.0
		arch_points.append(Vector2(px, py))
	draw_polyline(arch_points, ink_color, 3.0)
	
	# Upper parallel arch
	var arch_upper: PackedVector2Array = PackedVector2Array()
	for i in range(25):
		var t_val = float(i) / 24.0
		var px = lerp(-175.0, 175.0, t_val)
		var py = -80.0 * sin(t_val * PI) + 12.0
		arch_upper.append(Vector2(px, py))
	draw_polyline(arch_upper, ink_color, 2.5)
	
	# Truss diagonal lattice webbing
	for i in range(1, 24, 2):
		if i < arch_points.size() and i < arch_upper.size():
			draw_line(arch_points[i], Vector2(arch_points[i].x, 15.0), blue_ink, 1.5)
			draw_line(arch_upper[i], arch_points[i], blue_ink, 1.5)
			if i + 1 < arch_points.size():
				draw_line(arch_upper[i], arch_points[i+1], ink_color, 1.2)
				draw_line(arch_points[i], arch_upper[i+1], ink_color, 1.2)
				
	# Technical dimension tension arrows & callouts
	# Tension vector at top of arch
	draw_line(Vector2(0, -68), Vector2(0, -100), red_accent, 2.5)
	draw_line(Vector2(0, -100), Vector2(-8, -92), red_accent, 2.5)
	draw_line(Vector2(0, -100), Vector2(8, -92), red_accent, 2.5)
	
	# Annotations
	var font = ThemeDB.fallback_font
	if font:
		draw_string(font, Vector2(-15, -105), "T = 42,800 kN", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, red_accent)
		draw_string(font, Vector2(-w * 0.5 + 20, -h * 0.5 + 30), "VICTORIAN TRUSS SPEC No. 1884-B", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, blue_ink)
		draw_string(font, Vector2(-w * 0.5 + 20, -h * 0.5 + 50), "[EXACT STRUCTURAL TENSION ANALYSIS]", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, ink_color)
		
		# Funny stamp & browser research tabs
		draw_string(font, Vector2(60, -h * 0.5 + 32), "* 6 HOURS SPENT RESEARCHING *", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, red_accent)
		draw_string(font, Vector2(100, 115), "SCREEN TIME: 0.50 SECONDS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, red_accent)
		draw_string(font, Vector2(-210, 115), "VERIFIED: 100% ARCHITECTURALLY SOUND", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, blue_ink)
		
		# Cluttered engineering research tabs across top
		draw_rect(Rect2(Vector2(-230, -h * 0.5 - 24), Vector2(140, 22)), Color(0.9, 0.92, 0.96, 0.9), true)
		draw_rect(Rect2(Vector2(-230, -h * 0.5 - 24), Vector2(140, 22)), ink_color, false, 1.5)
		draw_string(font, Vector2(-225, -h * 0.5 - 8), "Tab 1: 1884 Bridge Specs", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, ink_color)
		
		draw_rect(Rect2(Vector2(-80, -h * 0.5 - 24), Vector2(150, 22)), Color(0.9, 0.92, 0.96, 0.9), true)
		draw_rect(Rect2(Vector2(-80, -h * 0.5 - 24), Vector2(150, 22)), ink_color, false, 1.5)
		draw_string(font, Vector2(-75, -h * 0.5 - 8), "Tab 2: Wrought Iron Yield", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, ink_color)
		
		draw_rect(Rect2(Vector2(80, -h * 0.5 - 24), Vector2(140, 22)), Color(0.9, 0.92, 0.96, 0.9), true)
		draw_rect(Rect2(Vector2(80, -h * 0.5 - 24), Vector2(140, 22)), ink_color, false, 1.5)
		draw_string(font, Vector2(85, -h * 0.5 - 8), "Tab 3: Rivet Dynamics", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, ink_color)
		
		# Sticky note formulas
		draw_string(font, Vector2(-220, 60), "Σ F_y = 0", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, blue_ink)
		draw_string(font, Vector2(-220, 75), "σ_max = 142 MPa", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, blue_ink)
