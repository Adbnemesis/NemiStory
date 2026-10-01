class_name ADBIntroDoodles
extends Node2D

## ADBIntroDoodles — Master Hand-Authored Storytime Doodles & Lettering
## ADB Episode 00: "HI, I'M ADB."
##
## Episode artwork played through the shared live-ink and drawn-lettering engine.
## Legacy illustrations remain available while authored assets are migrated.

const INK_MAIN: Color = Color("#2b2623")
const INK_SOFT: Color = Color("#594f4b")
const INK_RED: Color = Color("#d63031")
const INK_GOLD: Color = Color("#e67e22")
const INK_BLUE: Color = Color("#0984e3")
const INK_CYAN: Color = Color("#00cec9")
const INK_MINT: Color = Color("#00b894")
const INK_PURPLE: Color = Color("#6c5ce7")

const Marks = preload("res://common/engine/illustration/StoryMarks.gd")

var active_doodles: Array[Node2D] = []

# =============================================================================
# ANIMATED DOODLE CONTAINER (Organic Stroke-by-Stroke Revealer)
# =============================================================================
class AnimatedDoodle extends "res://common/engine/illustration/LiveDrawing.gd":
	pass

func clear_all() -> void:
	for d in active_doodles:
		if is_instance_valid(d):
			d.queue_free()
	active_doodles.clear()

# =============================================================================
# 1. AUTHORED VECTOR LETTERING ENGINE
# =============================================================================
static func add_handwritten_text(doodle: AnimatedDoodle, text: String, center_pos: Vector2, col: Color, font_h: float = 22.0, _line_w: float = 2.4) -> void:
	var letters = preload("res://common/engine/illustration/DrawnLettering.gd").compose(text, font_h, col)
	var offset := center_pos - Vector2(letters.width * 0.5, font_h * 0.5)
	for stroke in letters.strokes:
		var moved := PackedVector2Array()
		for pt in stroke.pts:
			moved.append(pt + offset)
		stroke.pts = moved
		doodle.stroke_list.append(stroke)

# =============================================================================
# 2. STORYTIME COMIC SPEECH BUBBLE & ACTION BURSTS
# =============================================================================
func spawn_speech_bubble(pos: Vector2, text: String, col: Color = INK_MAIN, flip_tail: bool = false, dur: float = 0.20) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	var bubble_w := 95.0
	var bubble_h := 38.0
	if text.length() > 6:
		bubble_w = float(text.length()) * 9.0 + 30.0

	var perimeter := PackedVector2Array()
	var num_pts := 26
	for i in range(num_pts):
		var t := float(i) / float(num_pts)
		var ang := t * TAU
		var rx := bubble_w * (1.0 + sin(ang * 3.0) * 0.04)
		var ry := bubble_h * (1.0 + cos(ang * 4.0) * 0.05)
		perimeter.append(Vector2(cos(ang) * rx, sin(ang) * ry))

	var tail_root: Vector2
	var tail_tip: Vector2
	var tail_end: Vector2
	if flip_tail:
		tail_root = Vector2(bubble_w * 0.32, bubble_h * 0.95)
		tail_tip = Vector2(bubble_w * 0.50, bubble_h * 1.70)
		tail_end = Vector2(bubble_w * 0.12, bubble_h * 0.98)
	else:
		tail_root = Vector2(-bubble_w * 0.12, bubble_h * 0.98)
		tail_tip = Vector2(-bubble_w * 0.50, bubble_h * 1.70)
		tail_end = Vector2(-bubble_w * 0.32, bubble_h * 0.95)

	var full_bubble := PackedVector2Array()
	var inserted := false
	for p in perimeter:
		var should_insert := false
		if flip_tail:
			should_insert = (not inserted and p.y > bubble_h * 0.85 and p.x > 0.0 and p.x < bubble_w * 0.35)
		else:
			should_insert = (not inserted and p.y > bubble_h * 0.85 and p.x < -bubble_w * 0.10)
		if should_insert:
			full_bubble.append(tail_root)
			full_bubble.append(tail_tip)
			full_bubble.append(tail_end)
			inserted = true
		full_bubble.append(p)
	full_bubble.append(full_bubble[0])

	d.fills.append({"poly": full_bubble, "col": Color("#fffef8")})
	d.stroke_list.append({"pts": full_bubble, "w": 3.0, "col": col})
	add_handwritten_text(d, text, Vector2(0.0, 2.0), col, 22.0, 2.8)

	d.reveal(dur)
	return d

