class_name PropHairdryer
extends "res://nemi/world/props/NemiProp.gd"

## Illustrated Hairdryer Prop
## Hand-drawn hair salon styling: barrel, tapered nozzle, handle, and dangling cord.
## State "blast": Projects fiery squiggly heat blast lines from nozzle with high-frequency buzz shake.

const BODY_COLOR: Color = Color("#4a586e")   # Slate navy
const ACCENT_COLOR: Color = Color("#df5d48") # Coral red accent rim
const NOZZLE_COLOR: Color = Color("#2e323b")
const HEAT_COLOR_1: Color = Color(0.95, 0.42, 0.22, 0.85)
const HEAT_COLOR_2: Color = Color(0.98, 0.72, 0.25, 0.75)

var is_blasting: bool = false
var _blast_time: float = 0.0

func _init() -> void:
	prop_name = "hairdryer"
	current_state = "off"

func _process(delta: float) -> void:
	super._process(delta)
	if current_state == "blast":
		_blast_time += delta
		queue_redraw()

func _draw() -> void:
	# 1. Nozzle (pointing left by default)
	var nozzle_pts: PackedVector2Array = [
		Vector2(-24, -8), Vector2(-16, -11), Vector2(-16, 7), Vector2(-24, 4)
	]
	draw_colored_polygon(nozzle_pts, NOZZLE_COLOR)
	draw_polyline(nozzle_pts, Color("#2b2623"), 2.8, true)
	
	# 2. Main Barrel Body
	var barrel_pts: PackedVector2Array = [
		Vector2(-16, -12), Vector2(12, -14),
		Vector2(16, -10), Vector2(16, 10),
		Vector2(12, 12), Vector2(-16, 8)
	]
	draw_colored_polygon(barrel_pts, BODY_COLOR)
	draw_polyline(barrel_pts, Color("#2b2623"), 3.2, true)
	
	# Accent stripe
	draw_line(Vector2(6, -13), Vector2(6, 11), ACCENT_COLOR, 3.0)
	
	# Rear intake vent
	draw_arc(Vector2(16, 0), 8.0, -PI * 0.45, PI * 0.45, 8, Color("#2b2623"), 2.2)
	
	# 3. Grip Handle
	var handle_pts: PackedVector2Array = [
		Vector2(0, 10), Vector2(6, 36), Vector2(-4, 38), Vector2(-8, 10)
	]
	draw_colored_polygon(handle_pts, BODY_COLOR)
	draw_polyline(handle_pts, Color("#2b2623"), 3.0, true)
	
	# 4. Curly Power Cord
	var cord_pts: PackedVector2Array = [
		Vector2(1, 38), Vector2(4, 48), Vector2(-3, 56), Vector2(6, 66), Vector2(0, 76)
	]
	draw_polyline(cord_pts, Color("#2b2623"), 2.2)
	
	# 5. Blast Heat Rays (if active)
	if current_state == "blast":
		_draw_heat_blast()

func _draw_heat_blast() -> void:
	var start_x := -26.0
	for i in range(4):
		var y_off = (i - 1.5) * 6.0
		var wave_amp = sin(_blast_time * 25.0 + i) * 4.0
		var pts: PackedVector2Array = [
			Vector2(start_x, y_off),
			Vector2(start_x - 18, y_off + wave_amp),
			Vector2(start_x - 38, y_off - wave_amp * 1.2),
			Vector2(start_x - 60, y_off + wave_amp * 0.8)
		]
		var col = HEAT_COLOR_1 if i % 2 == 0 else HEAT_COLOR_2
		draw_polyline(pts, col, 3.2)
		
	# Floating heat sparks
	for s in range(3):
		var spark_x = start_x - 20.0 - s * 16.0 + sin(_blast_time * 15.0 + s) * 6.0
		var spark_y = (s - 1.0) * 12.0 + cos(_blast_time * 20.0) * 5.0
		draw_circle(Vector2(spark_x, spark_y), 2.5, HEAT_COLOR_2)
