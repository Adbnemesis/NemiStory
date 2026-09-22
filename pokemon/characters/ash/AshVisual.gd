class_name AshVisual
extends Node2D

## Master 2D Visual Coordinator for ASH KETCHUM
## Manages layered drawing, procedural parts, head rotation, and style synchronization.

const AshStyle = preload("res://pokemon/characters/ash/AshStyle.gd")
const AshHead = preload("res://pokemon/characters/ash/parts/AshHead.gd")
const AshFace = preload("res://pokemon/characters/ash/parts/AshFace.gd")
const AshTorso = preload("res://pokemon/characters/ash/parts/AshTorso.gd")
const AshLimbs = preload("res://pokemon/characters/ash/parts/AshLimbs.gd")

var style: AshStyle:
	set(val):
		if style != val:
			if style and style.style_changed.is_connected(_on_style_changed):
				style.style_changed.disconnect(_on_style_changed)
			style = val
			if style:
				style.style_changed.connect(_on_style_changed)
			_propagate_style()
			queue_redraw()

@onready var torso: Node2D = $Torso
@onready var limbs: Node2D = $Limbs
@onready var head_pivot: Node2D = $HeadPivot
@onready var head: Node2D = $HeadPivot/Head
@onready var face: Node2D = $HeadPivot/Face

var head_tilt: float = 0.0:
	set(val):
		head_tilt = val
		if head_pivot:
			head_pivot.rotation = val

func _ready() -> void:
	if not style:
		style = AshStyle.new()
	_propagate_style()
	queue_redraw()

func _propagate_style() -> void:
	if not is_inside_tree():
		return
	if torso:
		torso.set("style", style)
		torso.queue_redraw()
	if limbs:
		limbs.set("style", style)
		limbs.queue_redraw()
	if head:
		head.set("style", style)
		head.queue_redraw()
	if face:
		face.set("style", style)
		face.queue_redraw()

func _on_style_changed() -> void:
	_propagate_style()
	queue_redraw()
