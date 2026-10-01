class_name ADB
extends Node2D

## Master Independent Storytime Character: ADB (Cool Minimalist Knit V3)
## 100% Godot 4-native procedural 2D vector character.
## Authored to match the Common Storytime Animation Style:
## - Organic inking (#2b2623) with calligraphic tapered ribbon polygons
## - Handsome anime silhouette: tousled slate curtain bangs, relaxed oatmeal half-zip knit
## - Autonomous facial system (almond anime eyes, mobile eyebrows, multi-state mouth, blush)
## - Autonomous hand gesture system (12+ distinct hand shapes, prop attachment anchors)

signal pose_changed(new_pose: String)
signal expression_changed(new_expr: String)

const ADBStyle = preload("res://adb/characters/adb/ADBStyle.gd")
const ADBFace = preload("res://adb/expressions/ADBFace.gd")
const ADBHands = preload("res://adb/hands/ADBHands.gd")
const ADBPoseLibrary = preload("res://adb/poses/ADBPoseLibrary.gd")
const ADBLipSync = preload("res://adb/lipsync/ADBLipSync.gd")
const ADBGeometry = preload("res://adb/characters/adb/ADBGeometry.gd")
const CommonInkStroke = preload("res://common/engine/drawing/CommonInkStroke.gd")

## Head scale factor: scales head to match Nemi's head height (92px)
## while body has broad athletic shoulders and muscular chest
const HEAD_SCALE: float = 0.82

# Subsystem node references
var face: ADBFace
var left_hand_node: ADBHands
var right_hand_node: ADBHands
var lipsync: ADBLipSync

# --- RIG TRANSFORM STATES (Pelvis is (0, 0)) ---
var current_pose_name: String = "relaxed_standing"
var current_expression_name: String = "neutral"

# Torso & Head transforms
var torso_offset: Vector2 = Vector2.ZERO
var torso_tilt: float = 0.0          # Degrees
var head_offset: Vector2 = Vector2(0, -106)
var head_tilt: float = 0.0           # Degrees
var pelvis_offset: Vector2 = Vector2.ZERO

# Shoulder socket offsets for shrug / gesture lifts
var left_shoulder_offset: Vector2 = Vector2.ZERO
var right_shoulder_offset: Vector2 = Vector2.ZERO

# Arm joints (Shoulder -> Elbow -> Hand)
var left_shoulder: Vector2 = Vector2(-52, -78)
var left_elbow: Vector2 = Vector2(-58, -20)
var left_hand: Vector2 = Vector2(-52, 35)

var right_shoulder: Vector2 = Vector2(52, -78)
var right_elbow: Vector2 = Vector2(58, -20)
var right_hand: Vector2 = Vector2(52, 35)

# Lower body transforms
var left_leg_lean: float = 0.0
var right_leg_lean: float = 0.0
var left_foot_offset: Vector2 = Vector2.ZERO   # Local offset (X stance/stride, Y lift/step)
var right_foot_offset: Vector2 = Vector2.ZERO
var left_knee_bend: float = 0.0                # Horizontal knee shift / athletic bend
var right_knee_bend: float = 0.0
var is_seated: bool = false

# Secondary hair follow-through
var _hair_sway: float = 0.0
var _prev_head_tilt: float = 0.0

var _pose_tween: Tween
var _freeze_timer: float = 0.0

func _ready() -> void:
	_ensure_subsystems()
	face.position = head_offset
	set_pose("relaxed_standing", 0.0)
	set_expression("neutral", 0.0)
	queue_redraw()

func _ensure_subsystems() -> void:
	if not face:
		face = ADBFace.new()
		face.name = "ADBFace"
		add_child(face)
		
	if not left_hand_node:
		left_hand_node = ADBHands.new()
		left_hand_node.name = "LeftHand"
		left_hand_node.is_right = false
		add_child(left_hand_node)
		
	if not right_hand_node:
		right_hand_node = ADBHands.new()
		right_hand_node.name = "RightHand"
		right_hand_node.is_right = true
		add_child(right_hand_node)
		
	if not lipsync:
		lipsync = ADBLipSync.new(face)

func _process(delta: float) -> void:
	lipsync.update(delta)
	
	# Hair secondary motion spring physics
	var head_vel := (head_tilt - _prev_head_tilt) / maxf(delta, 0.001)
	_hair_sway = lerpf(_hair_sway, -head_vel * 0.05, delta * 8.0)
	_prev_head_tilt = head_tilt
	
	# Face tracks head bone with proportional scaling
	face.scale = Vector2(HEAD_SCALE, HEAD_SCALE)
	face.position = head_offset
	face.rotation_degrees = head_tilt
	
	# Keep shoulders mathematically locked to torso socket
	left_shoulder = get_shoulder_pos(false)
	right_shoulder = get_shoulder_pos(true)
	
	left_hand_node.position = left_hand
	var l_arm_dir := (left_hand - left_elbow).normalized()
	if l_arm_dir.length_squared() > 0.01:
		left_hand_node.rotation = l_arm_dir.angle() - PI * 0.5
		
	right_hand_node.position = right_hand
	var r_arm_dir := (right_hand - right_elbow).normalized()
	if r_arm_dir.length_squared() > 0.01:
		right_hand_node.rotation = r_arm_dir.angle() - PI * 0.5
	
	if _freeze_timer > 0.0:
		_freeze_timer -= delta
		
	queue_redraw()

## Computes exact torso shoulder socket position in root/world space
func get_shoulder_pos(is_right: bool) -> Vector2:
	var t_pos := torso_offset + pelvis_offset
	var rad := deg_to_rad(torso_tilt)
	var local_shoulder := Vector2(49.0 if is_right else -49.0, -76.0)
	var offset := right_shoulder_offset if is_right else left_shoulder_offset
	return t_pos + (local_shoulder + offset).rotated(rad)

# --- MASTER 2D VECTOR RENDERING ---

