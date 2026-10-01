class_name ADBCarouselCharacter
extends Node2D

## Independent Native Vector Character for ADB
## Designed specifically for static 1080x1350 carousel compositions.
## Perfectly matches NEMI's carousel comic art style & proportion system:
## - Stylized ~3.5 to 4 heads tall proportion system (Head ~95px, Body ~265px)
## - Bold, expressive 3.2-3.8px ink line art
## - Canonical ADB visual identity from episode 8 & official reference:
##   * Sleek slate curtain-parted mop with two distinctive crown antenna tufts
##   * Sage green button-down shirt with open V-collar lapels & button placket
##   * Rolled-up sleeve cuffs with bare forearms
##   * Relaxed ecru / off-white linen trousers with center creases
##   * Dark canvas sneakers with off-white rubber toe caps
##   * Expressive almond anime eyes with corner hash accents
## Zero AI images, zero raster dependencies, 100% native Godot vector drawing.

const Geo = preload("res://carousel/adb/character/ADBVectorGeometry.gd")

@export var current_pose: String = "relaxed_standing"
@export var current_expression: String = "deadpan"
@export var is_peeking: bool = false
@export var peek_direction: String = "bottom" # "bottom", "left", "right"
@export var show_props: bool = true

# Pose transform offsets (Origin (0, 0) is Chin Apex, matching Nemi)
var head_offset: Vector2 = Vector2.ZERO
var head_rotation: float = 0.0
var body_offset: Vector2 = Vector2.ZERO
var pose_mode: String = "relaxed_standing"

func _ready() -> void:
	queue_redraw()

func set_pose(pose_name: String) -> void:
	current_pose = pose_name.to_lower()
	_apply_pose_parameters(current_pose)
	queue_redraw()

func set_expression(expr_name: String) -> void:
	current_expression = expr_name.to_lower()
	queue_redraw()

func _apply_pose_parameters(p: String) -> void:
	# Reset defaults
	head_offset = Vector2.ZERO
	head_rotation = 0.0
	body_offset = Vector2.ZERO
	is_peeking = false
	pose_mode = "relaxed_standing"
	
	match p:
		"peek_bottom_inquisitive", "peek_bottom_deadpan", "peek_side_deadpan":
			is_peeking = true
			peek_direction = "bottom"
			head_offset = Vector2(0, 15)
			head_rotation = -0.05
			pose_mode = "peek_bottom"
			
		"peek_right_pointing":
			is_peeking = true
			peek_direction = "right"
			head_offset = Vector2(10, 0)
			head_rotation = 0.04
			pose_mode = "peek_right"
			
		"lean_left_margin":
			head_offset = Vector2(-8, -2)
			head_rotation = 0.04
			body_offset = Vector2(-6, 0)
			pose_mode = "pocket_lean"
			
		"hero_bust_side_eye", "unimpressed_freeze":
			head_offset = Vector2(0, -4)
			head_rotation = -0.04
			pose_mode = "folded_arms"
			
		"sarcastic_shrug":
			head_offset = Vector2(0, -6)
			head_rotation = 0.06
			pose_mode = "shrug"
			
		"thinking_chin_tap":
			head_offset = Vector2(6, -4)
			head_rotation = 0.08
			pose_mode = "chin_tap"
			
		"sit_card_crosslegged", "sit_on_card":
			body_offset = Vector2(0, -20)
			pose_mode = "seated"
			
		"hold_cta_sign", "hold_terminal_board":
			pose_mode = "hold_sign"
			
		"relaxed_standing", _:
			head_offset = Vector2.ZERO
			head_rotation = 0.0
			body_offset = Vector2.ZERO
			pose_mode = "relaxed_standing"

