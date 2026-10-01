class_name ADBCarouselProps
extends RefCounted

## Procedural Vector Props for ADB Carousel Universe
## 100% Native vector drawing. Zero external raster assets.

const COLOR_INK := Color("#2b2623")
const COLOR_CONTROLLER := Color("#2e3440")
const COLOR_MUG := Color("#3b4252")
const COLOR_COFFEE := Color("#5c3d2e")

static func draw_prop(canvas: CanvasItem, prop_name: String, pos: Vector2, prop_scale: float = 1.0) -> void:
	match prop_name:
		"gaming_controller":
			_draw_controller(canvas, pos, prop_scale)
		"mechanical_keyboard":
			_draw_keyboard(canvas, pos, prop_scale)
		"matte_coffee_mug":
			_draw_mug(canvas, pos, prop_scale)
		"smartphone":
			_draw_phone(canvas, pos, prop_scale)

static func _draw_controller(c: CanvasItem, pos: Vector2, s: float) -> void:
	var w := 110.0 * s
	var h := 70.0 * s
	# Ergonomic gamepad body
	var body := PackedVector2Array([
		pos + Vector2(-w * 0.45, -h * 0.2), pos + Vector2(w * 0.45, -h * 0.2),
		pos + Vector2(w * 0.5, h * 0.4), pos + Vector2(w * 0.3, h * 0.5),
		pos + Vector2(0, h * 0.2), pos + Vector2(-w * 0.3, h * 0.5), pos + Vector2(-w * 0.5, h * 0.4)
	])
	c.draw_colored_polygon(body, COLOR_CONTROLLER)
	_draw_ink_stroke(c, body, 3.0)
	
	# D-pad on left
	c.draw_line(pos + Vector2(-w * 0.25, -2), pos + Vector2(-w * 0.25, 14), Color("#d8dee9"), 3.5)
	c.draw_line(pos + Vector2(-w * 0.3, 6), pos + Vector2(-w * 0.2, 6), Color("#d8dee9"), 3.5)
	
	# Thumbsticks
	c.draw_circle(pos + Vector2(-w * 0.12, 16), 8.0 * s, Color("#4c566a"))
	c.draw_arc(pos + Vector2(-w * 0.12, 16), 8.0 * s, 0, TAU, 14, COLOR_INK, 1.8)
	c.draw_circle(pos + Vector2(w * 0.12, 16), 8.0 * s, Color("#4c566a"))
	c.draw_arc(pos + Vector2(w * 0.12, 16), 8.0 * s, 0, TAU, 14, COLOR_INK, 1.8)
	
	# ABXY buttons on right
	c.draw_circle(pos + Vector2(w * 0.25, -2), 3.5 * s, Color("#e07a5f"))
	c.draw_circle(pos + Vector2(w * 0.32, 5), 3.5 * s, Color("#81a1c1"))
	c.draw_circle(pos + Vector2(w * 0.18, 5), 3.5 * s, Color("#a3be8c"))
	c.draw_circle(pos + Vector2(w * 0.25, 12), 3.5 * s, Color("#ebcb8b"))

static func _draw_keyboard(c: CanvasItem, pos: Vector2, s: float) -> void:
	var w := 140.0 * s
	var h := 50.0 * s
	var rect := Rect2(pos - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	c.draw_rect(rect, Color("#2b2e38"))
	c.draw_rect(rect, COLOR_INK, false, 2.5)
	# Keycap rows
	for r in range(3):
		var ry := pos.y - h * 0.3 + r * (h * 0.28)
		c.draw_line(Vector2(pos.x - w * 0.42, ry), Vector2(pos.x + w * 0.42, ry), Color("#434c5e"), 4.0 * s)

static func _draw_mug(c: CanvasItem, pos: Vector2, s: float) -> void:
	var w := 36.0 * s
	var h := 48.0 * s
	var rect := Rect2(pos - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	c.draw_rect(rect, COLOR_MUG)
	c.draw_rect(rect, COLOR_INK, false, 2.5)
	# Rectangular modern handle
	var handle := PackedVector2Array([
		pos + Vector2(w * 0.5, -h * 0.3), pos + Vector2(w * 0.8, -h * 0.3),
		pos + Vector2(w * 0.8, h * 0.3), pos + Vector2(w * 0.5, h * 0.3)
	])
	c.draw_polyline(handle, COLOR_INK, 2.5, true)

static func _draw_phone(c: CanvasItem, pos: Vector2, s: float) -> void:
	var w := 45.0 * s
	var h := 80.0 * s
	var rect := Rect2(pos - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	c.draw_rect(rect, Color("#1a1c23"))
	c.draw_rect(rect, COLOR_INK, false, 2.5)
	# Screen
	var s_rect := Rect2(pos - Vector2(w * 0.4, h * 0.4), Vector2(w * 0.8, h * 0.8))
	c.draw_rect(s_rect, Color("#2e3440"))
	# Notification dot
	c.draw_circle(pos + Vector2(0, -h * 0.2), 3.0 * s, Color("#e07a5f"))

static func _draw_ink_stroke(c: CanvasItem, pts: PackedVector2Array, width: float) -> void:
	var closed := pts.duplicate()
	closed.append(pts[0])
	c.draw_polyline(closed, COLOR_INK, width, true)
