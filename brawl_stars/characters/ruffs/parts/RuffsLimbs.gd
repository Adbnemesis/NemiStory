class_name RuffsLimbs
extends Node2D

## Lower Body & Left Arm Construction for RUFFS (Colonel Ruffs - Brawl Stars)
## Faithfully captures:
## - Magenta officer coat skirt / hem with gold trim piping
## - Short dark purple military trousers
## - Sturdy dark violet officer boots (supports heels-clicked attention stance)
## - Left Arm: Magenta officer sleeve with pink cuff and orange canine paw

const RuffsStyle = preload("res://brawl_stars/characters/ruffs/RuffsStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: RuffsStyle

var left_arm_pose: String = "behind_back": # "behind_back", "on_hip", "relaxed_side", "pointing_left"
	set(val):
		left_arm_pose = val
		queue_redraw()

var leg_stance: String = "neutral": # "neutral", "attention", "wide", "recoil"
	set(val):
		leg_stance = val
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Left Arm (drawn with coat sleeve & paw)
	_draw_left_arm()
	
	# 2. Lower Body: Coat Hem Skirt, Trousers & Boots
	_draw_lower_body()

func _draw_lower_body() -> void:
	# Origin is at Y ~ 0 (relative to Limbs node)
	
	# 1. Coat Lower Hem / Skirt (Magenta with gold trim button)
	var skirt_pts := PackedVector2Array([
		Vector2(-42, 0),
		Vector2(42, 0),
		Vector2(46, 26),
		Vector2(24, 30),
		Vector2(0, 32),
		Vector2(-24, 30),
		Vector2(-46, 26)
	])
	draw_colored_polygon(skirt_pts, style.coat_magenta_color)
	
	# Shadow on right
	var skirt_shadow := PackedVector2Array([
		Vector2(0, 32),
		Vector2(24, 30),
		Vector2(46, 26),
		Vector2(42, 0),
		Vector2(16, 0),
		Vector2(12, 18)
	])
	draw_colored_polygon(skirt_shadow, style.coat_shadow_color)
	
	var s_loop := PackedVector2Array()
	for p in skirt_pts: s_loop.append(p)
	s_loop.append(skirt_pts[0])
	CosmoInkStroke.from_points(s_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Diagonal Gold Flap & Button continuation
	draw_line(Vector2(-20, 0), Vector2(-28, 28), style.gold_accent_color, 4.0)
	draw_circle(Vector2(-24, 16), 5.0, style.gold_accent_color)
	draw_arc(Vector2(-24, 16), 5.0, 0, TAU, 12, style.ink_color, 1.4, true)
	
	# 2. Short Dark Purple Trousers & Boots
	var left_foot_x: float = -20.0
	var right_foot_x: float = 20.0
	
	match leg_stance:
		"attention": # Heels clicked together!
			left_foot_x = -10.0
			right_foot_x = 10.0
		"wide":
			left_foot_x = -30.0
			right_foot_x = 30.0
		"recoil":
			left_foot_x = -14.0
			right_foot_x = 24.0
	
	# Left Leg & Boot (his right, screen left)
	_draw_single_boot(Vector2(left_foot_x, 30), true)
	
	# Right Leg & Boot (his left, screen right)
	_draw_single_boot(Vector2(right_foot_x, 30), false)

func _draw_single_boot(pos: Vector2, is_left: bool) -> void:
	var flip: float = -1.0 if is_left else 1.0
	
	# Trousers visible above boot
	var pant_pts := PackedVector2Array([
		pos + Vector2(-12 * flip, 0),
		pos + Vector2(12 * flip, 0),
		pos + Vector2(10 * flip, 12),
		pos + Vector2(-10 * flip, 12)
	])
	draw_colored_polygon(pant_pts, style.navy_trim_color)
	
	# Sturdy Officer Boot
	var boot_pts := PackedVector2Array([
		pos + Vector2(-11 * flip, 10),
		pos + Vector2(11 * flip, 10),
		pos + Vector2(14 * flip, 24),
		pos + Vector2(18 * flip, 32), # Toe
		pos + Vector2(-8 * flip, 32),  # Sole
		pos + Vector2(-12 * flip, 22)  # Heel
	])
	draw_colored_polygon(boot_pts, style.coat_shadow_color)
	var b_loop := PackedVector2Array()
	for p in boot_pts: b_loop.append(p)
	b_loop.append(boot_pts[0])
	CosmoInkStroke.from_points(b_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Boot sole bottom tread line
	draw_line(pos + Vector2(-8 * flip, 32), pos + Vector2(18 * flip, 32), style.ink_color, 2.0)

# -------------------------------------------------------------------------
# LEFT ARM & PAW
# -------------------------------------------------------------------------

func _draw_left_arm() -> void:
	# Attached at shoulder Vector2(42, -58) relative to Limbs origin
	var shoulder := Vector2(40, -52)
	
	var elbow: Vector2
	var wrist: Vector2
	
	match left_arm_pose:
		"on_hip":
			elbow = shoulder + Vector2(24, 28)
			wrist = elbow + Vector2(-18, 20)
		"relaxed_side":
			elbow = shoulder + Vector2(10, 36)
			wrist = elbow + Vector2(4, 38)
		"pointing_left":
			elbow = shoulder + Vector2(32, 14)
			wrist = elbow + Vector2(42, -8)
		_: # "behind_back" (Parade rest: hand tucked behind back)
			elbow = shoulder + Vector2(18, 30)
			wrist = elbow + Vector2(-28, 14)
	
	# 1. Upper Arm Sleeve
	var up_dir := (elbow - shoulder).normalized()
	var up_n := Vector2(-up_dir.y, up_dir.x)
	var up_sleeve := PackedVector2Array([
		shoulder + up_n * 13,
		elbow + up_n * 11,
		elbow - up_n * 11,
		shoulder - up_n * 13
	])
	draw_colored_polygon(up_sleeve, style.coat_shadow_color)
	var u_loop := PackedVector2Array()
	for p in up_sleeve: u_loop.append(p)
	u_loop.append(up_sleeve[0])
	CosmoInkStroke.from_points(u_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 2. Forearm Sleeve
	var fore_dir := (wrist - elbow).normalized()
	var fore_n := Vector2(-fore_dir.y, fore_dir.x)
	var fore_sleeve := PackedVector2Array([
		elbow + fore_n * 11,
		wrist + fore_n * 12,
		wrist - fore_n * 12,
		elbow - fore_n * 11
	])
	draw_colored_polygon(fore_sleeve, style.coat_magenta_color)
	var f_loop := PackedVector2Array()
	for p in fore_sleeve: f_loop.append(p)
	f_loop.append(fore_sleeve[0])
	CosmoInkStroke.from_points(f_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 3. Officer Sleeve Cuff (Pink/Highlight)
	var cuff_w: float = 13.0
	var cuff_pts := PackedVector2Array([
		wrist + fore_n * cuff_w - fore_dir * 2,
		wrist + fore_n * cuff_w + fore_dir * 6,
		wrist - fore_n * cuff_w + fore_dir * 6,
		wrist - fore_n * cuff_w - fore_dir * 2
	])
	draw_colored_polygon(cuff_pts, style.coat_highlight_color)
	var c_loop := PackedVector2Array()
	for p in cuff_pts: c_loop.append(p)
	c_loop.append(cuff_pts[0])
	CosmoInkStroke.from_points(c_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 4. Orange Canine Paw
	var paw_pos := wrist + fore_dir * 6
	_draw_canine_paw(paw_pos, fore_dir, fore_n)

func _draw_canine_paw(pos: Vector2, dir: Vector2, norm: Vector2) -> void:
	# Main palm
	draw_circle(pos, 6.5, style.fur_orange_color)
	draw_arc(pos, 6.5, 0, TAU, 16, style.ink_color, style.inner_line_width, true)
	
	# 3 rounded paw fingers + thumb
	var p1 := pos + dir * 8 - norm * 3
	var p2 := pos + dir * 10
	var p3 := pos + dir * 8 + norm * 3
	draw_circle(p1, 2.8, style.fur_orange_color)
	draw_circle(p2, 2.8, style.fur_orange_color)
	draw_circle(p3, 2.8, style.fur_orange_color)
	draw_arc(p1, 2.8, 0, TAU, 10, style.ink_color, 1.2, true)
	draw_arc(p2, 2.8, 0, TAU, 10, style.ink_color, 1.2, true)
	draw_arc(p3, 2.8, 0, TAU, 10, style.ink_color, 1.2, true)