func _draw() -> void:
	# 1. Hair Back Volume
	var hair_back := Geo.get_hair_back_polygon()
	draw_colored_polygon(_transform_pts(hair_back, head_offset, head_rotation), Geo.COLOR_HAIR)
	_draw_ink_stroke(_transform_pts(hair_back, head_offset, head_rotation), Geo.COLOR_INK_HAIR, 3.6)
	
	# If peeking from bottom, skip lower body and legs
	if not (is_peeking and peek_direction == "bottom"):
		# 2. Relaxed Ecru Linen Trousers & Dark Sneakers
		_draw_trousers_and_shoes()
		
		# 3. Sage Green Button-Down Shirt Torso
		_draw_shirt_torso()
		
		# 4. Arms with Rolled Sleeves & Bare Forearms
		_draw_arms()
	
	# 5. Head Base & Skin
	var head := Geo.get_head_polygon()
	draw_colored_polygon(_transform_pts(head, head_offset, head_rotation), Geo.COLOR_SKIN)
	var jaw := Geo.get_jaw_outline()
	# Open jaw outline: drawn as an open polyline so NO line crosses the forehead!
	draw_polyline(_transform_pts(jaw, head_offset, head_rotation), Geo.COLOR_INK, 3.6)
	
	# 6. Facial Features (Almond anime eyes, corner hash marks, brows, mouth)
	_draw_face()
	
	# 7. Signature Curtain Bangs
	var bangs := Geo.get_front_curtain_bangs()
	draw_colored_polygon(_transform_pts(bangs, head_offset, head_rotation), Geo.COLOR_HAIR)
	_draw_ink_stroke(_transform_pts(bangs, head_offset, head_rotation), Geo.COLOR_INK_HAIR, 3.4)
	
	# Hair center part & separation accents
	draw_line(head_offset + Vector2(0, -82).rotated(head_rotation), head_offset + Vector2(0, -104).rotated(head_rotation), Geo.COLOR_INK_HAIR, 2.2)
	draw_line(head_offset + Vector2(-12, -66).rotated(head_rotation), head_offset + Vector2(-28, -42).rotated(head_rotation), Geo.COLOR_INK_HAIR, 2.0)
	draw_line(head_offset + Vector2(12, -66).rotated(head_rotation), head_offset + Vector2(28, -42).rotated(head_rotation), Geo.COLOR_INK_HAIR, 2.0)
	
	# Hair specular glint lines (slate highlight)
	draw_line(head_offset + Vector2(-28, -78).rotated(head_rotation), head_offset + Vector2(-16, -72).rotated(head_rotation), Geo.COLOR_HAIR_HIGHLIGHT, 2.4)
	draw_line(head_offset + Vector2(16, -72).rotated(head_rotation), head_offset + Vector2(28, -78).rotated(head_rotation), Geo.COLOR_HAIR_HIGHLIGHT, 2.4)
	
	# 8. Iconic Crown Antenna Tufts (Two flick horns on top)
	var tufts := Geo.get_crown_tufts()
	for t in tufts:
		draw_colored_polygon(_transform_pts(t, head_offset, head_rotation), Geo.COLOR_HAIR)
		_draw_ink_stroke(_transform_pts(t, head_offset, head_rotation), Geo.COLOR_INK_HAIR, 2.5)
	
	# 9. Peek Hands (if peeking from bottom border)
	if is_peeking and peek_direction == "bottom":
		_draw_peek_hands()

# -------------------------------------------------------------------------
# SHIRT & TORSO
# -------------------------------------------------------------------------

