class_name WorldAnnotation
extends Node2D

## Visual Storytelling & Annotation System
## Provides director tools for guiding viewer focus in the illustrated video style:
## Hand-drawn highlights, arrows tracking objects, callout notes, and selective background dimming.

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")
const DoodleInstanceScript = preload("res://world/doodles/DoodleInstance.gd")

enum HighlightStyle {
	BOX,
	CIRCLE,
	UNDERLINE,
	BRACKETS
}

var style: RefCounted = WorldStyleScript.new()

# Active annotation tracking
var _dim_rect: ColorRect
var _active_annotations: Array[Node2D] = []

func _ready() -> void:
	z_index = 25 # Between props (20) and top doodles (30)
	
	# Create background dimming overlay (Z-indexed below annotations)
	_dim_rect = ColorRect.new()
	_dim_rect.name = "BackgroundDimmer"
	_dim_rect.color = Color(0.08, 0.04, 0.06, 0.0) # Soft dark/ink tint
	_dim_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim_rect.z_index = -5 # Just below annotations
	_dim_rect.visible = false
	_dim_rect.size = Vector2(3840, 2160)
	_dim_rect.position = Vector2(-1920, -1080)
	add_child(_dim_rect)

func set_style(p_style: RefCounted) -> void:
	style = p_style
	queue_redraw()

# -------------------------------------------------------------------------
# DIRECTING FOCUS TOOLS
# -------------------------------------------------------------------------

## Dims everything behind the annotation layer to pop Nemi or a prop into extreme focus
func dim_background(dim_alpha: float = 0.45, duration: float = 0.25) -> Signal:
	_dim_rect.visible = true
	var target_color := Color(0.05, 0.02, 0.04, dim_alpha)
	var tw := create_tween()
	tw.tween_property(_dim_rect, "color", target_color, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return tw.finished

## Undims and hides the background dimming veil
func undim_background(duration: float = 0.2) -> Signal:
	var tw := create_tween()
	var clear_col := Color(0.05, 0.02, 0.04, 0.0)
	tw.tween_property(_dim_rect, "color", clear_col, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.finished.connect(func(): _dim_rect.visible = false)
	return tw.finished

## Highlight a target node with a hand-drawn box, oval, or brackets
func highlight(target: Node2D, padding: Vector2 = Vector2(24, 24), h_style: HighlightStyle = HighlightStyle.BOX) -> Node2D:
	var hl_node := Node2D.new()
	hl_node.name = "Highlight_" + str(target.name)
	add_child(hl_node)
	_active_annotations.append(hl_node)
	
	# Script for custom drawing
	hl_node.set_script(preload("res://world/annotations/HighlightDrawer.gd"))
	hl_node.init_highlight(target, padding, h_style, style)
	return hl_node

## Point an arrow to a target with optional text label
func point_arrow_to(target: Node2D, from_offset: Vector2 = Vector2(-120, -80), curved: bool = true) -> Node2D:
	var target_pos := target.global_position if is_instance_valid(target) else Vector2.ZERO
	var from_pos := target_pos + from_offset
	
	var doodle := DoodleInstanceScript.new()
	doodle.doodle_type = DoodleInstanceScript.Type.ARROW
	doodle.global_position = from_pos
	doodle.target_end = -from_offset
	doodle.is_curved = curved
	doodle.set_style(style)
	add_child(doodle)
	_active_annotations.append(doodle)
	doodle.draw_on(0.22)
	return doodle

## Add a callout tag note attached to a target
func add_callout(target: Node2D, text: String, offset: Vector2 = Vector2(0, -100)) -> Node2D:
	var callout := Node2D.new()
	callout.name = "Callout_" + str(target.name)
	add_child(callout)
	_active_annotations.append(callout)
	
	callout.set_script(preload("res://world/annotations/CalloutDrawer.gd"))
	callout.init_callout(target, text, offset, style)
	return callout

## Clear all active annotations with an optional quick pop-out animation
func clear_annotations(duration: float = 0.18) -> void:
	undim_background(duration)
	var to_clean := _active_annotations.duplicate()
	_active_annotations.clear()
	
	for node in to_clean:
		if is_instance_valid(node):
			if duration > 0.0:
				var tw := create_tween()
				tw.tween_property(node, "scale", Vector2(0.01, 0.01), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
				tw.parallel().tween_property(node, "modulate:a", 0.0, duration)
				tw.finished.connect(node.queue_free)
			else:
				node.queue_free()
