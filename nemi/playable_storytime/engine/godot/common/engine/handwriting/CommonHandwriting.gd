class_name CommonHandwriting
extends "res://common/engine/illustration/LiveDrawing.gd"
const Marks = preload("res://common/engine/illustration/StoryMarks.gd")
@export_multiline var text: String = "wait, what?"
@export var font_size: int = 34
@export var ink_color := Color("#423035")
@export var add_underline: bool = false
@export var tilt_degrees: float = -2.5
@export_range(0.0, 1.0) var write_progress: float = 1.0:
	set(value):
		write_progress = value
		progress = value
var text_size := Vector2.ZERO

func _ready() -> void:
	_rebuild_text()
	progress = write_progress

func set_handwriting(p_text: String, p_size: int = 34, p_color: Color = Color("#423035"), p_underline: bool = false, p_tilt: float = -2.5) -> void:
	text = p_text
	font_size = p_size
	ink_color = p_color
	add_underline = p_underline
	tilt_degrees = p_tilt
	_rebuild_text()

func _rebuild_text() -> void:
	var lettering := Letters.compose(text, float(font_size), ink_color)
	stroke_list.assign(lettering.strokes)
	text_size = Vector2(lettering.width, lettering.height)
	rotation_degrees = tilt_degrees
	if add_underline and not text.is_empty():
		for stroke in Marks.make("underline", ink_color, 1):
			var pts := PackedVector2Array()
			for pt in stroke.pts:
				pts.append(Vector2((pt.x + 60.0) / 121.0 * text_size.x, text_size.y + pt.y))
			stroke.pts = pts
			stroke.pause = 0.12
			stroke_list.append(stroke)
	prepare()

func animate_write_on(duration: float = 1.0) -> Signal:
	if _tween and _tween.is_valid():
		_tween.kill()
	visible = true
	write_progress = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "write_progress", 1.0, maxf(0.001, duration))
	return _tween.finished
