class_name AshLimbs
extends Node2D

## Limbs, Hands & Feet for ASH KETCHUM
## Features articulated arms with fingerless gloves, jeans with rolled cuffs,
## and canonical high-top sneakers with red ankle badges.

const AshStyle = preload("res://pokemon/characters/ash/AshStyle.gd")
const PokemonInkStroke = preload("res://pokemon/scripts/PokemonInkStroke.gd")

var style: AshStyle

# Arm pose: "rest", "confident", "point", "crossed", "hold_ball", "scratch_head", "shrug", "recoil"
var arm_pose: String = "rest":
	set(val):
		arm_pose = val
		queue_redraw()

var left_hand_pos: Vector2 = Vector2(-36, 12):
	set(val):
		left_hand_pos = val
		queue_redraw()

var right_hand_pos: Vector2 = Vector2(36, 12):
	set(val):
		right_hand_pos = val
		queue_redraw()

var leg_stance: String = "stand": # "stand", "crouch", "wide"
	set(val):
		leg_stance = val
		queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# Origin (0,0) is at waist/belt line (y = -105 in character space).
	# Ground is at y = 140 (feet contact line).
	
	# 1. Legs & Jeans
	_draw_legs()
	
	# 2. Sneakers
	_draw_shoes()
	
	# 3. Arms & Hands
	_draw_arms()

func _draw_legs() -> void:
	# Left and right denim jeans
	var hip_y := 0.0
	var knee_y := 65.0
	var cuff_y := 118.0
	
	var left_leg := PackedVector2Array([
		Vector2(-18, hip_y),
		Vector2(-2, hip_y + 10), # Crotch
		Vector2(-8, knee_y),
		Vector2(-12, cuff_y),
		Vector2(-26, cuff_y),
		Vector2(-24, knee_y),
		Vector2(-20, hip_y)
	])
	draw_colored_polygon(left_leg, style.jeans_color)
	draw_polyline(left_leg, style.ink_color, style.outer_contour_width, true)
	
	var right_leg := PackedVector2Array([
		Vector2(2, hip_y + 10), # Crotch
		Vector2(18, hip_y),
		Vector2(20, hip_y),
		Vector2(24, knee_y),
		Vector2(26, cuff_y),
		Vector2(12, cuff_y),
		Vector2(8, knee_y)
	])
	draw_colored_polygon(right_leg, style.jeans_color)
	draw_polyline(right_leg, style.ink_color, style.outer_contour_width, true)
	
	# Knee crease lines
	draw_line(Vector2(-20, knee_y - 2), Vector2(-12, knee_y + 2), style.ink_color, style.inner_line_width)
	draw_line(Vector2(12, knee_y + 2), Vector2(20, knee_y - 2), style.ink_color, style.inner_line_width)
	
	# Rolled-up white cuffs at bottom of jeans
	var left_cuff := Rect2(-28, cuff_y, 18, 9)
	draw_rect(left_cuff, style.jeans_cuff_color)
	draw_rect(left_cuff, style.ink_color, false, style.outer_contour_width)
	
	var right_cuff := Rect2(10, cuff_y, 18, 9)
	draw_rect(right_cuff, style.jeans_cuff_color)
	draw_rect(right_cuff, style.ink_color, false, style.outer_contour_width)

func _draw_shoes() -> void:
	var shoe_y := 127.0
	
	# Left sneaker
	var l_shoe := PackedVector2Array([
		Vector2(-26, shoe_y),
		Vector2(-10, shoe_y),
		Vector2(-8, shoe_y + 12),
		Vector2(-2, shoe_y + 18),
		Vector2(-32, shoe_y + 18),
		Vector2(-34, shoe_y + 10)
	])
	draw_colored_polygon(l_shoe, style.shoe_black_color)
	
	# White toe-box & rubber sole
	var l_toe := PackedVector2Array([
		Vector2(-10, shoe_y + 10),
		Vector2(-2, shoe_y + 18),
		Vector2(-14, shoe_y + 18),
		Vector2(-15, shoe_y + 10)
	])
	draw_colored_polygon(l_toe, style.shoe_white_color)
	
	# Red circle badge on ankle
	draw_circle(Vector2(-24, shoe_y + 7), 3.2, style.shoe_red_color)
	draw_circle(Vector2(-24, shoe_y + 7), 3.2, style.ink_color, false, 1.0)
	
	draw_polyline(l_shoe, style.ink_color, style.outer_contour_width, true)
	
	# Right sneaker
	var r_shoe := PackedVector2Array([
		Vector2(10, shoe_y),
		Vector2(26, shoe_y),
		Vector2(34, shoe_y + 10),
		Vector2(32, shoe_y + 18),
		Vector2(2, shoe_y + 18),
		Vector2(8, shoe_y + 12)
	])
	draw_colored_polygon(r_shoe, style.shoe_black_color)
	
	# White toe-box & rubber sole
	var r_toe := PackedVector2Array([
		Vector2(10, shoe_y + 10),
		Vector2(15, shoe_y + 10),
		Vector2(14, shoe_y + 18),
		Vector2(2, shoe_y + 18)
	])
	draw_colored_polygon(r_toe, style.shoe_white_color)
	
	# Red circle badge on ankle
	draw_circle(Vector2(24, shoe_y + 7), 3.2, style.shoe_red_color)
	draw_circle(Vector2(24, shoe_y + 7), 3.2, style.ink_color, false, 1.0)
	
	draw_polyline(r_shoe, style.ink_color, style.outer_contour_width, true)

