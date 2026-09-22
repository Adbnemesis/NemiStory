class_name PikachuTail
extends Node2D

## Procedural articulated lightning-bolt tail for PIKACHU
## Authentic zigzag silhouette with warm earth-brown base and animated wag/twitch/droop.

const PokemonInkStroke = preload("res://pokemon/scripts/PokemonInkStroke.gd")
const PikachuStyle = preload("res://pokemon/characters/pikachu/PikachuStyle.gd")

var style: PikachuStyle

var tail_angle_offset: float = 0.0:
	set(val):
		tail_angle_offset = val
		queue_redraw()

var wag_frequency: float = 0.0
var wag_amplitude: float = 0.0
var _wag_time: float = 0.0

var is_drooped: bool = false:
	set(val):
		is_drooped = val
		queue_redraw()

var is_zapping: bool = false:
	set(val):
		is_zapping = val
		queue_redraw()

func _process(delta: float) -> void:
	if wag_amplitude > 0.001:
		_wag_time += delta * wag_frequency
		tail_angle_offset = sin(_wag_time) * wag_amplitude

func _draw() -> void:
	if not style:
		return
	
	# Root transform
	var rot: float = tail_angle_offset
	if is_drooped:
		rot += 0.55
	
	draw_set_transform(Vector2.ZERO, rot, Vector2.ONE)
	
	# Tail polygon coordinates (classic 3-step lightning bolt)
	# 1. Brown Base segment (attaches to lower back)
	var base_poly := PackedVector2Array([
		Vector2(0, 4),
		Vector2(10, 2),
		Vector2(14, -6),
		Vector2(5, -4)
	])
	draw_colored_polygon(base_poly, style.brown_marking_color)
	draw_polyline(base_poly, style.ink_color, style.outer_contour_width, true)
	
	# Jagged transition from brown to yellow
	var brown_jag := PackedVector2Array([
		Vector2(5, -4),
		Vector2(8, -1),
		Vector2(11, -5),
		Vector2(14, -6)
	])
	draw_polyline(brown_jag, style.ink_color, style.inner_line_width, false)
	
	# 2. Middle zigzag segment (yellow)
	var mid_poly := PackedVector2Array([
		Vector2(5, -4),
		Vector2(14, -6),
		Vector2(12, -18),
		Vector2(25, -16),
		Vector2(20, -32),
		Vector2(6, -26)
	])
	draw_colored_polygon(mid_poly, style.fur_base_color)
	draw_polyline(mid_poly, style.ink_color, style.outer_contour_width, true)
	
	# 3. Large lightning blade tip (yellow)
	var blade_poly := PackedVector2Array([
		Vector2(20, -32),
		Vector2(25, -16),
		Vector2(44, -14),
		Vector2(32, -44),
		Vector2(55, -40),
		Vector2(26, -64),
		Vector2(10, -36),
		Vector2(18, -34)
	])
	draw_colored_polygon(blade_poly, style.fur_base_color)
	
	# Subtle shadow facet on blade for illustrated volume
	var blade_shadow := PackedVector2Array([
		Vector2(44, -14),
		Vector2(32, -44),
		Vector2(38, -43),
		Vector2(44, -26)
	])
	draw_colored_polygon(blade_shadow, style.fur_shadow_color)
	
	draw_polyline(blade_poly, style.ink_color, style.outer_contour_width, true)
	
	# Sparks if zapping
	if is_zapping:
		_draw_sparks()

func _draw_sparks() -> void:
	var spark_points := [
		Vector2(30, -68),
		Vector2(60, -42),
		Vector2(48, -10)
	]
	for p in spark_points:
		var spark_c := PackedVector2Array([
			p + Vector2(-6, 0),
			p + Vector2(6, 0),
			p,
			p + Vector2(0, -7),
			p + Vector2(0, 7)
		])
		draw_polyline(spark_c, style.spark_color, 2.4, false)
