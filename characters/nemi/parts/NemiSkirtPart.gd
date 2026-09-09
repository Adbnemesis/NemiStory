class_name NemiSkirtPart
extends NemiPart

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")

## Renders Nemi's dark forest green pleated tennis skirt.
## Pivot is at waist (0, 0).
## Includes waistband seam, stepped knife pleats, and clean radiating ink lines.

func _draw() -> void:
	if not style:
		return
	
	var skirt_poly := NemiGeometry.get_skirt_polygon()
	var pleats := NemiGeometry.get_skirt_pleat_lines()
	
	# 1. Main skirt base fill
	draw_colored_polygon(skirt_poly, style.skirt_color)
	
	# 2. Alternating knife pleat shadow facets for authentic depth
	var shadow_facets := NemiGeometry.get_skirt_shadow_facets()
	for facet in shadow_facets:
		draw_colored_polygon(facet, style.skirt_shadow_color)
	
	# 3. Radiating pleat crease lines (clean, crisp, hand-drawn)
	for pleat in pleats:
		var pleat_stroke := InkStroke.from_points(pleat, style.inner_line_width, InkStroke.Profile.TAPER_START, style.ink_line_color)
		pleat_stroke.draw_to(self)
	
	# 3. Waistband seam line
	var waistband_line := PackedVector2Array([
		Vector2(-33, 0), Vector2(-15, 2), Vector2(0, 3), Vector2(15, 2), Vector2(33, 0)
	])
	var wb_stroke := InkStroke.from_points(waistband_line, style.inner_line_width, InkStroke.Profile.DELICATE_CREASE, style.ink_line_color)
	wb_stroke.draw_to(self)
	
	# 4. Selective outer contours (left, right, and bottom hem — no top waistband box line!)
	var left_contour := NemiGeometry.get_skirt_left_contour()
	var right_contour := NemiGeometry.get_skirt_right_contour()
	var bottom_hem := NemiGeometry.get_skirt_bottom_hem()
	
	var l_stroke := InkStroke.from_points(left_contour, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	var r_stroke := InkStroke.from_points(right_contour, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	var b_stroke := InkStroke.from_points(bottom_hem, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	
	l_stroke.draw_to(self)
	r_stroke.draw_to(self)
	b_stroke.draw_to(self)
