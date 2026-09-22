class_name LeonDoodleDirector
extends Node2D

## Hand-Drawn Storytime Doodle & Stealth VFX Director for LEON (Brawl Stars)
## Implements the YouTube storytime physical sketching aesthetic:
## - Doodles look physically drawn in dark ink: DRAW -> HOLD -> ERASE
## - Hand-drawn ninja star trails, smoke bomb "POOF" clouds, sneaking bush camper diagrams:
##   * Shuriken Barrage: Spinning ninja star trajectories with dynamic speed streaks
##   * Smoke Bomb Invisibility: Puffy cloud outlines with spirals and question marks
##   * Bush Camping: Grassy bush outline with glowing eyes hidden inside
##   * Con-Artist Pitch Arrows: Curved emphasis arrows with comedic captions
##   * Panic Sweat Splatter: Radial comic sweat drops for frantic moments

const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var ink_color: Color = Color("#1e1a24")
var green_accent: Color = Color("#1ea838")
var orange_accent: Color = Color("#f47818")
var cyan_accent: Color = Color("#24a4f4")

var active_doodles: Array[Dictionary] = []

func _process(delta: float) -> void:
	var needs_redraw := false
	var finished_indices: Array[int] = []
	
	for i in range(active_doodles.size()):
		var d: Dictionary = active_doodles[i]
		d["timer"] += delta
		var t: float = d["timer"]
		
		# Phase 1: Draw (0.0 to draw_dur)
		if t < d["draw_dur"]:
			d["progress"] = clampf(t / d["draw_dur"], 0.0, 1.0)
			needs_redraw = true
		# Phase 2: Hold (draw_dur to draw_dur + hold_dur)
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

func doodle_smoke_bomb(pos: Vector2, hold_dur: float = 2.0) -> void:
	# Puffy cartoon smoke cloud with "POOF!" text and mystery spiral
	var d := {
		"type": "smoke_bomb",
		"pos": pos,
		"timer": 0.0,
		"draw_dur": 0.25,
		"hold_dur": hold_dur,
		"erase_dur": 0.4,
		"progress": 0.0,
		"alpha": 1.0
	}
	active_doodles.append(d)
	queue_redraw()

func doodle_bush(pos: Vector2, hold_dur: float = 2.2) -> void:
	# Grassy bush outline with suspicious glowing eyes inside
	var d := {
		"type": "bush_camper",
		"pos": pos,
		"timer": 0.0,
		"draw_dur": 0.35,
		"hold_dur": hold_dur,
		"erase_dur": 0.4,
		"progress": 0.0,
		"alpha": 1.0
	}
	active_doodles.append(d)
	queue_redraw()

func doodle_shuriken_barrage(from_pos: Vector2, to_pos: Vector2, hold_dur: float = 1.8) -> void:
	# 3 flying shurikens with speed lines
	var d := {
		"type": "shurikens",
		"from": from_pos,
		"to": to_pos,
		"timer": 0.0,
		"draw_dur": 0.2,
		"hold_dur": hold_dur,
		"erase_dur": 0.3,
		"progress": 0.0,
		"alpha": 1.0
	}
	active_doodles.append(d)
	queue_redraw()