func _draw() -> void:
	# 1. Hair back layer (drawn behind head and neck)
	_draw_hair_back()
	
	# 2. Lower body (Wide-leg trousers in warm off-white & canvas sneakers)
	_draw_lower_body()
	
	# 3. Torso body fill, side contours, placket & buttons
	_draw_torso()
	
	# 4. Arms (Upper arm & forearm sleeves with cuffs and rounded shoulder caps)
	_draw_arms()
	
	# 5. Head base, jawline, ears & neck
	_draw_head_base()
	
	# 6. Open shirt collar lapels (drawn over neck and chest)
	_draw_collar()
	
	# 7. Hair front layer (Curtain bangs & textured flick strands)
	_draw_hair_front()

func _draw_hair_back() -> void:
	var h_pos := head_offset
	var rad := deg_to_rad(head_tilt + _hair_sway * 0.5)
	
	var base_poly := ADBGeometry.get_hair_back_polygon()
	var xformed := PackedVector2Array()
	for pt in base_poly:
		xformed.append(h_pos + (pt * HEAD_SCALE).rotated(rad))
		
	draw_colored_polygon(xformed, ADBStyle.HAIR_BASE)
	draw_polyline(xformed, ADBStyle.INK_HAIR, ADBStyle.LINE_WEIGHT_MAIN, true)

func _draw_head_base() -> void:
	var h_pos := head_offset
	var rad := deg_to_rad(head_tilt)
	var t_pos := torso_offset + pelvis_offset
	var t_rad := deg_to_rad(torso_tilt)
	
	# Neck connecting from chin down into the shirt collar (Y ~ -78)
	var neck_pts := PackedVector2Array([
		h_pos + (Vector2(-12, -4) * HEAD_SCALE).rotated(rad),
		h_pos + (Vector2(12, -4) * HEAD_SCALE).rotated(rad),
		t_pos + Vector2(16, -78).rotated(t_rad),
		t_pos + Vector2(-16, -78).rotated(t_rad)
	])
	draw_colored_polygon(neck_pts, ADBStyle.SKIN_BASE)
	
	# Throat shadow under chin
	var throat_shadow := PackedVector2Array([
		h_pos + (Vector2(-10, -4) * HEAD_SCALE).rotated(rad),
		h_pos + (Vector2(10, -4) * HEAD_SCALE).rotated(rad),
		h_pos + (Vector2(8, 12) * HEAD_SCALE).rotated(rad),
		h_pos + (Vector2(-8, 12) * HEAD_SCALE).rotated(rad)
	])
	draw_colored_polygon(throat_shadow, ADBStyle.SKIN_SHADOW)
	
	# Ears
	var left_ear := ADBGeometry.get_ear_polygon(true)
	var right_ear := ADBGeometry.get_ear_polygon(false)
	var x_left_ear := PackedVector2Array()
	var x_right_ear := PackedVector2Array()
	for pt in left_ear:
		x_left_ear.append(h_pos + (pt * HEAD_SCALE).rotated(rad))
	for pt in right_ear:
		x_right_ear.append(h_pos + (pt * HEAD_SCALE).rotated(rad))
	draw_colored_polygon(x_left_ear, ADBStyle.SKIN_BASE)
	draw_colored_polygon(x_right_ear, ADBStyle.SKIN_BASE)
	draw_polyline(x_left_ear, ADBStyle.INK_CONTOUR, 2.0, true)
	draw_polyline(x_right_ear, ADBStyle.INK_CONTOUR, 2.0, true)
	
	# Ear inner creases
	var l_crease := ADBGeometry.get_ear_crease(true)
	var r_crease := ADBGeometry.get_ear_crease(false)
	var xl_c := PackedVector2Array()
	var xr_c := PackedVector2Array()
	for pt in l_crease:
		xl_c.append(h_pos + (pt * HEAD_SCALE).rotated(rad))
	for pt in r_crease:
		xr_c.append(h_pos + (pt * HEAD_SCALE).rotated(rad))
	draw_polyline(xl_c, ADBStyle.INK_INNER, 1.6, false)
	draw_polyline(xr_c, ADBStyle.INK_INNER, 1.6, false)
	
	# Smooth anime head skull base
	var head_poly := ADBGeometry.get_head_base_polygon()
	var x_head := PackedVector2Array()
	for pt in head_poly:
		x_head.append(h_pos + (pt * HEAD_SCALE).rotated(rad))
	draw_colored_polygon(x_head, ADBStyle.SKIN_BASE)
	
	# Calligraphic jawline contour
	var jaw_poly := ADBGeometry.get_jaw_outline()
	var x_jaw := PackedVector2Array()
	for pt in jaw_poly:
		x_jaw.append(h_pos + (pt * HEAD_SCALE).rotated(rad))
	var jaw_stroke := CommonInkStroke.from_points(x_jaw, ADBStyle.LINE_WEIGHT_MAIN, CommonInkStroke.Profile.TAPER_BOTH, ADBStyle.INK_CONTOUR)
	jaw_stroke.draw_to(self)

