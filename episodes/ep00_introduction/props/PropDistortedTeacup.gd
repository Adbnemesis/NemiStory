class_name PropDistortedTeacup
extends Node2D

## Prop for Beat 1: Distorted hand holding a teacup ("angry ginger root")
## Illustrated on a floating sketchcard with rough ink linework and tape accent.
## Includes hand-drawn callout arrow: "<- Supposed to be holding a teacup"

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")

var style: RefCounted = WorldStyleScript.new()
var show_annotation: bool = true
var show_anger_mark: bool = false

func _ready() -> void:
	z_index = 25 # Above character background, alongside props

func set_style(p_style: RefCounted) -> void:
	style = p_style
	queue_redraw()

func trigger_anger_mark() -> void:
	show_anger_mark = true
	queue_redraw()
	wobble(0.45)

func pop_in(duration: float = 0.25) -> Signal:
	scale = Vector2(0.2, 0.2)
	modulate.a = 0.0
	rotation = deg_to_rad(-8.0)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ONE, duration)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "rotation", 0.0, duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, duration * 0.6)
	return tw.finished

func wobble(duration: float = 0.5) -> Signal:
	var tw := create_tween()
	tw.tween_property(self, "rotation", deg_to_rad(6.0), duration * 0.2)
	tw.tween_property(self, "rotation", deg_to_rad(-6.0), duration * 0.2)
	tw.tween_property(self, "rotation", deg_to_rad(4.0), duration * 0.2)
	tw.tween_property(self, "rotation", deg_to_rad(-3.0), duration * 0.2)
	tw.tween_property(self, "rotation", 0.0, duration * 0.2)
	return tw.finished

