class_name NemiDoodleDirector
extends Node2D

## NemiDoodleDirector — Hand-Drawn Doodle & Ink Storytelling Director
## High-level API for spawning, layering, and choreographing hand-drawn doodles,
## annotations, handwritten labels, and mini-illustrations timed to narration.
## Supports world-space and screen-space rendering, camera awareness,
## draw-while-talking sequences, and deterministic authored imperfections.

const DoodleInstanceScript = preload("res://world/doodles/DoodleInstance.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")

var style: RefCounted = WorldStyleScript.new()
var color_mode: DoodleInstanceScript.ColorMode = DoodleInstanceScript.ColorMode.COLOR
var active_doodles: Array[Node2D] = []

# Optional dedicated screen-space canvas layer
var screen_canvas_layer: CanvasLayer

func _ready() -> void:
	z_index = int(DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI)

func set_style(p_style: RefCounted) -> void:
	style = p_style
	for d in active_doodles:
		if is_instance_valid(d) and d.has_method("set_style"):
			d.set_style(style)

func set_color_mode(p_mode: DoodleInstanceScript.ColorMode) -> void:
	color_mode = p_mode
	for d in active_doodles:
		if is_instance_valid(d):
			d.color_mode = p_mode
			d.queue_redraw()

func _ensure_screen_layer() -> CanvasLayer:
	if not screen_canvas_layer or not is_instance_valid(screen_canvas_layer):
		screen_canvas_layer = CanvasLayer.new()
		screen_canvas_layer.name = "DoodleScreenLayer"
		screen_canvas_layer.layer = 100
		add_child(screen_canvas_layer)
	return screen_canvas_layer

