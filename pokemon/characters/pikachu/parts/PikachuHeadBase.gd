class_name PikachuHeadBase
extends Node2D

## Illustrated Head Base for PIKACHU
## Constructs the soft rounded head silhouette seamlessly blending into the chubby cheeks.

const PikachuStyle = preload("res://pokemon/characters/pikachu/PikachuStyle.gd")

var style: PikachuStyle

func _draw() -> void:
	if not style:
		return
	
	# Head shape: rounded, slightly wider across lower cheeks
	var head_c := Curve2D.new()
	var rx := 31.0
	var ry := 28.0
	head_c.add_point(Vector2(0, -ry), Vector2(-rx * 0.7, 0), Vector2(rx * 0.7, 0))
	head_c.add_point(Vector2(rx, -2), Vector2(0, -ry * 0.6), Vector2(0, ry * 0.4))
	head_c.add_point(Vector2(rx * 0.9, ry * 0.7), Vector2(4, -6), Vector2(-4, 6))
	head_c.add_point(Vector2(0, ry), Vector2(rx * 0.6, 0), Vector2(-rx * 0.6, 0))
	head_c.add_point(Vector2(-rx * 0.9, ry * 0.7), Vector2(4, 6), Vector2(-4, -6))
	head_c.add_point(Vector2(-rx, -2), Vector2(0, ry * 0.4), Vector2(0, -ry * 0.6))
	head_c.add_point(Vector2(0, -ry), Vector2(-rx * 0.7, 0), Vector2(0, 0))
	
	var head_pts := head_c.tessellate(4, 2.0)
	draw_colored_polygon(head_pts, style.fur_base_color)
	draw_polyline(head_pts, style.ink_color, style.outer_contour_width, true)
