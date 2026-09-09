class_name PropDesk
extends "res://world/props/NemiProp.gd"

## Illustrated Workspace Desk Prop
## Minimalist wooden tabletop surface in slight 2.5D perspective with tapered legs.

func _init() -> void:
	prop_name = "desk"
	current_state = "normal"

func _draw() -> void:
	var top_w := 140.0
	var top_d := 24.0
	var leg_h := 80.0
	var thickness := 8.0
	
	# 1. Back legs
	var leg_col: Color = style.wood_dark
	draw_illustrated_polygon(PackedVector2Array([
		Vector2(-top_w * 0.44, 0.0),
		Vector2(-top_w * 0.40, 0.0),
		Vector2(-top_w * 0.41, leg_h - 10.0),
		Vector2(-top_w * 0.45, leg_h - 10.0)
	]), leg_col, style.structural_width)
	
	draw_illustrated_polygon(PackedVector2Array([
		Vector2(top_w * 0.40, 0.0),
		Vector2(top_w * 0.44, 0.0),
		Vector2(top_w * 0.45, leg_h - 10.0),
		Vector2(top_w * 0.41, leg_h - 10.0)
	]), leg_col, style.structural_width)
	
	# 2. Front legs
	draw_illustrated_polygon(PackedVector2Array([
		Vector2(-top_w * 0.48, thickness),
		Vector2(-top_w * 0.44, thickness),
		Vector2(-top_w * 0.46, leg_h),
		Vector2(-top_w * 0.50, leg_h)
	]), style.wood_shadow, style.structural_width)
	
	draw_illustrated_polygon(PackedVector2Array([
		Vector2(top_w * 0.44, thickness),
		Vector2(top_w * 0.48, thickness),
		Vector2(top_w * 0.50, leg_h),
		Vector2(top_w * 0.46, leg_h)
	]), style.wood_shadow, style.structural_width)
	
	# 3. Tabletop edge bevel
	var edge_pts := PackedVector2Array([
		Vector2(-top_w * 0.50, 0.0),
		Vector2(top_w * 0.50, 0.0),
		Vector2(top_w * 0.50, thickness),
		Vector2(-top_w * 0.50, thickness)
	])
	draw_illustrated_polygon(edge_pts, style.wood_shadow, style.structural_width)
	
	# 4. Tabletop top surface (slight perspective slant)
	var top_surface_pts := PackedVector2Array([
		Vector2(-top_w * 0.46, -top_d),
		Vector2(top_w * 0.46, -top_d),
		Vector2(top_w * 0.50, 0.0),
		Vector2(-top_w * 0.50, 0.0)
	])
	draw_illustrated_polygon(top_surface_pts, style.wood_surface, style.outer_contour_width)
	
	# 5. Hand-drawn wood plank line
	draw_ink_line(PackedVector2Array([
		Vector2(-top_w * 0.48, -top_d * 0.45),
		Vector2(top_w * 0.48, -top_d * 0.45)
	]), style.detail_line_width)