func _draw_shirt_torso() -> void:
	# 1. Torso Silhouette
	var torso := Geo.get_shirt_torso_polygon()
	draw_colored_polygon(_transform_pts(torso, body_offset, 0.0), Geo.COLOR_SHIRT)
	_draw_ink_stroke(_transform_pts(torso, body_offset, 0.0), Geo.COLOR_INK, 3.6)
	
	# 2. Bare neck inside collar
	var neck := Geo.get_bare_neck_polygon()
	draw_colored_polygon(_transform_pts(neck, body_offset, 0.0), Geo.COLOR_SKIN)
	
	# 3. Open Collar Lapels
	var lapel_l := Geo.get_collar_lapel_left()
	var lapel_r := Geo.get_collar_lapel_right()
	draw_colored_polygon(_transform_pts(lapel_l, body_offset, 0.0), Geo.COLOR_SHIRT_COLLAR)
	draw_colored_polygon(_transform_pts(lapel_r, body_offset, 0.0), Geo.COLOR_SHIRT_COLLAR)
	_draw_ink_stroke(_transform_pts(lapel_l, body_offset, 0.0), Geo.COLOR_INK, 2.8)
	_draw_ink_stroke(_transform_pts(lapel_r, body_offset, 0.0), Geo.COLOR_INK, 2.8)
	
	# 4. Button Placket & Buttons
	var p_top := Vector2(0, 32) + body_offset
	var p_bot := Vector2(0, 116) + body_offset
	draw_line(p_top, p_bot, Geo.COLOR_SHIRT_SHADOW, 4.0)
	draw_line(p_top, p_bot, Geo.COLOR_INK, 1.5)
	
	for y_off in [46.0, 68.0, 90.0, 108.0]:
		var b_pos := Vector2(0, y_off) + body_offset
		draw_circle(b_pos, 2.2, Geo.COLOR_BUTTON)

# -------------------------------------------------------------------------
# TROUSERS & SHOES
# -------------------------------------------------------------------------

func _draw_trousers_and_shoes() -> void:
	# Ecru Linen Trousers
	var trousers := Geo.get_trousers_polygon()
	draw_colored_polygon(_transform_pts(trousers, body_offset, 0.0), Geo.COLOR_TROUSERS)
	_draw_ink_stroke(_transform_pts(trousers, body_offset, 0.0), Geo.COLOR_INK, 3.6)
	
	# Crotch fly seam
	draw_line(Vector2(0, 118) + body_offset, Vector2(0, 155) + body_offset, Geo.COLOR_TROUSER_SEAM, 2.0)
	
	# Tailored Center Vertical Creases down each leg
	draw_line(Vector2(-19, 126) + body_offset, Vector2(-19, 240) + body_offset, Geo.COLOR_TROUSER_SEAM, 1.8)
	draw_line(Vector2(19, 126) + body_offset, Vector2(19, 240) + body_offset, Geo.COLOR_TROUSER_SEAM, 1.8)
	
	# Pocket slit if in pocket pose
	if pose_mode == "pocket_lean":
		draw_line(Vector2(24, 118) + body_offset, Vector2(34, 136) + body_offset, Geo.COLOR_INK, 2.2)
	
	# Dark Canvas Sneakers with off-white rubber toe caps
	_draw_sneaker(Vector2(-19, 245) + body_offset, -1.0)
	_draw_sneaker(Vector2(19, 245) + body_offset, 1.0)

func _draw_sneaker(pos: Vector2, dir: float) -> void:
	# Upper
	var upper := Geo.get_sneaker_polygon(pos, dir)
	draw_colored_polygon(upper, Geo.COLOR_SNEAKER_BASE)
	_draw_ink_stroke(upper, Geo.COLOR_INK, 2.6)
	
	# Off-white rubber toe cap
	var toe := Geo.get_sneaker_toe_cap(pos, dir)
	draw_colored_polygon(toe, Geo.COLOR_SNEAKER_SOLE)
	_draw_ink_stroke(toe, Geo.COLOR_INK, 1.8)
	
	# Sole strip
	var sole_pts := PackedVector2Array([
		pos + Vector2(-6 * dir, 15), pos + Vector2(30 * dir, 15),
		pos + Vector2(30 * dir, 18), pos + Vector2(-6 * dir, 18)
	])
	draw_colored_polygon(sole_pts, Geo.COLOR_SNEAKER_TREAD)
	_draw_ink_stroke(sole_pts, Geo.COLOR_INK, 1.8)

# -------------------------------------------------------------------------
# ARMS & ROLLED SLEEVES (Mode-Based Clean Rigs)
# -------------------------------------------------------------------------

