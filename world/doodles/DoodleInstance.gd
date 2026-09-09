class_name DoodleInstance
extends Node2D

## Reusable Animated Hand-Drawn Doodle Instance
## Renders authentic storytime manga/comic accents and doodles with organic stroke tapering,
## progressive draw-on reveals, and live transformations.

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")

enum Type {
	ARROW,
	CIRCLE,
	UNDERLINE,
	SCRIBBLE,
	QUESTION,
	EXCLAMATION,
	HEART,
	STAR,
	SPARKLE,
	SWEAT,
	MOTION_LINES,
	IMPACT_LINES,
	SPEECH_BUBBLE,
	THOUGHT_BUBBLE,
	CROSS_OUT,
	CHECK_MARK,
	SHOCK_LINES
}

@export var doodle_type: Type = Type.ARROW
@export var draw_progress: float = 1.0 # 0.0 = just started drawing, 1.0 = fully drawn

var style: RefCounted = WorldStyleScript.new()
var target_end: Vector2 = Vector2(60.0, 0.0)
var doodle_size: float = 24.0
var custom_text: String = ""
var is_curved: bool = true

var _active_tween: Tween

func _ready() -> void:
	if style and style.has_signal("style_changed") and not style.style_changed.is_connected(queue_redraw):
		style.style_changed.connect(queue_redraw)

func set_style(p_style: RefCounted) -> void:
	style = p_style
	if style and style.has_signal("style_changed") and not style.style_changed.is_connected(queue_redraw):
		style.style_changed.connect(queue_redraw)
	queue_redraw()

# -------------------------------------------------------------------------
# LIVE ANIMATION PRIMITIVES
# -------------------------------------------------------------------------

## Progressive draw-on animation (simulates hand drawing on the screen)
func draw_on(duration: float = 0.22) -> Signal:
	draw_progress = 0.0
	visible = true
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "draw_progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.step_finished.connect(func(_idx): queue_redraw())
	_active_tween.finished.connect(queue_redraw)
	return _active_tween.finished

## Snappy pop in with bounce
func pop_in(duration: float = 0.18, overshoot: float = 1.2) -> Signal:
	scale = Vector2.ZERO
	draw_progress = 1.0
	visible = true
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "scale", Vector2(overshoot, overshoot), duration * 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "scale", Vector2.ONE, duration * 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return _active_tween.finished

func pop_out(duration: float = 0.15) -> Signal:
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "scale", Vector2.ZERO, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_active_tween.tween_callback(func(): queue_free())
	return _active_tween.finished

func shake(intensity: float = 0.5, duration: float = 0.20) -> Signal:
	var orig_pos := position
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	var steps := 3
	var step_time := duration / float(steps * 2)
	for i in range(steps):
		var off := Vector2(randf_range(-5.0, 5.0), randf_range(-4.0, 4.0)) * intensity
		_active_tween.tween_property(self, "position", orig_pos + off, step_time)
		_active_tween.tween_property(self, "position", orig_pos, step_time)
	return _active_tween.finished

# -------------------------------------------------------------------------
# DRAWING DISPATCH
# -------------------------------------------------------------------------
func _draw() -> void:
	if draw_progress <= 0.001:
		return
	
	var ink: Color = style.doodle_accent_color
	var w: float = style.doodle_width
	
	match doodle_type:
		Type.ARROW:
			_draw_arrow(ink, w)
		Type.CIRCLE:
			_draw_circle_doodle(ink, w)
		Type.UNDERLINE:
			_draw_underline(ink, w)
		Type.SCRIBBLE:
			_draw_scribble(ink, w)
		Type.QUESTION:
			_draw_question_mark(ink, w)
		Type.EXCLAMATION:
			_draw_exclamation_mark(ink, w)
		Type.HEART:
			_draw_heart(ink, w)
		Type.STAR:
			_draw_star(ink, w)
		Type.SPARKLE:
			_draw_sparkles(ink, w)
		Type.SWEAT:
			_draw_sweat(ink, w)
		Type.MOTION_LINES:
			_draw_motion_lines(ink, w)
		Type.IMPACT_LINES:
			_draw_impact_lines(ink, w)
		Type.SPEECH_BUBBLE:
			_draw_speech_bubble(ink, w)
		Type.THOUGHT_BUBBLE:
			_draw_thought_bubble(ink, w)
		Type.CROSS_OUT:
			_draw_cross_out(ink, w)
		Type.CHECK_MARK:
			_draw_check_mark(ink, w)
		Type.SHOCK_LINES:
			_draw_shock_lines(ink, w)

