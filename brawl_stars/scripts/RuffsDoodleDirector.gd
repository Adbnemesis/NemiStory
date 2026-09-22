class_name RuffsDoodleDirector
extends Node2D

## Tactical Hand-Drawn Doodle & Military Strategy VFX Director for RUFFS (Brawl Stars)
## Implements the YouTube storytime physical sketching aesthetic:
## - Doodles look physically drawn in dark ink: DRAW -> HOLD -> ERASE
## - Hand-drawn tactical arrows, target circles, ricochet angles, and airstrike landing zones:
##   * Twin Laser Ricochet: Dual laser paths reflecting off walls with incident angles
##   * Starr Force Orbital LZ: Concentric targeting reticle with crosshairs and beacon pulses
##   * Strategic Flanking Arrows: Double-line hatched tactical maneuver vectors
##   * Canine Instinct Thought: Comedic thought bubble of a bone disrupting military focus
##   * Tactical Annotations: Clean handwritten notes and military coordinates

const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var ink_color: Color = Color("#201c24")
var laser_red: Color = Color("#ff3366")
var laser_cyan: Color = Color("#3fe5ff")
var gold_accent: Color = Color("#f6c33a")

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

func spawn_ricochet_trajectory(start_pt: Vector2, wall_pt: Vector2, end_pt: Vector2, draw_d: float = 0.35, hold_d: float = 1.8, erase_d: float = 0.3) -> void:
	active_doodles.append({
		"type": "ricochet",
		"start": start_pt,
		"wall": wall_pt,
		"end": end_pt,
		"timer": 0.0,
		"draw_dur": draw_d,
		"hold_dur": hold_d,
		"erase_dur": erase_d,
		"progress": 0.0,
		"alpha": 1.0
	})
	queue_redraw()