func _draw_arms() -> void:
	match pose_mode:
		"folded_arms":
			_draw_folded_arms()
		"pocket_lean":
			_draw_arm_hanging(Vector2(-44, 30), -1.0)
			_draw_pocket_arm(Vector2(44, 30))
		"shrug":
			_draw_shrug_arms()
		"chin_tap":
			_draw_arm_hanging(Vector2(-44, 30), -1.0)
			_draw_chin_tap_arm(Vector2(44, 30))
		"hold_sign":
			_draw_hold_sign_arms()
		"peek_right":
			_draw_arm_hanging(Vector2(-44, 30), -1.0)
			_draw_pointing_arm(Vector2(44, 30))
		"relaxed_standing", _:
			_draw_arm_hanging(Vector2(-44, 30), -1.0)
			_draw_arm_hanging(Vector2(44, 30), 1.0)

## Natural hanging arm along body side
func _draw_arm_hanging(shoulder: Vector2, dir_x: float) -> void:
	var s := shoulder + body_offset
	var e := s + Vector2(4.0 * dir_x, 38.0)
	var h := s + Vector2(5.0 * dir_x, 68.0)
	
	# 1. Bare Forearm
	draw_line(e, h, Geo.COLOR_SKIN, 12.0)
	draw_line(e, h, Geo.COLOR_INK, 2.5)
	
	# 2. Upper Sleeve
	draw_line(s, e, Geo.COLOR_SHIRT, 16.0)
	draw_line(s, e, Geo.COLOR_INK, 3.0)
	
	# 3. Rolled Cuff Band
	_draw_cuff(e, (h - s).normalized())
	
	# 4. Stylized Comic Hand
	draw_circle(h, 8.0, Geo.COLOR_SKIN)
	draw_arc(h, 8.0, 0, TAU, 16, Geo.COLOR_INK, 2.2)
	draw_line(h, h + Vector2(-6.0 * dir_x, -2), Geo.COLOR_INK, 2.0)

## Hand casually tucked into pocket
func _draw_pocket_arm(shoulder: Vector2) -> void:
	var s := shoulder + body_offset
	var e := s + Vector2(10.0, 38.0)
	var pocket := Vector2(28.0, 124.0) + body_offset
	
	# 1. Bare Forearm disappearing into pocket
	draw_line(e, pocket, Geo.COLOR_SKIN, 12.0)
	draw_line(e, pocket, Geo.COLOR_INK, 2.5)
	
	# 2. Upper Sleeve
	draw_line(s, e, Geo.COLOR_SHIRT, 16.0)
	draw_line(s, e, Geo.COLOR_INK, 3.0)
	
	# 3. Rolled Cuff Band
	_draw_cuff(e, (pocket - s).normalized())
	
	# 4. Wrist base at pocket opening
	draw_circle(pocket - Vector2(1, 4), 6.5, Geo.COLOR_SKIN)
	draw_arc(pocket - Vector2(1, 4), 6.5, 0, TAU, 14, Geo.COLOR_INK, 2.0)

## Arms folded casually across chest
func _draw_folded_arms() -> void:
	var b := body_offset
	var l_s := Vector2(-44, 30) + b
	var l_e := Vector2(-52, 64) + b
	var l_h := Vector2(16, 66) + b
	
	var r_s := Vector2(44, 30) + b
	var r_e := Vector2(52, 64) + b
	var r_h := Vector2(-16, 74) + b
	
	# Forearms crossed
	draw_line(l_e, l_h, Geo.COLOR_SKIN, 12.0)
	draw_line(l_e, l_h, Geo.COLOR_INK, 2.5)
	draw_line(r_e, r_h, Geo.COLOR_SKIN, 12.0)
	draw_line(r_e, r_h, Geo.COLOR_INK, 2.5)
	
	# Sleeves
	draw_line(l_s, l_e, Geo.COLOR_SHIRT, 16.0)
	draw_line(l_s, l_e, Geo.COLOR_INK, 3.0)
	draw_line(r_s, r_e, Geo.COLOR_SHIRT, 16.0)
	draw_line(r_s, r_e, Geo.COLOR_INK, 3.0)
	
	# Cuffs
	_draw_cuff(l_e, (l_h - l_s).normalized())
	_draw_cuff(r_e, (r_h - r_s).normalized())
	
	# Hands resting on bicep / elbow
	draw_circle(l_h, 7.5, Geo.COLOR_SKIN)
	draw_arc(l_h, 7.5, 0, TAU, 14, Geo.COLOR_INK, 2.0)
	draw_circle(r_h, 7.5, Geo.COLOR_SKIN)
	draw_arc(r_h, 7.5, 0, TAU, 14, Geo.COLOR_INK, 2.0)

