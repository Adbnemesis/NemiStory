class_name CosmoTorso
extends Node2D

## Torso & Scientist Outfit Construction for COSMO (Brawl Stars)
## Faithfully captures:
## - Open shirt collar with inner cyan neck levitation field (accommodating the floating head)
## - Crisp white collared shirt with amber-orange necktie
## - Crimson/magenta knit sweater vest with sharp V-neck
## - Royal blue scientist trench coat with peaked lapels and flowing tail contours
## - Waist levitation energy ring (separating torso from the dark robotic pelvis)
## - Synchronous torso lean transform for expressive acting

const CosmoStyle = preload("res://brawl_stars/characters/cosmo/CosmoStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: CosmoStyle

var torso_lean: float = 0.0: # Angle in radians for acting
	set(val):
		torso_lean = val
		rotation = torso_lean
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Waist Levitation Energy Ring (at bottom of torso, Y ~ 52)
	_draw_waist_levitation_ring()
	
	# 2. Main Trench Coat Body (Royal Blue)
	_draw_coat_body()
	
	# 3. Crimson / Magenta Sweater Vest
	_draw_sweater_vest()
	
	# 4. White Collared Shirt & Amber-Orange Tie
	_draw_shirt_and_tie()
	
	# 5. Coat Peaked Lapels & Collar
	_draw_coat_lapels()
	
	# 6. Open Neck Receptor Ring (under floating head, Y ~ -48)
	_draw_neck_receptor()

func _draw_waist_levitation_ring() -> void:
	var waist_y := 50.0
	var ring_center := Vector2(0, waist_y)
	var glow_col := style.energy_ring_color
	var core_col := style.energy_core_color
	
	# Elliptical levitation halo beneath the floating coat rim
	draw_set_transform(ring_center, 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 34.0, Color(glow_col.r, glow_col.g, glow_col.b, 0.22))
	draw_arc(Vector2.ZERO, 30.0, 0, TAU, 24, glow_col, 2.5, true)
	draw_arc(Vector2.ZERO, 24.0, 0, TAU, 20, core_col, 1.8, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_coat_body() -> void:
	# Trench coat flowing downward from shoulders (Y ~ -42) to hem (Y ~ 48)
	var coat_pts := PackedVector2Array([
		Vector2(-42, -38), # Left shoulder
		Vector2(-48, -10),
		Vector2(-52, 22),
		Vector2(-48, 48), # Left coat tail
		Vector2(-24, 46),
		Vector2(0, 48),
		Vector2(24, 46),
		Vector2(48, 48),  # Right coat tail
		Vector2(52, 22),
		Vector2(48, -10),
		Vector2(42, -38), # Right shoulder
		Vector2(24, -44),
		Vector2(0, -42),
		Vector2(-24, -44)
	])
	
	# Base royal blue
	draw_colored_polygon(coat_pts, style.coat_blue_color)
	
	# Cel shadow on right/flank
	var coat_shadow := PackedVector2Array([
		Vector2(24, -44),
		Vector2(42, -38),
		Vector2(48, -10),
		Vector2(52, 22),
		Vector2(48, 48),
		Vector2(28, 46),
		Vector2(32, 10),
		Vector2(20, -20)
	])
	draw_colored_polygon(coat_shadow, style.coat_shadow_color)
	
	# Outer ink contour
	var outer_loop := PackedVector2Array()
	for p in coat_pts:
		outer_loop.append(p)
	outer_loop.append(coat_pts[0])
	var s := CosmoInkStroke.from_points(outer_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
	s.draw_to(self)

func _draw_sweater_vest() -> void:
	# Central crimson/magenta vest visible between open coat lapels
	var vest_pts := PackedVector2Array([
		Vector2(-22, -32),
		Vector2(-26, 0),
		Vector2(-22, 38),
		Vector2(0, 42),
		Vector2(22, 38),
		Vector2(26, 0),
		Vector2(22, -32),
		Vector2(14, -28),
		Vector2(0, -8), # V-neck bottom point
		Vector2(-14, -28)
	])
	
	draw_colored_polygon(vest_pts, style.vest_magenta_color)
	
	# Vest fold shadow on right side
	var vest_shadow := PackedVector2Array([
		Vector2(0, -8),
		Vector2(14, -28),
		Vector2(22, -32),
		Vector2(26, 0),
		Vector2(22, 38),
		Vector2(8, 40),
		Vector2(10, 10)
	])
	draw_colored_polygon(vest_shadow, style.vest_shadow_color)
	
	# Vest boundary ink line
	var vest_loop := PackedVector2Array()
	for p in vest_pts:
		vest_loop.append(p)
	vest_loop.append(vest_pts[0])
	var s := CosmoInkStroke.from_points(vest_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
	s.draw_to(self)
	
	# Ribbed hem accent lines at bottom of vest
	draw_line(Vector2(-18, 35), Vector2(18, 35), style.ink_color, style.detail_line_width)

func _draw_shirt_and_tie() -> void:
	# Crisp white shirt inside V-neck cutout
	var shirt_pts := PackedVector2Array([
		Vector2(-14, -28),
		Vector2(0, -8),
		Vector2(14, -28),
		Vector2(16, -42),
		Vector2(0, -42),
		Vector2(-16, -42)
	])
	draw_colored_polygon(shirt_pts, style.shirt_white_color)
	
	# Left & Right Shirt Collar Wings
	var left_collar := PackedVector2Array([
		Vector2(-16, -44),
		Vector2(-4, -42),
		Vector2(-10, -26),
		Vector2(-18, -32)
	])
	var right_collar := PackedVector2Array([
		Vector2(16, -44),
		Vector2(18, -32),
		Vector2(10, -26),
		Vector2(4, -42)
	])
	draw_colored_polygon(left_collar, style.shirt_white_color)
	draw_colored_polygon(right_collar, style.shirt_shadow_color)
	
	var lc_loop := PackedVector2Array()
	for p in left_collar: lc_loop.append(p)
	lc_loop.append(left_collar[0])
	CosmoInkStroke.from_points(lc_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	var rc_loop := PackedVector2Array()
	for p in right_collar: rc_loop.append(p)
	rc_loop.append(right_collar[0])
	CosmoInkStroke.from_points(rc_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Amber-Orange Necktie
	# Tie knot
	var knot_pts := PackedVector2Array([
		Vector2(-4, -40),
		Vector2(4, -40),
		Vector2(3, -33),
		Vector2(-3, -33)
	])
	draw_colored_polygon(knot_pts, style.tie_orange_color)
	var knot_loop := PackedVector2Array()
	for p in knot_pts: knot_loop.append(p)
	knot_loop.append(knot_pts[0])
	CosmoInkStroke.from_points(knot_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Tie body
	var tie_body := PackedVector2Array([
		Vector2(-3, -33),
		Vector2(3, -33),
		Vector2(6, -14),
		Vector2(0, -6), # Tie pointed tip
		Vector2(-6, -14)
	])
	draw_colored_polygon(tie_body, style.tie_orange_color)
	var tie_loop := PackedVector2Array()
	for p in tie_body: tie_loop.append(p)
	tie_loop.append(tie_body[0])
	CosmoInkStroke.from_points(tie_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	# Subtle tie center crease line
	draw_line(Vector2(0, -33), Vector2(0, -7), style.ink_color, style.detail_line_width)

func _draw_coat_lapels() -> void:
	# Peaked Trench Coat Lapels folding over the vest
	var left_lapel := PackedVector2Array([
		Vector2(-24, -44),
		Vector2(-36, -26),
		Vector2(-20, -18),
		Vector2(-26, 4),
		Vector2(-18, 2),
		Vector2(-14, -28)
	])
	draw_colored_polygon(left_lapel, style.coat_blue_color)
	var ll_loop := PackedVector2Array()
	for p in left_lapel: ll_loop.append(p)
	ll_loop.append(left_lapel[0])
	CosmoInkStroke.from_points(ll_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	var right_lapel := PackedVector2Array([
		Vector2(24, -44),
		Vector2(14, -28),
		Vector2(18, 2),
		Vector2(26, 4),
		Vector2(20, -18),
		Vector2(36, -26)
	])
	draw_colored_polygon(right_lapel, style.coat_shadow_color)
	var rl_loop := PackedVector2Array()
	for p in right_lapel: rl_loop.append(p)
	rl_loop.append(right_lapel[0])
	CosmoInkStroke.from_points(rl_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)

func _draw_neck_receptor() -> void:
	# Collar neck cutout revealing the magnetic levitation socket
	var neck_center := Vector2(0, -44)
	draw_set_transform(neck_center, 0.0, Vector2(1.0, 0.38))
	draw_circle(Vector2.ZERO, 16.0, style.energy_ring_color)
	draw_arc(Vector2.ZERO, 15.0, 0, TAU, 16, style.energy_core_color, 2.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
