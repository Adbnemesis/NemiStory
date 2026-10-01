class_name CommonDoodle
extends "res://common/engine/illustration/LiveDrawing.gd"
const Marks = preload("res://common/engine/illustration/StoryMarks.gd")
enum DoodleType { ARROW, CIRCLE, STAR, QUESTION, EXCLAMATION, UNDERLINE, EMPHASIS_SCRIBBLE, CHECK_MARK, BRACKET }
@export var doodle_type: DoodleType = DoodleType.CIRCLE
@export_range(0.0, 1.0) var draw_progress: float = 1.0:
	set(value):
		draw_progress = value
		progress = value
@export var stroke_color := Color("#423035")
@export var base_width: float = 3.0
@export var doodle_scale: float = 1.0
@export var variant: int = 0

func _ready() -> void:
	_generate_geometry()
	progress = draw_progress

func set_doodle(p_type: DoodleType, p_color: Color = Color("#423035"), p_scale: float = 1.0, p_variant: int = 0) -> void:
	doodle_type = p_type
	stroke_color = p_color
	doodle_scale = p_scale
	variant = p_variant
	_generate_geometry()

func _generate_geometry() -> void:
	var names := ["arrow", "circle", "star", "question", "exclamation", "underline", "emphasis", "check", "bracket"]
	stroke_list = Marks.make(names[doodle_type], stroke_color, variant)
	for stroke in stroke_list:
		var scaled := PackedVector2Array()
		for pt in stroke.pts:
			scaled.append(pt * doodle_scale)
		stroke.pts = scaled
		stroke.w *= base_width / 3.0 * doodle_scale
	prepare()

func animate_draw_on(duration: float = 0.55) -> Signal:
	if _tween and _tween.is_valid():
		_tween.kill()
	visible = true
	draw_progress = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "draw_progress", 1.0, maxf(0.001, duration))
	return _tween.finished

func animate_erase(duration: float = 0.20) -> Signal:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "draw_progress", 0.0, maxf(0.001, duration))
	_tween.tween_callback(queue_free)
	return _tween.finished