func doodle_con_artist_arrow(from_pos: Vector2, to_pos: Vector2, text: String = "FREE TROPHIES!", hold_dur: float = 2.0) -> void:
	# Bouncy hand-drawn arrow with comedic annotation
	var d := {
		"type": "arrow_note",
		"from": from_pos,
		"to": to_pos,
		"text": text,
		"timer": 0.0,
		"draw_dur": 0.3,
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
			"smoke_bomb":
				_draw_smoke_bomb_doodle(d["pos"], p, a)
			"bush_camper":
				_draw_bush_doodle(d["pos"], p, a)
			"shurikens":
				_draw_shurikens_doodle(d["from"], d["to"], p, a)
			"arrow_note":
				_draw_arrow_doodle(d["from"], d["to"], d.get("text", ""), p, a)

func _draw_smoke_bomb_doodle(pos: Vector2, p: float, alpha: float) -> void:
	var col := Color(ink_color.r, ink_color.g, ink_color.b, alpha)
	var fill_col := Color(0.9, 0.94, 0.9, alpha * 0.45)
	
	# Puffy cloud lobes
	var lobes: Array[Vector2] = [
		Vector2(-45, -10), Vector2(-30, -38), Vector2(0, -50),
		Vector2(32, -36), Vector2(46, -8), Vector2(25, 20),
		Vector2(-20, 22)
	]
	var count := int(lobes.size() * p)
	for i in range(count):
		draw_circle(pos + lobes[i], 22.0, fill_col)
		draw_arc(pos + lobes[i], 22.0, -PI * 0.8, PI * 0.8, 16, col, 2.8, true)
	
	if p >= 0.8:
		# "POOF!" text sketch
		draw_string(ThemeDB.fallback_font, pos + Vector2(-28, -8), "POOF!", HORIZONTAL_ALIGNMENT_CENTER, -1, 24, col)

func _draw_bush_doodle(pos: Vector2, p: float, alpha: float) -> void:
	var col := Color(green_accent.r, green_accent.g, green_accent.b, alpha)
	var ink := Color(ink_color.r, ink_color.g, ink_color.b, alpha)
	
	# Bush foliage lobes
	var foliage := [
		Vector2(-50, 20), Vector2(-40, -10), Vector2(-15, -28),
		Vector2(15, -28), Vector2(40, -10), Vector2(50, 20)
	]
	var c := int(foliage.size() * p)
	for i in range(c):
		draw_circle(pos + foliage[i], 24.0, Color(0.12, 0.65, 0.22, alpha * 0.35))
		draw_arc(pos + foliage[i], 24.0, 0, TAU, 16, col, 3.2, true)
	
	if p >= 0.9:
		# Glowing eyes peeking out
		draw_circle(pos + Vector2(-10, 0), 4.5, Color(1, 1, 1, alpha))
		draw_circle(pos + Vector2(10, 0), 4.5, Color(1, 1, 1, alpha))
		draw_circle(pos + Vector2(-9, 0), 2.2, ink)
		draw_circle(pos + Vector2(11, 0), 2.2, ink)

func _draw_shurikens_doodle(from_pos: Vector2, to_pos: Vector2, p: float, alpha: float) -> void:
	var col := Color(cyan_accent.r, cyan_accent.g, cyan_accent.b, alpha)
	var ink := Color(ink_color.r, ink_color.g, ink_color.b, alpha)
	
	var curr := from_pos.lerp(to_pos, p)
	# Speed line
	draw_line(from_pos, curr, col, 2.5, true)
	draw_line(from_pos + Vector2(0, -6), curr + Vector2(0, -6), col, 1.5, true)
	draw_line(from_pos + Vector2(0, 6), curr + Vector2(0, 6), col, 1.5, true)
	
	# Spinning star at head
	draw_circle(curr, 7.0, col)
	draw_arc(curr, 12.0, 0, TAU, 12, ink, 2.0, true)

func _draw_arrow_doodle(from_pos: Vector2, to_pos: Vector2, text: String, p: float, alpha: float) -> void:
	var col := Color(orange_accent.r, orange_accent.g, orange_accent.b, alpha)
	var ink := Color(ink_color.r, ink_color.g, ink_color.b, alpha)
	
	var curr := from_pos.lerp(to_pos, p)
	draw_line(from_pos, curr, col, 3.5, true)
	
	if p >= 0.9:
		# Arrowhead
		var dir := (to_pos - from_pos).normalized()
		var left_wing := to_pos - dir * 16.0 + Vector2(-dir.y, dir.x) * 10.0
		var right_wing := to_pos - dir * 16.0 - Vector2(-dir.y, dir.x) * 10.0
		draw_line(to_pos, left_wing, col, 3.5, true)
		draw_line(to_pos, right_wing, col, 3.5, true)
		
		if text != "":
			draw_string(ThemeDB.fallback_font, from_pos + Vector2(-30, -12), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, ink)
