class_name CosmoDoodleDirector
extends Node2D

## Hand-Drawn Doodle & Ability VFX Director for COSMO (Brawl Stars)
## Implements the YouTube storytime physical sketching aesthetic:
## - Doodles look physically drawn in dark ink: DRAW -> HOLD -> ERASE
## - Organic hand-drawn arrows, focus circles, orbit ellipses, gravity vectors, magnetic dipole lines
## - Ability-inspired storytelling cues:
##   * Orbit Main Attack: 3 expanding orbital doodle arcs
##   * Gravitational Pull Super: Magnetic homing vectors curving toward target
##   * Planetary Pushback Gadget: Radial ink shockwave arcs
##   * Telescope Trap Gadget: Scientific coordinate scanning grid
## - Pure dark ink default with selective color accents

const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var ink_color: Color = Color("#201c24")
var accent_color: Color = Color("#f07820")
var cyan_color: Color = Color("#3ca4f0")

var active_doodles: Array[Dictionary] = []

func _process(delta: float) -> void:
	var needs_redraw := false
	var finished_indices: Array[int] = []
	
	for i in range(active_doodles.size()):
		var d: Dictionary = active_doodles[i]
		d["timer"] += delta
		var t: float = d["timer"]
		
		# Phase 1: Draw (0.0 to draw_duration)
		if t < d["draw_dur"]:
			d["progress"] = clampf(t / d["draw_dur"], 0.0, 1.0)
			needs_redraw = true
		# Phase 2: Hold (draw_duration to draw_duration + hold_duration)
		elif t < d["draw_dur"] + d["hold_dur"]:
			d["progress"] = 1.0
			d["alpha"] = 1.0
		# Phase 3: Erase / Fade
		elif t < d["draw_dur"] + d["hold_dur"] + d["erase_dur"]:
			var erase_t: float = (t - (d["draw_dur"] + d["hold_dur"])) / d["erase_dur"]
			d["alpha"] = 1.0 - erase_t
			needs_redraw = true
		else:
			finished_indices.append(i)
			needs_redraw = true
	
	# Remove finished in reverse
	for i in range(finished_indices.size() - 1, -1, -1):
		active_doodles.remove_at(finished_indices[i])
	
	if needs_redraw:
		queue_redraw()

func clear_all() -> void:
	active_doodles.clear()
	queue_redraw()

# -------------------------------------------------------------------------
# DOODLE SPAWNERS
# -------------------------------------------------------------------------

func spawn_arrow(from: Vector2, to: Vector2, draw_d: float = 0.25, hold_d: float = 1.2, erase_d: float = 0.3) -> void:
	active_doodles.append({
		"type": "arrow",
		"from": from,
		"to": to,
		"timer": 0.0,
		"draw_dur": draw_d,
		"hold_dur": hold_d,
		"erase_dur": erase_d,
		"progress": 0.0,
		"alpha": 1.0
	})
	queue_redraw()

func spawn_circle(center: Vector2, radius: float = 35.0, draw_d: float = 0.3, hold_d: float = 1.2, erase_d: float = 0.3) -> void:
	active_doodles.append({
		"type": "circle",
		"center": center,
		"radius": radius,
		"timer": 0.0,
		"draw_dur": draw_d,
		"hold_dur": hold_d,
		"erase_dur": erase_d,
		"progress": 0.0,
		"alpha": 1.0
	})
	queue_redraw()

func spawn_orbit_diagram(center: Vector2, radius_x: float = 80.0, radius_y: float = 34.0, draw_d: float = 0.35, hold_d: float = 1.8, erase_d: float = 0.3) -> void:
	active_doodles.append({
		"type": "orbit_diagram",
		"center": center,
		"rx": radius_x,
		"ry": radius_y,
		"timer": 0.0,
		"draw_dur": draw_d,
		"hold_dur": hold_d,
		"erase_dur": erase_d,
		"progress": 0.0,
		"alpha": 1.0
	})
	queue_redraw()

func spawn_gravity_concept(center: Vector2, draw_d: float = 0.35, hold_d: float = 1.8, erase_d: float = 0.3) -> void:
	active_doodles.append({
		"type": "gravity_concept",
		"center": center,
		"timer": 0.0,
		"draw_dur": draw_d,
		"hold_dur": hold_d,
		"erase_dur": erase_d,
		"progress": 0.0,
		"alpha": 1.0
	})
	queue_redraw()

func spawn_magnetic_pull(from: Vector2, target: Vector2, draw_d: float = 0.35, hold_d: float = 1.8, erase_d: float = 0.3) -> void:
	active_doodles.append({
		"type": "magnetic_pull",
		"from": from,
		"target": target,
		"timer": 0.0,
		"draw_dur": draw_d,
		"hold_dur": hold_d,
		"erase_dur": erase_d,
		"progress": 0.0,
		"alpha": 1.0
	})
	queue_redraw()

func spawn_annotation(pos: Vector2, text: String, draw_d: float = 0.25, hold_d: float = 1.5, erase_d: float = 0.3) -> void:
	active_doodles.append({
		"type": "annotation",
		"pos": pos,
		"text": text,
		"timer": 0.0,
		"draw_dur": draw_d,
		"hold_dur": hold_d,
		"erase_dur": erase_d,
		"progress": 0.0,
		"alpha": 1.0
	})
	queue_redraw()

