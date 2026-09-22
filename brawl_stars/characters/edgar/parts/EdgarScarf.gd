class_name EdgarScarf
extends Node2D

## Living Sentient Striped Scarf & Fist Appendages for EDGAR (Brawl Stars)
## Implements the high striped neck cowl (purple & white knit bands) and dual articulated
## sentient scarf limbs ending in expressive cartoon demon fists (draping, crossed, punching, thumbs down).

const EdgarStyle = preload("res://brawl_stars/characters/edgar/EdgarStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: EdgarStyle

var scarf_pose: String = "idle_drape" # idle_drape, crossed, punch_ready, thumbs_down, droop
var scarf_sway: float = 0.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Left Scarf Hanging Arm / Fist
	_draw_left_scarf_limb()
	
	# 2. Right Scarf Hanging Arm / Fist
	_draw_right_scarf_limb()
	
	# 3. High Striped Neck Cowl Wrap (in front of chin)
	_draw_neck_cowl()

func _draw_neck_cowl() -> void:
	# Bulky striped knit cowl sitting from Y = 10 down to Y = 36
	# Alternating purple and white vertical/diagonal sections
	var cowl_outline := PackedVector2Array([
		Vector2(-36, 12),
		Vector2(-42, 22),
		Vector2(-35, 36),
		Vector2(0, 40),
		Vector2(35, 36),
		Vector2(42, 22),
		Vector2(36, 12),
		Vector2(0, 16)
	])
	draw_colored_polygon(cowl_outline, style.scarf_purple_color)
	
	# Vertical white knit stripes
	var stripe_1 := PackedVector2Array([Vector2(-28, 13), Vector2(-18, 14), Vector2(-16, 38), Vector2(-26, 37)])
	var stripe_2 := PackedVector2Array([Vector2(-6, 15), Vector2(4, 15), Vector2(4, 40), Vector2(-6, 40)])
	var stripe_3 := PackedVector2Array([Vector2(16, 14), Vector2(26, 13), Vector2(24, 37), Vector2(14, 38)])
	
	draw_colored_polygon(stripe_1, style.scarf_white_color)
	draw_colored_polygon(stripe_2, style.scarf_white_color)
	draw_colored_polygon(stripe_3, style.scarf_white_color)
	
	# Shading on bottom fold
	var fold_sh := PackedVector2Array([
		Vector2(-35, 30),
		Vector2(0, 35),
		Vector2(35, 30),
		Vector2(35, 36),
		Vector2(0, 40),
		Vector2(-35, 36)
	])
	draw_colored_polygon(fold_sh, style.scarf_purple_shadow_color)
	
	# Scarf cowl ink outline
	draw_polyline(cowl_outline, style.ink_color, style.outer_contour_width, true)

func _draw_left_scarf_limb() -> void:
	var sway := sin(scarf_sway) * 4.0
	
	match scarf_pose:
		"crossed":
			# Wrapped tightly across the chest
			var limb_pts := PackedVector2Array([
				Vector2(-32, 26),
				Vector2(-48, 42),
				Vector2(-30, 68),
				Vector2(18, 65),
				Vector2(28, 54),
				Vector2(-20, 52),
				Vector2(-38, 38)
			])
			draw_colored_polygon(limb_pts, style.scarf_purple_color)
			draw_polyline(limb_pts, style.ink_color, style.inner_line_width, true)
			# Fist resting on right rib
			_draw_scarf_fist(Vector2(24, 60), 0.2)
		
		"punch_ready":
			# Raised clenched fist ready to strike
			var limb_pts := PackedVector2Array([
				Vector2(-34, 25),
				Vector2(-65, 10),
				Vector2(-80, -15),
				Vector2(-65, -18),
				Vector2(-48, 8),
				Vector2(-28, 28)
			])
			draw_colored_polygon(limb_pts, style.scarf_purple_color)
			draw_polyline(limb_pts, style.ink_color, style.inner_line_width, true)
			_draw_scarf_fist(Vector2(-82, -22), -0.6)
		
		_: # "idle_drape" / "droop"
			# Hanging down along left flank
			var limb_pts := PackedVector2Array([
				Vector2(-34, 28),
				Vector2(-48, 55 + sway),
				Vector2(-52, 95 + sway * 1.4),
				Vector2(-36, 92 + sway * 1.4),
				Vector2(-34, 52 + sway),
				Vector2(-26, 32)
			])
			draw_colored_polygon(limb_pts, style.scarf_purple_color)
			
			# White stripes across the hanging length
			var s1 := PackedVector2Array([Vector2(-39, 44 + sway * 0.5), Vector2(-46, 52 + sway), Vector2(-35, 54 + sway), Vector2(-30, 45 + sway * 0.5)])
			var s2 := PackedVector2Array([Vector2(-49, 74 + sway * 1.2), Vector2(-51, 84 + sway * 1.4), Vector2(-37, 82 + sway * 1.4), Vector2(-36, 73 + sway * 1.2)])
			draw_colored_polygon(s1, style.scarf_white_color)
			draw_colored_polygon(s2, style.scarf_white_color)
			
			draw_polyline(limb_pts, style.ink_color, style.inner_line_width, true)
			_draw_scarf_fist(Vector2(-44, 98 + sway * 1.4), 0.15)

func _draw_right_scarf_limb() -> void:
	var sway := cos(scarf_sway) * 4.0
	
	match scarf_pose:
		"crossed":
			# Wrapped across chest from right to left
			var limb_pts := PackedVector2Array([
				Vector2(32, 26),
				Vector2(48, 42),
				Vector2(30, 72),
				Vector2(-18, 70),
				Vector2(-28, 58),
				Vector2(20, 56),
				Vector2(38, 38)
			])
			draw_colored_polygon(limb_pts, style.scarf_purple_color)
			draw_polyline(limb_pts, style.ink_color, style.inner_line_width, true)
			_draw_scarf_fist(Vector2(-24, 65), -0.2)
		
		"thumbs_down":
			# Extended outward giving toxic thumbs-down gesture!
			var limb_pts := PackedVector2Array([
				Vector2(34, 25),
				Vector2(65, 32),
				Vector2(95, 28),
				Vector2(92, 42),
				Vector2(62, 44),
				Vector2(28, 32)
			])
			draw_colored_polygon(limb_pts, style.scarf_purple_color)
			draw_polyline(limb_pts, style.ink_color, style.inner_line_width, true)
			_draw_thumbs_down_fist(Vector2(104, 36))
		
		"punch_ready":
			# Raised punch fist on right
			var limb_pts := PackedVector2Array([
				Vector2(34, 25),
				Vector2(65, 10),
				Vector2(80, -15),
				Vector2(65, -18),
				Vector2(48, 8),
				Vector2(28, 28)
			])
			draw_colored_polygon(limb_pts, style.scarf_purple_color)
			draw_polyline(limb_pts, style.ink_color, style.inner_line_width, true)
			_draw_scarf_fist(Vector2(82, -22), 0.6)
		
		_: # "idle_drape"
			# Hanging down along right flank
			var limb_pts := PackedVector2Array([
				Vector2(26, 32),
				Vector2(34, 52 + sway),
				Vector2(36, 92 + sway * 1.4),
				Vector2(52, 95 + sway * 1.4),
				Vector2(48, 55 + sway),
				Vector2(34, 28)
			])
			draw_colored_polygon(limb_pts, style.scarf_purple_color)
			
			var s1 := PackedVector2Array([Vector2(30, 45 + sway * 0.5), Vector2(35, 54 + sway), Vector2(46, 52 + sway), Vector2(39, 44 + sway * 0.5)])
			var s2 := PackedVector2Array([Vector2(36, 73 + sway * 1.2), Vector2(37, 82 + sway * 1.4), Vector2(51, 84 + sway * 1.4), Vector2(49, 74 + sway * 1.2)])
			draw_colored_polygon(s1, style.scarf_white_color)
			draw_colored_polygon(s2, style.scarf_white_color)
			
			draw_polyline(limb_pts, style.ink_color, style.inner_line_width, true)
			_draw_scarf_fist(Vector2(44, 98 + sway * 1.4), -0.15)

func _draw_scarf_fist(pos: Vector2, rot: float) -> void:
	# Stylized demon / cloth fist with 4 cartoon knuckle segments
	draw_set_transform(pos, rot, Vector2.ONE)
	
	var fist_pts := PackedVector2Array([
		Vector2(-12, -8),
		Vector2(12, -8),
		Vector2(16, 6),
		Vector2(10, 16),
		Vector2(-10, 16),
		Vector2(-16, 6)
	])
	draw_colored_polygon(fist_pts, style.scarf_purple_color)
	
	# White "X" stitch accent on back of cloth fist
	draw_line(Vector2(-4, -2), Vector2(4, 6), style.scarf_white_color, 2.0, true)
	draw_line(Vector2(4, -2), Vector2(-4, 6), style.scarf_white_color, 2.0, true)
	
	# Knuckle lines
	draw_line(Vector2(-6, 6), Vector2(-6, 14), style.ink_color, 1.6, true)
	draw_line(Vector2(0, 6), Vector2(0, 15), style.ink_color, 1.6, true)
	draw_line(Vector2(6, 6), Vector2(6, 14), style.ink_color, 1.6, true)
	
	draw_polyline(fist_pts, style.ink_color, style.outer_contour_width, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_thumbs_down_fist(pos: Vector2) -> void:
	# Toxic thumbs-down pose
	draw_set_transform(pos, 0.0, Vector2.ONE)
	
	var fist := PackedVector2Array([
		Vector2(-12, -10),
		Vector2(12, -10),
		Vector2(14, 4),
		Vector2(-14, 4)
	])
	draw_colored_polygon(fist, style.scarf_purple_color)
	draw_polyline(fist, style.ink_color, style.outer_contour_width, true)
	
	# Thumb pointing straight down
	var thumb := PackedVector2Array([
		Vector2(-8, 4),
		Vector2(-2, 4),
		Vector2(-2, 18),
		Vector2(-8, 18)
	])
	draw_colored_polygon(thumb, style.scarf_purple_color)
	draw_polyline(thumb, style.ink_color, style.inner_line_width, true)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
