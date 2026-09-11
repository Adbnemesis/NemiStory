class_name PropMouse
extends "res://world/props/NemiProp.gd"

## Illustrated Ergonomic Computer Mouse Prop
## Sleek oval mouse with split click buttons and scroll wheel.

func _init() -> void:
	prop_name = "mouse"
	current_state = "normal"

func _draw() -> void:
	var rx := 8.0
	var ry := 14.0
	
	# Oval mouse body
	var body_pts := PackedVector2Array()
	var steps := 16
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		body_pts.append(Vector2(cos(ang) * rx, sin(ang) * ry))
	draw_illustrated_polygon(body_pts, style.metal_slate, style.outer_contour_width)
	
	# Button split center seam
	draw_ink_line(PackedVector2Array([Vector2(0.0, -ry), Vector2(0.0, -ry * 0.25)]), 1.4)
	
	# Horizontal separation seam
	draw_ink_line(PackedVector2Array([Vector2(-rx * 0.85, -ry * 0.25), Vector2(rx * 0.85, -ry * 0.25)]), 1.2)
	
	# Scroll wheel pill
	var wheel_pts := PackedVector2Array([
		Vector2(-1.2, -ry * 0.75), Vector2(1.2, -ry * 0.75),
		Vector2(1.2, -ry * 0.35), Vector2(-1.2, -ry * 0.35)
	])
	draw_colored_polygon(wheel_pts, style.ink_line_color)
