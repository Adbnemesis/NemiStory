class_name PropNotebook
extends "res://world/props/NemiProp.gd"

## Illustrated Spiral Notebook Prop
## Hand-drawn notebook with soft pastel cover, spiral ring binding, and lined pages.

func _init() -> void:
	prop_name = "notebook"
	current_state = "closed"

func _draw() -> void:
	var w := 32.0
	var h := 44.0
	
	# Cover polygon (soft teal / sage)
	var cover_col: Color = Color("#8ea89d") if (not style or style.is_color()) else Color("#e0ded9")
	var cover_pts := PackedVector2Array([
		Vector2(-w * 0.5 + 4.0, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5 + 1.0),
		Vector2(w * 0.5, h * 0.5),
		Vector2(-w * 0.5 + 4.0, h * 0.5 - 1.0)
	])
	draw_illustrated_polygon(cover_pts, cover_col, style.outer_contour_width)
	
	# Page paper edges visible on right
	var page_pts := PackedVector2Array([
		Vector2(w * 0.5 - 2.0, -h * 0.5 + 3.0),
		Vector2(w * 0.5 + 1.5, -h * 0.5 + 3.5),
		Vector2(w * 0.5 + 1.5, h * 0.5 - 3.5),
		Vector2(w * 0.5 - 2.0, h * 0.5 - 3.0)
	])
	draw_colored_polygon(page_pts, style.paper_bg_color)
	draw_ink_line(page_pts, style.detail_line_width)
	
	# Spiral wire rings on left edge
	var num_rings := 7
	var start_y := -h * 0.5 + 5.0
	var step_y := (h - 10.0) / float(num_rings - 1)
	for i in range(num_rings):
		var ry := start_y + float(i) * step_y
		var ring_pts := PackedVector2Array([
			Vector2(-w * 0.5 + 5.0, ry - 1.5),
			Vector2(-w * 0.5 - 1.5, ry - 0.5),
			Vector2(-w * 0.5 - 1.5, ry + 1.5),
			Vector2(-w * 0.5 + 5.0, ry + 2.5)
		])
		draw_ink_line(ring_pts, 1.6)
	
	# Cover label / elastic band
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.2, -4.0), Vector2(w * 0.35, -4.0)]), style.detail_line_width)
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.2, 2.0), Vector2(w * 0.25, 2.0)]), style.detail_line_width)
