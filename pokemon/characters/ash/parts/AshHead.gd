class_name AshHead
extends Node2D

## Head, Hair & Iconic Cap for ASH KETCHUM
## Faithfully recreates the classic anime aesthetic:
## - Iconic Indigo League cap with red crown, white front panel, green League logo,
##   and curved red visor with crimson underside shadow (plus backward battle cap mode).
## - Messy spiky black hair with signature bold center forehead bang hanging between eyes,
##   flanking forehead spikes, temple locks, and dynamic lateral hair wings.
## - Soft athletic anime jawline with soft chin shadow and sculpted ears.

const AshStyle = preload("res://pokemon/characters/ash/AshStyle.gd")
const PokemonInkStroke = preload("res://pokemon/scripts/PokemonInkStroke.gd")

var style: AshStyle

var is_cap_backward: bool = false:
	set(val):
		is_cap_backward = val
		queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# Head coordinate origin (0, 0) is at eye level in HeadPivot local space.
	# 1. Back spiky hair wings (flaring out laterally behind ears & nape)
	_draw_back_hair()
	
	# 2. Ears & Face skin base contour
	_draw_head_base()
	
	# 3. Canonical Indigo League Cap
	_draw_cap()
	
	# 4. Front bangs & framing locks (including prominent center forehead bang)
	_draw_front_hair()

func _draw_back_hair() -> void:
	# Dramatic spiky hair wedges radiating outward from behind ears
	var hair_poly := PackedVector2Array([
		Vector2(-26, -16),
		Vector2(-42, -10),
		Vector2(-34, 0),
		Vector2(-46, 8),
		Vector2(-32, 14),
		Vector2(-40, 22),
		Vector2(-24, 20),
		Vector2(-26, 32),
		Vector2(-12, 25),
		Vector2(0, 26),
		Vector2(12, 25),
		Vector2(26, 32),
		Vector2(24, 20),
		Vector2(40, 22),
		Vector2(32, 14),
		Vector2(46, 8),
		Vector2(34, 0),
		Vector2(42, -10),
		Vector2(26, -16)
	])
	draw_colored_polygon(hair_poly, style.hair_color)
	draw_polyline(hair_poly, style.ink_color, style.outer_contour_width, true)

func _draw_head_base() -> void:
	# Left and right ears with inner cartilage fold
	_draw_ear(Vector2(-26, 2), true)
	_draw_ear(Vector2(26, 2), false)
	
	# Face skin shape (youthful anime jawline tapering to soft athletic chin at (0, 24))
	var face_c := Curve2D.new()
	face_c.add_point(Vector2(-26, -16), Vector2(0, 0), Vector2(0, 12))
	face_c.add_point(Vector2(-24, 5), Vector2(-2, -6), Vector2(2, 6))
	face_c.add_point(Vector2(-14, 18), Vector2(-3, -4), Vector2(3, 4))
	face_c.add_point(Vector2(0, 24), Vector2(-7, -1), Vector2(7, -1)) # Chin tip
	face_c.add_point(Vector2(14, 18), Vector2(-3, 4), Vector2(3, -4))
	face_c.add_point(Vector2(24, 5), Vector2(-2, 6), Vector2(2, -6))
	face_c.add_point(Vector2(26, -16), Vector2(0, 12), Vector2(0, 0))
	face_c.add_point(Vector2(0, -30), Vector2(16, 0), Vector2(-16, 0)) # Forehead
	face_c.add_point(Vector2(-26, -16), Vector2(0, 0), Vector2(0, 0))
	
	var face_pts := face_c.tessellate(4, 2.0)
	draw_colored_polygon(face_pts, style.skin_color)
	
	# Soft chin shadow
	var chin_shadow := PackedVector2Array([
		Vector2(-10, 17),
		Vector2(0, 18),
		Vector2(10, 17),
		Vector2(0, 24)
	])
	draw_colored_polygon(chin_shadow, style.skin_shadow_color)
	
	# Lower jaw contour ink outline
	var jaw_line := Curve2D.new()
	jaw_line.add_point(Vector2(-25, 0), Vector2(0, 0), Vector2(2, 8))
	jaw_line.add_point(Vector2(-14, 18), Vector2(-3, -4), Vector2(3, 4))
	jaw_line.add_point(Vector2(0, 24), Vector2(-7, -1), Vector2(7, -1))
	jaw_line.add_point(Vector2(14, 18), Vector2(-3, 4), Vector2(3, -4))
	jaw_line.add_point(Vector2(25, 0), Vector2(-2, 8), Vector2(0, 0))
	var jaw_pts := jaw_line.tessellate(3, 2.0)
	draw_polyline(jaw_pts, style.ink_color, style.outer_contour_width, false)

