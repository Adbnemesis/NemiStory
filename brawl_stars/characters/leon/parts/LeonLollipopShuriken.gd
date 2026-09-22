class_name LeonLollipopShuriken
extends Node2D

## Spinning Fidget-Spinner Shurikens & Prop Item Controller for LEON (Brawl Stars)
## Implements the 3-bladed rotating ninja stars with cyan metallic gleams and hand-drawn ink contours.

const LeonStyle = preload("res://brawl_stars/characters/leon/LeonStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: LeonStyle

var is_spinning: bool = false
var spin_speed: float = 12.0
var show_shuriken: bool = false
var shuriken_spin_angle: float = 0.0

func _process(delta: float) -> void:
	if is_spinning:
		shuriken_spin_angle += delta * spin_speed
		queue_redraw()

func _draw() -> void:
	if not style or not show_shuriken:
		return
	
	draw_set_transform(Vector2(65, 50), shuriken_spin_angle, Vector2.ONE)
	_draw_3blade_shuriken()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_3blade_shuriken() -> void:
	# 3 curved aerodynamic blades around central circular core
	var num_blades := 3
	for i in range(num_blades):
		var ang := i * (TAU / num_blades)
		var blade_tip := Vector2(cos(ang), sin(ang)) * 24.0
		var blade_side := Vector2(cos(ang + 0.4), sin(ang + 0.4)) * 14.0
		var blade_notch := Vector2(cos(ang - 0.35), sin(ang - 0.35)) * 10.0
		
		var blade_poly := PackedVector2Array([
			Vector2.ZERO,
			blade_notch,
			blade_tip,
			blade_side,
			Vector2.ZERO
		])
		draw_colored_polygon(blade_poly, style.shuriken_metal_color)
		
		# Cyan sharp edge highlight
		draw_line(blade_notch, blade_tip, style.shuriken_glow_color, 2.0, true)
		draw_polyline(blade_poly, style.ink_color, style.inner_line_width, true)
	
	# Center bearing ring
	draw_circle(Vector2.ZERO, 6.0, style.hood_orange_color)
	draw_circle(Vector2.ZERO, 3.5, style.ink_color)
	draw_arc(Vector2.ZERO, 6.0, 0, TAU, 16, style.ink_color, 1.8, true)
