class_name DoodleInstance
extends Node2D

## Reusable Animated Hand-Drawn Doodle & Ink Storytelling Instance
## Renders authentic hand-drawn annotations, comic marks, and mini-illustrations with
## organic line quality, progressive draw-on reveals, deterministic authored imperfections,
## and complete erase/reverse-draw behaviors.

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")

enum Type {
	# Annotations
	ARROW,
	DOUBLE_ARROW,
	CIRCLE,
	OVAL,
	UNDERLINE,
	BRACKET,
	POINTER,
	CROSS_OUT,
	CHECK_MARK,
	STAR,
	EMPHASIS_BURST,
	
	# Text
	HANDWRITTEN_LABEL,
	
	# Motion
	SPEED_LINES,
	DIRECTION_LINES,
	MOTION_LINES,
	SWIRL,
	MOVEMENT_TRAIL,
	SHAKE_MARKS,
	IMPACT_LINES,
	
	# Reaction-adjacent
	SCRIBBLE,
	ATTENTION_RAYS,
	
	# Mini Illustrations
	MINI_CLOCK,
	MINI_CALENDAR,
	MINI_BRAIN,
	MINI_BANANA,
	MINI_DUMBBELL,
	MINI_NOTE,
	MINI_BRIDGE,
	MINI_CAR,
	MINI_MAGNIFIER,
	MINI_PERSON,
	
	# Legacy / Classic Accents
	QUESTION,
	EXCLAMATION,
	HEART,
	SPARKLE,
	SWEAT,
	SPEECH_BUBBLE,
	THOUGHT_BUBBLE,
	SHOCK_LINES
}

enum StylePreset {
	SUBTLE,        # 1.4px line width, soft presence
	NORMAL,        # 2.2px line width, master inking
	COMEDIC,       # 3.2px line width, punchy and rounded
	MESSY_CHAOTIC  # 2.0px line width, layered sketch passes
}

enum ColorMode {
	COLOR,         # Uses restrained accent colors (yellow, rose, soft blue)
	MONOCHROME     # Pure ink hierarchy (burgundy/black ink with subtle line tints only)
}

enum LayerOrder {
	BEHIND_NEMI = 15,
	IN_FRONT_OF_NEMI = 25,
	SCREEN_SPACE = 100
}

@export var doodle_type: Type = Type.ARROW
@export var draw_progress: float = 1.0 # 0.0 = not drawn, 1.0 = fully drawn
@export var style_preset: StylePreset = StylePreset.NORMAL
@export var color_mode: ColorMode = ColorMode.COLOR
@export var ink_color_override: Color = Color(0, 0, 0, 0)
@export var seed_val: int = 42

var style: RefCounted = WorldStyleScript.new()
var target_end: Vector2 = Vector2(60.0, 0.0)
var doodle_size: float = 28.0
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

func set_layer(order: LayerOrder) -> void:
	z_index = int(order)

# -------------------------------------------------------------------------
# LIVE DRAW-ON & ERASE ANIMATION BEHAVIORS
# -------------------------------------------------------------------------

## Progressive draw-on animation (stroke-by-stroke sequential reveal)
func draw_on(duration: float = 0.22) -> Signal:
	draw_progress = 0.0
	visible = true
	modulate.a = 1.0
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "draw_progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.step_finished.connect(func(_idx): queue_redraw())
	_active_tween.finished.connect(queue_redraw)
	return _active_tween.finished

## Reverse draw-on (undo strokes sequentially, then frees)
func reverse_draw(duration: float = 0.20) -> Signal:
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "draw_progress", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_active_tween.step_finished.connect(func(_idx): queue_redraw())
	_active_tween.finished.connect(func(): queue_free())
	return _active_tween.finished

## Alias for reverse_draw to match user request
func erase(duration: float = 0.20) -> Signal:
	return reverse_draw(duration)

## Smooth fade out and free
func fade_out(duration: float = 0.18) -> Signal:
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.finished.connect(func(): queue_free())
	return _active_tween.finished

## Shrink to zero and free
func shrink_out(duration: float = 0.15) -> Signal:
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "scale", Vector2.ZERO, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_active_tween.finished.connect(func(): queue_free())
	return _active_tween.finished

## Snappy pop-in with slight elastic bounce
func pop_in(duration: float = 0.18, overshoot: float = 1.2) -> Signal:
	scale = Vector2.ZERO
	draw_progress = 1.0
	visible = true
	modulate.a = 1.0
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "scale", Vector2(overshoot, overshoot), duration * 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "scale", Vector2.ONE, duration * 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return _active_tween.finished

func pop_out(duration: float = 0.15) -> Signal:
	return shrink_out(duration)

func shake(intensity: float = 0.5, duration: float = 0.20) -> Signal:
	var orig_pos := position
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	var steps := 3
	var step_time := duration / float(steps * 2)
	for i in range(steps):
		var det_angle := float(i) * 2.399
		var off := Vector2(cos(det_angle) * 5.0, sin(det_angle) * 4.0) * intensity
		_active_tween.tween_property(self, "position", orig_pos + off, step_time)
		_active_tween.tween_property(self, "position", orig_pos, step_time)
	return _active_tween.finished

# -------------------------------------------------------------------------
# STYLING & WIDTH HELPERS
# -------------------------------------------------------------------------
func _get_line_width() -> float:
	match style_preset:
		StylePreset.SUBTLE: return 1.4
		StylePreset.NORMAL: return 2.2
		StylePreset.COMEDIC: return 3.2
		StylePreset.MESSY_CHAOTIC: return 2.0
		_: return 2.2

func _get_ink_color() -> Color:
	if ink_color_override.a > 0.0:
		return ink_color_override
	if style and style.get("doodle_accent_color"):
		return style.doodle_accent_color
	return Color("#3e081e") # Nemi master burgundy

func _get_accent_color(default_col: Color) -> Color:
	if color_mode == ColorMode.MONOCHROME:
		# Return subtle ink wash in monochrome mode
		var ink := _get_ink_color()
		return Color(ink.r, ink.g, ink.b, 0.12)
	return default_col

