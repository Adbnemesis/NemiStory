class_name StarrCapsule
extends Node2D

## Starr Force Prototype Spacecraft / Launch Capsule Prop
## Used across Acts 2, 3, 4, 5, and 6:
## - Exterior retro scientific space pod with rounded nosecone, brass trim, and porthole window
## - Hatch door with open/closed states
## - Launch thrusters with animated flame/smoke plumes
## - Scorched/re-entry weathered state for return landing in Act 6

const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

enum State {
	GROUND_OPEN,
	SEALED,
	LAUNCHING,
	SPACE_DRIFT,
	ANOMALY,
	RETURNED_SCORCHED
}

@export var current_state: State = State.GROUND_OPEN:
	set(val):
		current_state = val
		queue_redraw()

var is_monochrome: bool = false:
	set(val):
		is_monochrome = val
		queue_redraw()

var thruster_flame_time: float = 0.0

# Palette
var hull_metal: Color:
	get:
		if is_monochrome: return Color("#3a3a42") if current_state == State.RETURNED_SCORCHED else Color("#666670")
		return Color("#283248") if current_state == State.RETURNED_SCORCHED else Color("#384c72")

var hull_highlight: Color:
	get:
		if is_monochrome: return Color("#555560")
		return Color("#546e9e")

var brass_trim: Color:
	get:
		if is_monochrome: return Color("#999999")
		return Color("#c89828") if current_state == State.RETURNED_SCORCHED else Color("#f4c238")

var glass_color: Color:
	get:
		if is_monochrome: return Color("#bbbbbb")
		return Color("#38d0f8", 0.5)

var thruster_fire: Color:
	get:
		if is_monochrome: return Color.WHITE
		return Color("#ff6a20")

var ink_color: Color = Color("#201c24")

func _process(delta: float) -> void:
	if current_state == State.LAUNCHING or current_state == State.ANOMALY:
		thruster_flame_time += delta * 20.0
		queue_redraw()

func _draw() -> void:
	# Origin is at bottom center of capsule (0, 0)
	# Capsule is ~140px wide, ~190px tall
	_draw_fins()
	_draw_thruster_nozzle()
	if current_state == State.LAUNCHING:
		_draw_thruster_plume()
	_draw_hull_body()
	_draw_porthole_window()
	_draw_hatch_door()
	if current_state == State.RETURNED_SCORCHED:
		_draw_scorch_marks()

