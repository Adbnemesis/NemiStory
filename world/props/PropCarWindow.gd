class_name PropCarWindow
extends "res://world/props/NemiProp.gd"

## Illustrated Car Window Frame Prop
## Driver's side window outline with tinted glass wash and white specular reflection shine lines.

func _init() -> void:
	prop_name = "car_window"
	current_state = "normal"

func _draw() -> void:
	var w := 70.0
	var h := 50.0
	
	# Window rubber seal frame
	var frame_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5 + 8.0),
		Vector2(w * 0.5 - 14.0, -h * 0.5),
		Vector2(w * 0.5, h * 0.5),
		Vector2(-w * 0.5, h * 0.5)
	])
	draw_illustrated_polygon(frame_pts, Color("#302d38"), style.outer_contour_width)
	
	# Glass pane (subtle sky blue tint)
	var glass_col := Color(0.78, 0.88, 0.94, 0.45)
	var inner_pts := PackedVector2Array([
		Vector2(-w * 0.5 + 4.0, -h * 0.5 + 11.0),
		Vector2(w * 0.5 - 16.0, -h * 0.5 + 4.0),
		Vector2(w * 0.5 - 4.0, h * 0.5 - 4.0),
		Vector2(-w * 0.5 + 4.0, h * 0.5 - 4.0)
	])
	draw_colored_polygon(inner_pts, glass_col)
	draw_ink_line(inner_pts, style.structural_width)
	
	# Specular glass reflection streaks (diagonal white stripes)
	var shine_pts1 := PackedVector2Array([
		Vector2(-12.0, -18.0), Vector2(-22.0, 15.0)
	])
	draw_ink_line(shine_pts1, 2.5)
	var shine_pts2 := PackedVector2Array([
		Vector2(-4.0, -16.0), Vector2(-14.0, 17.0)
	])
	draw_ink_line(shine_pts2, 1.5)