func _draw_ear(center: Vector2, is_left: bool) -> void:
	var sign_x := -1.0 if is_left else 1.0
	var ear_poly := PackedVector2Array([
		center + Vector2(0, -9),
		center + Vector2(sign_x * 7, -5),
		center + Vector2(sign_x * 8, 4),
		center + Vector2(sign_x * 3, 9),
		center + Vector2(0, 7)
	])
	draw_colored_polygon(ear_poly, style.skin_color)
	draw_polyline(ear_poly, style.ink_color, style.outer_contour_width, false)
	
	# Inner ear ink fold
	var fold := PackedVector2Array([
		center + Vector2(sign_x * 2, -4),
		center + Vector2(sign_x * 5, 0),
		center + Vector2(sign_x * 2, 4)
	])
	draw_polyline(fold, style.ink_color, style.inner_line_width, false)

func _draw_cap() -> void:
	var cap_y := -21.0
	
	if not is_cap_backward:
		# 1. Red Dome (Back of cap)
		var dome_c := Curve2D.new()
		dome_c.add_point(Vector2(-28, cap_y + 2), Vector2(0, 0), Vector2(-2, -18))
		dome_c.add_point(Vector2(-18, cap_y - 23), Vector2(-8, 3), Vector2(10, -5))
		dome_c.add_point(Vector2(0, cap_y - 28), Vector2(-12, 0), Vector2(12, 0))
		dome_c.add_point(Vector2(18, cap_y - 23), Vector2(-10, -5), Vector2(8, 3))
		dome_c.add_point(Vector2(28, cap_y + 2), Vector2(2, -18), Vector2(0, 0))
		dome_c.add_point(Vector2(0, cap_y + 4), Vector2(16, 0), Vector2(-16, 0))
		dome_c.add_point(Vector2(-28, cap_y + 2), Vector2(0, 0), Vector2(0, 0))
		var dome_pts := dome_c.tessellate(4, 2.0)
		draw_colored_polygon(dome_pts, style.cap_red_color)
		draw_polyline(dome_pts, style.ink_color, style.outer_contour_width, true)
		
		# 2. White Front Panel
		var panel_c := Curve2D.new()
		panel_c.add_point(Vector2(-19, cap_y + 2), Vector2(0, 0), Vector2(0, -12))
		panel_c.add_point(Vector2(-12, cap_y - 17), Vector2(-5, 2), Vector2(6, -4))
		panel_c.add_point(Vector2(0, cap_y - 21), Vector2(-8, 0), Vector2(8, 0))
		panel_c.add_point(Vector2(12, cap_y - 17), Vector2(-6, -4), Vector2(5, 2))
		panel_c.add_point(Vector2(19, cap_y + 2), Vector2(0, -12), Vector2(0, 0))
		panel_c.add_point(Vector2(0, cap_y + 4), Vector2(11, 0), Vector2(-11, 0))
		panel_c.add_point(Vector2(-19, cap_y + 2), Vector2(0, 0), Vector2(0, 0))
		var panel_pts := panel_c.tessellate(4, 2.0)
		draw_colored_polygon(panel_pts, style.cap_white_color)
		draw_polyline(panel_pts, style.ink_color, style.inner_line_width, true)
		
		# Stylized Indigo League green logo
		_draw_cap_logo(Vector2(0, cap_y - 8))
		
		# 3. Visor Underside Shadow (provides depth below brim)
		var visor_shadow := PackedVector2Array([
			Vector2(-26, cap_y + 2),
			Vector2(0, cap_y + 9),
			Vector2(28, cap_y + 2),
			Vector2(24, cap_y + 4),
			Vector2(0, cap_y + 11),
			Vector2(-23, cap_y + 4)
		])
		draw_colored_polygon(visor_shadow, style.cap_visor_shadow_color)
		
		# 4. Red Visor / Brim extending forward
		var visor_c := Curve2D.new()
		visor_c.add_point(Vector2(-26, cap_y + 2), Vector2(0, 0), Vector2(6, 6))
		visor_c.add_point(Vector2(0, cap_y + 8), Vector2(-14, 0), Vector2(14, 0))
		visor_c.add_point(Vector2(28, cap_y + 2), Vector2(-6, 6), Vector2(3, 0))
		visor_c.add_point(Vector2(24, cap_y - 1), Vector2(2, 0), Vector2(-8, -3))
		visor_c.add_point(Vector2(0, cap_y + 1), Vector2(10, 0), Vector2(-10, 0))
		visor_c.add_point(Vector2(-23, cap_y - 1), Vector2(8, -3), Vector2(0, 0))
		var visor_pts := visor_c.tessellate(3, 2.0)
		draw_colored_polygon(visor_pts, style.cap_visor_color)
		draw_polyline(visor_pts, style.ink_color, style.outer_contour_width, true)
	else:
		# Backward Cap Mode:
		# Visor is turned toward the back-left
		var b_visor := PackedVector2Array([
			Vector2(-24, cap_y + 4),
			Vector2(-38, cap_y + 14),
			Vector2(-22, cap_y + 17),
			Vector2(-10, cap_y + 5)
		])
		draw_colored_polygon(b_visor, style.cap_visor_color)
		draw_polyline(b_visor, style.ink_color, style.outer_contour_width, true)
		
		# Red Crown Dome facing forward
		var b_dome_c := Curve2D.new()
		b_dome_c.add_point(Vector2(-27, cap_y + 3), Vector2(0, 0), Vector2(-2, -18))
		b_dome_c.add_point(Vector2(-18, cap_y - 23), Vector2(-8, 3), Vector2(10, -5))
		b_dome_c.add_point(Vector2(0, cap_y - 28), Vector2(-12, 0), Vector2(12, 0))
		b_dome_c.add_point(Vector2(18, cap_y - 23), Vector2(-10, -5), Vector2(8, 3))
		b_dome_c.add_point(Vector2(27, cap_y + 3), Vector2(2, -18), Vector2(0, 0))
		b_dome_c.add_point(Vector2(0, cap_y + 5), Vector2(14, 0), Vector2(-14, 0))
		b_dome_c.add_point(Vector2(-27, cap_y + 3), Vector2(0, 0), Vector2(0, 0))
		var b_dome_pts := b_dome_c.tessellate(4, 2.0)
		draw_colored_polygon(b_dome_pts, style.cap_red_color)
		draw_polyline(b_dome_pts, style.ink_color, style.outer_contour_width, true)
		
		# Cap opening notch & snapback strap at forehead
		var snap_notch := PackedVector2Array([
			Vector2(-10, cap_y + 3),
			Vector2(0, cap_y - 5),
			Vector2(10, cap_y + 3)
		])
		draw_colored_polygon(snap_notch, style.skin_color)
		draw_polyline(snap_notch, style.ink_color, style.inner_line_width, false)
		draw_line(Vector2(-8, cap_y + 2), Vector2(8, cap_y + 2), Color("#212529"), 2.0)

