class_name Ep07Doodles
extends Node2D

## Ep07Doodles - Master Hand-Authored Storytime Doodles & Lettering
## Episode 07: "I GOT 0 MARKS IN MY EXAM"
##
## 100% Hand-drawn vector visual language.
## ZERO digital system fonts. ZERO geometric / math shapes. ZERO generic UI cards.
## All doodles & lettering drawn via organic pen-and-ink stroke paths (#2e1822 DNA).

const INK_MAIN: Color = Color("#2e1822")
const INK_SOFT: Color = Color("#6b5763")
const INK_RED: Color = Color("#d63031")
const INK_GOLD: Color = Color("#d35400")
const INK_BLUE: Color = Color("#0984e3")
const INK_MINT: Color = Color("#009470")

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
# 1. HAND-DRAWN LAPTOP & ONLINE CLASSES
# =============================================================================
func draw_online_laptop(pos: Vector2, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	var w := 160.0
	var h := 105.0

	# Laptop screen frame
	d.fills.append({
		"poly": PackedVector2Array([
			Vector2(-w * 0.5, -h), Vector2(w * 0.5, -h),
			Vector2(w * 0.5, -10.0), Vector2(-w * 0.5, -10.0)
		]),
		"col": Color(0.92, 0.95, 0.98, 0.9)
	})

	# Screen outline
	d.stroke_list.append({
		"pts": PackedVector2Array([
			Vector2(-w * 0.5, -10.0), Vector2(-w * 0.5, -h),
			Vector2(w * 0.5, -h), Vector2(w * 0.5, -10.0), Vector2(-w * 0.5, -10.0)
		]),
		"w": 3.2,
		"col": INK_MAIN
	})

	# Laptop base / keyboard slab
	d.stroke_list.append({
		"pts": PackedVector2Array([
			Vector2(-w * 0.65, 0.0), Vector2(w * 0.65, 0.0),
			Vector2(w * 0.55, 12.0), Vector2(-w * 0.55, 12.0), Vector2(-w * 0.65, 0.0)
		]),
		"w": 3.4,
		"col": INK_MAIN
	})

	# 4 little student boxes inside screen
	var box_w := 60.0
	var box_h := 36.0
	var offsets := [
		Vector2(-68.0, -92.0), Vector2(8.0, -92.0),
		Vector2(-68.0, -50.0), Vector2(8.0, -50.0)
	]
	for bpos in offsets:
		d.stroke_list.append({
			"pts": PackedVector2Array([
				bpos, bpos + Vector2(box_w, 0),
				bpos + Vector2(box_w, box_h), bpos + Vector2(0, box_h), bpos
			]),
			"w": 1.8,
			"col": INK_SOFT
		})
		# Little avatar doodle
		d.stroke_list.append({
			"pts": PackedVector2Array([
				bpos + Vector2(box_w * 0.5 - 6.0, box_h * 0.4),
				bpos + Vector2(box_w * 0.5 + 6.0, box_h * 0.4)
			]),
			"w": 2.2,
			"col": INK_BLUE
		})

	d.reveal(dur)
	return d

# =============================================================================
# 2. CHECKLIST ITEMS (Classes, Tests, Assignments, Everything)
# =============================================================================
func draw_checklist_step(pos: Vector2, label: String, dur: float = 0.25) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	# Checkbox square (organic)
	var box_pts := PackedVector2Array([
		Vector2(0, 0), Vector2(24, 2), Vector2(22, 26), Vector2(-2, 24), Vector2(0, 0)
	])
	d.stroke_list.append({"pts": box_pts, "w": 2.6, "col": INK_MAIN})

	# Green checkmark flick
	var check_pts := PackedVector2Array([
		Vector2(4, 12), Vector2(10, 20), Vector2(28, 4)
	])
	d.stroke_list.append({"pts": check_pts, "w": 3.4, "col": INK_MINT})

	# Underline and text indicator line
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(36, 16), Vector2(160, 16)]),
		"w": 2.8,
		"col": INK_MAIN
	})

	d.reveal(dur)
	return d

