class_name RuffsSupplyDrop
extends Node2D

## Starr Force Supply Drop Crate & Power-Up Badge Prop for COLONEL RUFFS (Brawl Stars)
## 100% Native 2D Hand-drawn illustrated military orbital drop:
## - Heavy steel drop pod crate with Starr Force emblem and yellow hazard chevrons
## - Floating Golden Dog-Bone Power-Up Badge with aura rings
## - Landing impact smoke puffs and ground scorch mark
## - ArtMode monochrome ink-wash support

const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

@export var is_deployed: bool = true
@export var show_powerup_badge: bool = true

var is_monochrome: bool = false:
	set(val):
		is_monochrome = val
		queue_redraw()

var crate_height_offset: float = 0.0:
	set(val):
		crate_height_offset = val
		queue_redraw()

var badge_bob_time: float = 0.0

# Palette
var crate_steel: Color:
	get: return Color("#34466d") if not is_monochrome else Color("#454550")

var crate_dark: Color:
	get: return Color("#1e2844") if not is_monochrome else Color("#2a2a30")

var hazard_yellow: Color:
	get: return Color("#f6c33a") if not is_monochrome else Color("#d0d0d0")

var starr_magenta: Color:
	get: return Color("#9d266e") if not is_monochrome else Color("#606068")

var gold_powerup: Color:
	get: return Color("#ffdd44") if not is_monochrome else Color("#eeeeee")

var aura_cyan: Color:
	get: return Color("#3fe5ff") if not is_monochrome else Color("#ffffff")

var ink_color: Color:
	get: return Color("#201c24")

func _process(delta: float) -> void:
	if show_powerup_badge:
		badge_bob_time += delta * 3.0
		queue_redraw()

func _draw() -> void:
	# Impact shadow on ground
	_draw_ground_shadow()
	
	# Supply Crate
	if is_deployed:
		_draw_crate(Vector2(0, crate_height_offset))
	
	# Floating Golden Bone Power-Up
	if show_powerup_badge:
		var bob := sin(badge_bob_time) * 4.0
		_draw_powerup_badge(Vector2(0, -68 + bob + crate_height_offset))

func _draw_ground_shadow() -> void:
	var shadow_color := Color(0, 0, 0, 0.28)
	_draw_shadow_ellipse(Vector2(0, 20), Vector2(52, 16), shadow_color)
	
	# Scorch / impact cracks
	draw_line(Vector2(-35, 18), Vector2(-54, 22), ink_color, 2.0)
	draw_line(Vector2(32, 19), Vector2(50, 16), ink_color, 2.0)
	draw_line(Vector2(10, 26), Vector2(18, 34), ink_color, 1.8)

