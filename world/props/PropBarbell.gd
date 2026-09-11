class_name PropBarbell
extends "res://world/props/NemiProp.gd"

## Illustrated Olympic Barbell Prop
## Full width iron barbell loaded with standard 20kg plates and spinlock collars.

func _init() -> void:
	prop_name = "barbell"
	current_state = "normal"

func _draw() -> void:
	var l := 110.0
	var bar_col := Color("#9a9fa8")
	var plate_col := Color("#2a2830")
	
	# Long steel bar
	var bar_pts := PackedVector2Array([
		Vector2(-l * 0.5, -2.5),
		Vector2(l * 0.5, -2.5),
		Vector2(l * 0.5, 2.5),
		Vector2(-l * 0.5, 2.5)
	])
	draw_illustrated_polygon(bar_pts, bar_col, style.structural_width)
	
	# Left outer plate
	var lp1 := PackedVector2Array([
		Vector2(-l * 0.5 + 4.0, -26.0), Vector2(-l * 0.5 + 10.0, -26.0),
		Vector2(-l * 0.5 + 10.0, 26.0), Vector2(-l * 0.5 + 4.0, 26.0)
	])
	draw_illustrated_polygon(lp1, plate_col, style.outer_contour_width)
	
	# Left inner plate
	var lp2 := PackedVector2Array([
		Vector2(-l * 0.5 + 11.0, -24.0), Vector2(-l * 0.5 + 17.0, -24.0),
		Vector2(-l * 0.5 + 17.0, 24.0), Vector2(-l * 0.5 + 11.0, 24.0)
	])
	draw_illustrated_polygon(lp2, plate_col * 1.1, style.outer_contour_width)
	
	# Right inner plate
	var rp2 := PackedVector2Array([
		Vector2(l * 0.5 - 17.0, -24.0), Vector2(l * 0.5 - 11.0, -24.0),
		Vector2(l * 0.5 - 11.0, 24.0), Vector2(l * 0.5 - 17.0, 24.0)
	])
	draw_illustrated_polygon(rp2, plate_col * 1.1, style.outer_contour_width)
	
	# Right outer plate
	var rp1 := PackedVector2Array([
		Vector2(l * 0.5 - 10.0, -26.0), Vector2(l * 0.5 - 4.0, -26.0),
		Vector2(l * 0.5 - 4.0, 26.0), Vector2(l * 0.5 - 10.0, 26.0)
	])
	draw_illustrated_polygon(rp1, plate_col, style.outer_contour_width)
