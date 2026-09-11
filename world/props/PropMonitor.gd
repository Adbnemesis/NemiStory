class_name PropMonitor
extends "res://world/props/NemiProp.gd"

## Illustrated Desktop Display Monitor Prop
## Widescreen computer display mounted on metallic stand base.

func _init() -> void:
	prop_name = "monitor"
	current_state = "on"

func _draw() -> void:
	var w := 64.0
	var h := 42.0
	
	# Stand base plate on desk
	var base_pts := PackedVector2Array([
		Vector2(-14.0, h * 0.5 + 10.0),
		Vector2(14.0, h * 0.5 + 10.0),
		Vector2(16.0, h * 0.5 + 13.0),
		Vector2(-16.0, h * 0.5 + 13.0)
	])
	draw_illustrated_polygon(base_pts, style.metal_dark, style.structural_width)
	
	# Stand vertical neck
	var neck_pts := PackedVector2Array([
		Vector2(-3.0, h * 0.5 - 2.0),
		Vector2(3.0, h * 0.5 - 2.0),
		Vector2(3.0, h * 0.5 + 10.0),
		Vector2(-3.0, h * 0.5 + 10.0)
	])
	draw_illustrated_polygon(neck_pts, style.metal_dark, style.structural_width)
	
	# Outer display bezel
	var bezel_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.5, h * 0.5),
		Vector2(-w * 0.5, h * 0.5)
	])
	draw_illustrated_polygon(bezel_pts, style.metal_dark, style.outer_contour_width)
	
	# Active glowing screen
	var sw := w - 6.0
	var sh := h - 6.0
	var screen_pts := PackedVector2Array([
		Vector2(-sw * 0.5, -sh * 0.5),
		Vector2(sw * 0.5, -sh * 0.5),
		Vector2(sw * 0.5, sh * 0.5),
		Vector2(-sw * 0.5, sh * 0.5)
	])
	var screen_col: Color = style.screen_glow if current_state == "on" else Color("#15131b")
	draw_colored_polygon(screen_pts, screen_col)
	draw_ink_line(screen_pts, style.structural_width)
	
	# Screen contents: UI code lines / animation curve
	if current_state == "on":
		var graph_pts := PackedVector2Array([
			Vector2(-sw * 0.35, sh * 0.25),
			Vector2(-sw * 0.1, -sh * 0.2),
			Vector2(sw * 0.1, sh * 0.1),
			Vector2(sw * 0.35, -sh * 0.25)
		])
		draw_ink_line(graph_pts, 1.8)
