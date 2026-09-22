class_name EdgarTorso
extends Node2D

## Red Punk Vest, Skull T-Shirt, Pins & Studded Belt for EDGAR (Brawl Stars)
## Implements the bright red sleeveless cropped jacket, distressed white skull graphic,
## yellow smiley pin, Starr Park badge, studded punk belt, and skull buckle.

const EdgarStyle = preload("res://brawl_stars/characters/edgar/EdgarStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: EdgarStyle

var torso_lean: float = 0.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Dark Inner T-Shirt
	_draw_inner_shirt()
	
	# 2. Distressed White Skull Graphic
	_draw_skull_print()
	
	# 3. Bright Red Sleeveless Vest & Popped Collars
	_draw_red_vest()
	
	# 4. Lapel Badges & Pins
	_draw_pins()
	
	# 5. Heavy Studded Punk Belt & Skull Buckle
	_draw_studded_belt()

func _draw_inner_shirt() -> void:
	# Dark shirt extending from neck at Y = 25 down to belt at Y = 82
	var shirt_pts := PackedVector2Array([
		Vector2(-26, 26),
		Vector2(-32, 45),
		Vector2(-30, 80),
		Vector2(30, 80),
		Vector2(32, 45),
		Vector2(26, 26)
	])
	draw_colored_polygon(shirt_pts, style.shirt_dark_color)
	draw_polyline(shirt_pts, style.ink_color, style.inner_line_width, true)

func _draw_skull_print() -> void:
	# Distressed white skull on center chest
	var sc := Vector2(0, 52)
	
	# Skull head oval
	draw_circle(sc, 10.0, style.skull_white_color)
	# Jaw block
	var jaw := PackedVector2Array([
		sc + Vector2(-6, 6),
		sc + Vector2(6, 6),
		sc + Vector2(5, 12),
		sc + Vector2(-5, 12)
	])
	draw_colored_polygon(jaw, style.skull_white_color)
	
	# "X" eye sockets in dark ink
	draw_line(sc + Vector2(-6, -3), sc + Vector2(-2, 1), style.ink_color, 2.0, true)
	draw_line(sc + Vector2(-2, -3), sc + Vector2(-6, 1), style.ink_color, 2.0, true)
	draw_line(sc + Vector2(2, -3), sc + Vector2(6, 1), style.ink_color, 2.0, true)
	draw_line(sc + Vector2(6, -3), sc + Vector2(2, 1), style.ink_color, 2.0, true)
	
	# Nose cavity & teeth slits
	draw_circle(sc + Vector2(0, 4), 1.4, style.ink_color)
	draw_line(sc + Vector2(-3, 8), sc + Vector2(-3, 11), style.ink_color, 1.2, true)
	draw_line(sc + Vector2(0, 8), sc + Vector2(0, 11), style.ink_color, 1.2, true)
	draw_line(sc + Vector2(3, 8), sc + Vector2(3, 11), style.ink_color, 1.2, true)

func _draw_red_vest() -> void:
	# Left Vest Panel
	var left_vest := PackedVector2Array([
		Vector2(-24, 25),
		Vector2(-36, 28), # shoulder
		Vector2(-42, 48), # armhole
		Vector2(-32, 80), # waist
		Vector2(-12, 80),
		Vector2(-14, 48)  # lapel opening
	])
	draw_colored_polygon(left_vest, style.vest_red_color)
	
	# Left shadow
	var l_sh := PackedVector2Array([
		Vector2(-36, 28),
		Vector2(-42, 48),
		Vector2(-32, 80),
		Vector2(-26, 80),
		Vector2(-34, 52)
	])
	draw_colored_polygon(l_sh, style.vest_red_shadow_color)
	draw_polyline(left_vest, style.ink_color, style.outer_contour_width, true)
	
	# Right Vest Panel
	var right_vest := PackedVector2Array([
		Vector2(24, 25),
		Vector2(36, 28),
		Vector2(42, 48),
		Vector2(32, 80),
		Vector2(12, 80),
		Vector2(14, 48)
	])
	draw_colored_polygon(right_vest, style.vest_red_color)
	
	var r_sh := PackedVector2Array([
		Vector2(36, 28),
		Vector2(42, 48),
		Vector2(32, 80),
		Vector2(26, 80),
		Vector2(34, 52)
	])
	draw_colored_polygon(r_sh, style.vest_red_shadow_color)
	draw_polyline(right_vest, style.ink_color, style.outer_contour_width, true)

func _draw_pins() -> void:
	# Yellow smiley button pin on left lapel
	var pin_pos := Vector2(-22, 40)
	draw_circle(pin_pos, 5.5, style.pin_yellow_color)
	draw_circle(pin_pos + Vector2(-1.5, -1.0), 1.0, style.ink_color)
	draw_circle(pin_pos + Vector2(1.5, -1.0), 1.0, style.ink_color)
	draw_arc(pin_pos + Vector2(0, 1.0), 2.5, 0.2, PI - 0.2, 8, style.ink_color, 1.2, true)
	draw_arc(pin_pos, 5.5, 0, TAU, 16, style.ink_color, 1.4, true)
	
	# Starr Park chick / panda pin on right lapel
	var chick_pos := Vector2(20, 38)
	draw_circle(chick_pos, 5.0, Color.WHITE)
	draw_circle(chick_pos + Vector2(-1.5, -0.5), 1.0, style.ink_color)
	draw_circle(chick_pos + Vector2(1.5, -0.5), 1.0, style.ink_color)
	# Orange beak dot
	draw_circle(chick_pos + Vector2(0, 1.5), 1.4, Color("#f48018"))
	draw_arc(chick_pos, 5.0, 0, TAU, 16, style.ink_color, 1.4, true)

func _draw_studded_belt() -> void:
	# Thick dark punk belt from Y = 80 to Y = 92
	var belt_pts := PackedVector2Array([
		Vector2(-32, 80),
		Vector2(-32, 92),
		Vector2(32, 92),
		Vector2(32, 80)
	])
	draw_colored_polygon(belt_pts, style.belt_dark_color)
	draw_polyline(belt_pts, style.ink_color, style.outer_contour_width, true)
	
	# Silver square studs along the belt
	for x in [-26, -18, -10, 10, 18, 26]:
		draw_rect(Rect2(x - 2.5, 83.5, 5, 5), style.stud_silver_color)
		draw_rect(Rect2(x - 2.5, 83.5, 5, 5), style.ink_color, false, 1.0)
	
	# Light blue skull buckle on center
	var b_pos := Vector2(0, 86)
	draw_circle(b_pos, 7.0, style.buckle_skull_color)
	draw_circle(b_pos + Vector2(-2.2, -1.0), 1.6, style.ink_color)
	draw_circle(b_pos + Vector2(2.2, -1.0), 1.6, style.ink_color)
	draw_line(b_pos + Vector2(-2, 3), b_pos + Vector2(2, 3), style.ink_color, 1.4, true)
	draw_arc(b_pos, 7.0, 0, TAU, 16, style.ink_color, 1.8, true)
