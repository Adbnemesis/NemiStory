class_name PikachuVisual
extends Node2D

## Master 2D Visual Coordinator for PIKACHU
## Manages layered drawing, procedural parts, head base, and style synchronization.

const PikachuStyle = preload("res://pokemon/characters/pikachu/PikachuStyle.gd")
const PikachuTail = preload("res://pokemon/characters/pikachu/parts/PikachuTail.gd")
const PikachuLimbs = preload("res://pokemon/characters/pikachu/parts/PikachuLimbs.gd")
const PikachuHeadBase = preload("res://pokemon/characters/pikachu/parts/PikachuHeadBase.gd")
const PikachuEars = preload("res://pokemon/characters/pikachu/parts/PikachuEars.gd")
const PikachuFace = preload("res://pokemon/characters/pikachu/parts/PikachuFace.gd")

var style: PikachuStyle:
	set(val):
		if style != val:
			if style and style.style_changed.is_connected(_on_style_changed):
				style.style_changed.disconnect(_on_style_changed)
			style = val
			if style:
				style.style_changed.connect(_on_style_changed)
			_propagate_style()
			queue_redraw()

@onready var tail: Node2D = $Tail
@onready var limbs: Node2D = $Limbs
@onready var head_pivot: Node2D = $HeadPivot
@onready var head_base: Node2D = $HeadPivot/HeadBase
@onready var ears: Node2D = $HeadPivot/Ears
@onready var face: Node2D = $HeadPivot/Face

var head_tilt: float = 0.0:
	set(val):
		head_tilt = val
		if head_pivot:
			head_pivot.rotation = val

func _ready() -> void:
	if not style:
		style = PikachuStyle.new()
	_propagate_style()
	queue_redraw()

func _propagate_style() -> void:
	if not is_inside_tree():
		return
	if tail:
		tail.set("style", style)
		tail.queue_redraw()
	if limbs:
		limbs.set("style", style)
		limbs.queue_redraw()
	if head_base:
		head_base.set("style", style)
		head_base.queue_redraw()
	if ears:
		ears.set("style", style)
		ears.queue_redraw()
	if face:
		face.set("style", style)
		face.queue_redraw()

func _on_style_changed() -> void:
	_propagate_style()
	queue_redraw()
