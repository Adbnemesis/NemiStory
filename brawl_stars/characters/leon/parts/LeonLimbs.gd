class_name LeonLimbs
extends Node2D

## Legs, Indigo Shorts, Bare Feet & Blue Mitten Hands for LEON (Brawl Stars)
## Implements the cropped indigo shorts, bare tanned legs, and expressive blue mittens
## (tucked in kangaroo pouch, gesturing in frantic sales pitch, or throwing shurikens).

const LeonStyle = preload("res://brawl_stars/characters/leon/LeonStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: LeonStyle

var arm_pose: String = "in_pockets" # in_pockets, gesture_pitch, panic_flail, holding_shuriken, on_hips
var stance: String = "neutral"       # neutral, wide, con_artist_lean, crouch

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Dark Indigo Shorts
	_draw_shorts()
	
	# 2. Bare Tanned Legs & Feet
	_draw_legs_and_feet()
	
	# 3. Arms & Blue Mittens
	_draw_arms_and_mittens()

func _draw_shorts() -> void:
	# Shorts extend from Y = 95 down to Y = 120
	var shorts_pts := PackedVector2Array([
		Vector2(-35, 96),
		Vector2(-38, 118),
		Vector2(-6, 120),
		Vector2(0, 110), # crotch inseam
		Vector2(6, 120),
		Vector2(38, 118),
		Vector2(35, 96)
	])
	draw_colored_polygon(shorts_pts, style.shorts_indigo_color)
	
	# Inseam shadow
	var inseam_sh := PackedVector2Array([
		Vector2(-12, 114),
		Vector2(0, 110),
		Vector2(12, 114),
		Vector2(6, 120),
		Vector2(-6, 120)
	])
	draw_colored_polygon(inseam_sh, style.shorts_shadow_color)
	
	draw_polyline(shorts_pts, style.ink_color, style.outer_contour_width, true)

func _draw_legs_and_feet() -> void:
	# Left Leg
	var l_leg := PackedVector2Array([
		Vector2(-28, 118),
		Vector2(-28, 142),
		Vector2(-38, 145), # foot toe
		Vector2(-18, 145), # heel
		Vector2(-16, 119)
	])
	draw_colored_polygon(l_leg, style.skin_tan_color)
	draw_polyline(l_leg, style.ink_color, style.inner_line_width, true)
	
	# Right Leg
	var r_leg := PackedVector2Array([
		Vector2(16, 119),
		Vector2(18, 145),
		Vector2(38, 145),
		Vector2(28, 142),
		Vector2(28, 118)
	])
	draw_colored_polygon(r_leg, style.skin_tan_color)
	draw_polyline(r_leg, style.ink_color, style.inner_line_width, true)

func _draw_arms_and_mittens() -> void:
	match arm_pose:
		"in_pockets":
			# Blue mittens snugly tucked into kangaroo pocket slits
			# Left mitten cuff peeking out
			var l_mit := PackedVector2Array([
				Vector2(-34, 66),
				Vector2(-26, 56),
				Vector2(-20, 62),
				Vector2(-28, 72)
			])
			draw_colored_polygon(l_mit, style.mitten_blue_color)
			draw_polyline(l_mit, style.ink_color, style.inner_line_width, true)
			
			# Right mitten cuff peeking out
			var r_mit := PackedVector2Array([
				Vector2(34, 66),
				Vector2(26, 56),
				Vector2(20, 62),
				Vector2(28, 72)
			])
			draw_colored_polygon(r_mit, style.mitten_blue_color)
			draw_polyline(r_mit, style.ink_color, style.inner_line_width, true)
		
		"gesture_pitch":
			# Con-artist sales pitch: right arm extended forward open-palm, left hand on hip
			# Right Arm sleeve & blue mitten
			var r_sleeve := PackedVector2Array([
				Vector2(38, 48),
				Vector2(65, 52),
				Vector2(63, 64),
				Vector2(38, 62)
			])
			draw_colored_polygon(r_sleeve, style.hood_green_color)
			draw_polyline(r_sleeve, style.ink_color, style.inner_line_width, true)
			
			# Right Mitten gesturing open
			var r_mitten := PackedVector2Array([
				Vector2(65, 52),
				Vector2(84, 48),
				Vector2(88, 56),
				Vector2(82, 66),
				Vector2(63, 64)
			])
			draw_colored_polygon(r_mitten, style.mitten_blue_color)
			# Thumb
			draw_colored_polygon(PackedVector2Array([Vector2(72, 49), Vector2(76, 42), Vector2(81, 46), Vector2(76, 51)]), style.mitten_blue_color)
			draw_polyline(r_mitten, style.ink_color, style.inner_line_width, true)
			
			# Left Arm bent on hip
			var l_sleeve := PackedVector2Array([
				Vector2(-38, 48),
				Vector2(-55, 62),
				Vector2(-46, 75),
				Vector2(-36, 68)
			])
			draw_colored_polygon(l_sleeve, style.hood_green_color)
			draw_polyline(l_sleeve, style.ink_color, style.inner_line_width, true)
			draw_circle(Vector2(-46, 75), 9.0, style.mitten_blue_color)
			draw_arc(Vector2(-46, 75), 9.0, 0, TAU, 16, style.ink_color, 1.8, true)
		
		"panic_flail":
			# Frantic panic: both arms raised up high
			# Left Arm up
			var l_arm := PackedVector2Array([
				Vector2(-36, 40),
				Vector2(-58, 18),
				Vector2(-70, -6),
				Vector2(-58, -12),
				Vector2(-48, 14),
				Vector2(-32, 48)
			])
			draw_colored_polygon(l_arm, style.hood_green_color)
			draw_polyline(l_arm, style.ink_color, style.inner_line_width, true)
			draw_circle(Vector2(-64, -12), 12.0, style.mitten_blue_color)
			draw_arc(Vector2(-64, -12), 12.0, 0, TAU, 16, style.ink_color, 2.0, true)
			
			# Right Arm up
			var r_arm := PackedVector2Array([
				Vector2(36, 40),
				Vector2(58, 18),
				Vector2(70, -6),
				Vector2(58, -12),
				Vector2(48, 14),
				Vector2(32, 48)
			])
			draw_colored_polygon(r_arm, style.hood_green_color)
			draw_polyline(r_arm, style.ink_color, style.inner_line_width, true)
			draw_circle(Vector2(64, -12), 12.0, style.mitten_blue_color)
			draw_arc(Vector2(64, -12), 12.0, 0, TAU, 16, style.ink_color, 2.0, true)
		
		_: # "on_hips"
			# Both hands planted on hips
			draw_circle(Vector2(-44, 76), 10.0, style.mitten_blue_color)
			draw_arc(Vector2(-44, 76), 10.0, 0, TAU, 16, style.ink_color, 2.0, true)
			draw_circle(Vector2(44, 76), 10.0, style.mitten_blue_color)
			draw_arc(Vector2(44, 76), 10.0, 0, TAU, 16, style.ink_color, 2.0, true)
