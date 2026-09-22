class_name LeonVisual
extends Node2D

## Visual & Pivot Hierarchy Manager for LEON (Brawl Stars)
## Coordinates all sub-components, distributes palette updates, and exposes transform hooks:
## - HeadPivot (head tilt, crouch offset)
## - Hood (cowl, crest, chameleon bubble eyes, tail)
## - Face (eyes, tooth smirk, visemes, lollipop, FX)
## - Torso (hoodie body, kangaroo pocket, zipper)
## - Limbs (shorts, bare legs, blue mittens)
## - LollipopShuriken (fidget spinner shurikens)

const LeonStyle = preload("res://brawl_stars/characters/leon/LeonStyle.gd")

var style: LeonStyle

@onready var head_pivot: Node2D = $HeadPivot
@onready var hood: Node2D = $HeadPivot/Hood
@onready var face: Node2D = $HeadPivot/Face
@onready var torso: Node2D = $Torso
@onready var limbs: Node2D = $Limbs
@onready var shurikens: Node2D = $LollipopShuriken

# Transform hooks
var head_tilt: float = 0.0:
	set(val):
		head_tilt = val
		if head_pivot:
			head_pivot.rotation = head_tilt

var head_offset: Vector2 = Vector2.ZERO:
	set(val):
		head_offset = val
		if head_pivot:
			head_pivot.position = Vector2(0, -60) + head_offset

var torso_lean: float = 0.0:
	set(val):
		torso_lean = val
		if torso:
			torso.rotation = torso_lean

var tail_wag: float = 0.0:
	set(val):
		tail_wag = val
		if hood:
			hood.set("tail_wag", tail_wag)
			hood.queue_redraw()

func _ready() -> void:
	if not style:
		style = LeonStyle.new()
	_apply_style_to_children()
	style.style_changed.connect(_on_style_changed)

func _apply_style_to_children() -> void:
	if hood:
		hood.set("style", style)
		hood.queue_redraw()
	if face:
		face.set("style", style)
		face.queue_redraw()
	if torso:
		torso.set("style", style)
		torso.queue_redraw()
	if limbs:
		limbs.set("style", style)
		limbs.queue_redraw()
	if shurikens:
		shurikens.set("style", style)
		shurikens.queue_redraw()

func _on_style_changed() -> void:
	_apply_style_to_children()
	queue_redraw()