func spawn_action_burst(pos: Vector2, text: String, col: Color = INK_RED, dur: float = 0.18) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	var radius_base := 75.0 + float(text.length()) * 4.0
	var burst_pts := PackedVector2Array()
	var num_spikes := 14
	for i in range(num_spikes):
		var a1 := (float(i) / float(num_spikes)) * TAU
		var a2 := (float(i) + 0.5) / float(num_spikes) * TAU
		var r_outer := radius_base * randf_range(1.15, 1.45)
		var r_inner := radius_base * randf_range(0.65, 0.85)
		burst_pts.append(Vector2(cos(a1) * r_outer, sin(a1) * r_outer * 0.7))
		burst_pts.append(Vector2(cos(a2) * r_inner, sin(a2) * r_inner * 0.7))
	burst_pts.append(burst_pts[0])

	d.fills.append({"poly": burst_pts, "col": Color("#fffef0")})
	d.stroke_list.append({"pts": burst_pts, "w": 3.5, "col": col})
	add_handwritten_text(d, text, Vector2(0, 0), col, 24.0, 3.2)

	d.reveal(dur)
	return d

# =============================================================================
# 3. EXPRESSIVE EMOTIONAL ACCENTS (Sweat, Confusion, Dust, Sparkles, Heart)
# =============================================================================
func spawn_sweat_drops(pos: Vector2, count: int = 2, dur: float = 0.22) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	# Position beside the temple / upper forehead, never directly over eyes or nose
	d.position = pos + Vector2(36, -28)
	add_child(d)
	active_doodles.append(d)

	var drop_col := Color(0.65, 0.85, 1.0, 0.85)
	for i in range(count):
		var ox := float(i) * 14.0 + randf_range(-2, 2)
		var oy := float(i) * 6.0 + randf_range(-3, 3)
		# Compact, elegant anime teardrop bead (12px tall, 6px wide)
		var drop_pts := PackedVector2Array([
			Vector2(ox, oy - 10),
			Vector2(ox + 3.2, oy - 3),
			Vector2(ox + 2.8, oy + 3),
			Vector2(ox, oy + 4.5),
			Vector2(ox - 2.8, oy + 3),
			Vector2(ox - 3.2, oy - 3)
		])
		d.fills.append({"poly": drop_pts, "col": drop_col})
		d.stroke_list.append({"pts": drop_pts, "w": 1.6, "col": INK_MAIN})
		# Tiny white glint highlight
		d.fills.append({"poly": PackedVector2Array([
			Vector2(ox - 1.0, oy - 2),
			Vector2(ox + 0.5, oy - 2),
			Vector2(ox + 0.5, oy),
			Vector2(ox - 1.0, oy)
		]), "col": Color.WHITE})

	d.reveal(dur)
	return d

func spawn_confusion_marks(pos: Vector2, dur: float = 0.25) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	# 1. Swirling spiral knot
	var spiral_pts := PackedVector2Array()
	var segs := 24
	for i in range(segs):
		var ang := float(i) * 0.45
		var rad := 6.0 + float(i) * 1.5
		spiral_pts.append(Vector2(cos(ang) * rad - 30, sin(ang) * rad * 0.6 - 10))
	d.stroke_list.append({"pts": spiral_pts, "w": 2.6, "col": INK_SOFT})

	# 2. Big comic question marks
	add_handwritten_text(d, "? ? ?", Vector2(25, 0), INK_GOLD, 28.0, 3.0)

	d.reveal(dur)
	return d

