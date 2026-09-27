class_name Ep06Doodles
extends Node2D

## Ep06Doodles - Master Hand-Authored Storytime Doodles & Lettering
## 100% Hand-drawn vector visual language.
## ZERO digital system fonts. ZERO geometric / math shapes. ZERO generic UI cards.
## All doodles & lettering drawn via organic pen-and-ink stroke paths (#2e1822 DNA).

const INK_MAIN: Color = Color("#2e1822")
const INK_SOFT: Color = Color("#6b5763")
const INK_RED: Color = Color("#d63031")
const INK_GOLD: Color = Color("#d35400") # Warm organic amber
const INK_BLUE: Color = Color("#0984e3")
const INK_MINT: Color = Color("#009470") # Deep forest mint

# =============================================================================
# ANIMATED DOODLE CONTAINER
# =============================================================================
class AnimatedDoodle extends Node2D:
	var stroke_list: Array[Dictionary] = [] # {"pts": PackedVector2Array, "w": float, "col": Color}
	var fills: Array[Dictionary] = []       # {"poly": PackedVector2Array, "col": Color}
	var progress: float = 0.0
	var _tween: Tween

	func _draw() -> void:
		if progress <= 0.001:
			return

		# 1. Soft paper fills (fade in smoothly)
		if progress > 0.15:
			var fill_alpha := clampf((progress - 0.15) / 0.45, 0.0, 1.0)
			for f in fills:
				var f_col: Color = f["col"]
				f_col.a *= fill_alpha
				draw_colored_polygon(f["poly"], f_col)

		# 2. Sequential ink strokes
		var total_strokes := stroke_list.size()
		if total_strokes == 0:
			return

		var scaled_prog := progress * float(total_strokes)
		for i in range(total_strokes):
			var s = stroke_list[i]
			var pts: PackedVector2Array = s["pts"]
			if pts.size() < 2:
				continue
			var stroke_prog := clampf(scaled_prog - float(i), 0.0, 1.0)
			if stroke_prog <= 0.001:
				continue
			var count := int(ceil(float(pts.size()) * stroke_prog))
			count = clampi(count, 2, pts.size())
			var drawn_pts := PackedVector2Array()
			for p in range(count):
				drawn_pts.append(pts[p])
			if drawn_pts.size() >= 2:
				draw_polyline(drawn_pts, s["col"], s["w"], true)
				# Soft rounded ink caps
				draw_circle(drawn_pts[0], s["w"] * 0.48, s["col"])
				draw_circle(drawn_pts[drawn_pts.size() - 1], s["w"] * 0.48, s["col"])

	func _process(_delta: float) -> void:
		if _tween and _tween.is_valid() and _tween.is_running():
			queue_redraw()

	func reveal(duration: float = 0.28) -> Signal:
		progress = 0.0
		visible = true
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(self, "progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.finished.connect(queue_redraw)
		return _tween.finished

	func dismiss(duration: float = 0.18) -> Signal:
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(self, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.finished.connect(func(): queue_free())
		return _tween.finished


	func auto_dismiss(delay: float, duration: float = 0.2) -> AnimatedDoodle:
		var t := create_tween()
		t.tween_interval(delay)
		t.tween_callback(func(): dismiss(duration))
		return self

func _ready() -> void:
	z_index = 25

# =============================================================================
# HANDWRITTEN STROKE LETTERING ENGINE
# =============================================================================
# Converts any text string into organic, hand-drawn vector stroke segments.
# Features:
# - Uneven natural baseline
# - Organic stroke overshoot & slight wobbles
# - Variable letter spacing & tilt
# - 100% vector stroke rendering (zero digital fonts)
# =============================================================================

static func _get_glyph_strokes(ch: String, w: float, h: float) -> Array[PackedVector2Array]:
	var strokes: Array[PackedVector2Array] = []
	match ch.to_upper():
		"A":
			strokes.append(PackedVector2Array([Vector2(w * 0.1, h * 0.98), Vector2(w * 0.5, h * 0.02), Vector2(w * 0.9, h * 0.98)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.22, h * 0.62), Vector2(w * 0.78, h * 0.62)]))
		"B":
			strokes.append(PackedVector2Array([Vector2(w * 0.15, h * 0.98), Vector2(w * 0.15, h * 0.02)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.15, h * 0.04), Vector2(w * 0.68, h * 0.04), Vector2(w * 0.88, h * 0.26), Vector2(w * 0.65, h * 0.48), Vector2(w * 0.15, h * 0.48)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.15, h * 0.48), Vector2(w * 0.72, h * 0.48), Vector2(w * 0.92, h * 0.72), Vector2(w * 0.68, h * 0.96), Vector2(w * 0.15, h * 0.96)]))
		"C":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.85, h * 0.18), Vector2(w * 0.55, h * 0.04),
				Vector2(w * 0.18, h * 0.25), Vector2(w * 0.14, h * 0.50),
				Vector2(w * 0.18, h * 0.75), Vector2(w * 0.55, h * 0.96),
				Vector2(w * 0.88, h * 0.82)
			]))
		"D":
			strokes.append(PackedVector2Array([Vector2(w * 0.18, h * 0.98), Vector2(w * 0.18, h * 0.02)]))
			strokes.append(PackedVector2Array([
				Vector2(w * 0.18, h * 0.04), Vector2(w * 0.58, h * 0.05),
				Vector2(w * 0.88, h * 0.28), Vector2(w * 0.88, h * 0.70),
				Vector2(w * 0.58, h * 0.95), Vector2(w * 0.18, h * 0.96)
			]))
		"E":
			strokes.append(PackedVector2Array([Vector2(w * 0.20, h * 0.98), Vector2(w * 0.20, h * 0.02)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.18, h * 0.05), Vector2(w * 0.85, h * 0.05)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.18, h * 0.50), Vector2(w * 0.70, h * 0.50)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.18, h * 0.95), Vector2(w * 0.85, h * 0.95)]))
		"F":
			strokes.append(PackedVector2Array([Vector2(w * 0.20, h * 0.98), Vector2(w * 0.20, h * 0.02)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.18, h * 0.05), Vector2(w * 0.85, h * 0.05)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.18, h * 0.50), Vector2(w * 0.68, h * 0.50)]))
		"G":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.85, h * 0.18), Vector2(w * 0.55, h * 0.04),
				Vector2(w * 0.18, h * 0.25), Vector2(w * 0.14, h * 0.50),
				Vector2(w * 0.18, h * 0.75), Vector2(w * 0.55, h * 0.96),
				Vector2(w * 0.88, h * 0.82), Vector2(w * 0.88, h * 0.52),
				Vector2(w * 0.52, h * 0.52)
			]))
		"H":
			strokes.append(PackedVector2Array([Vector2(w * 0.18, h * 0.98), Vector2(w * 0.18, h * 0.02)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.82, h * 0.98), Vector2(w * 0.82, h * 0.02)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.16, h * 0.50), Vector2(w * 0.84, h * 0.50)]))
		"I":
			strokes.append(PackedVector2Array([Vector2(w * 0.50, h * 0.98), Vector2(w * 0.50, h * 0.02)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.25, h * 0.04), Vector2(w * 0.75, h * 0.04)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.25, h * 0.96), Vector2(w * 0.75, h * 0.96)]))
		"J":
			strokes.append(PackedVector2Array([Vector2(w * 0.25, h * 0.04), Vector2(w * 0.85, h * 0.04)]))
			strokes.append(PackedVector2Array([
				Vector2(w * 0.65, h * 0.04), Vector2(w * 0.65, h * 0.75),
				Vector2(w * 0.50, h * 0.96), Vector2(w * 0.20, h * 0.85)
			]))
		"K":
			strokes.append(PackedVector2Array([Vector2(w * 0.20, h * 0.98), Vector2(w * 0.20, h * 0.02)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.85, h * 0.06), Vector2(w * 0.22, h * 0.52)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.32, h * 0.45), Vector2(w * 0.88, h * 0.96)]))
		"L":
			strokes.append(PackedVector2Array([Vector2(w * 0.22, h * 0.02), Vector2(w * 0.22, h * 0.96), Vector2(w * 0.85, h * 0.96)]))
		"M":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.12, h * 0.98), Vector2(w * 0.14, h * 0.02),
				Vector2(w * 0.50, h * 0.70), Vector2(w * 0.86, h * 0.02),
				Vector2(w * 0.88, h * 0.98)
			]))
		"N":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.16, h * 0.98), Vector2(w * 0.16, h * 0.02),
				Vector2(w * 0.84, h * 0.98), Vector2(w * 0.84, h * 0.02)
			]))
		"O":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.50, h * 0.04), Vector2(w * 0.18, h * 0.25),
				Vector2(w * 0.14, h * 0.52), Vector2(w * 0.22, h * 0.82),
				Vector2(w * 0.52, h * 0.96), Vector2(w * 0.82, h * 0.78),
				Vector2(w * 0.86, h * 0.48), Vector2(w * 0.78, h * 0.20),
				Vector2(w * 0.48, h * 0.03)
			]))
		"P":
			strokes.append(PackedVector2Array([Vector2(w * 0.18, h * 0.98), Vector2(w * 0.18, h * 0.02)]))
			strokes.append(PackedVector2Array([
				Vector2(w * 0.18, h * 0.04), Vector2(w * 0.65, h * 0.05),
				Vector2(w * 0.88, h * 0.26), Vector2(w * 0.65, h * 0.52),
				Vector2(w * 0.18, h * 0.52)
			]))
		"Q":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.50, h * 0.04), Vector2(w * 0.18, h * 0.25),
				Vector2(w * 0.14, h * 0.52), Vector2(w * 0.22, h * 0.82),
				Vector2(w * 0.52, h * 0.96), Vector2(w * 0.82, h * 0.78),
				Vector2(w * 0.86, h * 0.48), Vector2(w * 0.78, h * 0.20),
				Vector2(w * 0.48, h * 0.03)
			]))
			strokes.append(PackedVector2Array([Vector2(w * 0.55, h * 0.68), Vector2(w * 0.92, h * 1.05)]))
		"R":
			strokes.append(PackedVector2Array([Vector2(w * 0.18, h * 0.98), Vector2(w * 0.18, h * 0.02)]))
			strokes.append(PackedVector2Array([
				Vector2(w * 0.18, h * 0.04), Vector2(w * 0.65, h * 0.05),
				Vector2(w * 0.88, h * 0.26), Vector2(w * 0.65, h * 0.50),
				Vector2(w * 0.18, h * 0.50)
			]))
			strokes.append(PackedVector2Array([Vector2(w * 0.55, h * 0.48), Vector2(w * 0.88, h * 0.96)]))
		"S":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.82, h * 0.16), Vector2(w * 0.55, h * 0.04),
				Vector2(w * 0.22, h * 0.18), Vector2(w * 0.20, h * 0.38),
				Vector2(w * 0.52, h * 0.52), Vector2(w * 0.84, h * 0.66),
				Vector2(w * 0.80, h * 0.88), Vector2(w * 0.48, h * 0.96),
				Vector2(w * 0.16, h * 0.85)
			]))
		"T":
			strokes.append(PackedVector2Array([Vector2(w * 0.10, h * 0.05), Vector2(w * 0.90, h * 0.05)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.50, h * 0.04), Vector2(w * 0.50, h * 0.98)]))
		"U":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.18, h * 0.04), Vector2(w * 0.18, h * 0.72),
				Vector2(w * 0.35, h * 0.96), Vector2(w * 0.65, h * 0.96),
				Vector2(w * 0.82, h * 0.72), Vector2(w * 0.82, h * 0.04)
			]))
		"V":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.14, h * 0.04), Vector2(w * 0.50, h * 0.96), Vector2(w * 0.86, h * 0.04)
			]))
		"W":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.10, h * 0.04), Vector2(w * 0.30, h * 0.96),
				Vector2(w * 0.50, h * 0.35), Vector2(w * 0.70, h * 0.96),
				Vector2(w * 0.90, h * 0.04)
			]))
		"X":
			strokes.append(PackedVector2Array([Vector2(w * 0.15, h * 0.06), Vector2(w * 0.85, h * 0.94)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.85, h * 0.06), Vector2(w * 0.15, h * 0.94)]))
		"Y":
			strokes.append(PackedVector2Array([Vector2(w * 0.15, h * 0.05), Vector2(w * 0.50, h * 0.50)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.85, h * 0.05), Vector2(w * 0.50, h * 0.50), Vector2(w * 0.50, h * 0.98)]))
		"Z":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.15, h * 0.06), Vector2(w * 0.85, h * 0.06),
				Vector2(w * 0.18, h * 0.94), Vector2(w * 0.85, h * 0.94)
			]))
		"0":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.50, h * 0.04), Vector2(w * 0.20, h * 0.25),
				Vector2(w * 0.18, h * 0.52), Vector2(w * 0.24, h * 0.82),
				Vector2(w * 0.50, h * 0.96), Vector2(w * 0.80, h * 0.78),
				Vector2(w * 0.82, h * 0.48), Vector2(w * 0.76, h * 0.20),
				Vector2(w * 0.48, h * 0.03)
			]))
			strokes.append(PackedVector2Array([Vector2(w * 0.75, h * 0.20), Vector2(w * 0.25, h * 0.80)]))
		"1":
			strokes.append(PackedVector2Array([Vector2(w * 0.28, h * 0.28), Vector2(w * 0.52, h * 0.04), Vector2(w * 0.52, h * 0.96)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.25, h * 0.96), Vector2(w * 0.75, h * 0.96)]))
		"2":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.20, h * 0.25), Vector2(w * 0.35, h * 0.05),
				Vector2(w * 0.72, h * 0.06), Vector2(w * 0.85, h * 0.28),
				Vector2(w * 0.35, h * 0.70), Vector2(w * 0.18, h * 0.94),
				Vector2(w * 0.88, h * 0.94)
			]))
		"3":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.20, h * 0.06), Vector2(w * 0.82, h * 0.06),
				Vector2(w * 0.50, h * 0.45), Vector2(w * 0.78, h * 0.55),
				Vector2(w * 0.82, h * 0.78), Vector2(w * 0.50, h * 0.96),
				Vector2(w * 0.20, h * 0.88)
			]))
		"4":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.72, h * 0.04), Vector2(w * 0.18, h * 0.65),
				Vector2(w * 0.88, h * 0.65)
			]))
			strokes.append(PackedVector2Array([Vector2(w * 0.68, h * 0.30), Vector2(w * 0.68, h * 0.98)]))
		"5":
			strokes.append(PackedVector2Array([Vector2(w * 0.82, h * 0.06), Vector2(w * 0.22, h * 0.06), Vector2(w * 0.20, h * 0.46)]))
			strokes.append(PackedVector2Array([
				Vector2(w * 0.20, h * 0.46), Vector2(w * 0.68, h * 0.45),
				Vector2(w * 0.88, h * 0.66), Vector2(w * 0.72, h * 0.94),
				Vector2(w * 0.22, h * 0.94)
			]))
		"!":
			strokes.append(PackedVector2Array([Vector2(w * 0.50, h * 0.04), Vector2(w * 0.50, h * 0.68)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.50, h * 0.86), Vector2(w * 0.50, h * 0.96)]))
		"?":
			strokes.append(PackedVector2Array([
				Vector2(w * 0.20, h * 0.24), Vector2(w * 0.45, h * 0.04),
				Vector2(w * 0.80, h * 0.18), Vector2(w * 0.72, h * 0.42),
				Vector2(w * 0.48, h * 0.55), Vector2(w * 0.48, h * 0.70)
			]))
			strokes.append(PackedVector2Array([Vector2(w * 0.48, h * 0.86), Vector2(w * 0.48, h * 0.96)]))
		".":
			strokes.append(PackedVector2Array([Vector2(w * 0.45, h * 0.88), Vector2(w * 0.55, h * 0.94)]))
		":":
			strokes.append(PackedVector2Array([Vector2(w * 0.50, h * 0.32), Vector2(w * 0.50, h * 0.38)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.50, h * 0.82), Vector2(w * 0.50, h * 0.88)]))
		"-":
			strokes.append(PackedVector2Array([Vector2(w * 0.15, h * 0.50), Vector2(w * 0.85, h * 0.50)]))
		"+":
			strokes.append(PackedVector2Array([Vector2(w * 0.15, h * 0.50), Vector2(w * 0.85, h * 0.50)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.50, h * 0.18), Vector2(w * 0.50, h * 0.82)]))
		"%":
			strokes.append(PackedVector2Array([Vector2(w * 0.82, h * 0.12), Vector2(w * 0.18, h * 0.88)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.30, h * 0.22), Vector2(w * 0.30, h * 0.30)]))
			strokes.append(PackedVector2Array([Vector2(w * 0.70, h * 0.70), Vector2(w * 0.70, h * 0.78)]))
		"\'":
			strokes.append(PackedVector2Array([Vector2(w * 0.45, h * 0.05), Vector2(w * 0.55, h * 0.25)]))
		_:
			pass
	return strokes

