class_name ObservatoryLab
extends Node2D

## Observatory Laboratory Environment & Temporal Accelerator Machine Prop
## Provides the hand-drawn scientific setting for Acts 2, 7, 8, 9, 10, 11, 12:
## - Scientific laboratory desk with blueprint scrolls and computer console
## - Background laboratory chalkboard with chalk orbit formulas
## - The Temporal Space Accelerator Core Machine:
##   * Active state: Glowing core sphere with magnetic containment rings
##   * Destroyed state (Act 11): Shattered core glass, broken coils, smoke wisps

const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

@export var is_destroyed: bool = false:
	set(val):
		is_destroyed = val
		queue_redraw()

@export var show_desk: bool = true:
	set(val):
		show_desk = val
		queue_redraw()

@export var show_machine: bool = true:
	set(val):
		show_machine = val
		queue_redraw()

var is_monochrome: bool = false:
	set(val):
		is_monochrome = val
		queue_redraw()

var core_pulse_time: float = 0.0

# Palette
var steel_color: Color:
	get: return Color("#32384a") if not is_monochrome else Color("#454550")

var steel_highlight: Color:
	get: return Color("#4a546e") if not is_monochrome else Color("#60606c")

var wood_desk_color: Color:
	get: return Color("#523e2c") if not is_monochrome else Color("#38363a")

var chalkboard_color: Color:
	get: return Color("#263228") if not is_monochrome else Color("#222426")

var core_glow: Color:
	get:
		if is_destroyed: return Color("#2a2b34")
		if is_monochrome: return Color.WHITE
		return Color("#38d0f8")

var ink_color: Color = Color("#201c24")

func _process(delta: float) -> void:
	if not is_destroyed and show_machine:
		core_pulse_time += delta * 4.0
		queue_redraw()

func _draw() -> void:
	if show_machine:
		_draw_accelerator_machine(Vector2(180, -20))
	if show_desk:
		_draw_lab_desk(Vector2(0, 40))

