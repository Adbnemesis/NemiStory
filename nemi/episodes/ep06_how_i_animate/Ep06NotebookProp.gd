class_name Ep06NotebookProp
extends Node2D

## Ep06NotebookProp - Hand-Drawn Spiral Notebook for Beat 3
## Individually authored pen-and-ink spiral notebook.
## Features:
## - Organic cream lined pages with soft pastel sage-teal cover
## - Spiral wire coils along left edge
## - Hand-drawn ink lines representing story text
## - Animated cross-out stroke for "crossing out the boring parts"
## - Cause-and-effect interaction states (open, writing, crossing out)

const InkStroke = preload("res://nemi/characters/nemi/drawing/InkStroke.gd")

const INK_MAIN: Color = Color("#2e1822")
const INK_MUTED: Color = Color("#7a6572")
const INK_RED: Color = Color("#c0392b")
const PAPER_BG: Color = Color("#fffdf8")
const COVER_COL: Color = Color("#7f9f93")

var crossout_progress: float = 0.0
var _active_tween: Tween

func _ready() -> void:
	z_index = 22
	queue_redraw()

func animate_crossout(duration: float = 0.3) -> Signal:
	crossout_progress = 0.0
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "crossout_progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.step_finished.connect(func(_idx): queue_redraw())
	_active_tween.finished.connect(queue_redraw)
	return _active_tween.finished

func _draw() -> void:
	var nw := 130.0 # Notebook width
	var nh := 170.0 # Notebook height

	# 1. Pastel Cover (Slanted slightly for organic look)
	var cover_pts := PackedVector2Array([
		Vector2(-nw * 0.5 - 6.0, -nh * 0.5 - 4.0),
		Vector2(nw * 0.5 + 4.0, -nh * 0.5 - 2.0),
		Vector2(nw * 0.5 + 2.0, nh * 0.5 + 5.0),
		Vector2(-nw * 0.5 - 8.0, nh * 0.5 + 3.0)
	])
	draw_colored_polygon(cover_pts, COVER_COL)
	var cover_stroke := InkStroke.from_points(cover_pts, 3.2, InkStroke.Profile.UNIFORM, INK_MAIN)
	cover_stroke.draw_to(self)

	# 2. Main Paper Page
	var page_pts := PackedVector2Array([
		Vector2(-nw * 0.5, -nh * 0.5),
		Vector2(nw * 0.5, -nh * 0.5),
		Vector2(nw * 0.5 - 2.0, nh * 0.5),
		Vector2(-nw * 0.5 - 2.0, nh * 0.5)
	])
	draw_colored_polygon(page_pts, PAPER_BG)
	var page_stroke := InkStroke.from_points(page_pts, 2.5, InkStroke.Profile.UNIFORM, INK_MAIN)
	page_stroke.draw_to(self)

	# 3. Notebook Margin Line (Soft pink vertical line)
	draw_line(Vector2(-nw * 0.5 + 24.0, -nh * 0.5 + 8.0), Vector2(-nw * 0.5 + 24.0, nh * 0.5 - 8.0), Color("#f8a5c2"), 1.4)

	# 4. Horizontal Ruled Lines & Story Notes
	var num_lines := 8
	var line_spacing := 16.0
	var start_y := -nh * 0.5 + 25.0
	for i in range(num_lines):
		var ly := start_y + float(i) * line_spacing
		draw_line(Vector2(-nw * 0.5 + 28.0, ly), Vector2(nw * 0.5 - 10.0, ly), Color("#dcdde1"), 1.0)
		
		# Script text ink lines
		if i == 0:
			draw_string(ThemeDB.fallback_font, Vector2(-nw * 0.5 + 30.0, ly - 2.0), "STORY IDEA #4", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, INK_MAIN)
		elif i == 1:
			draw_string(ThemeDB.fallback_font, Vector2(-nw * 0.5 + 30.0, ly - 2.0), "- what happened", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, INK_MUTED)
		elif i == 2:
			draw_string(ThemeDB.fallback_font, Vector2(-nw * 0.5 + 30.0, ly - 2.0), "- WHY it was funny", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, INK_MAIN)
		elif i == 3:
			draw_string(ThemeDB.fallback_font, Vector2(-nw * 0.5 + 30.0, ly - 2.0), "- 10 min explanation", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, INK_MUTED)
		elif i == 4:
			draw_string(ThemeDB.fallback_font, Vector2(-nw * 0.5 + 30.0, ly - 2.0), "- funny punchline!", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, INK_MAIN)

	# 5. Spiral Binding Rings on Left Edge
	var num_spirals := 10
	var spiral_spacing := (nh - 20.0) / float(num_spirals - 1)
	for s in range(num_spirals):
		var sy := -nh * 0.5 + 10.0 + float(s) * spiral_spacing
		var ring_pts := PackedVector2Array([
			Vector2(-nw * 0.5 - 2.0, sy - 3.0),
			Vector2(-nw * 0.5 - 12.0, sy - 1.0),
			Vector2(-nw * 0.5 - 12.0, sy + 3.0),
			Vector2(-nw * 0.5 - 1.0, sy + 5.0)
		])
		var ring_stroke := InkStroke.from_points(ring_pts, 2.0, InkStroke.Profile.UNIFORM, INK_MAIN)
		ring_stroke.draw_to(self)

	# 6. Animated Vigorous Red Cross-Out Stroke across line 3 ("10 min explanation")
	if crossout_progress > 0.01:
		var cross_y := start_y + 3.0 * line_spacing - 5.0
		var cross_start_x := -nw * 0.5 + 26.0
		var cross_end_x := cross_start_x + (nw * 0.8) * crossout_progress
		
		# Wobbly hand-drawn cross line
		var cross_pts := PackedVector2Array([
			Vector2(cross_start_x, cross_y),
			Vector2(cross_start_x + (cross_end_x - cross_start_x) * 0.5, cross_y + 2.0),
			Vector2(cross_end_x, cross_y - 3.0)
		])
		var cross_stroke := InkStroke.from_points(cross_pts, 3.0, InkStroke.Profile.TAPER_BOTH, INK_RED)
		cross_stroke.draw_to(self)
		
		# Second quick scratch-out strike
		if crossout_progress > 0.5:
			var cross2_pts := PackedVector2Array([
				Vector2(cross_start_x + 5.0, cross_y - 4.0),
				Vector2(cross_start_x + (cross_end_x - cross_start_x) * 0.6, cross_y - 1.0),
				Vector2(cross_end_x - 4.0, cross_y + 3.0)
			])
			var cross2_stroke := InkStroke.from_points(cross2_pts, 2.4, InkStroke.Profile.TAPER_BOTH, INK_RED)
			cross2_stroke.draw_to(self)
