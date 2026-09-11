extends "res://world/props/NemiProp.gd"

## Illustrated Car Steering Wheel Prop
## Round steering wheel with center horn hub, 3 spokes, and grip texture.

func _init() -> void:
	prop_name = "steering_wheel"
	current_state = "normal"

func _draw() -> void:
	var r := 28.0
	var wheel_col := Color("#35323d") if (not style or style.is_color()) else Color("#222222")
	
	# Outer rim circle
	var outer_pts := PackedVector2Array()
	var steps := 24
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		outer_pts.append(Vector2(cos(ang) * r, sin(ang) * r))
	draw_illustrated_polygon(outer_pts, wheel_col, style.outer_contour_width)
	
	# Inner rim opening
	var inner_r := r - 5.5
	var inner_pts := PackedVector2Array()
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		inner_pts.append(Vector2(cos(ang) * inner_r, sin(ang) * inner_r))
	draw_colored_polygon(inner_pts, style.paper_bg_color)
	draw_ink_line(inner_pts, style.structural_width)
	
	# Center horn hub
	var hub_r := 9.0
	var hub_pts := PackedVector2Array()
	for i in range(16 + 1):
		var ang := (float(i) / 16.0) * TAU
		hub_pts.append(Vector2(cos(ang) * hub_r, sin(ang) * hub_r))
	draw_illustrated_polygon(hub_pts, wheel_col, style.structural_width)
	
	# 3 Spokes (left horizontal, right horizontal, bottom vertical)
	draw_ink_line(PackedVector2Array([Vector2(-inner_r, 0.0), Vector2(-hub_r, 0.0)]), 4.0)
	draw_ink_line(PackedVector2Array([Vector2(inner_r, 0.0), Vector2(hub_r, 0.0)]), 4.0)
	draw_ink_line(PackedVector2Array([Vector2(0.0, inner_r), Vector2(0.0, hub_r)]), 4.0)
