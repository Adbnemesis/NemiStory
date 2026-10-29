extends Node2D
## Shared illustration player, also used by legacy episode adapters.
const Ink = preload("res://common/engine/illustration/LiveInk.gd")
const Letters = preload("res://common/engine/illustration/DrawnLettering.gd")
var stroke_list: Array[Dictionary] = []
var fills: Array[Dictionary] = []
var texts: Array[Dictionary] = []
var progress: float = 0.0:
	set(value):
		progress = clampf(value, 0.0, 1.0)
		queue_redraw()
var _ink := Ink.new()
var _tween: Tween
var _dismiss_tween: Tween
var _prepared := false

func prepare() -> void:
	var all_strokes: Array = stroke_list.duplicate()
	for label in texts:
		var lettering := Letters.compose(str(label.txt), float(label.get("size", 24)), label.get("col", Color("#423035")))
		for stroke in lettering.strokes:
			var moved := PackedVector2Array()
			for pt in stroke.pts:
				moved.append(pt + Vector2(label.pos) - Vector2(0, float(label.get("size", 24))))
			stroke.pts = moved
			all_strokes.append(stroke)
	_ink.prepare(all_strokes)
	_prepared = true
	queue_redraw()

func _draw() -> void:
	if not _prepared:
		prepare()
	if progress <= 0.0:
		return
	# Fills are a deliberate late addition; they do not wash across an
	# unfinished outline by default. Individual assets can choose an earlier cue.
	for fill in fills:
		if progress >= float(fill.get("at", 0.88)):
			var poly: PackedVector2Array = fill.poly
			if poly.size() >= 3:
				draw_colored_polygon(poly, fill.col)
	_ink.draw_to(self, progress)

func reveal(duration: float = 0.7) -> Signal:
	prepare()
	if _tween and _tween.is_valid():
		_tween.kill()
	if _dismiss_tween and _dismiss_tween.is_valid():
		_dismiss_tween.kill()
	visible = true
	modulate.a = 1.0
	progress = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "progress", 1.0, maxf(0.001, duration))
	return _tween.finished

func play_draw(duration: float = 0.7):
	reveal(duration)
	return self

func dismiss(duration: float = 0.0) -> Signal:
	if _dismiss_tween and _dismiss_tween.is_valid():
		_dismiss_tween.kill()
	_dismiss_tween = create_tween()
	if duration > 0.0:
		_dismiss_tween.tween_property(self, "modulate:a", 0.0, duration)
	_dismiss_tween.tween_callback(queue_free)
	return _dismiss_tween.finished

func auto_dismiss(delay: float, duration: float = 0.0):
	if _dismiss_tween and _dismiss_tween.is_valid():
		_dismiss_tween.kill()
	_dismiss_tween = create_tween()
	_dismiss_tween.tween_interval(maxf(0.0, delay))
	if duration > 0.0:
		_dismiss_tween.tween_property(self, "modulate:a", 0.0, duration)
	_dismiss_tween.tween_callback(queue_free)
	return self

## Absolute-time evaluation for previews/exports, independent of render FPS.
func sample(time: float, start: float, duration: float, end: float = INF) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	visible = time >= start and time < end
	progress = clampf((time - start) / maxf(duration, 0.001), 0.0, 1.0)
