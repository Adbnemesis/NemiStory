class_name HumanDoodles
extends Node2D

## HumanDoodles - Authentic Hand-Drawn Doodle & Handwriting Subsystem
## Generates organic, imperfect, calligraphic human annotations:
## - Overlapping multi-revolution emphasis circles (authentic pen overshoot)
## - Multi-stroke arrows (curved shaft + two rapid flick barbs)
## - Vector handwriting letterforms (stroke-by-stroke sequential reveal)
## - Wobbly editorial brackets and underlines
## - ZERO pencil cursors / tools (lines reveal organically along their paths)

const InkStroke = preload("res://nemi/characters/nemi/drawing/InkStroke.gd")

class HumanStrokeItem extends Node2D:
	var stroke_points_list: Array[PackedVector2Array] = []
	var stroke_widths: Array[float] = []
	var stroke_profiles: Array[int] = []
	var stroke_colors: Array[Color] = []
	var draw_progress: float = 0.0
	var is_active: bool = true
	var _tween: Tween

	func _draw() -> void:
		if draw_progress <= 0.001 or stroke_points_list.is_empty():
			return

		var total_strokes := stroke_points_list.size()
		var global_prog := draw_progress * float(total_strokes)

		for i in range(total_strokes):
			var pts := stroke_points_list[i]
			if pts.size() < 2:
				continue
			var stroke_prog := clampf(global_prog - float(i), 0.0, 1.0)
			if stroke_prog <= 0.001:
				continue

			var count := int(ceil(float(pts.size()) * stroke_prog))
			count = clampi(count, 2, pts.size())
			var drawn_pts := PackedVector2Array()
			for p_idx in range(count):
				drawn_pts.append(pts[p_idx])

			if drawn_pts.size() >= 2:
				var w: float = stroke_widths[i] if i < stroke_widths.size() else 2.5
				var prof: int = stroke_profiles[i] if i < stroke_profiles.size() else 1
				var col: Color = stroke_colors[i] if i < stroke_colors.size() else Color("#3e081e")
				var stroke := InkStroke.from_points(drawn_pts, w, prof, col)
				stroke.draw_to(self)

	func animate_draw(duration: float = 0.25) -> Signal:
		draw_progress = 0.0
		visible = true
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(self, "draw_progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.step_finished.connect(func(_idx): queue_redraw())
		_tween.finished.connect(queue_redraw)
		return _tween.finished

	func animate_erase(duration: float = 0.18) -> Signal:
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(self, "draw_progress", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		_tween.step_finished.connect(func(_idx): queue_redraw())
		_tween.finished.connect(func(): queue_free())
		return _tween.finished

func _ready() -> void:
	z_index = 32 # Above character and props

## Spawns an organic overlapping emphasis circle with authored A/B/C variants
func spawn_imperfect_circle(center: Vector2, radius: float = 38.0, duration: float = 0.26, ink_color: Color = Color("#3e081e"), variant: String = "A") -> Node2D:
	var item := HumanStrokeItem.new()
	item.position = center

	var pts := PackedVector2Array()
	var steps := 36
	var total_steps := int(float(steps) * 1.32)
	var rx := radius
	var ry := radius * 0.92
	var start_angle := -PI * 0.35
	var spiral_factor := 6.5

	match variant.to_upper():
		"B":
			# Starts at bottom-left, slightly wider oval, 1.38 revolutions
			start_angle = PI * 0.65
			total_steps = int(float(steps) * 1.38)
			rx = radius * 1.06
			ry = radius * 0.88
			spiral_factor = 8.5
		"C":
			# Quick energetic loop starting at 11 o'clock with swift flick
			start_angle = -PI * 0.45
			total_steps = int(float(steps) * 1.28)
			rx = radius * 0.95
			ry = radius * 1.02
			spiral_factor = 5.2
		_:
			pass

	for i in range(total_steps + 1):
		var t_norm := float(i) / float(steps)
		var angle := start_angle + t_norm * TAU
		var wobble := 1.0 + sin(angle * 2.8) * 0.045 + cos(angle * 4.2) * 0.02
		var spiral_expand := (float(i) / float(total_steps)) * spiral_factor
		var pt := Vector2(cos(angle) * (rx + spiral_expand) * wobble, sin(angle) * (ry + spiral_expand) * wobble)
		pts.append(pt)

	item.stroke_points_list.append(pts)
	item.stroke_widths.append(2.6)
	item.stroke_profiles.append(InkStroke.Profile.TAPER_START)
	item.stroke_colors.append(ink_color)

	add_child(item)
	item.animate_draw(duration)
	return item

## Spawns an authentic human arrow with authored A/B variants
func spawn_human_arrow(from_pos: Vector2, to_pos: Vector2, curve_bend: float = 18.0, duration: float = 0.24, ink_color: Color = Color("#3e081e"), variant: String = "A") -> Node2D:
	var item := HumanStrokeItem.new()
	item.position = from_pos

	var target := to_pos - from_pos
	var shaft_pts := PackedVector2Array()
	var steps := 20
	var perp := Vector2(-target.y, target.x).normalized() * curve_bend

	if variant.to_upper() == "B":
		# Energetic straight flick with slight mid-break
		for i in range(steps + 1):
			var t := float(i) / float(steps)
			var base_pt := Vector2.ZERO.lerp(target, t) + perp * (2.0 * t * (1.0 - t))
			shaft_pts.append(base_pt)
		var dir := target.normalized()
		var barb1_pts := PackedVector2Array([target, target - dir.rotated(deg_to_rad(32.0)) * 16.0])
		var barb2_pts := PackedVector2Array([target, target - dir.rotated(deg_to_rad(-22.0)) * 12.0]) # Asymmetric barb
		item.stroke_points_list = [shaft_pts, barb1_pts, barb2_pts]
	else:
		# Quadratic bezier curved shaft
		for i in range(steps + 1):
			var t := float(i) / float(steps)
			var base_pt := Vector2.ZERO.lerp(target, t) + perp * (4.0 * t * (1.0 - t))
			var micro_wobble := Vector2(sin(t * 12.0) * 0.8, cos(t * 10.0) * 0.8)
			shaft_pts.append(base_pt + micro_wobble)

		var dir := (shaft_pts[-1] - shaft_pts[-4]).normalized()
		var barb_len := 15.0
		var barb1_pts := PackedVector2Array([target, target - dir.rotated(deg_to_rad(28.0)) * barb_len + Vector2(-0.5, 0.5)])
		var barb2_pts := PackedVector2Array([target, target - dir.rotated(deg_to_rad(-26.0)) * (barb_len * 0.92) + Vector2(0.5, -0.5)])
		item.stroke_points_list = [shaft_pts, barb1_pts, barb2_pts]

	item.stroke_widths = [2.4, 2.2, 2.0]
	item.stroke_profiles = [InkStroke.Profile.TAPER_START, InkStroke.Profile.TAPER_END, InkStroke.Profile.TAPER_END]
	item.stroke_colors = [ink_color, ink_color, ink_color]

	add_child(item)
	item.animate_draw(duration)
	return item

## Spawns an editorial wobbly underline with authored A/B variants
func spawn_wobbly_underline(start_pos: Vector2, length: float = 110.0, duration: float = 0.20, ink_color: Color = Color("#3e081e"), variant: String = "A") -> Node2D:
	var item := HumanStrokeItem.new()
	item.position = start_pos

	var pts := PackedVector2Array()
	var steps := 18
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var x := t * length
		var y := sin(t * PI * 2.2) * 2.2 + t * 3.5
		if variant.to_upper() == "B":
			# Stepped energetic double flick
			y = cos(t * PI * 3.0) * 2.5 + (t * 2.0)
		pts.append(Vector2(x, y))

	item.stroke_points_list.append(pts)
	item.stroke_widths.append(2.6)
	item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
	item.stroke_colors.append(ink_color)

	if variant.to_upper() == "B":
		# Second quick underline stroke
		var pts2 := PackedVector2Array()
		for i in range(steps + 1):
			var t := float(i) / float(steps)
			pts2.append(Vector2(t * (length * 0.85) + 8.0, 5.0 + sin(t * PI * 2.0) * 1.5))
		item.stroke_points_list.append(pts2)
		item.stroke_widths.append(1.8)
		item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
		item.stroke_colors.append(ink_color)

	add_child(item)
	item.animate_draw(duration)
	return item

## Spawns hand-drawn comic reaction rays / burst
func spawn_emphasis_burst(center: Vector2, radius: float = 32.0, count: int = 5, duration: float = 0.20, ink_color: Color = Color("#3e081e")) -> Node2D:
	var item := HumanStrokeItem.new()
	item.position = center

	for i in range(count):
		var angle := float(i) * (TAU / float(count)) - PI * 0.5 + 0.12 * sin(float(i))
		var r1 := radius * (0.65 + sin(float(i) * 1.7) * 0.1)
		var r2 := radius * (1.15 + cos(float(i) * 2.1) * 0.15)
		var p1 := Vector2(cos(angle) * r1, sin(angle) * r1)
		var p2 := Vector2(cos(angle) * r2, sin(angle) * r2)
		item.stroke_points_list.append(PackedVector2Array([p1, p2]))
		item.stroke_widths.append(2.4)
		item.stroke_profiles.append(InkStroke.Profile.TAPER_END)
		item.stroke_colors.append(ink_color)

	add_child(item)
	item.animate_draw(duration)
	return item

static func _scale_pts(pts: PackedVector2Array, s: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(p * s)
	return out

## Spawns true vector stroke-by-stroke handwritten words (no typing font, real ink strokes!)
func spawn_handwritten_text(pos: Vector2, phrase: String, scale_val: float = 1.0, duration: float = 0.35, ink_color: Color = Color("#3e081e")) -> Node2D:
	var item := HumanStrokeItem.new()
	item.position = pos

	match phrase.to_upper():
		"7 VIEWS":
			# Stroke 1: "7" top bar & down diagonal
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([
				Vector2(0, -28), Vector2(24, -30), Vector2(10, 0)
			]), scale_val))
			item.stroke_widths.append(3.0 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.TAPER_END)
			item.stroke_colors.append(ink_color)

			# Stroke 2: "7" crossbar
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([
				Vector2(8, -14), Vector2(22, -14)
			]), scale_val))
			item.stroke_widths.append(2.2 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
			item.stroke_colors.append(ink_color)

			# Stroke 3: "v"
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([
				Vector2(32, -18), Vector2(38, 0), Vector2(44, -18)
			]), scale_val))
			item.stroke_widths.append(2.4 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
			item.stroke_colors.append(ink_color)

			# Stroke 4: "i" stem + dot
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([
				Vector2(50, -18), Vector2(51, 0)
			]), scale_val))
			item.stroke_widths.append(2.4 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.TAPER_END)
			item.stroke_colors.append(ink_color)
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([
				Vector2(50.5, -23), Vector2(51, -22)
			]), scale_val))
			item.stroke_widths.append(3.0 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.UNIFORM)
			item.stroke_colors.append(ink_color)

			# Stroke 5: "e"
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([
				Vector2(57, -10), Vector2(67, -10), Vector2(66, -18), Vector2(58, -18), Vector2(56, -9), Vector2(58, 0), Vector2(67, -2)
			]), scale_val))
			item.stroke_widths.append(2.4 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
			item.stroke_colors.append(ink_color)

			# Stroke 6: "w"
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([
				Vector2(72, -18), Vector2(76, 0), Vector2(81, -12), Vector2(86, 0), Vector2(91, -18)
			]), scale_val))
			item.stroke_widths.append(2.4 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
			item.stroke_colors.append(ink_color)

			# Stroke 7: "s"
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([
				Vector2(101, -16), Vector2(96, -18), Vector2(94, -12), Vector2(101, -7), Vector2(100, 0), Vector2(93, -1)
			]), scale_val))
			item.stroke_widths.append(2.4 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.TAPER_END)
			item.stroke_colors.append(ink_color)

		"TODO: DON'T PANIC", "DONT PANIC", "PANIC":
			# Hand-lettered sticky note phrase
			# "TODO:"
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(-35, -16), Vector2(-35, 0)]), scale_val)) # T stem
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(-42, -16), Vector2(-28, -16)]), scale_val)) # T bar
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(-24, -8), Vector2(-16, -16), Vector2(-8, -8), Vector2(-16, 0), Vector2(-24, -8)]), scale_val)) # O
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(-4, -16), Vector2(-4, 0), Vector2(4, -4), Vector2(4, -12), Vector2(-4, -16)]), scale_val)) # D
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(8, -8), Vector2(16, -16), Vector2(24, -8), Vector2(16, 0), Vector2(8, -8)]), scale_val)) # O
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(27, -12), Vector2(27, -11)]), scale_val)) # :
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(27, -4), Vector2(27, -3)]), scale_val))
			for _k in range(7):
				item.stroke_widths.append(2.0 * scale_val)
				item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
				item.stroke_colors.append(ink_color)

			# Underline
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(-44, 4), Vector2(32, 5)]), scale_val))
			item.stroke_widths.append(2.4 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
			item.stroke_colors.append(Color("#d9485e"))

		"WHAT?!", "WHAT":
			# "W"
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([
				Vector2(0, -28), Vector2(6, 0), Vector2(12, -18), Vector2(18, 0), Vector2(24, -28)
			]), scale_val))
			item.stroke_widths.append(2.8 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
			item.stroke_colors.append(ink_color)

			# "H" (2 vertical + bar)
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(32, -28), Vector2(33, 0)]), scale_val))
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(44, -28), Vector2(45, 0)]), scale_val))
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(33, -14), Vector2(44, -14)]), scale_val))
			for _k in range(3):
				item.stroke_widths.append(2.6 * scale_val)
				item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
				item.stroke_colors.append(ink_color)

			# "!"
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(56, -30), Vector2(57, -10)]), scale_val))
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(57, -4), Vector2(57, -2)]), scale_val))
			item.stroke_widths.append(3.2 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.TAPER_END)
			item.stroke_colors.append(ink_color)
			item.stroke_widths.append(3.5 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.UNIFORM)
			item.stroke_colors.append(ink_color)

			# "?"
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([
				Vector2(68, -26), Vector2(76, -30), Vector2(81, -22), Vector2(74, -14), Vector2(74, -9)
			]), scale_val))
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(74, -4), Vector2(74, -2)]), scale_val))
			item.stroke_widths.append(2.8 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
			item.stroke_colors.append(ink_color)
			item.stroke_widths.append(3.5 * scale_val)
			item.stroke_profiles.append(InkStroke.Profile.UNIFORM)
			item.stroke_colors.append(ink_color)

		_:
			# Generic expressive double exclamation "?!"
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([
				Vector2(0, -26), Vector2(8, -30), Vector2(14, -22), Vector2(7, -14), Vector2(7, -9)
			]), scale_val))
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(7, -4), Vector2(7, -2)]), scale_val))
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(20, -30), Vector2(21, -10)]), scale_val))
			item.stroke_points_list.append(_scale_pts(PackedVector2Array([Vector2(21, -4), Vector2(21, -2)]), scale_val))
			for _k in range(4):
				item.stroke_widths.append(2.8 * scale_val)
				item.stroke_profiles.append(InkStroke.Profile.TAPER_BOTH)
				item.stroke_colors.append(ink_color)

	add_child(item)
	item.animate_draw(duration)
	return item

## Clears all active doodles with animated erase transition
func clear_all(duration: float = 0.18) -> void:
	for child in get_children():
		if child.has_method("animate_erase"):
			child.call("animate_erase", duration)
		else:
			child.queue_free()

## High-level helper for drawing handwritten words
func draw_word(text: String, pos: Vector2, font_size: float = 32.0, duration: float = 0.35, color: Color = Color("#3e081e")) -> Node2D:
	var scale_val: float = font_size / 32.0
	return spawn_handwritten_text(pos, text, scale_val, duration, color)

## High-level helper for drawing organic emphasis circles
func draw_emphasis_circle(pos: Vector2, size: Vector2 = Vector2(80, 50), duration: float = 0.26, color: Color = Color("#3e081e")) -> Node2D:
	var radius: float = maxf(size.x, size.y) * 0.5
	return spawn_imperfect_circle(pos, radius, duration, color)
