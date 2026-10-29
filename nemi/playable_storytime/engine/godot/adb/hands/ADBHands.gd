class_name ADBHands
extends Node2D

## Independent Vector Hand System for ADB Character
## Renders handsome, expressive hands with organic skin fills and calligraphic contours.
## Origin (0, 0) is at the wrist joint.

const ADBStyle = preload("res://adb/characters/adb/ADBStyle.gd")
const CommonInkStroke = preload("res://common/engine/drawing/CommonInkStroke.gd")

@export var is_right: bool = false
var current_hand_type: String = "relaxed"

func _ready() -> void:
	queue_redraw()

func set_hand_type(type_name: String) -> void:
	current_hand_type = type_name.to_lower()
	queue_redraw()

func get_prop_anchor() -> Vector2:
	var flip: float = 1.0 if is_right else -1.0
	match current_hand_type:
		"holding_phone":
			return Vector2(6.0 * flip, 4.0)
		"holding_cup":
			return Vector2(8.0 * flip, 6.0)
		"pointing":
			return Vector2(24.0 * flip, -14.0)
		_:
			return Vector2(0.0, 8.0)

func _draw() -> void:
	var flip: float = 1.0 if is_right else -1.0
	
	match current_hand_type:
		"relaxed":
			_draw_relaxed_hand(flip)
		"open_palm":
			_draw_open_palm(flip)
		"pointing":
			_draw_pointing_hand(flip)
		"fist":
			_draw_fist(flip)
		"holding_cup":
			_draw_holding_cup(flip)
		"shrug_open":
			_draw_open_palm(flip)
		"hand_to_chin":
			_draw_pointing_hand(flip)
		_:
			_draw_relaxed_hand(flip)

func _draw_relaxed_hand(flip: float) -> void:
	var c := Curve2D.new()
	c.add_point(Vector2(-5 * flip, 0), Vector2(0, 0), Vector2(-1 * flip, 3))     # Inner wrist
	c.add_point(Vector2(-8 * flip, 6), Vector2(1 * flip, -2), Vector2(1 * flip, 2)) # Thumb knuckle
	c.add_point(Vector2(-5 * flip, 13), Vector2(-1 * flip, -1), Vector2(2 * flip, 1)) # Thumb tip
	c.add_point(Vector2(-2 * flip, 13), Vector2(-1 * flip, 0), Vector2(0, 2))    # Thumb valley
	c.add_point(Vector2(2 * flip, 21), Vector2(-1 * flip, -3), Vector2(1 * flip, 1)) # Index/mid curve
	c.add_point(Vector2(7 * flip, 17), Vector2(-1 * flip, 2), Vector2(1 * flip, -2)) # Ring/pinky
	c.add_point(Vector2(6 * flip, 8), Vector2(0, 2), Vector2(0, -2))             # Outer palm
	c.add_point(Vector2(4 * flip, 0), Vector2(1 * flip, 2), Vector2(0, 0))       # Outer wrist
	var pts := c.tessellate(5, 1.5)
	
	draw_colored_polygon(pts, ADBStyle.SKIN_BASE)
	draw_polyline(pts, ADBStyle.INK_CONTOUR, 2.0, true)
	
	# Subtle inner finger crease lines
	var crease1 := PackedVector2Array([Vector2(-2 * flip, 13), Vector2(0, 18)])
	var crease2 := PackedVector2Array([Vector2(3 * flip, 13), Vector2(4 * flip, 17)])
	draw_polyline(crease1, ADBStyle.INK_INNER, 1.5, false)
	draw_polyline(crease2, ADBStyle.INK_INNER, 1.5, false)

func _draw_open_palm(flip: float) -> void:
	var c := Curve2D.new()
	c.add_point(Vector2(-5 * flip, 0), Vector2(0, 0), Vector2(-1 * flip, 2))
	c.add_point(Vector2(-9 * flip, 6), Vector2(1 * flip, -2), Vector2(1 * flip, 2))   # Thumb knuckle
	c.add_point(Vector2(-8 * flip, 12), Vector2(-1 * flip, -1), Vector2(2 * flip, 2))  # Thumb tip
	c.add_point(Vector2(-3 * flip, 19), Vector2(-2 * flip, -2), Vector2(1 * flip, 1))  # Index tip
	c.add_point(Vector2(1 * flip, 20), Vector2(-1 * flip, 0), Vector2(1 * flip, -1))   # Middle tip
	c.add_point(Vector2(5 * flip, 18), Vector2(-1 * flip, 1), Vector2(1 * flip, -1))   # Ring tip
	c.add_point(Vector2(8 * flip, 14), Vector2(0, 2), Vector2(0, -2))                  # Pinky tip
	c.add_point(Vector2(5 * flip, 0), Vector2(1 * flip, 2), Vector2(0, 0))             # Wrist
	var pts := c.tessellate(5, 1.5)
	
	draw_colored_polygon(pts, ADBStyle.SKIN_BASE)
	draw_polyline(pts, ADBStyle.INK_CONTOUR, 2.0, true)
	
	# Interior palm lines
	var p_line1 := PackedVector2Array([Vector2(-2 * flip, 8), Vector2(2 * flip, 13)])
	var p_line2 := PackedVector2Array([Vector2(1 * flip, 12), Vector2(5 * flip, 11)])
	draw_polyline(p_line1, ADBStyle.INK_INNER, 1.4, false)
	draw_polyline(p_line2, ADBStyle.INK_INNER, 1.4, false)