func _draw_crate(pos: Vector2) -> void:
	# Crate Body (Octagonal / Chamfered Heavy Military Pod)
	var body_pts := PackedVector2Array([
		pos + Vector2(-36, -26),
		pos + Vector2(36, -26),
		pos + Vector2(44, -14),
		pos + Vector2(44, 14),
		pos + Vector2(36, 24),
		pos + Vector2(-36, 24),
		pos + Vector2(-44, 14),
		pos + Vector2(-44, -14)
	])
	draw_colored_polygon(body_pts, crate_steel)
	
	# Shadow plate on right side
	var sh_pts := PackedVector2Array([
		pos + Vector2(0, -26),
		pos + Vector2(36, -26),
		pos + Vector2(44, -14),
		pos + Vector2(44, 14),
		pos + Vector2(36, 24),
		pos + Vector2(0, 24)
	])
	draw_colored_polygon(sh_pts, crate_dark)
	
	var c_loop := PackedVector2Array()
	for p in body_pts: c_loop.append(p)
	c_loop.append(body_pts[0])
	CosmoInkStroke.from_points(c_loop, 3.8, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	# Hazard diagonal stripes
	var haz1 := PackedVector2Array([
		pos + Vector2(-28, -26),
		pos + Vector2(-20, -26),
		pos + Vector2(-34, 24),
		pos + Vector2(-42, 24)
	])
	draw_colored_polygon(haz1, hazard_yellow)
	
	var haz2 := PackedVector2Array([
		pos + Vector2(18, -26),
		pos + Vector2(26, -26),
		pos + Vector2(12, 24),
		pos + Vector2(4, 24)
	])
	draw_colored_polygon(haz2, hazard_yellow)
	
	# Central Starr Force Emblem (Magenta Diamond + Silver Star)
	var diam_pts := PackedVector2Array([
		pos + Vector2(0, -18),
		pos + Vector2(14, -1),
		pos + Vector2(0, 16),
		pos + Vector2(-14, -1)
	])
	draw_colored_polygon(diam_pts, starr_magenta)
	var d_loop := PackedVector2Array()
	for p in diam_pts: d_loop.append(p)
	d_loop.append(diam_pts[0])
	CosmoInkStroke.from_points(d_loop, 2.2, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	# Gold bone insignia inside diamond
	draw_line(pos + Vector2(-6, -1), pos + Vector2(6, -1), hazard_yellow, 3.0)
	draw_circle(pos + Vector2(-6, -3), 2.2, hazard_yellow)
	draw_circle(pos + Vector2(-6, 1), 2.2, hazard_yellow)
	draw_circle(pos + Vector2(6, -3), 2.2, hazard_yellow)
	draw_circle(pos + Vector2(6, 1), 2.2, hazard_yellow)

func _draw_powerup_badge(pos: Vector2) -> void:
	# Aura glow rings
	var ring_col := aura_cyan
	ring_col.a = 0.4
	draw_arc(pos, 26.0, 0, TAU, 32, ring_col, 2.0, true)
	ring_col.a = 0.2
	draw_arc(pos, 32.0, 0, TAU, 32, ring_col, 1.5, true)
	
	# Floating Golden Dog Bone (Canonical Colonel Ruffs Power-Up)
	# Bone central shaft
	draw_line(pos + Vector2(-16, 0), pos + Vector2(16, 0), gold_powerup, 10.0)
	
	# Left Knobs
	draw_circle(pos + Vector2(-16, -6), 6.5, gold_powerup)
	draw_circle(pos + Vector2(-16, 6), 6.5, gold_powerup)
	
	# Right Knobs
	draw_circle(pos + Vector2(16, -6), 6.5, gold_powerup)
	draw_circle(pos + Vector2(16, 6), 6.5, gold_powerup)
	
	# Ink outlines for bone
	draw_arc(pos + Vector2(-16, -6), 6.5, -PI, PI * 0.25, 16, ink_color, 2.5, true)
	draw_arc(pos + Vector2(-16, 6), 6.5, PI * 0.75, PI * 2.0, 16, ink_color, 2.5, true)
	draw_arc(pos + Vector2(16, -6), 6.5, -PI * 0.25, PI, 16, ink_color, 2.5, true)
	draw_arc(pos + Vector2(16, 6), 6.5, 0, PI * 1.25, 16, ink_color, 2.5, true)
	draw_line(pos + Vector2(-14, -5.5), pos + Vector2(14, -5.5), ink_color, 2.5)
	draw_line(pos + Vector2(-14, 5.5), pos + Vector2(14, 5.5), ink_color, 2.5)
	
	# Sparkles
	draw_line(pos + Vector2(0, -20), pos + Vector2(0, -28), gold_powerup, 2.0)
	draw_line(pos + Vector2(-4, -24), pos + Vector2(4, -24), gold_powerup, 2.0)
	draw_line(pos + Vector2(24, -14), pos + Vector2(30, -14), gold_powerup, 1.8)

func _draw_shadow_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	var num_pts := 32
	for i in range(num_pts):
		var ang := (float(i) / float(num_pts)) * TAU
		pts.append(center + Vector2(cos(ang) * radii.x, sin(ang) * radii.y))
	draw_colored_polygon(pts, color)
