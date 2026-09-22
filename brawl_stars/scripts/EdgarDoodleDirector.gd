class_name EdgarDoodleDirector
extends Node2D

## Hand-Drawn Storytime Doodle & Cynical VFX Director for EDGAR (Brawl Stars)
## Implements the YouTube storytime physical sketching aesthetic:
## - Doodles look physically drawn in dark ink: DRAW -> HOLD -> ERASE
## - Scarf punch "WHAM!" bursts, toxic thumbs-down salt icons, leap trajectory arcs:
##   * Giant Scarf Punch: Oversized cartoon fist striking with action lines & "WHAM!"
##   * Toxic Thumbs Down: Spinning circular thumbs-down pin with salt sprinkles
##   * Super Jump Trajectory: Dotted parabolic arc showing an ill-fated leap
##   * Emo Stormcloud: Dark raincloud with drizzle and tiny lightning bolt
##   * Toxic Chat Notification: Smartphone alert bubble ("Stop feeding")

const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var ink_color: Color = Color("#1c1624")
var red_accent: Color = Color("#d62432")
var purple_accent: Color = Color("#8c3cd8")
var blue_accent: Color = Color("#40a8f8")

var active_doodles: Array[Dictionary] = []

func _process(delta: float) -> void:
	var needs_redraw := false
	var finished_indices: Array[int] = []
	
	for i in range(active_doodles.size()):
		var d: Dictionary = active_doodles[i]
		d["timer"] += delta
		var t: float = d["timer"]
		
		# Phase 1: Draw
		if t < d["draw_dur"]:
			d["progress"] = clampf(t / d["draw_dur"], 0.0, 1.0)
			needs_redraw = true
		# Phase 2: Hold
		elif t < d["draw_dur"] + d["hold_dur"]:
			d["progress"] = 1.0
			d["alpha"] = 1.0
		# Phase 3: Erase
		elif t < d["draw_dur"] + d["hold_dur"] + d["erase_dur"]:
			var erase_t: float = (t - (d["draw_dur"] + d["hold_dur"])) / d["erase_dur"]
			d["alpha"] = 1.0 - erase_t
			needs_redraw = true
		else:
			finished_indices.append(i)
			needs_redraw = true
	
	for i in range(finished_indices.size() - 1, -1, -1):
		active_doodles.remove_at(finished_indices[i])
	
	if needs_redraw:
		queue_redraw()

func clear_all() -> void:
	active_doodles.clear()
	queue_redraw()

# -------------------------------------------------------------------------
# DOODLE API
# -------------------------------------------------------------------------

func doodle_scarf_punch(from_pos: Vector2, to_pos: Vector2, hold_dur: float = 1.8) -> void:
	var d := {
		"type": "scarf_punch",
		"from": from_pos,
		"to": to_pos,
		"timer": 0.0,
		"draw_dur": 0.18,
		"hold_dur": hold_dur,
		"erase_dur": 0.35,
		"progress": 0.0,
		"alpha": 1.0
	}
	active_doodles.append(d)
	queue_redraw()

func doodle_toxic_thumbs_down(pos: Vector2, hold_dur: float = 2.0) -> void:
	var d := {
		"type": "thumbs_down",
		"pos": pos,
		"timer": 0.0,
		"draw_dur": 0.25,
		"hold_dur": hold_dur,
		"erase_dur": 0.35,
		"progress": 0.0,
		"alpha": 1.0
	}
	active_doodles.append(d)
	queue_redraw()

func doodle_jump_arc(from_pos: Vector2, peak_pos: Vector2, land_pos: Vector2, hold_dur: float = 2.2) -> void:
	var d := {
		"type": "jump_arc",
		"from": from_pos,
		"peak": peak_pos,
		"land": land_pos,
		"timer": 0.0,
		"draw_dur": 0.35,
		"hold_dur": hold_dur,
		"erase_dur": 0.4,
		"progress": 0.0,
		"alpha": 1.0
	}
	active_doodles.append(d)
	queue_redraw()

func doodle_emo_stormcloud(pos: Vector2, hold_dur: float = 2.5) -> void:
	var d := {
		"type": "emo_cloud",
		"pos": pos,
		"timer": 0.0,
		"draw_dur": 0.3,
		"hold_dur": hold_dur,
		"erase_dur": 0.4,
		"progress": 0.0,
		"alpha": 1.0
	}
	active_doodles.append(d)
	queue_redraw()

func doodle_phone_alert(pos: Vector2, text: String = "Bro stop feeding", hold_dur: float = 2.2) -> void:
	var d := {
		"type": "chat_alert",
		"pos": pos,
		"text": text,
		"timer": 0.0,
		"draw_dur": 0.25,
		"hold_dur": hold_dur,
		"erase_dur": 0.35,
		"progress": 0.0,
		"alpha": 1.0
	}
	active_doodles.append(d)
	queue_redraw()

# -------------------------------------------------------------------------
# RENDERING
# -------------------------------------------------------------------------

func _draw() -> void:
	for d in active_doodles:
		var a: float = d.get("alpha", 1.0)
		var p: float = d.get("progress", 1.0)
		
		match d.get("type"):
			"scarf_punch":
				_draw_punch_doodle(d["from"], d["to"], p, a)
			"thumbs_down":
				_draw_thumbs_down_doodle(d["pos"], p, a)
			"jump_arc":
				_draw_jump_arc_doodle(d["from"], d["peak"], d["land"], p, a)
			"emo_cloud":
				_draw_emo_cloud_doodle(d["pos"], p, a)
			"chat_alert":
				_draw_chat_alert_doodle(d["pos"], d.get("text", ""), p, a)