## Adds hand-lettered text directly to a doodle as ink strokes!
static func add_handwritten_text(doodle: AnimatedDoodle, text: String, center_pos: Vector2, col: Color, font_h: float = 22.0, line_w: float = 2.4) -> void:
	if text.is_empty():
		return

	# Calculate layout
	var char_w := font_h * 0.65
	var space_w := font_h * 0.40
	var total_w := 0.0
	for ch in text:
		if ch == " ":
			total_w += space_w
		elif ch in ["I", "!", ".", ":", "\'"]:
			total_w += char_w * 0.5
		elif ch in ["M", "W", "%"]:
			total_w += char_w * 1.3
		else:
			total_w += char_w
		total_w += 2.0 # Kerning gap

	var cur_x := center_pos.x - total_w * 0.5
	var base_y := center_pos.y - font_h * 0.5

	for idx in range(text.length()):
		var ch := text[idx]
		var cur_char_w := char_w
		if ch == " ":
			cur_x += space_w
			continue
		elif ch in ["I", "!", ".", ":", "\'"]:
			cur_char_w = char_w * 0.5
		elif ch in ["M", "W", "%"]:
			cur_char_w = char_w * 1.3

		# Organic baseline wobble & slight tilt per character
		var wobble_y := sin(float(idx * 7) + cur_x * 0.05) * 1.8
		var glyph_h := font_h + cos(float(idx * 3)) * 1.2
		var raw_strokes := _get_glyph_strokes(ch, cur_char_w, glyph_h)

		for s in raw_strokes:
			var jittered := PackedVector2Array()
			for pt in s:
				jittered.append(Vector2(cur_x + pt.x, base_y + pt.y + wobble_y))
			doodle.stroke_list.append({"pts": jittered, "w": line_w, "col": col})

		cur_x += cur_char_w + 2.5

