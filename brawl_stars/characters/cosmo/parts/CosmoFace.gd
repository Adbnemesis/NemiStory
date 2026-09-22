class_name CosmoFace
extends Node2D

## Master Facial Acting System for COSMO (Brawl Stars)
## Faithfully crafted to match the astronomer references & illustrated storytelling style:
## - Signature large cyclops telescope lens barrel mounted at an inquisitive angle
## - Cosmic purple lens interior with dual soft specular highlights
## - Glowing white pill/capsule pupil with magenta edge aura and full 2D gaze tracking
## - 4-segment illuminated amber speaker/teeth grill mouth that dynamically deforms
##   for speech visemes, comedic deadpans, cheerful smiles, and dropped-jaw shocks
## - Expressive FX (sweat droplets, eureka sparkles, anger marks)

const CosmoStyle = preload("res://brawl_stars/characters/cosmo/CosmoStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: CosmoStyle

# Eye properties
var eye_openness: float = 1.0: # 0.0 = blink/closed, 1.0 = normal, 1.4 = shock/wide
	set(val):
		eye_openness = clampf(val, 0.0, 1.6)
		queue_redraw()

var gaze_direction: Vector2 = Vector2.ZERO: # (-1.0 to 1.0)
	set(val):
		gaze_direction = val.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
		queue_redraw()

var eye_state: String = "normal": # "normal", "happy", "shock", "analytical", "fascinated", "deadpan", "suspicious"
	set(val):
		eye_state = val
		queue_redraw()

var pupil_tilt: float = 0.0:
	set(val):
		pupil_tilt = val
		queue_redraw()

# Mouth Grill properties
var mouth_shape: String = "neutral": # "neutral", "smile", "grin", "open_talk", "shout", "shock_o", "frown", "deadpan", "wavy", "smug"
	set(val):
		mouth_shape = val
		queue_redraw()

var mouth_openness: float = 0.0: # 0.0 = closed grill, 1.0 = wide open jaw
	set(val):
		mouth_openness = clampf(val, 0.0, 1.2)
		queue_redraw()

# Expressive FX
var show_sweat: bool = false:
	set(val):
		show_sweat = val
		queue_redraw()

var show_sparkle: bool = false:
	set(val):
		show_sparkle = val
		queue_redraw()

var show_anger: bool = false:
	set(val):
		show_anger = val
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Signature 4-segment Speaker / Teeth Grill Mouth (at lower chin)
	_draw_mouth_grill()
	
	# 2. Main Cyclops Telescope Barrel & Cosmic Eye (center-top)
	_draw_telescope_eye()
	
	# 3. Optional Expressive FX
	if show_sweat:
		_draw_sweat_drop()
	if show_sparkle:
		_draw_eureka_sparkle()
	if show_anger:
		_draw_anger_mark()

# -------------------------------------------------------------------------
# CYCLOPS TELESCOPE LENS & EYE SYSTEM
# -------------------------------------------------------------------------

func _draw_telescope_eye() -> void:
	var eye_center := Vector2(0, -22)
	var lens_radius: float = 24.0
	
	# Outer Telescope Barrel Casing (Dark gunmetal bevel)
	draw_circle(eye_center, lens_radius + 4.5, style.lens_barrel_color)
	draw_arc(eye_center, lens_radius + 4.5, 0, TAU, 32, style.ink_color, style.outer_contour_width, true)
	
	# Inner Bevel Ring
	draw_circle(eye_center, lens_radius + 1.0, style.robot_metal_shadow_color)
	
	# Deep Cosmic Purple Lens Interior
	draw_circle(eye_center, lens_radius, style.lens_interior_color)
	
	# If eye is completely closed (blink)
	if eye_openness <= 0.08:
		var blink_pts := PackedVector2Array([
			eye_center + Vector2(-16, 2),
			eye_center + Vector2(-8, 5),
			eye_center + Vector2(0, 6),
			eye_center + Vector2(8, 5),
			eye_center + Vector2(16, 2)
		])
		var b_stroke := CosmoInkStroke.from_points(blink_pts, style.lash_line_width, CosmoInkStroke.Profile.CALLIGRAPHIC_LASH, style.ink_color)
		b_stroke.draw_to(self)
		return
	
	# Specular Glints on Lens Glass (soft celestial reflections)
	draw_circle(eye_center + Vector2(-11, -11), 3.5, Color(1.0, 1.0, 1.0, 0.45))
	draw_circle(eye_center + Vector2(-6, -14), 1.8, Color(1.0, 1.0, 1.0, 0.35))
	draw_circle(eye_center + Vector2(12, 10), 2.2, Color(1.0, 1.0, 1.0, 0.25))
	
	# Gaze Offset (clamped within lens circle)
	var max_gaze_dist: float = 9.0 * eye_openness
	var current_gaze_offset := gaze_direction * max_gaze_dist
	var pupil_pos := eye_center + current_gaze_offset
	
	# Draw Pupil based on eye_state & openness
	match eye_state:
		"happy":
			# Cheerful upward crescent slit (^_^)
			var slit_pts := PackedVector2Array([
				pupil_pos + Vector2(-10, 4),
				pupil_pos + Vector2(-5, -3),
				pupil_pos + Vector2(0, -5),
				pupil_pos + Vector2(5, -3),
				pupil_pos + Vector2(10, 4)
			])
			# Outer magenta glow
			var glow_stroke := CosmoInkStroke.from_points(slit_pts, 5.0, CosmoInkStroke.Profile.TAPER_BOTH, style.pupil_glow_color)
			glow_stroke.draw_to(self)
			# Core white slit
			var white_stroke := CosmoInkStroke.from_points(slit_pts, 2.8, CosmoInkStroke.Profile.TAPER_BOTH, style.pupil_white_color)
			white_stroke.draw_to(self)
		
		"shock":
			# Tiny constricted pinpoint pupil with shock rays
			var p_rad: float = 3.2
			draw_circle(pupil_pos, p_rad + 2.5, style.pupil_glow_color)
			draw_circle(pupil_pos, p_rad, style.pupil_white_color)
			draw_circle(pupil_pos, 1.2, style.ink_color)
		
		"analytical":
			# Narrowed focused horizontal / angular slit
			var half_w: float = 12.0
			var half_h: float = 3.0 * eye_openness
			draw_set_transform(pupil_pos, pupil_tilt, Vector2.ONE)
			draw_rect(Rect2(-half_w - 1.5, -half_h - 1.5, (half_w + 1.5) * 2, (half_h + 1.5) * 2), style.pupil_glow_color, true)
			draw_rect(Rect2(-half_w, -half_h, half_w * 2, half_h * 2), style.pupil_white_color, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		
		"deadpan":
			# Canonical flat horizontal bar with zero tilt
			var half_w: float = 13.0
			var half_h: float = 2.4
			draw_rect(Rect2(pupil_pos.x - half_w - 1.0, pupil_pos.y - half_h - 1.0, (half_w + 1.0) * 2, (half_h + 1.0) * 2), style.pupil_glow_color, true)
			draw_rect(Rect2(pupil_pos.x - half_w, pupil_pos.y - half_h, half_w * 2, half_h * 2), style.pupil_white_color, true)
		
		"fascinated":
			# Huge wide glowing orb with starry highlight
			var orb_rad: float = 11.5 * eye_openness
			draw_circle(pupil_pos, orb_rad + 3.0, style.pupil_glow_color)
			draw_circle(pupil_pos, orb_rad, style.pupil_white_color)
			# Mini 4-point star highlight in center
			_draw_mini_star(pupil_pos, 5.0, style.pupil_glow_color)
		
		_:
			# "normal" / "curious" / "suspicious": Canonical Vertical Rounded Pill Capsule
			var pill_w: float = 7.0
			var pill_h: float = 14.0 * eye_openness
			
			draw_set_transform(pupil_pos, pupil_tilt, Vector2.ONE)
			
			# Outer magenta/violet glowing aura
			draw_circle(Vector2(0, -pill_h * 0.4), (pill_w + 3.0) * 0.5, style.pupil_glow_color)
			draw_circle(Vector2(0, pill_h * 0.4), (pill_w + 3.0) * 0.5, style.pupil_glow_color)
			draw_rect(Rect2(-(pill_w + 3.0) * 0.5, -pill_h * 0.4, pill_w + 3.0, pill_h * 0.8), style.pupil_glow_color, true)
			
			# Pure white luminous pill core
			draw_circle(Vector2(0, -pill_h * 0.4), pill_w * 0.5, style.pupil_white_color)
			draw_circle(Vector2(0, pill_h * 0.4), pill_w * 0.5, style.pupil_white_color)
			draw_rect(Rect2(-pill_w * 0.5, -pill_h * 0.4, pill_w, pill_h * 0.8), style.pupil_white_color, true)
			
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_mini_star(center: Vector2, rad: float, col: Color) -> void:
	var pts := PackedVector2Array([
		center + Vector2(0, -rad),
		center + Vector2(rad * 0.25, -rad * 0.25),
		center + Vector2(rad, 0),
		center + Vector2(rad * 0.25, rad * 0.25),
		center + Vector2(0, rad),
		center + Vector2(-rad * 0.25, rad * 0.25),
		center + Vector2(-rad, 0),
		center + Vector2(-rad * 0.25, -rad * 0.25)
	])
	draw_colored_polygon(pts, col)

# -------------------------------------------------------------------------
# 4-SEGMENT SPEAKER / TEETH GRILL MOUTH SYSTEM
# -------------------------------------------------------------------------

func _draw_mouth_grill() -> void:
	var mouth_y := 4.0
	
	match mouth_shape:
		"deadpan":
			# Flat straight thin horizontal grill bar
			var grill_w: float = 28.0
			var grill_h: float = 6.0
			var rect := Rect2(-grill_w * 0.5, mouth_y - grill_h * 0.5, grill_w, grill_h)
			draw_rect(rect, style.mouth_grill_color, true)
			draw_rect(rect, style.ink_color, false, style.inner_line_width)
			# 3 vertical slot dividers (4 teeth slots)
			for i in range(1, 4):
				var x := -grill_w * 0.5 + (grill_w / 4.0) * float(i)
				draw_line(Vector2(x, mouth_y - grill_h * 0.5), Vector2(x, mouth_y + grill_h * 0.5), style.ink_color, style.inner_line_width)
		
		"smile", "grin":
			# Arched upward smiling crescent grill
			var grill_w: float = 32.0
			var grill_h: float = 10.0 if mouth_shape == "grin" else 7.5
			var pts := PackedVector2Array([
				Vector2(-grill_w * 0.5, mouth_y - 2),
				Vector2(-grill_w * 0.25, mouth_y + 1),
				Vector2(0, mouth_y + 2),
				Vector2(grill_w * 0.25, mouth_y + 1),
				Vector2(grill_w * 0.5, mouth_y - 2),
				Vector2(grill_w * 0.38, mouth_y + grill_h - 1),
				Vector2(0, mouth_y + grill_h),
				Vector2(-grill_w * 0.38, mouth_y + grill_h - 1)
			])
			draw_colored_polygon(pts, style.mouth_grill_color)
			var loop := PackedVector2Array()
			for p in pts:
				loop.append(p)
			loop.append(pts[0])
			var s := CosmoInkStroke.from_points(loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
			s.draw_to(self)
			# Vertical slot lines
			for i in range(1, 4):
				var t: float = float(i) / 4.0
				var top_p := Vector2.ZERO.lerp(Vector2(grill_w * (t - 0.5), mouth_y), 1.0)
				var bot_p := Vector2(top_p.x * 0.85, mouth_y + grill_h - 1.0)
				draw_line(top_p, bot_p, style.ink_color, style.detail_line_width)
		
		"open_talk", "shout":
			# Dropped jaw exposing dark mouth chamber with illuminated upper and lower grill teeth
			var jaw_drop: float = 18.0 * (1.0 + mouth_openness * 0.5)
			var mouth_w: float = 30.0
			var cavity := PackedVector2Array([
				Vector2(-mouth_w * 0.5, mouth_y - 3),
				Vector2(mouth_w * 0.5, mouth_y - 3),
				Vector2(mouth_w * 0.42, mouth_y + jaw_drop),
				Vector2(-mouth_w * 0.42, mouth_y + jaw_drop)
			])
			# Deep dark mouth cavity
			draw_colored_polygon(cavity, style.lens_interior_color)
			# Upper grill teeth strip
			var top_teeth := Rect2(-mouth_w * 0.46, mouth_y - 3, mouth_w * 0.92, 5.0)
			draw_rect(top_teeth, style.mouth_grill_color, true)
			# Lower grill teeth strip
			var bot_teeth := Rect2(-mouth_w * 0.38, mouth_y + jaw_drop - 5.0, mouth_w * 0.76, 5.0)
			draw_rect(bot_teeth, style.mouth_grill_color, true)
			# Outer contour
			var loop := PackedVector2Array()
			for p in cavity:
				loop.append(p)
			loop.append(cavity[0])
			var s := CosmoInkStroke.from_points(loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
			s.draw_to(self)
			# Vertical slot lines on top/bottom teeth
			for i in range(1, 4):
				var x := -mouth_w * 0.4 + (mouth_w * 0.8 / 4.0) * float(i)
				draw_line(Vector2(x, mouth_y - 3), Vector2(x, mouth_y + 2), style.ink_color, style.detail_line_width)
				draw_line(Vector2(x * 0.82, mouth_y + jaw_drop - 5), Vector2(x * 0.82, mouth_y + jaw_drop), style.ink_color, style.detail_line_width)
		
		"shock_o":
			# Tall rounded oval grill mouth
			var o_rad_x: float = 9.0
			var o_rad_y: float = 14.0
			var o_center := Vector2(0, mouth_y + 4)
			draw_set_transform(o_center, 0.0, Vector2(1.0, o_rad_y / o_rad_x))
			draw_circle(Vector2.ZERO, o_rad_x, style.lens_interior_color)
			draw_arc(Vector2.ZERO, o_rad_x, 0, TAU, 24, style.mouth_grill_color, 3.5, true)
			draw_arc(Vector2.ZERO, o_rad_x + 1.5, 0, TAU, 24, style.ink_color, style.inner_line_width, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		
		"frown":
			# Downward curved grimace grill
			var grill_w: float = 30.0
			var grill_h: float = 7.0
			var pts := PackedVector2Array([
				Vector2(-grill_w * 0.5, mouth_y + 3),
				Vector2(0, mouth_y - 2),
				Vector2(grill_w * 0.5, mouth_y + 3),
				Vector2(grill_w * 0.4, mouth_y + 3 + grill_h),
				Vector2(0, mouth_y - 2 + grill_h),
				Vector2(-grill_w * 0.4, mouth_y + 3 + grill_h)
			])
			draw_colored_polygon(pts, style.mouth_grill_color)
			var loop := PackedVector2Array()
			for p in pts:
				loop.append(p)
			loop.append(pts[0])
			var s := CosmoInkStroke.from_points(loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
			s.draw_to(self)
			for i in range(1, 4):
				var t: float = float(i) / 4.0
				var x := -grill_w * 0.4 + (grill_w * 0.8) * t
				draw_line(Vector2(x, mouth_y), Vector2(x, mouth_y + grill_h), style.ink_color, style.detail_line_width)
		
		"wavy":
			# Undulating confused squiggly grill
			var grill_w: float = 28.0
			var grill_h: float = 6.0
			var pts := PackedVector2Array([
				Vector2(-grill_w * 0.5, mouth_y - 1),
				Vector2(-grill_w * 0.2, mouth_y + 3),
				Vector2(grill_w * 0.1, mouth_y - 3),
				Vector2(grill_w * 0.5, mouth_y + 2),
				Vector2(grill_w * 0.45, mouth_y + 2 + grill_h),
				Vector2(grill_w * 0.1, mouth_y - 3 + grill_h),
				Vector2(-grill_w * 0.2, mouth_y + 3 + grill_h),
				Vector2(-grill_w * 0.45, mouth_y - 1 + grill_h)
			])
			draw_colored_polygon(pts, style.mouth_grill_color)
			var loop := PackedVector2Array()
			for p in pts:
				loop.append(p)
			loop.append(pts[0])
			var s := CosmoInkStroke.from_points(loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
			s.draw_to(self)
		
		"smug":
			# Cocked diagonal smirk grill (higher on the right)
			var grill_w: float = 26.0
			var grill_h: float = 7.0
			var pts := PackedVector2Array([
				Vector2(-grill_w * 0.5, mouth_y + 2),
				Vector2(0, mouth_y),
				Vector2(grill_w * 0.5, mouth_y - 5),
				Vector2(grill_w * 0.45, mouth_y - 5 + grill_h),
				Vector2(0, mouth_y + grill_h),
				Vector2(-grill_w * 0.45, mouth_y + 2 + grill_h)
			])
			draw_colored_polygon(pts, style.mouth_grill_color)
			var loop := PackedVector2Array()
			for p in pts:
				loop.append(p)
			loop.append(pts[0])
			var s := CosmoInkStroke.from_points(loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
			s.draw_to(self)
		
		_:
			# "neutral": Canonical 4-slot rounded rectangular grill
			var grill_w: float = 30.0
			var grill_h: float = 8.0
			var pts := PackedVector2Array([
				Vector2(-grill_w * 0.5, mouth_y - 2),
				Vector2(grill_w * 0.5, mouth_y - 2),
				Vector2(grill_w * 0.45, mouth_y + grill_h),
				Vector2(-grill_w * 0.45, mouth_y + grill_h)
			])
			draw_colored_polygon(pts, style.mouth_grill_color)
			var loop := PackedVector2Array()
			for p in pts:
				loop.append(p)
			loop.append(pts[0])
			var s := CosmoInkStroke.from_points(loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
			s.draw_to(self)
			# 3 vertical slot divider lines
			for i in range(1, 4):
				var x := -grill_w * 0.45 + (grill_w * 0.9 / 4.0) * float(i)
				draw_line(Vector2(x, mouth_y - 2), Vector2(x, mouth_y + grill_h), style.ink_color, style.inner_line_width)

# -------------------------------------------------------------------------
# EXPRESSIVE REACTION FX
# -------------------------------------------------------------------------

func _draw_sweat_drop() -> void:
	# Classic comic anime sweat droplet on upper-right temple
	var drop_pos := Vector2(40, -42)
	var drop_pts := PackedVector2Array([
		drop_pos,
		drop_pos + Vector2(4, 8),
		drop_pos + Vector2(3, 14),
		drop_pos + Vector2(0, 16),
		drop_pos + Vector2(-3, 14),
		drop_pos + Vector2(-4, 8)
	])
	draw_colored_polygon(drop_pts, Color(0.65, 0.88, 1.0, 0.9))
	var loop := PackedVector2Array()
	for p in drop_pts:
		loop.append(p)
	loop.append(drop_pts[0])
	var s := CosmoInkStroke.from_points(loop, 1.4, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
	s.draw_to(self)

func _draw_eureka_sparkle() -> void:
	# Eureka / discovery sparkle above head
	var spark_pos := Vector2(28, -68)
	_draw_mini_star(spark_pos, 9.0, Color("#f8e050"))
	var s_outline := CosmoInkStroke.from_points(PackedVector2Array([
		spark_pos + Vector2(0, -9),
		spark_pos + Vector2(2, -2),
		spark_pos + Vector2(9, 0),
		spark_pos + Vector2(2, 2),
		spark_pos + Vector2(0, 9),
		spark_pos + Vector2(-2, 2),
		spark_pos + Vector2(-9, 0),
		spark_pos + Vector2(-2, -2),
		spark_pos + Vector2(0, -9)
	]), 1.4, CosmoInkStroke.Profile.UNIFORM, style.ink_color)
	s_outline.draw_to(self)

func _draw_anger_mark() -> void:
	# Annoyance / frustration 4-curved cross mark
	var mark_pos := Vector2(-36, -46)
	var col := Color("#dc3232")
	draw_arc(mark_pos + Vector2(-4, -4), 4.0, 0, PI * 0.5, 8, col, 2.0)
	draw_arc(mark_pos + Vector2(4, -4), 4.0, PI * 0.5, PI, 8, col, 2.0)
	draw_arc(mark_pos + Vector2(-4, 4), 4.0, -PI * 0.5, 0, 8, col, 2.0)
	draw_arc(mark_pos + Vector2(4, 4), 4.0, PI, PI * 1.5, 8, col, 2.0)
