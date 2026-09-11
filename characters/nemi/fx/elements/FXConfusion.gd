class_name FXConfusion
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn confusion reactions:
## Calligraphic question mark(s), floating confusion squiggles, and curved curiosity ticks.

enum Mode {
	QUESTION,
	DOUBLE_QUESTION,
	SQUIGGLE,
	QUESTION_AND_SQUIGGLE
}

@export var mode: Mode = Mode.QUESTION_AND_SQUIGGLE

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.HEAD_RIGHT
	anchor_offset = Vector2(45.0, -82.0)
	entrance_style = EntranceStyle.POP
	exit_style = ExitStyle.FADE
	auto_dismiss_time = 1.4

func _draw() -> void:
	var scale_factor: float = 0.8 + (float(intensity) * 0.15)
	
	match mode:
		Mode.QUESTION:
			_draw_single_question_mark(Vector2.ZERO, scale_factor)
		Mode.DOUBLE_QUESTION:
			_draw_single_question_mark(Vector2(-12, 4), scale_factor * 0.9)
			_draw_single_question_mark(Vector2(12, -4), scale_factor * 1.15)
		Mode.SQUIGGLE:
			_draw_confusion_squiggle(Vector2(0, 0), scale_factor)
		Mode.QUESTION_AND_SQUIGGLE:
			if intensity <= 2:
				_draw_single_question_mark(Vector2.ZERO, scale_factor)
			elif intensity <= 4:
				_draw_single_question_mark(Vector2(-8, -2), scale_factor)
				_draw_confusion_squiggle(Vector2(18, 12), scale_factor * 0.8)
			else: # Intensity 5: double questions + agitated squiggle
				_draw_single_question_mark(Vector2(-16, 2), scale_factor * 0.9)
				_draw_single_question_mark(Vector2(8, -8), scale_factor * 1.2)
				_draw_confusion_squiggle(Vector2(26, 14), scale_factor * 1.1)

func _draw_single_question_mark(pos: Vector2, s: float) -> void:
	var size: float = 24.0 * s
	var c := Curve2D.new()
	# Calligraphic question mark hook
	c.add_point(pos + Vector2(-size * 0.28, -size * 0.65), Vector2(0, 0), Vector2(size * 0.2, -size * 0.25))
	c.add_point(pos + Vector2(size * 0.25, -size * 0.72), Vector2(-size * 0.2, 0), Vector2(0, size * 0.35))
	c.add_point(pos + Vector2(size * 0.02, -size * 0.24), Vector2(size * 0.1, -size * 0.1), Vector2(-size * 0.05, size * 0.1))
	c.add_point(pos + Vector2(0.0, -size * 0.05))
	
	var q_col := accent_color if (not is_monochrome and intensity >= 3) else ink_color
	draw_ink_curve(self, c, 2.6 * s, InkStroke.Profile.TAPER_START, q_col)
	
	# Bottom dot
	var dot_pos := pos + Vector2(0.0, size * 0.20)
	var dot_r := 2.2 * s
	if draw_progress >= 0.85 and erase_progress < 0.95:
		draw_circle(dot_pos, dot_r, q_col)

func _draw_confusion_squiggle(pos: Vector2, s: float) -> void:
	var c := Curve2D.new()
	var w: float = 22.0 * s
	c.add_point(pos + Vector2(-w * 0.5, 0.0), Vector2(0, 0), Vector2(w * 0.15, -6 * s))
	c.add_point(pos + Vector2(-w * 0.2, -4 * s), Vector2(-w * 0.1, 0), Vector2(w * 0.1, 0))
	c.add_point(pos + Vector2(w * 0.1, 4 * s), Vector2(-w * 0.1, 0), Vector2(w * 0.1, 0))
	c.add_point(pos + Vector2(w * 0.5, -2 * s), Vector2(-w * 0.15, 6 * s), Vector2(0, 0))
	
	draw_ink_curve(self, c, 2.0 * s, InkStroke.Profile.TAPER_BOTH, ink_color)
