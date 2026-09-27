class_name PropMicrophone
extends "res://nemi/world/props/NemiProp.gd"

## Illustrated Studio Condenser Microphone Prop
## Hand-drawn studio microphone on a stand with shock mount and pop filter.

func _init() -> void:
	prop_name = "microphone"
	current_state = "recording"

func _draw() -> void:
	# 1. Base Stand Pole (extends down to floor)
	var pole_col: Color = style.metal_dark
	draw_illustrated_polygon(PackedVector2Array([
		Vector2(-3.0, 10.0),
		Vector2(3.0, 10.0),
		Vector2(3.0, 140.0),
		Vector2(-3.0, 140.0)
	]), pole_col, style.structural_width)

	# Stand base tripod / round foot
	draw_illustrated_polygon(PackedVector2Array([
		Vector2(-32.0, 140.0),
		Vector2(32.0, 140.0),
		Vector2(28.0, 146.0),
		Vector2(-28.0, 146.0)
	]), pole_col, style.structural_width)

	# 2. Shock Mount Ring
	var ring_pts := PackedVector2Array()
	var r := 20.0
	for i in range(16):
		var th := float(i) * TAU / 15.0
		ring_pts.append(Vector2(cos(th) * r, sin(th) * (r * 0.5) - 10.0))
	draw_ink_line(ring_pts, style.structural_width)

	# Elastic bands in shock mount
	draw_ink_line(PackedVector2Array([Vector2(-14.0, -10.0), Vector2(-6.0, -20.0)]), style.detail_line_width)
	draw_ink_line(PackedVector2Array([Vector2(14.0, -10.0), Vector2(6.0, -20.0)]), style.detail_line_width)

	# 3. Mic Body (Lower Capsule)
	var body_w := 18.0
	var body_h := 24.0
	var body_pts := PackedVector2Array([
		Vector2(-body_w * 0.5, -20.0),
		Vector2(body_w * 0.5, -20.0),
		Vector2(body_w * 0.5, -20.0 + body_h),
		Vector2(-body_w * 0.5, -20.0 + body_h)
	])
	draw_illustrated_polygon(body_pts, Color("#26232e"), style.structural_width)

	# 4. Mic Grille (Upper Dome)
	var grille_w := 18.0
	var grille_h := 26.0
	var grille_pts := PackedVector2Array([
		Vector2(-grille_w * 0.5, -20.0),
		Vector2(-grille_w * 0.5, -20.0 - grille_h * 0.6),
		Vector2(0.0, -20.0 - grille_h),
		Vector2(grille_w * 0.5, -20.0 - grille_h * 0.6),
		Vector2(grille_w * 0.5, -20.0)
	])
	var grille_col: Color = Color("#d8d0c5") if current_state != "recording" else Color("#e0d4cc")
	draw_illustrated_polygon(grille_pts, grille_col, style.structural_width)

	# Grille mesh cross-hatching
	for y_off in [-26.0, -32.0, -38.0]:
		draw_ink_line(PackedVector2Array([
			Vector2(-grille_w * 0.4, y_off),
			Vector2(grille_w * 0.4, y_off)
		]), style.detail_line_width)

	# 5. Pop Filter Hoop (in front)
	var pop_center := Vector2(-16.0, -28.0)
	var pop_r := 16.0
	var pop_circle := PackedVector2Array()
	for i in range(16):
		var th := float(i) * TAU / 15.0
		pop_circle.append(pop_center + Vector2(cos(th) * pop_r * 0.4, sin(th) * pop_r))
	draw_illustrated_polygon(pop_circle, Color(0.1, 0.1, 0.15, 0.35), style.structural_width)

	# Gooseneck arm to shock mount
	draw_ink_line(PackedVector2Array([
		pop_center + Vector2(0.0, pop_r),
		pop_center + Vector2(4.0, pop_r + 12.0),
		Vector2(0.0, 5.0)
	]), style.structural_width)

