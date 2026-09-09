class_name NemiProp
extends Node2D

## Base Class for All Illustrated Storytime Props in NEMI's World
## Follows the core visual philosophy:
## - Organic hand-drawn silhouettes (never mathematically sterile primitives)
## - Shared master ink lines and restrained palette via WorldStyle
## - Live transformation primitives (pop in, slide, shake, drop, bounce)
## - Reusable hand attachment system to link with Nemi's live rig

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")

signal state_changed(new_state: String)
signal detached

@export var prop_name: String = "prop"
@export var current_state: String = "normal"

var style: RefCounted = WorldStyleScript.new()
var _attached_target: Node2D = null
var _attached_offset: Vector2 = Vector2.ZERO
var _attached_rot: float = 0.0
var _active_tween: Tween

func _ready() -> void:
	if style and style.has_signal("style_changed") and not style.style_changed.is_connected(queue_redraw):
		style.style_changed.connect(queue_redraw)

func _process(_delta: float) -> void:
	# If attached to a moving rig bone/visual, follow its global transform
	if _attached_target and is_instance_valid(_attached_target):
		global_position = _attached_target.global_position + _attached_offset.rotated(_attached_target.global_rotation)
		global_rotation = _attached_target.global_rotation + _attached_rot

func set_style(p_style: RefCounted) -> void:
	style = p_style
	if style and style.has_signal("style_changed") and not style.style_changed.is_connected(queue_redraw):
		style.style_changed.connect(queue_redraw)
	queue_redraw()

func set_prop_state(new_state: String) -> void:
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)
		queue_redraw()

# -------------------------------------------------------------------------
# ATTACHMENT SYSTEM
# -------------------------------------------------------------------------

## Attaches this prop to a target node (e.g. Nemi's right_hand_visual or bone)
func attach_to(target_node: Node2D, offset: Vector2 = Vector2.ZERO, rotation_deg: float = 0.0) -> void:
	_attached_target = target_node
	_attached_offset = offset
	_attached_rot = deg_to_rad(rotation_deg)
	if _attached_target and is_instance_valid(_attached_target):
		global_position = _attached_target.global_position + _attached_offset.rotated(_attached_target.global_rotation)
		global_rotation = _attached_target.global_rotation + _attached_rot

## Detaches prop from target and leaves it resting at specified or current position
func detach(world_pos: Vector2 = Vector2.INF) -> void:
	var final_pos := global_position if world_pos == Vector2.INF else world_pos
	_attached_target = null
	global_position = final_pos
	detached.emit()

func is_attached() -> bool:
	return _attached_target != null and is_instance_valid(_attached_target)

# -------------------------------------------------------------------------
# LIVE TRANSFORMATION PRIMITIVES
# -------------------------------------------------------------------------

## Snappy pop in with subtle illustrated overshoot
func pop_in(duration: float = 0.20) -> Signal:
	scale = Vector2.ZERO
	visible = true
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "scale", Vector2(1.15, 1.15), duration * 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "scale", Vector2.ONE, duration * 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return _active_tween.finished

## Snappy pop out
func pop_out(duration: float = 0.15) -> Signal:
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "scale", Vector2(1.1, 1.1), duration * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "scale", Vector2.ZERO, duration * 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_active_tween.tween_callback(func(): visible = false; scale = Vector2.ONE)
	return _active_tween.finished

## Slide to target position
func slide_to(target_pos: Vector2, duration: float = 0.25) -> Signal:
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "position", target_pos, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return _active_tween.finished

## Illustrated comedic shake / rattle
func shake(intensity: float = 0.5, duration: float = 0.20) -> Signal:
	var orig_pos := position
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	var steps := 4
	var step_time := duration / float(steps * 2)
	for i in range(steps):
		var offset := Vector2(randf_range(-6.0, 6.0), randf_range(-4.0, 4.0)) * intensity
		_active_tween.tween_property(self, "position", orig_pos + offset, step_time)
		_active_tween.tween_property(self, "position", orig_pos, step_time)
	return _active_tween.finished

## Illustrated bounce in place
func bounce(height: float = 16.0, duration: float = 0.25) -> Signal:
	var orig_y := position.y
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "position:y", orig_y - height, duration * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "position:y", orig_y, duration * 0.55).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	return _active_tween.finished

## Illustrated comedic drop (e.g. dropped phone / object)
func drop(distance: float = 45.0, duration: float = 0.22) -> Signal:
	var orig_y := position.y
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "position:y", orig_y + distance, duration * 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_active_tween.tween_property(self, "rotation", deg_to_rad(randf_range(-18.0, 18.0)), duration * 0.65)
	# Little ground rebound
	_active_tween.tween_property(self, "position:y", orig_y + distance - 6.0, duration * 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "position:y", orig_y + distance, duration * 0.17).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	return _active_tween.finished

# -------------------------------------------------------------------------
# ILLUSTRATION DRAWING UTILITIES
# -------------------------------------------------------------------------

## Helper to draw an organic filled polygon with an outer InkStroke outline
func draw_illustrated_polygon(pts: PackedVector2Array, fill_color: Color, outline_width: float = 2.0) -> void:
	if pts.size() < 3: return
	draw_colored_polygon(pts, fill_color)
	var stroke_pts := pts.duplicate()
	stroke_pts.append(pts[0]) # close outline
	var stroke := InkStroke.from_points(stroke_pts, outline_width, InkStroke.Profile.UNIFORM, style.ink_line_color)
	stroke.draw_to(self)

## Helper to draw a single tapered or uniform stroke
func draw_ink_line(pts: PackedVector2Array, width: float = 1.8, profile: InkStroke.Profile = InkStroke.Profile.UNIFORM) -> void:
	if pts.size() < 2: return
	var stroke := InkStroke.from_points(pts, width, profile, style.ink_line_color)
	stroke.draw_to(self)
