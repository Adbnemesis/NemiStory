class_name PropDrinkGlasses
extends "res://nemi/world/props/NemiProp.gd"

## Illustrated Drink Glasses Prop for Episode 02
## Two hand-drawn tumblers with warm amber liquid for the drunk story beat.
## Supports clinking animation with subtle liquid slosh and vibration.

var clink_angle: float = 0.0:
	set(val):
		clink_angle = val
		queue_redraw()

var liquid_wobble: float = 0.0:
	set(val):
		liquid_wobble = val
		queue_redraw()

func _init() -> void:
	prop_name = "drink_glasses"
	current_state = "normal"

func clink(duration: float = 0.35) -> Signal:
	var tw := create_tween()
	tw.tween_property(self, "clink_angle", deg_to_rad(12.0), duration * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "clink_angle", deg_to_rad(-4.0), duration * 0.3)
	tw.tween_property(self, "clink_angle", 0.0, duration * 0.3)
	return tw.finished

func _draw() -> void:
	# Draw Left Glass (tilted by -clink_angle)
	_draw_glass(Vector2(-24, 0), -clink_angle, Color("#d99b43", 0.75))
	
	# Draw Right Glass (tilted by clink_angle)
	_draw_glass(Vector2(24, 0), clink_angle, Color("#d99b43", 0.75))
	
	# Clink stars if clinking
	if abs(clink_angle) > 0.05:
		draw_line(Vector2(0, -22), Vector2(0, -32), Color("#2b2623"), 2.0)
		draw_line(Vector2(-5, -27), Vector2(5, -27), Color("#2b2623"), 2.0)
		draw_line(Vector2(-4, -31), Vector2(4, -23), Color("#2b2623"), 1.6)

func _draw_glass(pos: Vector2, angle: float, liquid_col: Color) -> void:
	var w := 18.0
	var h := 32.0
	
	# Rotate local canvas
	draw_set_transform(pos, angle, Vector2.ONE)
	
	# Liquid fill
	var liquid_poly := PackedVector2Array([
		Vector2(-w * 0.45, -h * 0.1), Vector2(w * 0.45, -h * 0.1),
		Vector2(w * 0.4, h * 0.5 - 2), Vector2(-w * 0.4, h * 0.5 - 2)
	])
	draw_colored_polygon(liquid_poly, liquid_col)
	
	# Glass outline
	var glass_outline := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5), Vector2(-w * 0.4, h * 0.5),
		Vector2(w * 0.4, h * 0.5), Vector2(w * 0.5, -h * 0.5)
	])
	draw_polyline(glass_outline, Color("#2b2623"), 2.6)
	
	# Rim
	draw_line(Vector2(-w * 0.5, -h * 0.5), Vector2(w * 0.5, -h * 0.5), Color("#2b2623"), 2.4)
	
	# Glass bottom base line
	draw_line(Vector2(-w * 0.4, h * 0.5), Vector2(w * 0.4, h * 0.5), Color("#2b2623"), 3.4)
	
	# Glass highlight reflection stroke
	draw_line(Vector2(-w * 0.35, -h * 0.35), Vector2(-w * 0.28, h * 0.25), Color(1, 1, 1, 0.65), 2.0)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