func _draw() -> void:
	var ink_col: Color = Color("#2b111e") if (not style or style.is_color()) else Color("#1a1a1a")
	var card_bg: Color = Color("#fbf8f3")
	var tea_col: Color = Color("#753c20") if (not style or style.is_color()) else Color("#3a3a3a")
	var root_col: Color = Color("#dfc08f") if (not style or style.is_color()) else Color("#888888")
	var cup_col: Color = Color("#e8edf2") if (not style or style.is_color()) else Color("#cccccc")
	
	# 1. Sketch Paper Card (slight 4° rotation)
	var card_rect := Rect2(Vector2(-110, -110), Vector2(220, 200))
	draw_rect(card_rect, card_bg)
	
	# Card Border with rough sketchy ink lines
	var p1 := card_rect.position
	var p2 := card_rect.position + Vector2(card_rect.size.x, 0)
	var p3 := card_rect.position + card_rect.size
	var p4 := card_rect.position + Vector2(0, card_rect.size.y)
	
	_draw_line_stroke(p1, p2, 2.5, ink_col)
	_draw_line_stroke(p2, p3, 2.2, ink_col)
	_draw_line_stroke(p3, p4, 2.4, ink_col)
	_draw_line_stroke(p4, p1, 2.3, ink_col)
	
	# Scotch tape on top corner
	var tape_poly := PackedVector2Array([
		Vector2(-40, -122), Vector2(10, -122),
		Vector2(0, -98), Vector2(-50, -98)
	])
	draw_colored_polygon(tape_poly, Color(0.95, 0.92, 0.85, 0.65))
	
	# 2. Deformed Ginger Root Hand (gnarly, bumpy multi-jointed fingers)
	# Palm base
	var palm_pts := PackedVector2Array([
		Vector2(-60, 45), Vector2(-45, 10), Vector2(-15, -10),
		Vector2(20, -5), Vector2(35, 20), Vector2(30, 55),
		Vector2(-10, 60), Vector2(-50, 58)
	])
	draw_colored_polygon(palm_pts, root_col)
	_draw_poly_outline(palm_pts, 2.4, ink_col)
	
	# Bumpy ginger knobs / mutant knuckles
	var finger1 := PackedVector2Array([
		Vector2(-45, 10), Vector2(-65, -15), Vector2(-55, -35),
		Vector2(-35, -28), Vector2(-25, -5)
	])
	draw_colored_polygon(finger1, root_col)
	_draw_poly_outline(finger1, 2.2, ink_col)
	
	var finger2 := PackedVector2Array([
		Vector2(-25, -10), Vector2(-20, -45), Vector2(0, -50),
		Vector2(5, -30), Vector2(0, -5)
	])
	draw_colored_polygon(finger2, root_col)
	_draw_poly_outline(finger2, 2.2, ink_col)
	
	var finger3 := PackedVector2Array([
		Vector2(0, -5), Vector2(25, -38), Vector2(40, -25),
		Vector2(30, 0), Vector2(15, 5)
	])
	draw_colored_polygon(finger3, root_col)
	_draw_poly_outline(finger3, 2.2, ink_col)
	
	var extra_knob := PackedVector2Array([
		Vector2(-65, 30), Vector2(-80, 20), Vector2(-75, 5), Vector2(-55, 15)
	])
	draw_colored_polygon(extra_knob, root_col)
	_draw_poly_outline(extra_knob, 2.0, ink_col)
	
	# Ginger creases & angry wrinkle lines
	_draw_line_stroke(Vector2(-35, 10), Vector2(-20, 25), 1.8, ink_col)
	_draw_line_stroke(Vector2(-10, 5), Vector2(5, 20), 1.8, ink_col)
	_draw_line_stroke(Vector2(-45, -15), Vector2(-38, -5), 1.5, ink_col)
	_draw_line_stroke(Vector2(-15, -30), Vector2(-8, -18), 1.5, ink_col)
	
	# 3. Teacup being crushed / awkwardly held
	var cup_pts := PackedVector2Array([
		Vector2(-15, -15), Vector2(25, -10), Vector2(20, 25),
		Vector2(10, 32), Vector2(-5, 30), Vector2(-12, 22)
	])
	draw_colored_polygon(cup_pts, cup_col)
	_draw_poly_outline(cup_pts, 2.4, ink_col)
	
	# Liquid inside
	var rim_pts := PackedVector2Array([
		Vector2(-13, -13), Vector2(23, -8), Vector2(18, -3), Vector2(-10, -5)
	])
	draw_colored_polygon(rim_pts, tea_col)
	_draw_poly_outline(rim_pts, 1.6, ink_col)
	
	# Crooked handle
	var handle_pts := PackedVector2Array([
		Vector2(23, -5), Vector2(38, 0), Vector2(35, 18), Vector2(18, 18)
	])
	draw_polyline(handle_pts, ink_col, 2.2)
	
	# Squiggly steam
	_draw_line_stroke(Vector2(2, -20), Vector2(6, -35), 1.6, Color(ink_col.r, ink_col.g, ink_col.b, 0.6))
	_draw_line_stroke(Vector2(12, -22), Vector2(8, -38), 1.6, Color(ink_col.r, ink_col.g, ink_col.b, 0.6))
	
	# Small comedic anger stress marks on the ginger root
	if show_anger_mark:
		var c_ang := Vector2(-42, -22)
		var col_red := Color("#d63031") if (not style or style.is_color()) else ink_col
		draw_polyline(PackedVector2Array([c_ang + Vector2(-9, -2), c_ang + Vector2(-3, -3), c_ang + Vector2(-2, -9)]), col_red, 2.4)
		draw_polyline(PackedVector2Array([c_ang + Vector2(2, -9), c_ang + Vector2(3, -3), c_ang + Vector2(9, -2)]), col_red, 2.4)
		draw_polyline(PackedVector2Array([c_ang + Vector2(9, 2), c_ang + Vector2(3, 3), c_ang + Vector2(2, 9)]), col_red, 2.4)
		draw_polyline(PackedVector2Array([c_ang + Vector2(-2, 9), c_ang + Vector2(-3, 3), c_ang + Vector2(-9, 2)]), col_red, 2.4)
	
	# 4. Annotation: Arrow and text "<- Supposed to be holding a teacup"
	if show_annotation:
		var font := ThemeDB.fallback_font
		var arrow_start := Vector2(120, -50)
		var arrow_tip := Vector2(45, -20)
		
		# Curved arrow
		var arrow_pts := PackedVector2Array([
			arrow_start,
			Vector2(85, -55),
			arrow_tip
		])
		draw_polyline(arrow_pts, Color("#992030") if (not style or style.is_color()) else ink_col, 2.4)
		
		# Arrowhead
		var tip_head := PackedVector2Array([
			arrow_tip + Vector2(12, -6),
			arrow_tip,
			arrow_tip + Vector2(6, 12)
		])
		draw_polyline(tip_head, Color("#992030") if (not style or style.is_color()) else ink_col, 2.4)
		
		# Text label
		var text_str := "<- Supposed to be holding a teacup"
		draw_string(font, Vector2(65, -62), text_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#992030") if (not style or style.is_color()) else ink_col)

func _draw_line_stroke(p1: Vector2, p2: Vector2, width: float, col: Color) -> void:
	InkStroke.from_points(PackedVector2Array([p1, p2]), width, InkStroke.Profile.TAPER_BOTH, col).draw_to(self)

func _draw_poly_outline(pts: PackedVector2Array, width: float, col: Color) -> void:
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, col, width)
