class_name PropBackpack
extends "res://world/props/NemiProp.gd"

## Illustrated Backpack Prop
## Hand-drawn school bag with rounded dome silhouette, front zipper pocket, and handle.

func _init() -> void:
	prop_name = "backpack"
	current_state = "normal"

func _draw() -> void:
	var w := 36.0
	var h := 44.0
	
	# Top grab handle
	var handle_pts := PackedVector2Array([
		Vector2(-6.0, -h * 0.5),
		Vector2(-6.0, -h * 0.5 - 7.0),
		Vector2(6.0, -h * 0.5 - 7.0),
		Vector2(6.0, -h * 0.5)
	])
	draw_ink_line(handle_pts, style.structural_width)
	
	# Main bag body
	var body_pts := PackedVector2Array([
		Vector2(-w * 0.35, -h * 0.5),          # top-left curve
		Vector2(w * 0.35, -h * 0.5),           # top-right curve
		Vector2(w * 0.50, -h * 0.1),
		Vector2(w * 0.48, h * 0.45),           # bottom-right
		Vector2(w * 0.38, h * 0.5),
		Vector2(-w * 0.38, h * 0.5),
		Vector2(-w * 0.48, h * 0.45),          # bottom-left
		Vector2(-w * 0.50, -h * 0.1)
	])
	draw_illustrated_polygon(body_pts, style.accent_blue, style.outer_contour_width)
	
	# Main zipper arc line
	draw_ink_line(PackedVector2Array([
		Vector2(-w * 0.42, -h * 0.15),
		Vector2(0.0, -h * 0.38),
		Vector2(w * 0.42, -h * 0.15)
	]), style.inner_line_width)
	
	# Front pocket
	var pocket_pts := PackedVector2Array([
		Vector2(-w * 0.38, 0.0),
		Vector2(w * 0.38, 0.0),
		Vector2(w * 0.38, h * 0.38),
		Vector2(-w * 0.38, h * 0.38)
	])
	draw_illustrated_polygon(pocket_pts, style.metal_dark, style.structural_width)
	# Pocket zipper line
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.32, 5.0), Vector2(w * 0.32, 5.0)]), style.detail_line_width)
