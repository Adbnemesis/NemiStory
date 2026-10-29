class_name StoryProp
extends Node2D

## Reusable Prop Controller for Storytime Animatic
## Handles snappy pop-ins with intentional overshoot, shakes, and hand-attachment.

@export var prop_name: String = "prop"

@onready var sprite: Sprite2D = $Sprite2D

var base_scale: Vector2 = Vector2.ONE
var target_node: Node2D = null

func _ready() -> void:
	if sprite:
		base_scale = sprite.scale

func _process(_delta: float) -> void:
	if target_node:
		global_position = target_node.global_position

## Snappy pop-in with stepped/overshoot settle
func pop_in(overshoot: bool = true, duration: float = 0.18) -> void:
	visible = true
	if overshoot:
		scale = Vector2.ZERO
		var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", base_scale, duration)
	else:
		scale = base_scale

## Instant pop-out
func pop_out(snap: bool = false, duration: float = 0.12) -> void:
	if snap:
		visible = false
		scale = Vector2.ZERO
	else:
		var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "scale", Vector2.ZERO, duration)
		tween.tween_callback(func(): visible = false)

## Attach prop to a character's hand or marker
func attach_to(marker: Marker2D) -> void:
	target_node = marker

func detach() -> void:
	target_node = null