# -------------------------------------------------------------------------
# PROCEDURAL DOODLE IMPLEMENTATIONS
# -------------------------------------------------------------------------
func _draw_arrow(ink: Color, width: float) -> void:
	var start := Vector2.ZERO
	var end := target_end * draw_progress
	var curve := Curve2D.new()
	curve.add_point(start)
	if is_curved:
		var mid := (start + end) * 0.5 + Vector2(-(end.y - start.y) * 0.25, (end.x - start.x) * 0.25)
		curve.add_point(mid)
	curve.add_point(end)
	
	var stroke := InkStroke.from_curve(curve, width, InkStroke.Profile.TAPER_START, ink)
	stroke.draw_to(self)
	
	# Arrow head at end if draw_progress > 0.8
	if draw_progress >= 0.8:
		var head_scale := clampf((draw_progress - 0.8) / 0.2, 0.0, 1.0)
		var dir := (end - curve.get_point_position(max(0, curve.point_count - 2))).normalized()
		var left_wing := end - dir.rotated(deg_to_rad(30.0)) * (14.0 * head_scale)
		var right_wing := end - dir.rotated(deg_to_rad(-30.0)) * (14.0 * head_scale)
		var s1 := InkStroke.from_points(PackedVector2Array([end, left_wing]), width * 1.1, InkStroke.Profile.TAPER_END, ink)
		var s2 := InkStroke.from_points(PackedVector2Array([end, right_wing]), width * 1.1, InkStroke.Profile.TAPER_END, ink)
		s1.draw_to(self)
		s2.draw_to(self)

func _draw_circle_doodle(ink: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var steps := 24
	var max_step: int = int(float(steps + 4) * draw_progress)
	var rx := doodle_size
	var ry := doodle_size * 0.92
	for i in range(max_step + 1):
		var a := float(i) * TAU / float(steps) - PI * 0.5
		# Organic hand-drawn radius variation with authentic loop overlap
		var r_mult := 1.0 + sin(a * 3.0) * 0.06 + (float(i) / float(steps)) * 0.04
		pts.append(Vector2(cos(a) * rx * r_mult, sin(a) * ry * r_mult))
	if pts.size() >= 2:
		var stroke := InkStroke.from_points(pts, width, InkStroke.Profile.TAPER_BOTH, ink)
		stroke.draw_to(self)

func _draw_underline(ink: Color, width: float) -> void:
	var end_x := doodle_size * draw_progress
	var pts := PackedVector2Array([Vector2.ZERO, Vector2(end_x * 0.5, 2.0), Vector2(end_x, -1.0)])
	var stroke := InkStroke.from_points(pts, width, InkStroke.Profile.TAPER_BOTH, ink)
	stroke.draw_to(self)

func _draw_scribble(ink: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var loops := 6
	var max_loops: int = int(float(loops) * draw_progress)
	for i in range(max_loops + 1):
		var x := float(i) * (doodle_size / float(loops))
		var y := (doodle_size * 0.3) if (i % 2 == 0) else (-doodle_size * 0.3)
		pts.append(Vector2(x, y))
	if pts.size() >= 2:
		var stroke := InkStroke.from_points(pts, width * 0.9, InkStroke.Profile.TAPER_BOTH, ink)
		stroke.draw_to(self)

func _draw_question_mark(ink: Color, width: float) -> void:
	var sz := doodle_size
	var curve := Curve2D.new()
	curve.add_point(Vector2(-sz * 0.25, -sz * 0.6))
	curve.add_point(Vector2(sz * 0.25, -sz * 0.7), Vector2(0.0, -sz * 0.3), Vector2(0.0, sz * 0.3))
	curve.add_point(Vector2(0.0, -sz * 0.2), Vector2(sz * 0.1, -sz * 0.1), Vector2(-sz * 0.1, sz * 0.1))
	curve.add_point(Vector2(0.0, 0.0))
	var stroke := InkStroke.from_curve(curve, width * 1.1, InkStroke.Profile.TAPER_START, ink)
	stroke.draw_to(self)
	draw_circle(Vector2(0.0, sz * 0.22), width * 0.9, ink)

func _draw_exclamation_mark(ink: Color, width: float) -> void:
	var sz := doodle_size
	var top := Vector2(0.0, -sz * 0.8)
	var bottom := Vector2(0.0, -sz * 0.15)
	var stroke := InkStroke.from_points(PackedVector2Array([top, bottom]), width * 1.3, InkStroke.Profile.TAPER_END, ink)
	stroke.draw_to(self)
	draw_circle(Vector2(0.0, sz * 0.15), width * 0.9, ink)

func _draw_heart(ink: Color, width: float) -> void:
	var sz := doodle_size * 0.5
	var pts := PackedVector2Array()
	var steps := 28
	var max_step: int = int(float(steps) * draw_progress)
	for i in range(max_step + 1):
		var t := float(i) * TAU / float(steps)
		var x := 16.0 * pow(sin(t), 3)
		var y := -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t))
		pts.append(Vector2(x, y) * (sz / 16.0))
	if pts.size() >= 3:
		draw_colored_polygon(pts, style.accent_rose)
		var stroke := InkStroke.from_points(pts, width, InkStroke.Profile.UNIFORM, ink)
		stroke.draw_to(self)