# =============================================================================
# DOODLE SPAWNERS (ALL HAND-AUTHORED STROKE PATHS)
# =============================================================================

## Beat 1: Question Marks & Magic Sparkles
func spawn_magic_sparks(pos: Vector2) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	d.stroke_list.append({"pts": _make_hand_star(Vector2(-35.0, -30.0), 16.0), "w": 2.4, "col": INK_GOLD})
	d.stroke_list.append({"pts": _make_hand_star(Vector2(45.0, -38.0), 13.0), "w": 2.0, "col": INK_GOLD})
	d.stroke_list.append({"pts": _make_hand_star(Vector2(8.0, -58.0), 19.0), "w": 2.6, "col": INK_GOLD})
	# Hand-drawn question mark
	_add_hand_question_mark(d, Vector2(25.0, -15.0), 28.0, INK_MAIN)
	d.reveal(0.28)
	return d

## Beat 2: Sudden Realization Idea Spark
func spawn_idea_spark(pos: Vector2) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	# Hand-drawn radiating idea burst
	for ang_deg in [-75, -45, -15, 15, 45, 75]:
		var rad := deg_to_rad(float(ang_deg) - 90.0)
		var p1 := Vector2(cos(rad) * 18.0, sin(rad) * 18.0)
		var p2 := Vector2(cos(rad) * (38.0 + sin(float(ang_deg)) * 6.0), sin(rad) * 44.0)
		d.stroke_list.append({"pts": PackedVector2Array([p1, p2]), "w": 2.8, "col": INK_GOLD})
	# Big hand-inked exclamation
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-1.0, -54.0), Vector2(1.0, -22.0)]), "w": 4.2, "col": INK_RED})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(0.0, -14.0), Vector2(0.0, -10.0)]), "w": 4.5, "col": INK_RED})
	add_handwritten_text(d, "WAIT...!", Vector2(0.0, 22.0), INK_MAIN, 22.0, 2.8)
	d.reveal(0.22)
	return d

