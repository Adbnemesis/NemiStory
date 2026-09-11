class_name PropPlate
extends "res://world/props/NemiProp.gd"

## Illustrated Ceramic Plate Prop
## Shallow ceramic dining plate with wide lip rim and food crumb details.

func _init() -> void:
	prop_name = "plate"
	current_state = "normal"

func _draw() -> void:
	var rx := 26.0
	var ry := 12.0
	
	# Outer plate ellipse
	var outer_pts := PackedVector2Array()
	var steps := 20
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		outer_pts.append(Vector2(cos(ang) * rx, sin(ang) * ry))
	draw_illustrated_polygon(outer_pts, Color("#f2eee6"), style.outer_contour_width)
	
	# Inner rim dip ellipse
	var inner_rx := rx * 0.72
	var inner_ry := ry * 0.72
	var inner_pts := PackedVector2Array()
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		inner_pts.append(Vector2(cos(ang) * inner_rx, sin(ang) * inner_ry + 1.0))
	draw_ink_line(inner_pts, style.detail_line_width)