func _draw_hair_front() -> void:
	var h_pos := head_offset
	var rad := deg_to_rad(head_tilt + _hair_sway)
	
	# 1. Main Unified Curtain Bangs & Crown Dome
	var bangs_poly := ADBGeometry.get_curtain_bangs_polygon()
	var x_bangs := PackedVector2Array()
	for pt in bangs_poly:
		x_bangs.append(h_pos + (pt * HEAD_SCALE).rotated(rad))
	draw_colored_polygon(x_bangs, ADBStyle.HAIR_BASE)
	draw_polyline(x_bangs, ADBStyle.INK_HAIR, ADBStyle.LINE_WEIGHT_MAIN, true)
	
	# 2. Tousled Crown & Side Flicks
	var flicks := ADBGeometry.get_hair_flicks()
	for f in flicks:
		var x_f := PackedVector2Array()
		for pt in f:
			x_f.append(h_pos + (pt * HEAD_SCALE).rotated(rad))
		draw_colored_polygon(x_f, ADBStyle.HAIR_BASE)
		draw_polyline(x_f, ADBStyle.INK_HAIR, 2.0, true)
	
	# 3. Interior Curtain Strand Separation Creases
	var creases := ADBGeometry.get_curtain_creases()
	for c in creases:
		var x_c := PackedVector2Array()
		for pt in c:
			x_c.append(h_pos + (pt * HEAD_SCALE).rotated(rad))
		var stroke := CommonInkStroke.from_points(x_c, 2.2, CommonInkStroke.Profile.TAPER_BOTH, ADBStyle.INK_HAIR)
		stroke.draw_to(self)
	
	# 4. Specular Glint Highlight on Bangs
	var glint_left := [
		h_pos + (Vector2(-26, -74) * HEAD_SCALE).rotated(rad),
		h_pos + (Vector2(-16, -68) * HEAD_SCALE).rotated(rad)
	]
	var glint_right := [
		h_pos + (Vector2(16, -68) * HEAD_SCALE).rotated(rad),
		h_pos + (Vector2(26, -74) * HEAD_SCALE).rotated(rad)
	]
	draw_polyline(glint_left, ADBStyle.HAIR_GLINT, 2.8, true)
	draw_polyline(glint_right, ADBStyle.HAIR_GLINT, 2.8, true)

## Computes exact upper sleeve corners so torso and sleeve share identical boundary vertices
func _get_sleeve_corners(shoulder: Vector2, elbow: Vector2, half_w_s: float = 11.5, half_w_e: float = 10.0) -> Dictionary:
	var dir := (elbow - shoulder).normalized()
	if dir.length_squared() < 0.001:
		dir = Vector2.DOWN
	var norm := Vector2(-dir.y, dir.x)
	var pt_a := shoulder - norm * half_w_s
	var pt_b := shoulder + norm * half_w_s
	var pt_ea := elbow - norm * half_w_e
	var pt_eb := elbow + norm * half_w_e
	
	# Determine outer edge (furthest from body center or top edge)
	var a_is_outer: bool
	if absf(dir.x) > absf(dir.y):
		# Horizontal pointing: smaller Y is the top/outer edge
		a_is_outer = pt_a.y < pt_b.y
	else:
		# Vertical hanging: larger absolute X is outer edge
		a_is_outer = absf(pt_a.x) > absf(pt_b.x)
		
	var p_outer := pt_a if a_is_outer else pt_b
	var p_inner := pt_b if a_is_outer else pt_a
	var p_e_outer := pt_ea if a_is_outer else pt_eb
	var p_e_inner := pt_eb if a_is_outer else pt_ea
	
	return {
		"outer": p_outer,
		"inner": p_inner,
		"e_outer": p_e_outer,
		"e_inner": p_e_inner,
		"poly": PackedVector2Array([p_outer, p_inner, p_e_inner, p_e_outer]),
		"dir": dir,
		"norm": norm
	}

