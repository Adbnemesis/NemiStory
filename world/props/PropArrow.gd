class_name PropArrow
extends "res://world/props/NemiProp.gd"

## Illustrated Hand-Drawn Directional Arrow Prop
## Expressive curved comic arrow pointing to characters or objects.

func _init() -> void:
	prop_name = "arrow"
	current_state = "normal"

func _draw() -> void:
	var l := 42.0
	var arrow_col := Color("#d94141") if (not style or style.is_color()) else style.ink_line_color
	
	# Curved tail stroke
	var curve_pts := PackedVector2Array([
		Vector2(-l * 0.5, 12.0),
		Vector2(-l * 0.15, -4.0),
		Vector2(l * 0.2, -6.0),
		Vector2(l * 0.5 - 6.0, 0.0)
	])
	draw_ink_line(curve_pts, 3.2)
	
	# Arrow arrowhead pointer
	var head_pts := PackedVector2Array([
		Vector2(l * 0.5 - 10.0, -9.0),
		Vector2(l * 0.5 + 4.0, 0.0),
		Vector2(l * 0.5 - 10.0, 9.0),
		Vector2(l * 0.5 - 6.0, 0.0)
	])
	draw_illustrated_polygon(head_pts, arrow_col, style.structural_width)
