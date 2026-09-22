class_name CosmoAttractorArm
extends Node2D

## Master Attractor Gauntlet Construction for COSMO (Brawl Stars)
## Implements Cosmo's signature right-arm scientific device:
## - Heavy-duty cylindrical collar with industrial rims and rivets
## - Yellow hazard triangle emblem
## - Red curved emergency grip / power manifold underneath
## - Articulated robotic hand supporting multiple storytelling poses:
##   "palm_up_hover", "point_forward", "operate_device", "explain_gesture", "clenched_fist", "recoil"
## - Interactive magnetic energy aura when manipulating celestial bodies

const CosmoStyle = preload("res://brawl_stars/characters/cosmo/CosmoStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: CosmoStyle

var arm_pose: String = "palm_up_hover": # "palm_up_hover", "point_forward", "operate_device", "explain_gesture", "clenched_fist", "recoil"
	set(val):
		arm_pose = val
		queue_redraw()

var is_attracting: bool = true:
	set(val):
		is_attracting = val
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# Attached at Right Shoulder (-42, -58) relative to character origin
	var shoulder := Vector2(-42, -58)
	
	var elbow: Vector2
	var wrist: Vector2
	
	match arm_pose:
		"point_forward":
			elbow = shoulder + Vector2(-36, 10)
			wrist = elbow + Vector2(-42, -8)
		"operate_device":
			elbow = shoulder + Vector2(-28, -14)
			wrist = elbow + Vector2(-32, -26)
		"explain_gesture":
			elbow = shoulder + Vector2(-34, 18)
			wrist = elbow + Vector2(-36, -24)
		"clenched_fist":
			elbow = shoulder + Vector2(-24, 28)
			wrist = elbow + Vector2(-12, 14)
		"recoil":
			elbow = shoulder + Vector2(-16, 22)
			wrist = elbow + Vector2(8, -10) # Pulled close to chest
		_: # "palm_up_hover" (Canonical idle pose: palm facing up under celestial orbs)
			elbow = shoulder + Vector2(-32, 28)
			wrist = elbow + Vector2(-38, -6)
	
	# 1. Upper Arm Sleeve (Royal Blue)
	_draw_upper_arm_sleeve(shoulder, elbow)
	
	# 2. Attractor Device (Massive Cylindrical Collar & Manifold)
	_draw_attractor_cylinder(elbow, wrist)
	
	# 3. Articulated Robotic Hand
	_draw_gauntlet_hand(wrist, (wrist - elbow).normalized())
	
	# 4. Optional Magnetic Energy Aura
	if is_attracting:
		_draw_magnetic_aura(wrist + (wrist - elbow).normalized() * 18)

func _draw_upper_arm_sleeve(shoulder: Vector2, elbow: Vector2) -> void:
	var dir := (elbow - shoulder).normalized()
	var norm := Vector2(-dir.y, dir.x)
	var sleeve_pts := PackedVector2Array([
		shoulder + norm * 14,
		elbow + norm * 12,
		elbow - norm * 12,
		shoulder - norm * 14
	])
	draw_colored_polygon(sleeve_pts, style.coat_blue_color)
	var loop := PackedVector2Array()
	for p in sleeve_pts: loop.append(p)
	loop.append(sleeve_pts[0])
	CosmoInkStroke.from_points(loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)

func _draw_attractor_cylinder(from_pos: Vector2, to_pos: Vector2) -> void:
	var dir := (to_pos - from_pos).normalized()
	var norm := Vector2(-dir.y, dir.x)
	var radius: float = 16.0
	var length := from_pos.distance_to(to_pos)
	
	# 1. Red Curved Underside Manifold / Handle
	var manifold_pts := PackedVector2Array([
		from_pos - norm * (radius + 2),
		to_pos - norm * (radius + 2),
		to_pos - norm * (radius + 8) + dir * 4,
		from_pos - norm * (radius + 8) - dir * 2
	])
	draw_colored_polygon(manifold_pts, style.attractor_bracket_color)
	var m_loop := PackedVector2Array()
	for p in manifold_pts: m_loop.append(p)
	m_loop.append(manifold_pts[0])
	CosmoInkStroke.from_points(m_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 2. Main Cylindrical High-Tech Casing (Industrial Silver-White)
	var cylinder_pts := PackedVector2Array([
		from_pos + norm * radius,
		to_pos + norm * (radius * 1.05),
		to_pos - norm * (radius * 1.05),
		from_pos - norm * radius
	])
	draw_colored_polygon(cylinder_pts, style.attractor_cuff_color)
	
	# Shading line along cylinder
	draw_line(from_pos - norm * (radius * 0.4), to_pos - norm * (radius * 0.4), style.head_dome_shadow_color, 4.0)
	
	var c_loop := PackedVector2Array()
	for p in cylinder_pts: c_loop.append(p)
	c_loop.append(cylinder_pts[0])
	CosmoInkStroke.from_points(c_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 3. Metallic Rim Bands at Forearm and Wrist
	draw_line(from_pos + norm * radius, from_pos - norm * radius, style.ink_color, style.inner_line_width)
	draw_line(to_pos + norm * (radius * 1.05), to_pos - norm * (radius * 1.05), style.ink_color, style.inner_line_width)
	
	# 4. Yellow Hazard Warning Triangle Badge (Centered on gauntlet)
	var mid_pos := from_pos.lerp(to_pos, 0.5) + norm * (radius * 0.45)
	var badge_size: float = 6.5
	var badge_pts := PackedVector2Array([
		mid_pos + norm * badge_size,
		mid_pos - norm * (badge_size * 0.6) + dir * badge_size,
		mid_pos - norm * (badge_size * 0.6) - dir * badge_size
	])
	draw_colored_polygon(badge_pts, style.attractor_badge_color)
	var b_loop := PackedVector2Array()
	for p in badge_pts: b_loop.append(p)
	b_loop.append(badge_pts[0])
	CosmoInkStroke.from_points(b_loop, 1.2, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	# Center dot / exclamation in badge
	draw_circle(mid_pos, 1.2, style.ink_color)

func _draw_gauntlet_hand(pos: Vector2, dir: Vector2) -> void:
	var norm := Vector2(-dir.y, dir.x)
	
	# Robotic Wrist Socket
	draw_circle(pos, 8.5, style.robot_metal_shadow_color)
	draw_arc(pos, 8.5, 0, TAU, 16, style.ink_color, style.inner_line_width, true)
	
	# Hand Palm
	var palm_pos := pos + dir * 6
	draw_circle(palm_pos, 8.0, style.robot_metal_color)
	draw_arc(palm_pos, 8.0, 0, TAU, 16, style.ink_color, style.inner_line_width, true)
	
	# Fingers based on pose
	match arm_pose:
		"clenched_fist":
			# Tightly curled fist
			draw_circle(palm_pos + dir * 6, 7.0, style.robot_metal_color)
			draw_arc(palm_pos + dir * 6, 7.0, 0, TAU, 16, style.ink_color, style.inner_line_width, true)
			draw_line(palm_pos + dir * 4 - norm * 5, palm_pos + dir * 4 + norm * 5, style.ink_color, 1.8)
		
		"point_forward":
			# Index finger pointing straight, other fingers curled
			var index_tip := palm_pos + dir * 20
			draw_line(palm_pos, index_tip, style.robot_metal_color, 4.2)
			draw_line(palm_pos, index_tip, style.ink_color, 1.6)
			# Curled knuckle clump
			draw_circle(palm_pos - norm * 4, 5.0, style.robot_metal_color)
			draw_arc(palm_pos - norm * 4, 5.0, 0, TAU, 12, style.ink_color, 1.4, true)
		
		_:
			# "palm_up_hover" & "explain_gesture": Open palm with 4 articulated fingers spread upwards
			var f_thumb := palm_pos - dir * 2 + norm * 12
			var f_index := palm_pos + dir * 14 + norm * 8
			var f_mid   := palm_pos + dir * 16 + norm * 2
			var f_ring  := palm_pos + dir * 14 - norm * 5
			
			var fingers := [f_thumb, f_index, f_mid, f_ring]
			for f in fingers:
				draw_line(palm_pos, f, style.robot_metal_color, 3.8)
				draw_line(palm_pos, f, style.ink_color, 1.4)
				# Fingertip rounded cap
				draw_circle(f, 2.0, style.robot_metal_highlight_color)

func _draw_magnetic_aura(pos: Vector2) -> void:
	# Ethereal pulsing magnetic field arcs above palm
	var col := style.energy_ring_color
	draw_arc(pos, 16.0, -PI * 0.7, PI * 0.7, 16, col, 2.0, false)
	draw_arc(pos, 24.0, -PI * 0.6, PI * 0.6, 16, Color(col.r, col.g, col.b, 0.25), 1.6, false)