# -------------------------------------------------------------------------
# DRAWING DISPATCH
# -------------------------------------------------------------------------
func _draw() -> void:
	if draw_progress <= 0.001:
		return
	
	var ink: Color = _get_ink_color()
	var w: float = _get_line_width()
	
	match doodle_type:
		Type.ARROW: _draw_arrow(ink, w)
		Type.DOUBLE_ARROW: _draw_double_arrow(ink, w)
		Type.CIRCLE: _draw_circle_doodle(ink, w)
		Type.OVAL: _draw_oval_doodle(ink, w)
		Type.UNDERLINE: _draw_underline(ink, w)
		Type.BRACKET: _draw_bracket(ink, w)
		Type.POINTER: _draw_pointer(ink, w)
		Type.CROSS_OUT: _draw_cross_out(ink, w)
		Type.CHECK_MARK: _draw_check_mark(ink, w)
		Type.STAR: _draw_star(ink, w)
		Type.EMPHASIS_BURST: _draw_emphasis_burst(ink, w)
		Type.HANDWRITTEN_LABEL: _draw_handwritten_label(ink, w)
		Type.SPEED_LINES: _draw_speed_lines(ink, w)
		Type.DIRECTION_LINES, Type.MOTION_LINES: _draw_direction_lines(ink, w)
		Type.SWIRL: _draw_swirl(ink, w)
		Type.MOVEMENT_TRAIL: _draw_movement_trail(ink, w)
		Type.SHAKE_MARKS: _draw_shake_marks(ink, w)
		Type.IMPACT_LINES: _draw_impact_lines(ink, w)
		Type.SCRIBBLE: _draw_scribble(ink, w)
		Type.ATTENTION_RAYS: _draw_attention_rays(ink, w)
		Type.MINI_CLOCK: _draw_mini_clock(ink, w)
		Type.MINI_CALENDAR: _draw_mini_calendar(ink, w)
		Type.MINI_BRAIN: _draw_mini_brain(ink, w)
		Type.MINI_BANANA: _draw_mini_banana(ink, w)
		Type.MINI_DUMBBELL: _draw_mini_dumbbell(ink, w)
		Type.MINI_NOTE: _draw_mini_note(ink, w)
		Type.MINI_BRIDGE: _draw_mini_bridge(ink, w)
		Type.MINI_CAR: _draw_mini_car(ink, w)
		Type.MINI_MAGNIFIER: _draw_mini_magnifier(ink, w)
		Type.MINI_PERSON: _draw_mini_person(ink, w)
		Type.QUESTION: _draw_question_mark(ink, w)
		Type.EXCLAMATION: _draw_exclamation_mark(ink, w)
		Type.HEART: _draw_heart(ink, w)
		Type.SPARKLE: _draw_sparkles(ink, w)
		Type.SWEAT: _draw_sweat(ink, w)
		Type.SPEECH_BUBBLE: _draw_speech_bubble(ink, w)
		Type.THOUGHT_BUBBLE: _draw_thought_bubble(ink, w)
		Type.SHOCK_LINES: _draw_shock_lines(ink, w)

# -------------------------------------------------------------------------
# PROCEDURAL DRAWING IMPLEMENTATIONS (AUTHORED & DETERMINISTIC)
# -------------------------------------------------------------------------

func _draw_arrow(ink: Color, width: float) -> void:
	var shaft_prog := clampf(draw_progress / 0.75, 0.0, 1.0)
	var start := Vector2.ZERO
	var current_end := target_end * shaft_prog
	
	if current_end.length_squared() > 1.0:
		var curve := Curve2D.new()
		curve.add_point(start)
		if is_curved:
			var mid := (start + current_end) * 0.5 + Vector2(-(current_end.y - start.y) * 0.18, (current_end.x - start.x) * 0.18)
			curve.add_point(mid)
		curve.add_point(current_end)
		var stroke := InkStroke.from_curve(curve, width, InkStroke.Profile.TAPER_START, ink)
		stroke.draw_to(self)
	
	# Arrowhead appears and extends between 0.75 and 1.0
	if draw_progress > 0.75:
		var head_scale := (draw_progress - 0.75) / 0.25
		var dir := target_end.normalized()
		var left_wing := target_end - dir.rotated(deg_to_rad(28.0)) * (14.0 * head_scale)
		var right_wing := target_end - dir.rotated(deg_to_rad(-28.0)) * (14.0 * head_scale)
		var s1 := InkStroke.from_points(PackedVector2Array([target_end, left_wing]), width * 1.1, InkStroke.Profile.TAPER_END, ink)
		var s2 := InkStroke.from_points(PackedVector2Array([target_end, right_wing]), width * 1.1, InkStroke.Profile.TAPER_END, ink)
		s1.draw_to(self)
		s2.draw_to(self)

func _draw_double_arrow(ink: Color, width: float) -> void:
	var shaft_prog := clampf((draw_progress - 0.15) / 0.70, 0.0, 1.0)
	var current_end := target_end * shaft_prog
	
	if shaft_prog > 0.01:
		var curve := Curve2D.new()
		curve.add_point(Vector2.ZERO)
		if is_curved:
			var mid := current_end * 0.5 + Vector2(-current_end.y * 0.15, current_end.x * 0.15)
			curve.add_point(mid)
		curve.add_point(current_end)
		var stroke := InkStroke.from_curve(curve, width, InkStroke.Profile.UNIFORM, ink)
		stroke.draw_to(self)
	
	# Start arrow head
	if draw_progress >= 0.1:
		var hs1 := clampf(draw_progress / 0.25, 0.0, 1.0)
		var dir := target_end.normalized()
		var left := Vector2.ZERO + dir.rotated(deg_to_rad(30.0)) * (12.0 * hs1)
		var right := Vector2.ZERO + dir.rotated(deg_to_rad(-30.0)) * (12.0 * hs1)
		InkStroke.from_points(PackedVector2Array([Vector2.ZERO, left]), width, InkStroke.Profile.TAPER_END, ink).draw_to(self)
		InkStroke.from_points(PackedVector2Array([Vector2.ZERO, right]), width, InkStroke.Profile.TAPER_END, ink).draw_to(self)
	
	# End arrow head
	if draw_progress >= 0.85:
		var hs2 := clampf((draw_progress - 0.85) / 0.15, 0.0, 1.0)
		var dir := target_end.normalized()
		var left := target_end - dir.rotated(deg_to_rad(30.0)) * (12.0 * hs2)
		var right := target_end - dir.rotated(deg_to_rad(-30.0)) * (12.0 * hs2)
		InkStroke.from_points(PackedVector2Array([target_end, left]), width, InkStroke.Profile.TAPER_END, ink).draw_to(self)
		InkStroke.from_points(PackedVector2Array([target_end, right]), width, InkStroke.Profile.TAPER_END, ink).draw_to(self)