## Sarcastic shrug with raised hands
func _draw_shrug_arms() -> void:
	var b := body_offset
	var l_s := Vector2(-44, 30) + b
	var l_e := Vector2(-56, 56) + b
	var l_h := Vector2(-62, 28) + b
	draw_line(l_e, l_h, Geo.COLOR_SKIN, 12.0)
	draw_line(l_e, l_h, Geo.COLOR_INK, 2.5)
	draw_line(l_s, l_e, Geo.COLOR_SHIRT, 16.0)
	draw_line(l_s, l_e, Geo.COLOR_INK, 3.0)
	_draw_cuff(l_e, (l_h - l_e).normalized())
	draw_circle(l_h, 8.0, Geo.COLOR_SKIN)
	draw_arc(l_h, 8.0, 0, TAU, 16, Geo.COLOR_INK, 2.2)
	draw_line(l_h, l_h + Vector2(-6, 2), Geo.COLOR_INK, 2.0)
	
	var r_s := Vector2(44, 30) + b
	var r_e := Vector2(56, 56) + b
	var r_h := Vector2(62, 28) + b
	draw_line(r_e, r_h, Geo.COLOR_SKIN, 12.0)
	draw_line(r_e, r_h, Geo.COLOR_INK, 2.5)
	draw_line(r_s, r_e, Geo.COLOR_SHIRT, 16.0)
	draw_line(r_s, r_e, Geo.COLOR_INK, 3.0)
	_draw_cuff(r_e, (r_h - r_e).normalized())
	draw_circle(r_h, 8.0, Geo.COLOR_SKIN)
	draw_arc(r_h, 8.0, 0, TAU, 16, Geo.COLOR_INK, 2.2)
	draw_line(r_h, r_h + Vector2(6, 2), Geo.COLOR_INK, 2.0)

## Thinking arm with finger on chin
func _draw_chin_tap_arm(shoulder: Vector2) -> void:
	var s := shoulder + body_offset
	var e := s + Vector2(14.0, 42.0)
	var chin_pt := Vector2(16.0, -8.0) + head_offset
	
	draw_line(e, chin_pt, Geo.COLOR_SKIN, 12.0)
	draw_line(e, chin_pt, Geo.COLOR_INK, 2.5)
	draw_line(s, e, Geo.COLOR_SHIRT, 16.0)
	draw_line(s, e, Geo.COLOR_INK, 3.0)
	_draw_cuff(e, (chin_pt - s).normalized())
	
	draw_circle(chin_pt, 7.5, Geo.COLOR_SKIN)
	draw_arc(chin_pt, 7.5, 0, TAU, 14, Geo.COLOR_INK, 2.0)
	draw_line(chin_pt, chin_pt + Vector2(0, -12), Geo.COLOR_INK, 2.4)

## Holding signboard arms (hands gripping bottom rim to the left and right of head)
func _draw_hold_sign_arms() -> void:
	var b := body_offset
	# Left arm reaching up and outward
	var l_s := Vector2(-44, 30) + b
	var l_e := Vector2(-68, -15) + b
	var l_h := Vector2(-85, -80) + b
	
	draw_line(l_e, l_h, Geo.COLOR_SKIN, 12.0)
	draw_line(l_e, l_h, Geo.COLOR_INK, 2.5)
	draw_line(l_s, l_e, Geo.COLOR_SHIRT, 16.0)
	draw_line(l_s, l_e, Geo.COLOR_INK, 3.0)
	_draw_cuff(l_e, (l_h - l_e).normalized())
	draw_circle(l_h, 8.0, Geo.COLOR_SKIN)
	draw_arc(l_h, 8.0, 0, TAU, 16, Geo.COLOR_INK, 2.2)
	
	# Right arm reaching up and outward
	var r_s := Vector2(44, 30) + b
	var r_e := Vector2(68, -15) + b
	var r_h := Vector2(85, -80) + b
	
	draw_line(r_e, r_h, Geo.COLOR_SKIN, 12.0)
	draw_line(r_e, r_h, Geo.COLOR_INK, 2.5)
	draw_line(r_s, r_e, Geo.COLOR_SHIRT, 16.0)
	draw_line(r_s, r_e, Geo.COLOR_INK, 3.0)
	_draw_cuff(r_e, (r_h - r_e).normalized())
	draw_circle(r_h, 8.0, Geo.COLOR_SKIN)
	draw_arc(r_h, 8.0, 0, TAU, 16, Geo.COLOR_INK, 2.2)

