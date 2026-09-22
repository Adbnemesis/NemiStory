class_name PikachuFace
extends Node2D

## Procedural facial acting system for PIKACHU
## Authentic anime expression vocabulary:
## - Round dark anime eyes with gaze tracking and specular keylights
## - Cat-like wavy upper lip and stylized viseme mouths
## - Iconic red electric cheek pouches with spark emission and blush states
## - Supports all 20 emotional expressions

const PokemonInkStroke = preload("res://pokemon/scripts/PokemonInkStroke.gd")
const PikachuStyle = preload("res://pokemon/characters/pikachu/PikachuStyle.gd")

var style: PikachuStyle

# Eye properties
var eye_openness: float = 1.0: # 0.0 = closed/blink, 1.0 = normal, 1.35 = shock
	set(val):
		eye_openness = clampf(val, 0.0, 1.5)
		queue_redraw()

var gaze_direction: Vector2 = Vector2.ZERO: # (-1 to 1)
	set(val):
		gaze_direction = val.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
		queue_redraw()

var eye_state: String = "normal": # "normal", "happy", "shock", "squint", "spiral", "sad", "angry", "deadpan"
	set(val):
		eye_state = val
		queue_redraw()

var mouth_shape: String = "cat": # "cat", "smile", "open_happy", "open_shout", "shock_o", "wavy", "deadpan", "frown", "grit"
	set(val):
		mouth_shape = val
		queue_redraw()

var mouth_openness: float = 0.0:
	set(val):
		mouth_openness = clampf(val, 0.0, 1.0)
		queue_redraw()

var is_sparking: bool = false:
	set(val):
		is_sparking = val
		queue_redraw()

var show_blush: bool = false:
	set(val):
		show_blush = val
		queue_redraw()

var show_sweat: bool = false:
	set(val):
		show_sweat = val
		queue_redraw()

var head_tilt: float = 0.0:
	set(val):
		head_tilt = val
		queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	draw_set_transform(Vector2.ZERO, head_tilt, Vector2.ONE)
	
	# 1. Red Cheek Pouches (Left & Right)
	_draw_cheeks()
	
	# 2. Nose (Tiny delicate dark point)
	_draw_nose()
	
	# 3. Eyes (Left & Right)
	_draw_eye(Vector2(-15, -6), true)
	_draw_eye(Vector2(15, -6), false)
	
	# 4. Mouth
	_draw_mouth()
	
	# 5. Expression accents (sparks, sweat drop, blush)
	if show_blush:
		_draw_blush_scratches()
	if is_sparking:
		_draw_cheek_sparks()
	if show_sweat:
		_draw_sweat_drop()

func _draw_cheeks() -> void:
	var left_center := Vector2(-25, 6)
	var right_center := Vector2(25, 6)
	var cheek_r := 10.5
	
	# Soft peach glow under cheeks if in color mode
	if style.current_mode == PikachuStyle.ArtMode.COLOR:
		draw_circle(left_center, cheek_r + 1.5, Color(0.95, 0.25, 0.3, 0.25))
		draw_circle(right_center, cheek_r + 1.5, Color(0.95, 0.25, 0.3, 0.25))
	
	# Red circles
	draw_circle(left_center, cheek_r, style.cheek_color)
	draw_circle(right_center, cheek_r, style.cheek_color)
	
	# Clean subtle contour
	draw_arc(left_center, cheek_r, 0, TAU, 24, style.ink_color, style.inner_line_width, true)
	draw_arc(right_center, cheek_r, 0, TAU, 24, style.ink_color, style.inner_line_width, true)

func _draw_nose() -> void:
	# Small inverted triangle centered at (0, -1)
	var nose_poly := PackedVector2Array([
		Vector2(-1.6, -1.8),
		Vector2(1.6, -1.8),
		Vector2(0, -0.2)
	])
	draw_colored_polygon(nose_poly, style.ink_color)
	draw_polyline(nose_poly, style.ink_color, 1.2, true)

