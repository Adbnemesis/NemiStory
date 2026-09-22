class_name CosmoLimbs
extends Node2D

## Lower Body & Left Arm Construction for COSMO (Brawl Stars)
## Faithfully captures:
## - Dark slate robotic pelvis with top magnetic levitation socket
## - Spherical mechanical hip pivots
## - Corrugated / accordion cylindrical legs with horizontal segmented rings
## - Sleek robotic boots with flared ankle cuffs and angled soles
## - Left Arm: royal blue coat sleeve with teal cuff and articulated robotic hand

const CosmoStyle = preload("res://brawl_stars/characters/cosmo/CosmoStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: CosmoStyle

var left_arm_pose: String = "on_hip": # "on_hip", "relaxed_side", "pointing_left", "gesturing"
	set(val):
		left_arm_pose = val
		queue_redraw()

var leg_stance: String = "neutral": # "neutral", "wide", "recoil", "lean"
	set(val):
		leg_stance = val
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Left Arm (Coat sleeve, teal cuff, robotic hand)
	_draw_left_arm()
	
	# 2. Corrugated Accordion Legs & Robotic Boots
	_draw_legs_and_boots()
	
	# 3. Robotic Pelvis & Magnetic Receptor Socket
	_draw_pelvis()

# -------------------------------------------------------------------------
# PELVIS & HIPS
# -------------------------------------------------------------------------

func _draw_pelvis() -> void:
	# Pelvis origin at Y ~ 0 (relative to Limbs node)
	var pelvis_pts := PackedVector2Array([
		Vector2(-24, 0),
		Vector2(24, 0),
		Vector2(20, 16),
		Vector2(12, 28),
		Vector2(-12, 28),
		Vector2(-20, 16)
	])
	draw_colored_polygon(pelvis_pts, style.robot_metal_color)
	
	# Top magnetic receptor socket (aligns with torso waist ring)
	draw_set_transform(Vector2(0, 0), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 22.0, style.energy_ring_color)
	draw_arc(Vector2.ZERO, 20.0, 0, TAU, 20, style.energy_core_color, 1.8, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# Pelvis ink outline
	var loop := PackedVector2Array()
	for p in pelvis_pts: loop.append(p)
	loop.append(pelvis_pts[0])
	CosmoInkStroke.from_points(loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Spherical Hip Pivot Sockets
	draw_circle(Vector2(-16, 22), 8.0, style.robot_metal_shadow_color)
	draw_arc(Vector2(-16, 22), 8.0, 0, TAU, 16, style.ink_color, style.inner_line_width, true)
	
	draw_circle(Vector2(16, 22), 8.0, style.robot_metal_shadow_color)
	draw_arc(Vector2(16, 22), 8.0, 0, TAU, 16, style.ink_color, style.inner_line_width, true)

# -------------------------------------------------------------------------
# CORRUGATED LEGS & BOOTS
# -------------------------------------------------------------------------

func _draw_legs_and_boots() -> void:
	var left_hip := Vector2(-16, 24)
	var right_hip := Vector2(16, 24)
	
	var left_foot_pos := Vector2(-26, 92)
	var right_foot_pos := Vector2(26, 92)
	
	match leg_stance:
		"wide":
			left_foot_pos = Vector2(-38, 90)
			right_foot_pos = Vector2(38, 90)
		"recoil":
			left_foot_pos = Vector2(-22, 94)
			right_foot_pos = Vector2(18, 90)
		"lean":
			left_foot_pos = Vector2(-16, 92)
			right_foot_pos = Vector2(34, 92)
	
	# Draw Left Leg (Corrugated flexible cylinder)
	_draw_corrugated_leg(left_hip, left_foot_pos + Vector2(0, -22))
	_draw_boot(left_foot_pos, true)
	
	# Draw Right Leg (Corrugated flexible cylinder)
	_draw_corrugated_leg(right_hip, right_foot_pos + Vector2(0, -22))
	_draw_boot(right_foot_pos, false)

func _draw_corrugated_leg(from_pos: Vector2, to_pos: Vector2) -> void:
	var dir := (to_pos - from_pos).normalized()
	var normal := Vector2(-dir.y, dir.x)
	var length := from_pos.distance_to(to_pos)
	var segments := 7
	var seg_w := 9.0
	
	# Base cylinder backing
	var leg_quad := PackedVector2Array([
		from_pos + normal * seg_w,
		to_pos + normal * (seg_w * 0.9),
		to_pos - normal * (seg_w * 0.9),
		from_pos - normal * seg_w
	])
	draw_colored_polygon(leg_quad, style.robot_metal_shadow_color)
	
	# Corrugated accordion rings
	for i in range(segments):
		var t0: float = float(i) / float(segments)
		var t1: float = float(i + 0.7) / float(segments)
		var p0 := from_pos.lerp(to_pos, t0)
		var p1 := from_pos.lerp(to_pos, t1)
		
		var ring_pts := PackedVector2Array([
			p0 + normal * (seg_w + 1.5),
			p1 + normal * (seg_w + 1.5),
			p1 - normal * (seg_w + 1.5),
			p0 - normal * (seg_w + 1.5)
		])
		draw_colored_polygon(ring_pts, style.robot_metal_color)
		
		var r_loop := PackedVector2Array()
		for p in ring_pts: r_loop.append(p)
		r_loop.append(ring_pts[0])
		CosmoInkStroke.from_points(r_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)

func _draw_boot(pos: Vector2, is_left: bool) -> void:
	var flip: float = -1.0 if is_left else 1.0
	
	# Robotic boot ankle cuff
	var cuff_pts := PackedVector2Array([
		pos + Vector2(-12 * flip, -24),
		pos + Vector2(12 * flip, -24),
		pos + Vector2(14 * flip, -12),
		pos + Vector2(-14 * flip, -12)
	])
	draw_colored_polygon(cuff_pts, style.robot_metal_highlight_color)
	var c_loop := PackedVector2Array()
	for p in cuff_pts: c_loop.append(p)
	c_loop.append(cuff_pts[0])
	CosmoInkStroke.from_points(c_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Boot foot & sole
	var boot_pts := PackedVector2Array([
		pos + Vector2(-12 * flip, -12),
		pos + Vector2(10 * flip, -12),
		pos + Vector2(18 * flip, 6),
		pos + Vector2(24 * flip, 18), # Boot toe
		pos + Vector2(-8 * flip, 18), # Sole bottom
		pos + Vector2(-14 * flip, 8)  # Boot heel
	])
	draw_colored_polygon(boot_pts, style.robot_metal_color)
	var b_loop := PackedVector2Array()
	for p in boot_pts: b_loop.append(p)
	b_loop.append(boot_pts[0])
	CosmoInkStroke.from_points(b_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Heavy tread sole plate
	draw_line(pos + Vector2(-8 * flip, 18), pos + Vector2(24 * flip, 18), style.ink_color, style.inner_line_width)

# -------------------------------------------------------------------------
# LEFT ARM (Standard Scientist Sleeve & Hand)
# -------------------------------------------------------------------------

func _draw_left_arm() -> void:
	# Attached at shoulder (Vector2(44, -70) relative to Limbs origin)
	var shoulder := Vector2(42, -60)
	
	var elbow: Vector2
	var wrist: Vector2
	
	match left_arm_pose:
		"relaxed_side":
			elbow = shoulder + Vector2(12, 42)
			wrist = elbow + Vector2(6, 44)
		"pointing_left":
			elbow = shoulder + Vector2(38, 12)
			wrist = elbow + Vector2(46, -10)
		"gesturing":
			elbow = shoulder + Vector2(28, 24)
			wrist = elbow + Vector2(34, -18)
		_: # "on_hip"
			elbow = shoulder + Vector2(26, 32)
			wrist = elbow + Vector2(-18, 22) # Rest hand on hip/coat
	
	# 1. Upper Arm Sleeve (Royal Blue)
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
	
	# 2. Forearm Sleeve (Royal Blue)
	var fore_dir := (wrist - elbow).normalized()
	var fore_n := Vector2(-fore_dir.y, fore_dir.x)
	var fore_sleeve := PackedVector2Array([
		elbow + fore_n * 11,
		wrist + fore_n * 12,
		wrist - fore_n * 12,
		elbow - fore_n * 11
	])
	draw_colored_polygon(fore_sleeve, style.coat_blue_color)
	var f_loop := PackedVector2Array()
	for p in fore_sleeve: f_loop.append(p)
	f_loop.append(fore_sleeve[0])
	CosmoInkStroke.from_points(f_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 3. Light Teal / Cyan Rolled Sleeve Cuff
	var cuff_w: float = 14.0
	var cuff_pts := PackedVector2Array([
		wrist + fore_n * cuff_w - fore_dir * 3,
		wrist + fore_n * cuff_w + fore_dir * 5,
		wrist - fore_n * cuff_w + fore_dir * 5,
		wrist - fore_n * cuff_w - fore_dir * 3
	])
	draw_colored_polygon(cuff_pts, style.coat_cuff_color)
	var cuff_loop := PackedVector2Array()
	for p in cuff_pts: cuff_loop.append(p)
	cuff_loop.append(cuff_pts[0])
	CosmoInkStroke.from_points(cuff_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 4. Robotic Hand (Articulated dark slate fingers)
	var hand_pos := wrist + fore_dir * 7
	_draw_robotic_hand(hand_pos, fore_dir, fore_n)

func _draw_robotic_hand(pos: Vector2, dir: Vector2, norm: Vector2) -> void:
	# Hand palm
	draw_circle(pos, 7.0, style.robot_metal_color)
	draw_arc(pos, 7.0, 0, TAU, 16, style.ink_color, style.inner_line_width, true)
	
	# 3 main articulated fingers + thumb
	var f1 := pos + dir * 10 - norm * 4
	var f2 := pos + dir * 12
	var f3 := pos + dir * 10 + norm * 4
	var thumb := pos + dir * 5 - norm * 8
	
	draw_line(pos - norm * 2, f1, style.robot_metal_color, 3.5)
	draw_line(pos, f2, style.robot_metal_color, 3.5)
	draw_line(pos + norm * 2, f3, style.robot_metal_color, 3.5)
	draw_line(pos - norm * 4, thumb, style.robot_metal_color, 3.5)
	
	# Outline fingers
	draw_line(pos - norm * 2, f1, style.ink_color, 1.4)
	draw_line(pos, f2, style.ink_color, 1.4)
	draw_line(pos + norm * 2, f3, style.ink_color, 1.4)
	draw_line(pos - norm * 4, thumb, style.ink_color, 1.4)