## Pointing arm
func _draw_pointing_arm(shoulder: Vector2) -> void:
	var s := shoulder + body_offset
	var h := s + Vector2(58, -16)
	draw_line(s, h, Geo.COLOR_SHIRT, 16.0)
	draw_line(s, h, Geo.COLOR_INK, 3.0)
	draw_circle(h, 8.0, Geo.COLOR_SKIN)
	draw_arc(h, 8.0, 0, TAU, 16, Geo.COLOR_INK, 2.2)
	draw_line(h, h + Vector2(14, -2), Geo.COLOR_INK, 2.4)

## Helper to draw a clean rectangular rolled cuff band perpendicular to the arm
func _draw_cuff(pos: Vector2, dir: Vector2) -> void:
	var norm := Vector2(-dir.y, dir.x)
	var cuff_poly := PackedVector2Array([
		pos - norm * 10.5 - dir * 4.0,
		pos + norm * 10.5 - dir * 4.0,
		pos + norm * 10.5 + dir * 4.0,
		pos - norm * 10.5 + dir * 4.0
	])
	draw_colored_polygon(cuff_poly, Geo.COLOR_SHIRT_COLLAR)
	_draw_ink_stroke(cuff_poly, Geo.COLOR_INK, 2.2)

func _draw_peek_hands() -> void:
	# Hands clutching the bottom border
	draw_circle(Vector2(-35, 12) + head_offset, 12.0, Geo.COLOR_SKIN)
	draw_arc(Vector2(-35, 12) + head_offset, 12.0, 0, TAU, 16, Geo.COLOR_INK, 2.5)
	draw_circle(Vector2(35, 12) + head_offset, 12.0, Geo.COLOR_SKIN)
	draw_arc(Vector2(35, 12) + head_offset, 12.0, 0, TAU, 16, Geo.COLOR_INK, 2.5)

# -------------------------------------------------------------------------
# FACIAL FEATURES & EXPRESSIONS
# -------------------------------------------------------------------------

