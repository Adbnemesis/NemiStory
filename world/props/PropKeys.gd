class_name PropKeys
extends "res://world/props/NemiProp.gd"

## Illustrated Keyring Prop
## Metal ring with car fob, brass house key, and small decorative tag.

func _init() -> void:
	prop_name = "keys"
	current_state = "normal"

func _draw() -> void:
	# 1. Main Keyring Circle
	var ring_r := 7.0
	var ring_pts := PackedVector2Array()
	var steps := 12
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		ring_pts.append(Vector2(cos(ang) * ring_r, sin(ang) * ring_r))
	draw_ink_line(ring_pts, 1.8)
	
	# 2. Car Fob (black oval hanging down)
	var fob_col: Color = style.metal_dark
	var fob_pts := PackedVector2Array([
		Vector2(-4.0, 6.0),
		Vector2(4.0, 6.0),
		Vector2(6.0, 20.0),
		Vector2(-6.0, 20.0)
	])
	draw_illustrated_polygon(fob_pts, fob_col, style.structural_width)
	# Fob button accent
	draw_ink_line(PackedVector2Array([Vector2(-2.0, 11.0), Vector2(2.0, 11.0)]), 1.2)
	draw_ink_line(PackedVector2Array([Vector2(-2.0, 15.0), Vector2(2.0, 15.0)]), 1.2)
	
	# 3. Brass House Key (hanging angled to right)
	var key_col := Color("#d4a84f") if (not style or style.is_color()) else Color("#b8b6b0")
	var key_head := PackedVector2Array([
		Vector2(5.0, 5.0), Vector2(12.0, 2.0), Vector2(15.0, 8.0), Vector2(8.0, 11.0)
	])
	draw_illustrated_polygon(key_head, key_col, style.detail_line_width)
	var key_blade := PackedVector2Array([
		Vector2(11.0, 9.0), Vector2(20.0, 17.0), Vector2(18.0, 19.0), Vector2(9.0, 11.0)
	])
	draw_illustrated_polygon(key_blade, key_col, style.detail_line_width)
	# Teeth cuts on blade
	draw_ink_line(PackedVector2Array([Vector2(15.0, 12.0), Vector2(17.0, 11.0)]), 1.4)
	draw_ink_line(PackedVector2Array([Vector2(18.0, 15.0), Vector2(20.0, 14.0)]), 1.4)
