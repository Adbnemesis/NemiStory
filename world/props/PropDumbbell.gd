extends "res://world/props/NemiProp.gd"

## Illustrated 15kg Gym Dumbbell Prop
## Hexagonal iron gym dumbbell with knurled grip bar.

func _init() -> void:
	prop_name = "dumbbell"
	current_state = "normal"

func _draw() -> void:
	var plate_col := Color("#2e2a36") if (not style or style.is_color()) else Color("#222222")
	var bar_col := Color("#8e929a") if (not style or style.is_color()) else Color("#aaaaaa")
	
	# Center knurled bar
	var bar_pts := PackedVector2Array([
		Vector2(-24.0, -3.0),
		Vector2(24.0, -3.0),
		Vector2(24.0, 3.0),
		Vector2(-24.0, 3.0)
	])
	draw_illustrated_polygon(bar_pts, bar_col, style.structural_width)
	
	# Left hexagonal plate
	var lp := PackedVector2Array([
		Vector2(-32.0, -16.0),
		Vector2(-24.0, -16.0),
		Vector2(-20.0, 0.0),
		Vector2(-24.0, 16.0),
		Vector2(-32.0, 16.0),
		Vector2(-36.0, 0.0)
	])
	draw_illustrated_polygon(lp, plate_col, style.outer_contour_width)
	
	# Right hexagonal plate
	var rp := PackedVector2Array([
		Vector2(24.0, -16.0),
		Vector2(32.0, -16.0),
		Vector2(36.0, 0.0),
		Vector2(32.0, 16.0),
		Vector2(24.0, 16.0),
		Vector2(20.0, 0.0)
	])
	draw_illustrated_polygon(rp, plate_col, style.outer_contour_width)
	
	# Weight text indication "15KG"
	draw_ink_line(PackedVector2Array([Vector2(-30.0, -4.0), Vector2(-26.0, -4.0)]), 1.3)
	draw_ink_line(PackedVector2Array([Vector2(26.0, -4.0), Vector2(30.0, -4.0)]), 1.3)
