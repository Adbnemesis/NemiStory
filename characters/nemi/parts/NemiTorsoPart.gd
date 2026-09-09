class_name NemiTorsoPart
extends NemiPart

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")

## Renders Nemi's oversized sage green hoodie.
## Pivot is at hip (0, 0).
## Includes kangaroo pouch, layered cowl collar, hem ribbing, and drawstrings.

func _draw() -> void:
	if not style:
		return
	
	var torso_poly := NemiGeometry.get_hoodie_torso_polygon()
	var pouch_poly := NemiGeometry.get_hoodie_pouch_polygon()
	var collar_poly := NemiGeometry.get_hoodie_collar_polygon()
	var hem_line := NemiGeometry.get_hoodie_hem_line()
	var drawstrings := NemiGeometry.get_drawstrings()
	
	# 1. Main hoodie torso fill
	draw_colored_polygon(torso_poly, style.hoodie_color)
	
	# 2. Kangaroo pouch
	draw_colored_polygon(pouch_poly, style.hoodie_color)
	var welts := NemiGeometry.get_hoodie_pouch_welts()
	for w in welts:
		var w_stroke := InkStroke.from_points(w, style.inner_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		w_stroke.draw_to(self)
	
	# 3. Ribbed hem band line
	var hem_stroke := InkStroke.from_points(hem_line, style.inner_line_width, InkStroke.Profile.DELICATE_CREASE, style.ink_line_color)
	hem_stroke.draw_to(self)
	
	# 4. Organic clothing drape crease lines
	var crease_left := PackedVector2Array([Vector2(-43, -38), Vector2(-35, -24), Vector2(-38, -10)])
	var crease_right := PackedVector2Array([Vector2(43, -38), Vector2(35, -24), Vector2(38, -10)])
	var c_l_stroke := InkStroke.from_points(crease_left, style.inner_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	var c_r_stroke := InkStroke.from_points(crease_right, style.inner_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	c_l_stroke.draw_to(self)
	c_r_stroke.draw_to(self)
	
	# 5. Selective outer torso contours (left & right sides only, no top neck line!)
	var left_contour := NemiGeometry.get_hoodie_left_contour()
	var right_contour := NemiGeometry.get_hoodie_right_contour()
	var l_stroke := InkStroke.from_points(left_contour, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	var r_stroke := InkStroke.from_points(right_contour, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	l_stroke.draw_to(self)
	r_stroke.draw_to(self)
	
	# 6. Layered hood cowl collar around neck
	draw_colored_polygon(collar_poly, style.hoodie_color)
	var collar_outer := NemiGeometry.get_hoodie_collar_outer_stroke()
	var collar_front := NemiGeometry.get_hoodie_collar_front_stroke()
	var co_stroke := InkStroke.from_points(collar_outer, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	var cf_stroke := InkStroke.from_points(collar_front, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	co_stroke.draw_to(self)
	cf_stroke.draw_to(self)
	
	# 7. Drawstrings hanging from collar
	for string_path in drawstrings:
		var cord_stroke := InkStroke.from_points(string_path, 2.4, InkStroke.Profile.UNIFORM, style.hoodie_drawstring_color)
		cord_stroke.draw_to(self)
		var cord_ink := InkStroke.from_points(string_path, style.detail_line_width, InkStroke.Profile.UNIFORM, style.ink_line_color)
		cord_ink.draw_to(self)
		
		# Neat cream aglet tip with delicate contour
		var tip: Vector2 = string_path[string_path.size() - 1]
		var aglet_pts := PackedVector2Array([
			tip + Vector2(-1.4, -2.5),
			tip + Vector2(1.4, -2.5),
			tip + Vector2(1.4, 2.5),
			tip + Vector2(-1.4, 2.5)
		])
		draw_colored_polygon(aglet_pts, style.hoodie_drawstring_color)
		var aglet_stroke := InkStroke.from_points(aglet_pts + PackedVector2Array([aglet_pts[0]]), style.detail_line_width, InkStroke.Profile.UNIFORM, style.ink_line_color)
		aglet_stroke.draw_to(self)
