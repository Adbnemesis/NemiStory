class_name PropChair
extends "res://world/props/NemiProp.gd"

## Illustrated Desk Chair Prop
## Simple hand-drawn chair with contoured seat cushion, backrest, and legs.

func _init() -> void:
	prop_name = "chair"
	current_state = "normal"

func _draw() -> void:
	var seat_w := 42.0
	var seat_h := 8.0
	var leg_h := 50.0
	var back_h := 36.0
	
	# 1. Backrest poles
	draw_ink_line(PackedVector2Array([Vector2(-seat_w * 0.35, 0.0), Vector2(-seat_w * 0.35, -back_h)]), style.structural_width)
	draw_ink_line(PackedVector2Array([Vector2(seat_w * 0.35, 0.0), Vector2(seat_w * 0.35, -back_h)]), style.structural_width)
	
	# 2. Backrest cushion
	var back_pts := PackedVector2Array([
		Vector2(-seat_w * 0.42, -back_h),
		Vector2(seat_w * 0.42, -back_h),
		Vector2(seat_w * 0.40, -back_h + 16.0),
		Vector2(-seat_w * 0.40, -back_h + 16.0)
	])
	draw_illustrated_polygon(back_pts, style.accent_mint, style.outer_contour_width)
	
	# 3. Chair legs
	draw_ink_line(PackedVector2Array([Vector2(-seat_w * 0.40, seat_h), Vector2(-seat_w * 0.45, leg_h)]), style.structural_width)
	draw_ink_line(PackedVector2Array([Vector2(seat_w * 0.40, seat_h), Vector2(seat_w * 0.45, leg_h)]), style.structural_width)
	draw_ink_line(PackedVector2Array([Vector2(-seat_w * 0.25, seat_h * 0.5), Vector2(-seat_w * 0.28, leg_h - 6.0)]), style.inner_line_width)
	draw_ink_line(PackedVector2Array([Vector2(seat_w * 0.25, seat_h * 0.5), Vector2(seat_w * 0.28, leg_h - 6.0)]), style.inner_line_width)
	
	# 4. Seat cushion
	var seat_pts := PackedVector2Array([
		Vector2(-seat_w * 0.50, 0.0),
		Vector2(seat_w * 0.50, 0.0),
		Vector2(seat_w * 0.48, seat_h),
		Vector2(-seat_w * 0.48, seat_h)
	])
	draw_illustrated_polygon(seat_pts, style.accent_mint_shadow, style.outer_contour_width)