func _draw_eye(center: Vector2, is_left: bool) -> void:
	var sign_x := -1.0 if is_left else 1.0
	
	# Blink / Fully closed: cute curved lash line (^ ^)
	if eye_openness < 0.15 or eye_state == "happy":
		var arc := Curve2D.new()
		arc.add_point(center + Vector2(-sign_x * 7, 2), Vector2(0, 0), Vector2(2 * sign_x, -5))
		arc.add_point(center + Vector2(0, -3), Vector2(-3 * sign_x, 0), Vector2(3 * sign_x, 0))
		arc.add_point(center + Vector2(sign_x * 7, 1), Vector2(-2 * sign_x, -5), Vector2(0, 0))
		var stroke = PokemonInkStroke.from_curve(arc, style.eye_contour_width, PokemonInkStroke.Profile.TAPER_BOTH, style.ink_color)
		stroke.draw_to(self)
		return
	
	# Spiral (Confused / Fainted)
	if eye_state == "spiral":
		var spiral_pts := PackedVector2Array()
		var a_step := 0.4
		var max_turns := 3.2 * TAU
		var a := 0.0
		while a < max_turns:
			var r: float = a * 0.35
			spiral_pts.append(center + Vector2(cos(a) * r, sin(a) * r * 0.8))
			a += a_step
		draw_polyline(spiral_pts, style.ink_color, 1.8, true)
		return
	
	# Deadpan flat eye
	if eye_state == "deadpan":
		var half_w := 6.0
		var line_y := center.y
		draw_line(Vector2(center.x - half_w, line_y), Vector2(center.x + half_w, line_y), style.ink_color, style.eye_contour_width, true)
		return
	
	# Standard anime eye dimensions
	var rx := 6.5
	var ry := 7.5 * eye_openness
	var gaze_offset := gaze_direction * Vector2(2.5, 2.0)
	var pupil_center := center + gaze_offset
	
	# Shock / Wide Constriction
	if eye_state == "shock":
		# White sclera circle
		draw_circle(center, 7.5, Color("#ffffff"))
		draw_arc(center, 7.5, 0, TAU, 24, style.ink_color, style.inner_line_width, true)
		# Constricted small pupil dot
		draw_circle(pupil_center, 2.4, style.eye_pupil_color)
		return
	
	# Squint / Annoyed
	if eye_state == "squint":
		ry *= 0.45
	
	# Draw main eye oval
	var eye_c := Curve2D.new()
	eye_c.add_point(center + Vector2(0, -ry), Vector2(-rx * 0.7, 0), Vector2(rx * 0.7, 0))
	eye_c.add_point(center + Vector2(rx, 0), Vector2(0, -ry * 0.6), Vector2(0, ry * 0.6))
	eye_c.add_point(center + Vector2(0, ry), Vector2(rx * 0.7, 0), Vector2(-rx * 0.7, 0))
	eye_c.add_point(center + Vector2(-rx, 0), Vector2(0, ry * 0.6), Vector2(0, -ry * 0.6))
	var eye_pts := eye_c.tessellate(3, 2.0)
	
	draw_colored_polygon(eye_pts, style.eye_pupil_color)
	draw_polyline(eye_pts, style.ink_color, style.eye_contour_width, true)
	
	# Specular highlight (keylight at upper-inner portion)
	var highlight_pos := pupil_center + Vector2(-sign_x * 2.2, -ry * 0.35)
	draw_circle(highlight_pos, 2.5, style.eye_highlight_color)
	
	# Secondary smaller catchlight at bottom
	if eye_state != "squint" and eye_openness > 0.6:
		var sec_highlight := pupil_center + Vector2(sign_x * 2.0, ry * 0.35)
		draw_circle(sec_highlight, 1.2, Color(1, 1, 1, 0.8))

