class_name NemiNeckPart
extends NemiPart

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")

## Renders Nemi's neck column with chin shadow and collar overlap.
## Pivot is at base of neck (0, 0).

func _draw() -> void:
	if not style:
		return
	
	var neck_poly := NemiGeometry.get_neck_polygon()
	var shadow_poly := NemiGeometry.get_neck_shadow_polygon()
	
	# 1. Neck column fill
	draw_colored_polygon(neck_poly, style.skin_color)
	
	# 2. Cast shadow under chin
	if shadow_poly.size() >= 3:
		draw_colored_polygon(shadow_poly, style.skin_shadow_color)
	
	# 3. Side neck contour lines with subtle taper
	var left_side := PackedVector2Array([neck_poly[0], neck_poly[3]])
	var right_side := PackedVector2Array([neck_poly[1], neck_poly[2]])
	var l_stroke := InkStroke.from_points(left_side, style.inner_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	var r_stroke := InkStroke.from_points(right_side, style.inner_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	l_stroke.draw_to(self)
	r_stroke.draw_to(self)
