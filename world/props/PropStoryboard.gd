class_name PropStoryboard
extends "res://world/props/NemiProp.gd"

## Illustrated Animation Storyboard Prop
## 3-panel horizontal animation storyboard strip with aspect ratio frames and dialogue lines.

func _init() -> void:
	prop_name = "storyboard"
	current_state = "normal"

func _draw() -> void:
	var w := 72.0
	var h := 36.0
	
	# Backing card
	var back_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.5, h * 0.5),
		Vector2(-w * 0.5, h * 0.5)
	])
	draw_illustrated_polygon(back_pts, style.paper_bg_color, style.outer_contour_width)
	
	# 3 storyboard shot boxes
	var box_w := 18.0
	var box_h := 13.0
	var spacing := 22.0
	for i in range(3):
		var bx := -spacing + float(i) * spacing
		var b_pts := PackedVector2Array([
			Vector2(bx - box_w * 0.5, -h * 0.5 + 4.0),
			Vector2(bx + box_w * 0.5, -h * 0.5 + 4.0),
			Vector2(bx + box_w * 0.5, -h * 0.5 + 4.0 + box_h),
			Vector2(bx - box_w * 0.5, -h * 0.5 + 4.0 + box_h)
		])
		draw_illustrated_polygon(b_pts, Color("#ffffff"), style.structural_width)
		
		# Thumbnail stick figures in each shot
		if i == 0:
			draw_ink_line(PackedVector2Array([Vector2(bx, -9.0), Vector2(bx, -4.0)]), 1.3)
		elif i == 1:
			draw_ink_line(PackedVector2Array([Vector2(bx - 3.0, -9.0), Vector2(bx + 3.0, -4.0)]), 1.3)
		else:
			draw_ink_line(PackedVector2Array([Vector2(bx, -6.0), Vector2(bx + 4.0, -10.0)]), 1.3)
			
		# Dialogue lines beneath each panel
		draw_ink_line(PackedVector2Array([Vector2(bx - 8.0, 7.0), Vector2(bx + 8.0, 7.0)]), 1.1)
		draw_ink_line(PackedVector2Array([Vector2(bx - 6.0, 11.0), Vector2(bx + 4.0, 11.0)]), 1.1)
