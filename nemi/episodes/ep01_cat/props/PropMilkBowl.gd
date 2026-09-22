class_name PropMilkBowl
extends "res://nemi/world/props/NemiProp.gd"

## Illustrated Milk Bowl Prop
## Shallow ceramic saucer with warm white milk fill and ripple details.

func _init() -> void:
	prop_name = "milk_bowl"
	current_state = "normal"

func _draw() -> void:
	var w := 38.0
	var h := 16.0
	
	# Contact shadow
	_draw_shadow_ellipse(Vector2(0, h * 0.5 + 2), w * 0.52, 5.0, Color(0.17, 0.15, 0.14, 0.12))
	
	# Ceramic saucer base (curved half-ellipse)
	var body_pts := PackedVector2Array([
		Vector2(-w * 0.5, -2.0),
		Vector2(-w * 0.45, h * 0.5),
		Vector2(-w * 0.25, h),
		Vector2(w * 0.25, h),
		Vector2(w * 0.45, h * 0.5),
		Vector2(w * 0.5, -2.0)
	])
	draw_illustrated_polygon(body_pts, Color("#eddcc6"), 2.2)
	
	# Rim opening (ellipse)
	var rim_pts := PackedVector2Array()
	var steps := 20
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		rim_pts.append(Vector2(cos(ang) * (w * 0.5), sin(ang) * 5.0 - 2.0))
	draw_illustrated_polygon(rim_pts, Color("#fbf8f3"), 1.8)
	
	# Milk liquid surface (warm cream white)
	var milk_pts := PackedVector2Array()
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		milk_pts.append(Vector2(cos(ang) * (w * 0.44), sin(ang) * 4.0 - 1.5))
	draw_colored_polygon(milk_pts, Color("#ffffff"))
	
	# Subtle surface concentric ripple
	draw_arc(Vector2(0, -1.5), w * 0.22, 0, TAU, 16, Color("#dcd2c4"), 1.2)
	
	# Steam wisps
	var s1 := PackedVector2Array([Vector2(-4.0, -7.0), Vector2(-2.0, -14.0), Vector2(-4.0, -20.0)])
	var s2 := PackedVector2Array([Vector2(5.0, -6.0), Vector2(7.0, -13.0), Vector2(4.0, -21.0)])
	draw_ink_line(s1, 1.2)
	draw_ink_line(s2, 1.2)

func _draw_shadow_ellipse(pos: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var count := 18
	for i in range(count):
		var th := (float(i) / float(count)) * TAU
		pts.append(pos + Vector2(cos(th) * rx, sin(th) * ry))
	draw_colored_polygon(pts, col)
