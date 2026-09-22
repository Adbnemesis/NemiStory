class_name EdgarVisual
extends Node2D

## Visual & Pivot Hierarchy Manager for EDGAR (Brawl Stars)
## Coordinates all sub-components, distributes palette updates, and exposes transform hooks:
## - HeadPivot (head tilt, slouch offset)
## - Head (pale skin base, ear studs, emo hair fringe)
## - Face (white emo eyes, heavy eyeliner, mouth visemes)
## - Scarf (living sentient striped scarf, cowl wrap, demon fists)
## - Torso (red punk vest, skull shirt, pins, studded belt)
## - Limbs (skinny jeans, red pinstripe, purple fingerless gloves, creepers)

const EdgarStyle = preload("res://brawl_stars/characters/edgar/EdgarStyle.gd")

var style: EdgarStyle

@onready var head_pivot: Node2D = $HeadPivot
@onready var head: Node2D = $HeadPivot/Head
@onready var face: Node2D = $HeadPivot/Face
@onready var scarf: Node2D = $HeadPivot/Scarf
@onready var torso: Node2D = $Torso
@onready var limbs: Node2D = $Limbs

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

var scarf_sway: float = 0.0:
	set(val):
		scarf_sway = val
		if scarf:
			scarf.set("scarf_sway", scarf_sway)
			scarf.queue_redraw()

func _ready() -> void:
	if not style:
		style = EdgarStyle.new()
	_apply_style_to_children()
	style.style_changed.connect(_on_style_changed)

func _apply_style_to_children() -> void:
	if head:
		head.set("style", style)
		head.queue_redraw()
	if face:
		face.set("style", style)
		face.queue_redraw()
	if scarf:
		scarf.set("style", style)
		scarf.queue_redraw()
	if torso:
		torso.set("style", style)
		torso.queue_redraw()
	if limbs:
		limbs.set("style", style)
		limbs.queue_redraw()

func _on_style_changed() -> void:
	_apply_style_to_children()
	queue_redraw()
