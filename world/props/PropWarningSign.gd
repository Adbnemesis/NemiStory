class_name PropWarningSign
extends "res://world/props/NemiProp.gd"

## Illustrated Caution Warning Sign Prop
## Yellow hazard triangle with bold exclamation mark and rounded corners.

func _init() -> void:
	prop_name = "warning_sign"
	current_state = "normal"

func _draw() -> void:
	var s := 28.0
	var yellow_col := Color("#f5c442") if (not style or style.is_color()) else Color("#edeae4")
	
	# Triangle hazard shape
	var tri_pts := PackedVector2Array([
		Vector2(0.0, -s * 0.8),
		Vector2(s * 0.866, s * 0.5),
		Vector2(-s * 0.866, s * 0.5)
	])
	draw_illustrated_polygon(tri_pts, yellow_col, style.outer_contour_width)
	
	# Inset inner black warning triangle border
	var inner_tri := PackedVector2Array([
		Vector2(0.0, -s * 0.55),
		Vector2(s * 0.65, s * 0.38),
		Vector2(-s * 0.65, s * 0.38)
	])
	var stroke_tri := inner_tri.duplicate()
	stroke_tri.append(inner_tri[0])
	draw_ink_line(stroke_tri, style.structural_width)
	
	# Bold exclamation mark
	draw_ink_line(PackedVector2Array([Vector2(0.0, -s * 0.3), Vector2(0.0, s * 0.05)]), 3.2)
	# Exclamation dot
	var dot_pts := PackedVector2Array()
	for i in range(9):
		var ang := (float(i) / 8.0) * TAU
		dot_pts.append(Vector2(cos(ang) * 1.8, s * 0.22 + sin(ang) * 1.8))
	draw_colored_polygon(dot_pts, style.ink_line_color)
