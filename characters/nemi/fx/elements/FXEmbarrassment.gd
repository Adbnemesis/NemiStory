class_name FXEmbarrassment
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn embarrassment & fluster reaction:
## Dual diagonal blush hatching strokes (///), awkward sweat drop, and cringe squiggles.

enum FlusterStyle {
	BLUSH_ONLY,
	BLUSH_AND_SWEAT,
	FULL_CRINGE
}

@export var style_type: FlusterStyle = FlusterStyle.BLUSH_AND_SWEAT

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.CHEEKS
	anchor_offset = Vector2(0.0, -32.0)
	entrance_style = EntranceStyle.FADE
	exit_style = ExitStyle.FADE
	auto_dismiss_time = 1.6

func _draw() -> void:
	var s: float = 0.85 + (float(intensity) * 0.15)
	
	# Left cheek blush: x = -34, y = 0
	# Right cheek blush: x = +34, y = 0
	_draw_blush_hatch(Vector2(-35.0, 0.0), s)
	_draw_blush_hatch(Vector2(35.0, 0.0), s)
	
	if intensity >= 3 or style_type == FlusterStyle.BLUSH_AND_SWEAT or style_type == FlusterStyle.FULL_CRINGE:
		# Awkward bead of sweat on upper left temple
		_draw_awkward_sweat(Vector2(-42.0, -42.0), s)
	
	if intensity >= 4 or style_type == FlusterStyle.FULL_CRINGE:
		# Horizontal cringe wiggle across cheeks
		_draw_cringe_line(Vector2(0.0, 8.0), s)

func _draw_blush_hatch(center: Vector2, s: float) -> void:
	var w: float = 18.0 * s
	var h: float = 14.0 * s
	var offsets: Array[float] = [-w * 0.38, 0.0, w * 0.38]
	var slant: float = h * 0.85
	
	# Optional soft color glow behind hatches in color mode
	if not is_monochrome:
		var blush_alpha: float = clampf(0.25 + float(intensity) * 0.1, 0.2, 0.75)
		draw_circle(center, 12.0 * s, Color(0.98, 0.52, 0.62, blush_alpha))
	
	var hatch_col := Color("#c0392b") if (not is_monochrome and intensity >= 4) else ink_color
	for ox in offsets:
		var p1 := center + Vector2(ox - slant * 0.5, h * 0.5)
		var p2 := center + Vector2(ox + slant * 0.5, -h * 0.5)
		draw_ink_stroke(self, PackedVector2Array([p1, p2]), 1.5 * s, InkStroke.Profile.TAPER_BOTH, hatch_col)

func _draw_awkward_sweat(pos: Vector2, s: float) -> void:
	var sz: float = 11.0 * s
	var pts := PackedVector2Array()
	var steps: int = 12
	pts.append(pos + Vector2(0.0, -sz * 0.8))
	var bulb_center := pos + Vector2(0.0, sz * 0.2)
	var radius := sz * 0.45
	for i in range(steps + 1):
		var ang: float = lerpf(0.15 * PI, 0.85 * PI, float(i) / float(steps))
		pts.append(bulb_center + Vector2(cos(ang) * radius, sin(ang) * radius))
	
	if pts.size() >= 3 and draw_progress >= 0.3:
		var fill := Color("#b8e2f2", 0.9) if not is_monochrome else Color(0.9, 0.9, 0.9, 0.85)
		draw_colored_polygon(pts, fill)
		var outline_pts := pts.duplicate()
		outline_pts.append(pts[0])
		draw_ink_stroke(self, outline_pts, 1.6 * s, InkStroke.Profile.UNIFORM, ink_color)

func _draw_cringe_line(pos: Vector2, s: float) -> void:
	var c := Curve2D.new()
	var w: float = 34.0 * s
	c.add_point(pos + Vector2(-w * 0.5, 0))
	c.add_point(pos + Vector2(-w * 0.25, 2 * s))
	c.add_point(pos + Vector2(0, -2 * s))
	c.add_point(pos + Vector2(w * 0.25, 2 * s))
	c.add_point(pos + Vector2(w * 0.5, 0))
	draw_ink_curve(self, c, 1.4 * s, InkStroke.Profile.TAPER_BOTH, ink_color)
