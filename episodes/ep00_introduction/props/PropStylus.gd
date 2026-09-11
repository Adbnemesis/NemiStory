class_name PropStylus
extends Node2D

## Illustrated Digital Drawing Stylus Prop for Beat 3
## Hand-drawn vector stylus with nib, grip band, rocker button, and eraser end.

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")

var style: RefCounted = WorldStyleScript.new()

func _ready() -> void:
	z_index = 25

func set_style(p_style: RefCounted) -> void:
	style = p_style
	queue_redraw()

func pop_in(duration: float = 0.2) -> Signal:
	scale = Vector2.ZERO
	modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, duration * 0.7)
	return tw.finished

func _draw() -> void:
	var ink_col: Color = Color("#2b111e") if (not style or style.is_color()) else Color("#1a1a1a")
	var body_col: Color = Color("#383d44") if (not style or style.is_color()) else Color("#303030")
	var grip_col: Color = Color("#22252a") if (not style or style.is_color()) else Color("#1e1e1e")
	var nib_col: Color = Color("#dfd5c8") if (not style or style.is_color()) else Color("#888888")
	var accent_col: Color = Color("#753239") if (not style or style.is_color()) else Color("#555555")
	
	# Pen tilted at 45 degrees
	# Nib
	var nib_pts := PackedVector2Array([
		Vector2(-20, 20), Vector2(-12, 12), Vector2(-15, 9), Vector2(-23, 17)
	])
	draw_colored_polygon(nib_pts, nib_col)
	_draw_poly_stroke(nib_pts, 1.8, ink_col)
	
	# Grip cone
	var grip_cone := PackedVector2Array([
		Vector2(-12, 12), Vector2(0, 0), Vector2(-4, -4), Vector2(-15, 9)
	])
	draw_colored_polygon(grip_cone, grip_col)
	_draw_poly_stroke(grip_cone, 2.0, ink_col)
	
	# Main shaft
	var shaft := PackedVector2Array([
		Vector2(0, 0), Vector2(40, -40), Vector2(34, -46), Vector2(-4, -4)
	])
	draw_colored_polygon(shaft, body_col)
	_draw_poly_stroke(shaft, 2.2, ink_col)
	
	# Eraser end cap
	var cap := PackedVector2Array([
		Vector2(40, -40), Vector2(46, -46), Vector2(41, -51), Vector2(34, -46)
	])
	draw_colored_polygon(cap, accent_col)
	_draw_poly_stroke(cap, 2.0, ink_col)
	
	# Rocker button on grip
	var btn := PackedVector2Array([
		Vector2(6, -6), Vector2(16, -16), Vector2(14, -18), Vector2(4, -8)
	])
	draw_colored_polygon(btn, Color("#555c66"))
	_draw_poly_stroke(btn, 1.4, ink_col)

func _draw_poly_stroke(pts: PackedVector2Array, width: float, col: Color) -> void:
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, col, width)
