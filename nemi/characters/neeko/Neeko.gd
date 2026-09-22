class_name Neeko
extends Node2D

## Reusable Illustrated Cat Character: NEEKO
## 100% Godot-native procedural 2D hand-drawn vector character.
## Matches Nemi's master illustration language: organic pen-and-ink linework (#2b2623),
## controlled asymmetry, warm cream & ginger palette, and expressive cartoon acting.

signal state_changed(new_state: String)

enum State {
	NEUTRAL,
	SCARED,
	CURIOUS,
	DRINKING,
	HAPPY,
	HAPPY_LOAF,
	PROUD_BOSS,
	PLAYFUL,
	CONFUSED,
	SLEEPY
}

# --- PALETTE CONSTANTS ---
const INK_COLOR: Color = Color("#2b2623")
const FUR_BASE: Color = Color("#fbf8f3")       # Warm cream white
const FUR_PATCH: Color = Color("#c85a3a")      # Ginger / auburn patch
const NOSE_COLOR: Color = Color("#e8928a")     # Soft coral pink
const INNER_EAR: Color = Color("#f5cdc6")      # Soft pale pink
const EYE_COLOR: Color = Color("#2b2623")      # Dark charcoal with highlights
const EYE_GREEN: Color = Color("#558268")      # Sage emerald iris
const SHADOW_COLOR: Color = Color(0.17, 0.15, 0.14, 0.12)

# --- RIG & POSE STATE ---
var current_state: State = State.NEUTRAL
var state_name: String = "neutral"

# Head and body transforms (procedurally driven)
var body_pos: Vector2 = Vector2.ZERO
var body_scale: Vector2 = Vector2.ONE
var head_pos: Vector2 = Vector2(0, -18)
var head_rot: float = 0.0

var left_ear_rot: float = 0.0
var right_ear_rot: float = 0.0

var tail_root: Vector2 = Vector2(-22, 4)
var tail_angle: float = 0.2
var tail_curl: float = 0.3
var tail_sway: float = 0.0

var eye_state: String = "open"      # "open", "wide", "blink", "happy", "sleepy", "down"
var gaze_offset: Vector2 = Vector2.ZERO

var is_tucked_loaf: bool = false
var is_shivering: bool = false
var is_drinking: bool = false
var is_walking: bool = false

var _idle_time: float = 0.0
var _shiver_timer: float = 0.0
var _walk_phase: float = 0.0
var _active_tween: Tween

func _ready() -> void:
	set_state("neutral")

func _process(delta: float) -> void:
	_idle_time += delta
	
	# Procedural natural micro-behaviors based on state
	match current_state:
		State.NEUTRAL:
			tail_sway = sin(_idle_time * 2.2) * 0.15
			body_scale.y = 1.0 + sin(_idle_time * 3.0) * 0.02
		State.SCARED:
			# High-frequency tremble
			if is_shivering:
				_shiver_timer += delta * 45.0
				head_pos.x = sin(_shiver_timer) * 1.2
				body_pos.y = cos(_shiver_timer * 0.8) * 0.8
			tail_sway = sin(_idle_time * 8.0) * 0.05
		State.CURIOUS:
			tail_sway = sin(_idle_time * 3.0) * 0.22
			body_scale.y = 1.0 + sin(_idle_time * 2.5) * 0.025
		State.HAPPY, State.HAPPY_LOAF:
			# Rhythmic slow purr breathing
			var purr_pulse: float = sin(_idle_time * 4.5)
			body_scale.y = 1.0 + purr_pulse * 0.04
			body_scale.x = 1.0 - purr_pulse * 0.02
			tail_sway = sin(_idle_time * 1.5) * 0.08
		State.PROUD_BOSS:
			body_scale.y = 1.05 + sin(_idle_time * 2.0) * 0.015
			tail_sway = sin(_idle_time * 2.8) * 0.25
		State.DRINKING:
			# Handled in drinking tween
			pass
		State.PLAYFUL:
			tail_sway = sin(_idle_time * 7.0) * 0.4
			body_scale.x = 1.0 + sin(_idle_time * 6.0) * 0.03
	
	queue_redraw()

# -----------------------------------------------------------------------------
# HIGH LEVEL DIRECTORIAL API
# -----------------------------------------------------------------------------

