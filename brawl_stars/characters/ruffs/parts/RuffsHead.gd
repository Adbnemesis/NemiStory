class_name RuffsHead
extends Node2D

## Head, Peaked Cap & Hound Ears Construction for RUFFS (Colonel Ruffs - Brawl Stars)
## Faithfully captures:
## - Enormous magenta officer's peaked cap with front crown flare
## - Winged silver military commander badge with purple shield & anchor emblem
## - Glossy black curved visor with navy blue cap band
## - Dual side communication node pods
## - Long floppy basset hound ears responding to dynamic ear angles (perk / droop)

const RuffsStyle = preload("res://brawl_stars/characters/ruffs/RuffsStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: RuffsStyle

var left_ear_angle: float = 0.0: # Radians
	set(val):
		left_ear_angle = val
		queue_redraw()

var right_ear_angle: float = 0.0: # Radians
	set(val):
		right_ear_angle = val
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Floppy Basset Hound Ears (drawn behind head/cap)
	_draw_hound_ears()
	
	# 2. Main Peaked Cap Crown (Magenta)
	_draw_cap_crown()
	
	# 3. Navy Blue Cap Band & Dual Comm Pods
	_draw_cap_band_and_comm_nodes()
	
	# 4. Winged Silver Commander Badge (On front cap crown)
	_draw_commander_badge()
	
	# 5. Glossy Black Cap Visor / Brim (over forehead)
	_draw_cap_visor()

func _draw_hound_ears() -> void:
	# Left Ear (his right, screen left: hangs down from X ~ -54, Y ~ -25)
	_draw_single_ear(Vector2(-52, -22), left_ear_angle, true)
	
	# Right Ear (his left, screen right: hangs down from X ~ +54, Y ~ -25)
	_draw_single_ear(Vector2(52, -22), right_ear_angle, false)

func _draw_single_ear(base_pos: Vector2, angle: float, is_left: bool) -> void:
	var flip: float = -1.0 if is_left else 1.0
	draw_set_transform(base_pos, angle, Vector2.ONE)
	
	# Long drooping basset hound ear lobe
	var ear_pts := PackedVector2Array([
		Vector2(0, 0),
		Vector2(14 * flip, 18),
		Vector2(20 * flip, 48),
		Vector2(16 * flip, 82),
		Vector2(0, 96), # Rounded ear tip
		Vector2(-14 * flip, 82),
		Vector2(-16 * flip, 42),
		Vector2(-10 * flip, 12)
	])
	draw_colored_polygon(ear_pts, style.ear_brown_color)
	
	# Inner ear shadow fold
	var fold_pts := PackedVector2Array([
		Vector2(0, 0),
		Vector2(10 * flip, 24),
		Vector2(12 * flip, 56),
		Vector2(0, 78),
		Vector2(-8 * flip, 48),
		Vector2(-6 * flip, 16)
	])
	draw_colored_polygon(fold_pts, style.ear_shadow_color)
	
	var loop := PackedVector2Array()
	for p in ear_pts: loop.append(p)
	loop.append(ear_pts[0])
	CosmoInkStroke.from_points(loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_cap_crown() -> void:
	# Peaked commander cap dome (Monumental flare at top)
	# Origin is at cap base center Y ~ -30, crown arches up to Y ~ -120
	var cap_pts := PackedVector2Array([
		Vector2(-58, -32),
		Vector2(-76, -60),
		Vector2(-82, -88),
		Vector2(-65, -114),
		Vector2(-35, -128),
		Vector2(0, -132),
		Vector2(35, -128),
		Vector2(65, -114),
		Vector2(82, -88),
		Vector2(76, -60),
		Vector2(58, -32),
		Vector2(35, -28),
		Vector2(0, -26),
		Vector2(-35, -28)
	])
	draw_colored_polygon(cap_pts, style.coat_magenta_color)
	
	# Shading along underside and right crest
	var shadow_pts := PackedVector2Array([
		Vector2(0, -132),
		Vector2(35, -128),
		Vector2(65, -114),
		Vector2(82, -88),
		Vector2(76, -60),
		Vector2(58, -32),
		Vector2(35, -28),
		Vector2(20, -55),
		Vector2(10, -95)
	])
	draw_colored_polygon(shadow_pts, style.coat_shadow_color)
	
	var loop := PackedVector2Array()
	for p in cap_pts: loop.append(p)
	loop.append(cap_pts[0])
	CosmoInkStroke.from_points(loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)

func _draw_commander_badge() -> void:
	# Center of badge on front cap crown
	var badge_center := Vector2(0, -88)
	
	# 1. Silver Winged Plaque
	var wing_pts := PackedVector2Array([
		badge_center + Vector2(-34, -14),
		badge_center + Vector2(-20, -18),
		badge_center + Vector2(20, -18),
		badge_center + Vector2(34, -14),
		badge_center + Vector2(32, 2),
		badge_center + Vector2(18, 14),
		badge_center + Vector2(0, 22),
		badge_center + Vector2(-18, 14),
		badge_center + Vector2(-32, 2)
	])
	draw_colored_polygon(wing_pts, style.silver_badge_color)
	
	var w_loop := PackedVector2Array()
	for p in wing_pts: w_loop.append(p)
	w_loop.append(wing_pts[0])
	CosmoInkStroke.from_points(w_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Wing feather grooves
	draw_line(badge_center + Vector2(-26, -10), badge_center + Vector2(-22, 6), style.ink_color, 1.2)
	draw_line(badge_center + Vector2(-30, -4), badge_center + Vector2(-24, 8), style.ink_color, 1.2)
	draw_line(badge_center + Vector2(26, -10), badge_center + Vector2(22, 6), style.ink_color, 1.2)
	draw_line(badge_center + Vector2(30, -4), badge_center + Vector2(24, 8), style.ink_color, 1.2)
	
	# 2. Inner Purple Shield Emblem
	var shield_pts := PackedVector2Array([
		badge_center + Vector2(-12, -12),
		badge_center + Vector2(12, -12),
		badge_center + Vector2(10, 6),
		badge_center + Vector2(0, 14),
		badge_center + Vector2(-10, 6)
	])
	draw_colored_polygon(shield_pts, style.coat_shadow_color)
	var s_loop := PackedVector2Array()
	for p in shield_pts: s_loop.append(p)
	s_loop.append(shield_pts[0])
	CosmoInkStroke.from_points(s_loop, 1.4, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Inverted anchor / T-symbol in silver/gold
	draw_line(badge_center + Vector2(-7, -4), badge_center + Vector2(7, -4), style.silver_badge_color, 2.5)
	draw_line(badge_center + Vector2(0, -4), badge_center + Vector2(0, 8), style.silver_badge_color, 2.5)

func _draw_cap_band_and_comm_nodes() -> void:
	# Navy Cap Band across bottom of crown
	var band_pts := PackedVector2Array([
		Vector2(-58, -34),
		Vector2(-60, -46),
		Vector2(60, -46),
		Vector2(58, -34),
		Vector2(32, -26),
		Vector2(0, -24),
		Vector2(-32, -26)
	])
	draw_colored_polygon(band_pts, style.navy_trim_color)
	var b_loop := PackedVector2Array()
	for p in band_pts: b_loop.append(p)
	b_loop.append(band_pts[0])
	CosmoInkStroke.from_points(b_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Communication Pods (Cyan/Blue cylinders on left & right)
	draw_circle(Vector2(-58, -36), 9.0, style.comm_node_color)
	draw_arc(Vector2(-58, -36), 9.0, 0, TAU, 16, style.ink_color, style.inner_line_width, true)
	draw_circle(Vector2(-58, -36), 4.0, style.silver_badge_color)
	
	draw_circle(Vector2(58, -36), 9.0, style.comm_node_color)
	draw_arc(Vector2(58, -36), 9.0, 0, TAU, 16, style.ink_color, style.inner_line_width, true)
	draw_circle(Vector2(58, -36), 4.0, style.silver_badge_color)

func _draw_cap_visor() -> void:
	# Glossy black curved officer visor
	var visor_pts := PackedVector2Array([
		Vector2(-56, -34),
		Vector2(-42, -18),
		Vector2(-20, -10),
		Vector2(0, -8),
		Vector2(20, -10),
		Vector2(42, -18),
		Vector2(56, -34),
		Vector2(32, -26),
		Vector2(0, -24),
		Vector2(-32, -26)
	])
	draw_colored_polygon(visor_pts, style.navy_shadow_color)
	
	# Glossy specular reflection strip on visor
	var gleam_pts := PackedVector2Array([
		Vector2(-36, -22),
		Vector2(-14, -14),
		Vector2(0, -13),
		Vector2(14, -14),
		Vector2(0, -18),
		Vector2(-20, -22)
	])
	draw_colored_polygon(gleam_pts, Color(1.0, 1.0, 1.0, 0.25))
	
	var v_loop := PackedVector2Array()
	for p in visor_pts: v_loop.append(p)
	v_loop.append(visor_pts[0])
	CosmoInkStroke.from_points(v_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