func _draw_cap_logo(center: Vector2) -> void:
	# Canonical Indigo League emblem (green stylized angular arch / 'C' mark)
	var logo_pts := PackedVector2Array([
		center + Vector2(-5, -5),
		center + Vector2(1, -5),
		center + Vector2(4, -2),
		center + Vector2(-0.5, -2),
		center + Vector2(-2, -3),
		center + Vector2(-2, 3),
		center + Vector2(5, 3),
		center + Vector2(5, 5),
		center + Vector2(-5, 5)
	])
	draw_colored_polygon(logo_pts, style.cap_logo_color)
	draw_polyline(logo_pts, style.ink_color, 1.2, true)

func _draw_front_hair() -> void:
	var cap_y := -21.0
	
	# 1. Left sideburn & cheek tufts
	var left_tuft := PackedVector2Array([
		Vector2(-24, cap_y + 2),
		Vector2(-35, cap_y + 11),
		Vector2(-27, cap_y + 15),
		Vector2(-36, cap_y + 25),
		Vector2(-24, cap_y + 21),
		Vector2(-21, cap_y + 7)
	])
	draw_colored_polygon(left_tuft, style.hair_color)
	draw_polyline(left_tuft, style.ink_color, style.outer_contour_width, true)
	
	# 2. Right sideburn & cheek tufts
	var right_tuft := PackedVector2Array([
		Vector2(24, cap_y + 2),
		Vector2(35, cap_y + 11),
		Vector2(27, cap_y + 15),
		Vector2(36, cap_y + 25),
		Vector2(24, cap_y + 21),
		Vector2(21, cap_y + 7)
	])
	draw_colored_polygon(right_tuft, style.hair_color)
	draw_polyline(right_tuft, style.ink_color, style.outer_contour_width, true)
	
	# 3. Left Forehead Spike (pointing down toward left eyebrow)
	var left_spike := PackedVector2Array([
		Vector2(-14, cap_y + 5),
		Vector2(-9, cap_y + 15), # Point at y = -6
		Vector2(-4, cap_y + 6)
	])
	draw_colored_polygon(left_spike, style.hair_color)
	draw_polyline(left_spike, style.ink_color, style.inner_line_width, true)
	
	# 4. Right Forehead Spike (pointing down toward right eyebrow)
	var right_spike := PackedVector2Array([
		Vector2(4, cap_y + 6),
		Vector2(9, cap_y + 15), # Point at y = -6
		Vector2(14, cap_y + 5)
	])
	draw_colored_polygon(right_spike, style.hair_color)
	draw_polyline(right_spike, style.ink_color, style.inner_line_width, true)
	
	# 5. ICONIC CENTER FOREHEAD BANG (Signature Satoshi/Ash hair clump)
	# Prominent bold triangular wedge hanging down right between the eyes toward nose bridge
	var center_bang := PackedVector2Array([
		Vector2(-7, cap_y + 5),
		Vector2(0, cap_y + 19), # Reaches down to y = -2 (between eyebrows!)
		Vector2(6, cap_y + 5)
	])
	draw_colored_polygon(center_bang, style.hair_color)
	draw_polyline(center_bang, style.ink_color, style.inner_line_width, true)