func spawn_push_dust(pos: Vector2, dur: float = 0.25) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	# Comic puff cloud arcs
	var puff_col := Color(0.92, 0.90, 0.88, 0.8)
	var pts := PackedVector2Array([
		Vector2(-45, 0), Vector2(-40, -18), Vector2(-20, -28),
		Vector2(5, -24), Vector2(28, -28), Vector2(48, -14),
		Vector2(50, 0), Vector2(-45, 0)
	])
	d.fills.append({"poly": pts, "col": puff_col})
	d.stroke_list.append({"pts": pts, "w": 2.6, "col": INK_MAIN})
	# Skid dash lines
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-60, 4), Vector2(-30, 4)]), "w": 2.4, "col": INK_SOFT})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-45, 10), Vector2(-15, 10)]), "w": 2.0, "col": INK_SOFT})

	d.reveal(dur)
	return d

func spawn_sparkles(pos: Vector2, count: int = 4, dur: float = 0.22) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	var offsets := [Vector2(-35, -25), Vector2(40, -20), Vector2(-20, 25), Vector2(30, 20)]
	for i in range(mini(count, offsets.size())):
		var op: Vector2 = offsets[i]
		# 4-pointed diamond star
		var star_pts := PackedVector2Array([
			op + Vector2(0, -16), op + Vector2(4, -4), op + Vector2(16, 0),
			op + Vector2(4, 4), op + Vector2(0, 16), op + Vector2(-4, 4),
			op + Vector2(-16, 0), op + Vector2(-4, -4), op + Vector2(0, -16)
		])
		d.fills.append({"poly": star_pts, "col": Color("#fdcb6e")})
		d.stroke_list.append({"pts": star_pts, "w": 2.0, "col": INK_GOLD})

	d.reveal(dur)
	return d

func spawn_heart_doodle(pos: Vector2, dur: float = 0.22) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	var heart_col := Color("#ff7675")
	var heart_pts := PackedVector2Array([
		Vector2(0, 8), Vector2(-16, -14), Vector2(-26, -6),
		Vector2(-24, 10), Vector2(0, 32),
		Vector2(24, 10), Vector2(26, -6), Vector2(16, -14), Vector2(0, 8)
	])
	d.fills.append({"poly": heart_pts, "col": heart_col})
	d.stroke_list.append({"pts": heart_pts, "w": 2.8, "col": INK_MAIN})

	d.reveal(dur)
	return d