func _draw_pointing_hand(flip: float) -> void:
	var c := Curve2D.new()
	c.add_point(Vector2(-5 * flip, 0), Vector2(0, 0), Vector2(-2 * flip, 3))
	c.add_point(Vector2(-8 * flip, 7), Vector2(1 * flip, -2), Vector2(1 * flip, 2))   # Thumb knuckle
	c.add_point(Vector2(-5 * flip, 11), Vector2(-1 * flip, -1), Vector2(2 * flip, 0))  # Thumb tip
	c.add_point(Vector2(-2 * flip, 11), Vector2(-2 * flip, 0), Vector2(0, 3))         # Index base
	c.add_point(Vector2(3 * flip, 23), Vector2(-1 * flip, -3), Vector2(1 * flip, 0))   # Index fingertip
	c.add_point(Vector2(6 * flip, 21), Vector2(0, 2), Vector2(0, -3))
	c.add_point(Vector2(6 * flip, 10), Vector2(0, 2), Vector2(0, -2))                  # Curled knuckles
	c.add_point(Vector2(4 * flip, 0), Vector2(1 * flip, 2), Vector2(0, 0))             # Outer wrist
	var pts := c.tessellate(5, 1.5)
	
	draw_colored_polygon(pts, ADBStyle.SKIN_BASE)
	draw_polyline(pts, ADBStyle.INK_CONTOUR, 2.0, true)
	
	# Curled knuckle crease
	var curl := PackedVector2Array([Vector2(0, 11), Vector2(4 * flip, 11)])
	draw_polyline(curl, ADBStyle.INK_INNER, 1.5, false)

func _draw_fist(flip: float) -> void:
	var c := Curve2D.new()
	c.add_point(Vector2(-4 * flip, 0), Vector2(0, 0), Vector2(-2 * flip, 2))
	c.add_point(Vector2(-7 * flip, 7), Vector2(1 * flip, -2), Vector2(1 * flip, 2))
	c.add_point(Vector2(-3 * flip, 14), Vector2(-2 * flip, -2), Vector2(2 * flip, 1))
	c.add_point(Vector2(3 * flip, 14), Vector2(-2 * flip, 1), Vector2(2 * flip, -2))
	c.add_point(Vector2(6 * flip, 8), Vector2(1 * flip, 2), Vector2(-1 * flip, -2))
	c.add_point(Vector2(4 * flip, 0), Vector2(1 * flip, 2), Vector2(0, 0))
	var pts := c.tessellate(5, 1.5)
	
	draw_colored_polygon(pts, ADBStyle.SKIN_BASE)
	draw_polyline(pts, ADBStyle.INK_CONTOUR, 2.0, true)
	
	var knuckle1 := PackedVector2Array([Vector2(-3 * flip, 7), Vector2(0, 10)])
	var knuckle2 := PackedVector2Array([Vector2(1 * flip, 9), Vector2(4 * flip, 7)])
	draw_polyline(knuckle1, ADBStyle.INK_INNER, 1.4, false)
	draw_polyline(knuckle2, ADBStyle.INK_INNER, 1.4, false)

func _draw_holding_cup(flip: float) -> void:
	var c := Curve2D.new()
	c.add_point(Vector2(-4 * flip, 0), Vector2(0, 0), Vector2(-2 * flip, 2))
	c.add_point(Vector2(-8 * flip, 6), Vector2(1 * flip, -2), Vector2(1 * flip, 2))
	c.add_point(Vector2(-5 * flip, 13), Vector2(-1 * flip, -1), Vector2(2 * flip, 1))
	c.add_point(Vector2(2 * flip, 15), Vector2(-2 * flip, 0), Vector2(1 * flip, -1))
	c.add_point(Vector2(7 * flip, 10), Vector2(0, 2), Vector2(0, -2))
	c.add_point(Vector2(4 * flip, 0), Vector2(1 * flip, 2), Vector2(0, 0))
	var pts := c.tessellate(5, 1.5)
	
	draw_colored_polygon(pts, ADBStyle.SKIN_BASE)
	draw_polyline(pts, ADBStyle.INK_CONTOUR, 2.0, true)