func _draw_face() -> void:
	var h_pos := head_offset
	
	# 1. Nose (subtle stylish anime tick)
	draw_line(h_pos + Vector2(-1, -16), h_pos + Vector2(1, -14), Geo.COLOR_INK, 2.2)
	
	# 2. Blush wash if flustered or embarrassed
	if current_expression == "flustered" or current_expression == "embarrassed":
		draw_line(h_pos + Vector2(-32, -22), h_pos + Vector2(-26, -28), Geo.COLOR_BLUSH, 3.0)
		draw_line(h_pos + Vector2(-28, -20), h_pos + Vector2(-22, -26), Geo.COLOR_BLUSH, 3.0)
		draw_line(h_pos + Vector2(22, -26), h_pos + Vector2(28, -20), Geo.COLOR_BLUSH, 3.0)
		draw_line(h_pos + Vector2(26, -28), h_pos + Vector2(32, -22), Geo.COLOR_BLUSH, 3.0)
		
	# 3. Eyes, Brows & Mouth based on expression
	match current_expression:
		"smug", "smirk":
			# Cool side-eye glance with smirk
			_draw_almond_anime_eye(h_pos + Vector2(-18, -32), Vector2(0.5, -0.1), false)
			_draw_almond_anime_eye(h_pos + Vector2(18, -32), Vector2(0.5, -0.1), true)
			_draw_eyebrow(h_pos + Vector2(-18, -48), 6.0, false)
			_draw_eyebrow(h_pos + Vector2(18, -46), -2.0, true)
			# Smug smirk tilted to right
			draw_line(h_pos + Vector2(-6, -8), h_pos + Vector2(2, -7), Geo.COLOR_INK, 2.8)
			draw_line(h_pos + Vector2(2, -7), h_pos + Vector2(9, -12), Geo.COLOR_INK, 2.8)
			
		"flustered", "embarrassed":
			# Averted eyes
			_draw_almond_anime_eye(h_pos + Vector2(-18, -32), Vector2(-0.4, 0.2), false)
			_draw_almond_anime_eye(h_pos + Vector2(18, -32), Vector2(-0.4, 0.2), true)
			_draw_eyebrow(h_pos + Vector2(-18, -46), -6.0, false)
			_draw_eyebrow(h_pos + Vector2(18, -46), -6.0, true)
			draw_arc(h_pos + Vector2(0, -6), 6.0, 0.3, PI - 0.3, 12, Geo.COLOR_INK, 2.4)
			
		"happy", "laugh":
			# Warm upward curved eye arcs
			draw_arc(h_pos + Vector2(-18, -30), 8.0, PI + 0.3, TAU - 0.3, 14, Geo.COLOR_INK, 3.4)
			draw_arc(h_pos + Vector2(18, -30), 8.0, PI + 0.3, TAU - 0.3, 14, Geo.COLOR_INK, 3.4)
			_draw_eyebrow(h_pos + Vector2(-18, -48), 4.0, false)
			_draw_eyebrow(h_pos + Vector2(18, -48), 4.0, true)
			_draw_open_mouth(h_pos + Vector2(0, -6), 12.0)
			
		"sarcastic_sigh", "exhausted", "unimpressed":
			# Half-closed lidded eyes
			draw_line(h_pos + Vector2(-26, -32), h_pos + Vector2(-10, -32), Geo.COLOR_INK, 3.6)
			draw_line(h_pos + Vector2(10, -32), h_pos + Vector2(26, -32), Geo.COLOR_INK, 3.6)
			draw_line(h_pos + Vector2(-26, -46), h_pos + Vector2(-10, -45), Geo.COLOR_HAIR, 2.8)
			draw_line(h_pos + Vector2(10, -45), h_pos + Vector2(26, -46), Geo.COLOR_HAIR, 2.8)
			draw_line(h_pos + Vector2(-8, -6), h_pos + Vector2(8, -6), Geo.COLOR_INK, 2.6)
			
		"shocked", "disbelief":
			# Wide circular shock eyes
			draw_circle(h_pos + Vector2(-18, -34), 10.0, Color.WHITE)
			draw_circle(h_pos + Vector2(18, -34), 10.0, Color.WHITE)
			draw_arc(h_pos + Vector2(-18, -34), 10.0, 0, TAU, 20, Geo.COLOR_INK, 3.2)
			draw_arc(h_pos + Vector2(18, -34), 10.0, 0, TAU, 20, Geo.COLOR_INK, 3.2)
			draw_circle(h_pos + Vector2(-18, -34), 3.0, Geo.COLOR_EYE_PUPIL)
			draw_circle(h_pos + Vector2(18, -34), 3.0, Geo.COLOR_EYE_PUPIL)
			draw_line(h_pos + Vector2(-28, -52), h_pos + Vector2(-10, -48), Geo.COLOR_HAIR, 3.0)
			draw_line(h_pos + Vector2(10, -48), h_pos + Vector2(28, -52), Geo.COLOR_HAIR, 3.0)
			draw_circle(h_pos + Vector2(0, -6), 8.0, Geo.COLOR_INK)
			
		"deadpan", _:
			# Cool, composed deadpan gaze
			_draw_almond_anime_eye(h_pos + Vector2(-18, -32), Vector2(0.2, 0.0), false)
			_draw_almond_anime_eye(h_pos + Vector2(18, -32), Vector2(0.2, 0.0), true)
			_draw_eyebrow(h_pos + Vector2(-18, -48), 0.0, false)
			_draw_eyebrow(h_pos + Vector2(18, -48), 0.0, true)
			draw_line(h_pos + Vector2(-7, -7), h_pos + Vector2(7, -7), Geo.COLOR_INK, 2.8)
			draw_line(h_pos + Vector2(-2, -3), h_pos + Vector2(2, -3), Geo.COLOR_SKIN_SHADOW, 1.8)

