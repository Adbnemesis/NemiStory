class_name ChildhoodToy
extends Node2D

## The Childhood Chew Toy Prop — The Emotional Core of "COSMO STOLE RUFFS' CHILDHOOD"
## A small, endearing rubber bone toy connecting:
## Puppy Ruffs (Act 1-3) -> Capsule Space Voyage (Act 4) -> Adult Ruffs (Act 6) -> Confrontation Desk (Act 8) -> Pocket (Act 12).
## 100% Native 2D Hand-drawn illustrated vector prop with squash/squeak animation and weathered wear states.

const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

@export var is_worn: bool = false:
	set(val):
		is_worn = val
		queue_redraw()

var is_monochrome: bool = false:
	set(val):
		is_monochrome = val
		queue_redraw()

var ink_color: Color = Color("#201c24")

# Palette
var rubber_color: Color:
	get:
		if is_monochrome: return Color("#666670") if is_worn else Color("#888892")
		return Color("#48c2b4") if is_worn else Color("#58d8c8")

var rubber_highlight: Color:
	get:
		if is_monochrome: return Color("#888892") if is_worn else Color("#aaaaaa")
		return Color("#7ce6d8") if is_worn else Color("#a8f0e4")

var rubber_shadow: Color:
	get:
		if is_monochrome: return Color("#44444c")
		return Color("#328e84") if is_worn else Color("#38a498")

var star_gold: Color:
	get:
		if is_monochrome: return Color("#cccccc")
		return Color("#d4a832") if is_worn else Color("#f6c33a")

var _squeak_tween: Tween

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Origin at center of toy (0, 0). Width ~ 44px, Height ~ 20px
	_draw_bone_body()
	_draw_star_stamp()
	if is_worn:
		_draw_wear_patches()

func _draw_bone_body() -> void:
	# Central rubber shaft
	var shaft_pts := PackedVector2Array([
		Vector2(-12, -6),
		Vector2(12, -6),
		Vector2(12, 6),
		Vector2(-12, 6)
	])
	draw_colored_polygon(shaft_pts, rubber_color)
	
	# Top highlight on shaft
	draw_line(Vector2(-10, -3), Vector2(10, -3), rubber_highlight, 2.5)
	# Bottom shadow on shaft
	draw_line(Vector2(-10, 4), Vector2(10, 4), rubber_shadow, 2.0)
	
	# Four bulbous bone knobs (two on left, two on right)
	# Left knobs
	draw_circle(Vector2(-14, -6), 6.5, rubber_color)
	draw_circle(Vector2(-14, 6), 6.5, rubber_color)
	draw_circle(Vector2(-15, -7), 3.0, rubber_highlight)
	
	# Right knobs
	draw_circle(Vector2(14, -6), 6.5, rubber_color)
	draw_circle(Vector2(14, 6), 6.5, rubber_color)
	draw_circle(Vector2(13, -7), 3.0, rubber_highlight)
	
	# Ink Outlines
	draw_arc(Vector2(-14, -6), 6.5, -PI, PI * 0.25, 14, ink_color, 2.4, true)
	draw_arc(Vector2(-14, 6), 6.5, PI * 0.75, PI * 2.0, 14, ink_color, 2.4, true)
	draw_arc(Vector2(14, -6), 6.5, -PI * 0.25, PI, 14, ink_color, 2.4, true)
	draw_arc(Vector2(14, 6), 6.5, 0, PI * 1.25, 14, ink_color, 2.4, true)
	
	# Shaft contour lines
	draw_line(Vector2(-12, -6), Vector2(12, -6), ink_color, 2.4)
	draw_line(Vector2(-12, 6), Vector2(12, 6), ink_color, 2.4)

func _draw_star_stamp() -> void:
	# Cheerful embossed star in the center
	var star_center := Vector2(0, 0)
	var r_outer := 4.2
	var r_inner := 2.0
	var star_pts := PackedVector2Array()
	for i in range(10):
		var ang := (float(i) / 10.0) * TAU - PI * 0.5
		var r := r_outer if (i % 2 == 0) else r_inner
		star_pts.append(star_center + Vector2(cos(ang) * r, sin(ang) * r))
	draw_colored_polygon(star_pts, star_gold)
	var s_loop := PackedVector2Array()
	for p in star_pts: s_loop.append(p)
	s_loop.append(star_pts[0])
	draw_polyline(s_loop, ink_color, 1.2, true)

func _draw_wear_patches() -> void:
	# Subtle wear stitches and weathered scuffs for adult timeline
	# Left knob patch
	draw_line(Vector2(-17, 3), Vector2(-11, 7), ink_color, 1.4)
	draw_line(Vector2(-15, 2), Vector2(-13, 8), ink_color, 1.2)
	# Right shaft chew tooth mark
	draw_arc(Vector2(6, 4), 2.5, 0, PI, 6, ink_color, 1.5, true)
	draw_arc(Vector2(8, -4), 2.5, PI, TAU, 6, ink_color, 1.5, true)

func squeak() -> void:
	if _squeak_tween and _squeak_tween.is_valid():
		_squeak_tween.kill()
	_squeak_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_squeak_tween.tween_property(self, "scale", Vector2(1.3, 0.7), 0.08)
	_squeak_tween.tween_property(self, "scale", Vector2(0.9, 1.15), 0.09)
	_squeak_tween.tween_property(self, "scale", Vector2.ONE, 0.12)