# =============================================================================
# 3. HANDWRITTEN "LATER" & DISMISSIVE ARROW
# =============================================================================
func draw_handwritten_later(pos: Vector2, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	# Cursive / organic lettering: "later"
	# 'l'
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(0, 24), Vector2(4, -18), Vector2(8, -20), Vector2(10, 22), Vector2(14, 24)]),
		"w": 3.2,
		"col": INK_MAIN
	})
	# 'a'
	d.stroke_list.append({
		"pts": PackedVector2Array([
			Vector2(26, 8), Vector2(18, 6), Vector2(14, 16), Vector2(18, 24),
			Vector2(26, 22), Vector2(26, 6), Vector2(28, 24)
		]),
		"w": 3.0,
		"col": INK_MAIN
	})
	# 't'
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(38, -12), Vector2(38, 22), Vector2(44, 24)]),
		"w": 3.2,
		"col": INK_MAIN
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(32, 2), Vector2(46, 2)]),
		"w": 2.6,
		"col": INK_MAIN
	})
	# 'e'
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(48, 14), Vector2(62, 12), Vector2(58, 6), Vector2(50, 10), Vector2(50, 20), Vector2(62, 22)]),
		"w": 3.0,
		"col": INK_MAIN
	})
	# 'r'
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(68, 24), Vector2(68, 6), Vector2(76, 4), Vector2(82, 8)]),
		"w": 3.0,
		"col": INK_MAIN
	})

	# Organic wavy underline
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-8, 34), Vector2(30, 32), Vector2(60, 36), Vector2(96, 32)]),
		"w": 2.8,
		"col": INK_GOLD
	})

	# Sweeping casual dismissive arrow pointing away
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(105, 24), Vector2(135, 14), Vector2(165, 4)]),
		"w": 3.0,
		"col": INK_GOLD
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(150, -6), Vector2(165, 4), Vector2(154, 16)]),
		"w": 3.0,
		"col": INK_GOLD
	})

	d.reveal(dur)
	return d

# =============================================================================
# 4. TERRIBLE PLAN DOODLE
# =============================================================================
func draw_terrible_plan(pos: Vector2, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	# Tiny organic box with "PLAN"
	var plan_box := PackedVector2Array([
		Vector2(-45, -25), Vector2(45, -28), Vector2(48, 25), Vector2(-42, 28), Vector2(-45, -25)
	])
	d.stroke_list.append({"pts": plan_box, "w": 3.0, "col": INK_MAIN})
	d.fills.append({"poly": plan_box, "col": Color(0.98, 0.96, 0.90, 0.95)})

	# "P L A N" hand strokes
	# P
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-32, 14), Vector2(-32, -14), Vector2(-20, -14), Vector2(-20, 0), Vector2(-32, 0)]), "w": 2.4, "col": INK_MAIN})
	# L
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-14, -14), Vector2(-14, 14), Vector2(-4, 14)]), "w": 2.4, "col": INK_MAIN})
	# A
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(0, 14), Vector2(6, -14), Vector2(12, 14)]), "w": 2.4, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(2, 2), Vector2(10, 2)]), "w": 2.0, "col": INK_MAIN})
	# N
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(18, 14), Vector2(18, -14), Vector2(30, 14), Vector2(30, -14)]), "w": 2.4, "col": INK_MAIN})

	# Big hand-drawn scribble arrow pointing to it with label: "terrible plan"
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(65, 45), Vector2(50, 20), Vector2(35, 10)]),
		"w": 2.8,
		"col": INK_RED
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(30, 24), Vector2(35, 10), Vector2(48, 8)]),
		"w": 2.8,
		"col": INK_RED
	})

	# Rough red underline
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-50, 36), Vector2(50, 34)]),
		"w": 3.0,
		"col": INK_RED
	})

	d.reveal(dur)
	return d

