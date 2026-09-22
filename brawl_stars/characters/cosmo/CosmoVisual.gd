class_name CosmoVisual
extends Node2D

## Visual & Pivot Hierarchy Manager for COSMO (Brawl Stars)
## Coordinates all sub-components, distributes palette updates, and exposes transform hooks:
## - HeadPivot (tilt, float offset, levitation bob)
## - Torso (lean angle, clothing contours)
## - Limbs (leg stance, boot positions, left arm gestures)
## - AttractorArm (gauntlet orientation, hand poses, magnetic effects)

const CosmoStyle = preload("res://brawl_stars/characters/cosmo/CosmoStyle.gd")

var style: CosmoStyle

@onready var head_pivot: Node2D = $HeadPivot
@onready var head: Node2D = $HeadPivot/Head
@onready var face: Node2D = $HeadPivot/Face
@onready var torso: Node2D = $Torso
@onready var limbs: Node2D = $Limbs
@onready var attractor_arm: Node2D = $AttractorArm

# Transform hooks
var head_tilt: float = 0.0:
	set(val):
		head_tilt = val
		if head_pivot:
			head_pivot.rotation = head_tilt

var head_floating_offset: Vector2 = Vector2.ZERO:
	set(val):
		head_floating_offset = val
		if head_pivot:
			head_pivot.position = Vector2(0, -185) + head_floating_offset

var torso_lean: float = 0.0:
	set(val):
		torso_lean = val
		if torso:
			torso.torso_lean = torso_lean
		if attractor_arm:
			attractor_arm.rotation = torso_lean

func _ready() -> void:
	if not style:
		style = CosmoStyle.new()
	_apply_style_to_children()
	style.style_changed.connect(_on_style_changed)

func _apply_style_to_children() -> void:
	if head:
		head.set("style", style)
		head.queue_redraw()
	if face:
		face.set("style", style)
		face.queue_redraw()
	if torso:
		torso.set("style", style)
		torso.queue_redraw()
	if limbs:
		limbs.set("style", style)
		limbs.queue_redraw()
	if attractor_arm:
		attractor_arm.set("style", style)
		attractor_arm.queue_redraw()

func _on_style_changed() -> void:
	_apply_style_to_children()

func set_art_mode(mode: CosmoStyle.ArtMode) -> void:
	if style:
		style.set_mode(mode)
