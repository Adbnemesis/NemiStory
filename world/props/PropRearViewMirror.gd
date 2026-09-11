class_name PropRearViewMirror
extends "res://world/props/NemiProp.gd"

## Illustrated Rear-View Mirror Prop
## Automobile interior mirror mounted on ceiling ball-joint arm with reflection glass.

func _init() -> void:
	prop_name = "rear_view_mirror"
	current_state = "normal"

func _draw() -> void:
	var w := 44.0
	var h := 18.0
	
	# Mounting bracket arm from top
	var arm_pts := PackedVector2Array([
		Vector2(-2.0, -h * 0.5 - 10.0),
		Vector2(2.0, -h * 0.5 - 10.0),
		Vector2(1.5, -h * 0.5),
		Vector2(-1.5, -h * 0.5)
	])
	draw_illustrated_polygon(arm_pts, style.metal_dark, style.structural_width)
	
	# Mirror casing (rounded trapezoid)
	var case_pts := PackedVector2Array([
		Vector2(-w * 0.5 + 4.0, -h * 0.5),
		Vector2(w * 0.5 - 4.0, -h * 0.5),
		Vector2(w * 0.5, h * 0.5),
		Vector2(-w * 0.5, h * 0.5)
	])
	draw_illustrated_polygon(case_pts, style.metal_dark, style.outer_contour_width)
	
	# Glass reflection pane
	var mirror_pts := PackedVector2Array([
		Vector2(-w * 0.5 + 6.0, -h * 0.5 + 2.5),
		Vector2(w * 0.5 - 6.0, -h * 0.5 + 2.5),
		Vector2(w * 0.5 - 2.5, h * 0.5 - 2.5),
		Vector2(-w * 0.5 + 2.5, h * 0.5 - 2.5)
	])
	draw_colored_polygon(mirror_pts, Color(0.85, 0.90, 0.94, 0.8))
	draw_ink_line(mirror_pts, style.detail_line_width)
	
	# Specular diagonal reflection glint
	draw_ink_line(PackedVector2Array([Vector2(-8.0, -5.0), Vector2(-16.0, 5.0)]), 1.4)
