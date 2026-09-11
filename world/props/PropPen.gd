class_name PropPen
extends "res://world/props/NemiProp.gd"

## Illustrated Technical Fineliner Pen Prop
## Sleek black inking pen with cap clip and metallic nib.

func _init() -> void:
	prop_name = "pen"
	current_state = "normal"

func _draw() -> void:
	var l := 40.0
	var w := 4.5
	
	# Pen barrel (dark ink/slate)
	var barrel_col: Color = style.metal_dark
	var barrel_pts := PackedVector2Array([
		Vector2(-l * 0.5 + 12.0, -w * 0.5),
		Vector2(l * 0.5 - 6.0, -w * 0.45),
		Vector2(l * 0.5 - 6.0, w * 0.45),
		Vector2(-l * 0.5 + 12.0, w * 0.5)
	])
	draw_illustrated_polygon(barrel_pts, barrel_col, style.structural_width)
	
	# Pen Cap
	var cap_col: Color = Color("#2d2938")
	var cap_pts := PackedVector2Array([
		Vector2(-l * 0.5, -w * 0.55),
		Vector2(-l * 0.5 + 12.0, -w * 0.5),
		Vector2(-l * 0.5 + 12.0, w * 0.5),
		Vector2(-l * 0.5, w * 0.55)
	])
	draw_illustrated_polygon(cap_pts, cap_col, style.structural_width)
	
	# Clip on cap
	var clip_pts := PackedVector2Array([
		Vector2(-l * 0.5 + 2.0, -w * 0.55 - 2.0),
		Vector2(-l * 0.5 + 10.0, -w * 0.55 - 1.5),
		Vector2(-l * 0.5 + 10.0, -w * 0.55),
		Vector2(-l * 0.5 + 2.0, -w * 0.55)
	])
	draw_colored_polygon(clip_pts, Color("#c2c1c8"))
	draw_ink_line(clip_pts, 1.2)
	
	# Nib cone
	var nib_pts := PackedVector2Array([
		Vector2(l * 0.5 - 6.0, -w * 0.4),
		Vector2(l * 0.5, 0.0),
		Vector2(l * 0.5 - 6.0, w * 0.4)
	])
	draw_illustrated_polygon(nib_pts, Color("#d4d3da"), style.detail_line_width)
