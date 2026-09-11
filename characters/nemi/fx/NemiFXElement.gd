class_name NemiFXElement
extends Node2D

## Base class for live Godot procedural expression & reaction FX elements.
## 100% vector / path / calligraphic drawing with zero raster images or sprite sheets.
## Follows Nemi's anchor points, supports intensity scaling (1-5), draw-on / draw-off,
## and hand-drawn pen stroke aesthetics matching NemiStyle.

signal dismissed()

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const NemiFXAnchor = preload("res://characters/nemi/fx/NemiFXAnchor.gd")

enum EntranceStyle {
	POP,        # Quick pop-in with slight squash/stretch bounce settle
	DRAW_ON,    # Line draws progressively from 0% to 100% like real ink
	SNAP,       # 1-frame sudden comic cut-in
	FADE,       # Alpha ramp
	SLIDE,      # Slight directional slide-in
	BOUNCE      # Overshoot and spring
}

enum ExitStyle {
	FADE,       # Alpha fade out
	ERASE,      # Line un-draws backwards or wipes like eraser stroke
	SNAP,       # Immediate disappear
	SHRINK,     # Scale down to zero
	DISSOLVE    # Scatter/fade out
}

# Configuration
@export var intensity: int = 3: # 1=subtle, 2=mild, 3=normal, 4=strong, 5=exaggerated
	set(val):
		intensity = clampi(val, 1, 5)
		queue_redraw()

@export var draw_progress: float = 1.0: # 0.0 to 1.0 for draw-on animation
	set(val):
		draw_progress = clampf(val, 0.0, 1.0)
		queue_redraw()

@export var erase_progress: float = 0.0: # 0.0 to 1.0 for hand-drawn erase
	set(val):
		erase_progress = clampf(val, 0.0, 1.0)
		queue_redraw()

@export var entrance_style: EntranceStyle = EntranceStyle.POP
@export var exit_style: ExitStyle = ExitStyle.FADE
@export var auto_dismiss_time: float = 1.2 # Auto cleanup after duration; <= 0 for persistent

# Follow & anchoring
var anchor_type: NemiFXAnchor.AnchorType = NemiFXAnchor.AnchorType.HEAD_TOP
var anchor_node: Node2D = null
var anchor_offset: Vector2 = Vector2.ZERO
var follow_anchor: bool = true
var is_dismissing: bool = false

# Palette & Style
var ink_color: Color = Color("#3e081e") # Master burgundy inking
var accent_color: Color = Color("#e67e22") # Vivid comic accent
var fill_color: Color = Color("#fff8cc") # Soft warm tint
var is_monochrome: bool = false

# Internal state
var _lifetime_timer: float = 0.0
var _anim_tween: Tween
var _base_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	z_index = 25
	_base_scale = scale
	_update_anchor_position()
	play_entrance()

func _process(delta: float) -> void:
	if follow_anchor and is_instance_valid(anchor_node) and not is_dismissing:
		_update_anchor_position()
	
	if auto_dismiss_time > 0.0 and not is_dismissing:
		_lifetime_timer += delta
		if _lifetime_timer >= auto_dismiss_time:
			dismiss()

func _update_anchor_position() -> void:
	if is_instance_valid(anchor_node) and anchor_node.is_inside_tree():
		global_position = anchor_node.global_transform * anchor_offset
	elif get_parent() and not anchor_node:
		position = anchor_offset

## Sets up anchoring to a specific character and landmark
func mount_to_anchor(character: Node2D, p_anchor_type: NemiFXAnchor.AnchorType, custom_offset: Vector2 = Vector2.ZERO) -> void:
	anchor_type = p_anchor_type
	anchor_node = NemiFXAnchor.get_anchor_node(character, anchor_type)
	anchor_offset = NemiFXAnchor.get_local_offset(anchor_type) + custom_offset
	follow_anchor = true
	_update_anchor_position()

## Sets color palette (synced with NemiStyle mode)
func set_palette(p_ink: Color, p_accent: Color, p_fill: Color, p_monochrome: bool = false) -> void:
	ink_color = p_ink
	accent_color = p_accent if not p_monochrome else p_ink
	fill_color = p_fill if not p_monochrome else Color(0.95, 0.95, 0.95, 0.8)
	is_monochrome = p_monochrome
	queue_redraw()