func _draw_torso() -> void:
	var t_pos := torso_offset + pelvis_offset
	var rad := deg_to_rad(torso_tilt)
	var ls := get_shoulder_pos(false)
	var rs := get_shoulder_pos(true)
	
	# Sleeve corner anchors for seamless shared-vertex topology (relaxed drop-shoulders)
	var l_sleeve := _get_sleeve_corners(ls, left_elbow, 11.5, 10.0)
	var r_sleeve := _get_sleeve_corners(rs, right_elbow, 11.5, 10.0)
	
	# Torso contour key points in torso space
	# OVERSIZED from shoulders only: broad drop-shoulders (±49, -76) extending to outer sleeves (±60.5)
	# TOUCHING THE BODY below chest: clean waist (±38, -10), lengthened hip hem (±38.5, 21), NO middle pointy bulge
	var hem_c: Vector2 = t_pos + Vector2(0, 25).rotated(rad)
	var hem_l: Vector2 = t_pos + Vector2(-38.5, 21).rotated(rad)
	var waist_l: Vector2 = t_pos + Vector2(-38.0, -10).rotated(rad)
	var armpit_l: Vector2 = t_pos + Vector2(-42.0, -56.0).rotated(rad)
	var sh_l: Vector2 = t_pos + Vector2(-49.0, -76.0).rotated(rad)
	var collar_l: Vector2 = t_pos + Vector2(-20, -84).rotated(rad)
	var collar_dip: Vector2 = t_pos + Vector2(0, -82).rotated(rad)
	var collar_r: Vector2 = t_pos + Vector2(20, -84).rotated(rad)
	var sh_r: Vector2 = t_pos + Vector2(49.0, -76.0).rotated(rad)
	var armpit_r: Vector2 = t_pos + Vector2(42.0, -56.0).rotated(rad)
	var waist_r: Vector2 = t_pos + Vector2(38.0, -10).rotated(rad)
	var hem_r: Vector2 = t_pos + Vector2(38.5, 21).rotated(rad)
	
	# 1. Torso body fill polygon (robust simple polygon that NEVER self-intersects)
	var body_poly := PackedVector2Array([
		hem_c, hem_l, waist_l, armpit_l, sh_l, collar_l, collar_dip, collar_r, sh_r, armpit_r, waist_r, hem_r
	])
	draw_colored_polygon(body_poly, ADBStyle.SHIRT_BASE)
	
	# 2. Side contours (hips to armpits)
	var left_side := PackedVector2Array([hem_l, waist_l, armpit_l])
	var right_side := PackedVector2Array([hem_r, waist_r, armpit_r])
	draw_polyline(left_side, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, false)
	draw_polyline(right_side, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, false)
	
	# 3. Organic curved shoulder slope lines (connecting collar to shoulder outer corners)
	var l_sh_mid := t_pos + Vector2(-36, -81).rotated(rad)
	var r_sh_mid := t_pos + Vector2(36, -81).rotated(rad)
	var l_shoulder_curve := PackedVector2Array([collar_l, l_sh_mid, sh_l])
	var r_shoulder_curve := PackedVector2Array([collar_r, r_sh_mid, sh_r])
	draw_polyline(l_shoulder_curve, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, false)
	draw_polyline(r_shoulder_curve, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, false)
	
	# 4. Bare chest & throat inside open unbuttoned collar (NO inner shirt - skin tone only)
	var chest_skin := PackedVector2Array([
		t_pos + Vector2(-8, -84).rotated(rad),
		t_pos + Vector2(8, -84).rotated(rad),
		t_pos + Vector2(4, -58).rotated(rad),
		t_pos + Vector2(0, -42).rotated(rad),
		t_pos + Vector2(-4, -58).rotated(rad)
	])
	draw_colored_polygon(chest_skin, ADBStyle.SKIN_BASE)
	
	# Clavicle / collarbone contour lines in skin shadow
	var clavicle_l := [t_pos + Vector2(-2, -58).rotated(rad), t_pos + Vector2(-12, -64).rotated(rad)]
	var clavicle_r := [t_pos + Vector2(2, -58).rotated(rad), t_pos + Vector2(12, -64).rotated(rad)]
	draw_polyline(clavicle_l, ADBStyle.SKIN_SHADOW, 1.8, false)
	draw_polyline(clavicle_r, ADBStyle.SKIN_SHADOW, 1.8, false)
	
	# Sternal notch shadow accent
	draw_circle(t_pos + Vector2(0, -59).rotated(rad), 1.2, ADBStyle.SKIN_SHADOW)
	
	# 5. Button placket starting below open V apex down to extended hem
	var placket_top := t_pos + Vector2(0, -42).rotated(rad)
	var placket_bot := t_pos + Vector2(0, 22).rotated(rad)
	draw_line(placket_top, placket_bot, ADBStyle.SHIRT_SHADOW, 3.5)
	draw_line(placket_top, placket_bot, ADBStyle.INK_CONTOUR, 1.4)
	
	# Buttons along placket
	var b1 := t_pos + Vector2(0, -27).rotated(rad)
	var b2 := t_pos + Vector2(0, -12).rotated(rad)
	var b3 := t_pos + Vector2(0, 3).rotated(rad)
	var b4 := t_pos + Vector2(0, 18).rotated(rad)
	for b_pos in [b1, b2, b3, b4]:
		draw_circle(b_pos, 2.2, ADBStyle.BUTTON_COLOR)
		draw_circle(b_pos, 1.0, Color("#f3f0e8"))
	
	# Unbuttoned collar notch lines spreading from V apex
	var notch_l := [t_pos + Vector2(0, -42).rotated(rad), t_pos + Vector2(-6, -56).rotated(rad)]
	var notch_r := [t_pos + Vector2(0, -42).rotated(rad), t_pos + Vector2(6, -56).rotated(rad)]
	draw_polyline(notch_l, ADBStyle.INK_CONTOUR, 1.8, false)
	draw_polyline(notch_r, ADBStyle.INK_CONTOUR, 1.8, false)
	
	# 6. Clean Fitted Curved Hem touching the body/waist (lengthened down)
	var hem_curve := PackedVector2Array([
		hem_l,
		t_pos + Vector2(-19, 24).rotated(rad),
		hem_c,
		t_pos + Vector2(19, 24).rotated(rad),
		hem_r
	])
	draw_polyline(hem_curve, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, false)
	
	# Shirt hem stitch line
	var stitch_curve := PackedVector2Array([
		t_pos + Vector2(-36.5, 18.5).rotated(rad),
		t_pos + Vector2(-18.0, 21.5).rotated(rad),
		t_pos + Vector2(0, 22.5).rotated(rad),
		t_pos + Vector2(18.0, 21.5).rotated(rad),
		t_pos + Vector2(36.5, 18.5).rotated(rad)
	])
	draw_polyline(stitch_curve, ADBStyle.SHIRT_SHADOW, 1.4, false)
	
	# Small side hem slits
	draw_line(hem_l, t_pos + Vector2(-38.5, 16).rotated(rad), ADBStyle.INK_CONTOUR, 1.8)
	draw_line(hem_r, t_pos + Vector2(38.5, 16).rotated(rad), ADBStyle.INK_CONTOUR, 1.8)
	
	# Body drape folds (clean natural fabric drape down the torso)
	var fold1 := [t_pos + Vector2(-26, -24).rotated(rad), t_pos + Vector2(-30, -6).rotated(rad)]
	var fold2 := [t_pos + Vector2(26, -24).rotated(rad), t_pos + Vector2(30, -6).rotated(rad)]
	var fold3 := [t_pos + Vector2(-22, 2).rotated(rad), t_pos + Vector2(-25, 16).rotated(rad)]
	var fold4 := [t_pos + Vector2(22, 2).rotated(rad), t_pos + Vector2(25, 16).rotated(rad)]
	draw_polyline(fold1, ADBStyle.SHIRT_SHADOW, 1.6, false)
	draw_polyline(fold2, ADBStyle.SHIRT_SHADOW, 1.6, false)
	draw_polyline(fold3, ADBStyle.SHIRT_SHADOW, 1.5, false)
	draw_polyline(fold4, ADBStyle.SHIRT_SHADOW, 1.5, false)

func _draw_collar() -> void:
	var t_pos := torso_offset + pelvis_offset
	var rad := deg_to_rad(torso_tilt)
	
	# Open Shirt Collar Lapels (Left and Right)
	var lapel_l := ADBGeometry.get_collar_lapel_left()
	var lapel_r := ADBGeometry.get_collar_lapel_right()
	var xl := PackedVector2Array()
	var xr := PackedVector2Array()
	for pt in lapel_l:
		xl.append(t_pos + pt.rotated(rad))
	for pt in lapel_r:
		xr.append(t_pos + pt.rotated(rad))
	draw_colored_polygon(xl, ADBStyle.SHIRT_COLLAR)
	draw_colored_polygon(xr, ADBStyle.SHIRT_COLLAR)
	draw_polyline(xl, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, true)
	draw_polyline(xr, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, true)

