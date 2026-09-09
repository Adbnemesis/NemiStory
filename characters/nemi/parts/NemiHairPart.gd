class_name NemiHairPart
extends NemiPart

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")

## Renders Nemi's hair masses following Reference B's organic illustrated style:
## - BACK: Vertical cascading mane behind torso (compact width 102, reaches y = 190)
## - BANGS: Voluminous crown dome + authored layered forehead locks + iconic crown ahoge
## - LEFT_FRONT / RIGHT_FRONT: Flowing wavy tresses draping over shoulders
## All positioned relative to HeadBone origin (Chin at (0, 0)).

enum HairSection {
	BACK,
	BANGS,
	LEFT_FRONT,
	RIGHT_FRONT
}

@export var section: HairSection = HairSection.BACK

func _draw() -> void:
	if not style:
		return
	
	match section:
		HairSection.BACK:
			_draw_back_hair()
		HairSection.BANGS:
			_draw_bangs()
		HairSection.LEFT_FRONT:
			_draw_front_tress(true)
		HairSection.RIGHT_FRONT:
			_draw_front_tress(false)

func _draw_back_hair() -> void:
	var poly := NemiGeometry.get_hair_back_polygon()
	if poly.size() < 3:
		return
	
	# 1. Main organic fill
	draw_colored_polygon(poly, style.hair_color)
	
	# 2. Flowing crease lines (depth and lock separation)
	var creases := NemiGeometry.get_hair_back_creases()
	for crease in creases:
		var crease_stroke := InkStroke.from_points(crease, style.inner_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		crease_stroke.draw_to(self)
	
	# 3. Selective calligraphic silhouettes (no top line behind neck!)
	var left_sil := NemiGeometry.get_hair_back_left_silhouette()
	var right_sil := NemiGeometry.get_hair_back_right_silhouette()
	var bottom_hem := NemiGeometry.get_hair_back_bottom_hem()
	
	var l_stroke := InkStroke.from_points(left_sil, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	var r_stroke := InkStroke.from_points(right_sil, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	var b_stroke := InkStroke.from_points(bottom_hem, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	
	l_stroke.draw_to(self)
	r_stroke.draw_to(self)
	b_stroke.draw_to(self)

func _draw_bangs() -> void:
	var poly := NemiGeometry.get_hair_bangs_polygon()
	if poly.size() < 3:
		return
	
	# 1. Main bangs fill
	draw_colored_polygon(poly, style.hair_color)
	
	# 2. Crown top arch stroke
	var crown_arch := NemiGeometry.get_hair_crown_stroke()
	var crown_stroke := InkStroke.from_points(crown_arch, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	crown_stroke.draw_to(self)
	
	# 3. Stray hair tufts (lively hand-drawn texture)
	var tufts := NemiGeometry.get_hair_stray_tufts()
	for t in tufts:
		var t_stroke := InkStroke.from_points(t, style.inner_line_width, InkStroke.Profile.TAPER_END, style.ink_line_color)
		t_stroke.draw_to(self)
	
	# 4. Bang strand separation creases (individual authored locks)
	var creases := NemiGeometry.get_bangs_creases()
	for c in creases:
		var stroke := InkStroke.from_points(c, style.inner_line_width, InkStroke.Profile.TAPER_END, style.ink_line_color)
		stroke.draw_to(self)
	
	# 5. Bang fringe bottom contour stroke (soft locks framing forehead)
	var fringe := NemiGeometry.get_bangs_fringe_stroke()
	var fringe_stroke := InkStroke.from_points(fringe, style.silhouette_detail_width, InkStroke.Profile.DELICATE_CREASE, style.ink_line_color)
	fringe_stroke.draw_to(self)
	
	# 6. Ahoge cowlick (Iconic silhouette flicking right)
	var ahoge_poly := NemiGeometry.get_ahoge_polygon()
	if ahoge_poly.size() >= 3:
		draw_colored_polygon(ahoge_poly, style.hair_color)
		var spine := NemiGeometry.get_ahoge_spine()
		var ahoge_stroke := InkStroke.from_points(spine, 2.6, InkStroke.Profile.TAPER_END, style.ink_line_color)
		ahoge_stroke.draw_to(self)

func _draw_front_tress(is_left: bool) -> void:
	var poly := NemiGeometry.get_hair_tress_polygon(is_left)
	if poly.size() < 3:
		return
	
	# 1. Fill
	draw_colored_polygon(poly, style.hair_color)
	
	# 2. Outer calligraphic stroke
	var outer_stroke_pts := NemiGeometry.get_hair_tress_outer_stroke(is_left)
	var out_stroke := InkStroke.from_points(outer_stroke_pts, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	out_stroke.draw_to(self)
	
	# 3. Inner calligraphic stroke
	var inner_stroke_pts := NemiGeometry.get_hair_tress_inner_stroke(is_left)
	var in_stroke := InkStroke.from_points(inner_stroke_pts, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	in_stroke.draw_to(self)