# =============================================================================
# 5. THE EMAIL NOTIFICATION
# =============================================================================
func draw_email_reveal(pos: Vector2, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	var w := 180.0
	var h := 110.0

	# Hand-drawn envelope outline with slight organic angle
	var env_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5), Vector2(w * 0.5, -h * 0.5 + 4.0),
		Vector2(w * 0.5 - 2.0, h * 0.5), Vector2(-w * 0.5 + 2.0, h * 0.5 - 2.0),
		Vector2(-w * 0.5, -h * 0.5)
	])
	d.fills.append({"poly": env_pts, "col": Color(0.98, 0.97, 0.94, 0.95)})
	d.stroke_list.append({"pts": env_pts, "w": 3.4, "col": INK_MAIN})

	# Envelope flap V
	d.stroke_list.append({
		"pts": PackedVector2Array([
			Vector2(-w * 0.5, -h * 0.5), Vector2(0.0, 10.0), Vector2(w * 0.5, -h * 0.5 + 4.0)
		]),
		"w": 3.0,
		"col": INK_MAIN
	})

	# Red urgent exclamation badge
	var badge_pos := Vector2(w * 0.5 - 6.0, -h * 0.5 - 6.0)
	d.stroke_list.append({
		"pts": PackedVector2Array([badge_pos + Vector2(0, -16), badge_pos + Vector2(0, -4)]),
		"w": 4.2,
		"col": INK_RED
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([badge_pos + Vector2(0, 4), badge_pos + Vector2(0, 7)]),
		"w": 4.2,
		"col": INK_RED
	})

	d.reveal(dur)
	return d

# =============================================================================
# 6. "ONLINE" CROSSED OUT -> "OFFLINE." REVEAL
# =============================================================================
func draw_online_to_offline(pos: Vector2, dur: float = 0.40) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	# 1. "ONLINE" in faded ink
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-90, -30), Vector2(-90, -60), Vector2(-70, -60), Vector2(-70, -30), Vector2(-90, -30)]),
		"w": 2.8,
		"col": INK_SOFT
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-60, -30), Vector2(-60, -60), Vector2(-42, -30), Vector2(-42, -60)]),
		"w": 2.8,
		"col": INK_SOFT
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-32, -60), Vector2(-32, -30), Vector2(-16, -30)]),
		"w": 2.8,
		"col": INK_SOFT
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-6, -60), Vector2(-6, -30)]),
		"w": 2.8,
		"col": INK_SOFT
	})

	# 2. Aggressive RED X scratch-out over ONLINE
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-105, -68), Vector2(10, -22)]),
		"w": 4.5,
		"col": INK_RED
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-105, -22), Vector2(10, -68)]),
		"w": 4.5,
		"col": INK_RED
	})

	# 3. Bold handwritten "OFFLINE." in deep black/red
	# 'O'
	d.stroke_list.append({
		"pts": PackedVector2Array([
			Vector2(-95, 10), Vector2(-70, 8), Vector2(-68, 48), Vector2(-95, 50), Vector2(-95, 10)
		]),
		"w": 4.2,
		"col": INK_MAIN
	})
	# 'F'
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-55, 50), Vector2(-55, 10), Vector2(-35, 10)]), "w": 4.2, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-55, 28), Vector2(-40, 28)]), "w": 3.6, "col": INK_MAIN})
	# 'F'
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-25, 50), Vector2(-25, 10), Vector2(-5, 10)]), "w": 4.2, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-25, 28), Vector2(-10, 28)]), "w": 3.6, "col": INK_MAIN})
	# 'L'
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(8, 10), Vector2(8, 50), Vector2(28, 50)]), "w": 4.2, "col": INK_MAIN})
	# 'I'
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(40, 10), Vector2(40, 50)]), "w": 4.2, "col": INK_MAIN})
	# 'N'
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(52, 50), Vector2(52, 10), Vector2(74, 50), Vector2(74, 10)]), "w": 4.2, "col": INK_MAIN})
	# 'E'
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(86, 50), Vector2(86, 10), Vector2(106, 10)]), "w": 4.2, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(86, 29), Vector2(102, 29)]), "w": 3.6, "col": INK_MAIN})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(86, 50), Vector2(106, 50)]), "w": 4.2, "col": INK_MAIN})
	# '.'
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(116, 46), Vector2(116, 50)]), "w": 5.0, "col": INK_RED})

	# Thick double red underline for emphasis
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-105, 62), Vector2(125, 60)]),
		"w": 4.0,
		"col": INK_RED
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-95, 70), Vector2(115, 68)]),
		"w": 3.0,
		"col": INK_RED
	})

	d.reveal(dur)
	return d

