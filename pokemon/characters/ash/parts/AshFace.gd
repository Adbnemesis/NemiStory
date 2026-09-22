class_name AshFace
extends Node2D

## Master Facial Acting System for ASH KETCHUM
## Faithfully crafted to match the classic anime references:
## - Classic 90s shonen anime eyes: sharp, compact, determined, with solid dark irises
##   and a single thin vertical white catchlight slit (NO giant sparkling bubbles).
## - Signature horizontal "Z" lightning cheek marks (two horizontal jagged marks on each cheek).
## - Small sharp angular nose hook with soft warm nostril shadow.
## - Expressive eyebrows positioned close to the eyes for athletic determination.
## - Rich viseme mouth shapes (confident grin, cat smile, open shout, teeth grit, deadpan dash).

const AshStyle = preload("res://pokemon/characters/ash/AshStyle.gd")
const PokemonInkStroke = preload("res://pokemon/scripts/PokemonInkStroke.gd")

var style: AshStyle

# Eye properties
var eye_openness: float = 1.0: # 0.0 = closed/blink, 1.0 = normal, 1.35 = shock
	set(val):
		eye_openness = clampf(val, 0.0, 1.5)
		queue_redraw()

var gaze_direction: Vector2 = Vector2.ZERO: # (-1 to 1)
	set(val):
		gaze_direction = val.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
		queue_redraw()

var eye_state: String = "normal": # "normal", "happy", "shock", "squint", "determined", "deadpan"
	set(val):
		eye_state = val
		queue_redraw()

# Eyebrow controls
var left_brow_offset: Vector2 = Vector2.ZERO:
	set(val):
		left_brow_offset = val
		queue_redraw()

var right_brow_offset: Vector2 = Vector2.ZERO:
	set(val):
		right_brow_offset = val
		queue_redraw()

var left_brow_tilt: float = 0.0:
	set(val):
		left_brow_tilt = val
		queue_redraw()

var right_brow_tilt: float = 0.0:
	set(val):
		right_brow_tilt = val
		queue_redraw()

# Mouth
var mouth_shape: String = "smile": # "smile", "confident_grin", "open_happy", "open_shout", "shock_o", "deadpan", "wavy", "frown", "grit"
	set(val):
		mouth_shape = val
		queue_redraw()

# Accents
var show_blush: bool = false:
	set(val):
		show_blush = val
		queue_redraw()

var show_sweat: bool = false:
	set(val):
		show_sweat = val
		queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Iconic Horizontal "Z" Lightning Cheek Marks
	_draw_z_cheek_marks()
	
	# 2. Nose (Sharp angled anime hook with shadow)
	_draw_nose()
	
	# 3. Eyes (Compact, sharp shonen anime eyes)
	_draw_eye(Vector2(-11, -1), true)
	_draw_eye(Vector2(11, -1), false)
	
	# 4. Eyebrows
	_draw_eyebrows()
	
	# 5. Mouth
	_draw_mouth()
	
	# 6. Optional Accents
	if show_blush:
		_draw_blush()
	if show_sweat:
		_draw_sweat()

func _draw_z_cheek_marks() -> void:
	# In the anime, Ash's marks are two distinct horizontal lightning zigzags under each eye on the cheeks
	# Left Cheek (two horizontal zigzag lightning marks)
	var left_z1 := PackedVector2Array([
		Vector2(-16, 7.5),
		Vector2(-12, 8.8),
		Vector2(-8, 7.5)
	])
	draw_polyline(left_z1, style.ink_color, 1.4, false)
	
	var left_z2 := PackedVector2Array([
		Vector2(-15, 10.5),
		Vector2(-11, 11.8),
		Vector2(-7, 10.5)
	])
	draw_polyline(left_z2, style.ink_color, 1.4, false)
	
	# Right Cheek (two horizontal zigzag lightning marks)
	var right_z1 := PackedVector2Array([
		Vector2(8, 7.5),
		Vector2(12, 8.8),
		Vector2(16, 7.5)
	])
	draw_polyline(right_z1, style.ink_color, 1.4, false)
	
	var right_z2 := PackedVector2Array([
		Vector2(7, 10.5),
		Vector2(11, 11.8),
		Vector2(15, 10.5)
	])
	draw_polyline(right_z2, style.ink_color, 1.4, false)

func _draw_nose() -> void:
	# Classic anime nose: sharp small triangular hook at (0, 4.5) with soft nostril shadow
	var shadow_pts := PackedVector2Array([
		Vector2(-0.8, 3.5),
		Vector2(1.8, 5.2),
		Vector2(-1.0, 6.0)
	])
	draw_colored_polygon(shadow_pts, style.skin_shadow_color)
	
	var nose_pts := PackedVector2Array([
		Vector2(-0.5, 3.2),
		Vector2(1.8, 5.0),
		Vector2(-0.8, 5.8)
	])
	draw_polyline(nose_pts, style.ink_color, 1.3, false)

