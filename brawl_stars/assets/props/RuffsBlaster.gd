class_name RuffsBlaster
extends Node2D

## Double-Barrel Laser Blaster Prop for COLONEL RUFFS (Brawl Stars)
## 100% Native 2D Hand-drawn illustrated sidearm:
## - Twin parallel barrels firing signature ricochet laser beams (Cyan & Red/Magenta)
## - Deep navy officer casing with gold military accents and cream grip
## - Dynamic muzzle flash, parallel laser tracer arcs, and wall-bounce visualizers
## - ArtMode monochrome ink-wash support

const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var is_firing: bool = false:
	set(val):
		is_firing = val
		queue_redraw()

var is_monochrome: bool = false:
	set(val):
		is_monochrome = val
		queue_redraw()

var aim_angle: float = 0.0:
	set(val):
		aim_angle = val
		rotation = aim_angle

# Colors
var casing_color: Color:
	get: return Color("#1e2844") if not is_monochrome else Color("#383840")

var casing_highlight: Color:
	get: return Color("#34466d") if not is_monochrome else Color("#555560")

var gold_accent: Color:
	get: return Color("#f6c33a") if not is_monochrome else Color("#cccccc")

var grip_cream: Color:
	get: return Color("#ede0cb") if not is_monochrome else Color("#dddddd")

var laser_cyan: Color:
	get: return Color("#3fe5ff") if not is_monochrome else Color("#ffffff")

var laser_red: Color:
	get: return Color("#ff3366") if not is_monochrome else Color("#999999")

var ink_color: Color:
	get: return Color("#201c24")

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Main Blaster Assembly (Grip origin at (0, 0), barrels pointing left/forward (-X))
	_draw_grip()
	_draw_receiver()
	_draw_twin_barrels()
	
	if is_firing:
		_draw_muzzle_flash_and_lasers()

func _draw_grip() -> void:
	# Angled handle/grip
	var grip_pts := PackedVector2Array([
		Vector2(-4, 0),
		Vector2(10, 0),
		Vector2(16, 26),
		Vector2(2, 28)
	])
	draw_colored_polygon(grip_pts, grip_cream)
	var g_loop := PackedVector2Array()
	for p in grip_pts: g_loop.append(p)
	g_loop.append(grip_pts[0])
	CosmoInkStroke.from_points(g_loop, 3.0, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	# Grip pommel cap (Gold)
	var pommel_pts := PackedVector2Array([
		Vector2(0, 26),
		Vector2(18, 24),
		Vector2(20, 32),
		Vector2(2, 34)
	])
	draw_colored_polygon(pommel_pts, gold_accent)
	var p_loop := PackedVector2Array()
	for p in pommel_pts: p_loop.append(p)
	p_loop.append(pommel_pts[0])
	CosmoInkStroke.from_points(p_loop, 2.5, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)

func _draw_receiver() -> void:
	# Main casing body
	var body_pts := PackedVector2Array([
		Vector2(-24, -14),
		Vector2(12, -14),
		Vector2(14, 2),
		Vector2(-20, 4)
	])
	draw_colored_polygon(body_pts, casing_color)
	
	# Gold military trim stripe
	var stripe_pts := PackedVector2Array([
		Vector2(-6, -14),
		Vector2(2, -14),
		Vector2(4, 2),
		Vector2(-4, 2)
	])
	draw_colored_polygon(stripe_pts, gold_accent)
	
	var b_loop := PackedVector2Array()
	for p in body_pts: b_loop.append(p)
	b_loop.append(body_pts[0])
	CosmoInkStroke.from_points(b_loop, 3.5, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)

func _draw_twin_barrels() -> void:
	# Upper Barrel (Red Laser)
	var b1_pts := PackedVector2Array([
		Vector2(-48, -13),
		Vector2(-24, -13),
		Vector2(-24, -6),
		Vector2(-48, -6)
	])
	draw_colored_polygon(b1_pts, casing_highlight)
	var b1_loop := PackedVector2Array()
	for p in b1_pts: b1_loop.append(p)
	b1_loop.append(b1_pts[0])
	CosmoInkStroke.from_points(b1_loop, 2.8, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	# Muzzle emitter ring 1
	draw_circle(Vector2(-48, -9.5), 3.5, laser_red)
	
	# Lower Barrel (Cyan Laser)
	var b2_pts := PackedVector2Array([
		Vector2(-48, -4),
		Vector2(-24, -4),
		Vector2(-24, 3),
		Vector2(-48, 3)
	])
	draw_colored_polygon(b2_pts, casing_highlight)
	var b2_loop := PackedVector2Array()
	for p in b2_pts: b2_loop.append(p)
	b2_loop.append(b2_pts[0])
	CosmoInkStroke.from_points(b2_loop, 2.8, CosmoInkStroke.Profile.UNIFORM, ink_color).draw_to(self)
	
	# Muzzle emitter ring 2
	draw_circle(Vector2(-48, -0.5), 3.5, laser_cyan)

func _draw_muzzle_flash_and_lasers() -> void:
	# Burst flashes at barrel tips
	draw_circle(Vector2(-52, -9.5), 8.0, laser_red)
	draw_circle(Vector2(-52, -9.5), 4.0, Color.WHITE)
	
	draw_circle(Vector2(-52, -0.5), 8.0, laser_cyan)
	draw_circle(Vector2(-52, -0.5), 4.0, Color.WHITE)
	
	# Parallel Laser Beams extending forward
	# Red Laser (top)
	draw_line(Vector2(-54, -9.5), Vector2(-160, -9.5), laser_red, 5.0)
	draw_line(Vector2(-54, -9.5), Vector2(-160, -9.5), Color.WHITE, 2.0)
	
	# Cyan Laser (bottom)
	draw_line(Vector2(-54, -0.5), Vector2(-160, -0.5), laser_cyan, 5.0)
	draw_line(Vector2(-54, -0.5), Vector2(-160, -0.5), Color.WHITE, 2.0)