func _draw_almond_anime_eye(center: Vector2, gaze: Vector2, is_right: bool) -> void:
	var flip: float = 1.0 if is_right else -1.0
	
	# Sleek almond-shaped sclera polygon (clean white)
	var sclera := PackedVector2Array([
		center + Vector2(-11 * flip, 0),
		center + Vector2(-4 * flip, -5.5),
		center + Vector2(6 * flip, -5.0),
		center + Vector2(11 * flip, -1),
		center + Vector2(5 * flip, 5.0),
		center + Vector2(-4 * flip, 4.5)
	])
	draw_colored_polygon(sclera, Color.WHITE)
	
	# Iris & Pupil
	var iris_pos := center + gaze * 3.0
	draw_circle(iris_pos, 4.8, Geo.COLOR_EYE_IRIS)
	draw_circle(iris_pos, 2.4, Geo.COLOR_EYE_PUPIL)
	
	# Specular Catchlight
	draw_circle(iris_pos + Vector2(-1.4 * flip, -1.4), 1.3, Color.WHITE)
	draw_circle(iris_pos + Vector2(1.4 * flip, 1.2), 0.7, Color(1, 1, 1, 0.75))
	
	# Sleek Upper Eyelid Lash Line with Wing Flick
	var upper_lash := PackedVector2Array([
		center + Vector2(-12 * flip, 1),
		center + Vector2(-4 * flip, -5.5),
		center + Vector2(7 * flip, -5.5),
		center + Vector2(12 * flip, -2),
		center + Vector2(15 * flip, -4) # Wing flick
	])
	draw_polyline(upper_lash, Geo.COLOR_INK, 3.6)
	
	# Lower Lash Accent Line
	draw_line(center + Vector2(-3 * flip, 5.0), center + Vector2(6 * flip, 4.8), Geo.COLOR_INK, 1.8)
	
	# Double Eyelid Crease
	draw_line(center + Vector2(-6 * flip, -9.0), center + Vector2(5 * flip, -8.5), Geo.COLOR_INK, 1.6)
	
	# Signature ADB Double-Slash Corner Accent Marks (visible in reference photo!)
	draw_line(center + Vector2(11 * flip, 1), center + Vector2(14 * flip, 6), Geo.COLOR_INK, 1.6)
	draw_line(center + Vector2(14 * flip, 0), center + Vector2(17 * flip, 5), Geo.COLOR_INK, 1.6)

func _draw_eyebrow(origin: Vector2, angle_deg: float, is_right: bool) -> void:
	var flip: float = 1.0 if is_right else -1.0
	var rad := deg_to_rad(angle_deg * flip)
	var pts := PackedVector2Array([
		origin + Vector2(-10 * flip, 2).rotated(rad),
		origin + Vector2(-2 * flip, -2.5).rotated(rad),
		origin + Vector2(8 * flip, -1).rotated(rad),
		origin + Vector2(12 * flip, 3).rotated(rad)
	])
	draw_polyline(pts, Geo.COLOR_HAIR, 3.0)

func _draw_open_mouth(pos: Vector2, width: float) -> void:
	var pts := PackedVector2Array([
		pos + Vector2(-width * 0.5, 0), pos + Vector2(width * 0.5, 0),
		pos + Vector2(width * 0.4, width * 0.7), pos + Vector2(0, width * 0.85), pos + Vector2(-width * 0.4, width * 0.7)
	])
	draw_colored_polygon(pts, Color("#a83b3b"))
	_draw_ink_stroke(pts, Geo.COLOR_INK, 2.4)

# -------------------------------------------------------------------------
# UTILITIES
# -------------------------------------------------------------------------

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
