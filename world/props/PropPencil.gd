class_name PropPencil
extends "res://world/props/NemiProp.gd"

## Illustrated Pencil Prop
## Classic yellow hexagonal wooden pencil with pink eraser and graphite tip.

func _init() -> void:
	prop_name = "pencil"
	current_state = "normal"

func _draw() -> void:
	var l := 42.0
	var w := 5.0
	
	# Yellow body
	var yellow_col := Color("#e8b84d") if (not style or style.is_color()) else Color("#edeae4")
	var body_pts := PackedVector2Array([
		Vector2(-l * 0.5 + 8.0, -w * 0.5),
		Vector2(l * 0.5 - 6.0, -w * 0.5),
		Vector2(l * 0.5 - 6.0, w * 0.5),
		Vector2(-l * 0.5 + 8.0, w * 0.5)
	])
	draw_illustrated_polygon(body_pts, yellow_col, style.structural_width)
	
	# Metal ferrule band
	var ferrule_pts := PackedVector2Array([
		Vector2(-l * 0.5 + 8.0, -w * 0.5),
		Vector2(-l * 0.5 + 4.0, -w * 0.5),
		Vector2(-l * 0.5 + 4.0, w * 0.5),
		Vector2(-l * 0.5 + 8.0, w * 0.5)
	])
	draw_illustrated_polygon(ferrule_pts, Color("#9e9da4"), style.detail_line_width)
	
	# Pink eraser
	var pink_col := Color("#d98282") if (not style or style.is_color()) else Color("#dedede")
	var eraser_pts := PackedVector2Array([
		Vector2(-l * 0.5 + 4.0, -w * 0.45),
		Vector2(-l * 0.5, -w * 0.4),
		Vector2(-l * 0.5, w * 0.4),
		Vector2(-l * 0.5 + 4.0, w * 0.45)
	])
	draw_illustrated_polygon(eraser_pts, pink_col, style.detail_line_width)
	
	# Sharpened wood cone
	var wood_pts := PackedVector2Array([
		Vector2(l * 0.5 - 6.0, -w * 0.5),
		Vector2(l * 0.5, 0.0),
		Vector2(l * 0.5 - 6.0, w * 0.5)
	])
	draw_illustrated_polygon(wood_pts, Color("#deb887"), style.detail_line_width)
	
	# Graphite lead tip
	var tip_pts := PackedVector2Array([
		Vector2(l * 0.5 - 2.5, -w * 0.2),
		Vector2(l * 0.5, 0.0),
		Vector2(l * 0.5 - 2.5, w * 0.2)
	])
	draw_colored_polygon(tip_pts, style.ink_line_color)
