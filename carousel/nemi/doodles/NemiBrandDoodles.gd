class_name NemiBrandDoodles
extends RefCounted

## Procedural Decorative & Emotional Doodles for NEMI
## 100% Native vector drawing. Zero external raster assets.

const COLOR_INK := Color("#38101e")
const COLOR_COPPER := Color("#d64937")
const COLOR_PEACH := Color("#f8b4a0")
const COLOR_MINT := Color("#a8e6cf")

static func draw_doodle(canvas: CanvasItem, doodle_name: String, pos: Vector2, d_scale: float = 1.0) -> void:
	match doodle_name:
		"copper_star", "sparkles":
			_draw_star(canvas, pos, 14.0 * d_scale, COLOR_COPPER)
		"pink_heart":
			_draw_heart(canvas, pos, 12.0 * d_scale, COLOR_PEACH)
		"curved_arrow":
			_draw_curved_arrow(canvas, pos, d_scale)
		"sweat_drop":
			_draw_sweat_drop(canvas, pos, 10.0 * d_scale)
		"cat_paw":
			_draw_cat_paw(canvas, pos, d_scale)

static func _draw_star(c: CanvasItem, pos: Vector2, r: float, col: Color) -> void:
	c.draw_line(pos - Vector2(r, 0), pos + Vector2(r, 0), col, 2.8)
	c.draw_line(pos - Vector2(0, r), pos + Vector2(0, r), col, 2.8)
	c.draw_circle(pos, 2.0, col)

static func _draw_heart(c: CanvasItem, pos: Vector2, s: float, col: Color) -> void:
	c.draw_circle(pos + Vector2(-s * 0.4, -s * 0.2), s * 0.4, col)
	c.draw_circle(pos + Vector2(s * 0.4, -s * 0.2), s * 0.4, col)
	var tri := PackedVector2Array([
		pos + Vector2(-s * 0.8, -s * 0.2), pos + Vector2(s * 0.8, -s * 0.2), pos + Vector2(0, s * 0.8)
	])
	c.draw_colored_polygon(tri, col)

static func _draw_curved_arrow(c: CanvasItem, pos: Vector2, s: float) -> void:
	var pts := PackedVector2Array([
		pos, pos + Vector2(25 * s, 15 * s), pos + Vector2(55 * s, 10 * s), pos + Vector2(70 * s, 25 * s)
	])
	c.draw_polyline(pts, COLOR_INK, 3.0, true)
	# Arrowhead
	c.draw_line(pos + Vector2(70 * s, 25 * s), pos + Vector2(55 * s, 28 * s), COLOR_INK, 3.0)
	c.draw_line(pos + Vector2(70 * s, 25 * s), pos + Vector2(68 * s, 10 * s), COLOR_INK, 3.0)

static func _draw_sweat_drop(c: CanvasItem, pos: Vector2, s: float) -> void:
	c.draw_circle(pos + Vector2(0, s * 0.5), s * 0.6, Color("#80ed99"))
	var tri := PackedVector2Array([
		pos + Vector2(-s * 0.5, s * 0.4), pos + Vector2(s * 0.5, s * 0.4), pos + Vector2(0, -s * 0.8)
	])
	c.draw_colored_polygon(tri, Color("#80ed99"))
	c.draw_arc(pos + Vector2(0, s * 0.5), s * 0.6, 0, PI, 12, COLOR_INK, 2.0)

static func _draw_cat_paw(c: CanvasItem, pos: Vector2, s: float) -> void:
	c.draw_circle(pos, 16.0 * s, COLOR_INK)
	c.draw_circle(pos + Vector2(-12 * s, -14 * s), 6.0 * s, COLOR_INK)
	c.draw_circle(pos + Vector2(0, -18 * s), 6.0 * s, COLOR_INK)
	c.draw_circle(pos + Vector2(12 * s, -14 * s), 6.0 * s, COLOR_INK)
