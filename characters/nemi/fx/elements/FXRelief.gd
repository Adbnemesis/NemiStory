class_name FXRelief
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn relief & sigh reaction:
## Curving exhale breath swoosh streak (sigh) and soft floating sparkles.

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.HEAD_RIGHT
	anchor_offset = Vector2(38.0, -40.0)
	entrance_style = EntranceStyle.SLIDE
	exit_style = ExitStyle.FADE
	auto_dismiss_time = 1.3

func _draw() -> void:
	var s: float = 0.85 + (float(intensity) * 0.16)
	
	# 1. Main curving exhale breath plume (swooshing rightward and slightly up)
	_draw_exhale_swoosh(Vector2.ZERO, s)
	
	# 2. Gentle soft sparkles of relaxation
	if intensity >= 3:
		_draw_soft_sparkle(Vector2(24 * s, -14 * s), 7.0 * s)
	if intensity >= 5:
		_draw_soft_sparkle(Vector2(38 * s, 4 * s), 5.5 * s)
		_draw_soft_sparkle(Vector2(12 * s, -24 * s), 5.0 * s)

func _draw_exhale_swoosh(pos: Vector2, s: float) -> void:
	var c := Curve2D.new()
	var len_x: float = (30.0 + float(intensity) * 8.0) * s
	c.add_point(pos + Vector2(0, 0), Vector2(0, 0), Vector2(len_x * 0.35, -6 * s))
	c.add_point(pos + Vector2(len_x * 0.6, -4 * s), Vector2(-len_x * 0.2, 0), Vector2(len_x * 0.2, 0))
	c.add_point(pos + Vector2(len_x, -12 * s), Vector2(-len_x * 0.15, 6 * s), Vector2(0, 0))
	
	var col := Color(0.5, 0.7, 0.85, 0.75) if not is_monochrome else ink_color
	draw_ink_curve(self, c, 2.0 * s, InkStroke.Profile.TAPER_START, col)
	
	# Secondary smaller trailing curl
	var c2 := Curve2D.new()
	c2.add_point(pos + Vector2(len_x * 0.3, 4 * s), Vector2(0, 0), Vector2(len_x * 0.2, -4 * s))
	c2.add_point(pos + Vector2(len_x * 0.75, 2 * s))
	draw_ink_curve(self, c2, 1.4 * s, InkStroke.Profile.TAPER_BOTH, col)

func _draw_soft_sparkle(pos: Vector2, size: float) -> void:
	var pts := PackedVector2Array()
	for i in range(8):
		var ang := float(i) * PI * 0.25
		var r: float = size if (i % 2 == 0) else (size * 0.25)
		pts.append(pos + Vector2(cos(ang) * r, sin(ang) * r))
	
	if pts.size() >= 3 and draw_progress >= 0.3:
		var fill := Color("#fff9d4", 0.85) if not is_monochrome else Color(0.9, 0.9, 0.9, 0.8)
		draw_colored_polygon(pts, fill)
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_ink_stroke(self, closed, 1.2, InkStroke.Profile.UNIFORM, ink_color)