func spawn_confetti(pos: Vector2, count: int = 20, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	var colors := [Color("#e74c3c"), Color("#f1c40f"), Color("#2ecc71"), Color("#3498db"), Color("#9b59b6")]
	for i in range(count):
		var rx := randf_range(-180, 180)
		var ry := randf_range(-140, 120)
		var col: Color = colors[i % colors.size()]
		var rib := PackedVector2Array([
			Vector2(rx, ry), Vector2(rx + randf_range(-8, 8), ry + randf_range(12, 24))
		])
		d.stroke_list.append({"pts": rib, "w": randf_range(3.0, 5.0), "col": col})

	d.reveal(dur)
	return d

# =============================================================================
# 4. STORYLINE COMIC METAPHORS (Potato Chart, Digital Clock, Ball Trajectory)
# =============================================================================

# --- 3-Stage Humorous Potato Evolution Chart ---
func spawn_potato_evolution_chart(pos: Vector2, dur: float = 0.38) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	# Background card
	var card_rect := PackedVector2Array([
		Vector2(-220, -100), Vector2(220, -100),
		Vector2(220, 100), Vector2(-220, 100), Vector2(-220, -100)
	])
	d.fills.append({"poly": card_rect, "col": Color("#fffef5")})
	d.stroke_list.append({"pts": card_rect, "w": 3.0, "col": INK_MAIN})

	# Title: "CHARACTER EVOLUTION"
	add_handwritten_text(d, "CHARACTER DESIGN", Vector2(0, -75), INK_MAIN, 18.0, 2.5)

	# Stage 1: Derpy Potato (Left)
	var pot_pts := PackedVector2Array([
		Vector2(-160, 0), Vector2(-155, -25), Vector2(-140, -35),
		Vector2(-115, -30), Vector2(-105, 5), Vector2(-120, 30),
		Vector2(-145, 35), Vector2(-160, 0)
	])
	d.fills.append({"poly": pot_pts, "col": Color("#d3a26a")})
	d.stroke_list.append({"pts": pot_pts, "w": 2.5, "col": INK_MAIN})
	# Big RED X through potato
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-165, -35), Vector2(-100, 35)]), "w": 4.0, "col": INK_RED})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-100, -35), Vector2(-165, 35)]), "w": 4.0, "col": INK_RED})
	add_handwritten_text(d, "POTATO", Vector2(-132, 55), INK_RED, 14.0, 2.2)

	# Stage 2: Stick Figure (Center)
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(0, -30), Vector2(0, 15)]), "w": 2.5, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-18, -10), Vector2(18, -10)]), "w": 2.5, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-12, 35), Vector2(0, 15), Vector2(12, 35)]), "w": 2.5, "col": INK_MAIN})
	# Arrow to Stage 3
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(40, 0), Vector2(80, 0)]), "w": 3.0, "col": INK_GOLD})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(70, -8), Vector2(80, 0), Vector2(70, 8)]), "w": 3.0, "col": INK_GOLD})

	# Stage 3: Approved ADB (Right)
	var adb_box := PackedVector2Array([
		Vector2(110, -35), Vector2(175, -35), Vector2(175, 35), Vector2(110, 35), Vector2(110, -35)
	])
	d.fills.append({"poly": adb_box, "col": Color(0.9, 0.98, 0.92)})
	d.stroke_list.append({"pts": adb_box, "w": 2.5, "col": INK_MINT})
	add_handwritten_text(d, "ADB", Vector2(142, 0), INK_MAIN, 20.0, 2.8)
	# Green checkmark
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(130, -45), Vector2(142, -35), Vector2(165, -55)]), "w": 3.8, "col": INK_MINT})
	add_handwritten_text(d, "APPROVED!", Vector2(142, 55), INK_MINT, 14.0, 2.2)

	d.reveal(dur)
	return d

# --- Digital Clock 3:42 AM ---
func spawn_digital_clock(pos: Vector2, time_str: String = "3:42 AM", dur: float = 0.25) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	var frame_pts := PackedVector2Array([
		Vector2(-90, -30), Vector2(90, -30), Vector2(90, 30), Vector2(-90, 30), Vector2(-90, -30)
	])
	d.fills.append({"poly": frame_pts, "col": Color("#1e272e")})
	d.stroke_list.append({"pts": frame_pts, "w": 3.0, "col": INK_MAIN})
	add_handwritten_text(d, time_str, Vector2(0, 0), Color("#ff7675"), 24.0, 3.0)

	d.reveal(dur)
	return d

# --- Table Tennis Spin Arc ---
func spawn_spin_arc(pos: Vector2, dur: float = 0.25) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	var arc_pts := PackedVector2Array()
	for i in range(16):
		var t := float(i) / 15.0
		var x := -120.0 + t * 240.0
		var y := -sin(t * PI) * 85.0
		arc_pts.append(Vector2(x, y))
	d.stroke_list.append({"pts": arc_pts, "w": 3.4, "col": Color("#e67e22")})
	# Arrowhead at end
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(105, -15), Vector2(120, 0), Vector2(115, 18)]), "w": 3.4, "col": Color("#e67e22")})
	add_handwritten_text(d, "TOPSPIN", Vector2(0, -65), Color("#e67e22"), 18.0, 2.6)

	d.reveal(dur)
	return d

