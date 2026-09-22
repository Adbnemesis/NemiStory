class_name Mom
extends Node2D

## Illustrated Hand-Drawn Character: MOM
## 100% Godot-native procedural 2D hand-drawn vector character.
## Matches Nemi's master illustration language: organic pen-and-ink linework (#2b2623),
## controlled asymmetry, warm domestic palette, and expressive maternal cartoon acting.

signal pose_changed(new_pose: String)

enum Pose {
	NEUTRAL,
	DEPARTURE,
	ARMS_CROSSED,
	HANDS_ON_HIPS,
	SCOLDING_WAG,
	SILENT_STARE,
	TIRED_SIGH
}

# --- PALETTE CONSTANTS ---
const INK_COLOR: Color = Color("#2b2623")
const SKIN_COLOR: Color = Color("#fbf1e8")
const HAIR_COLOR: Color = Color("#3e2723")
const CARDIGAN_COLOR: Color = Color("#74859a")
const APRON_COLOR: Color = Color("#ede6dc")
const SLACKS_COLOR: Color = Color("#2e323b")
const AURA_COLOR: Color = Color(0.42, 0.16, 0.28, 0.35) # Dark plum judgment aura
const BLUSH_COLOR: Color = Color(0.92, 0.55, 0.52, 0.3)

# --- RIG & POSE STATE ---
var current_pose: Pose = Pose.NEUTRAL
var pose_name: String = "neutral"

var body_pos: Vector2 = Vector2.ZERO
var body_scale: Vector2 = Vector2.ONE
var head_pos: Vector2 = Vector2(0, -95)
var head_rot: float = 0.0

var left_arm_angle: float = 0.0
var right_arm_angle: float = 0.0
var right_arm_wag: float = 0.0

var eye_state: String = "neutral" # "neutral", "glare", "blink", "sigh", "radar"
var left_eyebrow_h: float = 0.0
var right_eyebrow_h: float = 0.0
var mouth_state: String = "rest" # "rest", "scold", "deadpan_dash", "sigh"

var show_judgment_aura: bool = false
var show_radar_arcs: bool = false
var aura_pulse: float = 0.0

var _idle_time: float = 0.0
var _active_tween: Tween

func _ready() -> void:
	set_pose("neutral", 0.0)

func _process(delta: float) -> void:
	_idle_time += delta
	
	if show_judgment_aura or show_radar_arcs:
		aura_pulse = sin(_idle_time * 6.0) * 0.15 + 0.85
		queue_redraw()
		
	if current_pose == Pose.SCOLDING_WAG:
		right_arm_wag = sin(_idle_time * 8.0) * 0.25
		queue_redraw()

func _draw() -> void:
	# 1. Draw Judgment Aura if active
	if show_judgment_aura:
		_draw_judgment_aura()
		
	# 2. Draw Maternal Radar if active
	if show_radar_arcs:
		_draw_radar_arcs()
		
	# 3. Draw Legs & Slacks
	_draw_slacks()
	
	# 4. Draw Torso (Cardigan & Apron)
	_draw_torso()
	
	# 5. Draw Arms according to pose
	_draw_arms()
	
	# 6. Draw Head, Hair & Face
	_draw_head_and_face()

func _draw_judgment_aura() -> void:
	# Wavy radiating heat aura around Mom
	var center = head_pos + Vector2(0, 40)
	for i in range(3):
		var r = 85.0 + i * 22.0 + aura_pulse * 10.0
		var pts: PackedVector2Array = []
		for a in range(16):
			var ang = a * (PI * 2.0 / 15.0)
			var wave = sin(ang * 4.0 + _idle_time * 5.0) * 8.0
			pts.append(center + Vector2(cos(ang), sin(ang)) * (r + wave))
		draw_polyline(pts, Color(AURA_COLOR.r, AURA_COLOR.g, AURA_COLOR.b, AURA_COLOR.a * (0.8 - i * 0.2)), 3.0, true)

func _draw_radar_arcs() -> void:
	# Concentric scanning sonar arcs projecting forward from Mom's gaze
	var eye_pt = head_pos + Vector2(-15, -4)
	for i in range(3):
		var arc_r = 30.0 + i * 25.0 + fmod(_idle_time * 40.0, 40.0)
		var pts: PackedVector2Array = []
		for step in range(9):
			var ang = PI * 0.85 + step * (PI * 0.3 / 8.0)
			pts.append(eye_pt + Vector2(cos(ang), sin(ang)) * arc_r)
		draw_polyline(pts, Color(0.95, 0.25, 0.35, 0.7 - i * 0.2), 2.5)

