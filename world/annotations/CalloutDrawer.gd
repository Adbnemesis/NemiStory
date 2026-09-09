class_name CalloutDrawer
extends Node2D

## Live renderer for illustrated note/callout badges with tail pointing to a target

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")

var target: Node2D
var text: String = ""
var offset: Vector2 = Vector2(0, -100)
var style: RefCounted = WorldStyleScript.new()

var _font: Font = ThemeDB.fallback_font

func init_callout(p_target: Node2D, p_text: String, p_offset: Vector2, p_style: RefCounted) -> void:
	target = p_target
	text = p_text
	offset = p_offset
	style = p_style
	
	if is_instance_valid(target):
		global_position = target.global_position + offset
		
	# Pop in entry
	scale = Vector2(0.2, 0.2)
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "modulate:a", 1.0, 0.15)

func _process(_delta: float) -> void:
	if is_instance_valid(target):
		var dest := target.global_position + offset
		if global_position != dest:
			global_position = dest
			queue_redraw()

func _draw_stroke(p1: Vector2, p2: Vector2, width: float, col: Color) -> void:
	InkStroke.from_points(PackedVector2Array([p1, p2]), width, InkStroke.Profile.TAPER_BOTH, col).draw_to(self)

func _draw() -> void:
	var ink_col: Color = style.get_ink_color() if (style and style.has_method("get_ink_color")) else Color("#38101e")
	var paper_col: Color = style.get_paper_color() if (style and style.has_method("get_paper_color")) else Color("#faf7f5")
	
	var str_size := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
	var pad := Vector2(16, 10)
	var box_w: float = maxf(str_size.x + pad.x * 2.0, 70.0)
	var box_h: float = str_size.y + pad.y * 2.0
	
	var r_top_left := Vector2(-box_w * 0.5, -box_h * 0.5)
	var rect := Rect2(r_top_left, Vector2(box_w, box_h))
	
	# Background fill
	draw_rect(rect, paper_col)
	
	# Ink border
	var p1 := r_top_left
	var p2 := r_top_left + Vector2(box_w, 0)
	var p3 := r_top_left + Vector2(box_w, box_h)
	var p4 := r_top_left + Vector2(0, box_h)
	
	_draw_stroke(p1 + Vector2(-2, 0), p2 + Vector2(2, 0), 2.6, ink_col)
	_draw_stroke(p2 + Vector2(0, -2), p3 + Vector2(0, 2), 2.4, ink_col)
	_draw_stroke(p3 + Vector2(2, 0), p4 + Vector2(-2, 0), 2.5, ink_col)
	_draw_stroke(p4 + Vector2(0, 2), p1 + Vector2(0, -2), 2.4, ink_col)
	
	# Callout tail pointing to origin (towards target)
	var tail_base1 := Vector2(-8, box_h * 0.5)
	var tail_base2 := Vector2(8, box_h * 0.5)
	var tail_tip := Vector2(0, box_h * 0.5 + 16)
	
	var poly := PackedVector2Array([tail_base1, tail_base2, tail_tip])
	draw_colored_polygon(poly, paper_col)
	_draw_stroke(tail_base1, tail_tip, 2.4, ink_col)
	_draw_stroke(tail_base2, tail_tip, 2.4, ink_col)
	
	# Text inside
	var text_pos := Vector2(-str_size.x * 0.5, str_size.y * 0.3)
	draw_string(_font, text_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, ink_col)
