class_name PokemonBaseProp
extends Node2D

## Base class for illustrated Pokémon story props
## Implements canonical lifecycle: pop_in, drop, bounce, shake, attach_to, detach, and fade_out.

signal interaction_completed(action_name: String)

var is_attached: bool = false
var _attach_target: Node2D
var _attach_offset: Vector2 = Vector2.ZERO
var _tween: Tween

func _process(_delta: float) -> void:
	if is_attached and is_instance_valid(_attach_target):
		global_position = _attach_target.global_position + _attach_offset

func pop_in(duration: float = 0.25) -> void:
	scale = Vector2.ZERO
	visible = true
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(1.15, 1.15), duration * 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2.ONE, duration * 0.3)
	await _tween.finished
	interaction_completed.emit("pop_in")

func drop(distance: float = 120.0, duration: float = 0.35) -> void:
	var final_pos := position
	position.y -= distance
	visible = true
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position:y", final_pos.y, duration).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await _tween.finished
	interaction_completed.emit("drop")

func bounce(height: float = 18.0, duration: float = 0.3) -> void:
	var orig_y := position.y
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position:y", orig_y - height, duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position:y", orig_y, duration * 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await _tween.finished
	interaction_completed.emit("bounce")

func shake(intensity: float = 4.0, duration: float = 0.4) -> void:
	var orig_pos := position
	var tw := create_tween()
	var steps := int(duration / 0.05)
	for i in range(steps):
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity * 0.5, intensity * 0.5))
		tw.tween_property(self, "position", orig_pos + offset, 0.05)
	tw.tween_property(self, "position", orig_pos, 0.05)
	await tw.finished
	interaction_completed.emit("shake")

func attach_to(target_node: Node2D, offset: Vector2 = Vector2.ZERO) -> void:
	_attach_target = target_node
	_attach_offset = offset
	is_attached = true

func detach() -> void:
	is_attached = false
	_attach_target = null

func fade_out(duration: float = 0.25) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, duration)
	await _tween.finished
	visible = false
	modulate.a = 1.0
	interaction_completed.emit("fade_out")
