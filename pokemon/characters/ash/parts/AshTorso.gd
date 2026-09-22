class_name AshTorso
extends Node2D

## Torso & Clothing for ASH KETCHUM
## Constructs neck, dark inner shirt, open blue vest with white collar,
## yellow trim accents, leather belt with metallic buckle,
## and Ash's canonical green traveler backpack with orange pocket and front chest straps.

const AshStyle = preload("res://pokemon/characters/ash/AshStyle.gd")
const PokemonInkStroke = preload("res://pokemon/scripts/PokemonInkStroke.gd")

var style: AshStyle

var torso_lean: float = 0.0:
	set(val):
		torso_lean = val
		queue_redraw()

var show_bag: bool = true:
	set(val):
		show_bag = val
		queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	draw_set_transform(Vector2.ZERO, torso_lean, Vector2.ONE)
	
	# Coordinates: Origin (0,0) is at mid-torso/chest.
	# Neck is at (0, -38), belt is at (0, 32).
	
	# 0. Canonical Green Backpack Body (behind torso & neck)
	if show_bag:
		_draw_bag_body()
	
	# 1. Neck (Peach skin)
	_draw_neck()
	
	# 2. Black Inner Undershirt
	_draw_undershirt()
	
	# 3. Open Blue Vest
	_draw_vest()
	
	# 4. Green Backpack Chest Straps
	if show_bag:
		_draw_bag_straps()
	
	# 5. Crisp White Collar Wings & Yellow Trim
	_draw_collar_and_trim()
	
	# 6. Belt & Buckle
	_draw_belt()

func _draw_bag_body() -> void:
	# Top carry loop arching behind neck
	var handle_pts := PackedVector2Array([
		Vector2(-9, -42),
		Vector2(-11, -50),
		Vector2(11, -50),
		Vector2(9, -42)
	])
	draw_polyline(handle_pts, style.bag_strap_color, 4.0, false)
	draw_polyline(handle_pts, style.ink_color, 1.4, false)
	
	# Left backpack curve (peeking behind left shoulder)
	var left_pack := PackedVector2Array([
		Vector2(-24, -36),
		Vector2(-37, -26),
		Vector2(-41, 2),
		Vector2(-35, 18),
		Vector2(-25, 14)
	])
	draw_colored_polygon(left_pack, style.bag_green_color)
	draw_polyline(left_pack, style.ink_color, style.outer_contour_width, true)
	
	# Orange side utility pouch on left side (canonical detail from anime references)
	var orange_pocket := PackedVector2Array([
		Vector2(-40, -10),
		Vector2(-33, -10),
		Vector2(-33, 8),
		Vector2(-39, 8)
	])
	draw_colored_polygon(orange_pocket, style.bag_pocket_color)
	draw_polyline(orange_pocket, style.ink_color, style.inner_line_width, true)
	
	# Right backpack curve (peeking behind right shoulder)
	var right_pack := PackedVector2Array([
		Vector2(24, -36),
		Vector2(37, -26),
		Vector2(41, 2),
		Vector2(35, 18),
		Vector2(25, 14)
	])
	draw_colored_polygon(right_pack, style.bag_green_color)
	draw_polyline(right_pack, style.ink_color, style.outer_contour_width, true)

func _draw_bag_straps() -> void:
	# Front chest straps running down both sides of the chest over the vest
	# Left strap
	var left_strap := PackedVector2Array([
		Vector2(-24, -28),
		Vector2(-18, -28),
		Vector2(-13, 26),
		Vector2(-19, 26)
	])
	draw_colored_polygon(left_strap, style.bag_strap_color)
	draw_polyline(left_strap, style.ink_color, style.inner_line_width, true)
	
	# Left strap buckle / adjuster pad
	var left_buckle := Rect2(-23, -8, 7, 7)
	draw_rect(left_buckle, style.belt_buckle_color)
	draw_rect(left_buckle, style.ink_color, false, 1.0)
	
	# Right strap
	var right_strap := PackedVector2Array([
		Vector2(18, -28),
		Vector2(24, -28),
		Vector2(19, 26),
		Vector2(13, 26)
	])
	draw_colored_polygon(right_strap, style.bag_strap_color)
	draw_polyline(right_strap, style.ink_color, style.inner_line_width, true)
	
	# Right strap buckle / adjuster pad
	var right_buckle := Rect2(16, -8, 7, 7)
	draw_rect(right_buckle, style.belt_buckle_color)
	draw_rect(right_buckle, style.ink_color, false, 1.0)

