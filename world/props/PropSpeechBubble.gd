class_name PropSpeechBubble
extends "res://world/props/NemiProp.gd"

## Illustrated Comic Speech Bubble Prop
## Organic dialogue bubble with directional pointer tail.

func _init() -> void:
	prop_name = "speech_bubble"
	current_state = "normal"

func _draw() -> void:
	var w := 60.0
	var h := 36.0
	
	# Bubble polygon with tail integrated on bottom-left
	var pts := PackedVector2Array([
		Vector2(-w * 0.45, -h * 0.5),
		Vector2(w * 0.45, -h * 0.5),
		Vector2(w * 0.5, -h * 0.25),
		Vector2(w * 0.5, h * 0.25),
		Vector2(w * 0.45, h * 0.5),
		Vector2(-w * 0.15, h * 0.5),
		Vector2(-w * 0.35, h * 0.5 + 14.0), # Tail tip
		Vector2(-w * 0.25, h * 0.5),
		Vector2(-w * 0.45, h * 0.5),
		Vector2(-w * 0.5, h * 0.25),
		Vector2(-w * 0.5, -h * 0.25)
	])
	draw_illustrated_polygon(pts, Color("#ffffff"), style.outer_contour_width)
	
	# Dialogue text placeholder lines
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.35, -5.0), Vector2(w * 0.35, -5.0)]), 1.8)
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.3, 5.0), Vector2(w * 0.2, 5.0)]), 1.8)