## Beat 3: Red Ink Cross-out and "NOPE" stamp
func spawn_script_crossout(pos: Vector2) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	# Scratchy, aggressive hand cross-out lines
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-80.0, -12.0), Vector2(-10.0, 2.0), Vector2(85.0, 16.0)]), "w": 3.6, "col": INK_RED})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-82.0, 14.0), Vector2(5.0, -4.0), Vector2(80.0, -15.0)]), "w": 3.4, "col": INK_RED})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-65.0, 3.0), Vector2(70.0, -2.0)]), "w": 2.6, "col": INK_RED})
	add_handwritten_text(d, "TOO BORING!", Vector2(0.0, -26.0), INK_RED, 22.0, 2.8)
	d.reveal(0.20)
	return d

## Beat 4: Acoustic Sound Wave Rings & "VOICE = MASTER CLOCK"
func spawn_sound_wave_pulse(pos: Vector2) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	for r: float in [26.0, 48.0, 70.0]:
		var arc_pts := PackedVector2Array()
		for step in range(14):
			var ang: float = -PI * 0.38 + (float(step) / 13.0) * PI * 0.76
			var rad_jitter: float = r + sin(float(step * 2)) * 1.5
			arc_pts.append(Vector2(cos(ang) * rad_jitter, sin(ang) * rad_jitter))
		d.stroke_list.append({"pts": arc_pts, "w": 2.6, "col": INK_GOLD})
	add_handwritten_text(d, "MASTER CLOCK", Vector2(40.0, 40.0), INK_GOLD, 20.0, 2.6)
	d.reveal(0.25)
	return d

