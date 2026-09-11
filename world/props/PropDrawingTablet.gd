class_name PropDrawingTablet
extends "res://world/props/NemiProp.gd"

## Illustrated Pen Display Tablet Prop
## Digital drawing tablet with active screen canvas and side express keys.

func _init() -> void:
	prop_name = "drawing_tablet"
	current_state = "active"

func _draw() -> void:
	var w := 56.0
	var h := 38.0
	
	# Bezel chassis
	var bezel_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.5, h * 0.5),
		Vector2(-w * 0.5, h * 0.5)
	])
	draw_illustrated_polygon(bezel_pts, style.metal_dark, style.outer_contour_width)
	
	# Active drawing screen
	var sw := w - 16.0
	var sh := h - 8.0
	var screen_pts := PackedVector2Array([
		Vector2(-sw * 0.5 + 4.0, -sh * 0.5),
		Vector2(sw * 0.5 + 4.0, -sh * 0.5),
		Vector2(sw * 0.5 + 4.0, sh * 0.5),
		Vector2(-sw * 0.5 + 4.0, sh * 0.5)
	])
	var screen_col: Color = style.screen_glow if current_state == "active" else Color("#1a1820")
	draw_illustrated_polygon(screen_pts, screen_col, style.structural_width)
	
	# Drawing on screen (a little hand-drawn character doodle line)
	if current_state == "active":
		var doodle_pts := PackedVector2Array([
			Vector2(-4.0, 4.0), Vector2(0.0, -6.0), Vector2(8.0, -2.0), Vector2(14.0, 6.0)
		])
		draw_ink_line(doodle_pts, 1.8)
	
	# Left side express keys
	for i in range(4):
		var ky := -h * 0.5 + 8.0 + float(i) * 7.5
		var key_pts := PackedVector2Array([
			Vector2(-w * 0.5 + 3.0, ky),
			Vector2(-w * 0.5 + 7.0, ky),
			Vector2(-w * 0.5 + 7.0, ky + 4.5),
			Vector2(-w * 0.5 + 3.0, ky + 4.5)
		])
		draw_illustrated_polygon(key_pts, Color("#26232e"), style.detail_line_width)
