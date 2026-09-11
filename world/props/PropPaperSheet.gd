class_name PropPaperSheet
extends "res://world/props/NemiProp.gd"

## Illustrated Single Sheet of Paper Prop
## Loose paper note with slightly curled dog-ear corner and masking tape on top.

func _init() -> void:
	prop_name = "paper_sheet"
	current_state = "normal"

func _draw() -> void:
	var w := 40.0
	var h := 52.0
	
	# Paper sheet with dog-eared top-right corner
	var dog_ear := 8.0
	var paper_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),
		Vector2(w * 0.5 - dog_ear, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5 + dog_ear),
		Vector2(w * 0.5, h * 0.5),
		Vector2(-w * 0.5, h * 0.5)
	])
	draw_illustrated_polygon(paper_pts, style.paper_bg_color, style.outer_contour_width)
	
	# Dog ear fold triangle
	var fold_pts := PackedVector2Array([
		Vector2(w * 0.5 - dog_ear, -h * 0.5),
		Vector2(w * 0.5 - dog_ear, -h * 0.5 + dog_ear),
		Vector2(w * 0.5, -h * 0.5 + dog_ear)
	])
	draw_illustrated_polygon(fold_pts, Color("#e6e1d8"), style.detail_line_width)
	
	# Masking tape tab at top center
	var tape_col := Color(0.92, 0.88, 0.76, 0.85)
	var tape_pts := PackedVector2Array([
		Vector2(-10.0, -h * 0.5 - 6.0),
		Vector2(10.0, -h * 0.5 - 5.0),
		Vector2(9.0, -h * 0.5 + 4.0),
		Vector2(-11.0, -h * 0.5 + 3.0)
	])
	draw_colored_polygon(tape_pts, tape_col)
	draw_ink_line(tape_pts, 1.2)
	
	# Scribbled notes on sheet
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.35, -10.0), Vector2(w * 0.25, -10.0)]), 1.3)
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.35, -2.0), Vector2(w * 0.3, -2.0)]), 1.3)
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.35, 6.0), Vector2(w * 0.15, 6.0)]), 1.3)
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.35, 14.0), Vector2(w * 0.35, 14.0)]), 1.3)
