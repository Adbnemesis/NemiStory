class_name PokemonDoodleDirector
extends Node2D

## Master Hand-Drawn Doodle & Ink Annotation System for Pokémon Storytelling
## All doodles follow the canonical lifecycle: DRAW -> HOLD -> ERASE / FADE.
## Default inking is dark charcoal (#262224) with organic human line curvature.

const PokemonInkStroke = preload("res://pokemon/scripts/PokemonInkStroke.gd")

class ActiveDoodle extends RefCounted:
	var type: String
	var points: PackedVector2Array = PackedVector2Array()
	var progress: float = 0.0 # 0.0 to 1.0
	var alpha: float = 1.0
	var color: Color = Color("#262224")
	var line_width: float = 2.8
	var text: String = ""
	var font_pos: Vector2 = Vector2.ZERO

var _doodles: Array[ActiveDoodle] = []

func _draw() -> void:
	for d in _doodles:
		if d.alpha <= 0.001 or d.progress <= 0.001:
			continue
		
		var draw_col := Color(d.color.r, d.color.g, d.color.b, d.color.a * d.alpha)
		
		match d.type:
			"arrow":
				_draw_progressive_arrow(d, draw_col)
			"circle":
				_draw_progressive_circle(d, draw_col)
			"underline":
				_draw_progressive_line(d, draw_col)
			"question_mark":
				_draw_progressive_question(d, draw_col)
			"exclamation":
				_draw_progressive_exclamation(d, draw_col)
			"label":
				_draw_progressive_label(d, draw_col)
			"sparkle":
				_draw_progressive_sparkle(d, draw_col)

func _draw_progressive_arrow(d: ActiveDoodle, col: Color) -> void:
	if d.points.size() < 2:
		return
	var start := d.points[0]
	var end := d.points[1]
	var current_end := start.lerp(end, minf(1.0, d.progress * 1.25))
	
	# Shaft
	draw_line(start, current_end, col, d.line_width, true)
	
	# Head chevrons appear once progress > 0.7
	if d.progress > 0.7:
		var head_prog := (d.progress - 0.7) / 0.3
		var dir := (end - start).normalized()
		var norm := Vector2(-dir.y, dir.x)
		var barb_len := 14.0 * head_prog
		var left_barb := end - dir * barb_len + norm * (barb_len * 0.55)
		var right_barb := end - dir * barb_len - norm * (barb_len * 0.55)
		draw_line(end, left_barb, col, d.line_width, true)
		draw_line(end, right_barb, col, d.line_width, true)

func _draw_progressive_circle(d: ActiveDoodle, col: Color) -> void:
	if d.points.is_empty():
		return
	var center := d.points[0]
	var radius := d.points[1].x
	var max_angle := TAU * 1.08 * d.progress # Slight hand-drawn overlap
	var steps := int(32 * d.progress)
	if steps < 2:
		return
	
	var pts := PackedVector2Array()
	for i in range(steps + 1):
		var a: float = -PI * 0.5 + (float(i) / 32.0) * TAU * 1.08
		# Slight organic wobble
		var r := radius + sin(a * 3.0) * 1.2
		pts.append(center + Vector2(cos(a) * r, sin(a) * r))
	draw_polyline(pts, col, d.line_width, false)

func _draw_progressive_line(d: ActiveDoodle, col: Color) -> void:
	if d.points.size() < 2:
		return
	var current_end := d.points[0].lerp(d.points[1], d.progress)
	draw_line(d.points[0], current_end, col, d.line_width, true)

func _draw_progressive_question(d: ActiveDoodle, col: Color) -> void:
	if d.points.is_empty():
		return
	var p := d.points[0]
	var q_curve := Curve2D.new()
	q_curve.add_point(p + Vector2(-6, -18), Vector2(0, 0), Vector2(0, -6))
	q_curve.add_point(p + Vector2(0, -26), Vector2(-4, 0), Vector2(6, 0))
	q_curve.add_point(p + Vector2(8, -18), Vector2(0, -4), Vector2(0, 4))
	q_curve.add_point(p + Vector2(0, -8), Vector2(4, -2), Vector2(0, 4))
	q_curve.add_point(p + Vector2(0, -2), Vector2(0, -2), Vector2(0, 0))
	
	var pts := q_curve.tessellate(3, 2.0)
	var count := int(pts.size() * d.progress)
	if count >= 2:
		var sub_pts := pts.slice(0, count)
		draw_polyline(sub_pts, col, d.line_width, false)
	if d.progress > 0.85:
		draw_circle(p + Vector2(0, 5), d.line_width * 0.65, col)

func _draw_progressive_exclamation(d: ActiveDoodle, col: Color) -> void:
	if d.points.is_empty():
		return
	var p := d.points[0]
	var top_y := p.y - 24
	var bot_y := top_y + 18 * d.progress
	draw_line(Vector2(p.x, top_y), Vector2(p.x, bot_y), col, d.line_width + 0.5, true)
	if d.progress > 0.85:
		draw_circle(p + Vector2(0, 2), d.line_width * 0.65, col)