func _draw_eye(center: Vector2, is_left: bool) -> void:
	var sign_x := -1.0 if is_left else 1.0
	
	# 1. Happy closed curved arc eyes (^ ^)
	if eye_openness < 0.15 or eye_state == "happy":
		var arc := Curve2D.new()
		arc.add_point(center + Vector2(-sign_x * 4.5, 1.8), Vector2(0, 0), Vector2(1.2 * sign_x, -3.2))
		arc.add_point(center + Vector2(0, -1.8), Vector2(-2.0 * sign_x, 0), Vector2(2.0 * sign_x, 0))
		arc.add_point(center + Vector2(sign_x * 4.5, 1.0), Vector2(-1.2 * sign_x, -3.2), Vector2(0, 0))
		var stroke = PokemonInkStroke.from_curve(arc, 2.5, PokemonInkStroke.Profile.CALLIGRAPHIC_LASH, style.ink_color)
		stroke.draw_to(self)
		return
	
	# 2. Deadpan dot / dash
	if eye_state == "deadpan":
		draw_circle(center, 1.6, style.ink_color)
		return
	
	# 3. Compact dimensions: True classic Ash Ketchum eye size
	var half_w := 4.2
	var half_h := 5.2 * eye_openness
	
	# Shock constriction
	if eye_state == "shock":
		var sclera_pts := PackedVector2Array([
			center + Vector2(-half_w, -half_h * 0.9),
			center + Vector2(half_w, -half_h * 0.9),
			center + Vector2(half_w * 0.85, half_h * 0.9),
			center + Vector2(-half_w * 0.85, half_h * 0.9)
		])
		draw_colored_polygon(sclera_pts, style.eye_sclera_color)
		draw_polyline(sclera_pts, style.ink_color, 1.0, true)
		draw_circle(center + gaze_direction * Vector2(1.8, 1.2), 1.4, style.ink_color)
		return
	
	# Squint / Annoyed
	if eye_state == "squint":
		half_h *= 0.45
	
	# 4. Sclera (White eye background - compact clean polygon)
	var sclera_poly := PackedVector2Array([
		center + Vector2(-sign_x * (half_w - 0.8), -half_h * 0.6), # Inner top
		center + Vector2(0, -half_h * 0.95),                        # Top center
		center + Vector2(sign_x * half_w, -half_h * 0.75),          # Outer top
		center + Vector2(sign_x * (half_w + 0.2), half_h * 0.5),    # Outer mid
		center + Vector2(sign_x * (half_w - 0.5), half_h * 0.85),   # Outer bottom
		center + Vector2(0, half_h * 0.95),                         # Bottom center
		center + Vector2(-sign_x * (half_w - 1.2), half_h * 0.8),   # Inner bottom
		center + Vector2(-sign_x * (half_w - 1.0), 0)               # Inner mid
	])
	draw_colored_polygon(sclera_poly, style.eye_sclera_color)
	
	# 5. Iris & Pupil (Dark charcoal-black vertical oval, fills ~70% of eye)
	var gaze_offset := gaze_direction * Vector2(1.2, 0.8)
	var iris_center := center + gaze_offset
	var iris_rx := 2.4
	var iris_ry := 4.4 * clampf(eye_openness, 0.4, 1.05)
	
	var iris_poly := PackedVector2Array([
		iris_center + Vector2(0, -iris_ry),
		iris_center + Vector2(iris_rx * 0.9, -iris_ry * 0.6),
		iris_center + Vector2(iris_rx, 0),
		iris_center + Vector2(iris_rx * 0.9, iris_ry * 0.6),
		iris_center + Vector2(0, iris_ry),
		iris_center + Vector2(-iris_rx * 0.9, iris_ry * 0.6),
		iris_center + Vector2(-iris_rx, 0),
		iris_center + Vector2(-iris_rx * 0.9, -iris_ry * 0.6)
	])
	draw_colored_polygon(iris_poly, Color("#1a181b"))
	
	# 6. SINGLE CLEAN CATCHLIGHT (Just ONE single vertical slit line - NO sparkles, NO multiple circles!)
	var catch_x := iris_center.x - 0.8
	var catch_y1 := iris_center.y - iris_ry * 0.55
	var catch_y2 := iris_center.y + iris_ry * 0.1
	draw_line(Vector2(catch_x, catch_y1), Vector2(catch_x, catch_y2), Color("#ffffff"), 1.1)
	
	# 7. Upper Eyelid / Lash Band (Bold confident downward-angled calligraphic inking)
	var lash_c := Curve2D.new()
	lash_c.add_point(center + Vector2(-sign_x * (half_w + 0.2), -half_h * 0.45), Vector2(0, 0), Vector2(1.2 * sign_x, -half_h * 0.35))
	lash_c.add_point(center + Vector2(0, -half_h - 0.6), Vector2(-1.5 * sign_x, 0), Vector2(1.5 * sign_x, 0))
	lash_c.add_point(center + Vector2(sign_x * (half_w + 0.5), -half_h * 0.55), Vector2(-1.2 * sign_x, -0.6), Vector2(0.8 * sign_x, 0.6))
	lash_c.add_point(center + Vector2(sign_x * (half_w + 1.6), -half_h * 0.25), Vector2(0, 0), Vector2(0, 0))
	var lash_stroke = PokemonInkStroke.from_curve(lash_c, 2.6, PokemonInkStroke.Profile.CALLIGRAPHIC_LASH, style.ink_color)
	lash_stroke.draw_to(self)
	
	# 8. Outer-Lower Eyelid (Delicate tick, bottom is open to skin like classic cel animation)
	draw_line(center + Vector2(sign_x * (half_w + 0.2), -half_h * 0.2), center + Vector2(sign_x * (half_w - 0.5), half_h * 0.85), style.ink_color, 1.1)
	draw_line(center + Vector2(sign_x * (half_w - 0.5), half_h * 0.85), center + Vector2(sign_x * 0.5, half_h * 0.95), style.ink_color, 1.0)