func _draw_circle_doodle(ink: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var steps := 28
	var max_step: int = int(float(steps + 5) * draw_progress)
	var rx := doodle_size
	var ry := doodle_size * 0.94
	for i in range(max_step + 1):
		var a := float(i) * TAU / float(steps) - PI * 0.5
		# Deterministic human hand wobble with authentic closing overlap
		var r_mult := 1.0 + sin(a * 2.7) * 0.05 + cos(a * 4.1) * 0.025 + (float(i) / float(steps)) * 0.03
		pts.append(Vector2(cos(a) * rx * r_mult, sin(a) * ry * r_mult))
	if pts.size() >= 2:
		var stroke := InkStroke.from_points(pts, width, InkStroke.Profile.TAPER_BOTH, ink)
		stroke.draw_to(self)

func _draw_oval_doodle(ink: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var steps := 28
	var max_step: int = int(float(steps + 4) * draw_progress)
	var rx := doodle_size * 1.35
	var ry := doodle_size * 0.75
	var tilt := deg_to_rad(-8.0)
	for i in range(max_step + 1):
		var a := float(i) * TAU / float(steps) - PI * 0.5
		var r_mult := 1.0 + sin(a * 3.0) * 0.04
		var p := Vector2(cos(a) * rx * r_mult, sin(a) * ry * r_mult).rotated(tilt)
		pts.append(p)
	if pts.size() >= 2:
		var stroke := InkStroke.from_points(pts, width, InkStroke.Profile.TAPER_BOTH, ink)
		stroke.draw_to(self)

func _draw_underline(ink: Color, width: float) -> void:
	var end_x := doodle_size * 2.4 * draw_progress
	var pts := PackedVector2Array()
	var segments := 16
	for i in range(segments + 1):
		var t := float(i) / float(segments)
		var x := end_x * t
		var y := sin(t * 7.5) * 2.2 + cos(t * 12.0) * 1.0
		pts.append(Vector2(x, y))
	if pts.size() >= 2:
		var stroke := InkStroke.from_points(pts, width, InkStroke.Profile.TAPER_BOTH, ink)
		stroke.draw_to(self)

func _draw_bracket(ink: Color, width: float) -> void:
	var h := doodle_size * 2.0
	var pts := PackedVector2Array()
	var steps := 20
	var max_step := int(float(steps) * draw_progress)
	for i in range(max_step + 1):
		var t := float(i) / float(steps)
		var y := lerpf(-h * 0.5, h * 0.5, t)
		var norm_y := (t - 0.5) * 2.0 # -1.0 to 1.0
		var x := -(1.0 - absf(norm_y)) * 12.0 + sin(norm_y * PI) * 4.0
		pts.append(Vector2(x, y))
	if pts.size() >= 2:
		var stroke := InkStroke.from_points(pts, width, InkStroke.Profile.TAPER_BOTH, ink)
		stroke.draw_to(self)

func _draw_pointer(ink: Color, width: float) -> void:
	var prog := clampf(draw_progress, 0.0, 1.0)
	var pts := PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(-18.0 * prog, -8.0 * prog),
		Vector2(-14.0 * prog, -2.0 * prog),
		Vector2(-30.0 * prog, -2.0 * prog),
		Vector2(-30.0 * prog, 2.0 * prog),
		Vector2(-14.0 * prog, 2.0 * prog),
		Vector2(-18.0 * prog, 8.0 * prog),
		Vector2(0.0, 0.0)
	])
	if prog >= 0.9:
		draw_colored_polygon(pts, _get_accent_color(Color("#ffecb3")))
	InkStroke.from_points(pts, width, InkStroke.Profile.UNIFORM, ink).draw_to(self)

func _draw_cross_out(ink: Color, width: float) -> void:
	var sz := doodle_size * 0.55
	# Stroke 1: top-left to bottom-right (0.0 to 0.5)
	if draw_progress > 0.0:
		var p1 := clampf(draw_progress / 0.5, 0.0, 1.0)
		var start := Vector2(-sz, -sz)
		var end := start + Vector2(sz * 2.0, sz * 2.0) * p1
		InkStroke.from_points(PackedVector2Array([start, end]), width * 1.15, InkStroke.Profile.TAPER_BOTH, ink).draw_to(self)
	# Stroke 2: bottom-left to top-right (0.5 to 1.0)
	if draw_progress > 0.5:
		var p2 := clampf((draw_progress - 0.5) / 0.5, 0.0, 1.0)
		var start := Vector2(-sz, sz)
		var end := start + Vector2(sz * 2.0, -sz * 2.0) * p2
		InkStroke.from_points(PackedVector2Array([start, end]), width * 1.15, InkStroke.Profile.TAPER_BOTH, ink).draw_to(self)

func _draw_check_mark(ink: Color, width: float) -> void:
	var sz := doodle_size * 0.55
	var pts := PackedVector2Array()
	# Stroke 1 (0.0 to 0.35)
	var p1 := clampf(draw_progress / 0.35, 0.0, 1.0)
	var start := Vector2(-sz * 0.8, 0.0)
	var mid := Vector2(-sz * 0.15, sz * 0.65)
	pts.append(start)
	pts.append(start.lerp(mid, p1))
	
	# Stroke 2 (0.35 to 1.0)
	if draw_progress > 0.35:
		var p2 := clampf((draw_progress - 0.35) / 0.65, 0.0, 1.0)
		var end := Vector2(sz * 0.85, -sz * 0.8)
		pts.append(mid.lerp(end, p2))
		
	if pts.size() >= 2:
		InkStroke.from_points(pts, width * 1.25, InkStroke.Profile.TAPER_START, ink).draw_to(self)

func _draw_star(ink: Color, width: float) -> void:
	# Classic 5-point star drawn in continuous 5 strokes
	var r := doodle_size * 0.65
	var star_points := PackedVector2Array()
	for i in range(5):
		var a := float(i * 2) * PI * 0.4 - PI * 0.5
		star_points.append(Vector2(cos(a) * r, sin(a) * r))
	star_points.append(star_points[0]) # Loop closed
	
	var total_segs := 5
	var curr_seg_float := draw_progress * float(total_segs)
	var full_segs := int(floor(curr_seg_float))
	var frac := curr_seg_float - float(full_segs)
	
	var drawn_pts := PackedVector2Array()
	for i in range(min(full_segs + 1, total_segs)):
		drawn_pts.append(star_points[i])
	if full_segs < total_segs and frac > 0.001:
		var p := star_points[full_segs].lerp(star_points[full_segs + 1], frac)
		drawn_pts.append(p)
		
	if draw_progress >= 0.98:
		# Draw colored polygon if color mode
		var poly := PackedVector2Array()
		for i in range(10):
			var a := float(i) * PI * 0.2 - PI * 0.5
			var rad := r if (i % 2 == 0) else (r * 0.42)
			poly.append(Vector2(cos(a) * rad, sin(a) * rad))
		draw_colored_polygon(poly, _get_accent_color(Color("#ffe082")))
		
	if drawn_pts.size() >= 2:
		InkStroke.from_points(drawn_pts, width, InkStroke.Profile.UNIFORM, ink).draw_to(self)