# -------------------------------------------------------------------------
# DRAW ROUTINES
# -------------------------------------------------------------------------

func _draw() -> void:
	for d in active_doodles:
		var col := Color(ink_color.r, ink_color.g, ink_color.b, d["alpha"])
		var p: float = d["progress"]
		
		match d["type"]:
			"arrow":
				_render_arrow(d["from"], d["to"], p, col)
			"circle":
				_render_circle(d["center"], d["radius"], p, col)
			"orbit_diagram":
				_render_orbit_diagram(d["center"], d["rx"], d["ry"], p, col)
			"gravity_concept":
				_render_gravity_concept(d["center"], p, col)
			"magnetic_pull":
				_render_magnetic_pull(d["from"], d["target"], p, col)
			"annotation":
				_render_annotation(d["pos"], d["text"], p, col)

func _render_arrow(from: Vector2, to: Vector2, progress: float, col: Color) -> void:
	var current_to := from.lerp(to, progress)
	draw_line(from, current_to, col, 2.8)
	
	if progress >= 0.85:
		var head_p := (progress - 0.85) / 0.15
		var dir := (to - from).normalized()
		var norm := Vector2(-dir.y, dir.x)
		var left_bar := to - dir * (14.0 * head_p) + norm * (7.0 * head_p)
		var right_bar := to - dir * (14.0 * head_p) - norm * (7.0 * head_p)
		draw_line(to, left_bar, col, 2.4)
		draw_line(to, right_bar, col, 2.4)

func _render_circle(center: Vector2, radius: float, progress: float, col: Color) -> void:
	var end_angle := progress * (TAU + 0.35) # Overshoot for hand-drawn look
	draw_arc(center, radius, -0.4, -0.4 + end_angle, 28, col, 2.5, false)

func _render_orbit_diagram(center: Vector2, rx: float, ry: float, progress: float, col: Color) -> void:
	# Hand-drawn ellipse with small satellite dots and radius label
	var end_angle := progress * TAU
	draw_set_transform(center, -0.2, Vector2(1.0, ry / rx))
	draw_arc(Vector2.ZERO, rx, 0, end_angle, 32, col, 2.0, false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# Center star doodle
	if progress >= 0.3:
		draw_circle(center, 4.0, col)
		draw_line(center + Vector2(-8, 0), center + Vector2(8, 0), col, 1.4)
		draw_line(center + Vector2(0, -8), center + Vector2(0, 8), col, 1.4)
	
	# Orbiting body dot
	if progress >= 0.7:
		var sat_pos := center + Vector2(cos(end_angle - 0.2) * rx, sin(end_angle - 0.2) * ry)
		draw_circle(sat_pos, 5.0, col)

func _render_gravity_concept(center: Vector2, progress: float, col: Color) -> void:
	# Central mass body + 4 inward pointing gravitational force arrows
	draw_circle(center, 12.0, col)
	draw_circle(center, 10.0, Color(1, 1, 1, col.a))
	draw_circle(center, 6.0, col)
	
	var dirs: Array[Vector2] = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	for d in dirs:
		var outer_p: Vector2 = center + d * 55.0
		var inner_p: Vector2 = center + d * 22.0
		_render_arrow(outer_p, inner_p, progress, col)

func _render_magnetic_pull(from: Vector2, target: Vector2, progress: float, col: Color) -> void:
	# Dipole magnetic curved lines arching toward target
	var mid := from.lerp(target, 0.5)
	var dir := (target - from).normalized()
	var norm := Vector2(-dir.y, dir.x)
	
	var arch1 := mid + norm * 35.0
	var arch2 := mid - norm * 35.0
	
	# Curve 1
	var curve1_pts := PackedVector2Array([from, arch1, target])
	var current_len := int(progress * 2) + 1
	if progress > 0.0:
		draw_line(from, from.lerp(arch1, clampf(progress * 2.0, 0.0, 1.0)), col, 2.0)
	if progress > 0.5:
		draw_line(arch1, arch1.lerp(target, clampf((progress - 0.5) * 2.0, 0.0, 1.0)), col, 2.0)
	
	# Curve 2
	if progress > 0.0:
		draw_line(from, from.lerp(arch2, clampf(progress * 2.0, 0.0, 1.0)), col, 2.0)
	if progress > 0.5:
		draw_line(arch2, arch2.lerp(target, clampf((progress - 0.5) * 2.0, 0.0, 1.0)), col, 2.0)

func _render_annotation(pos: Vector2, text: String, progress: float, col: Color) -> void:
	# Underline + text reveal
	var text_p := clampf(progress / 0.85, 0.0, 1.0)
	var char_count := text.length() if text_p >= 1.0 else int(float(text.length()) * text_p)
	var visible_str := text.substr(0, char_count)
	
	var font := ThemeDB.fallback_font
	var font_size := 16
	draw_string(font, pos, visible_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, col)
	
	# Ink underline beneath text
	if progress >= 0.5:
		var line_w := font.get_string_size(visible_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		draw_line(pos + Vector2(0, 4), pos + Vector2(line_w, 4), col, 2.0)
