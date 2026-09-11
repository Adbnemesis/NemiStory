class_name PropSteeringWheel
extends Node2D

## Illustrated Car Steering Wheel Doodle for Beat 4
## Hand-drawn minimalist comic steering wheel with column and hands.

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
	var wheel_col: Color = Color("#424750") if (not style or style.is_color()) else Color("#333333")
	
	# Circular rim (angled slightly back, elliptical)
	var center := Vector2(0, 0)
	var rx := 65.0
	var ry := 45.0
	var steps := 24
	var rim_outer := PackedVector2Array()
	var rim_inner := PackedVector2Array()
	
	for i in range(steps):
		var a := float(i) * TAU / float(steps)
		rim_outer.append(center + Vector2(cos(a) * rx, sin(a) * ry))
		rim_inner.append(center + Vector2(cos(a) * (rx - 8.0), sin(a) * (ry - 6.0)))
	
	draw_colored_polygon(rim_outer, wheel_col)
	draw_colored_polygon(rim_inner, Color(0, 0, 0, 0)) # Hollow center
	
	var rim_stroke := rim_outer.duplicate()
	rim_stroke.append(rim_outer[0])
	draw_polyline(rim_stroke, ink_col, 2.5)
	
	var inner_stroke := rim_inner.duplicate()
	inner_stroke.append(rim_inner[0])
	draw_polyline(inner_stroke, ink_col, 1.8)
	
	# 3 Spokes
	_draw_line_stroke(Vector2(-rx * 0.7, 0), Vector2(-15, 5), 3.0, ink_col)
	_draw_line_stroke(Vector2(rx * 0.7, 0), Vector2(15, 5), 3.0, ink_col)
	_draw_line_stroke(Vector2(0, ry * 0.8), Vector2(0, 15), 3.0, ink_col)
	
	# Center horn cap
	draw_circle(Vector2(0, 8), 16.0, wheel_col)
	draw_arc(Vector2(0, 8), 16.0, 0, TAU, 16, ink_col, 2.2)
	
	# Speed / vibration music notes near wheel
	_draw_line_stroke(Vector2(-75, -25), Vector2(-85, -35), 1.6, ink_col)
	_draw_line_stroke(Vector2(75, -25), Vector2(85, -35), 1.6, ink_col)

func _draw_line_stroke(p1: Vector2, p2: Vector2, width: float, col: Color) -> void:
	InkStroke.from_points(PackedVector2Array([p1, p2]), width, InkStroke.Profile.TAPER_BOTH, col).draw_to(self)