func _draw_emphasis_burst(ink: Color, width: float) -> void:
	var count := 6
	var r1 := doodle_size * 0.4
	var r2 := doodle_size * 0.95
	var prog := clampf(draw_progress, 0.0, 1.0)
	for i in range(count):
		var a := float(i) * TAU / float(count) + deg_to_rad(15.0)
		var p1 := Vector2(cos(a) * r1, sin(a) * r1)
		var p2 := Vector2(cos(a) * (r1 + (r2 - r1) * prog), sin(a) * (r1 + (r2 - r1) * prog))
		InkStroke.from_points(PackedVector2Array([p1, p2]), width * 1.1, InkStroke.Profile.TAPER_BOTH, ink).draw_to(self)

func _draw_attention_rays(ink: Color, width: float) -> void:
	var count := 8
	var r1 := doodle_size * 0.5
	var r2 := doodle_size * 1.1
	var prog := clampf(draw_progress, 0.0, 1.0)
	for i in range(count):
		var a := float(i) * TAU / float(count)
		var current_r2 := r1 + (r2 - r1) * prog
		var p1 := Vector2(cos(a) * r1, sin(a) * r1)
		var p2 := Vector2(cos(a) * current_r2, sin(a) * current_r2)
		InkStroke.from_points(PackedVector2Array([p1, p2]), width, InkStroke.Profile.TAPER_END, ink).draw_to(self)