# =============================================================================
# 7. 2 AM CLOCK & EXHAUSTION
# =============================================================================
func draw_clock_2am(pos: Vector2, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	var r := 54.0

	# Clock face circle with slight overshoot loop
	var circle_pts := PackedVector2Array()
	for i in range(26):
		var a: float = float(i) * TAU / 24.0
		circle_pts.append(Vector2(cos(a), sin(a)) * (r + sin(a * 3.0) * 1.5))
	circle_pts.append(Vector2(r + 6.0, 4.0)) # overshoot!

	d.fills.append({
		"poly": circle_pts,
		"col": Color(0.98, 0.97, 0.93, 0.95)
	})
	d.stroke_list.append({"pts": circle_pts, "w": 3.8, "col": INK_MAIN})

	# 12 tick marks
	for i in range(12):
		var a: float = float(i) * TAU / 12.0
		var p1 := Vector2(cos(a), sin(a)) * (r - 4.0)
		var p2 := Vector2(cos(a), sin(a)) * (r - 10.0)
		d.stroke_list.append({"pts": PackedVector2Array([p1, p2]), "w": 2.0, "col": INK_SOFT})

	# Clock hands pointing exactly to 2:00 AM
	# Minute hand pointing straight up to 12
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2.ZERO, Vector2(0.0, -r * 0.75)]),
		"w": 3.2,
		"col": INK_MAIN
	})
	# Hour hand pointing to 2 o'clock (60 deg from top = -30 deg from right = -PI/6)
	var h_ang := -PI / 6.0
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2.ZERO, Vector2(cos(h_ang), sin(h_ang)) * (r * 0.48)]),
		"w": 4.2,
		"col": INK_RED
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(0, -2), Vector2(0, 2)]),
		"w": 5.0,
		"col": INK_MAIN
	})

	# Bold hand-drawn "2 AM" emphasis loop below
	var text_pos := Vector2(-42.0, r + 22.0)
	# "2"
	d.stroke_list.append({
		"pts": PackedVector2Array([
			text_pos + Vector2(0, 4), text_pos + Vector2(8, -8), text_pos + Vector2(18, -4),
			text_pos + Vector2(6, 12), text_pos + Vector2(22, 12)
		]),
		"w": 3.6,
		"col": INK_RED
	})
	# "A"
	d.stroke_list.append({
		"pts": PackedVector2Array([
			text_pos + Vector2(30, 12), text_pos + Vector2(40, -8), text_pos + Vector2(50, 12)
		]),
		"w": 3.6,
		"col": INK_RED
	})
	d.stroke_list.append({"pts": PackedVector2Array([text_pos + Vector2(34, 2), text_pos + Vector2(46, 2)]), "w": 2.8, "col": INK_RED})
	# "M"
	d.stroke_list.append({
		"pts": PackedVector2Array([
			text_pos + Vector2(58, 12), text_pos + Vector2(58, -8), text_pos + Vector2(68, 6),
			text_pos + Vector2(78, -8), text_pos + Vector2(78, 12)
		]),
		"w": 3.6,
		"col": INK_RED
	})

	# Rough circular loop around "2 AM"
	var loop_pts := PackedVector2Array()
	for i in range(20):
		var a: float = float(i) * TAU / 18.0
		loop_pts.append(text_pos + Vector2(40, 2) + Vector2(cos(a) * 55.0, sin(a) * 22.0))
	loop_pts.append(text_pos + Vector2(40, 2) + Vector2(58.0, 6.0))
	d.stroke_list.append({"pts": loop_pts, "w": 2.6, "col": INK_RED})

	d.reveal(dur)
	return d

