class_name NemiCarouselCharacter
extends Node2D

## Independent Native Vector Character for NEMI
## Designed specifically for static 1080x1350 carousel compositions.
## Zero AI images, zero raster dependencies, 100% vector drawing.

const Geo = preload("res://carousel/nemi/character/NemiVectorGeometry.gd")

@export var current_pose: String = "relaxed_standing"
@export var current_expression: String = "neutral"
@export var is_peeking: bool = false
@export var peek_direction: String = "bottom" # "bottom", "left", "right"
@export var show_props: bool = true

# Pose transform offsets
var head_offset: Vector2 = Vector2.ZERO
var head_rotation: float = 0.0
var left_arm_angle: float = 0.2
var right_arm_angle: float = -0.2
var body_offset: Vector2 = Vector2.ZERO
var body_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	queue_redraw()

func set_pose(pose_name: String) -> void:
	current_pose = pose_name
	_apply_pose_parameters(pose_name)
	queue_redraw()

func set_expression(expr_name: String) -> void:
	current_expression = expr_name
	queue_redraw()

func _apply_pose_parameters(p: String) -> void:
	# Reset defaults
	head_offset = Vector2.ZERO
	head_rotation = 0.0
	left_arm_angle = 0.2
	right_arm_angle = -0.2
	body_offset = Vector2.ZERO
	body_scale = Vector2.ONE
	is_peeking = false
	
	match p:
		"peek_bottom_inquisitive":
			is_peeking = true
			peek_direction = "bottom"
			head_offset = Vector2(0, 15)
			head_rotation = -0.08
			left_arm_angle = 1.4
			right_arm_angle = -1.4
		"peek_right_pointing":
			is_peeking = true
			peek_direction = "right"
			head_offset = Vector2(10, 0)
			head_rotation = 0.05
			left_arm_angle = 1.8
			right_arm_angle = -0.4
		"dramatic_panic_sprawl":
			head_offset = Vector2(-15, 20)
			head_rotation = 0.22
			left_arm_angle = 2.1
			right_arm_angle = -2.1
			body_offset = Vector2(0, 40)
		"hero_sparkle_triumph":
			head_offset = Vector2(0, -10)
			head_rotation = 0.0
			left_arm_angle = 2.4
			right_arm_angle = -2.4
		"comic_recoil_shock":
			head_offset = Vector2(-25, -15)
			head_rotation = -0.25
			left_arm_angle = 1.9
			right_arm_angle = -1.2
		"thinking_chin_tap":
			head_offset = Vector2(10, -5)
			head_rotation = 0.12
			left_arm_angle = 0.4
			right_arm_angle = -1.9
		"sit_on_card":
			body_offset = Vector2(0, -20)
			left_arm_angle = 0.5
			right_arm_angle = -0.5
		"hold_cta_sign":
			left_arm_angle = 1.6
			right_arm_angle = -1.6
		"relaxed_standing", _:
			head_offset = Vector2.ZERO
			head_rotation = 0.0
			left_arm_angle = 0.2
			right_arm_angle = -0.2

func _draw() -> void:
	# 1. Hair Back Volume
	var hair_back := Geo.get_hair_back_polygon()
	draw_colored_polygon(_transform_pts(hair_back, head_offset, head_rotation), Geo.COLOR_HAIR)
	_draw_ink_stroke(_transform_pts(hair_back, head_offset, head_rotation), Geo.COLOR_INK, 3.5)
	
	# If peeking from bottom, skip lower body and legs
	if not (is_peeking and peek_direction == "bottom"):
		# 2. Skirt & Legs
		_draw_legs_and_skirt()
		
		# 3. Torso / Cowl Hoodie
		var torso := Geo.get_hoodie_torso_polygon()
		draw_colored_polygon(_transform_pts(torso, body_offset, 0.0), Geo.COLOR_HOODIE)
		_draw_ink_stroke(_transform_pts(torso, body_offset, 0.0), Geo.COLOR_INK, 4.0)
		
		# Draw Arms according to pose
		_draw_arms()
	
	# 4. Cowl Neck Collar
	var cowl := Geo.get_cowl_collar_polygon()
	draw_colored_polygon(_transform_pts(cowl, body_offset, 0.0), Geo.COLOR_HOODIE_SHADOW)
	_draw_ink_stroke(_transform_pts(cowl, body_offset, 0.0), Geo.COLOR_INK, 3.5)
	
	# 5. Head Base & Skin
	var head := Geo.get_head_polygon()
	draw_colored_polygon(_transform_pts(head, head_offset, head_rotation), Geo.COLOR_SKIN)
	var jaw := Geo.get_jaw_outline()
	_draw_ink_stroke(_transform_pts(jaw, head_offset, head_rotation), Geo.COLOR_INK, 3.8)
	
	# 6. Facial Features
	_draw_face()
	
	# 7. Bangs & Front Fringe
	var bangs := Geo.get_front_bangs_polygon()
	draw_colored_polygon(_transform_pts(bangs, head_offset, head_rotation), Geo.COLOR_HAIR)
	_draw_ink_stroke(_transform_pts(bangs, head_offset, head_rotation), Geo.COLOR_INK, 3.2)
	
	# 8. Bouncing Ahoge Lock
	var ahoge := Geo.get_ahoge_points()
	_draw_ink_stroke(_transform_pts(ahoge, head_offset, head_rotation), Geo.COLOR_HAIR, 4.0)
	_draw_ink_stroke(_transform_pts(ahoge, head_offset, head_rotation), Geo.COLOR_INK, 2.0)
	
	# 9. Peek Hands (if peeking from bottom border)
	if is_peeking and peek_direction == "bottom":
		_draw_peek_hands()