func _draw_handwritten_label(ink: Color, width: float) -> void:
	if custom_text == "":
		return
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 18
	match style_preset:
		StylePreset.SUBTLE: font_size = 14
		StylePreset.NORMAL: font_size = 18
		StylePreset.COMEDIC: font_size = 22
		StylePreset.MESSY_CHAOTIC: font_size = 18
		
	var visible_chars := int(ceil(float(custom_text.length()) * draw_progress))
	var partial_text := custom_text.substr(0, visible_chars)
	var str_sz := font.get_string_size(custom_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var text_pos := Vector2(-str_sz.x * 0.5, str_sz.y * 0.35)
	
	# Draw hand-drawn underline accent underneath if draw_progress > 0.4
	if draw_progress > 0.4:
		var u_prog := clampf((draw_progress - 0.4) / 0.6, 0.0, 1.0)
		var u_start := Vector2(-str_sz.x * 0.55, str_sz.y * 0.55)
		var u_end := u_start + Vector2(str_sz.x * 1.1 * u_prog, sin(u_prog * 4.0) * 2.0)
		InkStroke.from_points(PackedVector2Array([u_start, u_end]), width * 0.85, InkStroke.Profile.TAPER_BOTH, ink).draw_to(self)
		
	draw_string(font, text_pos, partial_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, ink)

func _draw_speed_lines(ink: Color, width: float) -> void:
	var count := 4
	var len := doodle_size * 1.8 * draw_progress
	var spacing := 7.0
	for i in range(count):
		var y := float(i - count / 2) * spacing
		var off_x := sin(float(i) * 1.5) * 6.0
		var p1 := Vector2(-len * 0.5 + off_x, y)
		var p2 := Vector2(len * 0.5 + off_x, y)
		InkStroke.from_points(PackedVector2Array([p1, p2]), width * 0.8, InkStroke.Profile.TAPER_BOTH, ink).draw_to(self)

func _draw_direction_lines(ink: Color, width: float) -> void:
	var count := 3
	var prog := clampf(draw_progress, 0.0, 1.0)
	for i in range(count):
		var radius := (doodle_size * 0.8) + float(i) * 8.0
		var pts := PackedVector2Array()
		var steps := 12
		var max_steps := int(float(steps) * prog)
		for s in range(max_steps + 1):
			var a := lerpf(deg_to_rad(-20.0), deg_to_rad(70.0), float(s) / float(steps))
			pts.append(Vector2(cos(a) * radius, sin(a) * radius))
		if pts.size() >= 2:
			InkStroke.from_points(pts, width * 0.75, InkStroke.Profile.TAPER_END, ink).draw_to(self)

func _draw_swirl(ink: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var total_turns := 2.2
	var steps := 36
	var max_steps := int(float(steps) * draw_progress)
	for i in range(max_steps + 1):
		var t := float(i) / float(steps)
		var a := t * TAU * total_turns
		var r := t * doodle_size * 0.95
		pts.append(Vector2(cos(a) * r, sin(a) * r))
	if pts.size() >= 2:
		InkStroke.from_points(pts, width, InkStroke.Profile.TAPER_BOTH, ink).draw_to(self)

func _draw_movement_trail(ink: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var steps := 16
	var max_steps := int(float(steps) * draw_progress)
	for i in range(max_steps + 1):
		var t := float(i) / float(steps)
		var x := -t * doodle_size * 1.5
		var y := sin(t * 5.0) * (doodle_size * 0.3)
		pts.append(Vector2(x, y))
	if pts.size() >= 2:
		InkStroke.from_points(pts, width * 0.85, InkStroke.Profile.TAPER_END, ink).draw_to(self)

func _draw_shake_marks(ink: Color, width: float) -> void:
	var h := doodle_size * 0.7
	var prog := clampf(draw_progress, 0.0, 1.0)
	for side_idx in range(2):
		var side: float = -1.0 if side_idx == 0 else 1.0
		var ox: float = side * (doodle_size * 0.75)
		var pts := PackedVector2Array([
			Vector2(ox, -h * 0.5 * prog),
			Vector2(ox + side * 5.0 * prog, 0.0),
			Vector2(ox, h * 0.5 * prog)
		])
		InkStroke.from_points(pts, width, InkStroke.Profile.TAPER_BOTH, ink).draw_to(self)

func _draw_impact_lines(ink: Color, width: float) -> void:
	var count := 8
	var r1 := doodle_size * 0.35
	var r2 := doodle_size * 0.9
	var prog := clampf(draw_progress, 0.0, 1.0)
	for i in range(count):
		var a := float(i) * TAU / float(count)
		var current_r2 := r1 + (r2 - r1) * prog
		var p1 := Vector2(cos(a) * r1, sin(a) * r1)
		var p2 := Vector2(cos(a) * current_r2, sin(a) * current_r2)
		InkStroke.from_points(PackedVector2Array([p1, p2]), width * 1.1, InkStroke.Profile.TAPER_BOTH, ink).draw_to(self)

func _draw_scribble(ink: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var loops := 8
	var max_loops: int = int(float(loops) * draw_progress)
	for i in range(max_loops + 1):
		var x := float(i) * (doodle_size * 1.4 / float(loops)) - (doodle_size * 0.7)
		var y := (doodle_size * 0.35) if (i % 2 == 0) else (-doodle_size * 0.35)
		y += sin(float(i) * 1.7) * 3.0 # Deterministic imperfection
		pts.append(Vector2(x, y))
	if pts.size() >= 2:
		var stroke := InkStroke.from_points(pts, width * 0.9, InkStroke.Profile.TAPER_BOTH, ink)
		stroke.draw_to(self)

# -------------------------------------------------------------------------
# MINI ILLUSTRATIONS (NARRATIVE STORYTELLING DRAWINGS)
# -------------------------------------------------------------------------

func _draw_mini_clock(ink: Color, width: float) -> void:
	var r := doodle_size * 0.8
	# Phase 1: Outer circle body (0.0 to 0.5)
	if draw_progress > 0.0:
		var circ_prog := clampf(draw_progress / 0.5, 0.0, 1.0)
		var pts := PackedVector2Array()
		var steps := 24
		var max_s := int(float(steps + 2) * circ_prog)
		for i in range(max_s + 1):
			var a := float(i) * TAU / float(steps) - PI * 0.5
			pts.append(Vector2(cos(a) * r, sin(a) * r))
		if circ_prog >= 0.98:
			var poly := PackedVector2Array()
			for s in range(steps):
				var a := float(s) * TAU / float(steps)
				poly.append(Vector2(cos(a) * r, sin(a) * r))
			draw_colored_polygon(poly, _get_accent_color(Color("#fefae0")))
		if pts.size() >= 2:
			InkStroke.from_points(pts, width, InkStroke.Profile.UNIFORM, ink).draw_to(self)
			
	# Phase 2: Tick marks (0.5 to 0.75)
	if draw_progress > 0.5:
		var tick_prog := clampf((draw_progress - 0.5) / 0.25, 0.0, 1.0)
		var tick_count := int(4.0 * tick_prog)
		for i in range(tick_count):
			var a := float(i) * (TAU * 0.25)
			var p1 := Vector2(cos(a) * (r * 0.75), sin(a) * (r * 0.75))
			var p2 := Vector2(cos(a) * (r * 0.9), sin(a) * (r * 0.9))
			InkStroke.from_points(PackedVector2Array([p1, p2]), width * 0.8, InkStroke.Profile.UNIFORM, ink).draw_to(self)
			
	# Phase 3: Center hands (0.75 to 1.0)
	if draw_progress > 0.75:
		var hands_prog := clampf((draw_progress - 0.75) / 0.25, 0.0, 1.0)
		draw_circle(Vector2.ZERO, width * 0.9, ink)
		# Hour hand (pointing to 2 o'clock)
		var h_ang := deg_to_rad(-30.0)
		var h_end := Vector2(cos(h_ang), sin(h_ang)) * (r * 0.45 * hands_prog)
		InkStroke.from_points(PackedVector2Array([Vector2.ZERO, h_end]), width * 1.1, InkStroke.Profile.TAPER_END, ink).draw_to(self)
		# Minute hand (pointing to 6 o'clock)
		var m_ang := deg_to_rad(90.0)
		var m_end := Vector2(cos(m_ang), sin(m_ang)) * (r * 0.7 * hands_prog)
		InkStroke.from_points(PackedVector2Array([Vector2.ZERO, m_end]), width * 0.9, InkStroke.Profile.TAPER_END, ink).draw_to(self)

func _draw_mini_bridge(ink: Color, width: float) -> void:
	var w := doodle_size * 2.2
	var h := doodle_size * 1.1
	# Phase 1: Deck & Arch (0.0 to 0.4)
	if draw_progress > 0.0:
		var p1 := clampf(draw_progress / 0.4, 0.0, 1.0)
		var deck_pts := PackedVector2Array([
			Vector2(-w * 0.5, -h * 0.2),
			Vector2(-w * 0.5 + w * p1, -h * 0.2)
		])
		InkStroke.from_points(deck_pts, width * 1.1, InkStroke.Profile.UNIFORM, ink).draw_to(self)
		
		# Curved arch underneath
		var arch_pts := PackedVector2Array()
		var steps := 16
		var max_s := int(float(steps) * p1)
		for s in range(max_s + 1):
			var a := lerpf(PI, 0.0, float(s) / float(steps))
			arch_pts.append(Vector2(cos(a) * (w * 0.4), sin(a) * (-h * 0.6) + h * 0.4))
		if arch_pts.size() >= 2:
			InkStroke.from_points(arch_pts, width, InkStroke.Profile.UNIFORM, ink).draw_to(self)
			
	# Phase 2: Vertical Truss Columns (0.4 to 0.75)
	if draw_progress > 0.4:
		var p2 := clampf((draw_progress - 0.4) / 0.35, 0.0, 1.0)
		var cols := 5
		for c in range(int(float(cols) * p2)):
			var x := lerpf(-w * 0.35, w * 0.35, float(c) / float(cols - 1))
			var top := Vector2(x, -h * 0.2)
			var bot := Vector2(x, h * 0.4)
			InkStroke.from_points(PackedVector2Array([top, bot]), width * 0.7, InkStroke.Profile.UNIFORM, ink).draw_to(self)
			
	# Phase 3: Victorian suspension / measurement annotations (0.75 to 1.0)
	if draw_progress > 0.75:
		var p3 := clampf((draw_progress - 0.75) / 0.25, 0.0, 1.0)
		# Dimension arrow underneath
		var a1 := Vector2(-w * 0.45, h * 0.55)
		var a2 := a1 + Vector2(w * 0.9 * p3, 0.0)
		InkStroke.from_points(PackedVector2Array([a1, a2]), width * 0.65, InkStroke.Profile.TAPER_BOTH, ink).draw_to(self)
		if p3 >= 0.8:
			var font: Font = ThemeDB.fallback_font
			draw_string(font, Vector2(-18.0, h * 0.8), "1884", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, ink)

func _draw_mini_banana(ink: Color, width: float) -> void:
	var sz := doodle_size * 0.9
	# Outer banana peel curves
	var p1 := clampf(draw_progress / 0.5, 0.0, 1.0)
	var left_peel := PackedVector2Array([
		Vector2(0.0, -sz * 0.7),
		Vector2(-sz * 0.4 * p1, -sz * 0.1),
		Vector2(-sz * 0.75 * p1, sz * 0.5)
	])
	var right_peel := PackedVector2Array([
		Vector2(0.0, -sz * 0.7),
		Vector2(sz * 0.4 * p1, -sz * 0.1),
		Vector2(sz * 0.75 * p1, sz * 0.5)
	])
	var center_peel := PackedVector2Array([
		Vector2(0.0, -sz * 0.7),
		Vector2(0.0, sz * 0.6 * p1)
	])
	
	if color_mode == ColorMode.COLOR and draw_progress >= 0.8:
		# Draw soft yellow peel polygon
		var peel_poly := PackedVector2Array([
			Vector2(0.0, -sz * 0.7),
			Vector2(sz * 0.75, sz * 0.5),
			Vector2(0.0, sz * 0.6),
			Vector2(-sz * 0.75, sz * 0.5)
		])
		draw_colored_polygon(peel_poly, Color("#ffeb3b"))
		
	InkStroke.from_points(left_peel, width, InkStroke.Profile.TAPER_END, ink).draw_to(self)
	InkStroke.from_points(right_peel, width, InkStroke.Profile.TAPER_END, ink).draw_to(self)
	InkStroke.from_points(center_peel, width, InkStroke.Profile.TAPER_END, ink).draw_to(self)
	
	# Stem and slip dashes
	if draw_progress >= 0.85:
		InkStroke.from_points(PackedVector2Array([Vector2(0.0, -sz * 0.7), Vector2(-sz * 0.12, -sz * 0.9)]), width * 1.2, InkStroke.Profile.TAPER_START, ink).draw_to(self)
		# Slip motion dashes
		draw_line(Vector2(-sz * 0.8, sz * 0.65), Vector2(-sz * 0.4, sz * 0.65), ink, width * 0.75)
		draw_line(Vector2(sz * 0.4, sz * 0.65), Vector2(sz * 0.8, sz * 0.65), ink, width * 0.75)

func _draw_mini_note(ink: Color, width: float) -> void:
	var sz := doodle_size * 0.8
	# Phase 1: Noteheads (0.0 to 0.4)
	var p1 := clampf(draw_progress / 0.4, 0.0, 1.0)
	var head_pts := PackedVector2Array()
	for i in range(16):
		var a := float(i) * TAU / 15.0
		head_pts.append(Vector2(cos(a) * (sz * 0.28 * p1), sin(a) * (sz * 0.2 * p1)).rotated(deg_to_rad(-25.0)))
	if head_pts.size() >= 3:
		draw_colored_polygon(head_pts, _get_accent_color(ink))
		
	# Phase 2: Vertical Stem (0.4 to 0.7)
	if draw_progress > 0.4:
		var p2 := clampf((draw_progress - 0.4) / 0.3, 0.0, 1.0)
		var stem_start := Vector2(sz * 0.22, 0.0)
		var stem_end := stem_start + Vector2(0.0, -sz * 0.95 * p2)
		InkStroke.from_points(PackedVector2Array([stem_start, stem_end]), width * 1.1, InkStroke.Profile.UNIFORM, ink).draw_to(self)
		
	# Phase 3: Flag / Beam (0.7 to 1.0)
	if draw_progress > 0.7:
		var p3 := clampf((draw_progress - 0.7) / 0.3, 0.0, 1.0)
		var flag_start := Vector2(sz * 0.22, -sz * 0.95)
		var flag_mid := flag_start + Vector2(sz * 0.35 * p3, sz * 0.15 * p3)
		var flag_end := flag_start + Vector2(sz * 0.25 * p3, sz * 0.45 * p3)
		var curve := Curve2D.new()
		curve.add_point(flag_start)
		curve.add_point(flag_mid)
		curve.add_point(flag_end)
		InkStroke.from_curve(curve, width * 1.2, InkStroke.Profile.TAPER_END, ink).draw_to(self)

func _draw_mini_dumbbell(ink: Color, width: float) -> void:
	var sz := doodle_size * 0.9
	var p := clampf(draw_progress, 0.0, 1.0)
	# Center Bar
	var bar_start := Vector2(-sz * 0.7 * p, 0.0)
	var bar_end := Vector2(sz * 0.7 * p, 0.0)
	InkStroke.from_points(PackedVector2Array([bar_start, bar_end]), width * 1.2, InkStroke.Profile.UNIFORM, ink).draw_to(self)
	
	# Left Weights
	if draw_progress >= 0.4:
		var p_left := clampf((draw_progress - 0.4) / 0.3, 0.0, 1.0)
		var w1 := PackedVector2Array([Vector2(-sz * 0.6, -sz * 0.45 * p_left), Vector2(-sz * 0.6, sz * 0.45 * p_left)])
		var w2 := PackedVector2Array([Vector2(-sz * 0.75, -sz * 0.35 * p_left), Vector2(-sz * 0.75, sz * 0.35 * p_left)])
		InkStroke.from_points(w1, width * 1.8, InkStroke.Profile.UNIFORM, ink).draw_to(self)
		InkStroke.from_points(w2, width * 1.5, InkStroke.Profile.UNIFORM, ink).draw_to(self)
		
	# Right Weights
	if draw_progress >= 0.7:
		var p_right := clampf((draw_progress - 0.7) / 0.3, 0.0, 1.0)
		var w3 := PackedVector2Array([Vector2(sz * 0.6, -sz * 0.45 * p_right), Vector2(sz * 0.6, sz * 0.45 * p_right)])
		var w4 := PackedVector2Array([Vector2(sz * 0.75, -sz * 0.35 * p_right), Vector2(sz * 0.75, sz * 0.35 * p_right)])
		InkStroke.from_points(w3, width * 1.8, InkStroke.Profile.UNIFORM, ink).draw_to(self)
		InkStroke.from_points(w4, width * 1.5, InkStroke.Profile.UNIFORM, ink).draw_to(self)

func _draw_mini_calendar(ink: Color, width: float) -> void:
	var sz := doodle_size * 0.85
	# Outer Page Rectangle
	var p := clampf(draw_progress / 0.5, 0.0, 1.0)
	var rect_pts := PackedVector2Array([
		Vector2(-sz * 0.75, -sz * 0.8),
		Vector2(-sz * 0.75 + sz * 1.5 * p, -sz * 0.8),
		Vector2(-sz * 0.75 + sz * 1.5 * p, -sz * 0.8 + sz * 1.6 * p),
		Vector2(-sz * 0.75, -sz * 0.8 + sz * 1.6 * p)
	])
	if draw_progress >= 0.5:
		draw_colored_polygon(rect_pts, _get_accent_color(Color("#ffffff")))
	var outline_pts := rect_pts.duplicate()
	outline_pts.append(rect_pts[0])
	InkStroke.from_points(outline_pts, width, InkStroke.Profile.UNIFORM, ink).draw_to(self)
	
	# Header & Spiral rings
	if draw_progress >= 0.5:
		var p2 := clampf((draw_progress - 0.5) / 0.25, 0.0, 1.0)
		# Red top banner in color mode
		if color_mode == ColorMode.COLOR:
			var banner := PackedVector2Array([
				Vector2(-sz * 0.75, -sz * 0.8), Vector2(sz * 0.75, -sz * 0.8),
				Vector2(sz * 0.75, -sz * 0.4), Vector2(-sz * 0.75, -sz * 0.4)
			])
			draw_colored_polygon(banner, Color("#ef5350"))
		draw_line(Vector2(-sz * 0.75, -sz * 0.4), Vector2(sz * 0.75 * p2, -sz * 0.4), ink, width)
		# Spiral rings
		var ring_offsets: Array[float] = [-0.4, 0.0, 0.4]
		for r_offset in ring_offsets:
			draw_circle(Vector2(sz * r_offset, -sz * 0.85), width * 0.8, ink)
			
	# Grid / Circled Date
	if draw_progress >= 0.75:
		# Circled date accent
		var circle_pts := PackedVector2Array()
		for i in range(13):
			var a := float(i) * TAU / 12.0
			circle_pts.append(Vector2(sz * 0.15 + cos(a) * (sz * 0.22), sz * 0.15 + sin(a) * (sz * 0.22)))
		InkStroke.from_points(circle_pts, width, InkStroke.Profile.TAPER_BOTH, Color("#d32f2f") if color_mode == ColorMode.COLOR else ink).draw_to(self)

func _draw_mini_brain(ink: Color, width: float) -> void:
	var sz := doodle_size * 0.85
	# Outer convoluted contours
	var p := clampf(draw_progress / 0.6, 0.0, 1.0)
	var pts := PackedVector2Array()
	var steps := 24
	var max_s := int(float(steps) * p)
	for i in range(max_s + 1):
		var a := float(i) * TAU / float(steps)
		var r := sz * (0.75 + sin(a * 5.0) * 0.12)
		pts.append(Vector2(cos(a) * r, sin(a) * (r * 0.85)))
	if draw_progress >= 0.6 and p >= 0.98:
		var poly := PackedVector2Array()
		for s in range(steps):
			var a := float(s) * TAU / float(steps)
			var r := sz * (0.75 + sin(a * 5.0) * 0.12)
			poly.append(Vector2(cos(a) * r, sin(a) * (r * 0.85)))
		draw_colored_polygon(poly, _get_accent_color(Color("#f8bbd0")))
	if pts.size() >= 2:
		InkStroke.from_points(pts, width, InkStroke.Profile.UNIFORM, ink).draw_to(self)
	
	# Interior sulci wrinkle lines
	if draw_progress >= 0.6:
		var p2 := clampf((draw_progress - 0.6) / 0.4, 0.0, 1.0)
		var w1 := PackedVector2Array([Vector2(-sz * 0.4, -sz * 0.1), Vector2(-sz * 0.1, 0.0), Vector2(-sz * 0.3 * p2, sz * 0.25 * p2)])
		var w2 := PackedVector2Array([Vector2(sz * 0.1, -sz * 0.3), Vector2(sz * 0.35 * p2, -sz * 0.05), Vector2(sz * 0.2 * p2, sz * 0.3 * p2)])
		InkStroke.from_points(w1, width * 0.8, InkStroke.Profile.TAPER_BOTH, ink).draw_to(self)
		InkStroke.from_points(w2, width * 0.8, InkStroke.Profile.TAPER_BOTH, ink).draw_to(self)

func _draw_mini_magnifier(ink: Color, width: float) -> void:
	var r := doodle_size * 0.55
	# Rim
	var p1 := clampf(draw_progress / 0.6, 0.0, 1.0)
	var pts := PackedVector2Array()
	var steps := 20
	for i in range(int(float(steps) * p1) + 1):
		var a := float(i) * TAU / float(steps)
		pts.append(Vector2(-r * 0.4 + cos(a) * r, -r * 0.4 + sin(a) * r))
	if p1 >= 0.98:
		var poly := PackedVector2Array()
		for s in range(steps):
			var a := float(s) * TAU / float(steps)
			poly.append(Vector2(-r * 0.4 + cos(a) * r, -r * 0.4 + sin(a) * r))
		draw_colored_polygon(poly, _get_accent_color(Color("#e0f7fa")))
	if pts.size() >= 2:
		InkStroke.from_points(pts, width * 1.15, InkStroke.Profile.UNIFORM, ink).draw_to(self)
		
	# Handle
	if draw_progress >= 0.6:
		var p2 := clampf((draw_progress - 0.6) / 0.4, 0.0, 1.0)
		var h_start := Vector2(-r * 0.4 + cos(deg_to_rad(45.0)) * r, -r * 0.4 + sin(deg_to_rad(45.0)) * r)
		var h_end := h_start + Vector2(r * 1.3 * p2, r * 1.3 * p2)
		InkStroke.from_points(PackedVector2Array([h_start, h_end]), width * 1.6, InkStroke.Profile.TAPER_START, ink).draw_to(self)

func _draw_mini_car(ink: Color, width: float) -> void:
	var sz := doodle_size * 1.1
	var p := clampf(draw_progress, 0.0, 1.0)
	# Wheels (0.0 to 0.3)
	var w_r := sz * 0.18
	if p > 0.0:
		draw_circle(Vector2(-sz * 0.45, sz * 0.3), w_r, ink)
		draw_circle(Vector2(sz * 0.45, sz * 0.3), w_r, ink)
		
	# Chassis & Cabin (0.3 to 0.8)
	if p >= 0.3:
		var p_body := clampf((p - 0.3) / 0.5, 0.0, 1.0)
		var body := PackedVector2Array([
			Vector2(-sz * 0.75, sz * 0.2),
			Vector2(-sz * 0.75, 0.0),
			Vector2(-sz * 0.35, -sz * 0.05),
			Vector2(-sz * 0.15, -sz * 0.45),
			Vector2(sz * 0.25, -sz * 0.45),
			Vector2(sz * 0.55, 0.0),
			Vector2(sz * 0.8, sz * 0.05),
			Vector2(sz * 0.8, sz * 0.2)
		])
		var drawn_body := PackedVector2Array()
		for i in range(int(float(body.size()) * p_body) + 1):
			if i < body.size(): drawn_body.append(body[i])
		if drawn_body.size() >= 2:
			InkStroke.from_points(drawn_body, width, InkStroke.Profile.UNIFORM, ink).draw_to(self)
			
	# Window split & exhaust puff (0.8 to 1.0)
	if p >= 0.8:
		draw_line(Vector2(0.05 * sz, -sz * 0.45), Vector2(0.05 * sz, 0.0), ink, width * 0.8)

func _draw_mini_person(ink: Color, width: float) -> void:
	var sz := doodle_size * 0.9
	var p := clampf(draw_progress, 0.0, 1.0)
	# Head
	if p > 0.0:
		var head_r := sz * 0.25 * clampf(p / 0.3, 0.0, 1.0)
		draw_circle(Vector2(0.0, -sz * 0.7), head_r, ink)
	# Spine
	if p >= 0.3:
		var p_torso := clampf((p - 0.3) / 0.25, 0.0, 1.0)
		draw_line(Vector2(0.0, -sz * 0.45), Vector2(0.0, -sz * 0.45 + sz * 0.6 * p_torso), ink, width)
	# Legs
	if p >= 0.55:
		var p_legs := clampf((p - 0.55) / 0.25, 0.0, 1.0)
		var hip := Vector2(0.0, sz * 0.15)
		draw_line(hip, hip + Vector2(-sz * 0.3 * p_legs, sz * 0.55 * p_legs), ink, width)
		draw_line(hip, hip + Vector2(sz * 0.3 * p_legs, sz * 0.55 * p_legs), ink, width)
	# Arms raised
	if p >= 0.8:
		var p_arms := clampf((p - 0.8) / 0.2, 0.0, 1.0)
		var shoulder := Vector2(0.0, -sz * 0.3)
		draw_line(shoulder, shoulder + Vector2(-sz * 0.4 * p_arms, -sz * 0.25 * p_arms), ink, width)
		draw_line(shoulder, shoulder + Vector2(sz * 0.4 * p_arms, -sz * 0.25 * p_arms), ink, width)

# -------------------------------------------------------------------------
# LEGACY / COMIC ACCENT METHODS (PRESERVED)
# -------------------------------------------------------------------------
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
		draw_colored_polygon(pts, _get_accent_color(Color("#f06292")))
		var stroke := InkStroke.from_points(pts, width, InkStroke.Profile.UNIFORM, ink)
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
		draw_colored_polygon(pts, _get_accent_color(Color("#ffeb3b")))
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
	draw_colored_polygon(pts, _get_accent_color(Color(0.72, 0.88, 0.95, 0.55)))
	var stroke_pts := pts.duplicate(); stroke_pts.append(pts[0])
	var stroke := InkStroke.from_points(stroke_pts, width, InkStroke.Profile.UNIFORM, ink)
	stroke.draw_to(self)

func _draw_speech_bubble(ink: Color, width: float) -> void:
	var w := doodle_size * 1.2
	var h := doodle_size * 0.65
	var rect_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5), Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.5, h * 0.5), Vector2(8.0, h * 0.5),
		Vector2(0.0, h * 0.8), Vector2(-6.0, h * 0.5),
		Vector2(-w * 0.5, h * 0.5)
	])
	draw_colored_polygon(rect_pts, _get_accent_color(Color("#ffffff")))
	var stroke_pts := rect_pts.duplicate(); stroke_pts.append(rect_pts[0])
	var stroke := InkStroke.from_points(stroke_pts, width, InkStroke.Profile.UNIFORM, ink)
	stroke.draw_to(self)
	
	if custom_text != "":
		var font: Font = ThemeDB.fallback_font
		var str_sz := font.get_string_size(custom_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
		var text_pos := Vector2(-str_sz.x * 0.5, str_sz.y * 0.35)
		draw_string(font, text_pos, custom_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, ink)

func _draw_thought_bubble(ink: Color, width: float) -> void:
	var w := doodle_size * 1.2
	var h := doodle_size * 0.65
	var cloud_pts := PackedVector2Array([
		Vector2(-w * 0.45, -h * 0.3), Vector2(-w * 0.25, -h * 0.55),
		Vector2(w * 0.25, -h * 0.55), Vector2(w * 0.45, -h * 0.3),
		Vector2(w * 0.5, 0.0), Vector2(w * 0.4, h * 0.45),
		Vector2(-w * 0.3, h * 0.45), Vector2(-w * 0.5, 0.0)
	])
	draw_colored_polygon(cloud_pts, _get_accent_color(Color("#ffffff")))
	var stroke_pts := cloud_pts.duplicate(); stroke_pts.append(cloud_pts[0])
	var stroke := InkStroke.from_points(stroke_pts, width, InkStroke.Profile.UNIFORM, ink)
	stroke.draw_to(self)
	draw_circle(Vector2(-8.0, h * 0.65), 2.5, ink)
	draw_circle(Vector2(-14.0, h * 0.85), 1.5, ink)
	
	if custom_text != "":
		var font: Font = ThemeDB.fallback_font
		var str_sz := font.get_string_size(custom_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
		var text_pos := Vector2(-str_sz.x * 0.5, str_sz.y * 0.35)
		draw_string(font, text_pos, custom_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, ink)

func _draw_shock_lines(ink: Color, width: float) -> void:
	for i in range(4):
		var ox := float(i - 2) * 8.0
		var stroke := InkStroke.from_points(PackedVector2Array([Vector2(ox, 0.0), Vector2(ox, 22.0 * draw_progress)]), width, InkStroke.Profile.TAPER_BOTH, ink)
		stroke.draw_to(self)
