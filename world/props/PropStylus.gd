extends "res://world/props/NemiProp.gd"

## Illustrated Digital Drawing Stylus Prop
## Ergonomic tablet pen with rocker button and fine white drawing tip.

func _init() -> void:
	prop_name = "stylus"
	current_state = "normal"

func _draw() -> void:
	var l := 38.0
	var w := 4.2
	
	# Body (slate grey)
	var body_col: Color = style.metal_slate
	var body_pts := PackedVector2Array([
		Vector2(-l * 0.5, -w * 0.35),
		Vector2(l * 0.5 - 7.0, -w * 0.5),
		Vector2(l * 0.5 - 7.0, w * 0.5),
		Vector2(-l * 0.5, w * 0.35)
	])
	draw_illustrated_polygon(body_pts, body_col, style.structural_width)
	
	# Grip flare
	var grip_pts := PackedVector2Array([
		Vector2(l * 0.5 - 16.0, -w * 0.55),
		Vector2(l * 0.5 - 7.0, -w * 0.5),
		Vector2(l * 0.5 - 7.0, w * 0.5),
		Vector2(l * 0.5 - 16.0, w * 0.55)
	])
	draw_illustrated_polygon(grip_pts, Color("#26232d"), style.detail_line_width)
	
	# Side rocker button
	draw_ink_line(PackedVector2Array([Vector2(l * 0.5 - 14.0, -w * 0.55 - 1.0), Vector2(l * 0.5 - 9.0, -w * 0.5 - 1.0)]), 1.5)
	
	# Fine nib cone
	var nib_pts := PackedVector2Array([
		Vector2(l * 0.5 - 7.0, -w * 0.4),
		Vector2(l * 0.5, 0.0),
		Vector2(l * 0.5 - 7.0, w * 0.4)
	])
	draw_illustrated_polygon(nib_pts, Color("#ffffff"), style.detail_line_width)
