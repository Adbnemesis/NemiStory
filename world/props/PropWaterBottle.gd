class_name PropWaterBottle
extends "res://world/props/NemiProp.gd"

## Illustrated Water Bottle Prop
## Translucent reusable bottle with sports cap, water level, and measurement ticks.

func _init() -> void:
	prop_name = "water_bottle"
	current_state = "normal"

func _draw() -> void:
	var w := 14.0
	var h := 34.0
	
	# 1. Cap / spout
	var cap_pts := PackedVector2Array([
		Vector2(-4.0, -h * 0.5 - 6.0),
		Vector2(4.0, -h * 0.5 - 6.0),
		Vector2(4.0, -h * 0.5),
		Vector2(-4.0, -h * 0.5)
	])
	draw_illustrated_polygon(cap_pts, style.metal_dark, style.structural_width)
	
	# 2. Main bottle body
	var body_pts := PackedVector2Array([
		Vector2(-w * 0.45, -h * 0.5),
		Vector2(w * 0.45, -h * 0.5),
		Vector2(w * 0.50, -h * 0.45),
		Vector2(w * 0.48, h * 0.46),
		Vector2(w * 0.40, h * 0.50),
		Vector2(-w * 0.40, h * 0.50),
		Vector2(-w * 0.48, h * 0.46),
		Vector2(-w * 0.50, -h * 0.45)
	])
	draw_illustrated_polygon(body_pts, style.screen_glow, style.outer_contour_width)
	
	# 3. Water liquid fill (lower half)
	var water_pts := PackedVector2Array([
		Vector2(-w * 0.45, -h * 0.1),
		Vector2(w * 0.45, -h * 0.1),
		Vector2(w * 0.46, h * 0.44),
		Vector2(-w * 0.46, h * 0.44)
	])
	var water_col := Color(0.55, 0.78, 0.95, 0.45) if style.is_color() else Color(0.85, 0.85, 0.85, 0.40)
	draw_colored_polygon(water_pts, water_col)
	
	# 4. Measurement tick marks
	for i in range(3):
		var y := -h * 0.25 + float(i) * 7.0
		draw_ink_line(PackedVector2Array([Vector2(-w * 0.35, y), Vector2(-w * 0.18, y)]), 1.1)