func set_state(p_state_name: String, transition: float = 0.25) -> void:
	state_name = p_state_name.to_lower()
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween().set_parallel(true)
	
	is_shivering = false
	is_drinking = false
	is_tucked_loaf = false
	
	match state_name:
		"neutral":
			current_state = State.NEUTRAL
			eye_state = "open"
			_tween_val("head_rot", 0.0, transition)
			_tween_val("head_pos", Vector2(0, -18), transition)
			_tween_val("left_ear_rot", 0.0, transition)
			_tween_val("right_ear_rot", 0.0, transition)
			_tween_val("tail_angle", 0.2, transition)
			_tween_val("tail_curl", 0.3, transition)
			
		"scared":
			current_state = State.SCARED
			eye_state = "wide"
			is_shivering = true
			# Hunch down low, ears flat back, tail tucked tightly
			_tween_val("head_pos", Vector2(0, -10), transition)
			_tween_val("head_rot", 0.05, transition)
			_tween_val("left_ear_rot", deg_to_rad(-45.0), transition)
			_tween_val("right_ear_rot", deg_to_rad(45.0), transition)
			_tween_val("tail_angle", deg_to_rad(-60.0), transition)
			_tween_val("tail_curl", -0.4, transition)
			
		"curious":
			current_state = State.CURIOUS
			eye_state = "open"
			# Head cocked at inquisitive angle, one ear perked, tail upright with hook
			_tween_val("head_pos", Vector2(2, -20), transition)
			_tween_val("head_rot", deg_to_rad(14.0), transition)
			_tween_val("left_ear_rot", deg_to_rad(8.0), transition)
			_tween_val("right_ear_rot", deg_to_rad(-18.0), transition)
			_tween_val("tail_angle", deg_to_rad(55.0), transition)
			_tween_val("tail_curl", 0.6, transition)
			
		"drinking":
			current_state = State.DRINKING
			eye_state = "down"
			is_drinking = true
			# Head lowered toward bowl, gentle tail sway
			_tween_val("head_pos", Vector2(16, -6), transition)
			_tween_val("head_rot", deg_to_rad(28.0), transition)
			_tween_val("left_ear_rot", deg_to_rad(10.0), transition)
			_tween_val("right_ear_rot", deg_to_rad(5.0), transition)
			_tween_val("tail_angle", deg_to_rad(15.0), transition)
			_start_drinking_bob()
			
		"happy", "happy_loaf", "loaf":
			current_state = State.HAPPY_LOAF
			eye_state = "happy"
			is_tucked_loaf = true
			# Settled down into loaf, ears relaxed outward, tail curled against flank
			_tween_val("head_pos", Vector2(0, -12), transition)
			_tween_val("head_rot", 0.0, transition)
			_tween_val("left_ear_rot", deg_to_rad(-10.0), transition)
			_tween_val("right_ear_rot", deg_to_rad(10.0), transition)
			_tween_val("tail_angle", deg_to_rad(-40.0), transition)
			_tween_val("tail_curl", 0.75, transition)
			
		"proud_boss", "boss":
			current_state = State.PROUD_BOSS
			eye_state = "open"
			# Upright tall sitting, chin elevated, upright perked tail
			_tween_val("head_pos", Vector2(0, -24), transition)
			_tween_val("head_rot", deg_to_rad(-6.0), transition)
			_tween_val("left_ear_rot", deg_to_rad(4.0), transition)
			_tween_val("right_ear_rot", deg_to_rad(-4.0), transition)
			_tween_val("tail_angle", deg_to_rad(75.0), transition)
			_tween_val("tail_curl", 0.45, transition)
			
		"confused":
			current_state = State.CONFUSED
			eye_state = "open"
			_tween_val("head_rot", deg_to_rad(-16.0), transition)
			_tween_val("left_ear_rot", deg_to_rad(25.0), transition)
			_tween_val("right_ear_rot", deg_to_rad(-8.0), transition)
			_tween_val("tail_angle", deg_to_rad(20.0), transition)
			
		"sleepy":
			current_state = State.SLEEPY
			eye_state = "sleepy"
			is_tucked_loaf = true
			_tween_val("head_pos", Vector2(0, -8), transition)
			_tween_val("left_ear_rot", deg_to_rad(-20.0), transition)
			_tween_val("right_ear_rot", deg_to_rad(20.0), transition)
			_tween_val("tail_curl", 0.85, transition)
			
		_:
			current_state = State.NEUTRAL
			eye_state = "open"
			
	state_changed.emit(state_name)