# =============================================================================
# 8. VISUAL METAPHOR: BRAIN LEAVING THE BUILDING
# =============================================================================
func draw_brain_leaving(pos: Vector2, dur: float = 0.40) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	# 1. Door frame on right
	var door_pts := PackedVector2Array([
		Vector2(60, 40), Vector2(60, -70), Vector2(110, -70), Vector2(110, 40)
	])
	d.stroke_list.append({"pts": door_pts, "w": 3.2, "col": INK_MAIN})
	# Exit sign or arrow
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(70, -80), Vector2(100, -80)]),
		"w": 2.4,
		"col": INK_MINT
	})

	# 2. Cute tiny pink hand-drawn brain walking toward door
	var bx := 0.0
	var by := -15.0

	# Lobes outline
	var brain_pts := PackedVector2Array([
		Vector2(bx - 32, by), Vector2(bx - 28, by - 22), Vector2(bx - 12, by - 28),
		Vector2(bx + 8, by - 26), Vector2(bx + 26, by - 14), Vector2(bx + 28, by + 6),
		Vector2(bx + 14, by + 18), Vector2(bx - 8, by + 18), Vector2(bx - 26, by + 10),
		Vector2(bx - 32, by)
	])
	d.fills.append({"poly": brain_pts, "col": Color(0.96, 0.78, 0.82, 0.95)})
	d.stroke_list.append({"pts": brain_pts, "w": 3.2, "col": INK_MAIN})

	# Internal brain folds
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(bx - 16, by - 12), Vector2(bx - 6, by - 6), Vector2(bx + 10, by - 14)]),
		"w": 2.0,
		"col": Color("#c46a80")
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(bx - 12, by + 4), Vector2(bx + 4, by + 2), Vector2(bx + 18, by + 4)]),
		"w": 2.0,
		"col": Color("#c46a80")
	})

	# Tiny cute stick legs walking
	# Left leg back
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(bx - 10, by + 18), Vector2(bx - 16, by + 34), Vector2(bx - 24, by + 34)]),
		"w": 2.8,
		"col": INK_MAIN
	})
	# Right leg forward
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(bx + 10, by + 18), Vector2(bx + 20, by + 32), Vector2(bx + 28, by + 32)]),
		"w": 2.8,
		"col": INK_MAIN
	})

	# Little motion lines behind feet
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(bx - 35, by + 24), Vector2(bx - 45, by + 24)]), "w": 2.0, "col": INK_SOFT})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(bx - 32, by + 32), Vector2(bx - 42, by + 32)]), "w": 2.0, "col": INK_SOFT})

	d.reveal(dur)
	return d

