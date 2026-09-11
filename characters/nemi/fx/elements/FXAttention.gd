class_name FXAttention
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn visual attention directors:
## Sketchy circle loops, calligraphic directional arrows, and highlight underlines.

enum AttentionType {
	CIRCLE,
	ARROW,
	HIGHLIGHT_UNDERLINE
}

@export var attention_type: AttentionType = AttentionType.CIRCLE
@export var target_offset: Vector2 = Vector2.ZERO
@export var circle_radius: float = 38.0
@export var arrow_start: Vector2 = Vector2(-60.0, -40.0)
@export var arrow_end: Vector2 = Vector2.ZERO

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.CUSTOM
	entrance_style = EntranceStyle.DRAW_ON
	exit_style = ExitStyle.ERASE
	auto_dismiss_time = 1.8

func _draw() -> void:
	var s: float = 0.85 + (float(intensity) * 0.15)
	var stroke_col := accent_color if (not is_monochrome and intensity >= 3) else ink_color
	
	match attention_type:
		AttentionType.CIRCLE:
			_draw_sketchy_circle(target_offset, circle_radius * s, stroke_col)
		AttentionType.ARROW:
			_draw_hand_drawn_arrow(arrow_start, arrow_end, s, stroke_col)
		AttentionType.HIGHLIGHT_UNDERLINE:
			_draw_highlight_underline(target_offset, 60.0 * s, stroke_col)

func _draw_sketchy_circle(center: Vector2, r: float, col: Color) -> void:
	var c := Curve2D.new()
	var steps: int = 14
	# Slight oval irregularity and overlap at the end for an authentic drawn circle
	for i in range(steps + 3): # 3 extra steps to overlap start
		var ang := float(i) * PI * 2.0 / float(steps)
		var rad := r * (1.0 + sin(float(i) * 1.7) * 0.08)
		c.add_point(center + Vector2(cos(ang) * rad * 1.1, sin(ang) * rad * 0.9))
	
	draw_ink_curve(self, c, 2.4, InkStroke.Profile.TAPER_START, col)

func _draw_hand_drawn_arrow(start_pt: Vector2, end_pt: Vector2, s: float, col: Color) -> void:
	# Curved shaft
	var c := Curve2D.new()
	var mid := (start_pt + end_pt) * 0.5 + Vector2(-(end_pt.y - start_pt.y) * 0.25, (end_pt.x - start_pt.x) * 0.25)
	c.add_point(start_pt)
	c.add_point(mid)
	c.add_point(end_pt)
	draw_ink_curve(self, c, 2.6 * s, InkStroke.Profile.TAPER_START, col)
	
	# Arrowhead barbed wings (drawn when shaft is >= 75% drawn)
	if draw_progress >= 0.75:
		var dir := (end_pt - mid).normalized()
		var norm := Vector2(-dir.y, dir.x)
		var head_len: float = 14.0 * s
		var wing1 := end_pt - dir * head_len + norm * (head_len * 0.6)
		var wing2 := end_pt - dir * head_len - norm * (head_len * 0.6)
		
		draw_ink_stroke(self, PackedVector2Array([wing1, end_pt]), 2.2 * s, InkStroke.Profile.TAPER_BOTH, col)
		draw_ink_stroke(self, PackedVector2Array([wing2, end_pt]), 2.2 * s, InkStroke.Profile.TAPER_BOTH, col)

func _draw_highlight_underline(center: Vector2, width: float, col: Color) -> void:
	var c := Curve2D.new()
	var half_w := width * 0.5
	c.add_point(center + Vector2(-half_w, 0))
	c.add_point(center + Vector2(0, 2.5))
	c.add_point(center + Vector2(half_w, -1.0))
	draw_ink_curve(self, c, 3.2, InkStroke.Profile.TAPER_BOTH, col)