func spawn_lz_target(center: Vector2, radius: float = 65.0, draw_d: float = 0.35, hold_d: float = 2.0, erase_d: float = 0.3) -> void:
	active_doodles.append({
		"type": "lz_target",
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

func spawn_bone_thought(pos: Vector2, draw_d: float = 0.3, hold_d: float = 1.8, erase_d: float = 0.3) -> void:
	active_doodles.append({
		"type": "bone_thought",
		"pos": pos,
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

func spawn_sparkle(center: Vector2, size: float = 14.0, draw_d: float = 0.25, hold_d: float = 1.2, erase_d: float = 0.3) -> void:
	active_doodles.append({
		"type": "sparkle",
		"center": center,
		"size": size,
		"timer": 0.0,
		"draw_dur": draw_d,
		"hold_dur": hold_d,
		"erase_dur": erase_d,
		"progress": 0.0,
		"alpha": 1.0
	})
	queue_redraw()

func _draw() -> void:
	for d in active_doodles:
		var col := Color(ink_color.r, ink_color.g, ink_color.b, d["alpha"])
		var p: float = d["progress"]
		
		match d["type"]:
			"sparkle":
				_render_sparkle(d["center"], d["size"], p, col)
			"arrow":
				_render_arrow(d["from"], d["to"], p, col)
			"circle":
				_render_circle(d["center"], d["radius"], p, col)
			"ricochet":
				_render_ricochet(d["start"], d["wall"], d["end"], p, col)
			"lz_target":
				_render_lz_target(d["center"], d["radius"], p, col)
			"bone_thought":
				_render_bone_thought(d["pos"], p, col)
			"annotation":
				_render_annotation(d["pos"], d["text"], p, col)

func _render_arrow(from: Vector2, to: Vector2, progress: float, color: Color) -> void:
	if progress <= 0.01:
		return
	var cur_to := from.lerp(to, progress)
	draw_line(from, cur_to, color, 3.5)
	
	if progress >= 0.85:
		var head_p := (progress - 0.85) / 0.15
		var dir := (to - from).normalized()
		var n := Vector2(-dir.y, dir.x)
		var left_tip := cur_to - dir * 18.0 + n * 12.0
		var right_tip := cur_to - dir * 18.0 - n * 12.0
		draw_line(cur_to, cur_to.lerp(left_tip, head_p), color, 3.5)
		draw_line(cur_to, cur_to.lerp(right_tip, head_p), color, 3.5)

func _render_circle(center: Vector2, radius: float, progress: float, color: Color) -> void:
	if progress <= 0.01:
		return
	var max_angle := TAU * 1.08 * progress
	var pts := PackedVector2Array()
	var steps := int(36 * progress) + 2
	for i in range(steps):
		var ang := (float(i) / 36.0) * TAU
		if ang > max_angle:
			break
		var r_wobble := radius + sin(ang * 4.0) * 2.0
		pts.append(center + Vector2(cos(ang) * r_wobble, sin(ang) * r_wobble))
	if pts.size() >= 2:
		draw_polyline(pts, color, 3.2, true)

func _render_ricochet(start_pt: Vector2, wall_pt: Vector2, end_pt: Vector2, progress: float, color: Color) -> void:
	if progress <= 0.01:
		return
	
	# Wall barrier sketch
	var w_col := color
	w_col.a *= 0.6
	draw_line(wall_pt + Vector2(0, -60), wall_pt + Vector2(0, 60), w_col, 5.0)
	# Wall hatching
	for y_off in [-45, -30, -15, 0, 15, 30, 45]:
		draw_line(wall_pt + Vector2(0, y_off), wall_pt + Vector2(16, y_off - 12), w_col, 2.0)
	
	# Leg 1: Start to Wall
	if progress < 0.5:
		var leg1_p := progress / 0.5
		var cur1 := start_pt.lerp(wall_pt, leg1_p)
		# Red beam (offset +3)
		draw_line(start_pt + Vector2(0, -3), cur1 + Vector2(0, -3), laser_red, 3.5)
		# Cyan beam (offset -3)
		draw_line(start_pt + Vector2(0, 3), cur1 + Vector2(0, 3), laser_cyan, 3.5)
	else:
		# Leg 1 full
		draw_line(start_pt + Vector2(0, -3), wall_pt + Vector2(0, -3), laser_red, 3.5)
		draw_line(start_pt + Vector2(0, 3), wall_pt + Vector2(0, 3), laser_cyan, 3.5)
		
		# Bounce impact star
		draw_circle(wall_pt, 6.0, gold_accent)
		
		# Leg 2: Wall to End
		var leg2_p := (progress - 0.5) / 0.5
		var cur2 := wall_pt.lerp(end_pt, leg2_p)
		draw_line(wall_pt + Vector2(0, -3), cur2 + Vector2(0, -3), laser_red, 3.5)
		draw_line(wall_pt + Vector2(0, 3), cur2 + Vector2(0, 3), laser_cyan, 3.5)
		
		# Angle annotation text
		var angle_txt_col := color
		angle_txt_col.a *= clampf(leg2_p / 0.5, 0.0, 1.0)
		draw_string(ThemeDB.fallback_font, wall_pt + Vector2(-65, -25), "THETA_1 = THETA_2", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, angle_txt_col)

func _render_lz_target(center: Vector2, radius: float, progress: float, color: Color) -> void:
	if progress <= 0.01:
		return
	
	# Concentric targeting rings
	var r1 := radius * progress
	draw_arc(center, r1, 0, TAU, 32, gold_accent, 3.0, true)
	
	if progress > 0.4:
		var r2 := (radius * 0.55) * ((progress - 0.4) / 0.6)
		draw_arc(center, r2, 0, TAU, 24, laser_red, 2.5, true)
	
	# Crosshairs
	var arm_len := radius * 1.2 * progress
	draw_line(center - Vector2(arm_len, 0), center + Vector2(arm_len, 0), color, 2.2)
	draw_line(center - Vector2(0, arm_len), center + Vector2(0, arm_len), color, 2.2)
	
	# Corner reticles
	var c_col := color
	c_col.a *= 0.8
	var cr := radius * 0.85
	for sign_x in [-1.0, 1.0]:
		for sign_y in [-1.0, 1.0]:
			var corner := center + Vector2(sign_x * cr, sign_y * cr)
			draw_line(corner, corner - Vector2(sign_x * 12, 0), c_col, 2.0)
			draw_line(corner, corner - Vector2(0, sign_y * 12), c_col, 2.0)
	
	if progress > 0.7:
		var txt_col := gold_accent
		txt_col.a *= (progress - 0.7) / 0.3
		draw_string(ThemeDB.fallback_font, center + Vector2(-54, radius + 22), "AIRSTRIKE LZ", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, txt_col)

func _render_bone_thought(pos: Vector2, progress: float, color: Color) -> void:
	if progress <= 0.01:
		return
	
	# Thought bubble connection dots
	var dot1 := pos + Vector2(18, -14)
	var dot2 := pos + Vector2(34, -30)
	var bubble_center := pos + Vector2(65, -55)
	
	draw_circle(dot1, 3.0, color)
	if progress > 0.2:
		draw_circle(dot2, 5.0, color)
	
	if progress > 0.4:
		var b_prog := (progress - 0.4) / 0.6
		# Thought cloud bubble
		var cloud_r := 34.0 * b_prog
		draw_circle(bubble_center, cloud_r, Color.WHITE)
		draw_arc(bubble_center, cloud_r, 0, TAU, 24, color, 2.5, true)
		
		# Inside: Golden Dog Bone
		if progress > 0.65:
			var bone_p := bubble_center
			draw_line(bone_p + Vector2(-12, 0), bone_p + Vector2(12, 0), gold_accent, 6.0)
			draw_circle(bone_p + Vector2(-12, -4), 4.5, gold_accent)
			draw_circle(bone_p + Vector2(-12, 4), 4.5, gold_accent)
			draw_circle(bone_p + Vector2(12, -4), 4.5, gold_accent)
			draw_circle(bone_p + Vector2(12, 4), 4.5, gold_accent)
			
			# Question mark / sparkle
			draw_string(ThemeDB.fallback_font, bone_p + Vector2(-6, -10), "?!", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)

func _render_annotation(pos: Vector2, text: String, progress: float, color: Color) -> void:
	var visible_chars := int(text.length() * clampf(progress / 0.85, 0.0, 1.0))
	if visible_chars <= 0:
		return
	var sub := text.substr(0, visible_chars)
	
	# Background tag pill
	var font := ThemeDB.fallback_font
	var font_size := 16
	var str_size := font.get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var bg_rect := Rect2(pos + Vector2(-6, -str_size.y - 2), str_size + Vector2(12, 8))
	var bg_col := Color.WHITE
	bg_col.a = color.a * 0.92
	draw_rect(bg_rect, bg_col, true)
	draw_rect(bg_rect, color, false, 1.8)
	
	draw_string(font, pos, sub, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
	
func _render_sparkle(center: Vector2, size: float, progress: float, color: Color) -> void:
	if progress <= 0.01:
		return
	var arm_len := size * progress
	draw_line(center - Vector2(0, arm_len), center + Vector2(0, arm_len), color, 2.5)
	draw_line(center - Vector2(arm_len, 0), center + Vector2(arm_len, 0), color, 2.5)
	var diag := arm_len * 0.5
	draw_line(center - Vector2(diag, diag), center + Vector2(diag, diag), color, 1.8)
	draw_line(center - Vector2(-diag, diag), center + Vector2(-diag, diag), color, 1.8)