func _draw_neck() -> void:
	var neck_poly := PackedVector2Array([
		Vector2(-8, -48),
		Vector2(-8, -28),
		Vector2(8, -28),
		Vector2(8, -48)
	])
	draw_colored_polygon(neck_poly, style.skin_color)
	
	# Throat shadow
	var shadow_poly := PackedVector2Array([
		Vector2(-8, -48),
		Vector2(8, -48),
		Vector2(6, -40),
		Vector2(-6, -40)
	])
	draw_colored_polygon(shadow_poly, style.skin_shadow_color)
	
	draw_line(Vector2(-8, -48), Vector2(-8, -28), style.ink_color, style.inner_line_width)
	draw_line(Vector2(8, -48), Vector2(8, -28), style.ink_color, style.inner_line_width)

func _draw_undershirt() -> void:
	# Dark inner crewneck shirt visible between vest lapels and at waist
	var shirt_poly := PackedVector2Array([
		Vector2(-12, -28),
		Vector2(12, -28),
		Vector2(14, 28),
		Vector2(-14, 28)
	])
	draw_colored_polygon(shirt_poly, style.undershirt_color)
	draw_polyline(shirt_poly, style.ink_color, style.inner_line_width, true)

func _draw_vest() -> void:
	# Left vest panel (viewer's left)
	var left_vest := PackedVector2Array([
		Vector2(-26, -26), # Shoulder
		Vector2(-9, -24),  # Inner collar
		Vector2(-7, 4),    # Open front lapel edge
		Vector2(-16, 28),  # Bottom front hem
		Vector2(-28, 26),  # Bottom side hem
		Vector2(-30, -8)   # Armpit
	])
	draw_colored_polygon(left_vest, style.vest_blue_color)
	draw_polyline(left_vest, style.ink_color, style.outer_contour_width, true)
	
	# Right vest panel (viewer's right)
	var right_vest := PackedVector2Array([
		Vector2(26, -26), # Shoulder
		Vector2(9, -24),  # Inner collar
		Vector2(7, 4),    # Open front lapel edge
		Vector2(16, 28),  # Bottom front hem
		Vector2(28, 26),  # Bottom side hem
		Vector2(30, -8)   # Armpit
	])
	draw_colored_polygon(right_vest, style.vest_blue_color)
	draw_polyline(right_vest, style.ink_color, style.outer_contour_width, true)

func _draw_collar_and_trim() -> void:
	# White folded collar lapels
	var left_collar := PackedVector2Array([
		Vector2(-9, -24),
		Vector2(-4, -14),
		Vector2(-14, -12),
		Vector2(-24, -25)
	])
	draw_colored_polygon(left_collar, style.vest_white_color)
	draw_polyline(left_collar, style.ink_color, style.inner_line_width, true)
	
	var right_collar := PackedVector2Array([
		Vector2(9, -24),
		Vector2(4, -14),
		Vector2(14, -12),
		Vector2(24, -25)
	])
	draw_colored_polygon(right_collar, style.vest_white_color)
	draw_polyline(right_collar, style.ink_color, style.inner_line_width, true)
	
	# Yellow pocket trim strokes
	var left_trim := PackedVector2Array([
		Vector2(-22, 6),
		Vector2(-14, 8)
	])
	draw_polyline(left_trim, style.vest_trim_color, 2.5, false)
	draw_polyline(left_trim, style.ink_color, 1.2, false)
	
	var right_trim := PackedVector2Array([
		Vector2(22, 6),
		Vector2(14, 8)
	])
	draw_polyline(right_trim, style.vest_trim_color, 2.5, false)
	draw_polyline(right_trim, style.ink_color, 1.2, false)
	
	# Gold button / snaps
	draw_circle(Vector2(-9, 12), 2.2, style.vest_trim_color)
	draw_circle(Vector2(-9, 12), 2.2, style.ink_color, false, 1.0)
	draw_circle(Vector2(9, 12), 2.2, style.vest_trim_color)
	draw_circle(Vector2(9, 12), 2.2, style.ink_color, false, 1.0)

func _draw_belt() -> void:
	var belt_poly := PackedVector2Array([
		Vector2(-20, 27),
		Vector2(20, 27),
		Vector2(19, 36),
		Vector2(-19, 36)
	])
	draw_colored_polygon(belt_poly, style.belt_color)
	draw_polyline(belt_poly, style.ink_color, style.outer_contour_width, true)
	
	# Silver buckle
	var buckle_rect := Rect2(-5, 26, 10, 11)
	draw_rect(buckle_rect, style.belt_buckle_color)
	draw_rect(buckle_rect, style.ink_color, false, style.inner_line_width)
	draw_rect(Rect2(-2, 29, 4, 5), style.belt_color)
