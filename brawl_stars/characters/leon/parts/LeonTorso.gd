class_name LeonTorso
extends Node2D

## Green Chameleon Hoodie Torso, Kangaroo Pocket & Industrial Zipper for LEON (Brawl Stars)
## Implements the bulky green hoodie body, front pouch pocket, oversized metallic zipper slider,
## and orange waistband hem lining.

const LeonStyle = preload("res://brawl_stars/characters/leon/LeonStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: LeonStyle

var torso_lean: float = 0.0
var breathing_offset: float = 0.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Main Green Hoodie Body
	_draw_hoodie_body()
	
	# 2. Orange Bottom Waistband Hem
	_draw_orange_hem()
	
	# 3. Front Kangaroo Pouch Pocket
	_draw_kangaroo_pocket()
	
	# 4. Heavy Industrial Metal Zipper & Pull Tab
	_draw_zipper()

func _draw_hoodie_body() -> void:
	# Torso polygon extending from collar at Y = 25 down to waist at Y = 85
	var body_pts := PackedVector2Array([
		Vector2(-36, 26),
		Vector2(-46, 45),
		Vector2(-48, 70),
		Vector2(-40, 85),
		Vector2(40, 85),
		Vector2(48, 70),
		Vector2(46, 45),
		Vector2(36, 26),
		Vector2(0, 32)
	])
	
	# Base green fill
	draw_colored_polygon(body_pts, style.hood_green_color)
	
	# Cel shadow on sides and under collar
	var shadow_pts := PackedVector2Array([
		Vector2(-36, 26),
		Vector2(-46, 45),
		Vector2(-48, 70),
		Vector2(-40, 85),
		Vector2(-24, 85),
		Vector2(-32, 60),
		Vector2(-28, 40)
	])
	draw_colored_polygon(shadow_pts, style.hood_green_shadow_color)
	
	# Right side shadow
	var shadow_r := PackedVector2Array([
		Vector2(40, 85),
		Vector2(48, 70),
		Vector2(46, 45),
		Vector2(36, 26),
		Vector2(28, 40),
		Vector2(32, 60),
		Vector2(24, 85)
	])
	draw_colored_polygon(shadow_r, style.hood_green_shadow_color)
	
	# Top collar shadow
	var collar_shadow := PackedVector2Array([
		Vector2(-36, 26),
		Vector2(0, 32),
		Vector2(36, 26),
		Vector2(28, 38),
		Vector2(0, 42),
		Vector2(-28, 38)
	])
	draw_colored_polygon(collar_shadow, style.hood_green_shadow_color)
	
	# Outer ink contour
	draw_polyline(body_pts, style.ink_color, style.outer_contour_width, true)

func _draw_orange_hem() -> void:
	# Orange waistband band at the bottom of the hoodie
	var hem_pts := PackedVector2Array([
		Vector2(-40, 85),
		Vector2(-40, 96),
		Vector2(0, 99),
		Vector2(40, 96),
		Vector2(40, 85),
		Vector2(0, 88)
	])
	draw_colored_polygon(hem_pts, style.hood_orange_color)
	
	# Hem shadow on right side
	var hem_shadow := PackedVector2Array([
		Vector2(14, 86),
		Vector2(40, 85),
		Vector2(40, 96),
		Vector2(14, 98)
	])
	draw_colored_polygon(hem_shadow, style.hood_orange_shadow_color)
	
	draw_polyline(hem_pts, style.ink_color, style.outer_contour_width, true)

func _draw_kangaroo_pocket() -> void:
	# Front kangaroo pouch (Bright Cyan/Blue Pocket as in reference)
	var pocket_pts := PackedVector2Array([
		Vector2(-26, 56),
		Vector2(-36, 68),
		Vector2(-34, 85),
		Vector2(34, 85),
		Vector2(36, 68),
		Vector2(26, 56)
	])
	draw_colored_polygon(pocket_pts, style.pouch_blue_color)
	
	# Pocket shadow along bottom
	var p_shadow := PackedVector2Array([
		Vector2(-34, 76),
		Vector2(-34, 85),
		Vector2(34, 85),
		Vector2(34, 76),
		Vector2(0, 80)
	])
	draw_colored_polygon(p_shadow, style.pouch_blue_shadow_color)
	
	# Pink/magenta candy wrapper poking out of the right pocket slit (signature reference detail)
	var candy_tab_pts := PackedVector2Array([
		Vector2(32, 65),
		Vector2(42, 60),
		Vector2(44, 68),
		Vector2(34, 72)
	])
	draw_colored_polygon(candy_tab_pts, style.lollipop_candy_color)
	draw_polyline(candy_tab_pts, style.ink_color, 1.8, true)
	
	# Dark pocket opening slits on left and right
	draw_line(Vector2(-26, 56), Vector2(-36, 68), style.ink_color, 3.2, true)
	draw_line(Vector2(26, 56), Vector2(36, 68), style.ink_color, 3.2, true)
	
	# Top crease of pocket
	draw_line(Vector2(-26, 56), Vector2(26, 56), style.ink_color, style.inner_line_width, true)
	draw_polyline(pocket_pts, style.ink_color, style.outer_contour_width, true)

func _draw_zipper() -> void:
	# Central vertical zipper track running from neck down into the pocket
	draw_line(Vector2(0, 32), Vector2(0, 56), style.ink_color, 2.8, true)
	
	# Large industrial metallic zipper slider & pull tab
	var zip_pos := Vector2(0, 42)
	
	# Slider block
	draw_rect(Rect2(zip_pos.x - 4, zip_pos.y - 4, 8, 8), style.zipper_metal_color)
	draw_rect(Rect2(zip_pos.x - 4, zip_pos.y - 4, 8, 8), style.ink_color, false, 1.6)
	
	# Elongated hanging pull tab (with hollow loop hole)
	var tab_pts := PackedVector2Array([
		zip_pos + Vector2(-5, 4),
		zip_pos + Vector2(5, 4),
		zip_pos + Vector2(6, 18),
		zip_pos + Vector2(0, 22),
		zip_pos + Vector2(-6, 18)
	])
	draw_colored_polygon(tab_pts, style.zipper_metal_color)
	
	# Shadow on right side of pull tab
	var tab_sh := PackedVector2Array([
		zip_pos + Vector2(1, 4),
		zip_pos + Vector2(5, 4),
		zip_pos + Vector2(6, 18),
		zip_pos + Vector2(0, 22),
		zip_pos + Vector2(1, 18)
	])
	draw_colored_polygon(tab_sh, style.zipper_shadow_color)
	
	# Hollow cutout slot inside the tab
	draw_rect(Rect2(zip_pos.x - 2, zip_pos.y + 8, 4, 6), style.ink_color)
	
	# Tab outline
	draw_polyline(tab_pts, style.ink_color, style.inner_line_width, true)