## Beat 5: Timeline Marker Indicator Arrow
func spawn_timeline_marker(pos: Vector2, tag: String, col: Color) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	# Hand-drawn downward arrow
	var arr := PackedVector2Array([
		Vector2(-18.0, -32.0), Vector2(-1.0, -8.0), Vector2(17.0, -34.0)
	])
	d.stroke_list.append({"pts": arr, "w": 3.4, "col": col})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(0.0, -42.0), Vector2(-0.5, -9.0)]), "w": 3.4, "col": col})
	add_handwritten_text(d, tag, Vector2(0.0, 18.0), col, 22.0, 2.8)
	d.reveal(0.20)
	return d

## Beat 6: Anime Sweat Drop & Awkward Silence Lines
func spawn_deadpan_sweat(pos: Vector2) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	var drop_pts := PackedVector2Array([
		Vector2(0.0, -18.0), Vector2(8.0, -6.0),
		Vector2(9.0, 6.0), Vector2(0.0, 16.0),
		Vector2(-9.0, 6.0), Vector2(-8.0, -6.0),
		Vector2(0.0, -18.0)
	])
	d.fills.append({"poly": drop_pts, "col": Color(0.7, 0.88, 1.0, 0.45)})
	d.stroke_list.append({"pts": drop_pts, "w": 2.6, "col": INK_BLUE})
	# Hand-inked awkward speed hatch marks
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-35.0, 22.0), Vector2(-14.0, 21.0)]), "w": 1.8, "col": INK_SOFT})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-38.0, 28.0), Vector2(-18.0, 27.5)]), "w": 1.8, "col": INK_SOFT})
	d.reveal(0.18)
	return d

## Beat 7: Keyframe Tracks Overwhelm & Wafting Soul
func spawn_keyframe_overwhelm(pos: Vector2) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	for y_off: float in [-28.0, -8.0, 12.0, 32.0]:
		var trk := PackedVector2Array([Vector2(-120.0, y_off), Vector2(120.0, y_off)])
		d.stroke_list.append({"pts": trk, "w": 1.4, "col": INK_SOFT})
		for kx: float in [-90.0, -50.0, -10.0, 30.0, 70.0]:
			d.stroke_list.append({"pts": _make_hand_star(Vector2(kx, y_off), 7.0), "w": 1.4, "col": INK_GOLD})
	# Wafting ghost soul curve
	var soul := PackedVector2Array([
		Vector2(0.0, 55.0), Vector2(16.0, 30.0),
		Vector2(-12.0, 8.0), Vector2(10.0, -14.0),
		Vector2(-2.0, -42.0)
	])
	d.stroke_list.append({"pts": soul, "w": 3.2, "col": Color(0.65, 0.78, 0.95, 0.9)})
	add_handwritten_text(d, "OH NO.", Vector2(0.0, -58.0), Color("#e74c3c"), 24.0, 3.0)
	d.reveal(0.28)
	return d

## Beat 8: Props & Doodles Art Showcase
func spawn_doodle_showcase(pos: Vector2) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	d.stroke_list.append({"pts": _make_hand_star(Vector2(-48.0, -22.0), 16.0), "w": 2.4, "col": INK_GOLD})
	d.stroke_list.append({"pts": _make_hand_star(Vector2(52.0, -26.0), 14.0), "w": 2.2, "col": INK_MINT})
	d.stroke_list.append({"pts": _make_hand_star(Vector2(2.0, 32.0), 17.0), "w": 2.5, "col": INK_RED})
	# Hand-drawn ink pen stroke
	var pen_pts := PackedVector2Array([
		Vector2(-22.0, 8.0), Vector2(24.0, -12.0)
	])
	d.stroke_list.append({"pts": pen_pts, "w": 3.6, "col": INK_MAIN})
	add_handwritten_text(d, "100% HAND-DRAWN", Vector2(0.0, -48.0), INK_MAIN, 20.0, 2.6)
	d.reveal(0.25)
	return d