func _draw_arms() -> void:
	_draw_arm_chain(left_shoulder, left_elbow, left_hand, false)
	_draw_arm_chain(right_shoulder, right_elbow, right_hand, true)

func _draw_arm_chain(shoulder: Vector2, elbow: Vector2, hand: Vector2, is_right_arm: bool) -> void:
	# 1. Upper arm sleeve (oversized, relaxed cut from drop-shoulder to elbow)
	var half_w_shoulder := 11.5
	var half_w_elbow := 10.0
	var sleeve := _get_sleeve_corners(shoulder, elbow, half_w_shoulder, half_w_elbow)
	draw_circle(shoulder, half_w_shoulder, ADBStyle.SHIRT_BASE)
	draw_colored_polygon(sleeve.poly, ADBStyle.SHIRT_BASE)
	
	# Side contours
	draw_line(sleeve.outer, sleeve.e_outer, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN)
	draw_line(sleeve.inner, sleeve.e_inner, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN)
	
	# Relaxed drop shoulder crease
	var dir_u: Vector2 = sleeve.dir
	var norm_u: Vector2 = sleeve.norm
	var shoulder_fold := [
		shoulder + dir_u * 14.0 - norm_u * 7.0,
		shoulder + dir_u * 18.0 + norm_u * 2.0
	]
	draw_polyline(shoulder_fold, ADBStyle.SHIRT_SHADOW, 1.8, false)
	
	# 2. Elbow round joint cap
	draw_circle(elbow, half_w_elbow, ADBStyle.SHIRT_BASE)
	
	# 3. Forearm with ROLLED SLEEVE
	var forearm_vec := hand - elbow
	var forearm_len := forearm_vec.length()
	var dir_f := forearm_vec / maxf(forearm_len, 0.001)
	var norm_f := Vector2(-dir_f.y, dir_f.x)
	
	# Rolled sleeve cuffs sit comfortably below the elbow crook (roughly 30% down the forearm)
	var roll_dist := clampf(forearm_len * 0.30, 12.0, 22.0)
	var roll_center := elbow + dir_f * roll_dist
	var roll_start := roll_center - dir_f * 4.0
	var roll_end := roll_center + dir_f * 5.0
	
	# Part 3A: Upper forearm sleeve (fabric from elbow to roll start)
	var w_roll_top := 10.5
	var fe_l := elbow - norm_f * half_w_elbow
	var fe_r := elbow + norm_f * half_w_elbow
	var fr_top_r := roll_start + norm_f * w_roll_top
	var fr_top_l := roll_start - norm_f * w_roll_top
	
	var forearm_shirt_poly := PackedVector2Array([fe_l, fe_r, fr_top_r, fr_top_l])
	draw_colored_polygon(forearm_shirt_poly, ADBStyle.SHIRT_BASE)
	
	# Determine outer edge of forearm to connect smoothly with elbow joint
	var f_l_is_outer: bool
	if absf(dir_f.x) > absf(dir_f.y):
		f_l_is_outer = fe_l.y < fe_r.y
	else:
		f_l_is_outer = absf(fe_l.x) > absf(fe_r.x)
	var f_outer_e := fe_l if f_l_is_outer else fe_r
	var f_outer_r := fr_top_l if f_l_is_outer else fr_top_r
	var f_inner_e := fe_r if f_l_is_outer else fe_l
	var f_inner_r := fr_top_r if f_l_is_outer else fr_top_l
	
	# Draw outer and inner forearm sleeve contours
	draw_line(f_outer_e, f_outer_r, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN)
	draw_line(f_inner_e, f_inner_r, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN)
	
	# Outer elbow bridge contour line connecting upper sleeve to forearm sleeve
	draw_line(sleeve.e_outer, f_outer_e, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN)
	
	# Fabric bunching fold just above the rolled cuff
	draw_line(roll_start - dir_f * 3.0 - norm_f * 6.5, roll_start - dir_f * 2.0 + norm_f * 6.5, ADBStyle.SHIRT_SHADOW, 1.8)
	
	# Part 3B: Rolled Cuff Band (folded cuff turned up)
	var w_cuff := 11.8
	var cuff_p1 := roll_start - norm_f * w_cuff
	var cuff_p2 := roll_start + norm_f * w_cuff
	var cuff_p3 := roll_end + norm_f * w_cuff
	var cuff_p4 := roll_end - norm_f * w_cuff
	var roll_cuff := PackedVector2Array([cuff_p1, cuff_p2, cuff_p3, cuff_p4])
	
	draw_colored_polygon(roll_cuff, ADBStyle.SHIRT_COLLAR)
	draw_polyline(roll_cuff, ADBStyle.INK_CONTOUR, 2.0, true)
	
	# Double-fold roll seam line in the middle
	draw_line(roll_center - norm_f * (w_cuff - 1.0), roll_center + norm_f * (w_cuff - 1.0), ADBStyle.SHIRT_SHADOW, 1.6)
	
	# Rolled sleeve button / tab accent on outer edge
	var outer_sign := -1.0 if is_right_arm else 1.0
	var tab_center := roll_center + norm_f * (w_cuff * 0.45 * outer_sign)
	draw_circle(tab_center, 1.4, ADBStyle.BUTTON_COLOR)
	
	# Part 3C: Bare Forearm & Wrist (from roll_end to hand)
	var w_arm_top := 8.2   # Athletic width just below rolled cuff
	var w_wrist := 5.5     # Width at wrist joint
	var arm_top_l := roll_end - norm_f * w_arm_top
	var arm_top_r := roll_end + norm_f * w_arm_top
	var wrist_r := hand + norm_f * w_wrist
	var wrist_l := hand - norm_f * w_wrist
	
	var bare_arm_poly := PackedVector2Array([arm_top_l, arm_top_r, wrist_r, wrist_l])
	draw_colored_polygon(bare_arm_poly, ADBStyle.SKIN_BASE)
	draw_line(arm_top_l, wrist_l, ADBStyle.INK_CONTOUR, 2.0)
	draw_line(arm_top_r, wrist_r, ADBStyle.INK_CONTOUR, 2.0)
	
	# Subtle forearm muscle / ulna contour
	if forearm_len > 35.0:
		var muscle_start := roll_end + dir_f * 5.0 + norm_f * (w_arm_top * 0.3 * outer_sign)
		var muscle_end := hand - dir_f * 10.0 + norm_f * (w_wrist * 0.2 * outer_sign)
		draw_line(muscle_start, muscle_end, ADBStyle.SKIN_SHADOW, 1.4)