# =============================================================================
# 9. HOPING MARKS: "10?", "5?", "pity marks"
# =============================================================================
func draw_hope_marks(pos: Vector2, text_opt: int, dur: float = 0.30) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	match text_opt:
		0: # "10?"
			d.stroke_list.append({"pts": PackedVector2Array([Vector2(-20, -18), Vector2(-20, 18)]), "w": 3.6, "col": INK_GOLD})
			d.stroke_list.append({"pts": PackedVector2Array([Vector2(-26, -10), Vector2(-20, -18)]), "w": 3.0, "col": INK_GOLD})
			# 0
			var z_pts := PackedVector2Array([
				Vector2(-6, -18), Vector2(10, -18), Vector2(10, 18), Vector2(-6, 18), Vector2(-6, -18)
			])
			d.stroke_list.append({"pts": z_pts, "w": 3.6, "col": INK_GOLD})
			# ?
			d.stroke_list.append({
				"pts": PackedVector2Array([Vector2(20, -12), Vector2(28, -18), Vector2(36, -12), Vector2(28, 4), Vector2(28, 10)]),
				"w": 3.2,
				"col": INK_GOLD
			})
			d.stroke_list.append({"pts": PackedVector2Array([Vector2(28, 16), Vector2(28, 19)]), "w": 3.6, "col": INK_GOLD})

		1: # "5?"
			d.stroke_list.append({
				"pts": PackedVector2Array([
					Vector2(6, -18), Vector2(-12, -18), Vector2(-12, -2), Vector2(4, 0), Vector2(6, 14), Vector2(-10, 18)
				]),
				"w": 3.6,
				"col": INK_GOLD
			})
			# ?
			d.stroke_list.append({
				"pts": PackedVector2Array([Vector2(18, -12), Vector2(26, -18), Vector2(34, -12), Vector2(26, 4), Vector2(26, 10)]),
				"w": 3.2,
				"col": INK_GOLD
			})
			d.stroke_list.append({"pts": PackedVector2Array([Vector2(26, 16), Vector2(26, 19)]), "w": 3.6, "col": INK_GOLD})

		2: # "pity marks"
			# Hand-drawn cute little banner with "pity marks"
			var pb := PackedVector2Array([
				Vector2(-60, -16), Vector2(60, -16), Vector2(55, 18), Vector2(-65, 18), Vector2(-60, -16)
			])
			d.stroke_list.append({"pts": pb, "w": 2.4, "col": INK_SOFT})
			d.stroke_list.append({
				"pts": PackedVector2Array([Vector2(-50, 0), Vector2(45, 0)]),
				"w": 2.6,
				"col": INK_SOFT
			})

	d.reveal(dur)
	return d

# =============================================================================
# 10. THE BIG ZERO PUNCHLINE (ZERO & 0 / 30)
# =============================================================================
func draw_big_zero_punchline(pos: Vector2, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	# 1. Giant hand-drawn "0"
	var o_pts := PackedVector2Array()
	var rx := 65.0
	var ry := 90.0
	for i in range(28):
		var a: float = float(i) * TAU / 24.0
		o_pts.append(Vector2(cos(a) * rx, sin(a) * ry))
	o_pts.append(Vector2(rx + 8.0, 6.0)) # Overshoot!

	d.fills.append({
		"poly": o_pts,
		"col": Color(0.98, 0.90, 0.90, 0.96)
	})
	d.stroke_list.append({"pts": o_pts, "w": 7.0, "col": INK_RED})

	# Giant red diagonal cross-slash through zero
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-rx * 0.7, -ry * 0.7), Vector2(rx * 0.7, ry * 0.7)]),
		"w": 5.0,
		"col": INK_RED
	})

	# 2. Hand-drawn "/ 30" beside it
	var slash_pts := PackedVector2Array([Vector2(85, 80), Vector2(115, -70)])
	d.stroke_list.append({"pts": slash_pts, "w": 5.0, "col": INK_MAIN})

	# '3'
	var p3 := PackedVector2Array([
		Vector2(125, -50), Vector2(150, -50), Vector2(138, -15),
		Vector2(154, 5), Vector2(125, 40)
	])
	d.stroke_list.append({"pts": p3, "w": 5.5, "col": INK_MAIN})

	# '0' in 30
	var zero30_pts := PackedVector2Array()
	for i in range(22):
		var a: float = float(i) * TAU / 20.0
		zero30_pts.append(Vector2(185, -5) + Vector2(cos(a) * 25.0, sin(a) * 45.0))
	d.stroke_list.append({"pts": zero30_pts, "w": 5.5, "col": INK_MAIN})

	# 3. Aggressive jagged double underline
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-95, 115), Vector2(0, 110), Vector2(120, 118), Vector2(230, 112)]),
		"w": 5.0,
		"col": INK_RED
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-80, 128), Vector2(215, 125)]),
		"w": 3.8,
		"col": INK_RED
	})

	# 4. Radiating shock accent flicks
	var flicks := [
		[Vector2(-110, -50), Vector2(-140, -70)],
		[Vector2(-115, 20), Vector2(-150, 25)],
		[Vector2(-80, -110), Vector2(-100, -145)],
		[Vector2(0, -120), Vector2(0, -155)],
		[Vector2(210, -80), Vector2(245, -110)],
		[Vector2(235, 10), Vector2(275, 15)]
	]
	for f in flicks:
		d.stroke_list.append({"pts": PackedVector2Array(f), "w": 3.5, "col": INK_RED})

	d.reveal(dur)
	return d

