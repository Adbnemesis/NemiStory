class_name NemiBagPart
extends NemiPart

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")

## Renders Nemi's dark crossbody shoulder bag and strap with gold leaf emblem.
## Pivot is at hip (0, 0) in TorsoBone coordinates.

@export var draw_strap: bool = true
@export var draw_bag: bool = true

func _draw() -> void:
	if not style:
		return
	
	if draw_strap:
		var strap_poly := NemiGeometry.get_bag_strap_polygon()
		if strap_poly.size() >= 3:
			draw_colored_polygon(strap_poly, style.bag_strap_color)
			# Draw strap side lines only
			var s_left := PackedVector2Array([strap_poly[0], strap_poly[3]])
			var s_right := PackedVector2Array([strap_poly[1], strap_poly[2]])
			var sl_stroke := InkStroke.from_points(s_left, style.inner_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
			var sr_stroke := InkStroke.from_points(s_right, style.inner_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
			sl_stroke.draw_to(self)
			sr_stroke.draw_to(self)
	
	if draw_bag:
		var body_poly := NemiGeometry.get_bag_polygon()
		var flap_poly := NemiGeometry.get_bag_flap_polygon()
		var leaf_poly := NemiGeometry.get_bag_leaf_polygon()
		
		# 1. Draw bag body
		if body_poly.size() >= 3:
			draw_colored_polygon(body_poly, style.bag_body_color)
			var body_out := InkStroke.from_points(body_poly + PackedVector2Array([body_poly[0]]), style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
			body_out.draw_to(self)
		
		# 2. Draw flap
		if flap_poly.size() >= 3:
			draw_colored_polygon(flap_poly, style.bag_body_color)
			var flap_out := InkStroke.from_points(flap_poly + PackedVector2Array([flap_poly[0]]), style.inner_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
			flap_out.draw_to(self)
		
		# 3. Signature gold badge
		if leaf_poly.size() >= 3:
			draw_colored_polygon(leaf_poly, style.bag_badge_color)
			var leaf_out := InkStroke.from_points(leaf_poly + PackedVector2Array([leaf_poly[0]]), style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
			leaf_out.draw_to(self)
