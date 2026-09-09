class_name StoryEnvironment
extends Node2D

## Reusable Illustrated Background & Environment System for NEMI
## Follows the core visual philosophy:
## - Backgrounds support the story rather than compete with the character
## - Sparse, intentional linework and large areas of negative space
## - 4 distinct visual density levels (0 = minimal to 3 = detailed)
## - 100% vector Godot drawing with instant COLOR / MONOCHROME mode switching

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")

enum EnvType {
	NEUTRAL,
	BEDROOM,
	WORKSPACE,
	LIVING_ROOM,
	STREET
}

# Compatibility alias
const EnvironmentType = EnvType

enum Density {
	LEVEL_0_MINIMAL,  # Plain negative space only
	LEVEL_1_SPARSE,   # Horizon line & ground boundary
	LEVEL_2_NORMAL,   # Simplified structural furniture
	LEVEL_3_DETAILED  # Full room accents
}

@export var environment_type: EnvType = EnvType.NEUTRAL
@export var density: int = 2

var style: RefCounted = WorldStyleScript.new()
var canvas_size: Vector2 = Vector2(1280, 720)
var floor_y: float = 640.0

func _ready() -> void:
	if style and style.has_signal("style_changed") and not style.style_changed.is_connected(queue_redraw):
		style.style_changed.connect(queue_redraw)

func set_style(p_style: RefCounted) -> void:
	style = p_style
	if style and style.has_signal("style_changed") and not style.style_changed.is_connected(queue_redraw):
		style.style_changed.connect(queue_redraw)
	queue_redraw()

func set_environment(type: EnvType, p_density: Density = Density.LEVEL_2_NORMAL) -> void:
	environment_type = type
	density = p_density
	queue_redraw()

func set_density(p_density: Density) -> void:
	density = p_density
	queue_redraw()

func _draw() -> void:
	# 1. Base paper canvas fill (always present)
	draw_rect(Rect2(Vector2.ZERO, canvas_size), style.paper_bg_color)
	
	if density == Density.LEVEL_0_MINIMAL:
		return # Level 0: pure negative space
	
	# 2. Level 1: Horizon / Floor ground boundary
	_draw_floor_line()
	
	if density == Density.LEVEL_1_SPARSE:
		return
	
	# 3. Level 2 & 3: Environment-specific illustrated structures
	match environment_type:
		EnvType.NEUTRAL:
			pass # Clean floor line is sufficient
		EnvType.BEDROOM:
			_draw_bedroom()
		EnvType.WORKSPACE:
			_draw_workspace()
		EnvType.LIVING_ROOM:
			_draw_living_room()
		EnvType.STREET:
			_draw_street()

func _draw_floor_line() -> void:
	var floor_pts := PackedVector2Array([Vector2(40.0, floor_y), Vector2(canvas_size.x - 40.0, floor_y)])
	draw_polyline(floor_pts, style.floor_line_color, 2.0)

# -------------------------------------------------------------------------
# BEDROOM ENVIRONMENT
# -------------------------------------------------------------------------
func _draw_bedroom() -> void:
	# Bed frame on left side
	var bed_w := 240.0
	var bed_h := 70.0
	var bed_top := floor_y - bed_h
	
	# Headboard
	var hb_pts := PackedVector2Array([
		Vector2(60.0, bed_top - 40.0),
		Vector2(90.0, bed_top - 40.0),
		Vector2(90.0, floor_y),
		Vector2(60.0, floor_y)
	])
	_draw_env_polygon(hb_pts, style.wood_shadow, style.structural_width)
	
	# Mattress & duvet
	var bed_pts := PackedVector2Array([
		Vector2(90.0, bed_top),
		Vector2(90.0 + bed_w, bed_top),
		Vector2(90.0 + bed_w, floor_y),
		Vector2(90.0, floor_y)
	])
	_draw_env_polygon(bed_pts, style.accent_mint_shadow, style.outer_contour_width)
	
	# Pillow
	var pillow_pts := PackedVector2Array([
		Vector2(100.0, bed_top - 20.0),
		Vector2(160.0, bed_top - 20.0),
		Vector2(165.0, bed_top),
		Vector2(95.0, bed_top)
	])
	_draw_env_polygon(pillow_pts, style.metal_light, style.structural_width)
	
	if density >= Density.LEVEL_3_DETAILED:
		# Wall window on right
		var win_x := canvas_size.x - 260.0
		var win_y := 160.0
		var win_w := 140.0
		var win_h := 180.0
		var win_pts := PackedVector2Array([
			Vector2(win_x, win_y), Vector2(win_x + win_w, win_y),
			Vector2(win_x + win_w, win_y + win_h), Vector2(win_x, win_y + win_h)
		])
		_draw_env_polygon(win_pts, style.screen_glow, style.structural_width)
		# Window cross panes
		_draw_env_line(PackedVector2Array([Vector2(win_x + win_w * 0.5, win_y), Vector2(win_x + win_w * 0.5, win_y + win_h)]), style.inner_line_width)
		_draw_env_line(PackedVector2Array([Vector2(win_x, win_y + win_h * 0.45), Vector2(win_x + win_w, win_y + win_h * 0.45)]), style.inner_line_width)
		
		# Wall art frame above bed
		var art_pts := PackedVector2Array([
			Vector2(120.0, 200.0), Vector2(220.0, 200.0),
			Vector2(220.0, 300.0), Vector2(120.0, 300.0)
		])
		_draw_env_polygon(art_pts, style.wood_surface, style.structural_width)