func _draw_star(ink: Color, width: float) -> void:
	var r_out := doodle_size * 0.6
	var r_in := r_out * 0.4
	var pts := PackedVector2Array()
	for i in range(10):
		var a := float(i) * PI * 0.2 - PI * 0.5
		var r := r_out if (i % 2 == 0) else r_in
		pts.append(Vector2(cos(a) * r, sin(a) * r))
	draw_colored_polygon(pts, style.accent_yellow)
	var stroke_pts := pts.duplicate(); stroke_pts.append(pts[0])
	var stroke := InkStroke.from_points(stroke_pts, width, InkStroke.Profile.UNIFORM, ink)
	stroke.draw_to(self)

func _draw_sparkles(ink: Color, width: float) -> void:
	var offsets := [Vector2.ZERO, Vector2(14.0, -10.0), Vector2(-12.0, 10.0)]
	var sizes := [doodle_size * 0.5, doodle_size * 0.35, doodle_size * 0.3]
	for idx in range(offsets.size()):
		var center: Vector2 = offsets[idx]
		var sz: float = sizes[idx]
		var pts := PackedVector2Array()
		for i in range(8):
			var a := float(i) * PI * 0.25
			var r := sz if (i % 2 == 0) else (sz * 0.22)
			pts.append(center + Vector2(cos(a) * r, sin(a) * r))
		draw_colored_polygon(pts, style.accent_yellow)
		var stroke_pts := pts.duplicate(); stroke_pts.append(pts[0])
		var stroke := InkStroke.from_points(stroke_pts, width * 0.7, InkStroke.Profile.UNIFORM, ink)
		stroke.draw_to(self)

func _draw_sweat(ink: Color, width: float) -> void:
	var sz := doodle_size
	var pts := PackedVector2Array([Vector2(0.0, -sz * 0.7)])
	var bulb_center := Vector2(0.0, sz * 0.15)
	var radius := sz * 0.35
	for i in range(13):
		var a := lerpf(0.15 * PI, 0.85 * PI, float(i) / 12.0)
		pts.append(bulb_center + Vector2(cos(a) * radius, sin(a) * radius))
	draw_colored_polygon(pts, Color(0.72, 0.88, 0.95, 0.55))
	var stroke_pts := pts.duplicate(); stroke_pts.append(pts[0])
	var stroke := InkStroke.from_points(stroke_pts, width, InkStroke.Profile.UNIFORM, ink)
	stroke.draw_to(self)

func _draw_motion_lines(ink: Color, width: float) -> void:
	var count := 3
	var len := doodle_size
	var spacing := 6.0
	for i in range(count):
		var oy := float(i - count / 2) * spacing
		var p1 := Vector2(-len * 0.5, oy)
		var p2 := Vector2(len * 0.5, oy)
		var stroke := InkStroke.from_points(PackedVector2Array([p1, p2]), width * 0.8, InkStroke.Profile.TAPER_BOTH, ink)
		stroke.draw_to(self)

