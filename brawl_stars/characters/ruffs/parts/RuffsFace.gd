class_name RuffsFace
extends Node2D

## Master Facial Acting System for RUFFS (Colonel Ruffs - Brawl Stars)
## Faithfully captures:
## - Orange-brown canine fur head with soft cel shadow
## - Right Eye: White sclera, dark pupil, athletic angled brow under the visor
## - Left Eye: Iconic black leather eyepatch with bold stitched white "X"
## - Enormous drooping cream/tan jowls & muzzle with central cleft
## - Large shiny black dog nose with specular highlight
## - Expressive canine mouth visemes (stoic closed, barking shout, growling snarl, panting tongue)
## - Reaction FX overlays (sweat drop, anger mark, sparkle)

const RuffsStyle = preload("res://brawl_stars/characters/ruffs/RuffsStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: RuffsStyle

# Right Eye properties
var eye_openness: float = 1.0: # 0.0 = blink, 1.0 = normal, 1.35 = shock/wide
	set(val):
		eye_openness = clampf(val, 0.0, 1.5)
		queue_redraw()

var gaze_direction: Vector2 = Vector2.ZERO: # (-1.0 to 1.0)
	set(val):
		gaze_direction = val.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
		queue_redraw()

var eye_state: String = "normal": # "normal", "happy", "shock", "analytical", "deadpan", "suspicious"
	set(val):
		eye_state = val
		queue_redraw()

var brow_tilt: float = 0.0:
	set(val):
		brow_tilt = val
		queue_redraw()

var brow_offset: Vector2 = Vector2.ZERO:
	set(val):
		brow_offset = val
		queue_redraw()

# Mouth & Canine Visemes
var mouth_shape: String = "neutral": # "neutral", "bark", "growl", "smirk", "deadpan", "panting"
	set(val):
		mouth_shape = val
		queue_redraw()

var mouth_openness: float = 0.0:
	set(val):
		mouth_openness = clampf(val, 0.0, 1.2)
		queue_redraw()

# Expression FX
var show_sweat: bool = false:
	set(val):
		show_sweat = val
		queue_redraw()

var show_anger: bool = false:
	set(val):
		show_anger = val
		queue_redraw()

var show_sparkle: bool = false:
	set(val):
		show_sparkle = val
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Orange-brown Fur Head Base
	_draw_head_fur()
	
	# 2. Right Eye & Eyebrow (his right, screen left)
	_draw_right_eye()
	
	# 3. Left Eye: Iconic Eyepatch with White "X" (his left, screen right)
	_draw_eyepatch()
	
	# 4. Canine Mouth (drawn before jowls so tongue/open mouth layers underneath)
	_draw_mouth()
	
	# 5. Puffy Cream Drooping Muzzle & Jowls
	_draw_cream_jowls()
	
	# 6. Big Shiny Black Dog Nose
	_draw_dog_nose()
	
	# 7. Optional Expressive FX
	if show_sweat:
		_draw_sweat_drop()
	if show_anger:
		_draw_anger_mark()
	if show_sparkle:
		_draw_sparkle()

func _draw_head_fur() -> void:
	# Rounded head base from below visor (Y ~ -15) to chin (Y ~ 42)
	var fur_pts := PackedVector2Array([
		Vector2(-48, -12),
		Vector2(-52, 10),
		Vector2(-44, 34),
		Vector2(-24, 44),
		Vector2(0, 46),
		Vector2(24, 44),
		Vector2(44, 34),
		Vector2(52, 10),
		Vector2(48, -12),
		Vector2(0, -14)
	])
	draw_colored_polygon(fur_pts, style.fur_orange_color)
	
	# Shadow on right cheek
	var shadow_pts := PackedVector2Array([
		Vector2(0, -14),
		Vector2(48, -12),
		Vector2(52, 10),
		Vector2(44, 34),
		Vector2(24, 44),
		Vector2(18, 18),
		Vector2(14, -6)
	])
	draw_colored_polygon(shadow_pts, style.fur_shadow_color)
	
	var loop := PackedVector2Array()
	for p in fur_pts: loop.append(p)
	loop.append(fur_pts[0])
	CosmoInkStroke.from_points(loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)

func _draw_right_eye() -> void:
	var eye_center := Vector2(-22, -8)
	var rad_x: float = 12.0
	var rad_y: float = 14.0 * eye_openness
	
	if eye_openness <= 0.08:
		# Closed blink line
		var blink_pts := PackedVector2Array([
			eye_center + Vector2(-12, 2),
			eye_center + Vector2(0, 5),
			eye_center + Vector2(12, 2)
		])
		CosmoInkStroke.from_points(blink_pts, style.lash_line_width, CosmoInkStroke.Profile.CALLIGRAPHIC_LASH, style.ink_color).draw_to(self)
	else:
		# White Sclera
		draw_set_transform(eye_center, 0.0, Vector2(1.0, rad_y / rad_x))
		draw_circle(Vector2.ZERO, rad_x, style.eye_sclera_color)
		draw_arc(Vector2.ZERO, rad_x, 0, TAU, 24, style.ink_color, style.inner_line_width, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		
		# Gaze & Pupil
		var gaze_max: float = 4.5 * eye_openness
		var pupil_pos := eye_center + gaze_direction * gaze_max
		var p_rad: float = 4.8
		if eye_state == "shock":
			p_rad = 2.2 # Constricted pinpoint pupil
		elif eye_state == "happy":
			p_rad = 6.0
		
		draw_circle(pupil_pos, p_rad, style.eye_pupil_color)
		# Catchlight dot
		draw_circle(pupil_pos + Vector2(-1.5, -1.5), 1.6, Color(1, 1, 1, 0.9))
	
	# Thick Determined Officer Eyebrow (Angles down toward snout)
	var brow_base := eye_center + Vector2(0, -12) + brow_offset
	draw_set_transform(brow_base, brow_tilt, Vector2.ONE)
	var brow_pts := PackedVector2Array([
		Vector2(-14, -2),
		Vector2(14, 4),
		Vector2(14, 8),
		Vector2(-14, 2)
	])
	draw_colored_polygon(brow_pts, style.ink_color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_eyepatch() -> void:
	var patch_center := Vector2(24, -8)
	var patch_rad: float = 15.0
	
	# Eyepatch Leather Strap (running to temple and bridge)
	draw_line(patch_center + Vector2(-14, -4), Vector2(0, -12), style.eyepatch_black_color, 3.5)
	draw_line(patch_center + Vector2(14, -4), Vector2(48, -16), style.eyepatch_black_color, 3.5)
	
	# Main Black Eyepatch Disc
	draw_circle(patch_center, patch_rad, style.eyepatch_black_color)
	draw_arc(patch_center, patch_rad, 0, TAU, 24, style.ink_color, style.outer_contour_width, true)
	
	# Signature Stitched White "X" Emblem
	var x_size: float = 8.5
	# Cross stroke 1: top-left to bottom-right
	draw_line(patch_center + Vector2(-x_size, -x_size), patch_center + Vector2(x_size, x_size), style.eyepatch_cross_color, 3.8)
	# Cross stroke 2: bottom-left to top-right
	draw_line(patch_center + Vector2(-x_size, x_size), patch_center + Vector2(x_size, -x_size), style.eyepatch_cross_color, 3.8)
	
	# Outline on the white X for crisp hand-drawn definition
	draw_line(patch_center + Vector2(-x_size, -x_size), patch_center + Vector2(x_size, x_size), style.ink_color, 1.2)
	draw_line(patch_center + Vector2(-x_size, x_size), patch_center + Vector2(x_size, -x_size), style.ink_color, 1.2)

func _draw_cream_jowls() -> void:
	# Massive drooping canine muzzle / jowls
	# Center sits at Y ~ 20. Left and right puffy bulges.
	var jowls_pts := PackedVector2Array([
		Vector2(0, 8),      # Top under nose
		Vector2(-20, 6),
		Vector2(-40, 14),
		Vector2(-46, 26),
		Vector2(-38, 40),
		Vector2(-18, 44),
		Vector2(0, 36),     # Center cleft
		Vector2(18, 44),
		Vector2(38, 40),
		Vector2(46, 26),
		Vector2(40, 14),
		Vector2(20, 6)
	])
	draw_colored_polygon(jowls_pts, style.muzzle_cream_color)
	
	# Jowls underside cel shadows (Left and Right crescents)
	var left_shadow := PackedVector2Array([
		Vector2(-38, 36),
		Vector2(-18, 41),
		Vector2(-6, 37),
		Vector2(-18, 44),
		Vector2(-38, 40)
	])
	draw_colored_polygon(left_shadow, style.muzzle_shadow_color)
	
	var right_shadow := PackedVector2Array([
		Vector2(6, 37),
		Vector2(18, 41),
		Vector2(38, 36),
		Vector2(38, 40),
		Vector2(18, 44)
	])
	draw_colored_polygon(right_shadow, style.muzzle_shadow_color)
	
	var loop := PackedVector2Array()
	for p in jowls_pts: loop.append(p)
	loop.append(jowls_pts[0])
	CosmoInkStroke.from_points(loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Center vertical cleft line from nose down to jowls valley
	draw_line(Vector2(0, 16), Vector2(0, 36), style.ink_color, style.inner_line_width)
	
	# Subtle whisker follicle dots
	draw_circle(Vector2(-26, 26), 1.4, style.ink_color)
	draw_circle(Vector2(-32, 28), 1.4, style.ink_color)
	draw_circle(Vector2(-24, 32), 1.4, style.ink_color)
	
	draw_circle(Vector2(26, 26), 1.4, style.ink_color)
	draw_circle(Vector2(32, 28), 1.4, style.ink_color)
	draw_circle(Vector2(24, 32), 1.4, style.ink_color)

func _draw_dog_nose() -> void:
	# Prominent shiny black dog nose at Vector2(0, 8)
	var nose_center := Vector2(0, 8)
	var nose_pts := PackedVector2Array([
		nose_center + Vector2(-15, -6),
		nose_center + Vector2(15, -6),
		nose_center + Vector2(14, 4),
		nose_center + Vector2(0, 12), # Pointed bottom lobe
		nose_center + Vector2(-14, 4)
	])
	draw_colored_polygon(nose_pts, style.nose_black_color)
	var loop := PackedVector2Array()
	for p in nose_pts: loop.append(p)
	loop.append(nose_pts[0])
	CosmoInkStroke.from_points(loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Shiny specular glint on upper-left nose bridge
	draw_circle(nose_center + Vector2(-5, -2), 3.0, Color(1, 1, 1, 0.75))
	draw_circle(nose_center + Vector2(-1, -3), 1.8, Color(1, 1, 1, 0.55))

func _draw_mouth() -> void:
	var mouth_y := 34.0
	
	match mouth_shape:
		"panting":
			# Canine panting mode: pink tongue lolling out!
			var tongue_pts := PackedVector2Array([
				Vector2(-10, mouth_y),
				Vector2(10, mouth_y),
				Vector2(12, mouth_y + 18),
				Vector2(0, mouth_y + 24), # Rounded tip
				Vector2(-12, mouth_y + 18)
			])
			draw_colored_polygon(tongue_pts, style.tongue_pink_color)
			var t_loop := PackedVector2Array()
			for p in tongue_pts: t_loop.append(p)
			t_loop.append(tongue_pts[0])
			CosmoInkStroke.from_points(t_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
			# Tongue center groove
			draw_line(Vector2(0, mouth_y + 2), Vector2(0, mouth_y + 18), style.ink_color, 1.4)
		
		"growl":
			# Snarl exposing sharp canine fangs
			var growl_pts := PackedVector2Array([
				Vector2(-16, mouth_y),
				Vector2(16, mouth_y),
				Vector2(14, mouth_y + 10),
				Vector2(-14, mouth_y + 10)
			])
			draw_colored_polygon(growl_pts, style.navy_shadow_color)
			# Top sharp fangs
			draw_line(Vector2(-12, mouth_y), Vector2(-10, mouth_y + 8), style.eye_sclera_color, 2.5)
			draw_line(Vector2(12, mouth_y), Vector2(10, mouth_y + 8), style.eye_sclera_color, 2.5)
			var g_loop := PackedVector2Array()
			for p in growl_pts: g_loop.append(p)
			g_loop.append(growl_pts[0])
			CosmoInkStroke.from_points(g_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
		
		"bark":
			# Open barking mouth
			var bark_pts := PackedVector2Array([
				Vector2(-18, mouth_y),
				Vector2(18, mouth_y),
				Vector2(12, mouth_y + 16),
				Vector2(-12, mouth_y + 16)
			])
			draw_colored_polygon(bark_pts, style.navy_shadow_color)
			# Lower jaw rim
			draw_line(Vector2(-12, mouth_y + 16), Vector2(12, mouth_y + 16), style.fur_shadow_color, 3.5)
			var b_loop := PackedVector2Array()
			for p in bark_pts: b_loop.append(p)
			b_loop.append(bark_pts[0])
			CosmoInkStroke.from_points(b_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
		
		"smirk":
			# Cocked officer smirk under right jowl
			draw_line(Vector2(-6, mouth_y + 2), Vector2(-18, mouth_y - 2), style.ink_color, style.inner_line_width)
		
		"deadpan":
			# Flat straight line
			draw_line(Vector2(-16, mouth_y + 3), Vector2(16, mouth_y + 3), style.ink_color, style.inner_line_width)
		
		_: # "neutral"
			# Stoic lip line under center jowl valley
			draw_line(Vector2(-12, mouth_y + 2), Vector2(12, mouth_y + 2), style.ink_color, style.inner_line_width)

func _draw_sweat_drop() -> void:
	var drop_pos := Vector2(42, -26)
	var pts := PackedVector2Array([
		drop_pos,
		drop_pos + Vector2(4, 7),
		drop_pos + Vector2(3, 13),
		drop_pos + Vector2(0, 15),
		drop_pos + Vector2(-3, 13),
		drop_pos + Vector2(-4, 7)
	])
	draw_colored_polygon(pts, Color(0.65, 0.88, 1.0, 0.9))
	var loop := PackedVector2Array()
	for p in pts: loop.append(p)
	loop.append(pts[0])
	CosmoInkStroke.from_points(loop, 1.4, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)

func _draw_anger_mark() -> void:
	var mark_pos := Vector2(-38, -32)
	var col := Color("#dc3232")
	draw_arc(mark_pos + Vector2(-4, -4), 4.0, 0, PI * 0.5, 8, col, 2.0)
	draw_arc(mark_pos + Vector2(4, -4), 4.0, PI * 0.5, PI, 8, col, 2.0)
	draw_arc(mark_pos + Vector2(-4, 4), 4.0, -PI * 0.5, 0, 8, col, 2.0)
	draw_arc(mark_pos + Vector2(4, 4), 4.0, PI, PI * 1.5, 8, col, 2.0)

func _draw_sparkle() -> void:
	var spark_pos := Vector2(28, -48)
	var rad: float = 8.0
	var pts := PackedVector2Array([
		spark_pos + Vector2(0, -rad),
		spark_pos + Vector2(rad * 0.25, -rad * 0.25),
		spark_pos + Vector2(rad, 0),
		spark_pos + Vector2(rad * 0.25, rad * 0.25),
		spark_pos + Vector2(0, rad),
		spark_pos + Vector2(-rad * 0.25, rad * 0.25),
		spark_pos + Vector2(-rad, 0),
		spark_pos + Vector2(-rad * 0.25, -rad * 0.25)
	])
	draw_colored_polygon(pts, Color("#f8e050"))
	var loop := PackedVector2Array()
	for p in pts: loop.append(p)
	loop.append(pts[0])
	CosmoInkStroke.from_points(loop, 1.2, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