func _draw_eyebrows() -> void:
	# Athletic, expressive anime eyebrows placed close above the eyes
	# Left eyebrow
	var l_root := Vector2(-11, -9) + left_brow_offset
	var l_pts := PackedVector2Array([
		l_root + Vector2(-6, 0.5 + left_brow_tilt * 3.5),
		l_root + Vector2(-2, -1.8 + left_brow_tilt * 1.8),
		l_root + Vector2(2, -1.0),
		l_root + Vector2(5, 0.8 - left_brow_tilt * 3.5)
	])
	draw_polyline(l_pts, style.ink_color, 2.4, false)
	
	# Right eyebrow
	var r_root := Vector2(11, -9) + right_brow_offset
	var r_pts := PackedVector2Array([
		r_root + Vector2(-5, 0.8 + right_brow_tilt * 3.5),
		r_root + Vector2(-2, -1.0),
		r_root + Vector2(2, -1.8 - right_brow_tilt * 1.8),
		r_root + Vector2(6, 0.5 - right_brow_tilt * 3.5)
	])
	draw_polyline(r_pts, style.ink_color, 2.4, false)

func _draw_mouth() -> void:
	var m_y := 12.0
	
	match mouth_shape:
		"smile":
			# Classic confident anime smile with subtle upturned corner
			var smile_c := Curve2D.new()
			smile_c.add_point(Vector2(-5.5, m_y - 0.5), Vector2(0, 0), Vector2(1.5, 1.5))
			smile_c.add_point(Vector2(0, m_y + 1.6), Vector2(-1.8, 0), Vector2(1.8, 0))
			smile_c.add_point(Vector2(6.0, m_y - 0.5), Vector2(-1.5, 1.5), Vector2(0, 0))
			var pts := smile_c.tessellate(3, 2.0)
			draw_polyline(pts, style.ink_color, style.inner_line_width, false)
			# Tiny right corner tick
			draw_line(Vector2(6.0, m_y - 0.5), Vector2(7.2, m_y - 1.6), style.ink_color, 1.2)
		
		"confident_grin":
			# Wide toothy confident grin
			var grin_poly := PackedVector2Array([
				Vector2(-7.5, m_y - 1.5),
				Vector2(7.5, m_y - 1.5),
				Vector2(4.5, m_y + 3.5),
				Vector2(-4.5, m_y + 3.5)
			])
			draw_colored_polygon(grin_poly, Color("#ffffff"))
			draw_polyline(grin_poly, style.ink_color, style.inner_line_width, true)
			draw_line(Vector2(-6.5, m_y + 0.5), Vector2(6.5, m_y + 0.5), style.ink_color, 1.0)
		
		"open_happy", "open_shout":
			var depth: float = 8.0 if mouth_shape == "open_happy" else 12.0
			var half_w: float = 7.0
			var mouth_c := Curve2D.new()
			mouth_c.add_point(Vector2(-half_w, m_y - 1), Vector2(0, 0), Vector2(half_w * 0.5, 1))
			mouth_c.add_point(Vector2(0, m_y), Vector2(-2, 0), Vector2(2, 0))
			mouth_c.add_point(Vector2(half_w, m_y - 1), Vector2(-half_w * 0.5, 1), Vector2(0, depth * 0.6))
			mouth_c.add_point(Vector2(0, m_y + depth), Vector2(half_w * 0.6, 0), Vector2(-half_w * 0.6, 0))
			mouth_c.add_point(Vector2(-half_w, m_y - 1), Vector2(0, depth * 0.6), Vector2(0, 0))
			var poly := mouth_c.tessellate(4, 2.0)
			
			draw_colored_polygon(poly, Color("#8b2635"))
			
			# Curved tongue at bottom of mouth
			var tongue_c := Curve2D.new()
			tongue_c.add_point(Vector2(-half_w * 0.7, m_y + depth * 0.5))
			tongue_c.add_point(Vector2(0, m_y + depth * 0.3))
			tongue_c.add_point(Vector2(half_w * 0.7, m_y + depth * 0.5))
			tongue_c.add_point(Vector2(0, m_y + depth))
			var tongue_poly := tongue_c.tessellate(3, 2.0)
			draw_colored_polygon(tongue_poly, Color("#e27396"))
			
			draw_polyline(poly, style.ink_color, style.inner_line_width, true)
		
		"shock_o":
			var o_center := Vector2(0, m_y + 2.5)
			var rx := 3.5
			var ry := 4.8
			var o_c := Curve2D.new()
			o_c.add_point(o_center + Vector2(0, -ry), Vector2(-rx * 0.7, 0), Vector2(rx * 0.7, 0))
			o_c.add_point(o_center + Vector2(rx, 0), Vector2(0, -ry * 0.6), Vector2(0, ry * 0.6))
			o_c.add_point(o_center + Vector2(0, ry), Vector2(rx * 0.7, 0), Vector2(-rx * 0.7, 0))
			o_c.add_point(o_center + Vector2(-rx, 0), Vector2(0, ry * 0.6), Vector2(0, -ry * 0.6))
			var o_poly := o_c.tessellate(3, 2.0)
			draw_colored_polygon(o_poly, Color("#8b2635"))
			draw_polyline(o_poly, style.ink_color, style.inner_line_width, true)
		
		"deadpan", "dash":
			draw_line(Vector2(-5.5, m_y + 1), Vector2(5.5, m_y + 1), style.ink_color, style.inner_line_width, true)
		
		"frown":
			var frown_c := Curve2D.new()
			frown_c.add_point(Vector2(-5.0, m_y + 2.2), Vector2(0, 0), Vector2(1.5, -1.5))
			frown_c.add_point(Vector2(0, m_y + 0.5), Vector2(-1.5, 0), Vector2(1.5, 0))
			frown_c.add_point(Vector2(5.0, m_y + 2.2), Vector2(-1.5, -1.5), Vector2(0, 0))
			var pts := frown_c.tessellate(3, 2.0)
			draw_polyline(pts, style.ink_color, style.inner_line_width, false)
		
		"wavy":
			var pts := PackedVector2Array([
				Vector2(-4.5, m_y + 1.2),
				Vector2(-2.2, m_y - 1.0),
				Vector2(0, m_y + 1.2),
				Vector2(2.2, m_y - 1.0),
				Vector2(4.5, m_y + 1.2)
			])
			draw_polyline(pts, style.ink_color, style.inner_line_width, false)
		
		"grit":
			var rect := Rect2(-5.5, m_y - 1, 11, 4.0)
			draw_rect(rect, Color("#ffffff"))
			draw_rect(rect, style.ink_color, false, style.inner_line_width)
			draw_line(Vector2(-1.8, m_y - 1), Vector2(-1.8, m_y + 3.0), style.ink_color, 1.0)
			draw_line(Vector2(1.8, m_y - 1), Vector2(1.8, m_y + 3.0), style.ink_color, 1.0)
			draw_line(Vector2(-5.5, m_y + 1.0), Vector2(5.5, m_y + 1.0), style.ink_color, 1.0)

func _draw_blush() -> void:
	var left_b := Vector2(-13, 7)
	var right_b := Vector2(13, 7)
	draw_circle(left_b, 4.5, style.blush_color)
	draw_circle(right_b, 4.5, style.blush_color)

func _draw_sweat() -> void:
	var sp := Vector2(-19, -9)
	var drop_c := Curve2D.new()
	drop_c.add_point(sp, Vector2(0, 0), Vector2(-2.2, 4.5))
	drop_c.add_point(sp + Vector2(-1.6, 7), Vector2(0, -1.6), Vector2(1.6, 1.6))
	drop_c.add_point(sp + Vector2(1.6, 7), Vector2(-1.6, 1.6), Vector2(0, -1.6))
	drop_c.add_point(sp, Vector2(2.2, 4.5), Vector2(0, 0))
	var drop_pts := drop_c.tessellate(3, 2.0)
	draw_colored_polygon(drop_pts, Color(0.65, 0.85, 0.98, 0.85))
	draw_polyline(drop_pts, style.ink_color, 1.2, true)
