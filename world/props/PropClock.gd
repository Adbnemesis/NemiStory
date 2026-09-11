class_name PropClock
extends "res://world/props/NemiProp.gd"

## Illustrated Analog Wall Clock Prop
## Circular clock face with 12 hour ticks and hands pointing to late night hours.

func _init() -> void:
	prop_name = "clock"
	current_state = "normal"

func _draw() -> void:
	var r := 24.0
	
	# Outer clock casing
	var outer_pts := PackedVector2Array()
	var steps := 24
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		outer_pts.append(Vector2(cos(ang) * r, sin(ang) * r))
	draw_illustrated_polygon(outer_pts, Color("#ffffff"), style.outer_contour_width)
	
	# 12 Hour tick marks
	for i in range(12):
		var ang := (float(i) / 12.0) * TAU
		var p1 := Vector2(cos(ang) * (r - 2.0), sin(ang) * (r - 2.0))
		var p2 := Vector2(cos(ang) * (r - 5.0), sin(ang) * (r - 5.0))
		draw_ink_line(PackedVector2Array([p1, p2]), 1.8 if (i % 3 == 0) else 1.1)
	
	# Hour hand (pointing to 3 AM)
	draw_ink_line(PackedVector2Array([Vector2.ZERO, Vector2(11.0, 2.0)]), 2.4)
	
	# Minute hand (pointing to 12)
	draw_ink_line(PackedVector2Array([Vector2.ZERO, Vector2(0.0, -16.0)]), 1.8)
	
	# Center axle pin
	var center_pts := PackedVector2Array()
	for i in range(9):
		var a := (float(i) / 8.0) * TAU
		center_pts.append(Vector2(cos(a) * 2.0, sin(a) * 2.0))
	draw_colored_polygon(center_pts, style.ink_line_color)
