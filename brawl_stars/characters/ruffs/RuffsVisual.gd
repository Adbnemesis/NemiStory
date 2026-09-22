class_name RuffsVisual
extends Node2D

## Visual & Pivot Hierarchy Manager for COLONEL RUFFS (Brawl Stars)
## Coordinates all sub-components, distributes palette updates, and exposes transform hooks:
## - HeadPivot (tilt, vertical offset, ear physics/angles)
## - Torso (posture lean, collar, medals, epaulettes)
## - Limbs (military stances: attention, parade rest, confident, walking)
## - RightArm (salute, aim blaster, command point, on hip)

const RuffsStyle = preload("res://brawl_stars/characters/ruffs/RuffsStyle.gd")

var style: RuffsStyle

@onready var head_pivot: Node2D = $HeadPivot
@onready var head: Node2D = $HeadPivot/Head
@onready var face: Node2D = $HeadPivot/Face
@onready var torso: Node2D = $Torso
@onready var limbs: Node2D = $Limbs
@onready var right_arm: Node2D = $RightArm

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
			head_pivot.position = Vector2(0, -85) + head_offset

var torso_lean: float = 0.0:
	set(val):
		torso_lean = val
		if torso:
			torso.torso_lean = torso_lean
		if right_arm:
			right_arm.rotation = torso_lean

var left_ear_angle: float = 0.0:
	set(val):
		left_ear_angle = val
		if head and "left_ear_angle" in head:
			head.left_ear_angle = left_ear_angle
			head.queue_redraw()

var right_ear_angle: float = 0.0:
	set(val):
		right_ear_angle = val
		if head and "right_ear_angle" in head:
			head.right_ear_angle = right_ear_angle
			head.queue_redraw()

var ear_droop: float = 0.0:
	set(val):
		ear_droop = val
		if head and "ear_droop" in head:
			head.ear_droop = ear_droop
			head.queue_redraw()

func _ready() -> void:
	if not style:
		style = RuffsStyle.new()
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
	if right_arm:
		right_arm.set("style", style)
		right_arm.queue_redraw()

func _on_style_changed() -> void:
	_apply_style_to_children()

func set_art_mode(mode: RuffsStyle.ArtMode) -> void:
	if style:
		style.set_mode(mode)
