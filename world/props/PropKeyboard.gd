class_name PropKeyboard
extends "res://world/props/NemiProp.gd"

## Illustrated Mechanical Keyboard Prop
## Angled keyboard chassis with keycap rows and spacebar.

func _init() -> void:
	prop_name = "keyboard"
	current_state = "normal"

func _draw() -> void:
	var w := 54.0
	var h := 22.0
	
	# Base chassis (angled slightly in isometric/2.5D perspective)
	var base_pts := PackedVector2Array([
		Vector2(-w * 0.5 + 3.0, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5 + 2.0),
		Vector2(w * 0.5 - 3.0, h * 0.5),
		Vector2(-w * 0.5, h * 0.5 - 2.0)
	])
	draw_illustrated_polygon(base_pts, style.metal_dark, style.outer_contour_width)
	
	# 3 rows of keycaps
	var row_y := [-h * 0.5 + 4.5, 0.0, h * 0.5 - 5.0]
	for ry in row_y:
		var line_pts := PackedVector2Array([
			Vector2(-w * 0.45, ry), Vector2(w * 0.45, ry)
		])
		draw_ink_line(line_pts, 1.4)
		# Key notches
		for k in range(8):
			var kx := -w * 0.4 + float(k) * 6.0
			draw_ink_line(PackedVector2Array([Vector2(kx, ry - 1.5), Vector2(kx, ry + 1.5)]), 1.1)
	
	# Spacebar bottom center
	var sb := PackedVector2Array([
		Vector2(-8.0, h * 0.5 - 4.5), Vector2(8.0, h * 0.5 - 4.5),
		Vector2(8.0, h * 0.5 - 2.0), Vector2(-8.0, h * 0.5 - 2.0)
	])
	draw_illustrated_polygon(sb, Color("#605b6e"), style.detail_line_width)