func _draw_lower_body() -> void:
	var p_pos := pelvis_offset
	
	if is_seated:
		# Seated thighs
		var left_thigh := PackedVector2Array([
			p_pos + Vector2(-36, 10),
			p_pos + Vector2(-6, 10),
			p_pos + Vector2(-6, 75),
			p_pos + Vector2(-36, 75)
		])
		draw_colored_polygon(left_thigh, ADBStyle.TROUSER_BASE)
		draw_polyline(left_thigh, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, true)
		
		var right_thigh := PackedVector2Array([
			p_pos + Vector2(6, 10),
			p_pos + Vector2(36, 10),
			p_pos + Vector2(36, 75),
			p_pos + Vector2(6, 75)
		])
		draw_colored_polygon(right_thigh, ADBStyle.TROUSER_BASE)
		draw_polyline(right_thigh, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, true)
		
		# Shins down to floor
		_draw_shin_and_sneaker(p_pos + Vector2(-21, 75), p_pos + Vector2(-24, 175), false)
		_draw_shin_and_sneaker(p_pos + Vector2(21, 75), p_pos + Vector2(24, 175), true)
	else:
		# Unified wide-leg trousers: flowing drape cut in warm off-white (#ece8df)
		var l_hip_out := -38.0 + left_leg_lean * 0.5
		var l_hem_out := -36.0 + left_leg_lean + left_foot_offset.x
		var l_hem_in := -8.0 + left_leg_lean + left_foot_offset.x
		var l_hem_y := 178.0 + left_foot_offset.y
		
		var r_hip_out := 38.0 + right_leg_lean * 0.5
		var r_hem_out := 36.0 + right_leg_lean + right_foot_offset.x
		var r_hem_in := 8.0 + right_leg_lean + right_foot_offset.x
		var r_hem_y := 178.0 + right_foot_offset.y
		
		# Dynamic knee joints for bending and athletic stance
		var l_knee_out := lerpf(l_hip_out, l_hem_out, 0.5) + left_knee_bend
		var l_knee_in := lerpf(0.0, l_hem_in, 0.5) + left_knee_bend
		var r_knee_out := lerpf(r_hip_out, r_hem_out, 0.5) + right_knee_bend
		var r_knee_in := lerpf(0.0, r_hem_in, 0.5) + right_knee_bend

		# 1. Left leg polygon
		var left_leg := PackedVector2Array([
			p_pos + Vector2(l_hip_out, 12),
			p_pos + Vector2(l_knee_out, 105),
			p_pos + Vector2(l_hem_out, l_hem_y),
			p_pos + Vector2(l_hem_in, l_hem_y),
			p_pos + Vector2(l_knee_in, 105),
			p_pos + Vector2(0, 46)
		])
		draw_colored_polygon(left_leg, ADBStyle.TROUSER_BASE)
		
		# 2. Right leg polygon
		var right_leg := PackedVector2Array([
			p_pos + Vector2(0, 46),
			p_pos + Vector2(r_knee_in, 105),
			p_pos + Vector2(r_hem_in, r_hem_y),
			p_pos + Vector2(r_hem_out, r_hem_y),
			p_pos + Vector2(r_knee_out, 105),
			p_pos + Vector2(r_hip_out, 12)
		])
		draw_colored_polygon(right_leg, ADBStyle.TROUSER_BASE)
		
		# 3. Pelvis seat fill under shirt hem
		var pelvis_fill := PackedVector2Array([
			p_pos + Vector2(-42, 4),
			p_pos + Vector2(42, 4),
			p_pos + Vector2(38, 25),
			p_pos + Vector2(0, 46),
			p_pos + Vector2(-38, 25)
		])
		draw_colored_polygon(pelvis_fill, ADBStyle.TROUSER_BASE)
		
		# 4. Outseams (smooth hip -> knee -> cuff)
		var left_outseam := PackedVector2Array([
			p_pos + Vector2(l_hip_out, 23),
			p_pos + Vector2(l_knee_out, 105),
			p_pos + Vector2(l_hem_out, l_hem_y)
		])
		var right_outseam := PackedVector2Array([
			p_pos + Vector2(r_hip_out, 23),
			p_pos + Vector2(r_knee_out, 105),
			p_pos + Vector2(r_hem_out, r_hem_y)
		])
		draw_polyline(left_outseam, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, false)
		draw_polyline(right_outseam, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, false)
		
		# 5. Inseam (left hem -> left knee in -> crotch -> right knee in -> right hem)
		var inseam := PackedVector2Array([
			p_pos + Vector2(l_hem_in, l_hem_y),
			p_pos + Vector2(l_knee_in, 105),
			p_pos + Vector2(0, 46),
			p_pos + Vector2(r_knee_in, 105),
			p_pos + Vector2(r_hem_in, r_hem_y)
		])
		draw_polyline(inseam, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, false)
		
		# 6. Hem lines across cuffs
		draw_line(p_pos + Vector2(l_hem_out, l_hem_y), p_pos + Vector2(l_hem_in, l_hem_y), ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN)
		draw_line(p_pos + Vector2(r_hem_in, r_hem_y), p_pos + Vector2(r_hem_out, r_hem_y), ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN)
		
		# 7. Crotch fly seam
		draw_line(p_pos + Vector2(0, 23), p_pos + Vector2(0, 38), ADBStyle.TROUSER_SEAM, 1.8)
		
		# 8. Clean tailored vertical crease lines down center of each pant leg
		var l_crease_x := (l_hem_out + l_hem_in) * 0.5
		var r_crease_x := (r_hem_out + r_hem_in) * 0.5
		var l_crease := PackedVector2Array([
			p_pos + Vector2((l_hip_out + 0.0) * 0.5, 26),
			p_pos + Vector2((l_knee_out + l_knee_in) * 0.5, 105),
			p_pos + Vector2(l_crease_x, l_hem_y - 4)
		])
		var r_crease := PackedVector2Array([
			p_pos + Vector2((r_hip_out + 0.0) * 0.5, 26),
			p_pos + Vector2((r_knee_out + r_knee_in) * 0.5, 105),
			p_pos + Vector2(r_crease_x, r_hem_y - 4)
		])
		draw_polyline(l_crease, ADBStyle.TROUSER_SEAM, 1.6, false)
		draw_polyline(r_crease, ADBStyle.TROUSER_SEAM, 1.6, false)
		
		# 9. Dark Canvas Sneakers under wide pant cuffs
		_draw_sneaker(p_pos + Vector2(l_crease_x, l_hem_y), true)
		_draw_sneaker(p_pos + Vector2(r_crease_x, r_hem_y), false)