func _draw_legs_and_skirt() -> void:
	# Skirt
	var skirt := Geo.get_skirt_polygon()
	draw_colored_polygon(_transform_pts(skirt, body_offset, 0.0), Geo.COLOR_SKIRT)
	_draw_ink_stroke(_transform_pts(skirt, body_offset, 0.0), Geo.COLOR_INK, 3.8)
	
	# Pleat Crease Lines
	draw_line(Vector2(-18, 140) + body_offset, Vector2(-22, 195) + body_offset, Geo.COLOR_INK, 2.0)
	draw_line(Vector2(0, 140) + body_offset, Vector2(0, 198) + body_offset, Geo.COLOR_INK, 2.0)
	draw_line(Vector2(18, 140) + body_offset, Vector2(22, 195) + body_offset, Geo.COLOR_INK, 2.0)
	
	# Legs & Socks
	var leg_left := PackedVector2Array([Vector2(-20, 195), Vector2(-12, 195), Vector2(-14, 280), Vector2(-22, 280)])
	var leg_right := PackedVector2Array([Vector2(12, 195), Vector2(20, 195), Vector2(22, 280), Vector2(14, 280)])
	draw_colored_polygon(_transform_pts(leg_left, body_offset, 0.0), Geo.COLOR_SKIN)
	draw_colored_polygon(_transform_pts(leg_right, body_offset, 0.0), Geo.COLOR_SKIN)
	_draw_ink_stroke(_transform_pts(leg_left, body_offset, 0.0), Geo.COLOR_INK, 2.5)
	_draw_ink_stroke(_transform_pts(leg_right, body_offset, 0.0), Geo.COLOR_INK, 2.5)
	
	# Platform Dad Sneakers
	_draw_sneaker(Vector2(-18, 280) + body_offset, -1.0)
	_draw_sneaker(Vector2(18, 280) + body_offset, 1.0)

func _draw_sneaker(pos: Vector2, dir: float) -> void:
	var sole := PackedVector2Array([
		pos, pos + Vector2(28 * dir, 0), pos + Vector2(30 * dir, 18), pos + Vector2(-6 * dir, 18), pos + Vector2(-6 * dir, 6)
	])
	draw_colored_polygon(sole, Geo.COLOR_SNEAKER_SOLE)
	_draw_ink_stroke(sole, Geo.COLOR_INK, 2.8)
	# Emerald trim stripe
	draw_line(pos + Vector2(6 * dir, 10), pos + Vector2(24 * dir, 10), Geo.COLOR_EYE_IRIS, 2.5)

func _draw_arms() -> void:
	# Left Arm
	var left_hand_pos := Vector2(-45, 60) + Vector2(sin(left_arm_angle), cos(left_arm_angle)) * 65.0
	draw_line(Vector2(-45, 40) + body_offset, left_hand_pos + body_offset, Geo.COLOR_HOODIE, 18.0)
	draw_line(Vector2(-45, 40) + body_offset, left_hand_pos + body_offset, Geo.COLOR_INK, 3.0)
	draw_circle(left_hand_pos + body_offset, 8.0, Geo.COLOR_SKIN)
	draw_arc(left_hand_pos + body_offset, 8.0, 0, TAU, 16, Geo.COLOR_INK, 2.0)
	
	# Right Arm
	var right_hand_pos := Vector2(45, 60) + Vector2(sin(right_arm_angle), cos(right_arm_angle)) * 65.0
	draw_line(Vector2(45, 40) + body_offset, right_hand_pos + body_offset, Geo.COLOR_HOODIE, 18.0)
	draw_line(Vector2(45, 40) + body_offset, right_hand_pos + body_offset, Geo.COLOR_INK, 3.0)
	draw_circle(right_hand_pos + body_offset, 8.0, Geo.COLOR_SKIN)
	draw_arc(right_hand_pos + body_offset, 8.0, 0, TAU, 16, Geo.COLOR_INK, 2.0)