func _draw_slacks() -> void:
	# Clean tapered slacks
	var left_leg: PackedVector2Array = [
		Vector2(-18, 30), Vector2(-6, 30), Vector2(-10, 110), Vector2(-22, 110)
	]
	var right_leg: PackedVector2Array = [
		Vector2(6, 30), Vector2(18, 30), Vector2(22, 110), Vector2(10, 110)
	]
	draw_colored_polygon(left_leg, SLACKS_COLOR)
	draw_colored_polygon(right_leg, SLACKS_COLOR)
	draw_polyline(left_leg, INK_COLOR, 3.2, true)
	draw_polyline(right_leg, INK_COLOR, 3.2, true)
	
	# Shoes
	draw_colored_polygon([Vector2(-25, 110), Vector2(-7, 110), Vector2(-8, 118), Vector2(-27, 118)], INK_COLOR)
	draw_colored_polygon([Vector2(8, 110), Vector2(26, 110), Vector2(28, 118), Vector2(7, 118)], INK_COLOR)

func _draw_torso() -> void:
	# Domestic cardigan / torso silhouette
	var torso_poly: PackedVector2Array = [
		Vector2(-28, -60), Vector2(28, -60),
		Vector2(32, -10), Vector2(22, 35),
		Vector2(-22, 35), Vector2(-32, -10)
	]
	draw_colored_polygon(torso_poly, CARDIGAN_COLOR)
	draw_polyline(torso_poly, INK_COLOR, 3.5, true)
	
	# Apron overlay in front
	var apron_poly: PackedVector2Array = [
		Vector2(-16, -40), Vector2(16, -40),
		Vector2(18, 30), Vector2(-18, 30)
	]
	draw_colored_polygon(apron_poly, APRON_COLOR)
	draw_polyline(apron_poly, INK_COLOR, 2.5, true)
	# Apron neck loop & pocket
	draw_polyline([Vector2(-12, -40), Vector2(-10, -58), Vector2(10, -58), Vector2(12, -40)], INK_COLOR, 2.2)
	draw_polyline([Vector2(-10, 5), Vector2(10, 5), Vector2(8, 20), Vector2(-8, 20), Vector2(-10, 5)], INK_COLOR, 2.0)

func _draw_arms() -> void:
	match current_pose:
		Pose.ARMS_CROSSED, Pose.SILENT_STARE:
			# Crossed arms over chest
			var arm_fold: PackedVector2Array = [
				Vector2(-26, -45), Vector2(-15, -15), Vector2(18, -15),
				Vector2(26, -45), Vector2(16, -10), Vector2(-18, -10), Vector2(-26, -45)
			]
			draw_colored_polygon(arm_fold, CARDIGAN_COLOR)
			draw_polyline(arm_fold, INK_COLOR, 3.5)
			# Hand tucks
			draw_polyline([Vector2(14, -20), Vector2(24, -22)], INK_COLOR, 3.0)
			draw_polyline([Vector2(-14, -20), Vector2(-24, -22)], INK_COLOR, 3.0)
			
		Pose.HANDS_ON_HIPS:
			# Left arm angled to hip
			draw_polyline([Vector2(-26, -48), Vector2(-42, -18), Vector2(-24, 0)], INK_COLOR, 6.5)
			draw_polyline([Vector2(-26, -48), Vector2(-42, -18), Vector2(-24, 0)], CARDIGAN_COLOR, 4.0)
			# Right arm angled to hip
			draw_polyline([Vector2(26, -48), Vector2(42, -18), Vector2(24, 0)], INK_COLOR, 6.5)
			draw_polyline([Vector2(26, -48), Vector2(42, -18), Vector2(24, 0)], CARDIGAN_COLOR, 4.0)
			
		Pose.SCOLDING_WAG:
			# Left hand on hip
			draw_polyline([Vector2(-26, -48), Vector2(-40, -18), Vector2(-22, 5)], INK_COLOR, 6.5)
			draw_polyline([Vector2(-26, -48), Vector2(-40, -18), Vector2(-22, 5)], CARDIGAN_COLOR, 4.0)
			# Right arm raised, pointing index finger wagging
			var elbow = Vector2(35, -55)
			var hand = Vector2(42 + right_arm_wag * 15.0, -85)
			draw_polyline([Vector2(26, -48), elbow, hand], INK_COLOR, 6.5)
			draw_polyline([Vector2(26, -48), elbow, hand], CARDIGAN_COLOR, 4.0)
			# Pointing finger
			draw_polyline([hand, hand + Vector2(2, -18)], INK_COLOR, 3.5)
			
		Pose.DEPARTURE:
			# Left arm relaxed down
			draw_polyline([Vector2(-26, -48), Vector2(-32, -10), Vector2(-30, 20)], INK_COLOR, 5.0)
			# Right arm holding car keys
			draw_polyline([Vector2(26, -48), Vector2(38, -25), Vector2(45, -28)], INK_COLOR, 5.0)
			# Car keys doodle in hand
			draw_circle(Vector2(48, -28), 5.0, Color.TRANSPARENT)
			draw_arc(Vector2(48, -28), 4.0, 0, PI * 2, 8, INK_COLOR, 2.0)
			draw_line(Vector2(48, -24), Vector2(54, -18), INK_COLOR, 2.5)
			
		_: # NEUTRAL / TIRED_SIGH
			# Relaxed arms at sides
			draw_polyline([Vector2(-26, -48), Vector2(-32, -10), Vector2(-28, 20)], INK_COLOR, 6.0)
			draw_polyline([Vector2(-26, -48), Vector2(-32, -10), Vector2(-28, 20)], CARDIGAN_COLOR, 3.8)
			draw_polyline([Vector2(26, -48), Vector2(32, -10), Vector2(28, 20)], INK_COLOR, 6.0)
			draw_polyline([Vector2(26, -48), Vector2(32, -10), Vector2(28, 20)], CARDIGAN_COLOR, 3.8)

