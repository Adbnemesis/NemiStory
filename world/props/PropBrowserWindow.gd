class_name PropBrowserWindow
extends "res://world/props/NemiProp.gd"

## Illustrated Web Browser Window Prop
## Floating desktop browser window with tabs, window buttons, and URL bar.

func _init() -> void:
	prop_name = "browser_window"
	current_state = "normal"

func _draw() -> void:
	var w := 84.0
	var h := 56.0
	
	# Outer window chassis
	var win_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.5, h * 0.5),
		Vector2(-w * 0.5, h * 0.5)
	])
	draw_illustrated_polygon(win_pts, Color("#fdfcfb"), style.outer_contour_width)
	
	# Top title / tab bar
	var bar_h := 12.0
	var bar_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5 + bar_h),
		Vector2(-w * 0.5, -h * 0.5 + bar_h)
	])
	draw_colored_polygon(bar_pts, Color("#ebe7df"))
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.5, -h * 0.5 + bar_h), Vector2(w * 0.5, -h * 0.5 + bar_h)]), 1.5)
	
	# 3 window traffic light dots
	var dot_col := [Color("#e06c75"), Color("#e5c07b"), Color("#98c379")]
	for i in range(3):
		var dx := -w * 0.5 + 6.0 + float(i) * 5.0
		var dy := -h * 0.5 + bar_h * 0.5
		var dot := PackedVector2Array()
		for a in range(9):
			var ang := (float(a) / 8.0) * TAU
			dot.append(Vector2(dx + cos(ang) * 1.5, dy + sin(ang) * 1.5))
		draw_colored_polygon(dot, dot_col[i])
	
	# Address bar pill
	var addr_pts := PackedVector2Array([
		Vector2(-w * 0.5 + 24.0, -h * 0.5 + 2.5),
		Vector2(w * 0.5 - 6.0, -h * 0.5 + 2.5),
		Vector2(w * 0.5 - 6.0, -h * 0.5 + bar_h - 2.5),
		Vector2(-w * 0.5 + 24.0, -h * 0.5 + bar_h - 2.5)
	])
	draw_colored_polygon(addr_pts, Color("#ffffff"))
	draw_ink_line(addr_pts, 1.0)
	
	# Web page content mock lines
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.4, 0.0), Vector2(w * 0.2, 0.0)]), 2.0)
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.4, 8.0), Vector2(w * 0.35, 8.0)]), 1.3)
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.4, 15.0), Vector2(w * 0.1, 15.0)]), 1.3)
