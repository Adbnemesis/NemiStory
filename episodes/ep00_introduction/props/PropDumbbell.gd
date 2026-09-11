class_name PropDumbbell
extends Node2D

## Illustrated 15kg Gym Dumbbell Prop for Beat 4
## Hand-drawn hexagonal/round plates with knurled chrome handle.
## Supports drop_in() animation with ground thud bounce.

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")

var style: RefCounted = WorldStyleScript.new()

func _ready() -> void:
	z_index = 22

func set_style(p_style: RefCounted) -> void:
	style = p_style
	queue_redraw()

func drop_in(target_y: float = 580.0, duration: float = 0.28) -> Signal:
	position.y = target_y - 280.0
	modulate.a = 0.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "position:y", target_y, duration)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, duration * 0.4)
	return tw.finished

func _draw() -> void:
	var ink_col: Color = Color("#2b111e") if (not style or style.is_color()) else Color("#1a1a1a")
	var plate_col: Color = Color("#2f333a") if (not style or style.is_color()) else Color("#303030")
	var bar_col: Color = Color("#8a93a0") if (not style or style.is_color()) else Color("#777777")
	
	# Horizontal dumbbell on floor
	# Center bar
	var bar_rect := Rect2(Vector2(-35, -5), Vector2(70, 10))
	draw_rect(bar_rect, bar_col)
	_draw_line_stroke(Vector2(-35, -5), Vector2(35, -5), 2.0, ink_col)
	_draw_line_stroke(Vector2(-35, 5), Vector2(35, 5), 2.0, ink_col)
	
	# Left inner plate
	var p_left1 := PackedVector2Array([
		Vector2(-35, -28), Vector2(-25, -28), Vector2(-25, 28), Vector2(-35, 28)
	])
	draw_colored_polygon(p_left1, plate_col)
	_draw_poly_stroke(p_left1, 2.2, ink_col)
	
	# Left outer plate
	var p_left2 := PackedVector2Array([
		Vector2(-48, -25), Vector2(-37, -25), Vector2(-37, 25), Vector2(-48, 25)
	])
	draw_colored_polygon(p_left2, plate_col * 0.9)
	_draw_poly_stroke(p_left2, 2.0, ink_col)
	
	# Right inner plate
	var p_right1 := PackedVector2Array([
		Vector2(25, -28), Vector2(35, -28), Vector2(35, 28), Vector2(25, 28)
	])
	draw_colored_polygon(p_right1, plate_col)
	_draw_poly_stroke(p_right1, 2.2, ink_col)
	
	# Right outer plate
	var p_right2 := PackedVector2Array([
		Vector2(37, -25), Vector2(48, -25), Vector2(48, 25), Vector2(37, 25)
	])
	draw_colored_polygon(p_right2, plate_col * 0.9)
	_draw_poly_stroke(p_right2, 2.0, ink_col)
	
	# Impact dust puffs on floor
	_draw_line_stroke(Vector2(-55, 26), Vector2(-65, 22), 1.6, Color(ink_col.r, ink_col.g, ink_col.b, 0.5))
	_draw_line_stroke(Vector2(55, 26), Vector2(65, 22), 1.6, Color(ink_col.r, ink_col.g, ink_col.b, 0.5))

func _draw_line_stroke(p1: Vector2, p2: Vector2, width: float, col: Color) -> void:
	InkStroke.from_points(PackedVector2Array([p1, p2]), width, InkStroke.Profile.TAPER_BOTH, col).draw_to(self)

func _draw_poly_stroke(pts: PackedVector2Array, width: float, col: Color) -> void:
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, col, width)
