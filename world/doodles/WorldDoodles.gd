class_name WorldDoodles
extends Node2D

## World Doodles Factory & Manager
## Provides one-line spawning for hand-drawn doodles, comic accents, and reaction marks.
## Manages active doodle instances, styling, auto-cleanup, and batch transitions.

const DoodleInstanceScript = preload("res://world/doodles/DoodleInstance.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")

var style: RefCounted = WorldStyleScript.new()
var active_doodles: Array[Node2D] = []

func _ready() -> void:
	z_index = 30 # Standard doodle layer (above props & characters)

func set_style(p_style: RefCounted) -> void:
	style = p_style
	for doodle in active_doodles:
		if is_instance_valid(doodle) and doodle.has_method("set_style"):
			doodle.set_style(style)

func _register_doodle(doodle: Node2D) -> Node2D:
	add_child(doodle)
	active_doodles.append(doodle)
	doodle.tree_exited.connect(func(): active_doodles.erase(doodle))
	return doodle

# -------------------------------------------------------------------------
# CONVENIENT SPAWNER API
# -------------------------------------------------------------------------

## Spawn an arrow pointing from start to target
func spawn_arrow(from_pos: Vector2, to_pos: Vector2, curved: bool = true, draw_in: bool = true, duration: float = 0.22) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.ARROW
	doodle.global_position = from_pos
	doodle.target_end = to_pos - from_pos
	doodle.is_curved = curved
	doodle.set_style(style)
	_register_doodle(doodle)
	if draw_in:
		doodle.draw_on(duration)
	return doodle

## Spawn a hand-drawn circle/oval accent around a target
func spawn_circle(pos: Vector2, radius: float = 35.0, draw_in: bool = true, duration: float = 0.22) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.CIRCLE
	doodle.global_position = pos
	doodle.doodle_size = radius
	doodle.set_style(style)
	_register_doodle(doodle)
	if draw_in:
		doodle.draw_on(duration)
	return doodle

## Spawn an underline under a point/word
func spawn_underline(pos: Vector2, length: float = 80.0, draw_in: bool = true, duration: float = 0.2) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.UNDERLINE
	doodle.global_position = pos
	doodle.target_end = Vector2(length, 0.0)
	doodle.set_style(style)
	_register_doodle(doodle)
	if draw_in:
		doodle.draw_on(duration)
	return doodle

## Spawn a question mark comic accent
func spawn_question(pos: Vector2, size: float = 32.0, pop: bool = true) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.QUESTION
	doodle.global_position = pos
	doodle.doodle_size = size
	doodle.set_style(style)
	_register_doodle(doodle)
	if pop:
		doodle.pop_in(0.18, 1.25)
	return doodle

## Spawn an exclamation mark comic accent
func spawn_exclamation(pos: Vector2, size: float = 34.0, pop: bool = true) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.EXCLAMATION
	doodle.global_position = pos
	doodle.doodle_size = size
	doodle.set_style(style)
	_register_doodle(doodle)
	if pop:
		doodle.pop_in(0.16, 1.3)
	return doodle

## Spawn a heart accent
func spawn_heart(pos: Vector2, size: float = 28.0, pop: bool = true) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.HEART
	doodle.global_position = pos
	doodle.doodle_size = size
	doodle.set_style(style)
	_register_doodle(doodle)
	if pop:
		doodle.pop_in(0.2, 1.2)
	return doodle

## Spawn a star accent
func spawn_star(pos: Vector2, size: float = 28.0, pop: bool = true) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.STAR
	doodle.global_position = pos
	doodle.doodle_size = size
	doodle.set_style(style)
	_register_doodle(doodle)
	if pop:
		doodle.pop_in(0.18, 1.25)
	return doodle

## Spawn multiple sparkles radiating outward
func spawn_sparkles(center: Vector2, count: int = 3, spread: float = 40.0) -> Array[Node2D]:
	var result: Array[Node2D] = []
	for i in range(count):
		var angle := (TAU / float(count)) * float(i) + randf_range(-0.2, 0.2)
		var dist := randf_range(spread * 0.6, spread)
		var pos := center + Vector2(cos(angle), sin(angle)) * dist
		var doodle := DoodleInstanceScript.new()
		doodle.doodle_type = DoodleInstanceScript.Type.SPARKLE
		doodle.global_position = pos
		doodle.doodle_size = randf_range(16.0, 24.0)
		doodle.set_style(style)
		_register_doodle(doodle)
		doodle.pop_in(0.15 + float(i) * 0.04, 1.2)
		result.append(doodle)
	return result

## Spawn an anime/manga sweat drop
func spawn_sweat_drop(pos: Vector2, size: float = 24.0, pop: bool = true) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.SWEAT
	doodle.global_position = pos
	doodle.doodle_size = size
	doodle.set_style(style)
	_register_doodle(doodle)
	if pop:
		doodle.pop_in(0.18, 1.15)
	return doodle

## Spawn directional motion lines
func spawn_motion_lines(pos: Vector2, length: float = 60.0, draw_in: bool = true) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.DIRECTION_LINES
	doodle.global_position = pos
	doodle.doodle_size = length
	doodle.set_style(style)
	_register_doodle(doodle)
	if draw_in:
		doodle.draw_on(0.16)
	return doodle

