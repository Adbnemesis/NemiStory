class_name PropCup
extends "res://world/props/NemiProp.gd"

## Illustrated Coffee Mug / Tea Cup Prop
## Features hand-drawn cylindrical body, curved ear handle, liquid fill,
## and optional steam doodle wisps.

@export var with_steam: bool = true

func _init() -> void:
	prop_name = "cup"
	current_state = "normal"

func _draw() -> void:
	var w := 18.0
	var h := 22.0
	
	# 1. Handle (curved ear on right)
	var handle_pts := PackedVector2Array([
		Vector2(w * 0.45, -h * 0.3),
		Vector2(w * 0.85, -h * 0.25),
		Vector2(w * 0.90, h * 0.2),
		Vector2(w * 0.45, h * 0.25)
	])
	draw_ink_line(handle_pts, style.structural_width)
	
	# 2. Main mug body
	var body_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),           # top-left
		Vector2(w * 0.5, -h * 0.5),            # top-right
		Vector2(w * 0.46, h * 0.45),           # bottom-right
		Vector2(w * 0.40, h * 0.5),
		Vector2(-w * 0.40, h * 0.5),
		Vector2(-w * 0.46, h * 0.45)           # bottom-left
	])
	draw_illustrated_polygon(body_pts, style.metal_light, style.outer_contour_width)
	
	# 3. Top rim & liquid fill
	var rim_rect := Rect2(Vector2(-w * 0.5, -h * 0.5 - 2.0), Vector2(w, 4.0))
	draw_ellipse_rim(rim_rect)
	
	# 4. Steam wisps (hand-drawn curvy lines)
	if with_steam and current_state != "tipped":
		var steam_col := Color(style.ink_line_color.r, style.ink_line_color.g, style.ink_line_color.b, 0.45)
		_draw_steam_wisp(Vector2(-3.0, -h * 0.5 - 6.0), 12.0, steam_col)
		_draw_steam_wisp(Vector2(3.0, -h * 0.5 - 10.0), 15.0, steam_col)

func draw_ellipse_rim(rect: Rect2) -> void:
	var pts := PackedVector2Array()
	var steps := 16
	var center := rect.position + rect.size * 0.5
	var rx := rect.size.x * 0.5
	var ry := rect.size.y * 0.5
	for i in range(steps):
		var a := float(i) * TAU / float(steps)
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	# Liquid fill (coffee brown / dark tea)
	var liquid_col: Color = Color("#4a2c1d") if style.is_color() else style.metal_dark
	draw_colored_polygon(pts, liquid_col)
	var stroke_pts := pts.duplicate(); stroke_pts.append(pts[0])
	draw_ink_line(stroke_pts, style.inner_line_width)

func _draw_steam_wisp(origin: Vector2, height: float, col: Color) -> void:
	var curve := Curve2D.new()
	curve.add_point(origin)
	curve.add_point(origin + Vector2(2.5, -height * 0.5), Vector2(-1.5, 2.0), Vector2(1.5, -2.0))
	curve.add_point(origin + Vector2(-1.5, -height), Vector2(2.0, 3.0), Vector2(-1.0, -2.0))
	var stroke := InkStroke.from_curve(curve, 1.2, InkStroke.Profile.TAPER_BOTH, col)
	stroke.draw_to(self)