# --- Engineering Formula Scribbles ---
func spawn_math_formulas(pos: Vector2, dur: float = 0.30) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	add_handwritten_text(d, "F = M A", Vector2(-80, -20), INK_BLUE, 20.0, 2.4)
	add_handwritten_text(d, "V = I R", Vector2(80, -20), INK_BLUE, 20.0, 2.4)
	add_handwritten_text(d, "E = M C 2", Vector2(0, 25), INK_BLUE, 20.0, 2.4)

	d.reveal(dur)
	return d

# --- Outro Subscribe Banner ---
func spawn_subscribe_banner(pos: Vector2, dur: float = 0.30) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	var banner_pts := PackedVector2Array([
		Vector2(-140, -32), Vector2(140, -32), Vector2(130, 32), Vector2(-130, 32), Vector2(-140, -32)
	])
	d.fills.append({"poly": banner_pts, "col": Color("#d63031")})
	d.stroke_list.append({"pts": banner_pts, "w": 3.5, "col": INK_MAIN})
	add_handwritten_text(d, "SUBSCRIBE!", Vector2(0, 0), Color("#ffffff"), 24.0, 3.2)

	# Stars around banner
	spawn_sparkles(pos + Vector2(-160, 0), 2)
	spawn_sparkles(pos + Vector2(160, 0), 2)

	d.reveal(dur)
	return d

# =============================================================================
# 5. LEGACY BACKWARD-COMPATIBLE API (For existing beat scripts)
# =============================================================================
func spawn_arrow(pos: Vector2, rot_deg: float = 0.0, scale_val: float = 1.0, col: Color = INK_MAIN) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	d.scale = Vector2.ONE * scale_val
	d.rotation_degrees = rot_deg
	d.stroke_list = Marks.make("arrow", col)
	add_child(d)
	active_doodles.append(d)
	d.reveal(0.55)
	return d

func spawn_circle(pos: Vector2, scale_val: float = 1.0, col: Color = INK_RED) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	d.scale = Vector2.ONE * scale_val
	d.stroke_list = Marks.make("circle", col)
	add_child(d)
	active_doodles.append(d)
	d.reveal(0.55)
	return d

func spawn_star(pos: Vector2, scale_val: float = 1.0, col: Color = INK_GOLD) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	d.scale = Vector2.ONE * scale_val
	d.stroke_list = Marks.make("star", col)
	add_child(d)
	active_doodles.append(d)
	d.reveal(0.55)
	return d

func spawn_handwritten_note(text_str: String, pos: Vector2, font_sz: int = 24, col: Color = INK_MAIN, tilt: float = -3.0, underline: bool = true) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	d.rotation_degrees = tilt
	add_child(d)
	active_doodles.append(d)

	add_handwritten_text(d, text_str, Vector2.ZERO, col, float(font_sz), 2.6)
	if underline:
		var width: float = preload("res://common/engine/illustration/DrawnLettering.gd").compose(text_str, font_sz, col).width
		for stroke in Marks.make("underline", col, 1):
			var moved := PackedVector2Array()
			for pt in stroke.pts:
				moved.append(Vector2(pt.x / 120.0 * width, float(font_sz) * 0.95 + pt.y * 0.5))
			stroke.pts = moved
			d.stroke_list.append(stroke)
	d.reveal(0.25)
	return d

func spawn_table_tennis_fx(pos: Vector2) -> AnimatedDoodle:
	return spawn_action_burst(pos, "SMASH!", INK_RED, 0.20)

func spawn_gaming_doodles(pos: Vector2) -> AnimatedDoodle:
	return spawn_digital_clock(pos, "ONE MORE MATCH!", 0.25)

func spawn_anime_mountain(pos: Vector2) -> AnimatedDoodle:
	return spawn_speech_bubble(pos, "PEAK FICTION!", INK_PURPLE, false, 0.25)

func spawn_gym_fx(pos: Vector2) -> AnimatedDoodle:
	return spawn_action_burst(pos, "DISCIPLINE!", INK_GOLD, 0.22)

func spawn_engineering_schematics(pos: Vector2) -> AnimatedDoodle:
	return spawn_math_formulas(pos, 0.28)

