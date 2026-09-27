class_name Ep06InteractiveTimeline
extends Node2D

## Ep06InteractiveTimeline - Hand-Drawn Storytime Timeline Prop
## Authentic hand-drawn visual timeline with organic pen-and-ink styling.
## Shows:
## - "VOICE" header and organic horizontal audio waveform track
## - Storytelling beat markers: EXPLAIN, REACTION, JOKE, PAUSE, CUTAWAY
## - Interactive marker highlighting and callouts
## - Smooth reveal and erase stroke animations

const InkStroke = preload("res://nemi/characters/nemi/drawing/InkStroke.gd")

const INK_MAIN: Color = Color("#2e1822")
const INK_MUTED: Color = Color("#7a6572")
const INK_ACCENT: Color = Color("#d63031")
const PAPER_BG: Color = Color("#fffdf8")
const HIGHLIGHT_COL: Color = Color("#ffeaa7")

var reveal_progress: float = 0.0
var active_beat_idx: int = -1 # -1 = none
var show_waveform: bool = true
var waveform_amplitude: float = 1.0

var beat_markers: Array[Dictionary] = [
	{"name": "EXPLAIN", "x": 120.0, "type": "explain", "annot": "body posture"},
	{"name": "REACTION", "x": 300.0, "type": "react", "annot": "eyes / tilt"},
	{"name": "JOKE", "x": 490.0, "type": "joke", "annot": "comic pause"},
	{"name": "PAUSE", "x": 670.0, "type": "pause", "annot": "silence"},
	{"name": "CUTAWAY", "x": 860.0, "type": "cutaway", "annot": "visual gag"},
	{"name": "REACTION", "x": 1050.0, "type": "react", "annot": "settle"}
]

var _active_tween: Tween

func _ready() -> void:
	z_index = 15
	queue_redraw()

func animate_reveal(duration: float = 0.6) -> Signal:
	reveal_progress = 0.0
	visible = true
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "reveal_progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.step_finished.connect(func(_idx): queue_redraw())
	_active_tween.finished.connect(queue_redraw)
	return _active_tween.finished

func animate_dismiss(duration: float = 0.4) -> Signal:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "reveal_progress", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_active_tween.step_finished.connect(func(_idx): queue_redraw())
	_active_tween.finished.connect(func(): visible = false; queue_redraw())
	return _active_tween.finished

func highlight_beat(idx: int) -> void:
	active_beat_idx = idx
	queue_redraw()

func _draw() -> void:
	if reveal_progress <= 0.001:
		return

	var total_w := 1020.0 * reveal_progress
	var track_y := 40.0
	var start_x := 80.0
	var end_x := start_x + total_w

	# 1. Timeline Card Base (Hand-drawn rounded rectangle)
	var card_rect_pts := PackedVector2Array([
		Vector2(start_x - 30.0, -25.0),
		Vector2(end_x + 30.0, -25.0),
		Vector2(end_x + 30.0, 115.0),
		Vector2(start_x - 30.0, 115.0)
	])
	draw_colored_polygon(card_rect_pts, Color(1.0, 0.99, 0.96, 0.92))
	
	# Hand-drawn ink contour for card
	var card_loop := card_rect_pts.duplicate()
	card_loop.append(card_rect_pts[0])
	var border_stroke := InkStroke.from_points(card_loop, 3.0, InkStroke.Profile.UNIFORM, INK_MAIN)
	border_stroke.draw_to(self)

	# 2. "VOICE" Label & Subtitle
	draw_string(ThemeDB.fallback_font, Vector2(start_x - 10.0, 5.0), "VOICE (MASTER CLOCK)", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, INK_MAIN)

	# 3. Main Center Track Line (Hand-drawn ink line)
	draw_line(Vector2(start_x, track_y), Vector2(end_x, track_y), INK_MAIN, 3.2)

	# 4. Stylized undulating audio waveform strokes along the track
	if show_waveform and total_w > 80.0:
		var wave_pts := PackedVector2Array()
		var wave_step := 8.0
		var max_steps := int(total_w / wave_step)
		for s in range(max_steps):
			var wx := start_x + float(s) * wave_step
			var wave_h := sin(float(s) * 0.45) * 12.0 * waveform_amplitude
			if s % 3 == 0:
				wave_h *= 1.4
			wave_pts.append(Vector2(wx, track_y + wave_h))
		if wave_pts.size() >= 2:
			var wave_stroke := InkStroke.from_points(wave_pts, 1.8, InkStroke.Profile.TAPER_BOTH, Color("#e17055"))
			wave_stroke.draw_to(self)

	# 5. Beat Markers & Hand-Drawn Cards
	for i in range(beat_markers.size()):
		var bm = beat_markers[i]
		var mx: float = bm["x"]
		if mx > end_x:
			continue

		var is_active: bool = (i == active_beat_idx)
		var marker_col: Color = INK_ACCENT if is_active else INK_MAIN
		var box_bg: Color = HIGHLIGHT_COL if is_active else PAPER_BG

		# Marker vertical tick line
		draw_line(Vector2(mx, track_y - 18.0), Vector2(mx, track_y + 18.0), marker_col, 3.0 if is_active else 2.0)

		# Marker Tag Card
		var tag_w := 90.0
		var tag_h := 30.0
		var tag_box := PackedVector2Array([
			Vector2(mx - tag_w * 0.5, track_y + 22.0),
			Vector2(mx + tag_w * 0.5, track_y + 22.0),
			Vector2(mx + tag_w * 0.5, track_y + 22.0 + tag_h),
			Vector2(mx - tag_w * 0.5, track_y + 22.0 + tag_h)
		])
		draw_colored_polygon(tag_box, box_bg)
		
		# Tag box ink border
		var tag_loop := tag_box.duplicate()
		tag_loop.append(tag_box[0])
		var tag_stroke := InkStroke.from_points(tag_loop, 2.2 if is_active else 1.6, InkStroke.Profile.UNIFORM, marker_col)
		tag_stroke.draw_to(self)

		# Tag Name Text
		draw_string(ThemeDB.fallback_font, Vector2(mx - tag_w * 0.45, track_y + 42.0), bm["name"], HORIZONTAL_ALIGNMENT_CENTER, int(tag_w * 0.9), 13, marker_col)

		# Sub-annotation underneath if active
		if is_active:
			draw_string(ThemeDB.fallback_font, Vector2(mx - tag_w * 0.5, track_y + 68.0), bm["annot"], HORIZONTAL_ALIGNMENT_CENTER, int(tag_w), 11, INK_MUTED)
			# Small bouncy arrow pointing up at marker
			draw_line(Vector2(mx, track_y - 28.0), Vector2(mx, track_y - 20.0), INK_ACCENT, 2.5)
			draw_line(Vector2(mx - 4.0, track_y - 24.0), Vector2(mx, track_y - 20.0), INK_ACCENT, 2.2)
			draw_line(Vector2(mx + 4.0, track_y - 24.0), Vector2(mx, track_y - 20.0), INK_ACCENT, 2.2)