## Beat 9: Cute Hand-Drawn Magnifier Focus on Stray Hair Pixel
func spawn_magnifier_focus(pos: Vector2) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	# 1. Warm hand-drawn magnifier glass ring with soft highlight
	var ring_pts := PackedVector2Array()
	var r := 48.0
	for step in range(32):
		var ang := float(step) / 31.0 * TAU
		var rad := r + sin(ang * 4.0) * 1.5
		ring_pts.append(Vector2(cos(ang) * rad, sin(ang) * rad))
	# Soft circular glass fill
	d.fills.append({"poly": ring_pts, "col": Color(1.0, 1.0, 1.0, 0.45)})
	d.stroke_list.append({"pts": ring_pts, "w": 3.4, "col": INK_MAIN})

	# Cute curved glass glare arc
	var glare_pts := PackedVector2Array()
	for step in range(10):
		var ang := -PI * 0.75 + float(step) / 9.0 * (PI * 0.45)
		glare_pts.append(Vector2(cos(ang) * (r - 7.0), sin(ang) * (r - 7.0)))
	d.stroke_list.append({"pts": glare_pts, "w": 2.2, "col": Color(1.0, 1.0, 1.0, 0.85)})

	# Wooden handle extending down-right
	var handle_pts := PackedVector2Array([
		Vector2(cos(PI * 0.25) * r, sin(PI * 0.25) * r),
		Vector2(cos(PI * 0.25) * (r + 42.0), sin(PI * 0.25) * (r + 42.0))
	])
	d.stroke_list.append({"pts": handle_pts, "w": 5.0, "col": Color("#8c6d58")})

	# Hand-drawn crosshairs focusing right on the center pixel
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-24.0, 0.0), Vector2(-8.0, 0.0)]), "w": 2.2, "col": INK_RED})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(8.0, 0.0), Vector2(24.0, 0.0)]), "w": 2.2, "col": INK_RED})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(0.0, -24.0), Vector2(0.0, -8.0)]), "w": 2.2, "col": INK_RED})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(0.0, 8.0), Vector2(0.0, 24.0)]), "w": 2.2, "col": INK_RED})

	# The single offending rogue pixel (small red square right at focal center!)
	var px_box := PackedVector2Array([
		Vector2(-4.0, -4.0), Vector2(4.0, -4.0), Vector2(4.0, 4.0), Vector2(-4.0, 4.0)
	])
	d.fills.append({"poly": px_box, "col": INK_RED})
	d.stroke_list.append({"pts": px_box, "w": 1.8, "col": INK_MAIN})

	# Comic pointer callout to the pixel
	add_handwritten_text(d, "1 PIXEL OFF!", Vector2(70.0, -32.0), INK_RED, 18.0, 2.4)
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(45.0, -20.0), Vector2(10.0, -5.0)]), "w": 2.0, "col": INK_RED})

	d.reveal(0.20)
	return d

func spawn_magnifier_no(pos: Vector2) -> AnimatedDoodle:
	return spawn_magnifier_focus(pos)


## Beat 10: Celebratory Golden Starbursts & "RENDER COMPLETE"
func spawn_render_complete(pos: Vector2) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	for s_idx in range(5):
		var offset := Vector2(float(s_idx - 2) * 55.0, -18.0 + float(abs(s_idx - 2)) * 8.0)
		d.stroke_list.append({"pts": _make_hand_star(offset, 16.0), "w": 2.4, "col": INK_GOLD})
	# Loose hand-drawn ribbon underline
	var banner := PackedVector2Array([
		Vector2(-130.0, 22.0), Vector2(-40.0, 25.0),
		Vector2(40.0, 21.0), Vector2(130.0, 24.0)
	])
	d.stroke_list.append({"pts": banner, "w": 3.0, "col": INK_MAIN})
	add_handwritten_text(d, "RENDER COMPLETE", Vector2(0.0, 56.0), INK_MAIN, 24.0, 3.2)
	d.reveal(0.28)
	return d

# =============================================================================
# GENERAL ANNOTATIONS (ALL ORGANIC HAND-INKED VISUALS)
# =============================================================================

## Organic Hand-Drawn Arrow (slight arc shaft + natural quick barb strokes)
func spawn_arrow(from_pos: Vector2, to_pos: Vector2, col: Color = INK_MAIN) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = from_pos
	add_child(d)
	var rel_to := to_pos - from_pos
	var dist := rel_to.length()
	var dir := rel_to.normalized()
	var normal := Vector2(-dir.y, dir.x)

	# Gentle curved shaft (not a laser beam!)
	var curve_pts := PackedVector2Array()
	var bow := clampf(dist * 0.08, 4.0, 16.0)
	for step in range(12):
		var t := float(step) / 11.0
		var pos_on_line := rel_to * t
		var sag := sin(t * PI) * bow
		curve_pts.append(pos_on_line + normal * sag)
	d.stroke_list.append({"pts": curve_pts, "w": 2.8, "col": col})

	# Natural asymmetrical barb flicks with slight overshoot
	var barb_len := 15.0
	var head1 := PackedVector2Array([
		rel_to - dir * barb_len + normal * 9.0,
		rel_to + dir * 1.5
	])
	var head2 := PackedVector2Array([
		rel_to - dir * (barb_len * 0.9) - normal * 8.5,
		rel_to + dir * 1.0
	])
	d.stroke_list.append({"pts": head1, "w": 2.8, "col": col})
	d.stroke_list.append({"pts": head2, "w": 2.8, "col": col})
	d.reveal(0.18)
	return d