# -------------------------------------------------------------------------
# WORKSPACE ENVIRONMENT
# -------------------------------------------------------------------------
func _draw_workspace() -> void:
	# Wall bookshelf on left
	var shelf_y := 240.0
	_draw_env_polygon(PackedVector2Array([
		Vector2(80.0, shelf_y), Vector2(300.0, shelf_y),
		Vector2(300.0, shelf_y + 10.0), Vector2(80.0, shelf_y + 10.0)
	]), style.wood_shadow, style.structural_width)
	
	# Illustrated books on shelf
	var book_colors := [style.accent_rose, style.accent_blue, style.accent_mint, style.accent_yellow]
	for i in range(4):
		var bx := 100.0 + float(i) * 22.0
		var bh := randf_range(30.0, 48.0)
		_draw_env_polygon(PackedVector2Array([
			Vector2(bx, shelf_y - bh), Vector2(bx + 18.0, shelf_y - bh),
			Vector2(bx + 18.0, shelf_y), Vector2(bx, shelf_y)
		]), book_colors[i], style.inner_line_width)
	
	if density >= Density.LEVEL_3_DETAILED:
		# Bulletin / memo board on right
		var b_pts := PackedVector2Array([
			Vector2(canvas_size.x - 320.0, 200.0), Vector2(canvas_size.x - 120.0, 200.0),
			Vector2(canvas_size.x - 120.0, 380.0), Vector2(canvas_size.x - 320.0, 380.0)
		])
		_draw_env_polygon(b_pts, style.wood_surface, style.structural_width)
		# Sticky notes
		_draw_env_polygon(PackedVector2Array([
			Vector2(canvas_size.x - 290.0, 230.0), Vector2(canvas_size.x - 250.0, 230.0),
			Vector2(canvas_size.x - 250.0, 270.0), Vector2(canvas_size.x - 290.0, 270.0)
		]), style.accent_yellow, style.detail_line_width)
		_draw_env_polygon(PackedVector2Array([
			Vector2(canvas_size.x - 220.0, 250.0), Vector2(canvas_size.x - 170.0, 250.0),
			Vector2(canvas_size.x - 170.0, 300.0), Vector2(canvas_size.x - 220.0, 300.0)
		]), style.accent_rose, style.detail_line_width)

