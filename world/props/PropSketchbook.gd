class_name PropSketchbook
extends "res://world/props/NemiProp.gd"

## Illustrated Open Sketchbook Prop
## Open landscape artist sketchbook with center seam and character construction doodles.

func _init() -> void:
	prop_name = "sketchbook"
	current_state = "open"

func _draw() -> void:
	var pw := 36.0
	var ph := 48.0
	
	# Left page
	var left_page := PackedVector2Array([
		Vector2(-pw, -ph * 0.5),
		Vector2(-1.0, -ph * 0.5 + 2.0),
		Vector2(-1.0, ph * 0.5 - 2.0),
		Vector2(-pw, ph * 0.5)
	])
	draw_illustrated_polygon(left_page, style.paper_bg_color, style.outer_contour_width)
	
	# Right page
	var right_page := PackedVector2Array([
		Vector2(1.0, -ph * 0.5 + 2.0),
		Vector2(pw, -ph * 0.5),
		Vector2(pw, ph * 0.5),
		Vector2(1.0, ph * 0.5 - 2.0)
	])
	draw_illustrated_polygon(right_page, style.paper_bg_color, style.outer_contour_width)
	
	# Center binding crease
	draw_ink_line(PackedVector2Array([Vector2(0.0, -ph * 0.5 + 2.0), Vector2(0.0, ph * 0.5 - 2.0)]), 2.2)
	
	# Left page doodles (head circle + cross guidelines)
	var center_l := Vector2(-pw * 0.5, -4.0)
	var head_pts := PackedVector2Array()
	for i in range(13):
		var a := (float(i) / 12.0) * TAU
		head_pts.append(center_l + Vector2(cos(a) * 9.0, sin(a) * 9.0))
	draw_ink_line(head_pts, 1.4)
	draw_ink_line(PackedVector2Array([center_l + Vector2(-9.0, 0.0), center_l + Vector2(9.0, 0.0)]), 1.1)
	draw_ink_line(PackedVector2Array([center_l + Vector2(0.0, -9.0), center_l + Vector2(0.0, 9.0)]), 1.1)
	
	# Right page sketch notes
	draw_ink_line(PackedVector2Array([Vector2(8.0, -14.0), Vector2(28.0, -14.0)]), 1.2)
	draw_ink_line(PackedVector2Array([Vector2(8.0, -8.0), Vector2(24.0, -8.0)]), 1.2)
	draw_ink_line(PackedVector2Array([Vector2(8.0, 4.0), Vector2(26.0, 4.0)]), 1.2)
	draw_ink_line(PackedVector2Array([Vector2(8.0, 10.0), Vector2(20.0, 10.0)]), 1.2)
