class_name PropLamp
extends "res://world/props/NemiProp.gd"

## Illustrated Desk Lamp Prop
## Features circular base, articulated neck armature, lamp shade,
## and optional translucent ambient light cone.

@export var light_on: bool = true

func _init() -> void:
	prop_name = "lamp"
	current_state = "normal"

func _draw() -> void:
	var base_w := 24.0
	
	# 1. Base plate
	var base_pts := PackedVector2Array([
		Vector2(-base_w * 0.5, 0.0),
		Vector2(base_w * 0.5, 0.0),
		Vector2(base_w * 0.45, 6.0),
		Vector2(-base_w * 0.45, 6.0)
	])
	draw_illustrated_polygon(base_pts, style.metal_dark, style.outer_contour_width)
	
	# 2. Articulated arm (two angled segments with pivot elbow)
	var p_base := Vector2(0.0, 0.0)
	var p_elbow := Vector2(-8.0, -32.0)
	var p_head := Vector2(10.0, -56.0)
	
	draw_ink_line(PackedVector2Array([p_base, p_elbow]), style.structural_width)
	draw_ink_line(PackedVector2Array([p_elbow, p_head]), style.structural_width)
	# Pivot joints
	draw_circle(p_elbow, 2.2, style.ink_line_color)
	draw_circle(p_head, 2.2, style.ink_line_color)
	
	# 3. Conical lamp shade
	var shade_pts := PackedVector2Array([
		p_head + Vector2(-4.0, -4.0),
		p_head + Vector2(6.0, -8.0),
		p_head + Vector2(18.0, 4.0),
		p_head + Vector2(4.0, 10.0)
	])
	draw_illustrated_polygon(shade_pts, style.accent_yellow, style.outer_contour_width)
	
	# 4. Translucent warm light cone
	if light_on and current_state != "off":
		var cone_col := Color(0.98, 0.92, 0.65, 0.18) if style.is_color() else Color(1.0, 1.0, 1.0, 0.14)
		var cone_pts := PackedVector2Array([
			p_head + Vector2(11.0, 7.0),
			p_head + Vector2(70.0, 60.0),
			p_head + Vector2(-15.0, 60.0)
		])
		draw_colored_polygon(cone_pts, cone_col)