## Spawn impact starburst lines
func spawn_impact_lines(pos: Vector2, radius: float = 50.0) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.IMPACT_LINES
	doodle.global_position = pos
	doodle.doodle_size = radius
	doodle.set_style(style)
	_register_doodle(doodle)
	doodle.pop_in(0.14, 1.35)
	return doodle

## Spawn head shock / realization vertical marks
func spawn_shock_lines(pos: Vector2, radius: float = 50.0) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.SHOCK_LINES
	doodle.global_position = pos
	doodle.doodle_size = radius
	doodle.set_style(style)
	_register_doodle(doodle)
	doodle.pop_in(0.12, 1.2)
	return doodle

## Spawn speech bubble with text
func spawn_speech_bubble(pos: Vector2, text: String, width: float = 120.0, draw_in: bool = true) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.SPEECH_BUBBLE
	doodle.global_position = pos
	doodle.custom_text = text
	doodle.doodle_size = width
	doodle.set_style(style)
	_register_doodle(doodle)
	if draw_in:
		doodle.draw_on(0.24)
	return doodle

## Spawn thought bubble with text
func spawn_thought_bubble(pos: Vector2, text: String, width: float = 120.0, draw_in: bool = true) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.THOUGHT_BUBBLE
	doodle.global_position = pos
	doodle.custom_text = text
	doodle.doodle_size = width
	doodle.set_style(style)
	_register_doodle(doodle)
	if draw_in:
		doodle.draw_on(0.24)
	return doodle

## Spawn checkmark
func spawn_check(pos: Vector2, size: float = 30.0) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.CHECK_MARK
	doodle.global_position = pos
	doodle.doodle_size = size
	doodle.set_style(style)
	_register_doodle(doodle)
	doodle.draw_on(0.18)
	return doodle

## Spawn cross-out X mark
func spawn_cross(pos: Vector2, size: float = 30.0) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.CROSS_OUT
	doodle.global_position = pos
	doodle.doodle_size = size
	doodle.set_style(style)
	_register_doodle(doodle)
	doodle.draw_on(0.18)
	return doodle

## Spawn handwritten label
func spawn_label(pos: Vector2, text: String, duration: float = 0.25) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.HANDWRITTEN_LABEL
	doodle.global_position = pos
	doodle.custom_text = text
	doodle.set_style(style)
	_register_doodle(doodle)
	doodle.draw_on(duration)
	return doodle

## Spawn hand-drawn bracket
func spawn_bracket(pos: Vector2, height: float = 60.0, duration: float = 0.20) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.BRACKET
	doodle.global_position = pos
	doodle.doodle_size = height * 0.5
	doodle.set_style(style)
	_register_doodle(doodle)
	doodle.draw_on(duration)
	return doodle

## Spawn mini-illustration (clock, bridge, banana, note, dumbbell, etc.)
func spawn_mini(pos: Vector2, illustration_name: String, size: float = 36.0, duration: float = 0.28) -> Node2D:
	var doodle := DoodleInstanceScript.new()
	match illustration_name.to_lower():
		"clock": doodle.doodle_type = DoodleInstanceScript.Type.MINI_CLOCK
		"bridge": doodle.doodle_type = DoodleInstanceScript.Type.MINI_BRIDGE
		"banana", "banana_peel": doodle.doodle_type = DoodleInstanceScript.Type.MINI_BANANA
		"note", "musical_note": doodle.doodle_type = DoodleInstanceScript.Type.MINI_NOTE
		"dumbbell": doodle.doodle_type = DoodleInstanceScript.Type.MINI_DUMBBELL
		"calendar": doodle.doodle_type = DoodleInstanceScript.Type.MINI_CALENDAR
		"brain": doodle.doodle_type = DoodleInstanceScript.Type.MINI_BRAIN
		"magnifier": doodle.doodle_type = DoodleInstanceScript.Type.MINI_MAGNIFIER
		"car": doodle.doodle_type = DoodleInstanceScript.Type.MINI_CAR
		"person": doodle.doodle_type = DoodleInstanceScript.Type.MINI_PERSON
		_: doodle.doodle_type = DoodleInstanceScript.Type.MINI_NOTE
	doodle.global_position = pos
	doodle.doodle_size = size
	doodle.set_style(style)
	_register_doodle(doodle)
	doodle.draw_on(duration)
	return doodle

# -------------------------------------------------------------------------
# CLEANUP & BATCH UTILITIES
# -------------------------------------------------------------------------

## Instantly clear all active doodles
func clear_all() -> void:
	for doodle in active_doodles:
		if is_instance_valid(doodle):
			doodle.queue_free()
	active_doodles.clear()

## Smoothly fade and pop out all active doodles
func fade_out_all(duration: float = 0.2) -> void:
	var to_remove := active_doodles.duplicate()
	for doodle in to_remove:
		if is_instance_valid(doodle):
			doodle.pop_out(duration).connect(func(): if is_instance_valid(doodle): doodle.queue_free())
	active_doodles.clear()