# -------------------------------------------------------------------------
# LIVING ROOM ENVIRONMENT
# -------------------------------------------------------------------------
func _draw_living_room() -> void:
	# Sofa silhouette on left
	var sofa_w := 280.0
	var sofa_h := 90.0
	var sofa_top := floor_y - sofa_h
	
	# Sofa back
	_draw_env_polygon(PackedVector2Array([
		Vector2(60.0, sofa_top - 40.0), Vector2(60.0 + sofa_w, sofa_top - 40.0),
		Vector2(60.0 + sofa_w, floor_y), Vector2(60.0, floor_y)
	]), style.accent_mint_shadow, style.outer_contour_width)
	
	# Sofa seat cushions
	_draw_env_polygon(PackedVector2Array([
		Vector2(60.0, sofa_top), Vector2(60.0 + sofa_w, sofa_top),
		Vector2(60.0 + sofa_w, floor_y - 20.0), Vector2(60.0, floor_y - 20.0)
	]), style.accent_mint, style.structural_width)
	
	if density >= Density.LEVEL_3_DETAILED:
		# Potted plant on right
		var pot_x := canvas_size.x - 180.0
		# Pot
		_draw_env_polygon(PackedVector2Array([
			Vector2(pot_x - 25.0, floor_y - 50.0), Vector2(pot_x + 25.0, floor_y - 50.0),
			Vector2(pot_x + 18.0, floor_y), Vector2(pot_x - 18.0, floor_y)
		]), style.plant_pot, style.structural_width)
		# Plant leaves
		_draw_env_line(PackedVector2Array([Vector2(pot_x, floor_y - 50.0), Vector2(pot_x - 30.0, floor_y - 110.0)]), style.structural_width)
		_draw_env_line(PackedVector2Array([Vector2(pot_x, floor_y - 50.0), Vector2(pot_x + 35.0, floor_y - 120.0)]), style.structural_width)
		_draw_env_line(PackedVector2Array([Vector2(pot_x, floor_y - 50.0), Vector2(pot_x + 5.0, floor_y - 135.0)]), style.structural_width)

# -------------------------------------------------------------------------
# STREET / OUTSIDE ENVIRONMENT
# -------------------------------------------------------------------------
func _draw_street() -> void:
	# Sidewalk curb line
	var curb_y := floor_y - 20.0
	_draw_env_line(PackedVector2Array([Vector2(40.0, curb_y), Vector2(canvas_size.x - 40.0, curb_y)]), style.structural_width)
	
	# Streetlight on right
	var light_x := canvas_size.x - 200.0
	_draw_env_line(PackedVector2Array([Vector2(light_x, floor_y), Vector2(light_x, 180.0)]), style.structural_width)
	# Streetlight arched arm & lantern
	var arm_pts := PackedVector2Array([
		Vector2(light_x, 190.0), Vector2(light_x - 25.0, 160.0), Vector2(light_x - 45.0, 180.0)
	])
	_draw_env_line(arm_pts, style.structural_width)
	_draw_env_polygon(PackedVector2Array([
		Vector2(light_x - 52.0, 180.0), Vector2(light_x - 38.0, 180.0),
		Vector2(light_x - 40.0, 195.0), Vector2(light_x - 50.0, 195.0)
	]), style.accent_yellow, style.inner_line_width)
	
	if density >= Density.LEVEL_3_DETAILED:
		# Distant illustrated cloud contours in sky
		_draw_cloud(Vector2(250.0, 140.0), 90.0)
		_draw_cloud(Vector2(650.0, 110.0), 120.0)

func _draw_cloud(pos: Vector2, width: float) -> void:
	var cloud_col := Color(style.ink_line_color.r, style.ink_line_color.g, style.ink_line_color.b, 0.25)
	var curve := Curve2D.new()
	curve.add_point(pos)
	curve.add_point(pos + Vector2(width * 0.35, -18.0), Vector2(-15.0, 0.0), Vector2(15.0, 0.0))
	curve.add_point(pos + Vector2(width * 0.70, -22.0), Vector2(-18.0, 0.0), Vector2(18.0, 0.0))
	curve.add_point(pos + Vector2(width, 0.0))
	var stroke := InkStroke.from_curve(curve, 1.4, InkStroke.Profile.TAPER_BOTH, cloud_col)
	stroke.draw_to(self)

# -------------------------------------------------------------------------
# DRAWING HELPERS
# -------------------------------------------------------------------------
func _draw_env_polygon(pts: PackedVector2Array, fill_color: Color, outline_width: float = 2.0) -> void:
	if pts.size() < 3: return
	draw_colored_polygon(pts, fill_color)
	var stroke_pts := pts.duplicate()
	stroke_pts.append(pts[0])
	var stroke := InkStroke.from_points(stroke_pts, outline_width, InkStroke.Profile.UNIFORM, style.ink_line_color)
	stroke.draw_to(self)

func _draw_env_line(pts: PackedVector2Array, width: float = 1.8) -> void:
	if pts.size() < 2: return
	var stroke := InkStroke.from_points(pts, width, InkStroke.Profile.UNIFORM, style.ink_line_color)
	stroke.draw_to(self)
