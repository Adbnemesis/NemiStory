class_name NemiLegPart
extends NemiPart

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")

## Renders Nemi's leg components (Thigh, Shin, Foot) with hidden overlapping joints:
## - Thigh pivot = Hip (0, 0)
## - Shin pivot = Knee (0, 0)
## - Foot pivot = Ankle (0, 0)

enum LegType {
	THIGH,
	SHIN,
	FOOT
}

@export var leg_type: LegType = LegType.THIGH
@export var is_left: bool = true

func _draw() -> void:
	if not style:
		return
	
	match leg_type:
		LegType.THIGH:
			_draw_thigh()
		LegType.SHIN:
			_draw_shin()
		LegType.FOOT:
			_draw_foot()

func _draw_thigh() -> void:
	var poly := NemiGeometry.get_thigh_polygon(is_left)
	if poly.size() < 3:
		return
	
	# Skin fill
	draw_colored_polygon(poly, style.skin_color)
	
	# Side contours only (no hip or knee cross-lines!)
	var contours := NemiGeometry.get_thigh_contours(is_left)
	for c in contours:
		var c_stroke := InkStroke.from_points(c, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		c_stroke.draw_to(self)

func _draw_shin() -> void:
	var poly := NemiGeometry.get_shin_polygon(is_left)
	var sock_poly := NemiGeometry.get_sock_polygon()
	if poly.size() < 3:
		return
	
	# 1. Shin skin fill
	draw_colored_polygon(poly, style.skin_color)
	
	# 2. Ribbed crew sock
	if sock_poly.size() >= 3:
		draw_colored_polygon(sock_poly, style.sock_color)
		
		# Top sock cuff line
		var cuff_top := PackedVector2Array([Vector2(-7.5, 54), Vector2(7.5, 54)])
		var ct_stroke := InkStroke.from_points(cuff_top, style.inner_line_width, InkStroke.Profile.DELICATE_CREASE, style.ink_line_color)
		ct_stroke.draw_to(self)
	
	# Side contours only
	var contours := NemiGeometry.get_shin_contours(is_left)
	for c in contours:
		var c_stroke := InkStroke.from_points(c, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		c_stroke.draw_to(self)

func _draw_foot() -> void:
	var sneaker_poly := NemiGeometry.get_sneaker_polygon(is_left)
	var sole_poly := NemiGeometry.get_sneaker_sole_polygon(is_left)
	var trim_poly := NemiGeometry.get_sneaker_trim_polygon(is_left)
	if sneaker_poly.size() < 3:
		return
	
	# 1. Sneaker body
	draw_colored_polygon(sneaker_poly, style.shoe_base_color)
	
	# 2. Green accent wave
	if trim_poly.size() >= 3:
		draw_colored_polygon(trim_poly, style.shoe_trim_color)
		var trim_out := InkStroke.from_points(trim_poly + PackedVector2Array([trim_poly[0]]), style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		trim_out.draw_to(self)
	
	# 3. Chunky platform sole
	if sole_poly.size() >= 3:
		draw_colored_polygon(sole_poly, style.shoe_sole_color)
		var sole_out := InkStroke.from_points(sole_poly + PackedVector2Array([sole_poly[0]]), style.inner_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		sole_out.draw_to(self)
		
		# Bottom dark tread layer
		var sign_x := -1.0 if is_left else 1.0
		var tread_pts := PackedVector2Array([
			Vector2(-sign_x * 14, 25), Vector2(sign_x * 19, 25),
			Vector2(sign_x * 19, 27), Vector2(-sign_x * 14, 27)
		])
		draw_colored_polygon(tread_pts, style.shoe_tread_color)
	
	# 4. Toe cap & laces
	var sign_x := -1.0 if is_left else 1.0
	var lace1 := PackedVector2Array([Vector2(-sign_x * 4, 4), Vector2(sign_x * 4, 8)])
	var lace2 := PackedVector2Array([Vector2(-sign_x * 3, 10), Vector2(sign_x * 5, 14)])
	var l1_s := InkStroke.from_points(lace1, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	var l2_s := InkStroke.from_points(lace2, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	l1_s.draw_to(self)
	l2_s.draw_to(self)
	
	# 5. Sneaker main perimeter
	var outline := InkStroke.from_points(sneaker_poly + PackedVector2Array([sneaker_poly[0]]), style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	outline.draw_to(self)
