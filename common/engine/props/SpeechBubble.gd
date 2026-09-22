class_name SpeechBubble
extends Node2D

## Hand-drawn styled Speech Bubble component
## Displays dialogue or reaction sounds with snappy animatic pop-in.

@onready var bubble_sprite: Sprite2D = $BubbleSprite
@onready var text_label: Label = $TextLabel

func _ready() -> void:
	visible = false
	scale = Vector2.ZERO

## Show speech bubble with snappy overshoot pop-in
func show_text(text: String, at_pos: Vector2, duration: float = 0.16) -> void:
	if text_label:
		text_label.text = text
	position = at_pos
	visible = true
	scale = Vector2.ZERO

	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, duration)

## Hide bubble with snap or pop-out
func hide_bubble(snap: bool = false) -> void:
	if snap:
		visible = false
		scale = Vector2.ZERO
	else:
		var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
		tween.tween_callback(func(): visible = false)
