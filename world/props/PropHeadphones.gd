class_name PropHeadphones
extends "res://world/props/NemiProp.gd"

## Illustrated Studio Headphones Prop
## Over-ear cushioned headphones with headband arc and circular earcups.

func _init() -> void:
	prop_name = "headphones"
	current_state = "normal"

func _draw() -> void:
	var r := 22.0
	
	# 1. Headband Arch
	var arc_pts := PackedVector2Array()
	var steps := 12
	for i in range(steps + 1):
		var ang := PI + (float(i) / float(steps)) * PI
		arc_pts.append(Vector2(cos(ang) * r, sin(ang) * (r * 0.8) - 2.0))
	
	# Draw thick padded headband
	draw_ink_line(arc_pts, style.outer_contour_width * 1.5)
	
	# 2. Earcups (Left & Right)
	var earcup_col: Color = Color("#322f3b") if (not style or style.is_color()) else Color("#222222")
	var cushion_col: Color = Color("#504b5c") if (not style or style.is_color()) else Color("#444444")
	
	# Left Earcup
	var left_pos := Vector2(-r - 1.0, -2.0)
	var left_cup := PackedVector2Array([
		left_pos + Vector2(-4.0, -10.0),
		left_pos + Vector2(2.0, -8.0),
		left_pos + Vector2(2.0, 8.0),
		left_pos + Vector2(-4.0, 10.0)
	])
	draw_illustrated_polygon(left_cup, earcup_col, style.structural_width)
	var left_cushion := PackedVector2Array([
		left_pos + Vector2(2.0, -8.0),
		left_pos + Vector2(6.0, -7.0),
		left_pos + Vector2(6.0, 7.0),
		left_pos + Vector2(2.0, 8.0)
	])
	draw_illustrated_polygon(left_cushion, cushion_col, style.detail_line_width)
	
	# Right Earcup
	var right_pos := Vector2(r + 1.0, -2.0)
	var right_cup := PackedVector2Array([
		right_pos + Vector2(-2.0, -8.0),
		right_pos + Vector2(4.0, -10.0),
		right_pos + Vector2(4.0, 10.0),
		right_pos + Vector2(-2.0, 8.0)
	])
	draw_illustrated_polygon(right_cup, earcup_col, style.structural_width)
	var right_cushion := PackedVector2Array([
		right_pos + Vector2(-6.0, -7.0),
		right_pos + Vector2(-2.0, -8.0),
		right_pos + Vector2(-2.0, 8.0),
		right_pos + Vector2(-6.0, 7.0)
	])
	draw_illustrated_polygon(right_cushion, cushion_col, style.detail_line_width)
