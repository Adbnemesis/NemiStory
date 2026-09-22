class_name CosmoCelestialOrbs
extends Node2D

## 3 Orbiting Celestial Bodies Manipulated by COSMO's Attractor Gauntlet
## 100% Native 2D Hand-drawn illustrated celestial bodies:
## 1. Ringed Planet (Saturn-style azure planet with hand-drawn planetary rings)
## 2. Blue Moon (Bright cyan sphere with crater dots)
## 3. Gravitational Plasma Bubble (Luminous translucent orb)
## Supports Orbit expansion (Main Attack: Orbit) and Homing vectors (Super: Gravitational Pull).

const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var orbit_radius_x: float = 38.0
var orbit_radius_y: float = 14.0
var orbit_angle: float = 0.0
var orbit_speed: float = 2.4

var mode: String = "hover_palm" # "hover_palm", "expand_orbit", "home_target", "idle"
var is_monochrome: bool = false:
	set(val):
		is_monochrome = val
		queue_redraw()

var target_point: Vector2 = Vector2(180, -40)

# Colors
var planet_color: Color:
	get: return Color("#3ca4f0") if not is_monochrome else Color("#555560")

var planet_band_color: Color:
	get: return Color("#1d6cb5") if not is_monochrome else Color("#3d3d46")

var ring_color: Color:
	get: return Color("#8ae0ff") if not is_monochrome else Color("#cccccc")

var moon_color: Color:
	get: return Color("#60c4ff") if not is_monochrome else Color("#888892")

var bubble_color: Color:
	get: return Color(0.4, 0.75, 1.0, 0.42) if not is_monochrome else Color(0.9, 0.9, 0.9, 0.35)

var ink_color: Color:
	get: return Color("#201c24")

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	if mode != "idle":
		orbit_angle += delta * orbit_speed
		if orbit_angle >= TAU:
			orbit_angle -= TAU
		queue_redraw()

func _draw() -> void:
	# 1. Hand-Drawn Orbital Trajectory Ellipse
	_draw_orbital_trajectory()
	
	# Compute 3 orb positions distributed evenly (0, 120, 240 deg)
	var p1_ang := orbit_angle
	var p2_ang := orbit_angle + TAU * (1.0 / 3.0)
	var p3_ang := orbit_angle + TAU * (2.0 / 3.0)
	
	var r_x := orbit_radius_x
	var r_y := orbit_radius_y
	
	if mode == "expand_orbit":
		r_x = 72.0
		r_y = 26.0
	
	var pos1 := Vector2(cos(p1_ang) * r_x, sin(p1_ang) * r_y)
	var pos2 := Vector2(cos(p2_ang) * r_x, sin(p2_ang) * r_y)
	var pos3 := Vector2(cos(p3_ang) * r_x, sin(p3_ang) * r_y)
	
	# Sort by Y for depth layering (behind orbit vs in front of orbit)
	var orbs: Array[Dictionary] = [
		{"type": "saturn", "pos": pos1, "y": pos1.y},
		{"type": "moon", "pos": pos2, "y": pos2.y},
		{"type": "bubble", "pos": pos3, "y": pos3.y}
	]
	orbs.sort_custom(func(a, b): return a["y"] < b["y"])
	
	for o in orbs:
		match o["type"]:
			"saturn":
				_draw_saturn_planet(o["pos"])
			"moon":
				_draw_moon_orb(o["pos"])
			"bubble":
				_draw_gravitational_bubble(o["pos"])

func _draw_orbital_trajectory() -> void:
	var r_x := orbit_radius_x
	var r_y := orbit_radius_y
	if mode == "expand_orbit":
		r_x = 72.0
		r_y = 26.0
	
	# Dashed ink trajectory ellipse
	var segments := 24
	for i in range(segments):
		if i % 2 == 0:
			var a0 := float(i) / float(segments) * TAU
			var a1 := float(i + 0.8) / float(segments) * TAU
			var p0 := Vector2(cos(a0) * r_x, sin(a0) * r_y)
			var p1 := Vector2(cos(a1) * r_x, sin(a1) * r_y)
			draw_line(p0, p1, Color(ink_color.r, ink_color.g, ink_color.b, 0.45), 1.2)

func _draw_saturn_planet(pos: Vector2) -> void:
	var rad: float = 9.0
	
	# Back half of planetary ring
	draw_set_transform(pos, -0.3, Vector2(1.0, 0.32))
	draw_arc(Vector2.ZERO, 18.0, PI, TAU, 16, ring_color, 3.2, true)
	draw_arc(Vector2.ZERO, 18.0, PI, TAU, 16, ink_color, 1.2, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# Planet Body
	draw_circle(pos, rad, planet_color)
	# Cloud band across center
	draw_line(pos + Vector2(-rad * 0.9, 0), pos + Vector2(rad * 0.9, 0), planet_band_color, 2.5)
	draw_arc(pos, rad, 0, TAU, 16, ink_color, 1.6, true)
	
	# Front half of planetary ring
	draw_set_transform(pos, -0.3, Vector2(1.0, 0.32))
	draw_arc(Vector2.ZERO, 18.0, 0, PI, 16, ring_color, 3.2, true)
	draw_arc(Vector2.ZERO, 18.0, 0, PI, 16, ink_color, 1.2, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_moon_orb(pos: Vector2) -> void:
	var rad: float = 6.5
	draw_circle(pos, rad, moon_color)
	draw_arc(pos, rad, 0, TAU, 16, ink_color, 1.6, true)
	# Crater dots
	draw_circle(pos + Vector2(-2, -1.5), 1.4, Color(ink_color.r, ink_color.g, ink_color.b, 0.35))
	draw_circle(pos + Vector2(2, 2), 1.0, Color(ink_color.r, ink_color.g, ink_color.b, 0.35))

func _draw_gravitational_bubble(pos: Vector2) -> void:
	var rad: float = 8.5
	# Outer glowing aura
	draw_circle(pos, rad + 2.5, Color(bubble_color.r, bubble_color.g, bubble_color.b, 0.2))
	# Luminous translucent core
	draw_circle(pos, rad, bubble_color)
	draw_arc(pos, rad, 0, TAU, 16, ink_color, 1.4, true)
	# Specular glint
	draw_circle(pos + Vector2(-3, -3), 2.0, Color(1, 1, 1, 0.8))
