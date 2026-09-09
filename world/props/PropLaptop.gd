class_name PropLaptop
extends "res://world/props/NemiProp.gd"

## Illustrated Laptop Prop
## Features open / closed states, angled screen bevel, keyboard lines, and screen glow.

func _init() -> void:
	prop_name = "laptop"
	current_state = "open"

func _draw() -> void:
	if current_state == "closed":
		_draw_closed()
	else:
		_draw_open()

func _draw_open() -> void:
	var base_w := 64.0
	var base_d := 22.0
	var screen_h := 38.0
	
	# 1. Base (bottom chassis in slight perspective)
	var base_pts := PackedVector2Array([
		Vector2(-base_w * 0.45, 0.0),           # top-left
		Vector2(base_w * 0.45, 0.0),            # top-right
		Vector2(base_w * 0.50, base_d),         # bottom-right
		Vector2(-base_w * 0.50, base_d)         # bottom-left
	])
	draw_illustrated_polygon(base_pts, style.metal_slate, style.outer_contour_width)
	
	# Trackpad
	var pad_pts := PackedVector2Array([
		Vector2(-7.0, base_d * 0.45),
		Vector2(7.0, base_d * 0.45),
		Vector2(6.5, base_d * 0.85),
		Vector2(-6.5, base_d * 0.85)
	])
	draw_colored_polygon(pad_pts, style.metal_dark)
	var pad_stroke := pad_pts.duplicate(); pad_stroke.append(pad_pts[0])
	draw_ink_line(pad_stroke, style.detail_line_width)
	
	# Keyboard area (simplified illustrated strip)
	var kb_pts := PackedVector2Array([
		Vector2(-base_w * 0.38, 3.0),
		Vector2(base_w * 0.38, 3.0),
		Vector2(base_w * 0.42, base_d * 0.40),
		Vector2(-base_w * 0.42, base_d * 0.40)
	])
	draw_colored_polygon(kb_pts, style.metal_dark)
	
	# Subtle key row lines
	draw_ink_line(PackedVector2Array([Vector2(-base_w * 0.36, 6.0), Vector2(base_w * 0.36, 6.0)]), 1.1)
	draw_ink_line(PackedVector2Array([Vector2(-base_w * 0.39, 9.0), Vector2(base_w * 0.39, 9.0)]), 1.1)
	
	# 2. Screen Bevel (stands upright, tilted slightly back)
	var lid_pts := PackedVector2Array([
		Vector2(-base_w * 0.44, -screen_h),     # top-left
		Vector2(base_w * 0.44, -screen_h),      # top-right
		Vector2(base_w * 0.42, 0.0),            # bottom-right
		Vector2(-base_w * 0.42, 0.0)            # bottom-left
	])
	draw_illustrated_polygon(lid_pts, style.metal_dark, style.outer_contour_width)
	
	# 3. Screen display
	var scr_margin := 3.5
	var scr_pts := PackedVector2Array([
		Vector2(-base_w * 0.44 + scr_margin, -screen_h + scr_margin),
		Vector2(base_w * 0.44 - scr_margin, -screen_h + scr_margin),
		Vector2(base_w * 0.42 - scr_margin, -scr_margin),
		Vector2(-base_w * 0.42 + scr_margin, -scr_margin)
	])
	draw_colored_polygon(scr_pts, style.screen_glow)
	var scr_stroke := scr_pts.duplicate(); scr_stroke.append(scr_pts[0])
	draw_ink_line(scr_stroke, style.detail_line_width)
	
	# 4. Illustrated code/text lines on screen
	var line_col: Color = style.metal_dark
	for i in range(4):
		var y := -screen_h + 8.0 + float(i) * 6.5
		var lw := randf_range(16.0, 32.0)
		draw_ink_line(PackedVector2Array([Vector2(-base_w * 0.32, y), Vector2(-base_w * 0.32 + lw, y)]), 1.3)
	
	# Camera dot
	draw_circle(Vector2(0.0, -screen_h + 1.8), 0.9, style.ink_line_color)

func _draw_closed() -> void:
	var w := 62.0
	var h := 8.0
	var lid_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.48, h * 0.5),
		Vector2(-w * 0.48, h * 0.5)
	])
	draw_illustrated_polygon(lid_pts, style.metal_slate, style.outer_contour_width)
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.48, 0.0), Vector2(w * 0.48, 0.0)]), style.inner_line_width)
