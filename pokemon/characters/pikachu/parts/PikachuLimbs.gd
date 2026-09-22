class_name PikachuLimbs
extends Node2D

## Limbs & Body Silhouette controller for PIKACHU
## Constructs Pikachu's iconic chubby pear-shaped body, back stripes, paws, and feet.

const PokemonInkStroke = preload("res://pokemon/scripts/PokemonInkStroke.gd")
const PikachuStyle = preload("res://pokemon/characters/pikachu/PikachuStyle.gd")

var style: PikachuStyle

# Arm pose states: "rest", "cheer", "wave", "point", "recoil", "hold"
var arm_pose: String = "rest":
	set(val):
		arm_pose = val
		queue_redraw()

var left_arm_offset: Vector2 = Vector2.ZERO:
	set(val):
		left_arm_offset = val
		queue_redraw()

var right_arm_offset: Vector2 = Vector2.ZERO:
	set(val):
		right_arm_offset = val
		queue_redraw()

# Body squash/stretch factor
var body_scale: Vector2 = Vector2.ONE:
	set(val):
		body_scale = val
		queue_redraw()

var body_lean: float = 0.0:
	set(val):
		body_lean = val
		queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	draw_set_transform(Vector2.ZERO, body_lean, body_scale)
	
	# 1. Feet (drawn first, grounded at y = 0)
	_draw_feet()
	
	# 2. Main Chubby Torso / Body Silhouette
	_draw_body_silhouette()
	
	# 3. Back Stripes (Iconic brown markings)
	_draw_back_stripes()
	
	# 4. Arms & Paws
	_draw_arms()

func _draw_feet() -> void:
	# Elongated flat pads resting on ground with 3 toe lines
	var left_foot_poly := PackedVector2Array([
		Vector2(-14, -6),
		Vector2(-32, -4),
		Vector2(-36, 1),
		Vector2(-18, 2),
		Vector2(-12, -2)
	])
	draw_colored_polygon(left_foot_poly, style.fur_base_color)
	draw_polyline(left_foot_poly, style.ink_color, style.outer_contour_width, true)
	
	# Left toe lines
	draw_line(Vector2(-34, -1), Vector2(-30, 1), style.ink_color, style.inner_line_width)
	draw_line(Vector2(-28, -2), Vector2(-24, 1), style.ink_color, style.inner_line_width)
	
	var right_foot_poly := PackedVector2Array([
		Vector2(14, -6),
		Vector2(12, -2),
		Vector2(18, 2),
		Vector2(36, 1),
		Vector2(32, -4)
	])
	draw_colored_polygon(right_foot_poly, style.fur_base_color)
	draw_polyline(right_foot_poly, style.ink_color, style.outer_contour_width, true)
	
	# Right toe lines
	draw_line(Vector2(34, -1), Vector2(30, 1), style.ink_color, style.inner_line_width)
	draw_line(Vector2(28, -2), Vector2(24, 1), style.ink_color, style.inner_line_width)

func _draw_body_silhouette() -> void:
	# Smooth pear-shaped chubby body contour
	# Origin at (0, 0), top at neck (0, -66)
	var body_c := Curve2D.new()
	# Top neck transition
	body_c.add_point(Vector2(0, -66), Vector2(-15, 0), Vector2(15, 0))
	# Right shoulder
	body_c.add_point(Vector2(24, -60), Vector2(-5, -4), Vector2(4, 8))
	# Right torso swell / hip
	body_c.add_point(Vector2(32, -24), Vector2(-2, -12), Vector2(0, 10))
	# Right lower belly
	body_c.add_point(Vector2(24, -2), Vector2(6, -6), Vector2(-10, 3))
	# Bottom belly curve
	body_c.add_point(Vector2(0, 2), Vector2(12, 0), Vector2(-12, 0))
	# Left lower belly
	body_c.add_point(Vector2(-24, -2), Vector2(10, 3), Vector2(-6, -6))
	# Left torso swell / hip
	body_c.add_point(Vector2(-32, -24), Vector2(0, 10), Vector2(-2, -12))
	# Left shoulder
	body_c.add_point(Vector2(-24, -60), Vector2(-4, 8), Vector2(5, -4))
	# Close back to top
	body_c.add_point(Vector2(0, -66), Vector2(-15, 0), Vector2(0, 0))
	
	var body_pts := body_c.tessellate(4, 2.0)
	draw_colored_polygon(body_pts, style.fur_base_color)
	
	# Soft lower shadow for illustrated volume
	var shadow_c := Curve2D.new()
	shadow_c.add_point(Vector2(-28, -16))
	shadow_c.add_point(Vector2(0, -10))
	shadow_c.add_point(Vector2(28, -16))
	shadow_c.add_point(Vector2(24, -2))
	shadow_c.add_point(Vector2(0, 2))
	shadow_c.add_point(Vector2(-24, -2))
	var shadow_pts := shadow_c.tessellate(3, 2.0)
	draw_colored_polygon(shadow_pts, style.fur_shadow_color)
	
	# Outer ink contour
	draw_polyline(body_pts, style.ink_color, style.outer_contour_width, true)