func _tween_val(prop: String, val: Variant, dur: float) -> void:
	if _active_tween:
		_active_tween.tween_property(self, prop, val, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func blink(speed: float = 0.12) -> void:
	var prev_eye := eye_state
	eye_state = "blink"
	queue_redraw()
	await get_tree().create_timer(speed).timeout
	eye_state = prev_eye
	queue_redraw()

func look_at_target(direction: String) -> void:
	match direction.to_lower():
		"left": gaze_offset = Vector2(-3, 0)
		"right": gaze_offset = Vector2(3, 0)
		"up": gaze_offset = Vector2(0, -2.5)
		"down": gaze_offset = Vector2(0, 2.5)
		"nemi": gaze_offset = Vector2(-3, -1.5)
		_: gaze_offset = Vector2.ZERO
	queue_redraw()

func tilt_head(deg: float, dur: float = 0.25) -> void:
	var tw := create_tween()
	tw.tween_property(self, "head_rot", deg_to_rad(deg), dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func trot_to(target_pos: Vector2, duration: float) -> void:
	is_walking = true
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "position", target_pos, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	# Slight bounce while trotting
	var bounce_tw := create_tween()
	var steps: int = int(duration / 0.18)
	for i in range(steps):
		bounce_tw.tween_property(self, "body_pos:y", -3.0, 0.09).set_trans(Tween.TRANS_QUAD)
		bounce_tw.tween_property(self, "body_pos:y", 0.0, 0.09).set_trans(Tween.TRANS_QUAD)
	await tw.finished
	is_walking = false
	body_pos = Vector2.ZERO

func curl_into_loaf(duration: float = 0.4) -> void:
	set_state("happy_loaf", duration)

func _start_drinking_bob() -> void:
	var bob_tw := create_tween().set_loops(8)
	bob_tw.tween_property(self, "head_pos:y", -3.0, 0.12).set_trans(Tween.TRANS_QUAD)
	bob_tw.tween_property(self, "head_pos:y", -6.0, 0.12).set_trans(Tween.TRANS_QUAD)

# -----------------------------------------------------------------------------
# VECTOR DRAWING (HAND-DRAWN INK AESTHETIC)
# -----------------------------------------------------------------------------

func _draw() -> void:
	# 1. Ground contact shadow (soft organic ellipse)
	draw_circle(Vector2(0, 10), 22.0, SHADOW_COLOR)
	
	# 2. Tail (drawn behind body)
	_draw_tail()
	
	# 3. Cat Body
	_draw_body()
	
	# 4. Legs / Paws (if not in loaf)
	if not is_tucked_loaf:
		_draw_paws()
		
	# 5. Head & Ears
	_draw_head()

func _draw_tail() -> void:
	var points := PackedVector2Array()
	var current_ang: float = tail_angle + tail_sway
	var seg_length: float = 7.0
	var seg_count: int = 6
	var curr_pt: Vector2 = tail_root + body_pos
	
	points.append(curr_pt)
	for i in range(seg_count):
		current_ang += tail_curl * 0.35
		curr_pt += Vector2(-cos(current_ang), -sin(current_ang)) * seg_length
		points.append(curr_pt)
		
	# Tail ink stroke (thicker at base, tapered tip)
	draw_polyline(points, FUR_BASE, 6.0, true)
	# Auburn ginger tip on tail
	if points.size() >= 3:
		var tip_pts := PackedVector2Array([points[-3], points[-2], points[-1]])
		draw_polyline(tip_pts, FUR_PATCH, 5.0, true)
	draw_polyline(points, INK_COLOR, 2.2, true)

func _draw_body() -> void:
	# Body is an organic hand-drawn bean/oval
	var b_pts := PackedVector2Array([
		Vector2(-18, 8),
		Vector2(-22, 0),
		Vector2(-18, -12),
		Vector2(-6, -18),
		Vector2(10, -16),
		Vector2(18, -8),
		Vector2(20, 2),
		Vector2(14, 8),
		Vector2(0, 10)
	])
	
	# Apply body scale & pos
	var xformed := PackedVector2Array()
	for p in b_pts:
		xformed.append((p * body_scale) + body_pos)
		
	draw_colored_polygon(xformed, FUR_BASE)
	
	# Large warm ginger patch across upper back
	var patch_pts := PackedVector2Array([
		xformed[2],
		xformed[3],
		xformed[4],
		(Vector2(2, -4) * body_scale) + body_pos,
		(Vector2(-10, -2) * body_scale) + body_pos
	])
	draw_colored_polygon(patch_pts, FUR_PATCH)
	
	# Organic closed outline
	var outline := xformed.duplicate()
	outline.append(xformed[0])
	draw_polyline(outline, INK_COLOR, 2.4, true)

func _draw_paws() -> void:
	# Front left & right paws, rear paw
	var paw_f1 := Vector2(8, 9) + body_pos
	var paw_f2 := Vector2(14, 9) + body_pos
	var paw_back := Vector2(-16, 9) + body_pos
	
	for p in [paw_back, paw_f1, paw_f2]:
		draw_circle(p, 4.0, FUR_BASE)
		draw_arc(p, 4.0, 0, PI, 8, INK_COLOR, 2.0)
		# Tiny paw toes
		draw_line(p + Vector2(-1.5, 0), p + Vector2(-1.5, 3.5), INK_COLOR, 1.2)
		draw_line(p + Vector2(1.5, 0), p + Vector2(1.5, 3.5), INK_COLOR, 1.2)

func _draw_head() -> void:
	var h_center := head_pos + body_pos
	
	# 1. Ears (drawn behind head contour)
	_draw_ear(h_center, -1, left_ear_rot)
	_draw_ear(h_center, 1, right_ear_rot)
	
	# 2. Head contour (cute rounded cat face with cheek tufts)
	var head_pts := PackedVector2Array([
		Vector2(-14, 4),
		Vector2(-18, 0),     # Left cheek tuft
		Vector2(-14, -8),
		Vector2(-8, -14),    # Top left crown
		Vector2(0, -15),     # Top crown
		Vector2(8, -14),     # Top right crown
		Vector2(14, -8),
		Vector2(18, 0),      # Right cheek tuft
		Vector2(14, 4),
		Vector2(6, 9),       # Chin right
		Vector2(0, 10),      # Chin center
		Vector2(-6, 9)       # Chin left
	])
	
	var rot_head := PackedVector2Array()
	for p in head_pts:
		rot_head.append(h_center + p.rotated(head_rot))
		
	draw_colored_polygon(rot_head, FUR_BASE)
	
	# Ginger patch over left eye / ear area
	var head_patch := PackedVector2Array([
		rot_head[2],
		rot_head[3],
		rot_head[4],
		h_center + Vector2(-2, -4).rotated(head_rot),
		h_center + Vector2(-10, -2).rotated(head_rot)
	])
	draw_colored_polygon(head_patch, FUR_PATCH)
	
	# Head outline
	var h_outline := rot_head.duplicate()
	h_outline.append(rot_head[0])
	draw_polyline(h_outline, INK_COLOR, 2.4, true)
	
	# 3. Eyes
	_draw_eyes(h_center)
	
	# 4. Nose & Mouth
	var nose_pt := h_center + Vector2(0, 2).rotated(head_rot)
	var nose_tri := PackedVector2Array([
		nose_pt + Vector2(-2.5, -1.5).rotated(head_rot),
		nose_pt + Vector2(2.5, -1.5).rotated(head_rot),
		nose_pt + Vector2(0, 1.5).rotated(head_rot)
	])
	draw_colored_polygon(nose_tri, NOSE_COLOR)
	draw_polyline(nose_tri, INK_COLOR, 1.2, true)
	
	# Cat mouth (classic :3 curve)
	var mouth_root := nose_pt + Vector2(0, 1.5).rotated(head_rot)
	var m_left := PackedVector2Array([
		mouth_root,
		mouth_root + Vector2(-2.5, 3.0).rotated(head_rot),
		mouth_root + Vector2(-5.0, 1.5).rotated(head_rot)
	])
	var m_right := PackedVector2Array([
		mouth_root,
		mouth_root + Vector2(2.5, 3.0).rotated(head_rot),
		mouth_root + Vector2(5.0, 1.5).rotated(head_rot)
	])
	draw_polyline(m_left, INK_COLOR, 1.8, true)
	draw_polyline(m_right, INK_COLOR, 1.8, true)
	
	# 5. Whiskers (3 tapered lines on each cheek)
	_draw_whiskers(h_center)

func _draw_ear(h_center: Vector2, side: int, rot_offset: float) -> void:
	var base_x := 7.0 * side
	var ear_rot_total := head_rot + rot_offset
	var ear_root := h_center + Vector2(base_x, -13).rotated(head_rot)
	
	var ear_pts := PackedVector2Array([
		ear_root + Vector2(-4.5 * side, 2).rotated(ear_rot_total),
		ear_root + Vector2(1.5 * side, -14).rotated(ear_rot_total),  # Ear tip
		ear_root + Vector2(6.5 * side, 2).rotated(ear_rot_total)
	])
	
	draw_colored_polygon(ear_pts, FUR_PATCH if side == -1 else FUR_BASE)
	
	# Inner ear pink triangle
	var inner := PackedVector2Array([
		ear_root + Vector2(-2.5 * side, 1).rotated(ear_rot_total),
		ear_root + Vector2(1.5 * side, -10).rotated(ear_rot_total),
		ear_root + Vector2(4.5 * side, 1).rotated(ear_rot_total)
	])
	draw_colored_polygon(inner, INNER_EAR)
	
	# Outline
	draw_polyline(ear_pts, INK_COLOR, 2.2, false)

func _draw_eyes(h_center: Vector2) -> void:
	var eye_l_pos := h_center + Vector2(-6, -3).rotated(head_rot) + gaze_offset
	var eye_r_pos := h_center + Vector2(6, -3).rotated(head_rot) + gaze_offset
	
	match eye_state:
		"open":
			for pos in [eye_l_pos, eye_r_pos]:
				# Dark charcoal pupil with green iris rim and white sparkle highlight
				draw_circle(pos, 3.8, EYE_GREEN)
				draw_circle(pos, 2.8, EYE_COLOR)
				# Catchlight sparkle
				draw_circle(pos + Vector2(-1.2, -1.2), 1.0, Color.WHITE)
		"wide":
			# Scared/shocked wide round eyes
			for pos in [eye_l_pos, eye_r_pos]:
				draw_circle(pos, 5.0, Color.WHITE)
				draw_circle(pos, 5.0, INK_COLOR) # outline circle
				draw_circle(pos, 2.0, EYE_COLOR) # tiny constricted pupil
		"happy":
			# Curved crescents ^ ^
			for pos in [eye_l_pos, eye_r_pos]:
				var arc_pts := PackedVector2Array([
					pos + Vector2(-4, 1),
					pos + Vector2(0, -3),
					pos + Vector2(4, 1)
				])
				draw_polyline(arc_pts, INK_COLOR, 2.4, true)
		"sleepy", "down":
			for pos in [eye_l_pos, eye_r_pos]:
				var line_pts := PackedVector2Array([
					pos + Vector2(-4, 0),
					pos + Vector2(4, 0)
				])
				draw_polyline(line_pts, INK_COLOR, 2.2, true)
		"blink":
			for pos in [eye_l_pos, eye_r_pos]:
				draw_line(pos + Vector2(-3.5, 0), pos + Vector2(3.5, 0), INK_COLOR, 2.0)

func _draw_whiskers(h_center: Vector2) -> void:
	var left_root := h_center + Vector2(-8, 3).rotated(head_rot)
	var right_root := h_center + Vector2(8, 3).rotated(head_rot)
	
	# Left whiskers
	draw_line(left_root, left_root + Vector2(-14, -4).rotated(head_rot), INK_COLOR, 1.2)
	draw_line(left_root, left_root + Vector2(-15, 1).rotated(head_rot), INK_COLOR, 1.2)
	draw_line(left_root, left_root + Vector2(-13, 6).rotated(head_rot), INK_COLOR, 1.2)
	
	# Right whiskers
	draw_line(right_root, right_root + Vector2(14, -4).rotated(head_rot), INK_COLOR, 1.2)
	draw_line(right_root, right_root + Vector2(15, 1).rotated(head_rot), INK_COLOR, 1.2)
	draw_line(right_root, right_root + Vector2(13, 6).rotated(head_rot), INK_COLOR, 1.2)
