class_name PropPhone
extends "res://world/props/NemiProp.gd"

## Illustrated Smartphone Prop
## Hand-drawn smartphone with organic rounded contour, screen fill, and notification states.

func _init() -> void:
	prop_name = "phone"
	current_state = "normal"

func _draw() -> void:
	var w := 18.0
	var h := 32.0
	var r := 4.0
	
	# 1. Outer phone chassis (organic rounded rectangle)
	var body_pts := _create_rounded_rect(Vector2(-w * 0.5, -h * 0.5), Vector2(w, h), r)
	draw_illustrated_polygon(body_pts, style.metal_dark, style.outer_contour_width)
	
	# 2. Screen
	var sw := w - 4.0
	var sh := h - 7.0
	var screen_pts := _create_rounded_rect(Vector2(-sw * 0.5, -sh * 0.5 + 0.5), Vector2(sw, sh), 2.0)
	var screen_col: Color = style.screen_glow if (current_state != "screen_off" and current_state != "dropped") else style.screen_off
	draw_colored_polygon(screen_pts, screen_col)
	var screen_stroke_pts := screen_pts.duplicate()
	screen_stroke_pts.append(screen_pts[0])
	draw_ink_line(screen_stroke_pts, style.detail_line_width)
	
	# 3. Screen content (minimalist illustrated message bubbles if screen is on)
	if current_state != "screen_off" and current_state != "dropped":
		var bubble_col: Color = style.accent_blue
		var b1 := PackedVector2Array([Vector2(-sw * 0.35, -sh * 0.25), Vector2(sw * 0.1, -sh * 0.25), Vector2(sw * 0.1, -sh * 0.1), Vector2(-sw * 0.35, -sh * 0.1)])
		draw_colored_polygon(b1, bubble_col)
		var b2 := PackedVector2Array([Vector2(-sw * 0.1, 0.0), Vector2(sw * 0.35, 0.0), Vector2(sw * 0.35, sh * 0.15), Vector2(-sw * 0.1, sh * 0.15)])
		draw_colored_polygon(b2, style.accent_mint)
	
	# 4. Top speaker slot
	draw_ink_line(PackedVector2Array([Vector2(-3.0, -h * 0.5 + 2.5), Vector2(3.0, -h * 0.5 + 2.5)]), 1.2)
	
	# 5. Bottom home bar
	draw_ink_line(PackedVector2Array([Vector2(-4.0, h * 0.5 - 2.0), Vector2(4.0, h * 0.5 - 2.0)]), 1.2)

func _create_rounded_rect(pos: Vector2, size: Vector2, radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var steps := 4
	var corners := [
		Vector2(pos.x + size.x - radius, pos.y + radius),          # top-right
		Vector2(pos.x + size.x - radius, pos.y + size.y - radius), # bottom-right
		Vector2(pos.x + radius, pos.y + size.y - radius),          # bottom-left
		Vector2(pos.x + radius, pos.y + radius)                   # top-left
	]
	var angles := [0.0, PI * 0.5, PI, PI * 1.5]
	
	for c in range(4):
		var center: Vector2 = corners[c]
		var start_ang: float = angles[c]
		for i in range(steps + 1):
			var a := start_ang + (float(i) / float(steps)) * (PI * 0.5)
			# Tiny hand-drawn jitter for authentic illustration feel
			var jitter := sin(a * 4.0) * 0.2
			pts.append(center + Vector2(cos(a) * (radius + jitter), sin(a) * (radius + jitter)))
	return pts
