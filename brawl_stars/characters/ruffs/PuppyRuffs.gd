class_name PuppyRuffs
extends Node2D

## Procedural Hand-Drawn Puppy Rig for YOUNG RUFFS (Brawl Stars)
## The innocent, playful puppy before Cosmo's space experiment.
## 100% Native 2D Godot procedural vector rig:
## - Two big round innocent puppy eyes with glossy highlights (NO eyepatch)
## - Oversized floppy brown basset hound ears with bounce & perk physics
## - Soft orange fur with puffy cream chest & jowls
## - Tiny puppy paws, wagging tail, and playful/sleeping postures

const RuffsStyle = preload("res://brawl_stars/characters/ruffs/RuffsStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: RuffsStyle

# Directorial states
var current_pose: String = "sitting" # "playing", "chewing", "sitting", "sleeping", "standing", "hovering", "glass_press"
var current_expression: String = "happy" # "happy", "curious", "sleepy", "confused", "scared", "neutral"

# Transform & animation parameters
var head_tilt: float = 0.0
var ear_angle_l: float = 0.0
var ear_angle_r: float = 0.0
var eye_openness: float = 1.0
var gaze_direction: Vector2 = Vector2.ZERO
var tail_angle: float = 0.0
var is_tail_wagging: bool = true
var body_bob: float = 0.0

var _anim_time: float = 0.0
var _blink_tween: Tween
var _pose_tween: Tween

func _ready() -> void:
	if not style:
		style = RuffsStyle.new()
	queue_redraw()

func _process(delta: float) -> void:
	_anim_time += delta
	var needs_redraw := false
	
	if is_tail_wagging:
		tail_angle = sin(_anim_time * 12.0) * 0.4
		needs_redraw = true
		
	if current_pose == "sleeping":
		body_bob = sin(_anim_time * 2.5) * 1.5
		needs_redraw = true
	elif current_pose == "chewing":
		body_bob = sin(_anim_time * 8.0) * 1.2
		needs_redraw = true
	elif current_pose == "hovering":
		body_bob = sin(_anim_time * 3.0) * 3.0
		needs_redraw = true
		
	if needs_redraw:
		queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# Origin is at puppy center-bottom (0, 0)
	match current_pose:
		"sleeping":
			_draw_sleeping_body()
			_draw_curled_head()
		"chewing":
			_draw_chewing_body()
			_draw_active_head(Vector2(0, -28 + body_bob))
		"playing":
			_draw_playing_body()
			_draw_active_head(Vector2(-14, -36))
		"glass_press":
			_draw_glass_press_body()
			_draw_active_head(Vector2(0, -38))
		"hovering":
			_draw_hovering_body()
			_draw_active_head(Vector2(0, -36 + body_bob))
		_: # "sitting", "standing"
			_draw_sitting_body()
			_draw_active_head(Vector2(0, -36))

# -------------------------------------------------------------------------
# BODY DRAWING ROUTINES
# -------------------------------------------------------------------------

func _draw_sitting_body() -> void:
	# 1. Wagging Tail (Behind body)
	_draw_tail(Vector2(20, -12), tail_angle)
	
	# 2. Hind Leg / Haunches
	_draw_flat_ellipse(Vector2(-18, -10), Vector2(10, 8), style.fur_shadow_color)
	_draw_flat_ellipse(Vector2(18, -10), Vector2(10, 8), style.fur_shadow_color)
	
	# 3. Chubby Puppy Torso
	var torso_pts := PackedVector2Array([
		Vector2(-16, -34),
		Vector2(16, -34),
		Vector2(22, -8),
		Vector2(16, 0),
		Vector2(-16, 0),
		Vector2(-22, -8)
	])
	draw_colored_polygon(torso_pts, style.fur_orange_color)
	
	# Soft cream chest patch
	var chest_pts := PackedVector2Array([
		Vector2(-10, -34),
		Vector2(10, -34),
		Vector2(12, -12),
		Vector2(0, -4),
		Vector2(-12, -12)
	])
	draw_colored_polygon(chest_pts, style.muzzle_cream_color)
	
	var t_loop := PackedVector2Array()
	for p in torso_pts: t_loop.append(p)
	t_loop.append(torso_pts[0])
	CosmoInkStroke.from_points(t_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 4. Tiny Front Paws
	_draw_front_paws(Vector2(-8, -2), Vector2(8, -2))

func _draw_playing_body() -> void:
	# Play bow: front down, rear up, tail wagging excitedly
	_draw_tail(Vector2(28, -24), tail_angle * 1.5)
	
	var body_pts := PackedVector2Array([
		Vector2(-24, -14),
		Vector2(0, -28),
		Vector2(24, -26),
		Vector2(28, -8),
		Vector2(10, 0),
		Vector2(-18, 0)
	])
	draw_colored_polygon(body_pts, style.fur_orange_color)
	var b_loop := PackedVector2Array()
	for p in body_pts: b_loop.append(p)
	b_loop.append(body_pts[0])
	CosmoInkStroke.from_points(b_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Front paws stretched forward
	_draw_front_paws(Vector2(-24, 0), Vector2(-12, 0))

func _draw_chewing_body() -> void:
	# Prone body lying on floor holding toy
	_draw_tail(Vector2(24, -8), tail_angle * 0.8)
	
	var body_pts := PackedVector2Array([
		Vector2(-18, -18),
		Vector2(18, -18),
		Vector2(26, -2),
		Vector2(16, 2),
		Vector2(-16, 2),
		Vector2(-24, -2)
	])
	draw_colored_polygon(body_pts, style.fur_orange_color)
	var b_loop := PackedVector2Array()
	for p in body_pts: b_loop.append(p)
	b_loop.append(body_pts[0])
	CosmoInkStroke.from_points(b_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Paws tucked inwards hugging toy
	draw_circle(Vector2(-8, -6), 5.5, style.muzzle_cream_color)
	draw_arc(Vector2(-8, -6), 5.5, 0, TAU, 12, style.ink_color, 1.8, true)
	draw_circle(Vector2(8, -6), 5.5, style.muzzle_cream_color)
	draw_arc(Vector2(8, -6), 5.5, 0, TAU, 12, style.ink_color, 1.8, true)

func _draw_sleeping_body() -> void:
	# Curled round ball
	var sleep_pts := PackedVector2Array([
		Vector2(-22, -10),
		Vector2(-10, -22),
		Vector2(16, -22),
		Vector2(26, -10),
		Vector2(20, 2),
		Vector2(-16, 2)
	])
	draw_colored_polygon(sleep_pts, style.fur_orange_color)
	
	# Wrapped tail around nose
	var tail_pts := PackedVector2Array([
		Vector2(22, -6),
		Vector2(16, 2),
		Vector2(-6, 2),
		Vector2(-14, -2)
	])
	draw_polyline(tail_pts, style.fur_shadow_color, 7.0, true)
	
	var s_loop := PackedVector2Array()
	for p in sleep_pts: s_loop.append(p)
	s_loop.append(sleep_pts[0])
	CosmoInkStroke.from_points(s_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)

func _draw_hovering_body() -> void:
	_draw_tail(Vector2(18, -4), tail_angle * 0.6)
	var body_pts := PackedVector2Array([
		Vector2(-14, -30),
		Vector2(14, -30),
		Vector2(18, -8),
		Vector2(10, 4),
		Vector2(-10, 4),
		Vector2(-18, -8)
	])
	draw_colored_polygon(body_pts, style.fur_orange_color)
	var b_loop := PackedVector2Array()
	for p in body_pts: b_loop.append(p)
	b_loop.append(body_pts[0])
	CosmoInkStroke.from_points(b_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	# Dangling paws
	_draw_front_paws(Vector2(-8, 6), Vector2(8, 6))

func _draw_glass_press_body() -> void:
	var body_pts := PackedVector2Array([
		Vector2(-15, -34),
		Vector2(15, -34),
		Vector2(18, -10),
		Vector2(12, 0),
		Vector2(-12, 0),
		Vector2(-18, -10)
	])
	draw_colored_polygon(body_pts, style.fur_orange_color)
	var b_loop := PackedVector2Array()
	for p in body_pts: b_loop.append(p)
	b_loop.append(body_pts[0])
	CosmoInkStroke.from_points(b_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Both paws pressed outward/forward (flat oval against glass)
	draw_circle(Vector2(-18, -26), 6.5, style.muzzle_cream_color)
	draw_arc(Vector2(-18, -26), 6.5, 0, TAU, 14, style.ink_color, 2.0, true)
	draw_circle(Vector2(18, -26), 6.5, style.muzzle_cream_color)
	draw_arc(Vector2(18, -26), 6.5, 0, TAU, 14, style.ink_color, 2.0, true)

func _draw_tail(pos: Vector2, angle: float) -> void:
	draw_set_transform(pos, angle, Vector2.ONE)
	var t_pts := PackedVector2Array([
		Vector2(0, 0),
		Vector2(8, -6),
		Vector2(16, -8),
		Vector2(20, -4),
		Vector2(16, 2),
		Vector2(8, 2)
	])
	draw_colored_polygon(t_pts, style.fur_orange_color)
	var loop := PackedVector2Array()
	for p in t_pts: loop.append(p)
	loop.append(t_pts[0])
	CosmoInkStroke.from_points(loop, 2.2, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_front_paws(p1: Vector2, p2: Vector2) -> void:
	# Left Paw
	draw_circle(p1, 5.5, style.muzzle_cream_color)
	draw_arc(p1, 5.5, 0, TAU, 12, style.ink_color, 2.0, true)
	draw_line(p1 + Vector2(-2, 2), p1 + Vector2(-2, 5.5), style.ink_color, 1.4)
	draw_line(p1 + Vector2(2, 2), p1 + Vector2(2, 5.5), style.ink_color, 1.4)
	
	# Right Paw
	draw_circle(p2, 5.5, style.muzzle_cream_color)
	draw_arc(p2, 5.5, 0, TAU, 12, style.ink_color, 2.0, true)
	draw_line(p2 + Vector2(-2, 2), p2 + Vector2(-2, 5.5), style.ink_color, 1.4)
	draw_line(p2 + Vector2(2, 2), p2 + Vector2(2, 5.5), style.ink_color, 1.4)

# -------------------------------------------------------------------------
# HEAD & FACIAL DRAWING
# -------------------------------------------------------------------------

func _draw_active_head(head_center: Vector2) -> void:
	draw_set_transform(head_center, head_tilt, Vector2.ONE)
	
	# 1. Floppy Basset Hound Ears (Behind Head)
	_draw_puppy_ear(Vector2(-20, -8), ear_angle_l, true)
	_draw_puppy_ear(Vector2(20, -8), ear_angle_r, false)
	
	# 2. Round Chubby Puppy Head Base
	var head_pts := PackedVector2Array([
		Vector2(-26, -20),
		Vector2(0, -28),
		Vector2(26, -20),
		Vector2(32, 2),
		Vector2(24, 20),
		Vector2(0, 22),
		Vector2(-24, 20),
		Vector2(-32, 2)
	])
	draw_colored_polygon(head_pts, style.fur_orange_color)
	var h_loop := PackedVector2Array()
	for p in head_pts: h_loop.append(p)
	h_loop.append(head_pts[0])
	CosmoInkStroke.from_points(h_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 3. Two Big Innocent Puppy Eyes (NO eyepatch!)
	_draw_puppy_eyes()
	
	# 4. Soft Cream Drooping Muzzle & Mouth
	_draw_puppy_muzzle()
	
	# 5. Little Button Black Nose
	_draw_puppy_nose()
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_curled_head() -> void:
	# Sleeping head resting on paws
	var sleep_center := Vector2(-4, -12 + body_bob)
	draw_set_transform(sleep_center, 0.1, Vector2.ONE)
	
	# Ear draped over face
	_draw_puppy_ear(Vector2(-16, -6), 0.2, true)
	
	var head_pts := PackedVector2Array([
		Vector2(-20, -16),
		Vector2(14, -16),
		Vector2(20, 4),
		Vector2(0, 12),
		Vector2(-18, 8)
	])
	draw_colored_polygon(head_pts, style.fur_orange_color)
	var h_loop := PackedVector2Array()
	for p in head_pts: h_loop.append(p)
	h_loop.append(head_pts[0])
	CosmoInkStroke.from_points(h_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Closed sleeping eyes (peaceful crescents ^_^)
	draw_arc(Vector2(-8, -4), 5.0, PI * 1.1, PI * 1.9, 10, style.ink_color, 2.2, true)
	draw_arc(Vector2(8, -4), 5.0, PI * 1.1, PI * 1.9, 10, style.ink_color, 2.2, true)
	
	# Nose
	draw_circle(Vector2(0, 4), 3.5, style.nose_black_color)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_puppy_ear(base_pos: Vector2, angle: float, is_left: bool) -> void:
	var flip: float = -1.0 if is_left else 1.0
	draw_set_transform(base_pos, angle, Vector2.ONE)
	
	var ear_pts := PackedVector2Array([
		Vector2(0, 0),
		Vector2(10 * flip, 14),
		Vector2(14 * flip, 36),
		Vector2(0, 46), # Rounded ear tip
		Vector2(-10 * flip, 34),
		Vector2(-8 * flip, 12)
	])
	draw_colored_polygon(ear_pts, style.ear_brown_color)
	
	var loop := PackedVector2Array()
	for p in ear_pts: loop.append(p)
	loop.append(ear_pts[0])
	CosmoInkStroke.from_points(loop, 2.6, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_puppy_eyes() -> void:
	var eye_y := -6.0
	var left_eye_x := -13.0
	var right_eye_x := 13.0
	var eye_r := 7.5
	
	# Left Eye
	_draw_single_puppy_eye(Vector2(left_eye_x, eye_y), eye_r)
	
	# Right Eye
	_draw_single_puppy_eye(Vector2(right_eye_x, eye_y), eye_r)

func _draw_single_puppy_eye(pos: Vector2, rad: float) -> void:
	var effective_h := rad * eye_openness
	
	if eye_openness <= 0.1:
		# Closed blink / happy slit
		draw_arc(pos, rad * 0.8, PI * 1.1, PI * 1.9, 12, style.ink_color, 2.5, true)
		return
	
	# White Sclera
	_draw_flat_ellipse(pos, Vector2(rad, effective_h), Color.WHITE)
	draw_arc(pos, rad, 0, TAU, 18, style.ink_color, 2.0, true)
	
	# Big Shiny Dark Pupil
	var p_offset := gaze_direction * 2.5
	var pupil_r := rad * 0.72
	draw_circle(pos + p_offset, pupil_r * eye_openness, style.eye_pupil_color)
	
	# Big Anime / Puppy Specular Highlights
	draw_circle(pos + p_offset + Vector2(-2.2, -2.5), 2.4 * eye_openness, Color.WHITE)
	draw_circle(pos + p_offset + Vector2(2.5, 1.8), 1.3 * eye_openness, Color.WHITE)

func _draw_puppy_muzzle() -> void:
	# Puffy Cream Muzzle
	var muzzle_pts := PackedVector2Array([
		Vector2(0, -2),
		Vector2(-14, -1),
		Vector2(-22, 10),
		Vector2(-12, 18),
		Vector2(0, 14),
		Vector2(12, 18),
		Vector2(22, 10),
		Vector2(14, -1)
	])
	draw_colored_polygon(muzzle_pts, style.muzzle_cream_color)
	var m_loop := PackedVector2Array()
	for p in muzzle_pts: m_loop.append(p)
	m_loop.append(muzzle_pts[0])
	CosmoInkStroke.from_points(m_loop, 2.4, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Center vertical groove
	draw_line(Vector2(0, 4), Vector2(0, 14), style.ink_color, 1.6)
	
	# Mouth expression
	if current_expression == "happy" or current_expression == "excited":
		# Pink tongue peeking out happily
		var tongue_pts := PackedVector2Array([
			Vector2(-4, 14),
			Vector2(4, 14),
			Vector2(3, 22),
			Vector2(0, 24),
			Vector2(-3, 22)
		])
		draw_colored_polygon(tongue_pts, style.tongue_pink_color)
		var t_loop := PackedVector2Array()
		for p in tongue_pts: t_loop.append(p)
		t_loop.append(tongue_pts[0])
		draw_polyline(t_loop, style.ink_color, 1.5, true)
	
	# Whisker dots
	draw_circle(Vector2(-12, 8), 1.2, style.ink_color)
	draw_circle(Vector2(-16, 11), 1.2, style.ink_color)
	draw_circle(Vector2(12, 8), 1.2, style.ink_color)
	draw_circle(Vector2(16, 11), 1.2, style.ink_color)

func _draw_puppy_nose() -> void:
	var n_center := Vector2(0, 2)
	draw_circle(n_center, 4.5, style.nose_black_color)
	draw_circle(n_center + Vector2(-1.2, -1.2), 1.5, Color.WHITE) # Specular glint

func _draw_flat_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(24):
		var ang := (float(i) / 24.0) * TAU
		pts.append(center + Vector2(cos(ang) * radii.x, sin(ang) * radii.y))
	draw_colored_polygon(pts, color)

# -------------------------------------------------------------------------
# DIRECTORIAL CONTROLS
# -------------------------------------------------------------------------

func set_pose(pose: String, duration: float = 0.2) -> void:
	current_pose = pose
	match current_pose:
		"playing":
			head_tilt = -0.15
			ear_angle_l = -0.2
			ear_angle_r = 0.2
			is_tail_wagging = true
		"chewing":
			head_tilt = 0.05
			ear_angle_l = 0.1
			ear_angle_r = -0.1
			is_tail_wagging = true
		"sleeping":
			head_tilt = 0.0
			ear_angle_l = 0.25
			ear_angle_r = -0.25
			eye_openness = 0.0
			is_tail_wagging = false
		"hovering":
			head_tilt = -0.1
			ear_angle_l = -0.15
			ear_angle_r = 0.15
			is_tail_wagging = true
		"glass_press":
			head_tilt = 0.0
			ear_angle_l = -0.1
			ear_angle_r = 0.1
			is_tail_wagging = false
		_: # "sitting", "standing"
			head_tilt = 0.0
			ear_angle_l = 0.0
			ear_angle_r = 0.0
			eye_openness = 1.0
			is_tail_wagging = true
	queue_redraw()

func set_expression(expr: String) -> void:
	current_expression = expr
	match current_expression:
		"happy":
			eye_openness = 1.1
			gaze_direction = Vector2.ZERO
		"curious":
			eye_openness = 1.25
			gaze_direction = Vector2(0.4, -0.3)
			head_tilt = -0.18
			ear_angle_l = -0.25
		"sleepy":
			eye_openness = 0.25
			gaze_direction = Vector2(0.0, 0.4)
			ear_angle_l = 0.2
			ear_angle_r = -0.2
		"confused":
			eye_openness = 1.1
			gaze_direction = Vector2(-0.5, -0.2)
			head_tilt = 0.22
			ear_angle_l = 0.2
			ear_angle_r = -0.1
		"scared":
			eye_openness = 1.45
			gaze_direction = Vector2(0.0, -0.2)
			head_tilt = 0.0
			ear_angle_l = 0.3
			ear_angle_r = -0.3
		_:
			eye_openness = 1.0
			gaze_direction = Vector2.ZERO
			head_tilt = 0.0
	queue_redraw()

func wag_tail(enable: bool) -> void:
	is_tail_wagging = enable

func perk_ears() -> void:
	var tw := create_tween()
	tw.tween_property(self, "ear_angle_l", -0.28, 0.12)
	tw.parallel().tween_property(self, "ear_angle_r", 0.28, 0.12)

func droop_ears() -> void:
	var tw := create_tween()
	tw.tween_property(self, "ear_angle_l", 0.28, 0.15)
	tw.parallel().tween_property(self, "ear_angle_r", -0.28, 0.15)

func look_at_point(pos: Vector2) -> void:
	var dir := (pos - global_position).normalized()
	gaze_direction = dir
	queue_redraw()

func blink() -> void:
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	var cur_open := eye_openness
	_blink_tween = create_tween()
	_blink_tween.tween_property(self, "eye_openness", 0.0, 0.06)
	_blink_tween.tween_property(self, "eye_openness", cur_open, 0.08)