func _draw_progressive_label(d: ActiveDoodle, col: Color) -> void:
	if d.text.is_empty():
		return
	var font := ThemeDB.fallback_font
	var visible_chars := int(d.text.length() * d.progress)
	var sub_str := d.text.substr(0, visible_chars)
	draw_string(font, d.font_pos, sub_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, col)
	
	if d.points.size() >= 2 and d.progress > 0.5:
		var u_prog := (d.progress - 0.5) / 0.5
		var u_end := d.points[0].lerp(d.points[1], u_prog)
		draw_line(d.points[0], u_end, col, 2.0, true)

func _draw_progressive_sparkle(d: ActiveDoodle, col: Color) -> void:
	if d.points.is_empty():
		return
	var p := d.points[0]
	var s: float = 12.0 * d.progress
	draw_line(p - Vector2(s, 0), p + Vector2(s, 0), col, d.line_width, true)
	draw_line(p - Vector2(0, s), p + Vector2(0, s), col, d.line_width, true)
	draw_line(p - Vector2(s * 0.5, s * 0.5), p + Vector2(s * 0.5, s * 0.5), col, d.line_width * 0.6, true)
	draw_line(p - Vector2(-s * 0.5, s * 0.5), p + Vector2(-s * 0.5, s * 0.5), col, d.line_width * 0.6, true)

# -------------------------------------------------------------------------
# PUBLIC DIRECTORIAL API: DRAW -> HOLD -> ERASE
# -------------------------------------------------------------------------

func draw_doodle_arrow(start_pos: Vector2, end_pos: Vector2, draw_time: float = 0.3) -> ActiveDoodle:
	var d := ActiveDoodle.new()
	d.type = "arrow"
	d.points = PackedVector2Array([start_pos, end_pos])
	_doodles.append(d)
	
	var tw := create_tween()
	tw.tween_property(d, "progress", 1.0, draw_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)
	return d

func draw_doodle_circle(center: Vector2, radius: float, draw_time: float = 0.35) -> ActiveDoodle:
	var d := ActiveDoodle.new()
	d.type = "circle"
	d.points = PackedVector2Array([center, Vector2(radius, 0)])
	_doodles.append(d)
	
	var tw := create_tween()
	tw.tween_property(d, "progress", 1.0, draw_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)
	return d

func draw_doodle_underline(start_pos: Vector2, end_pos: Vector2, draw_time: float = 0.25) -> ActiveDoodle:
	var d := ActiveDoodle.new()
	d.type = "underline"
	d.points = PackedVector2Array([start_pos, end_pos])
	_doodles.append(d)
	
	var tw := create_tween()
	tw.tween_property(d, "progress", 1.0, draw_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)
	return d

func draw_doodle_question(pos: Vector2, draw_time: float = 0.3) -> ActiveDoodle:
	var d := ActiveDoodle.new()
	d.type = "question_mark"
	d.points = PackedVector2Array([pos])
	_doodles.append(d)
	
	var tw := create_tween()
	tw.tween_property(d, "progress", 1.0, draw_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)
	return d

func draw_doodle_exclamation(pos: Vector2, draw_time: float = 0.2) -> ActiveDoodle:
	var d := ActiveDoodle.new()
	d.type = "exclamation"
	d.points = PackedVector2Array([pos])
	_doodles.append(d)
	
	var tw := create_tween()
	tw.tween_property(d, "progress", 1.0, draw_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)
	return d

func draw_doodle_label(text_str: String, pos: Vector2, draw_time: float = 0.35) -> ActiveDoodle:
	var d := ActiveDoodle.new()
	d.type = "label"
	d.text = text_str
	d.font_pos = pos
	d.points = PackedVector2Array([pos + Vector2(0, 6), pos + Vector2(text_str.length() * 12.0, 6)])
	_doodles.append(d)
	
	var tw := create_tween()
	tw.tween_property(d, "progress", 1.0, draw_time)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)
	return d

func draw_doodle_sparkle(pos: Vector2, draw_time: float = 0.25) -> ActiveDoodle:
	var d := ActiveDoodle.new()
	d.type = "sparkle"
	d.points = PackedVector2Array([pos])
	_doodles.append(d)
	
	var tw := create_tween()
	tw.tween_property(d, "progress", 1.0, draw_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)
	return d

func erase_doodle(doodle: ActiveDoodle, duration: float = 0.2) -> void:
	var tw := create_tween()
	tw.tween_property(doodle, "alpha", 0.0, duration)
	tw.finished.connect(func():
		_doodles.erase(doodle)
		queue_redraw()
	)

func clear_all_doodles(duration: float = 0.2) -> void:
	if _doodles.is_empty():
		return
	var tw := create_tween()
	for d in _doodles:
		tw.parallel().tween_property(d, "alpha", 0.0, duration)
	tw.finished.connect(func():
		_doodles.clear()
		queue_redraw()
	)