## Organic Hand-Drawn Arrow with Hand-Lettered Label
func spawn_arrow_with_label(from_pos: Vector2, to_pos: Vector2, text: String, col: Color = INK_MAIN) -> AnimatedDoodle:
	var d := spawn_arrow(from_pos, to_pos, col)
	var mid := (to_pos - from_pos) * 0.5
	# Position label cleanly above the arc apex
	add_handwritten_text(d, text, mid + Vector2(0.0, -36.0), col, 18.0, 2.4)
	return d

## Organic Hand-Drawn Underline (expressive brush stroke with natural waviness)
func spawn_underline(pos: Vector2, length: float = 90.0, col: Color = INK_MAIN) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	var line_pts := PackedVector2Array()
	var half_len := length * 0.5
	for step in range(14):
		var t := float(step) / 13.0
		var lx := -half_len + t * length
		var ly := sin(t * PI * 2.0) * 1.8 - 0.5 * t
		line_pts.append(Vector2(lx, ly))
	d.stroke_list.append({"pts": line_pts, "w": 3.2, "col": col})
	d.reveal(0.16)
	return d

## Organic Hand-Drawn Circle Callout (1.12 turns with authentic hand overlap!)
func spawn_circle_callout(pos: Vector2, radius: float = 38.0, col: Color = INK_RED) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	var pts := PackedVector2Array()
	var total_steps := 28
	for step in range(total_steps):
		var t := float(step) / float(total_steps - 1)
		var ang := t * TAU * 1.12 # 112% sweep creates natural animator overlap
		var r := radius + sin(ang * 2.0) * (radius * 0.06) + (t * 2.0)
		pts.append(Vector2(cos(ang) * r, sin(ang) * (r * 0.88)))
	d.stroke_list.append({"pts": pts, "w": 2.8, "col": col})
	d.reveal(0.20)
	return d

## Organic Hand-Drawn Speech Balloon (NO RECTANGLES!)
## Features smooth wobbly hand-inked cloud/oval contour + curved tail pointing to Nemi
func spawn_speech_bubble(pos: Vector2, text: String, col: Color = INK_MAIN, flip_tail: bool = false) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	var bubble_w := 90.0
	var bubble_h := 36.0
	if text.length() > 8:
		bubble_w = float(text.length()) * 8.5 + 24.0

	# 1. Generate organic wobbly bubble perimeter
	var perimeter := PackedVector2Array()
	var num_pts := 26
	for i in range(num_pts):
		var t := float(i) / float(num_pts)
		var ang := t * TAU
		# Slight organic wobble
		var rx := bubble_w * (1.0 + sin(ang * 3.0) * 0.04)
		var ry := bubble_h * (1.0 + cos(ang * 4.0) * 0.05)
		perimeter.append(Vector2(cos(ang) * rx, sin(ang) * ry))

	# Tail attachment: points organically down toward Nemi
	var tail_root: Vector2
	var tail_tip: Vector2
	var tail_end: Vector2
	if flip_tail:
		# Tail on bottom-right, pointing down-right toward Nemi
		tail_root = Vector2(bubble_w * 0.32, bubble_h * 0.95)
		tail_tip = Vector2(bubble_w * 0.48, bubble_h * 1.65)
		tail_end = Vector2(bubble_w * 0.12, bubble_h * 0.98)
	else:
		# Tail on bottom-left, pointing down-left toward Nemi
		tail_root = Vector2(-bubble_w * 0.12, bubble_h * 0.98)
		tail_tip = Vector2(-bubble_w * 0.48, bubble_h * 1.65)
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

	# 2. Paper white fill
	d.fills.append({"poly": full_bubble, "col": Color("#fffef8")})

	# 3. Hand-inked outline
	d.stroke_list.append({"pts": full_bubble, "w": 2.8, "col": col})

	# 4. Hand-drawn text inside
	add_handwritten_text(d, text, Vector2(0.0, 2.0), col, 20.0, 2.6)

	d.reveal(0.20)
	return d

## Organic Hand-Drawn Stamp / Badge (Smooth rounded badge contour, subtle wobble, warm tinted paper fill)
func spawn_handwritten_stamp(pos: Vector2, text: String, col: Color = INK_RED, size: int = 24) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	d.rotation = deg_to_rad(-2.5) # Natural organic hand-stamped angle
	add_child(d)

	var text_len := text.length()
	var half_w := float(text_len) * 8.0 + 22.0
	var half_h := float(size) * 0.85 + 10.0
	var corner_r := minf(half_h * 0.45, 14.0)

	# Generate 32-point smooth rounded badge contour with organic hand wobble
	var badge_pts := PackedVector2Array()
	var corners := [
		Vector2(half_w - corner_r, -half_h + corner_r), # TR center
		Vector2(-half_w + corner_r, -half_h + corner_r), # TL center
		Vector2(-half_w + corner_r, half_h - corner_r),  # BL center
		Vector2(half_w - corner_r, half_h - corner_r)   # BR center
	]
	var corner_angles := [
		[-PI * 0.5, 0.0],
		[-PI, -PI * 0.5],
		[PI * 0.5, PI],
		[0.0, PI * 0.5]
	]

	# Build smooth perimeter around the 4 rounded corners in clockwise order (TL, TR, BR, BL)
	var order := [1, 0, 3, 2]
	var idx := 0
	for c_idx in order:
		var c_center: Vector2 = corners[c_idx]
		var a_start: float = corner_angles[c_idx][0]
		var a_end: float = corner_angles[c_idx][1]
		for s in range(8):
			var t := float(s) / 8.0
			var ang := lerpf(a_start, a_end, t)
			# Hand wobble sinusoidal micro-variation (never machine straight)
			var wobble := 1.0 + sin(float(idx) * 1.3) * 0.028
			var pt := c_center + Vector2(cos(ang), sin(ang)) * (corner_r * wobble)
			badge_pts.append(pt)
			idx += 1
	badge_pts.append(badge_pts[0])

	# Warm translucent tinted paper fill
	var fill_col := Color(col.r, col.g, col.b, 0.08)
	var paper_base := Color("#fffef8")
	d.fills.append({"poly": badge_pts, "col": paper_base.lerp(fill_col, 0.5)})

	# Hand-inked badge contour
	d.stroke_list.append({"pts": badge_pts, "w": 2.8, "col": col})

	# Hand-lettered text inside
	add_handwritten_text(d, text, Vector2(0.0, 1.5), col, float(size), 2.8)
	d.reveal(0.18)
	return d

