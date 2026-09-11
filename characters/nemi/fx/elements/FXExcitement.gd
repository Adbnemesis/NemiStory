class_name FXExcitement
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn excitement & confidence reaction:
## 4-pointed calligraphic sparkle stars, radiating joy sparks, and twinkling constellations.

enum SparklePattern {
	SINGLE_STAR,
	TWIN_STARS,
	CONSTELLATION_BURST
}

@export var pattern: SparklePattern = SparklePattern.TWIN_STARS

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.HEAD_LEFT
	anchor_offset = Vector2(-46.0, -75.0)
	entrance_style = EntranceStyle.POP
	exit_style = ExitStyle.FADE
	auto_dismiss_time = 1.4

func _draw() -> void:
	var s: float = 0.85 + (float(intensity) * 0.16)
	
	match pattern:
		SparklePattern.SINGLE_STAR:
			_draw_4point_star(Vector2.ZERO, 14.0 * s)
		
		SparklePattern.TWIN_STARS:
			_draw_4point_star(Vector2(-10, -8), 13.0 * s)
			_draw_4point_star(Vector2(14, 8), 9.5 * s)
			if intensity >= 3:
				_draw_spark_dot(Vector2(2, -18), 2.2 * s)
				_draw_spark_dot(Vector2(-16, 14), 1.8 * s)
		
		SparklePattern.CONSTELLATION_BURST:
			# Grand constellation for high confidence / triumph
			_draw_4point_star(Vector2(0, -6), 16.0 * s)
			_draw_4point_star(Vector2(-24, 12), 10.0 * s)
			_draw_4point_star(Vector2(24, 8), 11.0 * s)
			_draw_4point_star(Vector2(-18, -26), 8.5 * s)
			_draw_4point_star(Vector2(20, -22), 9.0 * s)
			# Connecting delicate radiance lines
			_draw_radiance_cross(Vector2(0, -6), 24.0 * s)

func _draw_4point_star(center: Vector2, size: float) -> void:
	var pts := PackedVector2Array()
	var r_outer := size
	var r_inner := size * 0.22
	for i in range(8):
		var ang: float = float(i) * PI * 0.25
		var r: float = r_outer if (i % 2 == 0) else r_inner
		pts.append(center + Vector2(cos(ang) * r, sin(ang) * r))
	
	if pts.size() >= 3 and draw_progress >= 0.2:
		var fill := Color("#fff8cc", 0.95) if not is_monochrome else Color(0.95, 0.95, 0.95, 0.9)
		draw_colored_polygon(pts, fill)
		
		var stroke_pts := pts.duplicate()
		stroke_pts.append(pts[0])
		var star_stroke_col := Color("#d4ac0d") if (not is_monochrome and intensity >= 3) else ink_color
		draw_ink_stroke(self, stroke_pts, 1.4, InkStroke.Profile.UNIFORM, star_stroke_col)

func _draw_spark_dot(pos: Vector2, r: float) -> void:
	if draw_progress >= 0.5:
		var col := Color("#f1c40f") if not is_monochrome else ink_color
		draw_circle(pos, r, col)

func _draw_radiance_cross(center: Vector2, span: float) -> void:
	# Subtle horizontal and vertical glimmer beams
	var p_h1 := center + Vector2(-span, 0)
	var p_h2 := center + Vector2(span, 0)
	var p_v1 := center + Vector2(0, -span)
	var p_v2 := center + Vector2(0, span)
	
	var col := Color("#f39c12", 0.65) if not is_monochrome else Color(ink_color.r, ink_color.g, ink_color.b, 0.5)
	draw_ink_stroke(self, PackedVector2Array([p_h1, p_h2]), 1.2, InkStroke.Profile.TAPER_BOTH, col)
	draw_ink_stroke(self, PackedVector2Array([p_v1, p_v2]), 1.2, InkStroke.Profile.TAPER_BOTH, col)