func _draw_peek_hands() -> void:
	# Hands clutching the bottom border
	draw_circle(Vector2(-35, 10) + head_offset, 12.0, Geo.COLOR_SKIN)
	draw_arc(Vector2(-35, 10) + head_offset, 12.0, 0, TAU, 16, Geo.COLOR_INK, 2.5)
	draw_circle(Vector2(35, 10) + head_offset, 12.0, Geo.COLOR_SKIN)
	draw_arc(Vector2(35, 10) + head_offset, 12.0, 0, TAU, 16, Geo.COLOR_INK, 2.5)

func _draw_face() -> void:
	var h_pos := head_offset
	
	# 1. Blush Hatches (45-degree anime scratches)
	draw_line(h_pos + Vector2(-32, -22), h_pos + Vector2(-26, -28), Geo.COLOR_BLUSH, 3.0)
	draw_line(h_pos + Vector2(-28, -20), h_pos + Vector2(-22, -26), Geo.COLOR_BLUSH, 3.0)
	draw_line(h_pos + Vector2(22, -26), h_pos + Vector2(28, -20), Geo.COLOR_BLUSH, 3.0)
	draw_line(h_pos + Vector2(26, -28), h_pos + Vector2(32, -22), Geo.COLOR_BLUSH, 3.0)
	
	# 2. Nose (tiny subtle ink dot/flick)
	draw_line(h_pos + Vector2(0, -18), h_pos + Vector2(1, -16), Geo.COLOR_INK, 2.2)
	
	# 3. Eyes & Brows based on expression
	match current_expression:
		"sparkle_happy":
			# Curved eye arcs + sparkles
			draw_arc(h_pos + Vector2(-18, -32), 10.0, PI + 0.3, TAU - 0.3, 16, Geo.COLOR_INK, 3.5)
			draw_arc(h_pos + Vector2(18, -32), 10.0, PI + 0.3, TAU - 0.3, 16, Geo.COLOR_INK, 3.5)
			_draw_star_glint(h_pos + Vector2(-18, -32), 6.0, Geo.COLOR_EYE_IRIS)
			_draw_star_glint(h_pos + Vector2(18, -32), 6.0, Geo.COLOR_EYE_IRIS)
			# Arched Brows
			draw_arc(h_pos + Vector2(-18, -48), 12.0, PI + 0.4, TAU - 0.4, 12, Geo.COLOR_HAIR, 3.0)
			draw_arc(h_pos + Vector2(18, -48), 12.0, PI + 0.4, TAU - 0.4, 12, Geo.COLOR_HAIR, 3.0)
			# Mouth: Happy open 'D'
			_draw_open_mouth(h_pos + Vector2(0, -6), 14.0)
			
		"dramatic_panic", "shocked":
			# Wide circular shock eyes
			draw_circle(h_pos + Vector2(-18, -34), 10.0, Color.WHITE)
			draw_circle(h_pos + Vector2(18, -34), 10.0, Color.WHITE)
			draw_arc(h_pos + Vector2(-18, -34), 10.0, 0, TAU, 20, Geo.COLOR_INK, 3.0)
			draw_arc(h_pos + Vector2(18, -34), 10.0, 0, TAU, 20, Geo.COLOR_INK, 3.0)
			# Tiny pinpoint pupils
			draw_circle(h_pos + Vector2(-18, -34), 3.0, Geo.COLOR_EYE_PUPIL)
			draw_circle(h_pos + Vector2(18, -34), 3.0, Geo.COLOR_EYE_PUPIL)
			# Wavy panic eyebrows
			draw_line(h_pos + Vector2(-28, -52), h_pos + Vector2(-10, -48), Geo.COLOR_HAIR, 3.0)
			draw_line(h_pos + Vector2(10, -48), h_pos + Vector2(28, -52), Geo.COLOR_HAIR, 3.0)
			# Open wavy gasp mouth
			draw_circle(h_pos + Vector2(0, -6), 9.0, Geo.COLOR_INK)
			draw_circle(h_pos + Vector2(0, -6), 6.0, Color("#d64937"))
			
		"thinking":
			# Looking up-right
			_draw_almond_eye(h_pos + Vector2(-18, -32), Vector2(0.5, -0.4))
			_draw_almond_eye(h_pos + Vector2(18, -32), Vector2(0.5, -0.4))
			# Asymmetric brows
			draw_line(h_pos + Vector2(-26, -48), h_pos + Vector2(-10, -52), Geo.COLOR_HAIR, 3.0)
			draw_line(h_pos + Vector2(10, -50), h_pos + Vector2(26, -46), Geo.COLOR_HAIR, 3.0)
			# Small purse mouth
			draw_line(h_pos + Vector2(-4, -6), h_pos + Vector2(5, -7), Geo.COLOR_INK, 2.5)
			
		"exhausted":
			# Drooped half-closed eyes
			draw_line(h_pos + Vector2(-26, -32), h_pos + Vector2(-10, -32), Geo.COLOR_INK, 3.5)
			draw_line(h_pos + Vector2(10, -32), h_pos + Vector2(26, -32), Geo.COLOR_INK, 3.5)
			# Flat brows
			draw_line(h_pos + Vector2(-26, -46), h_pos + Vector2(-10, -44), Geo.COLOR_HAIR, 2.8)
			draw_line(h_pos + Vector2(10, -44), h_pos + Vector2(26, -46), Geo.COLOR_HAIR, 2.8)
			# Straight dash mouth
			draw_line(h_pos + Vector2(-8, -6), h_pos + Vector2(8, -6), Geo.COLOR_INK, 2.5)
			
		"neutral", _:
			_draw_almond_eye(h_pos + Vector2(-18, -32), Vector2.ZERO)
			_draw_almond_eye(h_pos + Vector2(18, -32), Vector2.ZERO)
			# Relaxed arched brows
			draw_arc(h_pos + Vector2(-18, -48), 12.0, PI + 0.3, TAU - 0.3, 12, Geo.COLOR_HAIR, 2.5)
			draw_arc(h_pos + Vector2(18, -48), 12.0, PI + 0.3, TAU - 0.3, 12, Geo.COLOR_HAIR, 2.5)
			# Small soft smile
			draw_arc(h_pos + Vector2(0, -10), 6.0, 0.2, PI - 0.2, 12, Geo.COLOR_INK, 2.5)

