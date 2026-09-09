class_name PropSnackPacket
extends "res://world/props/NemiProp.gd"

## Illustrated Snack Packet / Chips Bag Prop
## Crinkled hand-drawn snack packet with crimped edges and flavor badge.

func _init() -> void:
	prop_name = "snack_packet"
	current_state = "normal"

func _draw() -> void:
	var w := 28.0
	var h := 36.0
	
	# Crinkled jagged silhouette
	var body_pts := PackedVector2Array([
		Vector2(-w * 0.46, -h * 0.5),          # top crimp
		Vector2(-w * 0.20, -h * 0.52),
		Vector2(0.0, -h * 0.49),
		Vector2(w * 0.25, -h * 0.52),
		Vector2(w * 0.48, -h * 0.50),
		Vector2(w * 0.52, -h * 0.1),           # right puffed side
		Vector2(w * 0.48, h * 0.50),           # bottom crimp
		Vector2(w * 0.22, h * 0.52),
		Vector2(0.0, h * 0.49),
		Vector2(-w * 0.24, h * 0.52),
		Vector2(-w * 0.48, h * 0.50),
		Vector2(-w * 0.52, -h * 0.1)           # left puffed side
	])
	draw_illustrated_polygon(body_pts, style.accent_yellow, style.outer_contour_width)
	
	# Top and bottom crimp seal lines
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.44, -h * 0.42), Vector2(w * 0.44, -h * 0.42)]), style.inner_line_width)
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.44, h * 0.42), Vector2(w * 0.44, h * 0.42)]), style.inner_line_width)
	
	# Center decorative flavor star / badge
	var badge_col: Color = style.accent_rose
	var badge_pts := PackedVector2Array([
		Vector2(-8.0, -4.0),
		Vector2(8.0, -4.0),
		Vector2(6.0, 8.0),
		Vector2(-6.0, 8.0)
	])
	draw_colored_polygon(badge_pts, badge_col)
	var badge_stroke := badge_pts.duplicate(); badge_stroke.append(badge_pts[0])
	draw_ink_line(badge_stroke, style.detail_line_width)