func _draw_arms() -> void:
	var l_shoulder := Vector2(-28, -60)
	var r_shoulder := Vector2(28, -60)
	
	var l_hand := Vector2(-36, 6)
	var r_hand := Vector2(36, 6)
	
	match arm_pose:
		"confident":
			l_hand = Vector2(-24, -2) # Hand on hip
			r_hand = Vector2(38, -52) # Raised victory fist
		"point":
			l_hand = Vector2(-24, -2)
			r_hand = Vector2(62, -26) # Pointing straight forward
		"crossed":
			l_hand = Vector2(8, -26)
			r_hand = Vector2(-8, -26)
		"hold_ball":
			l_hand = Vector2(-24, -2)
			r_hand = Vector2(32, -40) # Cupped holding Poké Ball
		"scratch_head":
			l_hand = Vector2(-26, 4)
			r_hand = Vector2(22, -88) # Behind cap/head
		"shrug":
			l_hand = Vector2(-48, -18) # Palms up wide
			r_hand = Vector2(48, -18)
		"recoil":
			l_hand = Vector2(-16, -42) # Close to chest
			r_hand = Vector2(16, -42)
	
	_draw_single_arm(l_shoulder, l_hand, true)
	_draw_single_arm(r_shoulder, r_hand, false)

func _draw_single_arm(shoulder: Vector2, hand: Vector2, is_left: bool) -> void:
	var sign_x := -1.0 if is_left else 1.0
	
	# 1. White short sleeve cuff at shoulder
	var cuff_poly := PackedVector2Array([
		shoulder + Vector2(-6 * sign_x, -4),
		shoulder + Vector2(6 * sign_x, -4),
		shoulder + Vector2(7 * sign_x, 14),
		shoulder + Vector2(-7 * sign_x, 14)
	])
	draw_colored_polygon(cuff_poly, style.vest_white_color)
	draw_polyline(cuff_poly, style.ink_color, style.outer_contour_width, true)
	
	# 2. Forearm (Skin)
	var elbow := (shoulder + hand) * 0.5 + Vector2(sign_x * 8, 0)
	var arm_line := PackedVector2Array([
		shoulder + Vector2(0, 12),
		elbow,
		hand - (hand - elbow).normalized() * 12
	])
	draw_polyline(arm_line, style.skin_color, 11.0, false)
	draw_polyline(arm_line, style.ink_color, style.outer_contour_width, false)
	
	# 3. Green Fingerless Glove with Mint Cuff
	var glove_dir := (hand - elbow).normalized()
	var glove_norm := Vector2(-glove_dir.y, glove_dir.x)
	var wrist := hand - glove_dir * 10
	
	# Mint cuff
	var mint_cuff := PackedVector2Array([
		wrist - glove_norm * 6,
		wrist + glove_norm * 6,
		wrist + glove_dir * 5 + glove_norm * 6,
		wrist + glove_dir * 5 - glove_norm * 6
	])
	draw_colored_polygon(mint_cuff, style.glove_cuff_color)
	draw_polyline(mint_cuff, style.ink_color, style.inner_line_width, true)
	
	# Green glove body
	var palm_poly := PackedVector2Array([
		wrist + glove_dir * 4 - glove_norm * 5.5,
		wrist + glove_dir * 4 + glove_norm * 5.5,
		hand + glove_norm * 5,
		hand - glove_norm * 5
	])
	draw_colored_polygon(palm_poly, style.glove_green_color)
	draw_polyline(palm_poly, style.ink_color, style.inner_line_width, true)
	
	# Exposed peach fingers
	var finger_tip := hand + glove_dir * 6
	var fingers := PackedVector2Array([
		hand - glove_norm * 4,
		finger_tip - glove_norm * 2,
		finger_tip + glove_norm * 2,
		hand + glove_norm * 4
	])
	draw_colored_polygon(fingers, style.skin_color)
	draw_polyline(fingers, style.ink_color, style.inner_line_width, true)