func _draw_head_and_face() -> void:
	var h_center = head_pos
	
	# Neck
	draw_colored_polygon([
		h_center + Vector2(-8, 20), h_center + Vector2(8, 20),
		h_center + Vector2(10, 38), h_center + Vector2(-10, 38)
	], SKIN_COLOR)
	draw_line(h_center + Vector2(-8, 20), h_center + Vector2(-10, 38), INK_COLOR, 2.5)
	draw_line(h_center + Vector2(8, 20), h_center + Vector2(10, 38), INK_COLOR, 2.5)
	
	# Back Hair / Bun
	draw_circle(h_center + Vector2(0, -32), 22.0, HAIR_COLOR)
	draw_arc(h_center + Vector2(0, -32), 22.0, 0, PI * 2, 16, INK_COLOR, 3.0)
	
	# Head shape
	var head_poly: PackedVector2Array = [
		h_center + Vector2(-22, -15),
		h_center + Vector2(22, -15),
		h_center + Vector2(20, 10),
		h_center + Vector2(12, 26),
		h_center + Vector2(-12, 26),
		h_center + Vector2(-20, 10)
	]
	draw_colored_polygon(head_poly, SKIN_COLOR)
	draw_polyline(head_poly, INK_COLOR, 3.2, true)
	
	# Front Hair & stylized bangs
	var bangs: PackedVector2Array = [
		h_center + Vector2(-25, -12),
		h_center + Vector2(-14, -6),
		h_center + Vector2(-5, -16),
		h_center + Vector2(6, -8),
		h_center + Vector2(18, -14),
		h_center + Vector2(25, -10),
		h_center + Vector2(22, -28),
		h_center + Vector2(-22, -28)
	]
	draw_colored_polygon(bangs, HAIR_COLOR)
	draw_polyline(bangs, INK_COLOR, 3.2, true)
	
	# Eyebrows
	var l_brow_y = h_center.y - 12 + left_eyebrow_h
	var r_brow_y = h_center.y - 12 + right_eyebrow_h
	draw_line(Vector2(h_center.x - 18, l_brow_y), Vector2(h_center.x - 6, l_brow_y - 2), INK_COLOR, 3.0)
	draw_line(Vector2(h_center.x + 6, r_brow_y - 2), Vector2(h_center.x + 18, r_brow_y), INK_COLOR, 3.0)
	
	# Eyes
	match eye_state:
		"glare", "radar":
			# Arched sharp glare
			draw_line(Vector2(h_center.x - 17, h_center.y - 5), Vector2(h_center.x - 6, h_center.y - 4), INK_COLOR, 3.5)
			draw_circle(Vector2(h_center.x - 11, h_center.y - 1), 3.2, INK_COLOR)
			draw_circle(Vector2(h_center.x - 12, h_center.y - 2), 1.0, Color.WHITE) # Catchlight
			
			draw_line(Vector2(h_center.x + 6, h_center.y - 4), Vector2(h_center.x + 17, h_center.y - 5), INK_COLOR, 3.5)
			draw_circle(Vector2(h_center.x + 11, h_center.y - 1), 3.2, INK_COLOR)
			draw_circle(Vector2(h_center.x + 10, h_center.y - 2), 1.0, Color.WHITE)
			
		"sigh":
			# Soft downward closed eyes
			draw_arc(Vector2(h_center.x - 11, h_center.y - 2), 5.0, PI * 0.2, PI * 0.8, 8, INK_COLOR, 2.5)
			draw_arc(Vector2(h_center.x + 11, h_center.y - 2), 5.0, PI * 0.2, PI * 0.8, 8, INK_COLOR, 2.5)
			
		_: # "neutral"
			draw_circle(Vector2(h_center.x - 11, h_center.y - 3), 4.0, INK_COLOR)
			draw_circle(Vector2(h_center.x - 12, h_center.y - 4), 1.2, Color.WHITE)
			draw_circle(Vector2(h_center.x + 11, h_center.y - 3), 4.0, INK_COLOR)
			draw_circle(Vector2(h_center.x + 10, h_center.y - 4), 1.2, Color.WHITE)
			
	# Nose
	draw_line(h_center + Vector2(0, 1), h_center + Vector2(2, 6), INK_COLOR, 2.0)
	
	# Mouth
	match mouth_state:
		"scold":
			# O-shape speaking scold mouth
			draw_arc(h_center + Vector2(0, 16), 4.5, 0, PI * 2, 10, INK_COLOR, 2.5)
		"deadpan_dash":
			# Signature flat horizontal dash mouth
			draw_line(h_center + Vector2(-8, 16), h_center + Vector2(8, 16), INK_COLOR, 3.0)
		"sigh":
			# Soft downturned sigh mouth
			draw_arc(h_center + Vector2(0, 19), 6.0, PI * 1.1, PI * 1.9, 8, INK_COLOR, 2.2)
		_: # "rest"
			draw_line(h_center + Vector2(-5, 16), h_center + Vector2(5, 16), INK_COLOR, 2.2)

