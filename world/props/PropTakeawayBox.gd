class_name PropTakeawayBox
extends "res://world/props/NemiProp.gd"

## Illustrated Takeaway Noodle Box Prop
## Paper carton box with wire handle and folded flaps.

func _init() -> void:
	prop_name = "takeaway_box"
	current_state = "normal"

func _draw() -> void:
	var bw := 24.0
	var tw := 32.0
	var h := 32.0
	
	# Carton body trapezoid
	var box_pts := PackedVector2Array([
		Vector2(-tw * 0.5, -h * 0.5),
		Vector2(tw * 0.5, -h * 0.5),
		Vector2(bw * 0.5, h * 0.5),
		Vector2(-bw * 0.5, h * 0.5)
	])
	draw_illustrated_polygon(box_pts, style.paper_bg_color, style.outer_contour_width)
	
	# Folded top flaps
	var flap_left := PackedVector2Array([
		Vector2(-tw * 0.5, -h * 0.5),
		Vector2(-tw * 0.2, -h * 0.5 - 6.0),
		Vector2(0.0, -h * 0.5)
	])
	draw_illustrated_polygon(flap_left, Color("#ece7dc"), style.detail_line_width)
	var flap_right := PackedVector2Array([
		Vector2(0.0, -h * 0.5),
		Vector2(tw * 0.2, -h * 0.5 - 6.0),
		Vector2(tw * 0.5, -h * 0.5)
	])
	draw_illustrated_polygon(flap_right, Color("#ece7dc"), style.detail_line_width)
	
	# Wire carry handle arch
	var wire_pts := PackedVector2Array([
		Vector2(-tw * 0.35, -h * 0.5 + 4.0),
		Vector2(-tw * 0.35, -h * 0.5 - 14.0),
		Vector2(tw * 0.35, -h * 0.5 - 14.0),
		Vector2(tw * 0.35, -h * 0.5 + 4.0)
	])
	draw_ink_line(wire_pts, 1.6)
	
	# Red pagoda / stamp accent on front
	var stamp_pts := PackedVector2Array([
		Vector2(-4.0, 0.0), Vector2(4.0, 0.0), Vector2(4.0, 8.0), Vector2(-4.0, 8.0)
	])
	draw_colored_polygon(stamp_pts, Color("#c94a4a"))