func _draw_back_stripes() -> void:
	# Upper and lower brown back stripes visible on back/side
	var stripe1 := PackedVector2Array([
		Vector2(14, -46),
		Vector2(28, -48),
		Vector2(27, -42),
		Vector2(16, -41)
	])
	draw_colored_polygon(stripe1, style.brown_marking_color)
	draw_polyline(stripe1, style.ink_color, style.inner_line_width, true)
	
	var stripe2 := PackedVector2Array([
		Vector2(16, -34),
		Vector2(31, -35),
		Vector2(29, -29),
		Vector2(18, -28)
	])
	draw_colored_polygon(stripe2, style.brown_marking_color)
	draw_polyline(stripe2, style.ink_color, style.inner_line_width, true)

func _draw_arms() -> void:
	# Arm roots at (-22, -48) and (22, -48)
	var left_root := Vector2(-22, -48)
	var right_root := Vector2(22, -48)
	
	var left_tip := Vector2(-14, -34) + left_arm_offset
	var right_tip := Vector2(14, -34) + right_arm_offset
	
	match arm_pose:
		"cheer":
			left_tip = Vector2(-28, -68) + left_arm_offset
			right_tip = Vector2(28, -68) + right_arm_offset
		"wave":
			left_tip = Vector2(-14, -34) + left_arm_offset
			right_tip = Vector2(34, -64) + right_arm_offset
		"point":
			left_tip = Vector2(-14, -34) + left_arm_offset
			right_tip = Vector2(38, -42) + right_arm_offset
		"recoil":
			left_tip = Vector2(-10, -50) + left_arm_offset
			right_tip = Vector2(10, -50) + right_arm_offset
		"hold":
			left_tip = Vector2(-8, -38) + left_arm_offset
			right_tip = Vector2(8, -38) + right_arm_offset
	
	_draw_single_arm(left_root, left_tip, true)
	_draw_single_arm(right_root, right_tip, false)

func _draw_single_arm(root: Vector2, tip: Vector2, is_left: bool) -> void:
	var sign_x := -1.0 if is_left else 1.0
	
	# Stubby arm polygon with 5 delicate digit notches
	var arm_dir := (tip - root).normalized()
	var arm_norm := Vector2(-arm_dir.y, arm_dir.x)
	var half_w := 6.5
	
	var arm_pts := PackedVector2Array([
		root - arm_norm * half_w * 0.9,
		root + arm_norm * half_w * 0.9,
		tip + arm_norm * half_w * 0.6,
		tip + arm_dir * 3.5,
		tip - arm_norm * half_w * 0.6
	])
	
	draw_colored_polygon(arm_pts, style.fur_base_color)
	draw_polyline(arm_pts, style.ink_color, style.outer_contour_width, true)
	
	# Paw digit lines
	var p1 := tip + arm_dir * 1.5 - arm_norm * 2.2
	var p2 := tip + arm_dir * 1.5 + arm_norm * 2.2
	draw_line(p1, p1 - arm_dir * 3.0, style.ink_color, 1.2)
	draw_line(p2, p2 - arm_dir * 3.0, style.ink_color, 1.2)
