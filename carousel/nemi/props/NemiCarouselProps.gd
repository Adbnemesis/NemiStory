class_name NemiCarouselProps
extends RefCounted

## Procedural Vector Props for NEMI Carousel Universe
## 100% Native vector drawing. Zero external raster assets.

const COLOR_INK := Color("#38101e")
const COLOR_TABLET_BASE := Color("#2e3440")
const COLOR_SCREEN := Color("#76987f")
const COLOR_MUG := Color("#faf7f5")
const COLOR_COFFEE := Color("#5c3d2e")

static func draw_prop(canvas: CanvasItem, prop_name: String, pos: Vector2, prop_scale: float = 1.0) -> void:
	match prop_name:
		"drawing_tablet":
			_draw_tablet(canvas, pos, prop_scale)
		"coffee_mug":
			_draw_coffee_mug(canvas, pos, prop_scale)
		"timeline_scrubber":
			_draw_timeline(canvas, pos, prop_scale)
		"sketchbook":
			_draw_sketchbook(canvas, pos, prop_scale)

static func _draw_tablet(c: CanvasItem, pos: Vector2, s: float) -> void:
	var w := 120.0 * s
	var h := 80.0 * s
	var rect := Rect2(pos - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	c.draw_rect(rect, COLOR_TABLET_BASE)
	c.draw_rect(rect, COLOR_INK, false, 3.0)
	# Screen active area
	var screen_rect := Rect2(pos - Vector2(w * 0.42, h * 0.42), Vector2(w * 0.84, h * 0.84))
	c.draw_rect(screen_rect, COLOR_SCREEN)
	c.draw_rect(screen_rect, COLOR_INK, false, 1.8)
	# Stylus resting next to it
	c.draw_line(pos + Vector2(w * 0.55, -h * 0.4), pos + Vector2(w * 0.65, h * 0.4), COLOR_INK, 3.5)

static func _draw_coffee_mug(c: CanvasItem, pos: Vector2, s: float) -> void:
	var w := 40.0 * s
	var h := 50.0 * s
	var rect := Rect2(pos - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	c.draw_rect(rect, COLOR_MUG)
	c.draw_rect(rect, COLOR_INK, false, 2.5)
	# Coffee liquid top
	c.draw_rect(Rect2(pos - Vector2(w * 0.45, h * 0.45), Vector2(w * 0.9, 10.0 * s)), COLOR_COFFEE)
	# Handle
	c.draw_arc(pos + Vector2(w * 0.5, 0), 12.0 * s, -PI * 0.5, PI * 0.5, 12, COLOR_INK, 2.5)
	# Steam plumes
	c.draw_line(pos + Vector2(-6 * s, -h * 0.6), pos + Vector2(-4 * s, -h * 0.9), COLOR_INK, 1.8)
	c.draw_line(pos + Vector2(6 * s, -h * 0.6), pos + Vector2(8 * s, -h * 0.9), COLOR_INK, 1.8)

static func _draw_timeline(c: CanvasItem, pos: Vector2, s: float) -> void:
	var w := 200.0 * s
	var h := 32.0 * s
	var rect := Rect2(pos - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	c.draw_rect(rect, Color("#2b2d42"))
	c.draw_rect(rect, COLOR_INK, false, 2.5)
	# Timeline ticks
	for i in range(8):
		var tx := pos.x - w * 0.4 + i * (w * 0.8 / 7.0)
		c.draw_line(Vector2(tx, pos.y - h * 0.3), Vector2(tx, pos.y + h * 0.3), Color("#8d99ae"), 1.5)
	# Playhead
	c.draw_line(Vector2(pos.x - w * 0.1, pos.y - h * 0.45), Vector2(pos.x - w * 0.1, pos.y + h * 0.45), Color("#d64937"), 2.5)

static func _draw_sketchbook(c: CanvasItem, pos: Vector2, s: float) -> void:
	var w := 90.0 * s
	var h := 110.0 * s
	var rect := Rect2(pos - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	c.draw_rect(rect, Color("#faf7f5"))
	c.draw_rect(rect, COLOR_INK, false, 2.5)
	# Spiral rings
	for i in range(5):
		var sy := pos.y - h * 0.4 + i * (h * 0.8 / 4.0)
		c.draw_line(Vector2(pos.x - w * 0.52, sy), Vector2(pos.x - w * 0.42, sy), COLOR_INK, 2.2)
