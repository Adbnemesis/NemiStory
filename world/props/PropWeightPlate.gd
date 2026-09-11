class_name PropWeightPlate
extends "res://world/props/NemiProp.gd"

## Illustrated 20kg Iron Olympic Plate Prop
## Heavy circular weight plate with center hole and raised grip rim.

func _init() -> void:
	prop_name = "weight_plate"
	current_state = "normal"

func _draw() -> void:
	var r := 26.0
	var plate_col := Color("#2c2834") if (not style or style.is_color()) else Color("#303030")
	
	# Outer plate circle
	var outer_pts := PackedVector2Array()
	var steps := 20
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		outer_pts.append(Vector2(cos(ang) * r, sin(ang) * r))
	draw_illustrated_polygon(outer_pts, plate_col, style.outer_contour_width)
	
	# Inner inset rim circle
	var inner_r := r - 6.0
	var inner_pts := PackedVector2Array()
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		inner_pts.append(Vector2(cos(ang) * inner_r, sin(ang) * inner_r))
	draw_ink_line(inner_pts, style.structural_width)
	
	# Center barbell sleeve hole
	var hole_r := 5.0
	var hole_pts := PackedVector2Array()
	for i in range(12 + 1):
		var ang := (float(i) / 12.0) * TAU
		hole_pts.append(Vector2(cos(ang) * hole_r, sin(ang) * hole_r))
	draw_colored_polygon(hole_pts, style.paper_bg_color)
	draw_ink_line(hole_pts, style.structural_width)
	
	# Embossed "20" label
	draw_ink_line(PackedVector2Array([Vector2(-4.0, -14.0), Vector2(4.0, -14.0)]), 1.5)
	draw_ink_line(PackedVector2Array([Vector2(-4.0, 14.0), Vector2(4.0, 14.0)]), 1.5)
