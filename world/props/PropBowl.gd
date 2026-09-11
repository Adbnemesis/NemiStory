class_name PropBowl
extends "res://world/props/NemiProp.gd"

## Illustrated Ceramic Bowl Prop
## Deep ceramic bowl with steam plumes rising from hot soup or cereal.

func _init() -> void:
	prop_name = "bowl"
	current_state = "normal"

func _draw() -> void:
	var w := 32.0
	var h := 18.0
	
	# Bowl body (curved half-ellipse)
	var body_pts := PackedVector2Array([
		Vector2(-w * 0.5, -4.0),
		Vector2(-w * 0.45, h * 0.5),
		Vector2(-w * 0.2, h),
		Vector2(w * 0.2, h),
		Vector2(w * 0.45, h * 0.5),
		Vector2(w * 0.5, -4.0)
	])
	draw_illustrated_polygon(body_pts, Color("#eedcc9") if (not style or style.is_color()) else Color("#dddddd"), style.outer_contour_width)
	
	# Bowl top opening rim (ellipse)
	var rim_pts := PackedVector2Array()
	var steps := 16
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		rim_pts.append(Vector2(cos(ang) * (w * 0.5), sin(ang) * 5.0 - 4.0))
	draw_illustrated_polygon(rim_pts, Color("#ffffff"), style.structural_width)
	
	# Soup soup fill inside rim
	var soup_pts := PackedVector2Array()
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		soup_pts.append(Vector2(cos(ang) * (w * 0.42), sin(ang) * 4.0 - 3.5))
	draw_colored_polygon(soup_pts, Color("#d99b66"))
	
	# Steam wisps rising
	var s1 := PackedVector2Array([Vector2(-4.0, -10.0), Vector2(-2.0, -18.0), Vector2(-5.0, -25.0)])
	var s2 := PackedVector2Array([Vector2(4.0, -9.0), Vector2(6.0, -17.0), Vector2(3.0, -26.0)])
	draw_ink_line(s1, 1.4)
	draw_ink_line(s2, 1.4)
