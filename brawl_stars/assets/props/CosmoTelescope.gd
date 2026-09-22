class_name CosmoTelescope
extends Node2D

## Observatory Refractor Telescope Prop for COSMO (Brawl Stars)
## 100% Native 2D Hand-drawn illustrated telescope on an adjustable tripod:
## - Brass and deep navy telescope barrel with finder scope and brass focus wheels
## - Angled eyepiece specifically calibrated for Cosmo to align his cyclops eye
## - Adjustable elevation angle for pointing into the deep cosmos
## - Discovery shimmer effect for scientific breakthrough moments

const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var elevation_angle: float = 0.35: # Radians
	set(val):
		elevation_angle = clampf(val, -0.25, 0.75)
		queue_redraw()

var is_discovering: bool = false:
	set(val):
		is_discovering = val
		queue_redraw()

var is_monochrome: bool = false:
	set(val):
		is_monochrome = val
		queue_redraw()

# Palette
var brass_color: Color:
	get: return Color("#cfaf50") if not is_monochrome else Color("#cccccc")

var brass_highlight: Color:
	get: return Color("#f6d678") if not is_monochrome else Color("#eeeeee")

var tube_color: Color:
	get: return Color("#1e2844") if not is_monochrome else Color("#383840")

var tripod_wood_color: Color:
	get: return Color("#5a3c28") if not is_monochrome else Color("#45454c")

var metal_joint_color: Color:
	get: return Color("#40424e") if not is_monochrome else Color("#55555c")

var ink_color: Color:
	get: return Color("#201c24")

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Tripod Mount Base (Center at (0, 0))
	_draw_tripod_legs()
	_draw_mount_swivel()
	
	# Telescope Barrel & Eyepiece (rotated by elevation_angle)
	_draw_telescope_assembly()

func _draw_tripod_legs() -> void:
	var mount_pos := Vector2(0, -60)
	var left_foot := Vector2(-54, 90)
	var mid_foot := Vector2(0, 96)
	var right_foot := Vector2(54, 90)
	
	# Leg struts
	_draw_tripod_leg(mount_pos, left_foot)
	_draw_tripod_leg(mount_pos, mid_foot)
	_draw_tripod_leg(mount_pos, right_foot)
	
	# Horizontal brace spreader
	var b_y := 20.0
	draw_line(Vector2(-30, b_y), Vector2(30, b_y), metal_joint_color, 4.0)
	draw_line(Vector2(-30, b_y), Vector2(30, b_y), ink_color, 1.6)

func _draw_tripod_leg(from: Vector2, to: Vector2) -> void:
	draw_line(from, to, tripod_wood_color, 6.5)
	# Ink edges
	var dir := (to - from).normalized()
	var norm := Vector2(-dir.y, dir.x)
	draw_line(from + norm * 3.5, to + norm * 3.5, ink_color, 1.4)
	draw_line(from - norm * 3.5, to - norm * 3.5, ink_color, 1.4)
	# Brass foot tip
	draw_circle(to, 4.0, brass_color)
	draw_arc(to, 4.0, 0, TAU, 12, ink_color, 1.4, true)

func _draw_mount_swivel() -> void:
	var mount_pos := Vector2(0, -60)
	# Swivel hub
	draw_circle(mount_pos, 12.0, metal_joint_color)
	draw_arc(mount_pos, 12.0, 0, TAU, 16, ink_color, 2.0, true)
	# Brass elevation gear dial
	draw_circle(mount_pos, 6.0, brass_color)
	draw_arc(mount_pos, 6.0, 0, TAU, 12, ink_color, 1.4, true)

func _draw_telescope_assembly() -> void:
	var mount_pos := Vector2(0, -60)
	
	# Assembly local transform: positive elevation tilts objective up and right
	draw_set_transform(mount_pos, -elevation_angle, Vector2.ONE)
	
	# Main Optical Tube (Eyepiece on left at X ~ -65, Objective on right at X ~ +95 pointing to stars)
	var tube_pts := PackedVector2Array([
		Vector2(-55, -11),
		Vector2(95, -16),
		Vector2(95, 16),
		Vector2(-55, 11)
	])
	draw_colored_polygon(tube_pts, tube_color)
	var loop := PackedVector2Array()
	for p in tube_pts: loop.append(p)
	loop.append(tube_pts[0])
	CosmoInkStroke.from_points(loop, 2.8, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	# Brass Trim Rings along the tube
	draw_rect(Rect2(-55, -12, 10, 24), brass_color, true)
	draw_rect(Rect2(-55, -12, 10, 24), ink_color, false, 1.6)
	
	draw_rect(Rect2(15, -15, 8, 30), brass_color, true)
	draw_rect(Rect2(15, -15, 8, 30), ink_color, false, 1.6)
	
	draw_rect(Rect2(85, -18, 10, 36), brass_color, true)
	draw_rect(Rect2(85, -18, 10, 36), ink_color, false, 1.6)
	
	# Finder Scope mounted on top of main tube
	draw_line(Vector2(10, -26), Vector2(60, -26), tube_color, 7.0)
	draw_line(Vector2(10, -26), Vector2(60, -26), ink_color, 1.6)
	draw_line(Vector2(25, -16), Vector2(25, -26), metal_joint_color, 3.0)
	draw_line(Vector2(45, -16), Vector2(45, -26), metal_joint_color, 3.0)
	
	# Eyepiece Assembly on Left (Where Cosmo looks into!)
	var eye_pts := PackedVector2Array([
		Vector2(-55, -6),
		Vector2(-75, -16),
		Vector2(-82, -8),
		Vector2(-62, 2)
	])
	draw_colored_polygon(eye_pts, brass_color)
	var eye_loop := PackedVector2Array()
	for p in eye_pts: eye_loop.append(p)
	eye_loop.append(eye_pts[0])
	CosmoInkStroke.from_points(eye_loop, 1.8, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	# Eyepiece rubber cup
	draw_circle(Vector2(-78, -12), 5.5, metal_joint_color)
	draw_arc(Vector2(-78, -12), 5.5, 0, TAU, 12, ink_color, 1.4, true)
	
	# Focus Wheel (Knob under eyepiece)
	draw_circle(Vector2(-48, 16), 6.0, brass_highlight)
	draw_arc(Vector2(-48, 16), 6.0, 0, TAU, 12, ink_color, 1.4, true)
	
	# Objective Glass Gleam on Right
	draw_line(Vector2(95, -12), Vector2(95, 12), Color(0.6, 0.88, 1.0, 0.75), 3.0)
	
	# Optional Discovery Shimmer (Cosmic eureka discovery rays emitting into sky)
	if is_discovering:
		var beam_col := Color(0.4, 0.8, 1.0, 0.4)
		var star_pts := PackedVector2Array([
			Vector2(95, 0),
			Vector2(140, -25),
			Vector2(155, 0),
			Vector2(140, 25)
		])
		draw_colored_polygon(star_pts, beam_col)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
