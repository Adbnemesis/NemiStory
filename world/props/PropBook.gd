class_name PropBook
extends "res://world/props/NemiProp.gd"

## Illustrated Book / Notebook Prop
## Features open / closed states, page layers, bookmark ribbon, and pen.

func _init() -> void:
	prop_name = "book"
	current_state = "open"

func _draw() -> void:
	if current_state == "closed":
		_draw_closed()
	else:
		_draw_open()

func _draw_open() -> void:
	var w := 48.0
	var h := 32.0
	
	# Left page
	var left_page := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),
		Vector2(0.0, -h * 0.44),
		Vector2(0.0, h * 0.44),
		Vector2(-w * 0.5, h * 0.5)
	])
	draw_illustrated_polygon(left_page, style.metal_light, style.outer_contour_width)
	
	# Right page
	var right_page := PackedVector2Array([
		Vector2(0.0, -h * 0.44),
		Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.5, h * 0.5),
		Vector2(0.0, h * 0.44)
	])
	draw_illustrated_polygon(right_page, style.metal_light, style.outer_contour_width)
	
	# Center spine fold
	draw_ink_line(PackedVector2Array([Vector2(0.0, -h * 0.48), Vector2(0.0, h * 0.48)]), style.structural_width)
	
	# Illustrated text scribble lines
	for i in range(3):
		var y := -h * 0.25 + float(i) * 7.0
		draw_ink_line(PackedVector2Array([Vector2(-w * 0.42, y), Vector2(-w * 0.08, y)]), style.detail_line_width)
		draw_ink_line(PackedVector2Array([Vector2(w * 0.08, y), Vector2(w * 0.42, y)]), style.detail_line_width)
	
	# Bookmark ribbon hanging down
	var ribbon := PackedVector2Array([Vector2(0.0, h * 0.44), Vector2(3.0, h * 0.65), Vector2(1.0, h * 0.72)])
	draw_ink_line(ribbon, 1.8, InkStroke.Profile.TAPER_END)

func _draw_closed() -> void:
	var w := 28.0
	var h := 36.0
	var cover_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.48, h * 0.5),
		Vector2(-w * 0.48, h * 0.5)
	])
	draw_illustrated_polygon(cover_pts, style.accent_rose, style.outer_contour_width)
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.38, -h * 0.5), Vector2(-w * 0.38, h * 0.5)]), style.structural_width)
