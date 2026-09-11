class_name FXSad
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn sadness & gloom reaction:
## Downward vertical gloom hatch lines and falling illustrated teardrop beads.

enum SadStyle {
	GLOOM_LINES,
	TEARDROP,
	FULL_GLOOM
}

@export var style_type: SadStyle = SadStyle.FULL_GLOOM

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.HEAD_LEFT
	anchor_offset = Vector2(-36.0, -60.0)
	entrance_style = EntranceStyle.SLIDE
	exit_style = ExitStyle.FADE
	auto_dismiss_time = 1.4

func _draw() -> void:
	var s: float = 0.85 + (float(intensity) * 0.16)
	
	match style_type:
		SadStyle.GLOOM_LINES:
			_draw_gloom_lines(Vector2.ZERO, s)
		SadStyle.TEARDROP:
			_draw_teardrop(Vector2(0, 10 * s), s)
		SadStyle.FULL_GLOOM:
			_draw_gloom_lines(Vector2(0, -10 * s), s)
			_draw_teardrop(Vector2(4 * s, 14 * s), s)
			if intensity >= 4:
				_draw_teardrop(Vector2(-12 * s, 26 * s), s * 0.75) # Secondary teardrop

func _draw_gloom_lines(pos: Vector2, s: float) -> void:
	var count: int = 4 + intensity
	var span: float = 36.0 * s
	var line_len: float = (20.0 + float(intensity) * 6.0) * s
	
	var gloom_col := Color(0.24, 0.45, 0.65, 0.8) if not is_monochrome else ink_color
	for i in range(count):
		var x := lerpf(-span * 0.5, span * 0.5, float(i) / float(count - 1))
		var y_start := pos.y - line_len * 0.3 + sin(float(i) * 2.3) * 4.0 * s
		var p1 := Vector2(pos.x + x, y_start)
		var p2 := Vector2(pos.x + x, y_start + line_len)
		draw_ink_stroke(self, PackedVector2Array([p1, p2]), 1.5 * s, InkStroke.Profile.TAPER_START, gloom_col)

func _draw_teardrop(pos: Vector2, s: float) -> void:
	var sz: float = 11.0 * s
	var pts := PackedVector2Array()
	pts.append(pos + Vector2(0.0, -sz * 0.8))
	var bulb := pos + Vector2(0.0, sz * 0.25)
	var radius := sz * 0.42
	for i in range(13):
		var ang := lerpf(0.12 * PI, 0.88 * PI, float(i) / 12.0)
		pts.append(bulb + Vector2(cos(ang) * radius, sin(ang) * radius))
	
	if pts.size() >= 3 and draw_progress >= 0.2:
		var fill := Color("#90caf9", 0.9) if not is_monochrome else Color(0.85, 0.85, 0.85, 0.85)
		draw_colored_polygon(pts, fill)
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_ink_stroke(self, closed, 1.5 * s, InkStroke.Profile.UNIFORM, ink_color)