# =============================================================================
# 11. "FUTURE ME" OUTRO ANNOTATION
# =============================================================================
func draw_future_me_annotation(pos: Vector2, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	# Organic circular loop enclosing the thought
	var circle_pts := PackedVector2Array()
	for i in range(24):
		var a: float = float(i) * TAU / 22.0
		circle_pts.append(Vector2(cos(a) * 92.0, sin(a) * 36.0))
	circle_pts.append(Vector2(96.0, 5.0)) # Overshoot

	d.fills.append({"poly": circle_pts, "col": Color(0.98, 0.96, 0.92, 0.95)})
	d.stroke_list.append({"pts": circle_pts, "w": 3.2, "col": INK_GOLD})

	# Underline stroke
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-68, 14), Vector2(68, 14)]),
		"w": 2.4,
		"col": INK_GOLD
	})

	# Organic handwritten lettering
	add_handwritten_text(d, "FUTURE ME", Vector2(0, -6), INK_GOLD, 18.0, 2.4)

	# Cute little arrow pointing down to Nemi
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(0, 36), Vector2(0, 65)]),
		"w": 3.0,
		"col": INK_GOLD
	})
	d.stroke_list.append({
		"pts": PackedVector2Array([Vector2(-8, 52), Vector2(0, 65), Vector2(8, 52)]),
		"w": 3.0,
		"col": INK_GOLD
	})

	d.reveal(dur)
	return d

# =============================================================================
# 12. HANDWRITTEN LETTERING ENGINE & SPEECH BUBBLES
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

static func add_handwritten_text(doodle: AnimatedDoodle, text: String, center_pos: Vector2, col: Color, font_h: float = 22.0, line_w: float = 2.4) -> void:
	if text.is_empty():
		return

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
		total_w += 2.0

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

		var wobble_y := sin(float(idx * 7) + cur_x * 0.05) * 1.8
		var glyph_h := font_h + cos(float(idx * 3)) * 1.2
		var raw_strokes := _get_glyph_strokes(ch, cur_char_w, glyph_h)

		for s in raw_strokes:
			var jittered := PackedVector2Array()
			for pt in s:
				jittered.append(Vector2(cur_x + pt.x, base_y + pt.y + wobble_y))
			doodle.stroke_list.append({"pts": jittered, "w": line_w, "col": col})

		cur_x += cur_char_w + 2.5

func spawn_speech_bubble(pos: Vector2, text: String, col: Color = INK_MAIN, flip_tail: bool = false) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	add_child(d)

	var bubble_w := 90.0
	var bubble_h := 36.0
	if text.length() > 8:
		bubble_w = float(text.length()) * 8.5 + 24.0

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
		tail_tip = Vector2(bubble_w * 0.48, bubble_h * 1.65)
		tail_end = Vector2(bubble_w * 0.12, bubble_h * 0.98)
	else:
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

	d.fills.append({"poly": full_bubble, "col": Color("#fffef8")})
	d.stroke_list.append({"pts": full_bubble, "w": 2.8, "col": col})
	add_handwritten_text(d, text, Vector2(0.0, 2.0), col, 20.0, 2.6)

	d.reveal(0.20)
	return d