func _draw_almond_eye(center: Vector2, gaze: Vector2) -> void:
	# White Sclera
	draw_circle(center, 9.0, Color.WHITE)
	draw_arc(center, 9.0, 0, TAU, 16, Geo.COLOR_INK, 2.2)
	# Upper Eyelash Weight (Cat-eye flare)
	draw_line(center + Vector2(-11, -5), center + Vector2(11, -5), Geo.COLOR_INK, 3.8)
	# Emerald Bean Iris
	var iris_pos := center + gaze * 3.5
	draw_circle(iris_pos, 5.5, Geo.COLOR_EYE_IRIS)
	draw_circle(iris_pos, 2.8, Geo.COLOR_EYE_PUPIL)
	# Catchlights
	draw_circle(iris_pos + Vector2(-2, -2), 1.6, Color.WHITE)
	draw_circle(iris_pos + Vector2(2, 2), 0.9, Color.WHITE)

func _draw_open_mouth(pos: Vector2, width: float) -> void:
	var pts := PackedVector2Array([
		pos + Vector2(-width * 0.5, 0), pos + Vector2(width * 0.5, 0),
		pos + Vector2(width * 0.4, width * 0.7), pos + Vector2(0, width * 0.85), pos + Vector2(-width * 0.4, width * 0.7)
	])
	draw_colored_polygon(pts, Color("#a83b3b"))
	_draw_ink_stroke(pts, Geo.COLOR_INK, 2.5)

func _draw_star_glint(center: Vector2, size: float, col: Color) -> void:
	draw_line(center - Vector2(size, 0), center + Vector2(size, 0), col, 2.0)
	draw_line(center - Vector2(0, size), center + Vector2(0, size), col, 2.0)

func _transform_pts(pts: PackedVector2Array, offset: Vector2, rot: float) -> PackedVector2Array:
	var res := PackedVector2Array()
	var cos_r := cos(rot)
	var sin_r := sin(rot)
	for p in pts:
		var rx := p.x * cos_r - p.y * sin_r
		var ry := p.x * sin_r + p.y * cos_r
		res.append(Vector2(rx, ry) + offset)
	return res

func _draw_ink_stroke(pts: PackedVector2Array, col: Color, width: float) -> void:
	if pts.size() < 2:
		return
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, col, width, true)