func _draw_impact_lines(ink: Color, width: float) -> void:
	var count := 8
	var r1 := doodle_size * 0.4
	var r2 := doodle_size * 0.9
	for i in range(count):
		var a := float(i) * TAU / float(count)
		var p1 := Vector2(cos(a) * r1, sin(a) * r1)
		var p2 := Vector2(cos(a) * r2, sin(a) * r2)
		var stroke := InkStroke.from_points(PackedVector2Array([p1, p2]), width, InkStroke.Profile.TAPER_BOTH, ink)
		stroke.draw_to(self)

func _draw_speech_bubble(ink: Color, width: float) -> void:
	var w := doodle_size
	var h := doodle_size * 0.55
	var rect_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5), Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.5, h * 0.5), Vector2(8.0, h * 0.5),
		Vector2(0.0, h * 0.8), Vector2(-6.0, h * 0.5),
		Vector2(-w * 0.5, h * 0.5)
	])
	draw_colored_polygon(rect_pts, style.paper_bg_color)
	var stroke_pts := rect_pts.duplicate(); stroke_pts.append(rect_pts[0])
	var stroke := InkStroke.from_points(stroke_pts, width, InkStroke.Profile.UNIFORM, ink)
	stroke.draw_to(self)
	
	if custom_text != "":
		var font: Font = ThemeDB.fallback_font
		var str_sz := font.get_string_size(custom_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
		var text_pos := Vector2(-str_sz.x * 0.5, str_sz.y * 0.35)
		draw_string(font, text_pos, custom_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, ink)

func _draw_thought_bubble(ink: Color, width: float) -> void:
	var w := doodle_size
	var h := doodle_size * 0.55
	# Cloud-like rounded bumps
	var cloud_pts := PackedVector2Array([
		Vector2(-w * 0.45, -h * 0.3), Vector2(-w * 0.25, -h * 0.55),
		Vector2(w * 0.25, -h * 0.55), Vector2(w * 0.45, -h * 0.3),
		Vector2(w * 0.5, 0.0), Vector2(w * 0.4, h * 0.45),
		Vector2(-w * 0.3, h * 0.45), Vector2(-w * 0.5, 0.0)
	])
	draw_colored_polygon(cloud_pts, style.paper_bg_color)
	var stroke_pts := cloud_pts.duplicate(); stroke_pts.append(cloud_pts[0])
	var stroke := InkStroke.from_points(stroke_pts, width, InkStroke.Profile.UNIFORM, ink)
	stroke.draw_to(self)
	# Trailing thought dots
	draw_circle(Vector2(-8.0, h * 0.65), 2.5, ink)
	draw_circle(Vector2(-14.0, h * 0.85), 1.5, ink)
	
	if custom_text != "":
		var font: Font = ThemeDB.fallback_font
		var str_sz := font.get_string_size(custom_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
		var text_pos := Vector2(-str_sz.x * 0.5, str_sz.y * 0.35)
		draw_string(font, text_pos, custom_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, ink)

func _draw_cross_out(ink: Color, width: float) -> void:
	var sz := doodle_size * 0.5
	var s1 := InkStroke.from_points(PackedVector2Array([Vector2(-sz, -sz), Vector2(sz, sz)]), width * 1.2, InkStroke.Profile.TAPER_BOTH, ink)
	var s2 := InkStroke.from_points(PackedVector2Array([Vector2(-sz, sz), Vector2(sz, -sz)]), width * 1.2, InkStroke.Profile.TAPER_BOTH, ink)
	s1.draw_to(self)
	s2.draw_to(self)

func _draw_check_mark(ink: Color, width: float) -> void:
	var sz := doodle_size * 0.5
	var pts := PackedVector2Array([
		Vector2(-sz * 0.8, 0.0),
		Vector2(-sz * 0.2, sz * 0.7),
		Vector2(sz * 0.8, -sz * 0.8)
	])
	var stroke := InkStroke.from_points(pts, width * 1.3, InkStroke.Profile.TAPER_START, ink)
	stroke.draw_to(self)

func _draw_shock_lines(ink: Color, width: float) -> void:
	for i in range(4):
		var ox := float(i - 2) * 8.0
		var stroke := InkStroke.from_points(PackedVector2Array([Vector2(ox, 0.0), Vector2(ox, 22.0)]), width, InkStroke.Profile.TAPER_BOTH, ink)
		stroke.draw_to(self)