func _draw_mouth() -> void:
	var m_y := 5.0
	
	match mouth_shape:
		"cat", "closed":
			# Iconic wavy '3' upper lip curve
			var cat_c := Curve2D.new()
			cat_c.add_point(Vector2(-7, m_y + 1), Vector2(0, 0), Vector2(2, -3))
			cat_c.add_point(Vector2(-3.5, m_y - 1.5), Vector2(-2, 0), Vector2(1.5, 0))
			cat_c.add_point(Vector2(0, m_y), Vector2(-1.5, -1.5), Vector2(1.5, -1.5))
			cat_c.add_point(Vector2(3.5, m_y - 1.5), Vector2(-1.5, 0), Vector2(2, 0))
			cat_c.add_point(Vector2(7, m_y + 1), Vector2(-2, -3), Vector2(0, 0))
			var pts := cat_c.tessellate(3, 2.0)
			draw_polyline(pts, style.ink_color, style.inner_line_width, false)
		
		"smile":
			# Gentle curved smile with slight upturned corners
			var smile_c := Curve2D.new()
			smile_c.add_point(Vector2(-6, m_y - 1), Vector2(0, 0), Vector2(2, 2))
			smile_c.add_point(Vector2(0, m_y + 2.5), Vector2(-2.5, 0), Vector2(2.5, 0))
			smile_c.add_point(Vector2(6, m_y - 1), Vector2(-2, 2), Vector2(0, 0))
			var pts := smile_c.tessellate(3, 2.0)
			draw_polyline(pts, style.ink_color, style.inner_line_width, false)
		
		"open_happy", "open_shout":
			# Wide open mouth showing tongue and throat
			var depth: float = 9.0 if mouth_shape == "open_happy" else 13.0
			var half_w: float = 7.0
			
			# Upper lip arc
			var mouth_c := Curve2D.new()
			mouth_c.add_point(Vector2(-half_w, m_y - 1), Vector2(0, 0), Vector2(half_w * 0.5, 1))
			mouth_c.add_point(Vector2(0, m_y), Vector2(-2, 0), Vector2(2, 0))
			mouth_c.add_point(Vector2(half_w, m_y - 1), Vector2(-half_w * 0.5, 1), Vector2(0, depth * 0.6))
			mouth_c.add_point(Vector2(0, m_y + depth), Vector2(half_w * 0.6, 0), Vector2(-half_w * 0.6, 0))
			mouth_c.add_point(Vector2(-half_w, m_y - 1), Vector2(0, depth * 0.6), Vector2(0, 0))
			var poly := mouth_c.tessellate(4, 2.0)
			
			# Interior throat fill
			draw_colored_polygon(poly, style.mouth_interior_color)
			
			# Soft pink tongue crescent at bottom
			var tongue_c := Curve2D.new()
			tongue_c.add_point(Vector2(-half_w * 0.7, m_y + depth * 0.55))
			tongue_c.add_point(Vector2(0, m_y + depth * 0.35))
			tongue_c.add_point(Vector2(half_w * 0.7, m_y + depth * 0.55))
			tongue_c.add_point(Vector2(0, m_y + depth))
			var tongue_poly := tongue_c.tessellate(3, 2.0)
			draw_colored_polygon(tongue_poly, style.tongue_color)
			
			# Outer mouth outline
			draw_polyline(poly, style.ink_color, style.inner_line_width, true)
		
		"shock_o":
			# Small rounded 'O'
			var o_center := Vector2(0, m_y + 3)
			var rx := 3.8
			var ry := 5.2
			var o_c := Curve2D.new()
			o_c.add_point(o_center + Vector2(0, -ry), Vector2(-rx * 0.7, 0), Vector2(rx * 0.7, 0))
			o_c.add_point(o_center + Vector2(rx, 0), Vector2(0, -ry * 0.6), Vector2(0, ry * 0.6))
			o_c.add_point(o_center + Vector2(0, ry), Vector2(rx * 0.7, 0), Vector2(-rx * 0.7, 0))
			o_c.add_point(o_center + Vector2(-rx, 0), Vector2(0, ry * 0.6), Vector2(0, -ry * 0.6))
			var o_poly := o_c.tessellate(3, 2.0)
			draw_colored_polygon(o_poly, style.mouth_interior_color)
			draw_polyline(o_poly, style.ink_color, style.inner_line_width, true)
		
		"deadpan", "dash":
			# Straight horizontal line (- -)
			draw_line(Vector2(-5, m_y + 1), Vector2(5, m_y + 1), style.ink_color, style.inner_line_width, true)
		
		"frown":
			# Downturned arc
			var frown_c := Curve2D.new()
			frown_c.add_point(Vector2(-5, m_y + 3), Vector2(0, 0), Vector2(2, -2))
			frown_c.add_point(Vector2(0, m_y + 0.5), Vector2(-2, 0), Vector2(2, 0))
			frown_c.add_point(Vector2(5, m_y + 3), Vector2(-2, -2), Vector2(0, 0))
			var pts := frown_c.tessellate(3, 2.0)
			draw_polyline(pts, style.ink_color, style.inner_line_width, false)
		
		"wavy":
			# Squiggly nervous mouth
			var pts := PackedVector2Array([
				Vector2(-5, m_y + 2),
				Vector2(-2.5, m_y - 0.5),
				Vector2(0, m_y + 2),
				Vector2(2.5, m_y - 0.5),
				Vector2(5, m_y + 2)
			])
			draw_polyline(pts, style.ink_color, style.inner_line_width, false)
		
		"grit":
			# Determined tooth grit
			var rect := Rect2(-5.5, m_y, 11, 4.0)
			draw_rect(rect, Color("#ffffff"))
			draw_rect(rect, style.ink_color, false, style.inner_line_width)
			draw_line(Vector2(-1.8, m_y), Vector2(-1.8, m_y + 4), style.ink_color, 1.0)
			draw_line(Vector2(1.8, m_y), Vector2(1.8, m_y + 4), style.ink_color, 1.0)
			draw_line(Vector2(-5.5, m_y + 2), Vector2(5.5, m_y + 2), style.ink_color, 1.0)

