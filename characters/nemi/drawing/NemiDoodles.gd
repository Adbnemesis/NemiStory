class_name NemiDoodles
extends RefCounted

## Micro-expression and storytime comic accents:
## Blush hatches (///), sweat drops, sparkles, question marks, and tension lines.
## Drawn using calligraphic ink strokes to match the YouTube storytime aesthetic.

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")

## Draws a set of 3 diagonal blush hatching strokes (///)
static func draw_blush_hatch(canvas_item: CanvasItem, center: Vector2, width: float = 14.0, height: float = 12.0, ink_color: Color = Color("#3e081e")) -> void:
	var offsets: Array[float] = [-width * 0.36, 0.0, width * 0.36]
	var slant: float = height * 0.85 # Authentic 45-degree anime hatching
	
	for ox in offsets:
		var start := center + Vector2(ox - slant * 0.5, height * 0.5)
		var finish := center + Vector2(ox + slant * 0.5, -height * 0.5)
		var stroke := InkStroke.from_points(PackedVector2Array([start, finish]), 1.2, InkStroke.Profile.TAPER_BOTH, ink_color)
		stroke.draw_to(canvas_item)

## Draws an illustrated teardrop (sweat drop) for awkward / nervous expressions
static func draw_sweat_drop(canvas_item: CanvasItem, pos: Vector2, size: float = 10.0, fill_color: Color = Color("#b8e2f2"), ink_color: Color = Color("#3e081e")) -> void:
	var pts := PackedVector2Array()
	var steps: int = 12
	# Top point
	pts.append(pos + Vector2(0.0, -size * 0.8))
	# Bottom rounded bulb
	var bulb_center := pos + Vector2(0.0, size * 0.2)
	var radius := size * 0.4
	for i in range(steps + 1):
		var ang: float = lerpf(0.15 * PI, 0.85 * PI, float(i) / float(steps))
		pts.append(bulb_center + Vector2(cos(ang) * radius, sin(ang) * radius))
	
	if pts.size() >= 3:
		canvas_item.draw_colored_polygon(pts, fill_color)
		var outline := InkStroke.from_points(pts, 1.5, InkStroke.Profile.UNIFORM, ink_color)
		outline.draw_to(canvas_item)

## Draws a 4-pointed hand-drawn star sparkle for excitement / awe
static func draw_sparkle_star(canvas_item: CanvasItem, center: Vector2, size: float = 12.0, fill_color: Color = Color("#fff8cc"), ink_color: Color = Color("#3e081e")) -> void:
	var pts := PackedVector2Array()
	var r_outer := size
	var r_inner := size * 0.22
	for i in range(8):
		var ang: float = float(i) * PI * 0.25
		var r: float = r_outer if (i % 2 == 0) else r_inner
		pts.append(center + Vector2(cos(ang) * r, sin(ang) * r))
	
	if pts.size() >= 3:
		canvas_item.draw_colored_polygon(pts, fill_color)
		var stroke := InkStroke.from_points(pts, 1.3, InkStroke.Profile.UNIFORM, ink_color)
		stroke.draw_to(canvas_item)

## Draws an illustrated hand-drawn question mark (?)
static func draw_question_mark(canvas_item: CanvasItem, pos: Vector2, size: float = 18.0, ink_color: Color = Color("#3e081e")) -> void:
	# Curved hook
	var curve := Curve2D.new()
	curve.add_point(pos + Vector2(-size * 0.25, -size * 0.6))
	curve.add_point(pos + Vector2(size * 0.25, -size * 0.7), Vector2(0.0, -size * 0.3), Vector2(0.0, size * 0.3))
	curve.add_point(pos + Vector2(0.0, -size * 0.2), Vector2(size * 0.1, -size * 0.1), Vector2(-size * 0.1, size * 0.1))
	curve.add_point(pos + Vector2(0.0, 0.0))
	
	var stroke := InkStroke.from_curve(curve, 2.4, InkStroke.Profile.TAPER_START, ink_color)
	stroke.draw_to(canvas_item)
	
	# Dot at bottom
	var dot_pos := pos + Vector2(0.0, size * 0.22)
	canvas_item.draw_circle(dot_pos, 1.8, ink_color)

## Draws anime/comic tension hatch lines
static func draw_shock_lines(canvas_item: CanvasItem, origin: Vector2, count: int = 4, length: float = 24.0, spacing: float = 6.0, ink_color: Color = Color("#3e081e")) -> void:
	for i in range(count):
		var ox: float = float(i - count / 2) * spacing
		var start := origin + Vector2(ox, 0.0)
		var finish := origin + Vector2(ox, length)
		var stroke := InkStroke.from_points(PackedVector2Array([start, finish]), 1.4, InkStroke.Profile.TAPER_BOTH, ink_color)
		stroke.draw_to(canvas_item)