func _draw_shin_and_sneaker(knee: Vector2, foot: Vector2, is_right_leg: bool) -> void:
	var leg_pts := PackedVector2Array([
		knee + Vector2(-12, 0),
		knee + Vector2(12, 0),
		foot + Vector2(11, -12),
		foot + Vector2(-11, -12)
	])
	draw_colored_polygon(leg_pts, ADBStyle.TROUSER_BASE)
	draw_polyline(leg_pts, ADBStyle.INK_CONTOUR, ADBStyle.LINE_WEIGHT_MAIN, true)
	_draw_sneaker(foot, is_right_leg)

func _draw_sneaker(pos: Vector2, is_left: bool) -> void:
	# Canvas upper
	var upper := ADBGeometry.get_sneaker_polygon(pos, is_left)
	draw_colored_polygon(upper, ADBStyle.SNEAKER_BASE)
	draw_polyline(upper, ADBStyle.INK_CONTOUR, 2.0, true)
	
	# Rubber toe cap
	var toe := ADBGeometry.get_sneaker_toe_cap(pos, is_left)
	draw_colored_polygon(toe, ADBStyle.SNEAKER_SOLE)
	draw_polyline(toe, ADBStyle.INK_CONTOUR, 1.8, true)
	
	# Sole tread line
	var sole := ADBGeometry.get_sneaker_sole(pos, is_left)
	draw_colored_polygon(sole, ADBStyle.SNEAKER_TREAD)
	draw_polyline(sole, ADBStyle.INK_CONTOUR, 2.0, true)

# --- DIRECTORIAL ACTING & POSE API ---

func set_pose(pose_name: String, duration: float = 0.20) -> void:
	current_pose_name = pose_name.to_lower()
	var pose_data: Dictionary = ADBPoseLibrary.get_pose(current_pose_name)
	if pose_data.is_empty():
		push_warning("[ADB] Unknown pose: " + pose_name)
		return
		
	var t_torso_off: Vector2 = pose_data.get("torso_offset", Vector2.ZERO)
	var t_torso_tilt: float = pose_data.get("torso_tilt", 0.0)
	var t_head_off: Vector2 = pose_data.get("head_offset", Vector2(0, -106))
	var t_head_tilt: float = pose_data.get("head_tilt", 0.0)
	var t_pelvis_off: Vector2 = pose_data.get("pelvis_offset", Vector2.ZERO)
	
	var t_left_shoulder: Vector2 = pose_data.get("left_shoulder", Vector2(-52, -78))
	var t_left_elbow: Vector2 = pose_data.get("left_elbow", Vector2(-58, -20))
	var t_left_hand: Vector2 = pose_data.get("left_hand", Vector2(-52, 35))
	
	var t_right_shoulder: Vector2 = pose_data.get("right_shoulder", Vector2(52, -78))
	var t_right_elbow: Vector2 = pose_data.get("right_elbow", Vector2(58, -20))
	var t_right_hand: Vector2 = pose_data.get("right_hand", Vector2(52, 35))
	
	var t_left_lean: float = pose_data.get("left_leg_lean", 0.0)
	var t_right_lean: float = pose_data.get("right_leg_lean", 0.0)
	var t_left_foot: Vector2 = pose_data.get("left_foot_offset", Vector2.ZERO)
	var t_right_foot: Vector2 = pose_data.get("right_foot_offset", Vector2.ZERO)
	var t_left_knee: float = pose_data.get("left_knee_bend", 0.0)
	var t_right_knee: float = pose_data.get("right_knee_bend", 0.0)
	var t_seated: bool = pose_data.get("is_seated", false)
	
	var left_hand_type: String = pose_data.get("left_hand_type", "relaxed")
	var right_hand_type: String = pose_data.get("right_hand_type", "relaxed")
	
	_ensure_subsystems()
	left_hand_node.set_hand_type(left_hand_type)
	right_hand_node.set_hand_type(right_hand_type)
	is_seated = t_seated
	
	# Calculate shoulder offsets from base torso socket
	var t_torso_pos := t_torso_off + t_pelvis_off
	var t_rad := deg_to_rad(t_torso_tilt)
	var base_ls := t_torso_pos + Vector2(-52, -78).rotated(t_rad)
	var base_rs := t_torso_pos + Vector2(52, -78).rotated(t_rad)
	var t_ls_off := (t_left_shoulder - base_ls).rotated(-t_rad)
	var t_rs_off := (t_right_shoulder - base_rs).rotated(-t_rad)
	
	if duration <= 0.001:
		torso_offset = t_torso_off
		torso_tilt = t_torso_tilt
		head_offset = t_head_off
		head_tilt = t_head_tilt
		pelvis_offset = t_pelvis_off
		left_shoulder_offset = t_ls_off
		right_shoulder_offset = t_rs_off
		left_shoulder = get_shoulder_pos(false)
		right_shoulder = get_shoulder_pos(true)
		left_elbow = t_left_elbow
		left_hand = t_left_hand
		right_elbow = t_right_elbow
		right_hand = t_right_hand
		left_leg_lean = t_left_lean
		right_leg_lean = t_right_lean
		left_foot_offset = t_left_foot
		right_foot_offset = t_right_foot
		left_knee_bend = t_left_knee
		right_knee_bend = t_right_knee
		queue_redraw()
		return
		
	if _pose_tween and _pose_tween.is_valid():
		_pose_tween.kill()
		
	_pose_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_pose_tween.tween_property(self, "torso_offset", t_torso_off, duration)
	_pose_tween.tween_property(self, "torso_tilt", t_torso_tilt, duration)
	_pose_tween.tween_property(self, "head_offset", t_head_off, duration)
	_pose_tween.tween_property(self, "head_tilt", t_head_tilt, duration)
	_pose_tween.tween_property(self, "pelvis_offset", t_pelvis_off, duration)
	_pose_tween.tween_property(self, "left_shoulder_offset", t_ls_off, duration)
	_pose_tween.tween_property(self, "right_shoulder_offset", t_rs_off, duration)
	_pose_tween.tween_property(self, "left_elbow", t_left_elbow, duration)
	_pose_tween.tween_property(self, "left_hand", t_left_hand, duration)
	_pose_tween.tween_property(self, "right_elbow", t_right_elbow, duration)
	_pose_tween.tween_property(self, "right_hand", t_right_hand, duration)
	_pose_tween.tween_property(self, "left_leg_lean", t_left_lean, duration)
	_pose_tween.tween_property(self, "right_leg_lean", t_right_lean, duration)
	_pose_tween.tween_property(self, "left_foot_offset", t_left_foot, duration)
	_pose_tween.tween_property(self, "right_foot_offset", t_right_foot, duration)
	_pose_tween.tween_property(self, "left_knee_bend", t_left_knee, duration)
	_pose_tween.tween_property(self, "right_knee_bend", t_right_knee, duration)
	_pose_tween.step_finished.connect(func(_idx): queue_redraw())
	_pose_tween.finished.connect(queue_redraw)
	
	pose_changed.emit(current_pose_name)