func _register_doodle(doodle: Node2D, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> Node2D:
	if layer == DoodleInstanceScript.LayerOrder.SCREEN_SPACE:
		var sc := _ensure_screen_layer()
		sc.add_child(doodle)
	else:
		add_child(doodle)
		doodle.z_index = int(layer)
		
	active_doodles.append(doodle)
	doodle.tree_exited.connect(func(): active_doodles.erase(doodle))
	return doodle

# -------------------------------------------------------------------------
# HIGH-LEVEL ANNOTATION PRIMITIVES
# -------------------------------------------------------------------------

## Draw an arrow from start to target
func arrow(from_pos: Vector2, to_pos: Vector2, duration: float = 0.22, curved: bool = true, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.ARROW
	d.global_position = from_pos
	d.target_end = to_pos - from_pos
	d.is_curved = curved
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw a double-ended arrow
func double_arrow(from_pos: Vector2, to_pos: Vector2, duration: float = 0.24, curved: bool = false, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.DOUBLE_ARROW
	d.global_position = from_pos
	d.target_end = to_pos - from_pos
	d.is_curved = curved
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw a circle accent around a target
func circle(target_pos: Vector2, radius: float = 35.0, duration: float = 0.22, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.CIRCLE
	d.global_position = target_pos
	d.doodle_size = radius
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw an oval accent around a target
func oval(target_pos: Vector2, size: float = 35.0, duration: float = 0.22, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.OVAL
	d.global_position = target_pos
	d.doodle_size = size
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw an underline under a target
func underline(target_pos: Vector2, length: float = 80.0, duration: float = 0.20, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.UNDERLINE
	d.global_position = target_pos
	d.doodle_size = length / 2.4
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw a bracket accent
func bracket(target_pos: Vector2, height: float = 60.0, duration: float = 0.20, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.BRACKET
	d.global_position = target_pos
	d.doodle_size = height * 0.5
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw an pointing finger/wedge pointer
func pointer(target_pos: Vector2, duration: float = 0.20, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.POINTER
	d.global_position = target_pos
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw a cross-out X mark
func cross(target_pos: Vector2, size: float = 30.0, duration: float = 0.18, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.CROSS_OUT
	d.global_position = target_pos
	d.doodle_size = size
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw a checkmark
func check(target_pos: Vector2, size: float = 30.0, duration: float = 0.18, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.CHECK_MARK
	d.global_position = target_pos
	d.doodle_size = size
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw a 5-point star
func star(target_pos: Vector2, size: float = 32.0, duration: float = 0.22, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.STAR
	d.global_position = target_pos
	d.doodle_size = size
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw radiating emphasis burst marks
func emphasis(target_pos: Vector2, radius: float = 40.0, duration: float = 0.20, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.EMPHASIS_BURST
	d.global_position = target_pos
	d.doodle_size = radius
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw a scribble sequence
func scribble(target_pos: Vector2, size: float = 40.0, duration: float = 0.24, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.SCRIBBLE
	d.global_position = target_pos
	d.doodle_size = size
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

## Draw a handwritten label annotation (NOT a subtitle - max 1 to 3 punchy words)
func label(text: String, target_pos: Vector2, duration: float = 0.25, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.HANDWRITTEN_LABEL
	d.global_position = target_pos
	d.custom_text = text
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

# -------------------------------------------------------------------------
# MOTION MARKS
# -------------------------------------------------------------------------

func speed_lines(target_pos: Vector2, length: float = 60.0, duration: float = 0.18, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.SPEED_LINES
	d.global_position = target_pos
	d.doodle_size = length
	d.style_preset = DoodleInstanceScript.StylePreset.NORMAL
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

func swirl(target_pos: Vector2, size: float = 30.0, duration: float = 0.22, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.SWIRL
	d.global_position = target_pos
	d.doodle_size = size
	d.style_preset = DoodleInstanceScript.StylePreset.NORMAL
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

func shake_marks(target_pos: Vector2, size: float = 30.0, duration: float = 0.18, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	d.doodle_type = DoodleInstanceScript.Type.SHAKE_MARKS
	d.global_position = target_pos
	d.doodle_size = size
	d.style_preset = DoodleInstanceScript.StylePreset.NORMAL
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

# -------------------------------------------------------------------------
# MINI ILLUSTRATIONS (NARRATIVE STORY DRAWINGS)
# -------------------------------------------------------------------------

## Draw small narrative illustration (clock, bridge, banana, note, dumbbell, etc.)
func mini(illustration_name: String, target_pos: Vector2, size: float = 36.0, duration: float = 0.28, style_preset: DoodleInstanceScript.StylePreset = DoodleInstanceScript.StylePreset.NORMAL, layer: DoodleInstanceScript.LayerOrder = DoodleInstanceScript.LayerOrder.IN_FRONT_OF_NEMI) -> DoodleInstance:
	var d := DoodleInstanceScript.new()
	match illustration_name.to_lower():
		"clock": d.doodle_type = DoodleInstanceScript.Type.MINI_CLOCK
		"bridge": d.doodle_type = DoodleInstanceScript.Type.MINI_BRIDGE
		"banana", "banana_peel": d.doodle_type = DoodleInstanceScript.Type.MINI_BANANA
		"note", "musical_note": d.doodle_type = DoodleInstanceScript.Type.MINI_NOTE
		"dumbbell": d.doodle_type = DoodleInstanceScript.Type.MINI_DUMBBELL
		"calendar": d.doodle_type = DoodleInstanceScript.Type.MINI_CALENDAR
		"brain": d.doodle_type = DoodleInstanceScript.Type.MINI_BRAIN
		"magnifier": d.doodle_type = DoodleInstanceScript.Type.MINI_MAGNIFIER
		"car": d.doodle_type = DoodleInstanceScript.Type.MINI_CAR
		"person": d.doodle_type = DoodleInstanceScript.Type.MINI_PERSON
		_: d.doodle_type = DoodleInstanceScript.Type.MINI_NOTE
		
	d.global_position = target_pos
	d.doodle_size = size
	d.style_preset = style_preset
	d.color_mode = color_mode
	d.set_style(style)
	_register_doodle(d, layer)
	d.draw_on(duration)
	return d

# -------------------------------------------------------------------------
# NARRATIVE STORYTELLING & SYNCHRONIZATION HELPERS
# -------------------------------------------------------------------------

## Draws a doodle progressively over the exact duration of a spoken phrase
func draw_while_talking(doodle_node: DoodleInstance, total_duration: float) -> Signal:
	return doodle_node.draw_on(total_duration)

## Reverse-draws or erases a doodle
func erase(doodle_node: DoodleInstance, duration: float = 0.20) -> Signal:
	if is_instance_valid(doodle_node):
		return doodle_node.erase(duration)
	var tw := create_tween()
	tw.tween_interval(0.01)
	return tw.finished

## Fades out a doodle
func fade_out(doodle_node: DoodleInstance, duration: float = 0.18) -> Signal:
	if is_instance_valid(doodle_node):
		return doodle_node.fade_out(duration)
	var tw := create_tween()
	tw.tween_interval(0.01)
	return tw.finished

## Instantly clears or fades all active doodles
func clear_all(duration: float = 0.0) -> void:
	var to_clean := active_doodles.duplicate()
	for d in to_clean:
		if is_instance_valid(d):
			if duration > 0.001:
				d.erase(duration)
			else:
				d.queue_free()
	active_doodles.clear()
