class_name FXDeadpan
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn deadpan & awkward silence reaction:
## Restrained horizontal focus dash, triple dot ellipsis (...), and comic tumbleweed stillness tick.

enum DeadpanStyle {
	HORIZONTAL_DASH,
	ELLIPSIS,
	MINIMAL_TICK
}

## Default to HORIZONTAL_DASH (minimal, restrained). ELLIPSIS is strictly opt-in via nemi.fx("ellipsis").
@export var style_type: DeadpanStyle = DeadpanStyle.HORIZONTAL_DASH

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.FACE_CENTER
	anchor_offset = Vector2(32.0, -42.0) # Floating subtly to upper right of eye
	entrance_style = EntranceStyle.SNAP
	exit_style = ExitStyle.FADE
	auto_dismiss_time = 1.6

func _draw() -> void:
	var s: float = 0.85 + (float(intensity) * 0.15)
	
	match style_type:
		DeadpanStyle.HORIZONTAL_DASH:
			_draw_horizontal_dash(Vector2.ZERO, s)
		DeadpanStyle.ELLIPSIS:
			_draw_ellipsis(Vector2.ZERO, s)
		DeadpanStyle.MINIMAL_TICK:
			_draw_horizontal_dash(Vector2(0, -4), s)
			_draw_tumbleweed_tick(Vector2(20 * s, 10 * s), s)

func _draw_horizontal_dash(pos: Vector2, s: float) -> void:
	var len_x: float = (16.0 + float(intensity) * 4.0) * s
	var p1 := pos + Vector2(-len_x * 0.5, 0)
	var p2 := pos + Vector2(len_x * 0.5, 0)
	draw_ink_stroke(self, PackedVector2Array([p1, p2]), 1.8 * s, InkStroke.Profile.TAPER_BOTH, ink_color)

func _draw_ellipsis(pos: Vector2, s: float) -> void:
	var spacing: float = 8.0 * s
	var dot_r: float = 1.8 * s
	if draw_progress >= 0.25:
		draw_circle(pos + Vector2(-spacing, 0), dot_r, ink_color)
	if draw_progress >= 0.55:
		draw_circle(pos + Vector2(0, 0), dot_r, ink_color)
	if draw_progress >= 0.85:
		draw_circle(pos + Vector2(spacing, 0), dot_r, ink_color)

func _draw_tumbleweed_tick(pos: Vector2, s: float) -> void:
	var c := Curve2D.new()
	c.add_point(pos + Vector2(-6 * s, 4 * s))
	c.add_point(pos + Vector2(0, -4 * s))
	c.add_point(pos + Vector2(6 * s, 2 * s))
	draw_ink_curve(self, c, 1.3 * s, InkStroke.Profile.TAPER_BOTH, ink_color)