func spawn_multitask_icons(pos: Vector2, dur: float = 0.25) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	active_doodles.append(d)

	var icon_configs := [
		{"pos": Vector2(-155, 0), "label": "GYM", "col": INK_GOLD},
		{"pos": Vector2(-52, -22), "label": "GAMES", "col": INK_CYAN},
		{"pos": Vector2(52, -22), "label": "ANIME", "col": INK_PURPLE},
		{"pos": Vector2(155, 0), "label": "ENGINEERING", "col": INK_BLUE}
	]

	for cfg in icon_configs:
		var cp: Vector2 = cfg["pos"]
		var badge_col: Color = cfg["col"]
		# Circular hand-drawn paper badge
		var badge_pts := PackedVector2Array()
		for a in range(16):
			var ang := (float(a) / 16.0) * TAU
			var r := 26.0 + sin(float(a) * 3.1) * 1.2
			badge_pts.append(cp + Vector2(cos(ang) * r, sin(ang) * r))
		badge_pts.append(badge_pts[0])
		d.fills.append({"poly": badge_pts, "col": Color("#fffdf5")})
		d.stroke_list.append({"pts": badge_pts, "w": 2.2, "col": INK_MAIN})

	# 1. Gym (Dumbbell) at -155, 0
	var p_gym := Vector2(-155, 0)
	d.stroke_list.append({"pts": PackedVector2Array([p_gym + Vector2(-12, 0), p_gym + Vector2(12, 0)]), "w": 3.0, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([p_gym + Vector2(-12, -7), p_gym + Vector2(-12, 7)]), "w": 4.5, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([p_gym + Vector2(12, -7), p_gym + Vector2(12, 7)]), "w": 4.5, "col": INK_MAIN})

	# 2. Games (Controller D-pad) at -52, -22
	var p_game := Vector2(-52, -22)
	d.stroke_list.append({"pts": PackedVector2Array([p_game + Vector2(-9, 0), p_game + Vector2(9, 0)]), "w": 3.5, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([p_game + Vector2(0, -9), p_game + Vector2(0, 9)]), "w": 3.5, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([p_game + Vector2(7, -4), p_game + Vector2(7, -4)]), "w": 3.0, "col": INK_RED})
	d.stroke_list.append({"pts": PackedVector2Array([p_game + Vector2(11, 2), p_game + Vector2(11, 2)]), "w": 3.0, "col": INK_GOLD})

	# 3. Anime (Open Manga Book) at 52, -22
	var p_ani := Vector2(52, -22)
	var book_l := PackedVector2Array([p_ani + Vector2(0, 6), p_ani + Vector2(-11, 3), p_ani + Vector2(-11, -7), p_ani + Vector2(0, -4)])
	var book_r := PackedVector2Array([p_ani + Vector2(0, 6), p_ani + Vector2(11, 3), p_ani + Vector2(11, -7), p_ani + Vector2(0, -4)])
	d.stroke_list.append({"pts": book_l, "w": 2.0, "col": INK_MAIN})
	d.stroke_list.append({"pts": book_r, "w": 2.0, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([p_ani + Vector2(0, -4), p_ani + Vector2(0, 7)]), "w": 2.2, "col": INK_MAIN})

	# 4. Engineering (Gear / Circuit) at 155, 0
	var p_eng := Vector2(155, 0)
	var gear_pts := PackedVector2Array()
	for g in range(12):
		var a1 := (float(g) / 12.0) * TAU
		var a2 := (float(g) + 0.5) / 12.0 * TAU
		gear_pts.append(p_eng + Vector2(cos(a1) * 11, sin(a1) * 11))
		gear_pts.append(p_eng + Vector2(cos(a2) * 7.5, sin(a2) * 7.5))
	gear_pts.append(gear_pts[0])
	d.stroke_list.append({"pts": gear_pts, "w": 2.0, "col": INK_MAIN})

	d.reveal(dur)
	return d

func spawn_potato_doodle(pos: Vector2) -> AnimatedDoodle:
	return spawn_potato_evolution_chart(pos, 0.35)
