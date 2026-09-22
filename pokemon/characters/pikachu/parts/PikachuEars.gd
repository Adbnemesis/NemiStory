class_name PikachuEars
extends Node2D

## Articulated expressive ears for PIKACHU
## Distinctive long pointed shape with iconic black tips and full independent rotation.

const PokemonInkStroke = preload("res://pokemon/scripts/PokemonInkStroke.gd")
const PikachuStyle = preload("res://pokemon/characters/pikachu/PikachuStyle.gd")

var style: PikachuStyle

# Left and right ear rotations in radians
var left_ear_angle: float = -0.45: # default ~ -26 degrees
	set(val):
		left_ear_angle = val
		queue_redraw()

var right_ear_angle: float = 0.52: # default ~ +30 degrees
	set(val):
		right_ear_angle = val
		queue_redraw()

var ear_droop: float = 0.0: # 0.0 = perked, 1.0 = fully drooped down
	set(val):
		ear_droop = clampf(val, 0.0, 1.5)
		queue_redraw()

var ear_twitch: float = 0.0:
	set(val):
		ear_twitch = val
		queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# Left ear root is around (-16, -24) relative to head center
	_draw_single_ear(Vector2(-16, -24), left_ear_angle - ear_droop * 0.9 + ear_twitch, true)
	
	# Right ear root is around (16, -24) relative to head center
	_draw_single_ear(Vector2(16, -24), right_ear_angle + ear_droop * 0.9 - ear_twitch, false)

func _draw_single_ear(root: Vector2, angle: float, is_left: bool) -> void:
	var sign_x := -1.0 if is_left else 1.0
	
	# Transform for ear rotation around its base
	var xform := Transform2D().rotated(angle).translated(root)
	
	# Ear geometry in local ear space (base at (0,0), tip at (0, -56))
	var base_w := 9.0
	var tip_y := -58.0
	
	var ear_curve := Curve2D.new()
	# Outer curve
	ear_curve.add_point(Vector2(sign_x * -base_w, 0), Vector2(0, 0), Vector2(sign_x * -4, tip_y * 0.4))
	ear_curve.add_point(Vector2(sign_x * -2, tip_y * 0.7), Vector2(sign_x * -3, 6), Vector2(sign_x * 1, -8))
	ear_curve.add_point(Vector2(0, tip_y), Vector2(sign_x * -2, 4), Vector2(sign_x * 2, 4))
	# Inner curve back to base
	ear_curve.add_point(Vector2(sign_x * 2, tip_y * 0.7), Vector2(sign_x * -1, -8), Vector2(sign_x * 3, 6))
	ear_curve.add_point(Vector2(sign_x * base_w, 0), Vector2(sign_x * 4, tip_y * 0.4), Vector2(0, 0))
	
	var ear_pts := ear_curve.tessellate(4, 2.0)
	var xformed_pts := PackedVector2Array()
	xformed_pts.resize(ear_pts.size())
	for i in range(ear_pts.size()):
		xformed_pts[i] = xform * ear_pts[i]
	
	# Fill base yellow
	draw_colored_polygon(xformed_pts, style.fur_base_color)
	
	# Black tip polygon (top 35% of ear: y from -38 to -58)
	var tip_curve := Curve2D.new()
	tip_curve.add_point(Vector2(sign_x * -4.5, tip_y * 0.65), Vector2(0, 0), Vector2(sign_x * -1, -6))
	tip_curve.add_point(Vector2(0, tip_y), Vector2(sign_x * -2, 4), Vector2(sign_x * 2, 4))
	tip_curve.add_point(Vector2(sign_x * 4.5, tip_y * 0.65), Vector2(sign_x * 1, -6), Vector2(0, 0))
	tip_curve.add_point(Vector2(sign_x * -4.5, tip_y * 0.65), Vector2(0, 0), Vector2(0, 0))
	
	var tip_pts := tip_curve.tessellate(3, 2.0)
	var xformed_tip := PackedVector2Array()
	xformed_tip.resize(tip_pts.size())
	for i in range(tip_pts.size()):
		xformed_tip[i] = xform * tip_pts[i]
	
	draw_colored_polygon(xformed_tip, style.ear_tip_color)
	
	# Black tip outline & base boundary
	draw_polyline(xformed_tip, style.ink_color, style.inner_line_width, true)
	
	# Outer ear contour outline
	draw_polyline(xformed_pts, style.ink_color, style.outer_contour_width, true)
