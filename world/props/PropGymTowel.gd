class_name PropGymTowel
extends "res://world/props/NemiProp.gd"

## Illustrated Gym Sweat Towel Prop
## Draped cotton towel with striped woven border.

func _init() -> void:
	prop_name = "gym_towel"
	current_state = "normal"

func _draw() -> void:
	var towel_col := Color("#d6e4db") if (not style or style.is_color()) else Color("#dedede")
	var stripe_col := Color("#536b5c")
	
	# Folded/draped cloth contour
	var cloth_pts := PackedVector2Array([
		Vector2(-16.0, -18.0),
		Vector2(16.0, -18.0),
		Vector2(18.0, 14.0),
		Vector2(14.0, 20.0),
		Vector2(-14.0, 22.0),
		Vector2(-18.0, 16.0)
	])
	draw_illustrated_polygon(cloth_pts, towel_col, style.outer_contour_width)
	
	# Woven bottom stripe
	var s_pts := PackedVector2Array([
		Vector2(-17.0, 10.0),
		Vector2(17.0, 10.0),
		Vector2(16.0, 14.0),
		Vector2(-16.0, 14.0)
	])
	draw_colored_polygon(s_pts, stripe_col)
	
	# Fabric fold creases
	draw_ink_line(PackedVector2Array([Vector2(-4.0, -16.0), Vector2(-6.0, 12.0)]), 1.3)
	draw_ink_line(PackedVector2Array([Vector2(6.0, -16.0), Vector2(8.0, 8.0)]), 1.3)