## Question Burst (3 lively hand-drawn question marks)
func spawn_question_burst(pos: Vector2) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	_add_hand_question_mark(d, Vector2(-32.0, -18.0), 24.0, INK_GOLD)
	_add_hand_question_mark(d, Vector2(0.0, -38.0), 30.0, INK_GOLD)
	_add_hand_question_mark(d, Vector2(34.0, -20.0), 26.0, INK_GOLD)
	d.reveal(0.20)
	return d

## Exclamation Spikes (Punchy hand-drawn shock lines)
func spawn_exclamation_spikes(pos: Vector2, col: Color = INK_RED) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	for ang_deg in [-55, -28, 0, 28, 55]:
		var rad := deg_to_rad(float(ang_deg) - 90.0)
		var p1 := Vector2(cos(rad) * 22.0, sin(rad) * 22.0)
		var p2 := Vector2(cos(rad) * (50.0 + sin(float(ang_deg * 3)) * 6.0), sin(rad) * 54.0)
		d.stroke_list.append({"pts": PackedVector2Array([p1, p2]), "w": 3.0, "col": col})
	d.reveal(0.18)
	return d

## Check Mark with Optional Hand-Lettered Text
func spawn_check_mark(pos: Vector2, text: String = "", col: Color = INK_MINT) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	var check := PackedVector2Array([
		Vector2(-18.0, 2.0), Vector2(-4.0, 16.0), Vector2(24.0, -18.0)
	])
	d.stroke_list.append({"pts": check, "w": 4.0, "col": col})
	if not text.is_empty():
		add_handwritten_text(d, text, Vector2(40.0 + float(text.length()) * 4.5, 2.0), col, 20.0, 2.6)
	d.reveal(0.18)
	return d

## Sparkle / Star (Hand-drawn 4-point or 5-point sketch star)
func spawn_sparkle(pos: Vector2, rad: float = 24.0, col: Color = INK_GOLD) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)
	d.stroke_list.append({"pts": _make_hand_star(Vector2.ZERO, rad), "w": 2.6, "col": col})
	d.reveal(0.20)
	return d

# =============================================================================
# INTERNAL HAND-DRAWN PRIMITIVE BUILDERS
# =============================================================================

## Hand-drawn star with organic rays and slight asymmetry
static func _make_hand_star(center: Vector2, rad: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	# 4-point organic diamond star with curved inner arches
	var r_top := rad * 1.05
	var r_bot := rad * 0.95
	var r_right := rad * 0.85
	var r_left := rad * 0.82
	var r_in := rad * 0.28

	# Top point
	pts.append(center + Vector2(0.0, -r_top))
	pts.append(center + Vector2(r_in * 1.1, -r_in * 0.9))
	# Right point
	pts.append(center + Vector2(r_right, 0.0))
	pts.append(center + Vector2(r_in * 0.9, r_in * 1.1))
	# Bottom point
	pts.append(center + Vector2(0.0, r_bot))
	pts.append(center + Vector2(-r_in * 1.0, r_in * 0.9))
	# Left point
	pts.append(center + Vector2(-r_left, 0.0))
	pts.append(center + Vector2(-r_in * 0.9, -r_in * 1.0))
	pts.append(pts[0])
	return pts

## Adds a hand-drawn question mark to a doodle
static func _add_hand_question_mark(doodle: AnimatedDoodle, pos: Vector2, height: float, col: Color) -> void:
	var w := height * 0.55
	var q_pts := PackedVector2Array([
		pos + Vector2(-w * 0.35, -height * 0.35),
		pos + Vector2(0.0, -height * 0.52),
		pos + Vector2(w * 0.45, -height * 0.38),
		pos + Vector2(w * 0.30, -height * 0.12),
		pos + Vector2(-w * 0.05, 0.0),
		pos + Vector2(-w * 0.05, height * 0.18)
	])
	doodle.stroke_list.append({"pts": q_pts, "w": 2.8, "col": col})
	# Hand dot
	doodle.stroke_list.append({
		"pts": PackedVector2Array([pos + Vector2(-w * 0.05, height * 0.34), pos + Vector2(-w * 0.05, height * 0.40)]),
		"w": 3.4,
		"col": col
	})