func _draw_lab_desk(pos: Vector2) -> void:
	# Metal / wood scientist console desk
	# Desktop surface
	var top_pts := PackedVector2Array([
		pos + Vector2(-95, -20),
		pos + Vector2(95, -20),
		pos + Vector2(85, 0),
		pos + Vector2(-85, 0)
	])
	draw_colored_polygon(top_pts, steel_highlight)
	
	# Desk front body
	var front_pts := PackedVector2Array([
		pos + Vector2(-85, 0),
		pos + Vector2(85, 0),
		pos + Vector2(80, 50),
		pos + Vector2(-80, 50)
	])
	draw_colored_polygon(front_pts, steel_color)
	
	# Outlines
	var t_loop := PackedVector2Array()
	for p in top_pts: t_loop.append(p)
	t_loop.append(top_pts[0])
	CosmoInkStroke.from_points(t_loop, 2.8, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	var f_loop := PackedVector2Array()
	for p in front_pts: f_loop.append(p)
	f_loop.append(front_pts[0])
	CosmoInkStroke.from_points(f_loop, 2.8, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	# Data monitor screen on left of desk
	var screen_rect := Rect2(pos + Vector2(-75, -55), Vector2(46, 32))
	draw_rect(screen_rect, Color("#161a24"), true)
	draw_rect(screen_rect, ink_color, false, 2.0)
	# Glowing waveforms / orbit graphs on monitor
	if not is_destroyed:
		draw_line(pos + Vector2(-70, -40), pos + Vector2(-55, -46), Color("#42cbf5"), 1.8)
		draw_line(pos + Vector2(-55, -46), pos + Vector2(-40, -36), Color("#42cbf5"), 1.8)
	
	# Papers / blueprint scroll on right
	var paper_pts := PackedVector2Array([
		pos + Vector2(25, -16),
		pos + Vector2(70, -16),
		pos + Vector2(65, -4),
		pos + Vector2(20, -4)
	])
	draw_colored_polygon(paper_pts, Color("#ede8da"))
	var p_loop := PackedVector2Array()
	for p in paper_pts: p_loop.append(p)
	p_loop.append(paper_pts[0])
	draw_polyline(p_loop, ink_color, 1.4, true)

func _draw_accelerator_machine(pos: Vector2) -> void:
	# Heavy Temporal Machine Base
	var base_pts := PackedVector2Array([
		pos + Vector2(-55, 60),
		pos + Vector2(55, 60),
		pos + Vector2(45, 100),
		pos + Vector2(-45, 100)
	])
	draw_colored_polygon(base_pts, steel_color)
	var b_loop := PackedVector2Array()
	for p in base_pts: b_loop.append(p)
	b_loop.append(base_pts[0])
	CosmoInkStroke.from_points(b_loop, 3.2, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	# Vertical containment pylons (Left and Right)
	# Left Pylon
	var l_pylon := Rect2(pos + Vector2(-52, -70), Vector2(18, 130))
	draw_rect(l_pylon, steel_highlight, true)
	draw_rect(l_pylon, ink_color, false, 2.4)
	
	# Right Pylon
	var r_pylon := Rect2(pos + Vector2(34, -70), Vector2(18, 130))
	draw_rect(r_pylon, steel_highlight, true)
	draw_rect(r_pylon, ink_color, false, 2.4)
	
	# Top Cap Arch
	var arch_pts := PackedVector2Array([
		pos + Vector2(-56, -70),
		pos + Vector2(56, -70),
		pos + Vector2(44, -90),
		pos + Vector2(-44, -90)
	])
	draw_colored_polygon(arch_pts, steel_color)
	var a_loop := PackedVector2Array()
	for p in arch_pts: a_loop.append(p)
	a_loop.append(arch_pts[0])
	CosmoInkStroke.from_points(a_loop, 2.8, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	# Center Accelerator Power Core (Sphere at pos + Vector2(0, 0))
	var core_center := pos + Vector2(0, 0)
	var core_r := 28.0
	
	if not is_destroyed:
		# Glowing pulsating core sphere
		var pulse := sin(core_pulse_time) * 3.0
		var c_col := core_glow
		c_col.a = 0.35
		draw_circle(core_center, core_r + 8.0 + pulse, c_col)
		draw_circle(core_center, core_r, core_glow)
		draw_circle(core_center, core_r * 0.5, Color.WHITE)
		draw_arc(core_center, core_r, 0, TAU, 24, ink_color, 2.4, true)
		
		# Orbiting containment ring
		draw_arc(core_center, core_r * 1.3, -PI * 0.4, PI * 0.4, 16, Color("#f4c238"), 3.0, true)
		draw_arc(core_center, core_r * 1.3, PI * 0.6, PI * 1.4, 16, Color("#f4c238"), 3.0, true)
	else:
		# DESTROYED MACHINE (Act 11): Shattered glass, broken pylons, smoke
		# Shattered dark core
		draw_circle(core_center, core_r * 0.8, Color("#262832"))
		draw_arc(core_center, core_r * 0.8, 0, TAU, 16, ink_color, 2.4, true)
		
		# Fracture / impact crack lines
		draw_line(core_center + Vector2(-15, -18), core_center + Vector2(12, 14), Color.WHITE, 2.2)
		draw_line(core_center + Vector2(10, -20), core_center + Vector2(-8, 16), Color.WHITE, 2.0)
		draw_line(core_center + Vector2(-22, 0), core_center + Vector2(24, -4), Color.WHITE, 2.0)
		
		# Broken hanging wires
		draw_line(pos + Vector2(-34, -20), pos + Vector2(-20, 10), Color("#ff3355"), 2.2)
		draw_line(pos + Vector2(34, -15), pos + Vector2(18, 15), Color("#f4c238"), 2.2)
		
		# Smoke wisps
		var smk_col := Color(0.3, 0.3, 0.35, 0.6)
		draw_circle(core_center + Vector2(-14, -38), 12.0, smk_col)
		draw_circle(core_center + Vector2(8, -50), 16.0, smk_col)
		draw_circle(core_center + Vector2(2, -72), 10.0, smk_col)
