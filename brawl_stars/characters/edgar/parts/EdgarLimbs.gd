class_name EdgarLimbs
extends Node2D

## Skinny Jeans, Fingerless Gloves & Punk Shoes for EDGAR (Brawl Stars)
## Implements the dark indigo skinny pants with red side pinstripe, chunky creepers,
## and slender pale arms with purple fingerless combat gloves (with white "X" stitching).

const EdgarStyle = preload("res://brawl_stars/characters/edgar/EdgarStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: EdgarStyle

var arm_pose: String = "idle_slouch" # idle_slouch, phone_scroll, shrug, hands_in_pockets

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Dark Indigo Skinny Jeans & Red Pinstripe
	_draw_skinny_jeans()
	
	# 2. Chunky Punk Shoes
	_draw_punk_shoes()
	
	# 3. Slender Pale Arms & Purple Fingerless Gloves
	_draw_arms_and_gloves()

func _draw_skinny_jeans() -> void:
	# Pants extend from belt at Y = 92 down to ankles at Y = 138
	var pants := PackedVector2Array([
		Vector2(-30, 92),
		Vector2(-24, 138),
		Vector2(-8, 138),
		Vector2(0, 114), # high crotch inseam
		Vector2(8, 138),
		Vector2(24, 138),
		Vector2(30, 92)
	])
	draw_colored_polygon(pants, style.pants_indigo_color)
	
	# Red side pinstripes
	draw_line(Vector2(-28, 94), Vector2(-22, 138), style.pants_stripe_color, 2.0, true)
	draw_line(Vector2(28, 94), Vector2(22, 138), style.pants_stripe_color, 2.0, true)
	
	# Inseam shadow
	var inseam := PackedVector2Array([
		Vector2(-10, 120),
		Vector2(0, 114),
		Vector2(10, 120),
		Vector2(8, 138),
		Vector2(-8, 138)
	])
	draw_colored_polygon(inseam, style.scarf_purple_shadow_color)
	
	draw_polyline(pants, style.ink_color, style.outer_contour_width, true)

func _draw_punk_shoes() -> void:
	# Left Creeper Shoe
	var l_shoe := PackedVector2Array([
		Vector2(-24, 138),
		Vector2(-28, 150),
		Vector2(-36, 154), # chunky toe
		Vector2(-8, 154),  # heel
		Vector2(-8, 138)
	])
	draw_colored_polygon(l_shoe, style.hair_black_color)
	# Thick sole
	draw_line(Vector2(-36, 153), Vector2(-8, 153), style.glove_purple_color, 3.2, true)
	draw_polyline(l_shoe, style.ink_color, style.inner_line_width, true)
	
	# Right Creeper Shoe
	var r_shoe := PackedVector2Array([
		Vector2(8, 138),
		Vector2(8, 154),
		Vector2(36, 154),
		Vector2(28, 150),
		Vector2(24, 138)
	])
	draw_colored_polygon(r_shoe, style.hair_black_color)
	draw_line(Vector2(8, 153), Vector2(36, 153), style.glove_purple_color, 3.2, true)
	draw_polyline(r_shoe, style.ink_color, style.inner_line_width, true)

func _draw_arms_and_gloves() -> void:
	match arm_pose:
		"phone_scroll":
			# Left arm relaxed down
			_draw_relaxed_arm(true)
			# Right arm bent holding smartphone
			_draw_phone_arm()
		
		"shrug":
			# Both arms raised in cynical "what did you expect" shrug
			_draw_shrug_arms()
		
		"hands_in_pockets":
			# Arms tucked into pants pockets
			_draw_pocket_arms()
		
		_: # "idle_slouch"
			_draw_relaxed_arm(true)
			_draw_relaxed_arm(false)

func _draw_relaxed_arm(is_left: bool) -> void:
	var sign_x := -1.0 if is_left else 1.0
	var shoulder := Vector2(38 * sign_x, 34)
	var elbow := Vector2(44 * sign_x, 62)
	var wrist := Vector2(40 * sign_x, 88)
	
	# Pale arm
	draw_line(shoulder, elbow, style.skin_pale_color, 8.0, true)
	draw_line(elbow, wrist, style.skin_pale_color, 7.0, true)
	draw_line(shoulder, elbow, style.ink_color, style.inner_line_width, true)
	draw_line(elbow, wrist, style.ink_color, style.inner_line_width, true)
	
	# Purple fingerless combat glove
	var g_center := wrist + Vector2(2 * sign_x, 10)
	draw_circle(g_center, 8.5, style.glove_purple_color)
	
	# White "X" stitch across knuckle
	draw_line(g_center + Vector2(-3, -3), g_center + Vector2(3, 3), Color.WHITE, 1.8, true)
	draw_line(g_center + Vector2(3, -3), g_center + Vector2(-3, 3), Color.WHITE, 1.8, true)
	
	# Pale fingertips peeking out of fingerless cut
	draw_line(g_center + Vector2(-3, 8), g_center + Vector2(3, 8), style.skin_pale_color, 3.2, true)
	draw_arc(g_center, 8.5, 0, TAU, 16, style.ink_color, 1.8, true)

func _draw_phone_arm() -> void:
	var shoulder := Vector2(38, 34)
	var hand_pos := Vector2(24, 70)
	
	# Bent arm
	draw_line(shoulder, Vector2(50, 56), style.skin_pale_color, 7.5, true)
	draw_line(Vector2(50, 56), hand_pos, style.skin_pale_color, 7.0, true)
	draw_line(shoulder, Vector2(50, 56), style.ink_color, style.inner_line_width, true)
	draw_line(Vector2(50, 56), hand_pos, style.ink_color, style.inner_line_width, true)
	
	# Hand holding phone
	draw_circle(hand_pos, 8.0, style.glove_purple_color)
	
	# Dark smartphone screen
	var phone_rect := Rect2(hand_pos.x - 5, hand_pos.y - 14, 10, 18)
	draw_rect(phone_rect, Color("#14141c"))
	draw_rect(phone_rect, style.ink_color, false, 1.4)
	# Glowing blue app message screen
	draw_rect(Rect2(hand_pos.x - 3, hand_pos.y - 12, 6, 14), Color("#30a8f8"))

func _draw_shrug_arms() -> void:
	for is_left in [true, false]:
		var sign_x := -1.0 if is_left else 1.0
		var shoulder := Vector2(38 * sign_x, 34)
		var elbow := Vector2(54 * sign_x, 50)
		var palm := Vector2(62 * sign_x, 38)
		
		draw_line(shoulder, elbow, style.skin_pale_color, 7.5, true)
		draw_line(elbow, palm, style.skin_pale_color, 7.0, true)
		draw_line(shoulder, elbow, style.ink_color, style.inner_line_width, true)
		draw_line(elbow, palm, style.ink_color, style.inner_line_width, true)
		
		draw_circle(palm, 8.0, style.glove_purple_color)
		draw_arc(palm, 8.0, 0, TAU, 16, style.ink_color, 1.8, true)

func _draw_pocket_arms() -> void:
	for is_left in [true, false]:
		var sign_x := -1.0 if is_left else 1.0
		var shoulder := Vector2(38 * sign_x, 34)
		var elbow := Vector2(46 * sign_x, 58)
		var pocket := Vector2(30 * sign_x, 82)
		
		draw_line(shoulder, elbow, style.skin_pale_color, 7.5, true)
		draw_line(elbow, pocket, style.skin_pale_color, 7.0, true)
		draw_line(shoulder, elbow, style.ink_color, style.inner_line_width, true)
		draw_line(elbow, pocket, style.ink_color, style.inner_line_width, true)
