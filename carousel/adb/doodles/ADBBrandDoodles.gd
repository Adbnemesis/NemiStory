class_name ADBBrandDoodles
extends RefCounted

## Procedural Decorative & Technical Accents for ADB
## 100% Native vector drawing. Zero external raster assets.

const COLOR_INK := Color("#2b2623")
const COLOR_STEEL := Color("#4a5770")
const COLOR_EMBER := Color("#e07a5f")

static func draw_doodle(canvas: CanvasItem, doodle_name: String, pos: Vector2, d_scale: float = 1.0) -> void:
	match doodle_name:
		"pixel_stars", "sparkles":
			_draw_pixel_star(canvas, pos, 12.0 * d_scale, COLOR_STEEL)
		"deadpan_dots":
			_draw_deadpan_dots(canvas, pos, d_scale)
		"terminal_brackets":
			_draw_terminal_brackets(canvas, pos, d_scale)
		"crosshair":
			_draw_crosshair(canvas, pos, 14.0 * d_scale)
		"strikethrough_bar":
			_draw_strikethrough(canvas, pos, d_scale)

static func _draw_pixel_star(c: CanvasItem, pos: Vector2, r: float, col: Color) -> void:
	# 4-point diamond geometric glint
	var diamond := PackedVector2Array([
		pos + Vector2(0, -r), pos + Vector2(r * 0.35, -r * 0.35),
		pos + Vector2(r, 0), pos + Vector2(r * 0.35, r * 0.35),
		pos + Vector2(0, r), pos + Vector2(-r * 0.35, r * 0.35),
		pos + Vector2(-r, 0), pos + Vector2(-r * 0.35, -r * 0.35)
	])
	c.draw_colored_polygon(diamond, col)
	c.draw_polyline(diamond, COLOR_INK, 1.8, true)

static func _draw_deadpan_dots(c: CanvasItem, pos: Vector2, s: float) -> void:
	for i in range(3):
		c.draw_circle(pos + Vector2(i * 12.0 * s, 0), 3.0 * s, COLOR_INK)

static func _draw_terminal_brackets(c: CanvasItem, pos: Vector2, s: float) -> void:
	# Code bracket [ > ]
	c.draw_line(pos + Vector2(-15 * s, -12 * s), pos + Vector2(-22 * s, -12 * s), COLOR_STEEL, 2.0)
	c.draw_line(pos + Vector2(-22 * s, -12 * s), pos + Vector2(-22 * s, 12 * s), COLOR_STEEL, 2.0)
	c.draw_line(pos + Vector2(-22 * s, 12 * s), pos + Vector2(-15 * s, 12 * s), COLOR_STEEL, 2.0)
	
	c.draw_line(pos + Vector2(15 * s, -12 * s), pos + Vector2(22 * s, -12 * s), COLOR_STEEL, 2.0)
	c.draw_line(pos + Vector2(22 * s, -12 * s), pos + Vector2(22 * s, 12 * s), COLOR_STEEL, 2.0)
	c.draw_line(pos + Vector2(22 * s, 12 * s), pos + Vector2(15 * s, 12 * s), COLOR_STEEL, 2.0)
	
	# Prompt arrow >
	c.draw_line(pos + Vector2(-4 * s, -6 * s), pos + Vector2(4 * s, 0), COLOR_EMBER, 2.2)
	c.draw_line(pos + Vector2(4 * s, 0), pos + Vector2(-4 * s, 6 * s), COLOR_EMBER, 2.2)

static func _draw_crosshair(c: CanvasItem, pos: Vector2, r: float) -> void:
	c.draw_arc(pos, r, 0, TAU, 16, COLOR_STEEL, 1.6)
	c.draw_line(pos - Vector2(r * 1.4, 0), pos - Vector2(r * 0.4, 0), COLOR_STEEL, 1.6)
	c.draw_line(pos + Vector2(r * 0.4, 0), pos + Vector2(r * 1.4, 0), COLOR_STEEL, 1.6)
	c.draw_line(pos - Vector2(0, r * 1.4), pos - Vector2(0, r * 0.4), COLOR_STEEL, 1.6)
	c.draw_line(pos + Vector2(0, r * 0.4), pos + Vector2(0, r * 1.4), COLOR_STEEL, 1.6)

static func _draw_strikethrough(c: CanvasItem, pos: Vector2, s: float) -> void:
	c.draw_line(pos + Vector2(-60 * s, 0), pos + Vector2(60 * s, 0), COLOR_INK, 3.0)