func _draw_fins() -> void:
	# Left Fin
	var l_fin := PackedVector2Array([
		Vector2(-55, -20),
		Vector2(-85, 0),
		Vector2(-85, 14),
		Vector2(-52, 4)
	])
	draw_colored_polygon(l_fin, hull_metal)
	var l_loop := PackedVector2Array()
	for p in l_fin: l_loop.append(p)
	l_loop.append(l_fin[0])
	CosmoInkStroke.from_points(l_loop, 2.8, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	# Right Fin
	var r_fin := PackedVector2Array([
		Vector2(55, -20),
		Vector2(85, 0),
		Vector2(85, 14),
		Vector2(52, 4)
	])
	draw_colored_polygon(r_fin, hull_metal)
	var r_loop := PackedVector2Array()
	for p in r_fin: r_loop.append(p)
	r_loop.append(r_fin[0])
	CosmoInkStroke.from_points(r_loop, 2.8, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)

func _draw_thruster_nozzle() -> void:
	var nozzle_pts := PackedVector2Array([
		Vector2(-32, 0),
		Vector2(32, 0),
		Vector2(24, 18),
		Vector2(-24, 18)
	])
	draw_colored_polygon(nozzle_pts, Color("#22242e"))
	var n_loop := PackedVector2Array()
	for p in nozzle_pts: n_loop.append(p)
	n_loop.append(nozzle_pts[0])
	CosmoInkStroke.from_points(n_loop, 2.8, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)

func _draw_thruster_plume() -> void:
	var wobble := sin(thruster_flame_time) * 6.0
	var flame_pts := PackedVector2Array([
		Vector2(-20, 18),
		Vector2(20, 18),
		Vector2(14, 55 + wobble),
		Vector2(0, 75 + wobble * 1.4),
		Vector2(-14, 55 + wobble)
	])
	draw_colored_polygon(flame_pts, thruster_fire)
	
	# Inner white core
	var core_pts := PackedVector2Array([
		Vector2(-10, 18),
		Vector2(10, 18),
		Vector2(6, 40),
		Vector2(0, 52),
		Vector2(-6, 40)
	])
	draw_colored_polygon(core_pts, Color.WHITE)

func _draw_hull_body() -> void:
	# Main aerodynamic capsule body
	var hull_pts := PackedVector2Array([
		Vector2(-52, 0),
		Vector2(52, 0),
		Vector2(55, -80),
		Vector2(42, -135),
		Vector2(22, -170),
		Vector2(0, -182),
		Vector2(-22, -170),
		Vector2(-42, -135),
		Vector2(-55, -80)
	])
	draw_colored_polygon(hull_pts, hull_metal)
	
	# Left shadow plate
	var sh_pts := PackedVector2Array([
		Vector2(0, -182),
		Vector2(22, -170),
		Vector2(42, -135),
		Vector2(55, -80),
		Vector2(52, 0),
		Vector2(0, 0)
	])
	draw_colored_polygon(sh_pts, hull_metal.darkened(0.2))
	
	var h_loop := PackedVector2Array()
	for p in hull_pts: h_loop.append(p)
	h_loop.append(hull_pts[0])
	CosmoInkStroke.from_points(h_loop, 3.5, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	# Brass nosecone band
	draw_line(Vector2(-35, -145), Vector2(35, -145), brass_trim, 4.0)
	draw_line(Vector2(-48, -95), Vector2(48, -95), brass_trim, 3.5)

func _draw_porthole_window() -> void:
	# Circular observation window at Vector2(0, -95)
	var win_center := Vector2(0, -95)
	var win_r := 26.0
	
	# Brass outer porthole bezel
	draw_circle(win_center, win_r + 5.0, brass_trim)
	draw_arc(win_center, win_r + 5.0, 0, TAU, 24, ink_color, 2.4, true)
	
	# Interior Cabin Dark Depth
	draw_circle(win_center, win_r, Color("#161a24"))
	
	# Glass tint
	draw_circle(win_center, win_r, glass_color)
	draw_arc(win_center, win_r, 0, TAU, 24, ink_color, 2.0, true)
	
	# Specular glass reflection arcs
	draw_arc(win_center + Vector2(-3, -3), win_r * 0.75, PI * 1.1, PI * 1.7, 10, Color.WHITE, 2.4, true)
	draw_line(win_center + Vector2(-12, 10), win_center + Vector2(-6, 16), Color.WHITE, 1.8)

func _draw_hatch_door() -> void:
	var door_center := Vector2(0, -38)
	var dw := 36.0
	var dh := 26.0
	
	if current_state == State.GROUND_OPEN:
		# Open hatch door: swung to the right
		var open_pts := PackedVector2Array([
			Vector2(dw * 0.8, door_center.y - dh * 0.5),
			Vector2(dw * 1.5, door_center.y - dh * 0.4),
			Vector2(dw * 1.5, door_center.y + dh * 0.4),
			Vector2(dw * 0.8, door_center.y + dh * 0.5)
		])
		draw_colored_polygon(open_pts, hull_highlight)
		var o_loop := PackedVector2Array()
		for p in open_pts: o_loop.append(p)
		o_loop.append(open_pts[0])
		CosmoInkStroke.from_points(o_loop, 2.4, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
		# Interior dark opening
		var in_rect := Rect2(door_center - Vector2(dw * 0.5, dh * 0.5), Vector2(dw, dh))
		draw_rect(in_rect, Color("#141620"), true)
		draw_rect(in_rect, ink_color, false, 2.4)
	else:
		# Sealed hatch door
		var door_rect := Rect2(door_center - Vector2(dw * 0.5, dh * 0.5), Vector2(dw, dh))
		draw_rect(door_rect, hull_highlight, true)
		draw_rect(door_rect, ink_color, false, 2.4)
		# Central hatch wheel handle
		draw_circle(door_center, 6.0, brass_trim)
		draw_arc(door_center, 6.0, 0, TAU, 14, ink_color, 2.0, true)
		draw_line(door_center + Vector2(-5, 0), door_center + Vector2(5, 0), ink_color, 1.8)
		draw_line(door_center + Vector2(0, -5), door_center + Vector2(0, 5), ink_color, 1.8)

func _draw_scorch_marks() -> void:
	# Heavy atmospheric re-entry burn marks and soot streaks
	var scorch_col := Color(0.1, 0.08, 0.12, 0.7)
	# Nosecone scorch
	draw_line(Vector2(-15, -170), Vector2(-8, -140), scorch_col, 4.0)
	draw_line(Vector2(0, -180), Vector2(6, -135), scorch_col, 5.0)
	draw_line(Vector2(12, -165), Vector2(18, -130), scorch_col, 4.0)
	# Base soot
	draw_line(Vector2(-45, -10), Vector2(-30, -40), scorch_col, 3.5)
	draw_line(Vector2(45, -10), Vector2(28, -35), scorch_col, 4.0)
