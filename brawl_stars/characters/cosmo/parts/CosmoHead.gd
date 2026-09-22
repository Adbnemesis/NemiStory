class_name CosmoHead
extends Node2D

## Head & Observatory Dome Construction for COSMO (Brawl Stars)
## Implements the floating observatory dome silhouette, top ridge antenna,
## side swivel ear brackets, mechanical pivot screws, and the neck levitation field.

const CosmoStyle = preload("res://brawl_stars/characters/cosmo/CosmoStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: CosmoStyle

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Floating Neck Levitation Field (Ethereal cyan energy glow under the dome)
	_draw_levitation_energy()
	
	# 2. Side Ear Brackets & Mechanical Pivot Screws (behind dome)
	_draw_ear_bracket(Vector2(-52, -12), true)
	_draw_ear_bracket(Vector2(52, -12), false)
	
	# 3. Main Observatory Dome Shell
	_draw_dome_shell()
	
	# 4. Top Antenna Ridge
	_draw_antenna_ridge()

func _draw_levitation_energy() -> void:
	# Concentric elliptical energy rings beneath the floating dome
	var ring_center := Vector2(0, 24)
	var glow_col := style.energy_ring_color
	var core_col := style.energy_core_color
	
	# Outer soft aura
	draw_set_transform(ring_center, 0.0, Vector2(1.0, 0.32))
	draw_circle(Vector2.ZERO, 38.0, Color(glow_col.r, glow_col.g, glow_col.b, 0.18))
	draw_arc(Vector2.ZERO, 34.0, 0, TAU, 24, glow_col, 2.5, true)
	draw_arc(Vector2.ZERO, 26.0, 0, TAU, 20, core_col, 1.8, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_dome_shell() -> void:
	# Hand-drawn asymmetrical observatory dome
	# Base sits at Y ~ 12, top dome arches up to Y ~ -58
	var dome_pts := PackedVector2Array([
		Vector2(-48, 12),
		Vector2(-52, -4),
		Vector2(-50, -28),
		Vector2(-42, -46),
		Vector2(-24, -58),
		Vector2(0, -62),
		Vector2(24, -58),
		Vector2(42, -46),
		Vector2(50, -28),
		Vector2(52, -4),
		Vector2(48, 12),
		Vector2(28, 16),
		Vector2(0, 17),
		Vector2(-28, 16)
	])
	
	# Fill base color
	draw_colored_polygon(dome_pts, style.head_dome_color)
	
	# Soft cel shadow on lower-left / underside
	var shadow_pts := PackedVector2Array([
		Vector2(-48, 12),
		Vector2(-52, -4),
		Vector2(-50, -28),
		Vector2(-32, -12),
		Vector2(-10, 6),
		Vector2(0, 17),
		Vector2(-28, 16)
	])
	draw_colored_polygon(shadow_pts, style.head_dome_shadow_color)
	
	# Outer organic ink outline
	var outer_contour := PackedVector2Array()
	for p in dome_pts:
		outer_contour.append(p)
	outer_contour.append(dome_pts[0])
	var stroke := CosmoInkStroke.from_points(outer_contour, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
	stroke.draw_to(self)
	
	# Internal panel seam line (hand-drawn dome plate curve)
	var seam_pts := PackedVector2Array([
		Vector2(-38, -32),
		Vector2(-20, -38),
		Vector2(0, -40),
		Vector2(20, -38),
		Vector2(38, -32)
	])
	var seam_stroke := CosmoInkStroke.from_points(seam_pts, style.inner_line_width, CosmoInkStroke.Profile.TAPER_BOTH, style.ink_color)
	seam_stroke.draw_to(self)

func _draw_ear_bracket(pos: Vector2, is_left: bool) -> void:
	var flip: float = -1.0 if is_left else 1.0
	
	# Winged swivel bracket plate
	var bracket_pts := PackedVector2Array([
		pos + Vector2(0, -14),
		pos + Vector2(14 * flip, -22),
		pos + Vector2(22 * flip, -10),
		pos + Vector2(16 * flip, 12),
		pos + Vector2(2 * flip, 14)
	])
	draw_colored_polygon(bracket_pts, style.ear_bracket_color)
	
	var bracket_loop := PackedVector2Array()
	for p in bracket_pts:
		bracket_loop.append(p)
	bracket_loop.append(bracket_pts[0])
	var b_stroke := CosmoInkStroke.from_points(bracket_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
	b_stroke.draw_to(self)
	
	# Central mechanical pivot screw
	var screw_center := pos + Vector2(8 * flip, -2)
	draw_circle(screw_center, 6.0, style.ear_screw_color)
	draw_arc(screw_center, 6.0, 0, TAU, 16, style.ink_color, style.inner_line_width, true)
	# Screw drive slot (angled ink line)
	var slot_dir := Vector2(3.5, 3.5)
	draw_line(screw_center - slot_dir, screw_center + slot_dir, style.ink_color, 1.8)

func _draw_antenna_ridge() -> void:
	# Prominent central observatory dome fin / antenna
	var ridge_pts := PackedVector2Array([
		Vector2(-6, -60),
		Vector2(0, -74),
		Vector2(6, -60),
		Vector2(3, -56),
		Vector2(-3, -56)
	])
	draw_colored_polygon(ridge_pts, style.ear_bracket_color)
	
	var ridge_loop := PackedVector2Array()
	for p in ridge_pts:
		ridge_loop.append(p)
	ridge_loop.append(ridge_pts[0])
	var r_stroke := CosmoInkStroke.from_points(ridge_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
	r_stroke.draw_to(self)
	
	# Tip accent dot
	draw_circle(Vector2(0, -74), 2.5, style.head_dome_shadow_color)