## Dynamic lower-body direct acting methods
func step_foot(is_left_foot: bool, offset: Vector2, knee_bend: float = 0.0, duration: float = 0.22) -> void:
	var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if is_left_foot:
		tw.tween_property(self, "left_foot_offset", offset, duration)
		tw.tween_property(self, "left_knee_bend", knee_bend, duration)
	else:
		tw.tween_property(self, "right_foot_offset", offset, duration)
		tw.tween_property(self, "right_knee_bend", knee_bend, duration)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)

func shift_weight(lean_left: float, lean_right: float, pelvis_shift_x: float = 0.0, duration: float = 0.25) -> void:
	var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "left_leg_lean", lean_left, duration)
	tw.tween_property(self, "right_leg_lean", lean_right, duration)
	tw.tween_property(self, "pelvis_offset:x", pelvis_shift_x, duration)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)

func reset_legs(duration: float = 0.20) -> void:
	var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "left_leg_lean", 0.0, duration)
	tw.tween_property(self, "right_leg_lean", 0.0, duration)
	tw.tween_property(self, "left_foot_offset", Vector2.ZERO, duration)
	tw.tween_property(self, "right_foot_offset", Vector2.ZERO, duration)
	tw.tween_property(self, "left_knee_bend", 0.0, duration)
	tw.tween_property(self, "right_knee_bend", 0.0, duration)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)

func set_expression(expr_name: String, duration: float = 0.15) -> void:
	_ensure_subsystems()
	current_expression_name = expr_name
	face.set_expression(expr_name, duration)
	expression_changed.emit(expr_name)

func blink(duration: float = 0.14) -> void:
	_ensure_subsystems()
	face.blink(duration)

func look(direction: String) -> void:
	_ensure_subsystems()
	match direction.to_lower():
		"camera":
			face.look_at_direction(Vector2.ZERO)
		"side_eye":
			face.look_at_direction(Vector2(0.8, -0.1))
		"down":
			face.look_at_direction(Vector2(0.0, 0.7))
		"up":
			face.look_at_direction(Vector2(0.0, -0.7))
		"away":
			face.look_at_direction(Vector2(-0.85, 0.2))
		_:
			face.look_at_direction(Vector2.ZERO)

func head_tilt_to(target_deg: float, duration: float = 0.20) -> void:
	if duration <= 0.001:
		head_tilt = target_deg
		queue_redraw()
		return
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "head_tilt", target_deg, duration)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)

func freeze_stillness(duration: float = 1.0) -> void:
	_freeze_timer = duration
	stop_speaking()

func start_speaking(cps: float = 12.0) -> void:
	_ensure_subsystems()
	lipsync.start_speaking(cps)

func stop_speaking() -> void:
	_ensure_subsystems()
	lipsync.stop_speaking()

func set_mouth(mouth_shape: String) -> void:
	_ensure_subsystems()
	face.set_mouth(mouth_shape)

func set_blush(intensity: float, duration: float = 0.20) -> void:
	_ensure_subsystems()
	face.set_blush(intensity, duration)

func look_at_pos(global_target: Vector2) -> void:
	_ensure_subsystems()
	var dir := (global_target - (global_position + head_offset)).normalized()
	face.look_at_direction(dir)
