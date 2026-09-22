class_name PropCardboardBox
extends "res://nemi/world/props/NemiProp.gd"

## Illustrated Damp Cardboard Box Prop
## Hand-drawn box with open flaps and subtle corrugated texture.
## Features a layered FrontFace node (z_index = 1) so Neeko sits physically inside the box.

var is_damp: bool = true
var front_node: Node2D

func _init() -> void:
	prop_name = "cardboard_box"
	current_state = "normal"

func _ready() -> void:
	super._ready()
	front_node = CardboardFront.new()
	front_node.name = "FrontFace"
	front_node.z_index = 1
	(front_node as CardboardFront).box = self
	add_child(front_node)

func _draw() -> void:
	var w := 70.0
	var h := 45.0
	
	# Ground shadow
	_draw_shadow_ellipse(Vector2(0, h * 0.5 + 4), w * 0.55, 8.0, Color(0.17, 0.15, 0.14, 0.12))
	
	# Box interior / back depth
	var interior_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.2),
		Vector2(w * 0.5, -h * 0.2),
		Vector2(w * 0.42, -h * 0.5),
		Vector2(-w * 0.42, -h * 0.5)
	])
	var dark_interior := Color("#876442")
	draw_illustrated_polygon(interior_pts, dark_interior, 2.0)
	
	# Back top flap
	var back_flap := PackedVector2Array([
		Vector2(-w * 0.42, -h * 0.5),
		Vector2(w * 0.42, -h * 0.5),
		Vector2(w * 0.38, -h * 0.72),
		Vector2(-w * 0.38, -h * 0.72)
	])
	draw_illustrated_polygon(back_flap, Color("#9e784e"), 1.8)

func _draw_shadow_ellipse(pos: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var count := 20
	for i in range(count):
		var th := (float(i) / float(count)) * TAU
		pts.append(pos + Vector2(cos(th) * rx, sin(th) * ry))
	draw_colored_polygon(pts, col)

class CardboardFront extends Node2D:
	var box: PropCardboardBox
	
	func _draw() -> void:
		if not box: return
		var w := 70.0
		var h := 45.0
		var ink_col: Color = box.style.ink_line_color if (box.style and "ink_line_color" in box.style) else Color("#232026")
		
		# Box main front face
		var front_pts := PackedVector2Array([
			Vector2(-w * 0.5, -h * 0.2),
			Vector2(w * 0.5, -h * 0.2),
			Vector2(w * 0.45, h * 0.5),
			Vector2(-w * 0.45, h * 0.5)
		])
		var box_brown := Color("#c49a6c")
		draw_colored_polygon(front_pts, box_brown)
		var f_stroke := InkStroke.from_points(front_pts + PackedVector2Array([front_pts[0]]), 2.4, InkStroke.Profile.UNIFORM, ink_col)
		f_stroke.draw_to(self)
		
		# Left flap folded outward
		var flap_l := PackedVector2Array([
			Vector2(-w * 0.5, -h * 0.2),
			Vector2(-w * 0.7, -h * 0.4),
			Vector2(-w * 0.5, -h * 0.45),
			Vector2(-w * 0.42, -h * 0.5)
		])
		draw_colored_polygon(flap_l, Color("#b38b5f"))
		var fl_stroke := InkStroke.from_points(flap_l + PackedVector2Array([flap_l[0]]), 2.2, InkStroke.Profile.UNIFORM, ink_col)
		fl_stroke.draw_to(self)
		
		# Right flap folded outward
		var flap_r := PackedVector2Array([
			Vector2(w * 0.5, -h * 0.2),
			Vector2(w * 0.7, -h * 0.4),
			Vector2(w * 0.5, -h * 0.45),
			Vector2(w * 0.42, -h * 0.5)
		])
		draw_colored_polygon(flap_r, Color("#b38b5f"))
		var fr_stroke := InkStroke.from_points(flap_r + PackedVector2Array([flap_r[0]]), 2.2, InkStroke.Profile.UNIFORM, ink_col)
		fr_stroke.draw_to(self)
		
		# Corrugated tape / damp stain on bottom
		if box.is_damp:
			var stain_pts := PackedVector2Array([
				Vector2(-w * 0.45, h * 0.5),
				Vector2(w * 0.45, h * 0.5),
				Vector2(w * 0.42, h * 0.35),
				Vector2(w * 0.1, h * 0.28),
				Vector2(-w * 0.2, h * 0.38),
				Vector2(-w * 0.42, h * 0.32)
			])
			draw_colored_polygon(stain_pts, Color("#9e784e", 0.75))
			
		# Front box line creases
		var crease := InkStroke.from_points(PackedVector2Array([Vector2(-w * 0.4, 0), Vector2(w * 0.4, 0)]), 1.2, InkStroke.Profile.UNIFORM, ink_col)
		crease.draw_to(self)