func _draw_blush_scratches() -> void:
	# Hand-drawn diagonal scratch marks (///) across cheeks
	var left_start := Vector2(-28, 4)
	var right_start := Vector2(22, 4)
	for i in range(3):
		var offset := Vector2(i * 3.0, 0)
		draw_line(left_start + offset, left_start + offset + Vector2(2, 5), style.ink_color, 1.2, true)
		draw_line(right_start + offset, right_start + offset + Vector2(2, 5), style.ink_color, 1.2, true)

func _draw_cheek_sparks() -> void:
	var spark_locs := [
		Vector2(-35, 2), Vector2(-38, 10), Vector2(-28, 17),
		Vector2(35, 2), Vector2(38, 10), Vector2(28, 17)
	]
	for p in spark_locs:
		draw_line(p - Vector2(3, 0), p + Vector2(3, 0), style.spark_color, 2.0)
		draw_line(p - Vector2(0, 3), p + Vector2(0, 3), style.spark_color, 2.0)

func _draw_sweat_drop() -> void:
	# Anime sweat drop on temple
	var drop_c := Curve2D.new()
	var sp := Vector2(-24, -18)
	drop_c.add_point(sp, Vector2(0, 0), Vector2(-3, 6))
	drop_c.add_point(sp + Vector2(-2, 9), Vector2(0, -2), Vector2(2, 2))
	drop_c.add_point(sp + Vector2(2, 9), Vector2(-2, 2), Vector2(0, -2))
	drop_c.add_point(sp, Vector2(3, 6), Vector2(0, 0))
	var drop_pts := drop_c.tessellate(3, 2.0)
	draw_colored_polygon(drop_pts, Color(0.65, 0.85, 0.98, 0.85))
	draw_polyline(drop_pts, style.ink_color, 1.2, true)
