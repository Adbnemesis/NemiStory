class_name Ep05LiveDoodles
extends Node2D

## Master Hand-Drawn Doodle & Prop Engine for Nemi Episode 05: "WHAT IS GOING ON WITH YOUTUBE?"
## Strictly complies with NEMI_ANIMATION_PRODUCTION_BIBLE.md:
## - 100% ORGANIC, AUTHORED HUMAN LINEWORK (zero ruler-straight vectors, zero CAD polygons).
## - ZERO PENCILS OR DRAWING TOOLS (doodles draw themselves into the scene via progressive ink reveal).
## - Multi-stroke organic draw-on with natural hesitations, varied curvature, and tapered terminals.
## - Uses authentic handwriting fonts (Patrick Hand / Caveat) via Ep05Doodles.get_handwriting_font().
## - Controlled variations across arrows, bubbles, stars, and underlines.

const INK_DARK: Color = Color("#2c1820")
const INK_RED: Color = Color("#d63031")
const INK_GOLD: Color = Color("#f39c12")
const INK_BLUE: Color = Color("#2980b9")
const PAPER_BG: Color = Color("#fffdf9")
const TAPE_COLOR: Color = Color(0.95, 0.92, 0.78, 0.85)

# -----------------------------------------------------------------------------
# GEOMETRY HELPERS: AUTHORED ORGANIC HAND-DRAWN STROKES (Delegates)
# -----------------------------------------------------------------------------

static func build_organic_path(base_pts: PackedVector2Array, wobble_amp: float = 2.2, seed_offset: float = 0.0) -> PackedVector2Array:
	return LiveDrawingProp.build_organic_path(base_pts, wobble_amp, seed_offset)

static func build_organic_box_paths(half: Vector2, wobble: float = 2.0, seed_val: float = 1.0) -> Array[PackedVector2Array]:
	return LiveDrawingProp.build_organic_box_paths(half, wobble, seed_val)

static func build_organic_loop(center: Vector2, radius: Vector2, wobble: float = 3.0, seed_val: float = 3.0) -> PackedVector2Array:
	return LiveDrawingProp.build_organic_loop(center, radius, wobble, seed_val)

static func build_organic_arrow_paths(start_pt: Vector2, end_pt: Vector2, curve_bend: float = 18.0) -> Array[PackedVector2Array]:
	return LiveDrawingProp.build_organic_arrow_paths(start_pt, end_pt, curve_bend)

