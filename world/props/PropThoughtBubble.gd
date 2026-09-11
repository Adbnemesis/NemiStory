class_name PropThoughtBubble
extends "res://world/props/NemiProp.gd"

## Illustrated Comic Thought Bubble Prop
## Fluffy cloud-like thought bubble with trail of 3 floating circles toward character.

func _init() -> void:
	prop_name = "thought_bubble"
	current_state = "normal"

func _draw() -> void:
	var w := 56.0
	var h := 38.0
	
	# Cloud bubble composed of 6 overlapping circular lobes
	var lobe_centers := [
		Vector2(-w * 0.28, -h * 0.25),
		Vector2(0.0, -h * 0.35),
		Vector2(w * 0.28, -h * 0.25),
		Vector2(w * 0.32, h * 0.15),
		Vector2(0.0, h * 0.3),
		Vector2(-w * 0.32, h * 0.15)
	]
	var lobe_radii := [15.0, 17.0, 15.0, 16.0, 17.0, 15.0]
	
	# Fill base cloud
	for i in range(lobe_centers.size()):
		var c: Vector2 = lobe_centers[i]
		var r: float = lobe_radii[i]
		var pts := PackedVector2Array()
		for a in range(13):
			var ang := (float(a) / 12.0) * TAU
			pts.append(c + Vector2(cos(ang) * r, sin(ang) * r))
		draw_colored_polygon(pts, Color("#ffffff"))
		var strk := pts.duplicate()
		strk.append(pts[0])
		draw_ink_line(strk, style.structural_width)
	
	# Trailing thought dots toward speaker (bottom-left)
	var trail_pos := [Vector2(-w * 0.35, h * 0.5 + 8.0), Vector2(-w * 0.42, h * 0.5 + 16.0), Vector2(-w * 0.48, h * 0.5 + 23.0)]
	var trail_rad := [4.5, 3.0, 1.8]
	for i in range(3):
		var p: Vector2 = trail_pos[i]
		var r: float = trail_rad[i]
		var pts := PackedVector2Array()
		for a in range(9):
			var ang := (float(a) / 8.0) * TAU
			pts.append(p + Vector2(cos(ang) * r, sin(ang) * r))
		draw_illustrated_polygon(pts, Color("#ffffff"), style.detail_line_width)
