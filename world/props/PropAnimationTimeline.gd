class_name PropAnimationTimeline
extends "res://world/props/NemiProp.gd"

## Illustrated Animation Timeline Prop
## Stylized digital timeline ruler with frame tick marks, keyframe diamonds, and playhead.

func _init() -> void:
	prop_name = "animation_timeline"
	current_state = "normal"

func _draw() -> void:
	var w := 80.0
	var h := 22.0
	
	# Dark timeline panel
	var panel_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5),
		Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.5, h * 0.5),
		Vector2(-w * 0.5, h * 0.5)
	])
	draw_illustrated_polygon(panel_pts, Color("#26242e"), style.outer_contour_width)
	
	# Frame ruler ticks
	var num_ticks := 16
	for i in range(num_ticks):
		var tx := -w * 0.5 + 6.0 + float(i) * 4.5
		var th := 5.0 if (i % 4 == 0) else 2.5
		draw_ink_line(PackedVector2Array([Vector2(tx, -h * 0.5 + 2.0), Vector2(tx, -h * 0.5 + 2.0 + th)]), 1.1)
	
	# Track row separator
	draw_ink_line(PackedVector2Array([Vector2(-w * 0.5 + 4.0, 1.0), Vector2(w * 0.5 - 4.0, 1.0)]), 1.2)
	
	# Keyframe diamonds on track
	var key_x := [-24.0, -8.0, 8.0, 24.0]
	for kx in key_x:
		var diamond := PackedVector2Array([
			Vector2(kx, 3.0),
			Vector2(kx + 2.5, 5.5),
			Vector2(kx, 8.0),
			Vector2(kx - 2.5, 5.5)
		])
		draw_colored_polygon(diamond, Color("#f0c05a"))
		draw_ink_line(diamond, 1.0)
	
	# Blue playhead line and indicator
	var px := 4.0
	draw_ink_line(PackedVector2Array([Vector2(px, -h * 0.5 + 2.0), Vector2(px, h * 0.5 - 2.0)]), 1.8)
	var marker := PackedVector2Array([
		Vector2(px - 3.0, -h * 0.5 + 2.0),
		Vector2(px + 3.0, -h * 0.5 + 2.0),
		Vector2(px, -h * 0.5 + 6.0)
	])
	draw_colored_polygon(marker, Color("#4da6ff"))
