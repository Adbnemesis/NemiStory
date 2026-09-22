class_name LeonFace
extends Node2D

## Face, Cowl Shadow, Eye Glints, Tooth Smirk, Visemes & Lollipop for LEON (Brawl Stars)
## Implements the deep cowl shadow over upper face, expressive eyes peeking through,
## iconic cheeky tooth smirk, speech mouth visemes, signature blue lollipop, and FX overlays.

const LeonStyle = preload("res://brawl_stars/characters/leon/LeonStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: LeonStyle

# Directorial facial parameters
var eye_state: String = "normal"          # normal, wide_shock, deadpan, smug, wink, angry
var eye_openness: float = 1.0
var blink_ratio: float = 0.0             # 0.0 = open, 1.0 = fully closed
var gaze_direction: Vector2 = Vector2.ZERO # normalized (-1.0 to 1.0)
var mouth_shape: String = "smirk"        # smirk, talk_open, talk_narrow, shout, deadpan, smile, frown
var mouth_openness: float = 0.0          # 0.0 to 1.0
var has_lollipop: bool = true
var lollipop_angle: float = 0.25         # angle of the lollipop stick

# FX Overlays
var show_sweat: bool = false
var show_anger: bool = false
var show_sparkle: bool = false
var show_shock_lines: bool = false

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Face Opening Geometry (Tanned Skin Base)
	_draw_face_base()
	
	# 2. Deep Cowl Shadow Gradient (covering upper half)
	_draw_cowl_shadow()
	
	# 3. Eyes & Pupils (Peeking through the cowl shadow)
	_draw_eyes()
	
	# 4. Cute Curved Nose
	_draw_nose()
	
	# 5. Mouth Viseme & Tooth Grin
	_draw_mouth()
	
	# 6. Signature Lollipop (Pink/Magenta Candy)
	if has_lollipop:
		_draw_lollipop()
	
	# 7. FX Overlays (Sweat, Sparkle, Anger cross, Shock lines)
	_draw_fx_overlays()

func _draw_face_base() -> void:
	# Face cutout inside the hood
	# From Y = -35 down to chin at Y = 28
	var face_pts := PackedVector2Array([
		Vector2(-38, -32),
		Vector2(-42, -6),
		Vector2(-36, 16),
		Vector2(-22, 28),
		Vector2(0, 32),
		Vector2(22, 28),
		Vector2(36, 16),
		Vector2(42, -6),
		Vector2(38, -32),
		Vector2(0, -38)
	])
	draw_colored_polygon(face_pts, style.skin_tan_color)
	
	# Lower jaw / chin shadow
	var chin_shadow := PackedVector2Array([
		Vector2(-24, 24),
		Vector2(0, 32),
		Vector2(24, 24),
		Vector2(0, 27)
	])
	draw_colored_polygon(chin_shadow, style.skin_tan_shadow_color)
	
	# Inner hood opening rim
	draw_polyline(face_pts, style.ink_color, style.inner_line_width, true)

func _draw_cowl_shadow() -> void:
	# Deep dark shadow cast over the eyes and upper forehead by the hoodie cowl
	var shadow_pts := PackedVector2Array([
		Vector2(-42, -34),
		Vector2(-44, -6),
		Vector2(-35, 2),
		Vector2(0, 6),
		Vector2(35, 2),
		Vector2(44, -6),
		Vector2(42, -34),
		Vector2(0, -40)
	])
	draw_colored_polygon(shadow_pts, style.cowl_deep_shadow_color)
	
	# Soft secondary drop shadow edge
	var rim_pts := PackedVector2Array([
		Vector2(-38, 0),
		Vector2(-18, 5),
		Vector2(0, 7),
		Vector2(18, 5),
		Vector2(38, 0),
		Vector2(34, -2),
		Vector2(0, 4),
		Vector2(-34, -2)
	])
	draw_colored_polygon(rim_pts, Color(0.04, 0.06, 0.04, 0.45))

func _draw_eyes() -> void:
	# Eye centers relative to face center
	var left_eye_center := Vector2(-16, -10) + gaze_direction * Vector2(4.0, 2.5)
	var right_eye_center := Vector2(16, -10) + gaze_direction * Vector2(4.0, 2.5)
	
	var effective_openness := eye_openness * (1.0 - blink_ratio)
	
	if effective_openness < 0.1:
		# Fully closed eyes / blink lines
		draw_line(left_eye_center + Vector2(-8, 0), left_eye_center + Vector2(8, 0), Color.WHITE, style.lash_line_width, true)
		draw_line(right_eye_center + Vector2(-8, 0), right_eye_center + Vector2(8, 0), Color.WHITE, style.lash_line_width, true)
		return
	
	match eye_state:
		"wide_shock":
			# Huge wide cartoon eyes popping vividly out of the dark cowl shadow!
			var r := 11.0 * effective_openness
			draw_circle(left_eye_center, r, Color.WHITE)
			draw_circle(right_eye_center, r, Color.WHITE)
			# Pinprick pupils
			draw_circle(left_eye_center + gaze_direction * 2.0, 3.2, style.ink_color)
			draw_circle(right_eye_center + gaze_direction * 2.0, 3.2, style.ink_color)
			# Outer contour
			draw_arc(left_eye_center, r, 0, TAU, 24, style.ink_color, 2.2, true)
			draw_arc(right_eye_center, r, 0, TAU, 24, style.ink_color, 2.2, true)
		
		"deadpan":
			# Flat, unbothered horizontal eye slits
			draw_line(left_eye_center + Vector2(-9, 0), left_eye_center + Vector2(9, 0), Color.WHITE, 3.2, true)
			draw_line(right_eye_center + Vector2(-9, 0), right_eye_center + Vector2(9, 0), Color.WHITE, 3.2, true)
			# Small pupil dashes beneath
			draw_circle(left_eye_center, 2.5, style.ink_color)
			draw_circle(right_eye_center, 2.5, style.ink_color)
		
		"smug":
			# Angled cocky eye slits pointing up toward nose
			var pts_l := PackedVector2Array([
				left_eye_center + Vector2(-8, 2),
				left_eye_center + Vector2(0, -3 * effective_openness),
				left_eye_center + Vector2(8, -1)
			])
			var pts_r := PackedVector2Array([
				right_eye_center + Vector2(-8, -1),
				right_eye_center + Vector2(0, -3 * effective_openness),
				right_eye_center + Vector2(8, 2)
			])
			draw_polyline(pts_l, Color.WHITE, 3.2, true)
			draw_polyline(pts_r, Color.WHITE, 3.2, true)
			draw_circle(left_eye_center + Vector2(1, -1), 2.8, style.ink_color)
			draw_circle(right_eye_center + Vector2(-1, -1), 2.8, style.ink_color)
			# Specular shine
			draw_circle(left_eye_center + Vector2(2, -2), 1.2, Color.WHITE)
			draw_circle(right_eye_center + Vector2(0, -2), 1.2, Color.WHITE)
		
		_: # "normal" / mischievous gleam
			# Glowing sharp white triangle/crescent gleams through the dark shadow
			var h := 6.0 * effective_openness
			var l_eye_poly := PackedVector2Array([
				left_eye_center + Vector2(-9, 1),
				left_eye_center + Vector2(-4, -h),
				left_eye_center + Vector2(8, -2),
				left_eye_center + Vector2(4, 2)
			])
			var r_eye_poly := PackedVector2Array([
				right_eye_center + Vector2(-8, -2),
				right_eye_center + Vector2(4, -h),
				right_eye_center + Vector2(9, 1),
				right_eye_center + Vector2(-4, 2)
			])
			draw_colored_polygon(l_eye_poly, Color.WHITE)
			draw_colored_polygon(r_eye_poly, Color.WHITE)
			
			# Indigo pupil dots
			draw_circle(left_eye_center + Vector2(0, -1), 3.0, style.shorts_indigo_color)
			draw_circle(right_eye_center + Vector2(0, -1), 3.0, style.shorts_indigo_color)
			
			# Specular highlights
			draw_circle(left_eye_center + Vector2(-1, -2), 1.4, Color.WHITE)
			draw_circle(right_eye_center + Vector2(-1, -2), 1.4, Color.WHITE)
			
			# Lash line
			draw_polyline(l_eye_poly, style.ink_color, 1.8, true)
			draw_polyline(r_eye_poly, style.ink_color, 1.8, true)

func _draw_mouth() -> void:
	var mouth_center := Vector2(2, 17)
	
	match mouth_shape:
		"closed", "rest":
			# Closed cheeky line with slight mischievous upward right corner
			var closed_pts := PackedVector2Array([
				mouth_center + Vector2(-12, 1),
				mouth_center + Vector2(0, 3),
				mouth_center + Vector2(13, -1)
			])
			draw_polyline(closed_pts, style.ink_color, 2.6, true)
			draw_line(mouth_center + Vector2(13, -2), mouth_center + Vector2(16, 0), style.ink_color, 1.8, true)
		
		"small_open":
			# Subtle conversational speech viseme (consonants & unstressed vowels)
			var h := 3.5 + mouth_openness * 4.5
			var talk_pts := PackedVector2Array([
				mouth_center + Vector2(-10, 0),
				mouth_center + Vector2(0, -2),
				mouth_center + Vector2(11, 0),
				mouth_center + Vector2(8, h),
				mouth_center + Vector2(0, h + 1.5),
				mouth_center + Vector2(-7, h)
			])
			draw_colored_polygon(talk_pts, style.mouth_interior_color)
			# Upper teeth bar
			var teeth_bar := PackedVector2Array([
				mouth_center + Vector2(-9, 0),
				mouth_center + Vector2(10, 0),
				mouth_center + Vector2(8, 2.2),
				mouth_center + Vector2(-7, 2.2)
			])
			draw_colored_polygon(teeth_bar, style.mouth_tooth_color)
			draw_polyline(talk_pts, style.ink_color, style.inner_line_width, true)
		
		"ae", "a_e":
			# Wide horizontal opening for open front vowels ("cat", "say", "bed")
			var h := 5.0 + mouth_openness * 6.0
			var ae_pts := PackedVector2Array([
				mouth_center + Vector2(-15, -2),
				mouth_center + Vector2(0, -4),
				mouth_center + Vector2(15, -2),
				mouth_center + Vector2(12, h),
				mouth_center + Vector2(0, h + 2.0),
				mouth_center + Vector2(-12, h)
			])
			draw_colored_polygon(ae_pts, style.mouth_interior_color)
			# Top teeth strip
			var top_teeth := PackedVector2Array([
				mouth_center + Vector2(-13, -1),
				mouth_center + Vector2(13, -1),
				mouth_center + Vector2(10, 2.5),
				mouth_center + Vector2(-10, 2.5)
			])
			draw_colored_polygon(top_teeth, style.mouth_tooth_color)
			# Lower red tongue hint
			draw_circle(mouth_center + Vector2(0, h), 4.5, Color("#e04860"))
			draw_polyline(ae_pts, style.ink_color, style.inner_line_width, true)
		
		"o_u":
			# Rounded pursed circular mouth ("go", "you", "who", "oh")
			var rx := 6.5 + mouth_openness * 1.5
			var ry := 7.0 + mouth_openness * 2.5
			draw_set_transform(mouth_center + Vector2(1, 1), 0.0, Vector2(1.0, ry / rx))
			draw_circle(Vector2.ZERO, rx, style.mouth_interior_color)
			draw_circle(Vector2(0, rx * 0.4), rx * 0.5, Color("#e04860"))
			draw_arc(Vector2.ZERO, rx, 0, TAU, 24, style.ink_color, 2.2, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		
		"wide":
			# Large open mouth for shouting, high-energy con-artist pitch, or screaming
			var h := 9.0 + mouth_openness * 7.0
			var wide_pts := PackedVector2Array([
				mouth_center + Vector2(-17, -4),
				mouth_center + Vector2(0, -6),
				mouth_center + Vector2(17, -4),
				mouth_center + Vector2(14, h),
				mouth_center + Vector2(0, h + 3.0),
				mouth_center + Vector2(-14, h)
			])
			draw_colored_polygon(wide_pts, style.mouth_interior_color)
			# Top teeth
			var top_teeth := PackedVector2Array([
				mouth_center + Vector2(-14, -3),
				mouth_center + Vector2(14, -3),
				mouth_center + Vector2(11, 2.0),
				mouth_center + Vector2(-11, 2.0)
			])
			draw_colored_polygon(top_teeth, style.mouth_tooth_color)
			# Bottom teeth
			var bot_teeth := PackedVector2Array([
				mouth_center + Vector2(-10, h + 1.0),
				mouth_center + Vector2(10, h + 1.0),
				mouth_center + Vector2(8, h - 2.5),
				mouth_center + Vector2(-8, h - 2.5)
			])
			draw_colored_polygon(bot_teeth, style.mouth_tooth_color)
			# Red tongue
			draw_circle(mouth_center + Vector2(0, h - 1.0), 6.5, Color("#e04860"))
			draw_polyline(wide_pts, style.ink_color, style.inner_line_width, true)
		
		"smirk":
			# Iconic Leon cheeky diagonal smirk showing white upper tooth row
			var smirk_pts := PackedVector2Array([
				mouth_center + Vector2(-14, 0),
				mouth_center + Vector2(-4, 6),
				mouth_center + Vector2(10, 3),
				mouth_center + Vector2(18, -4), # upturned cheek corner
				mouth_center + Vector2(8, 0),
				mouth_center + Vector2(-2, 1)
			])
			# Dark interior
			draw_colored_polygon(smirk_pts, style.mouth_interior_color)
			
			# White sharp tooth gleam along the upper lip
			var tooth_pts := PackedVector2Array([
				mouth_center + Vector2(-10, 1),
				mouth_center + Vector2(12, -1),
				mouth_center + Vector2(8, 2),
				mouth_center + Vector2(-6, 3)
			])
			draw_colored_polygon(tooth_pts, style.mouth_tooth_color)
			
			# Ink outline & cheek dimple
			draw_polyline(smirk_pts, style.ink_color, style.inner_line_width, true)
			draw_line(mouth_center + Vector2(16, -6), mouth_center + Vector2(21, -2), style.ink_color, 1.8, true)
		
		"shout":
			# Screaming panic wide open mouth
			var shout_pts := PackedVector2Array([
				mouth_center + Vector2(-18, -4),
				mouth_center + Vector2(0, -7),
				mouth_center + Vector2(18, -4),
				mouth_center + Vector2(15, 12),
				mouth_center + Vector2(0, 15),
				mouth_center + Vector2(-15, 12)
			])
			draw_colored_polygon(shout_pts, style.mouth_interior_color)
			# Top teeth
			var top_teeth := PackedVector2Array([
				mouth_center + Vector2(-15, -3),
				mouth_center + Vector2(0, -5),
				mouth_center + Vector2(15, -3),
				mouth_center + Vector2(12, 1),
				mouth_center + Vector2(0, 0),
				mouth_center + Vector2(-12, 1)
			])
			draw_colored_polygon(top_teeth, style.mouth_tooth_color)
			# Red tongue at bottom
			draw_circle(mouth_center + Vector2(0, 10), 7.0, Color("#e04860"))
			draw_polyline(shout_pts, style.ink_color, style.outer_contour_width, true)
		
		"talk_open":
			# Active talking viseme
			var open_h := 6.0 + mouth_openness * 7.0
			var talk_pts := PackedVector2Array([
				mouth_center + Vector2(-12, -2),
				mouth_center + Vector2(0, -4),
				mouth_center + Vector2(12, -2),
				mouth_center + Vector2(8, open_h),
				mouth_center + Vector2(0, open_h + 2),
				mouth_center + Vector2(-8, open_h)
			])
			draw_colored_polygon(talk_pts, style.mouth_interior_color)
			# Upper teeth bar
			var teeth_bar := PackedVector2Array([
				mouth_center + Vector2(-10, -1),
				mouth_center + Vector2(10, -1),
				mouth_center + Vector2(8, 2),
				mouth_center + Vector2(-8, 2)
			])
			draw_colored_polygon(teeth_bar, style.mouth_tooth_color)
			draw_polyline(talk_pts, style.ink_color, style.inner_line_width, true)
		
		"deadpan":
			# Deadpan flat horizontal line
			draw_line(mouth_center + Vector2(-12, 1), mouth_center + Vector2(12, 1), style.ink_color, 2.5, true)
		
		"frown":
			# Disappointed curved frown
			var pts := PackedVector2Array([
				mouth_center + Vector2(-12, 4),
				mouth_center + Vector2(0, -1),
				mouth_center + Vector2(12, 4)
			])
			draw_polyline(pts, style.ink_color, 2.5, true)
		
		_: # "smile"
			var pts := PackedVector2Array([
				mouth_center + Vector2(-14, -1),
				mouth_center + Vector2(0, 6),
				mouth_center + Vector2(14, -1)
			])
			draw_polyline(pts, style.ink_color, 2.5, true)

func _draw_nose() -> void:
	# Subtle curved nose bridge/tip line above the mouth
	draw_arc(Vector2(2, 9), 3.5, 0.1, PI * 0.85, 12, style.ink_color, 2.0, true)

func _draw_lollipop() -> void:
	# White lollipop stick extending out from cheek corner of mouth
	# Adjust stick angle dynamically when mouth opens during speech
	var stick_offset_x := 14.0 + (mouth_openness * 3.0 if mouth_shape in ["ae", "wide", "shout", "talk_open"] else 0.0)
	var stick_root := Vector2(stick_offset_x, 18)
	var dynamic_angle := lollipop_angle + (0.15 * mouth_openness if mouth_shape in ["ae", "wide", "shout"] else 0.0)
	var stick_dir := Vector2(cos(dynamic_angle), sin(dynamic_angle))
	var stick_len := 26.0
	var stick_end := stick_root + stick_dir * stick_len
	
	# White plastic stick
	draw_line(stick_root, stick_end, style.lollipop_stick_color, 3.2, true)
	draw_line(stick_root, stick_end, style.ink_color, 1.2, true)
	
	# Spherical magenta/pink candy ball
	var ball_center := stick_end + stick_dir * 10.0
	var ball_radius := 11.0
	
	# Candy base fill (Magenta/Pink)
	draw_circle(ball_center, ball_radius, style.lollipop_candy_color)
	# Cel shadow on lower hemisphere
	draw_circle(ball_center + Vector2(1.5, 2.0), ball_radius * 0.75, style.lollipop_candy_shadow_color)
	draw_circle(ball_center + Vector2(-1.0, -1.0), ball_radius * 0.7, style.lollipop_candy_color)
	# White curved specular highlight
	draw_arc(ball_center + Vector2(-3, -3), ball_radius * 0.55, -PI * 0.8, -PI * 0.2, 16, Color.WHITE, 2.2, true)
	draw_circle(ball_center + Vector2(-4, -4), 2.0, Color.WHITE)
	
	# Ink contour
	draw_arc(ball_center, ball_radius, 0, TAU, 28, style.ink_color, style.inner_line_width, true)

func _draw_fx_overlays() -> void:
	if show_sweat:
		# Cyan cartoon panic sweat drop near forehead/temple
		var drop_pos := Vector2(-34, -16)
		var drop_pts := PackedVector2Array([
			drop_pos,
			drop_pos + Vector2(-5, 8),
			drop_pos + Vector2(0, 13),
			drop_pos + Vector2(5, 8)
		])
		draw_colored_polygon(drop_pts, style.sweat_color)
		draw_circle(drop_pos + Vector2(-1, 9), 1.8, Color.WHITE)
		draw_polyline(drop_pts, style.ink_color, 1.8, true)
	
	if show_anger:
		# Red 4-curve anger cross mark
		var c := Vector2(30, -22)
		draw_arc(c + Vector2(-5, 0), 6.0, -0.8, 0.8, 8, style.anger_color, 2.8, true)
		draw_arc(c + Vector2(5, 0), 6.0, PI - 0.8, PI + 0.8, 8, style.anger_color, 2.8, true)
		draw_arc(c + Vector2(0, -5), 6.0, 0.8, PI - 0.8, 8, style.anger_color, 2.8, true)
		draw_arc(c + Vector2(0, 5), 6.0, -PI + 0.8, -0.8, 8, style.anger_color, 2.8, true)
	
	if show_sparkle:
		# 4-point yellow star sparkle on tooth grin
		var sc := Vector2(18, 14)
		var sparkle_pts := PackedVector2Array([
			sc + Vector2(0, -9),
			sc + Vector2(2.5, -2.5),
			sc + Vector2(9, 0),
			sc + Vector2(2.5, 2.5),
			sc + Vector2(0, 9),
			sc + Vector2(-2.5, 2.5),
			sc + Vector2(-9, 0),
			sc + Vector2(-2.5, -2.5)
		])
		draw_colored_polygon(sparkle_pts, style.sparkle_color)
		draw_circle(sc, 2.0, Color.WHITE)
		draw_polyline(sparkle_pts, style.ink_color, 1.2, true)
	
	if show_shock_lines:
		# Vertical dark shock lines over forehead
		for x in [-22, -14, -6, 2, 10, 18]:
			draw_line(Vector2(x, -28), Vector2(x, -14), Color("#102438"), 1.6, true)