func _draw_punch_doodle(from_pos: Vector2, to_pos: Vector2, p: float, alpha: float) -> void:
	var col := Color(purple_accent.r, purple_accent.g, purple_accent.b, alpha)
	var ink := Color(ink_color.r, ink_color.g, ink_color.b, alpha)
	
	var curr := from_pos.lerp(to_pos, p)
	# Speed streaks
	draw_line(from_pos, curr, col, 5.0, true)
	draw_line(from_pos + Vector2(0, -8), curr + Vector2(0, -8), col, 2.0, true)
	draw_line(from_pos + Vector2(0, 8), curr + Vector2(0, 8), col, 2.0, true)
	
	# Giant impact fist at end
	draw_circle(curr, 18.0, col)
	draw_arc(curr, 18.0, 0, TAU, 20, ink, 2.8, true)
	
	if p >= 0.85:
		# "WHAM!" impact burst
		draw_string(ThemeDB.fallback_font, to_pos + Vector2(-28, -26), "WHAM!", HORIZONTAL_ALIGNMENT_CENTER, -1, 26, Color(red_accent.r, red_accent.g, red_accent.b, alpha))

func _draw_thumbs_down_doodle(pos: Vector2, p: float, alpha: float) -> void:
	var red_col := Color(red_accent.r, red_accent.g, red_accent.b, alpha)
	var ink := Color(ink_color.r, ink_color.g, ink_color.b, alpha)
	
	# Circular red badge
	draw_circle(pos, 24.0 * p, red_col)
	draw_arc(pos, 24.0 * p, 0, TAU, 24, ink, 3.0, true)
	
	if p >= 0.8:
		# White thumbs down icon
		var thumb_root := pos + Vector2(0, -6)
		draw_line(thumb_root, pos + Vector2(0, 10), Color.WHITE, 6.0, true)
		draw_line(pos + Vector2(-6, 2), pos + Vector2(6, 2), Color.WHITE, 5.0, true)
		# "SALT" text caption
		draw_string(ThemeDB.fallback_font, pos + Vector2(-20, 36), "SALT", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, ink)

func _draw_jump_arc_doodle(from_pos: Vector2, peak_pos: Vector2, land_pos: Vector2, p: float, alpha: float) -> void:
	var col := Color(purple_accent.r, purple_accent.g, purple_accent.b, alpha)
	var ink := Color(ink_color.r, ink_color.g, ink_color.b, alpha)
	
	# Quadratic bezier trajectory
	var pts := 20
	var max_idx := int(pts * p)
	for i in range(max_idx - 1):
		var t1 := float(i) / float(pts)
		var t2 := float(i + 1) / float(pts)
		var p1 := (1.0 - t1) * (1.0 - t1) * from_pos + 2.0 * (1.0 - t1) * t1 * peak_pos + t1 * t1 * land_pos
		var p2 := (1.0 - t2) * (1.0 - t2) * from_pos + 2.0 * (1.0 - t2) * t2 * peak_pos + t2 * t2 * land_pos
		draw_line(p1, p2, col, 2.8, true)
	
	if p >= 0.95:
		# Red "X" disaster landing mark
		draw_line(land_pos + Vector2(-8, -8), land_pos + Vector2(8, 8), Color(red_accent.r, red_accent.g, red_accent.b, alpha), 3.0, true)
		draw_line(land_pos + Vector2(8, -8), land_pos + Vector2(-8, 8), Color(red_accent.r, red_accent.g, red_accent.b, alpha), 3.0, true)

func _draw_emo_cloud_doodle(pos: Vector2, p: float, alpha: float) -> void:
	var dark_col := Color(0.18, 0.14, 0.24, alpha * 0.75)
	var rain_col := Color(blue_accent.r, blue_accent.g, blue_accent.b, alpha)
	
	# Dark puffy stormcloud lobes
	var lobes := [Vector2(-30, 0), Vector2(-15, -16), Vector2(10, -18), Vector2(28, -2), Vector2(10, 10), Vector2(-15, 8)]
	var cnt := int(lobes.size() * p)
	for i in range(cnt):
		draw_circle(pos + lobes[i], 16.0, dark_col)
	
	if p >= 0.8:
		# Rain drizzle lines
		for x_off in [-20, -10, 0, 10, 20]:
			draw_line(pos + Vector2(x_off, 18), pos + Vector2(x_off - 4, 34), rain_col, 1.8, true)

func _draw_chat_alert_doodle(pos: Vector2, text: String, p: float, alpha: float) -> void:
	var bg_col := Color(0.96, 0.96, 0.98, alpha)
	var ink := Color(ink_color.r, ink_color.g, ink_color.b, alpha)
	
	var r := Rect2(pos.x - 70, pos.y - 20, 140 * p, 32)
	draw_rect(r, bg_col)
	draw_rect(r, ink, false, 2.0)
	
	if p >= 0.9:
		draw_string(ThemeDB.fallback_font, pos + Vector2(-60, 2), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ink)