## Plays the configured entrance animation
func play_entrance(duration: float = 0.25) -> void:
	if _anim_tween and _anim_tween.is_valid():
		_anim_tween.kill()
	
	if entrance_style == EntranceStyle.SNAP:
		scale = _base_scale
		modulate.a = 1.0
		draw_progress = 1.0
		return
	
	_anim_tween = create_tween().set_parallel(true)
	
	match entrance_style:
		EntranceStyle.POP:
			scale = _base_scale * 0.1
			modulate.a = 1.0
			draw_progress = 1.0
			_anim_tween.tween_property(self, "scale", _base_scale * 1.18, duration * 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			_anim_tween.chain().tween_property(self, "scale", _base_scale, duration * 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		EntranceStyle.DRAW_ON:
			scale = _base_scale
			modulate.a = 1.0
			draw_progress = 0.0
			_anim_tween.tween_property(self, "draw_progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		EntranceStyle.FADE:
			scale = _base_scale
			modulate.a = 0.0
			draw_progress = 1.0
			_anim_tween.tween_property(self, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		EntranceStyle.SLIDE:
			var start_pos := position + Vector2(0, 16)
			position = start_pos
			modulate.a = 0.0
			draw_progress = 1.0
			_anim_tween.tween_property(self, "position", position - Vector2(0, 16), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			_anim_tween.tween_property(self, "modulate:a", 1.0, duration * 0.5)
		
		EntranceStyle.BOUNCE:
			scale = _base_scale * 0.0
			modulate.a = 1.0
			draw_progress = 1.0
			_anim_tween.tween_property(self, "scale", _base_scale * 1.35, duration * 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			_anim_tween.chain().tween_property(self, "scale", _base_scale, duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## Triggers smooth dismiss and cleanup
func dismiss(duration: float = 0.22) -> void:
	if is_dismissing:
		return
	is_dismissing = true
	
	if _anim_tween and _anim_tween.is_valid():
		_anim_tween.kill()
	
	if exit_style == ExitStyle.SNAP:
		modulate.a = 0.0
		dismissed.emit()
		queue_free()
		return
	
	_anim_tween = create_tween()
	
	match exit_style:
		ExitStyle.FADE:
			_anim_tween.tween_property(self, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
		ExitStyle.ERASE:
			_anim_tween.tween_property(self, "erase_progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			_anim_tween.parallel().tween_property(self, "modulate:a", 0.0, duration * 1.2)
		
		ExitStyle.SHRINK:
			_anim_tween.tween_property(self, "scale", Vector2.ZERO, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			_anim_tween.parallel().tween_property(self, "modulate:a", 0.0, duration * 0.8)
		
		ExitStyle.DISSOLVE:
			_anim_tween.tween_property(self, "scale", _base_scale * 1.25, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_anim_tween.parallel().tween_property(self, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	_anim_tween.chain().tween_callback(func():
		dismissed.emit()
		queue_free()
	)

## Helper: Progressive calligraphic stroke drawing from points
func draw_ink_stroke(canvas: CanvasItem, pts: PackedVector2Array, width: float, profile: int = 1, col: Color = Color.TRANSPARENT) -> void:
	if pts.size() < 2:
		return
	var stroke_col := col if col.a > 0.0 else ink_color
	
	# Apply draw_progress and erase_progress
	var start_t := erase_progress
	var end_t := draw_progress
	if end_t <= start_t or end_t <= 0.001:
		return
	
	var effective_pts := pts
	if start_t > 0.0 or end_t < 1.0:
		effective_pts = _slice_points(pts, start_t, end_t)
	
	if effective_pts.size() >= 2:
		var stroke = InkStroke.from_points(effective_pts, width, profile, stroke_col)
		stroke.draw_to(canvas)

## Helper: Progressive calligraphic curve drawing
func draw_ink_curve(canvas: CanvasItem, curve: Curve2D, width: float, profile: int = 1, col: Color = Color.TRANSPARENT, max_stages: int = 4) -> void:
	var tess_pts := curve.tessellate(max_stages, 2.5)
	draw_ink_stroke(canvas, tess_pts, width, profile, col)

func _slice_points(pts: PackedVector2Array, start_ratio: float, end_ratio: float) -> PackedVector2Array:
	var n := pts.size()
	if n < 2:
		return pts
	var start_idx := clampi(int(n * start_ratio), 0, n - 2)
	var end_idx := clampi(int(ceil(n * end_ratio)), start_idx + 1, n)
	var sliced := PackedVector2Array()
	for i in range(start_idx, end_idx):
		sliced.append(pts[i])
	return sliced