# --- DIRECTORIAL INTERFACE ---

func set_pose(p_name: String, transition_duration: float = 0.2) -> void:
	pose_name = p_name.to_lower()
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
		
	match pose_name:
		"departure":
			current_pose = Pose.DEPARTURE
			eye_state = "neutral"
			left_eyebrow_h = 0.0
			right_eyebrow_h = 0.0
			mouth_state = "rest"
			show_judgment_aura = false
			show_radar_arcs = false
			
		"arms_crossed":
			current_pose = Pose.ARMS_CROSSED
			eye_state = "glare"
			left_eyebrow_h = -4.0 # Raised judgment brow
			right_eyebrow_h = 2.0
			mouth_state = "deadpan_dash"
			show_judgment_aura = true
			show_radar_arcs = false
			
		"hands_on_hips":
			current_pose = Pose.HANDS_ON_HIPS
			eye_state = "glare"
			left_eyebrow_h = -2.0
			right_eyebrow_h = -2.0
			mouth_state = "rest"
			show_judgment_aura = false
			show_radar_arcs = false
			
		"scolding_wag":
			current_pose = Pose.SCOLDING_WAG
			eye_state = "glare"
			left_eyebrow_h = -3.0
			right_eyebrow_h = 1.0
			mouth_state = "scold"
			show_judgment_aura = false
			show_radar_arcs = false
			
		"silent_stare":
			current_pose = Pose.SILENT_STARE
			eye_state = "radar"
			left_eyebrow_h = -6.0 # Extreme one-eyebrow raise
			right_eyebrow_h = 3.0
			mouth_state = "deadpan_dash"
			show_judgment_aura = true
			show_radar_arcs = true
			
		"tired_sigh":
			current_pose = Pose.TIRED_SIGH
			eye_state = "sigh"
			left_eyebrow_h = 3.0
			right_eyebrow_h = 3.0
			mouth_state = "sigh"
			show_judgment_aura = false
			show_radar_arcs = false
			
		_: # "neutral"
			current_pose = Pose.NEUTRAL
			eye_state = "neutral"
			left_eyebrow_h = 0.0
			right_eyebrow_h = 0.0
			mouth_state = "rest"
			show_judgment_aura = false
			show_radar_arcs = false
			
	if transition_duration > 0.0:
		_active_tween = create_tween()
		_active_tween.tween_property(self, "scale", Vector2(1.03, 0.98), transition_duration * 0.4)
		_active_tween.tween_property(self, "scale", Vector2.ONE, transition_duration * 0.6)
		
	queue_redraw()
	pose_changed.emit(pose_name)

func activate_radar(active: bool = true) -> void:
	show_radar_arcs = active
	queue_redraw()

func activate_aura(active: bool = true) -> void:
	show_judgment_aura = active
	queue_redraw()