# -----------------------------------------------------------------------------
# BASE CLASS: LiveDrawingProp (Pure Organic Ink Reveal — Zero Pencils)
# -----------------------------------------------------------------------------
class LiveDrawingProp extends Node2D:
	var progress: float = 0.0
	var fill_alpha: float = 0.0
	var _tween: Tween

	## Generates an organic, wobbly, hand-drawn polyline from a set of base keypoints
	static func build_organic_path(base_pts: PackedVector2Array, wobble_amp: float = 2.2, seed_offset: float = 0.0) -> PackedVector2Array:
		var out_pts := PackedVector2Array()
		if base_pts.size() < 2:
			return base_pts
		
		for i in range(base_pts.size() - 1):
			var p0 := base_pts[i]
			var p1 := base_pts[i + 1]
			var dist := p0.distance_to(p1)
			var steps := maxi(3, int(ceil(dist / 14.0)))
			var dir := (p1 - p0).normalized()
			var norm := Vector2(-dir.y, dir.x)
			
			for s in range(steps):
				var frac := float(s) / float(steps)
				var base_pos := p0.lerp(p1, frac)
				var s_val := float(i * 11 + s) + seed_offset
				var disp := (sin(s_val * 1.57) * 0.65 + cos(s_val * 3.14) * 0.35) * wobble_amp
				out_pts.append(base_pos + norm * disp)
				
		out_pts.append(base_pts[-1])
		return out_pts

	## Generates an organic closed rounded rectangle with slight hand-drawn asymmetry
	static func build_organic_box_paths(half: Vector2, wobble: float = 2.0, seed_val: float = 1.0) -> Array[PackedVector2Array]:
		# 4 distinct strokes with slight natural corner overshoots (just like human inking)
		var top := build_organic_path(PackedVector2Array([
			Vector2(-half.x - 3.0, -half.y + 1.0),
			Vector2(half.x + 4.0, -half.y - 1.0)
		]), wobble, seed_val)
		
		var right := build_organic_path(PackedVector2Array([
			Vector2(half.x + 1.0, -half.y - 3.0),
			Vector2(half.x - 1.0, half.y + 3.0)
		]), wobble, seed_val + 2.5)
		
		var bottom := build_organic_path(PackedVector2Array([
			Vector2(half.x + 3.0, half.y + 1.0),
			Vector2(-half.x - 4.0, half.y - 1.0)
		]), wobble, seed_val + 5.0)
		
		var left := build_organic_path(PackedVector2Array([
			Vector2(-half.x - 1.0, half.y + 3.0),
			Vector2(-half.x + 1.0, -half.y - 4.0)
		]), wobble, seed_val + 7.5)
		
		return [top, right, bottom, left]

	## Generates an organic hand-drawn loop/circle (imperfect oval with overlap)
	static func build_organic_loop(center: Vector2, radius: Vector2, wobble: float = 3.0, seed_val: float = 3.0) -> PackedVector2Array:
		var pts := PackedVector2Array()
		var steps := 32
		var total_ang := TAU + 0.35 # ~20 degree overlap at end
		for i in range(steps + 1):
			var frac := float(i) / float(steps)
			var ang := frac * total_ang - PI * 0.5 # Start at top
			var r_mod := 1.0 + (sin(ang * 2.0 + seed_val) * 0.05 + cos(ang * 3.0) * 0.04)
			var disp := sin(float(i) * 1.8 + seed_val) * wobble
			var pt := center + Vector2(cos(ang) * radius.x * r_mod, sin(ang) * radius.y * r_mod) + Vector2(disp * 0.5, disp)
			pts.append(pt)
		return pts

	## Generates an organic hand-drawn arrow (shaft curve + two curved barb wings)
	static func build_organic_arrow_paths(start_pt: Vector2, end_pt: Vector2, curve_bend: float = 18.0) -> Array[PackedVector2Array]:
		var mid := start_pt.lerp(end_pt, 0.5)
		var dir := (end_pt - start_pt).normalized()
		var norm := Vector2(-dir.y, dir.x)
		var control := mid + norm * curve_bend
		
		# Shaft curve
		var shaft_base := PackedVector2Array()
		for s in range(16):
			var t := float(s) / 15.0
			var pt := start_pt.bezier_interpolate(control, control, end_pt, t)
			shaft_base.append(pt)
		var shaft := build_organic_path(shaft_base, 1.8, 4.2)
		
		# Arrowhead barb 1 & 2
		var barb_len := 22.0
		var barb_ang1 := dir.rotated(PI * 0.82) * barb_len
		var barb_ang2 := dir.rotated(-PI * 0.80) * barb_len
		var barb1 := build_organic_path(PackedVector2Array([end_pt, end_pt + barb_ang1]), 1.5, 1.0)
		var barb2 := build_organic_path(PackedVector2Array([end_pt, end_pt + barb_ang2]), 1.5, 2.0)
		
		return [shaft, barb1, barb2]

	func _init() -> void:
		z_index = 5

	func start_live_draw(duration: float = 0.6, delay: float = 0.0) -> Signal:
		progress = 0.0
		fill_alpha = 0.0
		
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		if delay > 0.0:
			_tween.tween_interval(delay)
		
		_tween.tween_property(self, "progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_method(func(_v): queue_redraw(), 0.0, 1.0, duration)
		_tween.tween_property(self, "fill_alpha", 1.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_method(func(_v): queue_redraw(), 0.0, 1.0, 0.25)
		return _tween.finished

	func erase_away(duration: float = 0.25) -> Signal:
		var tw := create_tween().set_parallel(true)
		tw.tween_property(self, "modulate:a", 0.0, duration)
		tw.tween_property(self, "scale", scale * 0.92, duration)
		tw.chain().tween_callback(queue_free)
		return tw.finished

	## Draws an organic path progressively along its length
	func _draw_progressive_stroke(pts: PackedVector2Array, color: Color, width: float, prog: float) -> void:
		if pts.size() < 2 or prog <= 0.001:
			return
		if prog >= 1.0:
			draw_polyline(pts, color, width, true)
			return
			
		var total_len := 0.0
		var seg_lens: Array[float] = []
		for i in range(pts.size() - 1):
			var l := pts[i].distance_to(pts[i + 1])
			seg_lens.append(l)
			total_len += l
			
		var target_len := total_len * prog
		var cur_len := 0.0
		var drawn := PackedVector2Array([pts[0]])
		
		for i in range(seg_lens.size()):
			var sl := seg_lens[i]
			if cur_len + sl <= target_len:
				drawn.append(pts[i + 1])
				cur_len += sl
			else:
				var rem := target_len - cur_len
				var frac := rem / maxf(sl, 0.001)
				drawn.append(pts[i].lerp(pts[i + 1], frac))
				break
				
		if drawn.size() >= 2:
			draw_polyline(drawn, color, width, true)

# -----------------------------------------------------------------------------
# 1. LIVE STICKY NOTE ("TODO: DON'T PANIC" & "FROZE")
# -----------------------------------------------------------------------------
class LiveStickyNote extends LiveDrawingProp:
	var title_text: String = "TODO: DON'T PANIC"
	var note_color: Color = Color("#fef9e7")
	var size: Vector2 = Vector2(170, 95)
	var _box_strokes: Array[PackedVector2Array]
	var _poly_pts: PackedVector2Array
	
	func _init(p_text: String = "TODO: DON'T PANIC", p_size: Vector2 = Vector2(170, 95)) -> void:
		super._init()
		title_text = p_text
		size = p_size
		var half := size * 0.5
		_box_strokes = build_organic_box_paths(half, 2.0, 1.2)
		_poly_pts = PackedVector2Array([
			Vector2(-half.x, -half.y),
			Vector2(half.x, -half.y + 2.0),
			Vector2(half.x - 2.0, half.y),
			Vector2(-half.x + 1.0, half.y - 1.0)
		])

	func _draw() -> void:
		var half := size * 0.5
		
		# Paper background wash with soft shadow
		if fill_alpha > 0.01:
			var shadow_pts := PackedVector2Array()
			for pt in _poly_pts: shadow_pts.append(pt + Vector2(3, 4))
			draw_colored_polygon(shadow_pts, Color(0, 0, 0, 0.08 * fill_alpha))
			draw_colored_polygon(_poly_pts, Color(note_color.r, note_color.g, note_color.b, fill_alpha * 0.95))
			
			# Textured scotch tape
			var tape_rect := Rect2(-30, -half.y - 10, 60, 16)
			draw_rect(tape_rect, Color(TAPE_COLOR.r, TAPE_COLOR.g, TAPE_COLOR.b, fill_alpha * 0.85))
			draw_rect(tape_rect, Color(INK_DARK.r, INK_DARK.g, INK_DARK.b, fill_alpha * 0.25), false, 1.0)
		
		# 1. First 60% of progress: The 4 organic sides sketch in sequentially
		var box_prog := clampf(progress / 0.6, 0.0, 1.0)
		for i in range(_box_strokes.size()):
			var p_start := float(i) / 4.0
			var p_end := float(i + 1) / 4.0
			var stroke_prog := clampf((box_prog - p_start) / (p_end - p_start), 0.0, 1.0)
			_draw_progressive_stroke(_box_strokes[i], INK_DARK, 2.8, stroke_prog)
		
		# 2. Last 40% of progress: Handwritten text reveals
		if progress > 0.5:
			var txt_alpha := clampf((progress - 0.5) / 0.5, 0.0, 1.0)
			var font := Ep05Doodles.get_handwriting_font(false)
			var lines := title_text.split("\n")
			var line_h := 24.0
			var start_y := -half.y + 26.0
			for i in range(lines.size()):
				var l_text: String = lines[i]
				var chars_to_show := int(round(l_text.length() * txt_alpha))
				if chars_to_show > 0:
					var sub := l_text.substr(0, chars_to_show)
					var pos := Vector2(-half.x + 15, start_y + i * line_h)
					draw_string(font, pos, sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, INK_DARK)

# -----------------------------------------------------------------------------
# 2. LIVE EP04 RECAP CARD WITH LIVE RED CHECKMARK
# -----------------------------------------------------------------------------
class LiveRecapCard extends LiveDrawingProp:
	var checkmark_progress: float = 0.0
	var size := Vector2(230, 125)
	var _box_strokes: Array[PackedVector2Array]
	var _check_stroke: PackedVector2Array
	var _poly_pts: PackedVector2Array

	func _init() -> void:
		super._init()
		var half := size * 0.5
		_box_strokes = build_organic_box_paths(half, 2.2, 3.4)
		_poly_pts = PackedVector2Array([
			Vector2(-half.x, -half.y),
			Vector2(half.x, -half.y + 1),
			Vector2(half.x - 1, half.y),
			Vector2(-half.x + 1, half.y - 1)
		])
		
		# Organic curved checkmark path
		var check_base := PackedVector2Array([
			Vector2(-half.x + 28, -half.y + 56),
			Vector2(-half.x + 56, -half.y + 86),
			Vector2(half.x - 26, -half.y + 18)
		])
		_check_stroke = build_organic_path(check_base, 2.0, 5.7)

	func start_live_draw(duration: float = 0.8, delay: float = 0.0) -> Signal:
		progress = 0.0
		checkmark_progress = 0.0
		fill_alpha = 0.0
		
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		if delay > 0.0:
			_tween.tween_interval(delay)
			
		# Step 1: Draw paper card & text (0.0 -> 0.6)
		_tween.tween_property(self, "progress", 1.0, duration * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_property(self, "fill_alpha", 1.0, duration * 0.6)
		
		# Step 2: Red checkmark draws organically across the card (0.6 -> 1.0)
		_tween.tween_property(self, "checkmark_progress", 1.0, duration * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_method(func(_v): queue_redraw(), 0.0, 1.0, duration * 0.4)
		return _tween.finished

	func _draw() -> void:
		var half := size * 0.5
		
		if fill_alpha > 0.01:
			var shadow_pts := PackedVector2Array()
			for pt in _poly_pts: shadow_pts.append(pt + Vector2(3, 4))
			draw_colored_polygon(shadow_pts, Color(0, 0, 0, 0.08 * fill_alpha))
			draw_colored_polygon(_poly_pts, Color(PAPER_BG.r, PAPER_BG.g, PAPER_BG.b, fill_alpha * 0.96))
			
			var tape_rect := Rect2(-35, -half.y - 10, 70, 16)
			draw_rect(tape_rect, Color(TAPE_COLOR.r, TAPE_COLOR.g, TAPE_COLOR.b, fill_alpha * 0.85))
			draw_rect(tape_rect, Color(INK_DARK.r, INK_DARK.g, INK_DARK.b, fill_alpha * 0.25), false, 1.0)
		
		for stroke in _box_strokes:
			_draw_progressive_stroke(stroke, INK_DARK, 2.6, progress)
		
		if progress > 0.45:
			var txt_alpha := clampf((progress - 0.45) / 0.55, 0.0, 1.0)
			var col := Color(INK_DARK.r, INK_DARK.g, INK_DARK.b, txt_alpha)
			var font := Ep05Doodles.get_handwriting_font(false)
			draw_string(font, Vector2(-half.x + 18, -half.y + 32), "EP04 RECAP:", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, col)
			draw_string(font, Vector2(-half.x + 36, -half.y + 68), "7  VIEWS", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, col)
			draw_string(font, Vector2(-half.x + 18, -half.y + 102), "(3 from my phone)", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, col)
		
		if checkmark_progress > 0.01:
			_draw_progressive_stroke(_check_stroke, INK_RED, 4.4, checkmark_progress)

# -----------------------------------------------------------------------------
# 3. LIVE SUBSCRIBER COUNTER BOX
# -----------------------------------------------------------------------------
class LiveCounterBox extends LiveDrawingProp:
	var display_count: int = 1
	var target_count: int = 1
	var size := Vector2(250, 105)
	var _box_strokes: Array[PackedVector2Array]
	var _poly_pts: PackedVector2Array
	var _count_tween: Tween

	func _init() -> void:
		super._init()
		var half := size * 0.5
		_box_strokes = build_organic_box_paths(half, 2.0, 7.1)
		_poly_pts = PackedVector2Array([
			Vector2(-half.x, -half.y),
			Vector2(half.x, -half.y),
			Vector2(half.x, half.y),
			Vector2(-half.x, half.y)
		])

	func climb_to(count: int, climb_duration: float = 0.5) -> void:
		target_count = count
		if _count_tween and _count_tween.is_valid():
			_count_tween.kill()
		_count_tween = create_tween()
		_count_tween.tween_method(func(val: int):
			display_count = val
			queue_redraw()
		, display_count, target_count, climb_duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	func _draw() -> void:
		var half := size * 0.5
		
		if fill_alpha > 0.01:
			var shadow_pts := PackedVector2Array()
			for pt in _poly_pts: shadow_pts.append(pt + Vector2(3, 4))
			draw_colored_polygon(shadow_pts, Color(0, 0, 0, 0.08 * fill_alpha))
			draw_colored_polygon(_poly_pts, Color(PAPER_BG.r, PAPER_BG.g, PAPER_BG.b, fill_alpha * 0.97))
			
		for stroke in _box_strokes:
			_draw_progressive_stroke(stroke, INK_DARK, 2.8, progress)
		
		if progress > 0.4:
			var txt_alpha := clampf((progress - 0.4) / 0.6, 0.0, 1.0)
			var col := Color(INK_DARK.r, INK_DARK.g, INK_DARK.b, txt_alpha)
			var font := Ep05Doodles.get_handwriting_font(false)
			draw_string(font, Vector2(-60, -half.y + 32), "SUBSCRIBERS", HORIZONTAL_ALIGNMENT_CENTER, 120, 18, col)
			
			var count_str := str(display_count)
			var num_col := INK_DARK if display_count < 1000 else INK_RED
			draw_string(font, Vector2(-half.x, half.y - 18), count_str, HORIZONTAL_ALIGNMENT_CENTER, int(size.x), 46, num_col)

# -----------------------------------------------------------------------------
# 4. LIVE GIANT 1,000 MILESTONE BURST
# -----------------------------------------------------------------------------
class LiveGiant1000 extends LiveDrawingProp:
	var ray_progress: float = 0.0
	var _star_strokes: Array[PackedVector2Array] = []
	var _ray_strokes: Array[PackedVector2Array] = []

	func _init() -> void:
		super._init()
		# Build 14 radiating curved burst rays of varied lengths
		var num_rays := 14
		for i in range(num_rays):
			var ang := (i / float(num_rays)) * TAU + (sin(float(i)) * 0.08)
			var r_start := 160.0
			var r_len := 65.0 + sin(float(i) * 2.3) * 25.0
			var p1 := Vector2(cos(ang), sin(ang)) * r_start
			var p2 := Vector2(cos(ang), sin(ang)) * (r_start + r_len)
			var ray_path := build_organic_path(PackedVector2Array([p1, p2]), 2.2, float(i))
			_ray_strokes.append(ray_path)
			
		# Irregular hand-drawn sparkle stars
		var star_centers := [
			Vector2(-180, -90), Vector2(185, -80), Vector2(-195, 60), Vector2(190, 75)
		]
		for sc in star_centers:
			var pts := PackedVector2Array([
				sc + Vector2(0, -18), sc + Vector2(5, -5), sc + Vector2(20, 0),
				sc + Vector2(6, 6), sc + Vector2(0, 19), sc + Vector2(-5, 5),
				sc + Vector2(-19, 0), sc + Vector2(-5, -6), sc + Vector2(0, -18)
			])
			_star_strokes.append(build_organic_path(pts, 1.8, 2.0))

	func start_live_draw(duration: float = 0.7, delay: float = 0.0) -> Signal:
		progress = 0.0
		ray_progress = 0.0
		fill_alpha = 0.0
		
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		if delay > 0.0:
			_tween.tween_interval(delay)
			
		_tween.tween_property(self, "progress", 1.0, duration * 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_property(self, "fill_alpha", 1.0, duration * 0.7)
		_tween.tween_property(self, "ray_progress", 1.0, duration * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_method(func(_v): queue_redraw(), 0.0, 1.0, duration * 0.3)
		return _tween.finished

	func _draw() -> void:
		# Draw radiating celebration sunburst rays
		if ray_progress > 0.01:
			for r in _ray_strokes:
				_draw_progressive_stroke(r, Color(INK_GOLD.r, INK_GOLD.g, INK_GOLD.b, ray_progress * 0.85), 3.2, ray_progress)
			for s in _star_strokes:
				_draw_progressive_stroke(s, Color(INK_GOLD.r, INK_GOLD.g, INK_GOLD.b, ray_progress * 0.9), 2.2, ray_progress)
		
		# Giant 1,000 hand-lettered bold numbers
		var txt := "1,000"
		var font := Ep05Doodles.get_handwriting_font(false)
		var pos := Vector2(-160, 20)
		
		if progress > 0.01:
			# Shadow outline
			draw_string(font, pos + Vector2(3, 4), txt, HORIZONTAL_ALIGNMENT_CENTER, 320, 115, Color(0, 0, 0, 0.25 * fill_alpha))
			# Bold red fill
			draw_string(font, pos, txt, HORIZONTAL_ALIGNMENT_CENTER, 320, 115, INK_RED)
			
			if progress > 0.6:
				var banner_alpha := (progress - 0.6) / 0.4
				draw_string(font, Vector2(-170, 75), "SUBSCRIBERS!!", HORIZONTAL_ALIGNMENT_CENTER, 340, 34, Color(INK_GOLD.r, INK_GOLD.g, INK_GOLD.b, banner_alpha))

# -----------------------------------------------------------------------------
# 5. LIVE TINY CROWD METAPHOR (Cute Hand-Drawn Stick Figure Viewers)
# -----------------------------------------------------------------------------
class LiveTinyCrowd extends LiveDrawingProp:
	var num_people: int = 24
	var wave_time: float = 0.0
	var is_waving: bool = false
	var _wave_tween: Tween

	func start_live_draw(duration: float = 1.0, delay: float = 0.0) -> Signal:
		progress = 0.0
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		if delay > 0.0:
			_tween.tween_interval(delay)
		_tween.tween_property(self, "progress", 1.0, duration).set_trans(Tween.TRANS_LINEAR)
		_tween.parallel().tween_method(func(_v): queue_redraw(), 0.0, 1.0, duration)
		return _tween.finished

	func start_waving() -> void:
		is_waving = true
		if _wave_tween and _wave_tween.is_valid():
			_wave_tween.kill()
		_wave_tween = create_tween().set_loops()
		_wave_tween.tween_method(func(val: float):
			wave_time = val
			queue_redraw()
		, 0.0, TAU * 2.0, 2.0)

	func _draw() -> void:
		var start_x := -520.0
		var spacing := 46.0
		var visible_people := int(round(num_people * progress))
		
		for i in range(visible_people):
			var x := start_x + i * spacing
			var y_base := 0.0
			var head_y := y_base - 32.0
			
			# Hand-drawn head loop (slightly wobbly circle)
			var head_loop := build_organic_loop(Vector2(x, head_y), Vector2(7.0, 7.5), 1.2, float(i))
			draw_circle(Vector2(x, head_y), 7.0, PAPER_BG)
			draw_polyline(head_loop, INK_DARK, 2.2, true)
			
			# Curved spine
			var spine := build_organic_path(PackedVector2Array([
				Vector2(x, head_y + 7.0), Vector2(x + sin(float(i)) * 2.0, y_base - 10.0)
			]), 1.2, float(i))
			draw_polyline(spine, INK_DARK, 2.2, true)
			
			# Legs
			var leg_l := build_organic_path(PackedVector2Array([Vector2(x, y_base - 10), Vector2(x - 5, y_base)]), 1.0, float(i))
			var leg_r := build_organic_path(PackedVector2Array([Vector2(x, y_base - 10), Vector2(x + 5, y_base)]), 1.0, float(i + 1))
			draw_polyline(leg_l, INK_DARK, 2.0, true)
			draw_polyline(leg_r, INK_DARK, 2.0, true)
			
			# Waving arms
			var wave_offset := sin(wave_time * 4.0 + i * 0.6) * 10.0 if is_waving else 0.0
			var arm_l := build_organic_path(PackedVector2Array([
				Vector2(x, y_base - 22), Vector2(x - 11, y_base - 24 + wave_offset)
			]), 1.2, float(i))
			var arm_r := build_organic_path(PackedVector2Array([
				Vector2(x, y_base - 22), Vector2(x + 11, y_base - 24 - wave_offset)
			]), 1.2, float(i + 2))
			draw_polyline(arm_l, INK_DARK, 2.0, true)
			draw_polyline(arm_r, INK_DARK, 2.0, true)

# -----------------------------------------------------------------------------
# 6. LIVE COMMENT SPEECH BUBBLE
# -----------------------------------------------------------------------------
class LiveCommentBubble extends LiveDrawingProp:
	var comment_text: String = "SO PROUD OF YOU!!"
	var bubble_size: Vector2 = Vector2(210, 60)
	var tail_dir: Vector2 = Vector2(-20, 20)
	var _contour: PackedVector2Array
	var _poly_pts: PackedVector2Array

	func _init(p_text: String, p_size: Vector2 = Vector2(210, 60), p_tail: Vector2 = Vector2(-20, 20)) -> void:
		super._init()
		comment_text = p_text
		bubble_size = p_size
		tail_dir = p_tail
		var half := bubble_size * 0.5
		
		# Organic rounded speech bubble contour with curved tail hook
		var base_pts := PackedVector2Array([
			Vector2(-half.x + 8, -half.y),
			Vector2(half.x - 8, -half.y),
			Vector2(half.x, -half.y + 8),
			Vector2(half.x, half.y - 8),
			Vector2(half.x - 8, half.y),
			Vector2(-half.x + 34, half.y),
			Vector2(-half.x + 18, half.y + 18),
			Vector2(-half.x + 12, half.y),
			Vector2(-half.x + 8, half.y),
			Vector2(-half.x, half.y - 8),
			Vector2(-half.x, -half.y + 8),
			Vector2(-half.x + 8, -half.y)
		])
		_contour = build_organic_path(base_pts, 2.0, 4.3)
		_poly_pts = _contour

	func _draw() -> void:
		var half := bubble_size * 0.5
		
		if fill_alpha > 0.01:
			var shadow_pts := PackedVector2Array()
			for pt in _poly_pts: shadow_pts.append(pt + Vector2(2.5, 3.5))
			draw_colored_polygon(shadow_pts, Color(0, 0, 0, 0.07 * fill_alpha))
			draw_colored_polygon(_poly_pts, Color(PAPER_BG.r, PAPER_BG.g, PAPER_BG.b, fill_alpha * 0.98))
			
			draw_circle(Vector2(-half.x + 22, 0), 10.0, Color(INK_BLUE.r, INK_BLUE.g, INK_BLUE.b, fill_alpha * 0.18))
		
		_draw_progressive_stroke(_contour, INK_DARK, 2.6, progress)
		
		if progress > 0.4:
			var txt_alpha := clampf((progress - 0.4) / 0.6, 0.0, 1.0)
			var font := Ep05Doodles.get_handwriting_font(false)
			draw_string(font, Vector2(-half.x + 40, 6), comment_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(INK_DARK.r, INK_DARK.g, INK_DARK.b, txt_alpha))

# -----------------------------------------------------------------------------
# 7. LIVE HEART CARD ("WE LOVE YOUR WORK")
# -----------------------------------------------------------------------------
class LiveHeartCard extends LiveDrawingProp:
	var heart_progress: float = 0.0
	var size := Vector2(240, 110)
	var _box_strokes: Array[PackedVector2Array]
	var _heart_stroke: PackedVector2Array
	var _poly_pts: PackedVector2Array

	func _init() -> void:
		super._init()
		var half := size * 0.5
		_box_strokes = build_organic_box_paths(half, 2.2, 5.1)
		_poly_pts = PackedVector2Array([
			Vector2(-half.x, -half.y),
			Vector2(half.x, -half.y + 1),
			Vector2(half.x - 1, half.y),
			Vector2(-half.x + 1, half.y - 1)
		])
		
		# Hand-drawn organic heart contour
		var heart_pts := PackedVector2Array([
			Vector2(-half.x + 36, -6),
			Vector2(-half.x + 25, -22),
			Vector2(-half.x + 14, -14),
			Vector2(-half.x + 36, 16),
			Vector2(-half.x + 58, -14),
			Vector2(-half.x + 47, -22),
			Vector2(-half.x + 36, -6)
		])
		_heart_stroke = build_organic_path(heart_pts, 1.6, 2.2)

	func start_live_draw(duration: float = 0.8, delay: float = 0.0) -> Signal:
		progress = 0.0
		heart_progress = 0.0
		fill_alpha = 0.0
		
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		if delay > 0.0:
			_tween.tween_interval(delay)
			
		_tween.tween_property(self, "progress", 1.0, duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_property(self, "fill_alpha", 1.0, duration * 0.5)
		_tween.tween_property(self, "heart_progress", 1.0, duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_method(func(_v): queue_redraw(), 0.0, 1.0, duration * 0.5)
		return _tween.finished

	func _draw() -> void:
		var half := size * 0.5
		
		if fill_alpha > 0.01:
			var shadow_pts := PackedVector2Array()
			for pt in _poly_pts: shadow_pts.append(pt + Vector2(3, 4))
			draw_colored_polygon(shadow_pts, Color(0, 0, 0, 0.08 * fill_alpha))
			draw_colored_polygon(_poly_pts, Color(PAPER_BG.r, PAPER_BG.g, PAPER_BG.b, fill_alpha * 0.96))
			
			var tape_rect := Rect2(-30, -half.y - 10, 60, 16)
			draw_rect(tape_rect, Color(TAPE_COLOR.r, TAPE_COLOR.g, TAPE_COLOR.b, fill_alpha * 0.85))
		
		for stroke in _box_strokes:
			_draw_progressive_stroke(stroke, INK_DARK, 2.6, progress)
		
		if heart_progress > 0.01:
			_draw_progressive_stroke(_heart_stroke, INK_RED, 3.4, heart_progress)
		
		if progress > 0.5:
			var txt_alpha := clampf((progress - 0.5) / 0.5, 0.0, 1.0)
			var font := Ep05Doodles.get_handwriting_font(false)
			draw_string(font, Vector2(-half.x + 65, 8), "\"WE LOVE YOUR WORK!\"", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(INK_DARK.r, INK_DARK.g, INK_DARK.b, txt_alpha))

# -----------------------------------------------------------------------------
# 8. LIVE INSTAGRAM PHONE (250 FOLLOWERS)
# -----------------------------------------------------------------------------
class LiveInstagramPhone extends LiveDrawingProp:
	var size := Vector2(140, 200)
	var _phone_contour: PackedVector2Array
	var _poly_pts: PackedVector2Array

	func _init() -> void:
		super._init()
		var half := size * 0.5
		var base_pts := PackedVector2Array([
			Vector2(-half.x + 12, -half.y),
			Vector2(half.x - 12, -half.y),
			Vector2(half.x, -half.y + 12),
			Vector2(half.x, half.y - 12),
			Vector2(half.x - 12, half.y),
			Vector2(-half.x + 12, half.y),
			Vector2(-half.x, half.y - 12),
			Vector2(-half.x, -half.y + 12),
			Vector2(-half.x + 12, -half.y)
		])
		_phone_contour = build_organic_path(base_pts, 2.0, 8.4)
		_poly_pts = _phone_contour

	func _draw() -> void:
		var half := size * 0.5
		
		if fill_alpha > 0.01:
			var shadow_pts := PackedVector2Array()
			for pt in _poly_pts: shadow_pts.append(pt + Vector2(3, 4))
			draw_colored_polygon(shadow_pts, Color(0, 0, 0, 0.09 * fill_alpha))
			draw_colored_polygon(_poly_pts, Color(PAPER_BG.r, PAPER_BG.g, PAPER_BG.b, fill_alpha * 0.98))
			
			# Screen area
			var screen_rect := Rect2(-half.x + 10, -half.y + 15, size.x - 20, size.y - 40)
			draw_rect(screen_rect, Color("#faf4fc", fill_alpha * 0.9))
			draw_rect(screen_rect, Color(INK_DARK.r, INK_DARK.g, INK_DARK.b, fill_alpha * 0.3), false, 1.5)
			
		_draw_progressive_stroke(_phone_contour, INK_DARK, 2.8, progress)
		
		if progress > 0.5:
			var txt_alpha := clampf((progress - 0.5) / 0.5, 0.0, 1.0)
			var col := Color(INK_DARK.r, INK_DARK.g, INK_DARK.b, txt_alpha)
			var font := Ep05Doodles.get_handwriting_font(false)
			
			# Hand-drawn camera glyph
			var cam_loop := build_organic_loop(Vector2(0, -21), Vector2(12, 12), 1.2, 3.0)
			draw_polyline(cam_loop, Color("#e1306c", txt_alpha), 2.5, true)
			
			draw_string(font, Vector2(-half.x, 34), "250", HORIZONTAL_ALIGNMENT_CENTER, int(size.x), 32, col)
			draw_string(font, Vector2(-half.x, 64), "FOLLOWERS", HORIZONTAL_ALIGNMENT_CENTER, int(size.x), 17, col)

# -----------------------------------------------------------------------------
# 9. LIVE PHYSICAL CARD ("THANK YOU <3" / "NEW VIDEO SOON!")
# -----------------------------------------------------------------------------
class LivePhysicalCard extends LiveDrawingProp:
	var card_text: String = "THANK YOU <3"
	var checkmark: bool = true
	var check_prog: float = 0.0
	var size := Vector2(210, 115)
	var _box_strokes: Array[PackedVector2Array]
	var _check_stroke: PackedVector2Array
	var _poly_pts: PackedVector2Array

	func _init(p_text: String = "THANK YOU <3", p_check: bool = true) -> void:
		super._init()
		card_text = p_text
		checkmark = p_check
		var half := size * 0.5
		_box_strokes = build_organic_box_paths(half, 2.0, 9.2)
		_poly_pts = PackedVector2Array([
			Vector2(-half.x, -half.y),
			Vector2(half.x, -half.y + 1),
			Vector2(half.x - 1, half.y),
			Vector2(-half.x + 1, half.y - 1)
		])
		
		var chk_base := PackedVector2Array([
			Vector2(-half.x + 50, 20),
			Vector2(-half.x + 80, 45),
			Vector2(half.x - 50, -5)
		])
		_check_stroke = build_organic_path(chk_base, 2.0, 4.1)

	func start_live_draw(duration: float = 0.7, delay: float = 0.0) -> Signal:
		progress = 0.0
		check_prog = 0.0
		fill_alpha = 0.0
		
		if _tween and _tween.is_valid():
			_tween.kill()
		_tween = create_tween()
		if delay > 0.0:
			_tween.tween_interval(delay)
		_tween.tween_property(self, "progress", 1.0, duration * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_property(self, "fill_alpha", 1.0, duration * 0.6)
		if checkmark:
			_tween.tween_property(self, "check_prog", 1.0, duration * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_tween.parallel().tween_method(func(_v): queue_redraw(), 0.0, 1.0, duration * 0.4)
		return _tween.finished

	func _draw() -> void:
		var half := size * 0.5
		
		if fill_alpha > 0.01:
			var shadow_pts := PackedVector2Array()
			for pt in _poly_pts: shadow_pts.append(pt + Vector2(3, 4))
			draw_colored_polygon(shadow_pts, Color(0, 0, 0, 0.08 * fill_alpha))
			draw_colored_polygon(_poly_pts, Color(PAPER_BG.r, PAPER_BG.g, PAPER_BG.b, fill_alpha * 0.96))
			
			var tape_rect := Rect2(-30, -half.y - 10, 60, 16)
			draw_rect(tape_rect, Color(TAPE_COLOR.r, TAPE_COLOR.g, TAPE_COLOR.b, fill_alpha * 0.85))
		
		for stroke in _box_strokes:
			_draw_progressive_stroke(stroke, INK_DARK, 2.6, progress)
		
		if progress > 0.4:
			var txt_alpha := clampf((progress - 0.4) / 0.6, 0.0, 1.0)
			var col := Color(INK_DARK.r, INK_DARK.g, INK_DARK.b, txt_alpha)
			var font := Ep05Doodles.get_handwriting_font(false)
			draw_string(font, Vector2(-half.x, 8), card_text, HORIZONTAL_ALIGNMENT_CENTER, int(size.x), 24, col)
		
		if checkmark and check_prog > 0.01:
			_draw_progressive_stroke(_check_stroke, INK_RED, 4.2, check_prog)

# -----------------------------------------------------------------------------
# 10. LIVE ORGANIC ARROW (With Controlled Variation)
# -----------------------------------------------------------------------------
class LiveOrganicArrow extends LiveDrawingProp:
	var from_pos: Vector2
	var to_pos: Vector2
	var arrow_color: Color
	var _arrow_paths: Array[PackedVector2Array]

	func _init(p_from: Vector2, p_to: Vector2, p_color: Color = Color("#d63031"), p_bend: float = 18.0) -> void:
		super._init()
		from_pos = p_from
		to_pos = p_to
		arrow_color = p_color
		_arrow_paths = build_organic_arrow_paths(from_pos, to_pos, p_bend)

	func _draw() -> void:
		if _arrow_paths.size() >= 3:
			# Shaft draws first (0.0 -> 0.7)
			var shaft_prog := clampf(progress / 0.7, 0.0, 1.0)
			_draw_progressive_stroke(_arrow_paths[0], arrow_color, 3.4, shaft_prog)
			
			# Barbs draw second (0.7 -> 1.0)
			if progress > 0.7:
				var barb_prog := clampf((progress - 0.7) / 0.3, 0.0, 1.0)
				_draw_progressive_stroke(_arrow_paths[1], arrow_color, 3.4, barb_prog)
				_draw_progressive_stroke(_arrow_paths[2], arrow_color, 3.4, barb_prog)
