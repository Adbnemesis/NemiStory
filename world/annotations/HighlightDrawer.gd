class_name HighlightDrawer
extends Node2D

## Helper node for rendering live hand-drawn highlights around characters/props

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const WorldStyleScript = preload("res://world/style/WorldStyle.gd")

var target: Node2D
var padding: Vector2 = Vector2(24, 24)
var highlight_style: int = 0
var style: RefCounted = WorldStyleScript.new()
var progress: float = 0.0

func init_highlight(p_target: Node2D, p_padding: Vector2, p_style_type: int, p_style: RefCounted) -> void:
	target = p_target
	padding = p_padding
	highlight_style = p_style_type
	style = p_style
	
	if is_instance_valid(target):
		global_position = target.global_position
		
	# Draw-on entry tween
	progress = 0.0
	var tw := create_tween()
	tw.tween_property(self, "progress", 1.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2.ONE, 0.22).from(Vector2(0.85, 0.85))
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)

func _process(_delta: float) -> void:
	if is_instance_valid(target):
		if global_position != target.global_position:
			global_position = target.global_position
			queue_redraw()

func _draw_stroke(p1: Vector2, p2: Vector2, width: float, col: Color) -> void:
	InkStroke.from_points(PackedVector2Array([p1, p2]), width, InkStroke.Profile.TAPER_BOTH, col).draw_to(self)

func _draw() -> void:
	if progress <= 0.01:
		return
	
	var ink_col: Color = style.get_ink_color() if (style and style.has_method("get_ink_color")) else Color("#38101e")
	var is_color_mode: bool = style.is_color() if (style and style.has_method("is_color")) else true
	var fill_tint: Color = Color(1.0, 0.9, 0.3, 0.25) if is_color_mode else Color(1.0, 1.0, 1.0, 0.2)
	
	var w: float = padding.x * 2.0
	var h: float = padding.y * 2.0
	var rect := Rect2(-padding.x, -padding.y, w, h)
	
	match highlight_style:
		0: # BOX
			var p1 := Vector2(-padding.x, -padding.y)
			var p2 := Vector2(padding.x, -padding.y)
			var p3 := Vector2(padding.x, padding.y)
			var p4 := Vector2(-padding.x, padding.y)
			
			draw_rect(rect, fill_tint)
			
			var max_len := (w + h) * 2.0
			var current_len := max_len * progress
			
			if current_len > 0.0:
				var t_top := clampf(current_len / w, 0.0, 1.0)
				_draw_stroke(p1 + Vector2(-4, -2), p1 + Vector2(w * t_top + 4, -1), 2.8, ink_col)
			if current_len > w:
				var t_right := clampf((current_len - w) / h, 0.0, 1.0)
				_draw_stroke(p2 + Vector2(2, -4), p2 + Vector2(1, h * t_right + 4), 2.5, ink_col)
			if current_len > (w + h):
				var t_bot := clampf((current_len - (w + h)) / w, 0.0, 1.0)
				_draw_stroke(p3 + Vector2(4, 2), p3 - Vector2(w * t_bot + 4, -1), 2.8, ink_col)
			if current_len > (w * 2.0 + h):
				var t_left := clampf((current_len - (w * 2.0 + h)) / h, 0.0, 1.0)
				_draw_stroke(p4 + Vector2(-2, 4), p4 - Vector2(-1, h * t_left + 4), 2.5, ink_col)
				
		1: # CIRCLE / OVAL
			var r := maxf(padding.x, padding.y)
			draw_circle(Vector2.ZERO, r, fill_tint)
			var pts: PackedVector2Array = []
			var segments := 24
			var max_seg := int(float(segments) * progress)
			for i in range(max_seg + 1):
				var ang := (TAU / float(segments)) * float(i)
				var rad_jitter := r + sin(float(i) * 1.5) * 2.5
				pts.append(Vector2(cos(ang) * (rad_jitter + (padding.x - r) * 0.5), sin(ang) * (rad_jitter + (padding.y - r) * 0.5)))
			if pts.size() >= 2:
				InkStroke.from_points(pts, 2.8, InkStroke.Profile.TAPER_BOTH, ink_col).draw_to(self)
				
		2: # UNDERLINE
			var start := Vector2(-padding.x - 8, padding.y + 4)
			var end := Vector2(padding.x + 8, padding.y + 2)
			var cur_end := start.lerp(end, progress)
			_draw_stroke(start, cur_end, 3.4, ink_col)
			draw_line(start + Vector2(0, 4), cur_end + Vector2(0, 4), fill_tint, 8.0)
			
		3: # BRACKETS
			var b_w := padding.x
			var b_h := padding.y
			# Left bracket [
			_draw_stroke(Vector2(-b_w + 12, -b_h), Vector2(-b_w, -b_h), 2.8, ink_col)
			_draw_stroke(Vector2(-b_w, -b_h), Vector2(-b_w, b_h), 2.6, ink_col)
			_draw_stroke(Vector2(-b_w, b_h), Vector2(-b_w + 12, b_h), 2.4, ink_col)
			# Right bracket ]
			_draw_stroke(Vector2(b_w - 12, -b_h), Vector2(b_w, -b_h), 2.8, ink_col)
			_draw_stroke(Vector2(b_w, -b_h), Vector2(b_w, b_h), 2.6, ink_col)
			_draw_stroke(Vector2(b_w, b_h), Vector2(b_w - 12, b_h), 2.4, ink_col)
