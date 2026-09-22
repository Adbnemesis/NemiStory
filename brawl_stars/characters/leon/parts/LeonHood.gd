class_name LeonHood
extends Node2D

## Chameleon Hoodie Cowl, Dual Blue Eye Turrets, Red Brim Accent & Tail for LEON (Brawl Stars)
## Implements the iconic green cowl, orange center crest stripe,
## dual bulging BLUE chameleon eye turrets (left & right), red visor brim flap, and curled tail.

const LeonStyle = preload("res://brawl_stars/characters/leon/LeonStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: LeonStyle

var tail_wag: float = 0.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Curled Chameleon Tail (behind torso/limbs, attached at lower left back)
	_draw_chameleon_tail()
	
	# 2. Main Hood Cowl Base
	_draw_hood_cowl()
	
	# 3. Orange Central Hood Stripe
	_draw_orange_crest_stripe()
	
	# 4. Chameleon Left Eye Turret (Upper Left Crest - Blue)
	_draw_chameleon_left_eye(Vector2(-42, -58))
	
	# 5. Chameleon Right Eye Turret (Upper Right Crest - Blue)
	_draw_chameleon_right_eye(Vector2(44, -56))
	
	# 6. Red Brim Accent (Chameleon Tongue / Brow Flap on Lower-Right Brim)
	_draw_red_brim_accent(Vector2(25, -16))

func _draw_chameleon_tail() -> void:
	# Curled spiral tail extending behind the left hip
	var base_origin := Vector2(-28, 70)
	var wag_offset := Vector2(sin(tail_wag) * 4.0, cos(tail_wag) * 2.5)
	
	var tail_pts := PackedVector2Array([
		base_origin,
		base_origin + Vector2(-16, -6) + wag_offset,
		base_origin + Vector2(-30, -22) + wag_offset * 1.2,
		base_origin + Vector2(-32, -42) + wag_offset * 1.5,
		base_origin + Vector2(-20, -56) + wag_offset * 1.8,
		base_origin + Vector2(-6, -58) + wag_offset * 1.8,
		base_origin + Vector2(6, -48) + wag_offset * 1.5,
		base_origin + Vector2(0, -38) + wag_offset * 1.2,
		base_origin + Vector2(-10, -40) + wag_offset,
		base_origin + Vector2(-18, -48) + wag_offset,
		base_origin + Vector2(-14, -52) + wag_offset,
	])
	
	# Draw thick tapered ink stroke for tail
	var stroke := CosmoInkStroke.from_points(tail_pts, 18.0, CosmoInkStroke.Profile.TAPER_END, style.hood_green_color)
	stroke.draw_to(self)
	
	# Outer contour
	draw_polyline(tail_pts, style.ink_color, style.inner_line_width, true)

func _draw_hood_cowl() -> void:
	# Oversized bulbous chameleon hood silhouette
	# Centers around Vector2(0, -20)
	var cowl_pts := PackedVector2Array([
		Vector2(-58, 25),
		Vector2(-66, 0),
		Vector2(-68, -30),
		Vector2(-56, -60),
		Vector2(-32, -78),
		Vector2(0, -84),
		Vector2(32, -78),
		Vector2(56, -60),
		Vector2(68, -30),
		Vector2(66, 0),
		Vector2(58, 25),
		Vector2(40, 36),
		Vector2(0, 40),
		Vector2(-40, 36)
	])
	
	# Base green fill
	draw_colored_polygon(cowl_pts, style.hood_green_color)
	
	# Cel-shadowing on lower edges and back fold
	var shadow_pts := PackedVector2Array([
		Vector2(-58, 25),
		Vector2(-66, 0),
		Vector2(-68, -30),
		Vector2(-50, -20),
		Vector2(-35, 10),
		Vector2(-20, 32),
		Vector2(-40, 36)
	])
	draw_colored_polygon(shadow_pts, style.hood_green_shadow_color)
	
	# Top highlight arc
	var highlight_pts := PackedVector2Array([
		Vector2(-24, -76),
		Vector2(0, -82),
		Vector2(24, -76),
		Vector2(18, -70),
		Vector2(0, -75),
		Vector2(-18, -70)
	])
	draw_colored_polygon(highlight_pts, style.hood_green_highlight_color)
	
	# Outer ink contour
	draw_polyline(cowl_pts, style.ink_color, style.outer_contour_width, true)

func _draw_orange_crest_stripe() -> void:
	# Wide bold orange central stripe running from forehead over top down the spine
	var stripe_pts := PackedVector2Array([
		Vector2(-18, -82),
		Vector2(-20, -50),
		Vector2(-16, -20),
		Vector2(16, -20),
		Vector2(20, -50),
		Vector2(18, -82),
		Vector2(0, -84)
	])
	draw_colored_polygon(stripe_pts, style.hood_orange_color)
	
	# Right-side shadow slice
	var stripe_shadow := PackedVector2Array([
		Vector2(4, -82),
		Vector2(7, -50),
		Vector2(8, -20),
		Vector2(16, -20),
		Vector2(20, -50),
		Vector2(18, -82)
	])
	draw_colored_polygon(stripe_shadow, style.hood_orange_shadow_color)
	
	# Ink divider lines
	draw_line(Vector2(-18, -82), Vector2(-16, -20), style.ink_color, style.inner_line_width, true)
	draw_line(Vector2(18, -82), Vector2(16, -20), style.ink_color, style.inner_line_width, true)

func _draw_chameleon_left_eye(pos: Vector2) -> void:
	# Protruding conical chameleon eye turret jutting to the upper-left (ALL BLUE)
	draw_set_transform(pos, -0.26, Vector2.ONE)
	
	# Turret conical base mound
	var base_pts := PackedVector2Array([
		Vector2(10, 16),
		Vector2(-8, 20),
		Vector2(-24, 6),
		Vector2(-22, -18),
		Vector2(0, -22),
		Vector2(18, -8)
	])
	draw_colored_polygon(base_pts, style.cham_turret_shadow_color)
	
	# Main eye sphere / cylinder face
	draw_circle(Vector2.ZERO, 20.0, style.cham_turret_blue_color)
	# Bottom shadow crescent
	draw_circle(Vector2(2, 3), 18.0, style.cham_turret_shadow_color)
	draw_circle(Vector2(-1, -1), 17.0, style.cham_turret_blue_color)
	
	# Deep concave dark blue pupil pit
	draw_circle(Vector2(-2, -2), 12.5, style.cham_turret_recess_color)
	
	# Curved crescent chameleon pupil slit
	var pupil_pts := PackedVector2Array([
		Vector2(-6, -7),
		Vector2(-2, -5),
		Vector2(0, 0),
		Vector2(-2, 5),
		Vector2(-6, 7),
		Vector2(-4, 0)
	])
	draw_colored_polygon(pupil_pts, Color("#0f172a"))
	
	# White specular crescent highlight
	draw_arc(Vector2(-2, -2), 11.0, -PI * 0.75, -PI * 0.25, 16, Color.WHITE, 2.2, true)
	draw_circle(Vector2(-5, -6), 2.2, Color.WHITE)
	
	# Bold ink outer contour
	draw_arc(Vector2.ZERO, 20.0, 0, TAU, 32, style.ink_color, style.outer_contour_width, true)
	draw_polyline(base_pts, style.ink_color, style.inner_line_width, true)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_chameleon_right_eye(pos: Vector2) -> void:
	# Protruding conical chameleon eye turret jutting to the upper-right in perspective (ALL BLUE)
	draw_set_transform(pos, 0.42, Vector2.ONE)
	
	# Conical cylinder body extending rightward
	var cyl_pts := PackedVector2Array([
		Vector2(-16, -16),
		Vector2(12, -20),
		Vector2(22, -6),
		Vector2(20, 16),
		Vector2(-4, 22),
		Vector2(-16, 12)
	])
	draw_colored_polygon(cyl_pts, style.cham_turret_shadow_color)
	
	# Upper highlight on cylinder
	var cyl_hi := PackedVector2Array([
		Vector2(-16, -16),
		Vector2(12, -20),
		Vector2(18, -10),
		Vector2(-8, -6)
	])
	draw_colored_polygon(cyl_hi, style.cham_turret_blue_color)
	
	# Tilted oval face of the turret
	var oval_center := Vector2(14, 0)
	var oval_r := Vector2(10.0, 17.0)
	
	# Base blue rim
	draw_set_transform(pos + oval_center.rotated(0.42), 0.42, Vector2(1.0, 1.4))
	draw_circle(Vector2.ZERO, 10.0, style.cham_turret_blue_color)
	draw_circle(Vector2(-1, 1), 9.0, style.cham_turret_shadow_color)
	draw_circle(Vector2(0, 0), 8.0, style.cham_turret_recess_color)
	
	# Dark pupil slit in recess
	draw_line(Vector2(-1, -5), Vector2(-1, 5), Color("#0f172a"), 3.0, true)
	# White specular gleam
	draw_circle(Vector2(-3, -3), 1.6, Color.WHITE)
	
	# Ink contour around the oval
	draw_arc(Vector2.ZERO, 10.0, 0, TAU, 24, style.ink_color, style.outer_contour_width, true)
	
	draw_set_transform(pos, 0.42, Vector2.ONE)
	draw_polyline(cyl_pts, style.ink_color, style.outer_contour_width, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_red_brim_accent(pos: Vector2) -> void:
	# Red oval / button flap on the lower-right edge of the hood visor brim
	# (Signature Leon chameleon tongue / eyelid accent from reference art)
	draw_set_transform(pos, -0.35, Vector2(1.3, 1.0))
	
	# Shadow layer
	draw_circle(Vector2(1, 1), 11.5, style.hood_red_shadow_color)
	# Bright red fill
	draw_circle(Vector2.ZERO, 11.0, style.hood_red_accent_color)
	
	# Curved crescent shadow on lower edge
	draw_arc(Vector2(0, 1), 8.5, 0.1, PI * 0.9, 16, style.hood_red_shadow_color, 2.8, true)
	
	# Subtle top specular highlight
	draw_circle(Vector2(-3, -3), 2.0, Color(1, 1, 1, 0.55))
	
	# Bold black ink contour
	draw_arc(Vector2.ZERO, 11.0, 0, TAU, 28, style.ink_color, style.inner_line_width + 0.6, true)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
