class_name NemiHeadPart
extends NemiPart

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")

## Renders Nemi's soft anime face base, cute ear lobes, and calligraphic jawline.
## Pivot is at chin (0, 0).

func _draw() -> void:
	if not style:
		return
	
	# 1. Ears (skin fill, outer lobe contour, inner crease)
	var left_ear := NemiGeometry.get_ear_polygon(true)
	var right_ear := NemiGeometry.get_ear_polygon(false)
	draw_colored_polygon(left_ear, style.skin_color)
	draw_colored_polygon(right_ear, style.skin_color)
	
	var left_ear_stroke := InkStroke.from_points(left_ear, style.silhouette_detail_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	var right_ear_stroke := InkStroke.from_points(right_ear, style.silhouette_detail_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	left_ear_stroke.draw_to(self)
	right_ear_stroke.draw_to(self)
	
	var left_crease := NemiGeometry.get_ear_crease(true)
	var right_crease := NemiGeometry.get_ear_crease(false)
	var l_c_stroke := InkStroke.from_points(left_crease, style.detail_line_width, InkStroke.Profile.DELICATE_CREASE, style.ink_line_color)
	var r_c_stroke := InkStroke.from_points(right_crease, style.detail_line_width, InkStroke.Profile.DELICATE_CREASE, style.ink_line_color)
	l_c_stroke.draw_to(self)
	r_c_stroke.draw_to(self)
	
	# 2. Head base fill (smooth skull dome under hair)
	var head_poly := NemiGeometry.get_head_base_polygon()
	draw_colored_polygon(head_poly, style.skin_color)
	
	# 3. Calligraphic jawline contour with tapered ends at temples
	var jaw_line := NemiGeometry.get_jaw_outline()
	var jaw_stroke := InkStroke.from_points(jaw_line, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	jaw_stroke.draw_to(self)
