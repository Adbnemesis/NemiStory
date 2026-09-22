class_name EdgarFace
extends Node2D

## Blank Emo Eyes, Heavy Eyeliner, Fatigue Bags & Visemes for EDGAR (Brawl Stars)
## Implements the iconic white pupilless emo eyes, thick black eyeliner, fatigue under-eye bags,
## sharp brows, mouth visemes (above scarf collar), and cynical comedic FX overlays.

const EdgarStyle = preload("res://brawl_stars/characters/edgar/EdgarStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: EdgarStyle

# Directorial facial parameters
var eye_state: String = "normal"          # normal, deadpan, shock, annoyed, toxic_smug, closed
var eye_openness: float = 1.0
var blink_ratio: float = 0.0             # 0.0 = open, 1.0 = fully closed
var gaze_direction: Vector2 = Vector2.ZERO # normalized (-1.0 to 1.0)
var mouth_shape: String = "deadpan"       # deadpan, smirk, talk_open, shout, sarcastic_frown
var mouth_openness: float = 0.0

# FX Overlays
var show_sweat: bool = false
var show_anger: bool = false
var show_dark_lines: bool = false
var show_toxic_sparkle: bool = false

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Under-Eye Fatigue Bags & Purple Shadow
	_draw_undereye_shadows()
	
	# 2. White Emo Eyes & Thick Black Eyeliner
	_draw_eyes()
	
	# 3. Eyebrows
	_draw_eyebrows()
	
	# 4. Subtle Nose Tip
	_draw_nose()
	
	# 5. Mouth Viseme (peeking over scarf)
	_draw_mouth()
	
	# 6. FX Overlays
	_draw_fx_overlays()

func _draw_undereye_shadows() -> void:
	# Subtle purple fatigue bags under eyes
	var l_pos := Vector2(-18, -12)
	var r_pos := Vector2(18, -12)
	
	draw_circle(l_pos + Vector2(0, 8), 10.0, style.eye_shadow_purple_color)
	draw_circle(r_pos + Vector2(0, 8), 10.0, style.eye_shadow_purple_color)

func _draw_eyes() -> void:
	var l_center := Vector2(-18, -14) + gaze_direction * Vector2(3.5, 2.0)
	var r_center := Vector2(18, -14) + gaze_direction * Vector2(3.5, 2.0)
	
	var effective_openness := eye_openness * (1.0 - blink_ratio)
	
	if effective_openness < 0.1:
		# Heavy closed eye lines with winged eyeliner
		draw_line(l_center + Vector2(-11, 0), l_center + Vector2(11, 0), style.ink_color, style.lash_line_width, true)
		draw_line(r_center + Vector2(-11, 0), r_center + Vector2(11, 0), style.ink_color, style.lash_line_width, true)
		return
	
	match eye_state:
		"shock":
			# Huge wide blank white eyes with tiny pinprick pupils of pure disgust/horror!
			var r := 11.5 * effective_openness
			draw_circle(l_center, r, Color.WHITE)
			draw_circle(r_center, r, Color.WHITE)
			draw_circle(l_center + gaze_direction * 2.0, 2.8, style.ink_color)
			draw_circle(r_center + gaze_direction * 2.0, 2.8, style.ink_color)
			draw_arc(l_center, r, 0, TAU, 24, style.ink_color, 2.6, true)
			draw_arc(r_center, r, 0, TAU, 24, style.ink_color, 2.6, true)
		
		"deadpan":
			# Flat straight unbothered horizontal slits
			draw_line(l_center + Vector2(-12, 0), l_center + Vector2(12, 0), style.ink_color, 3.8, true)
			draw_line(r_center + Vector2(-12, 0), r_center + Vector2(12, 0), style.ink_color, 3.8, true)
			# Tiny sliver of white under the line
			draw_line(l_center + Vector2(-8, 3), l_center + Vector2(8, 3), Color.WHITE, 2.2, true)
			draw_line(r_center + Vector2(-8, 3), r_center + Vector2(8, 3), Color.WHITE, 2.2, true)
		
		"annoyed":
			# Angled angry glare
			var l_eye := PackedVector2Array([
				l_center + Vector2(-11, -3),
				l_center + Vector2(9, 3),
				l_center + Vector2(0, 8 * effective_openness)
			])
			var r_eye := PackedVector2Array([
				r_center + Vector2(-9, 3),
				r_center + Vector2(11, -3),
				r_center + Vector2(0, 8 * effective_openness)
			])
			draw_colored_polygon(l_eye, Color.WHITE)
			draw_colored_polygon(r_eye, Color.WHITE)
			draw_polyline(l_eye, style.ink_color, 2.8, true)
			draw_polyline(r_eye, style.ink_color, 2.8, true)
			# Small pupil dot
			draw_circle(l_center + Vector2(1, 2), 2.5, style.ink_color)
			draw_circle(r_center + Vector2(-1, 2), 2.5, style.ink_color)
		
		"toxic_smug":
			# Half-lidded mocking gaze
			var l_smug := PackedVector2Array([
				l_center + Vector2(-11, 0),
				l_center + Vector2(11, -2),
				l_center + Vector2(8, 6 * effective_openness),
				l_center + Vector2(-8, 6 * effective_openness)
			])
			var r_smug := PackedVector2Array([
				r_center + Vector2(-11, -2),
				r_center + Vector2(11, 0),
				r_center + Vector2(8, 6 * effective_openness),
				r_center + Vector2(-8, 6 * effective_openness)
			])
			draw_colored_polygon(l_smug, Color.WHITE)
			draw_colored_polygon(r_smug, Color.WHITE)
			draw_circle(l_center + Vector2(2, 2), 3.0, style.ink_color)
			draw_circle(r_center + Vector2(-2, 2), 3.0, style.ink_color)
			draw_polyline(l_smug, style.ink_color, 2.5, true)
			draw_polyline(r_smug, style.ink_color, 2.5, true)
		
		_: # "normal"
			# Iconic Edgar large white oval blank eyes with thick top eyeliner wing
			var rx := 10.5
			var ry := 12.0 * effective_openness
			
			draw_set_transform(l_center, -0.08, Vector2(1.0, ry / rx))
			draw_circle(Vector2.ZERO, rx, Color.WHITE)
			draw_arc(Vector2.ZERO, rx, 0, TAU, 28, style.ink_color, 2.2, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			
			draw_set_transform(r_center, 0.08, Vector2(1.0, ry / rx))
			draw_circle(Vector2.ZERO, rx, Color.WHITE)
			draw_arc(Vector2.ZERO, rx, 0, TAU, 28, style.ink_color, 2.2, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			
			# Heavy black top lash / winged liner
			draw_line(l_center + Vector2(-13, -ry * 0.8), l_center + Vector2(12, -ry * 0.9), style.ink_color, style.lash_line_width, true)
			draw_line(r_center + Vector2(-12, -ry * 0.9), r_center + Vector2(13, -ry * 0.8), style.ink_color, style.lash_line_width, true)

func _draw_eyebrows() -> void:
	# Sharp dark emo brows
	match eye_state:
		"annoyed", "toxic_smug":
			draw_line(Vector2(-28, -26), Vector2(-8, -22), style.ink_color, 3.2, true)
			draw_line(Vector2(8, -22), Vector2(28, -26), style.ink_color, 3.2, true)
		"shock":
			# Raised high in disbelief
			draw_line(Vector2(-26, -34), Vector2(-10, -32), style.ink_color, 2.8, true)
			draw_line(Vector2(10, -32), Vector2(26, -34), style.ink_color, 2.8, true)
		_:
			# Flat skeptical brows
			draw_line(Vector2(-26, -28), Vector2(-10, -28), style.ink_color, 2.6, true)
			draw_line(Vector2(10, -28), Vector2(26, -28), style.ink_color, 2.6, true)

func _draw_nose() -> void:
	# Subtle curved nose bridge/tip line above the mouth
	draw_arc(Vector2(0, 3), 3.2, 0.15, PI * 0.85, 12, style.ink_color, 1.8, true)

func _draw_mouth() -> void:
	# Sits right at the upper edge of the high scarf collar at Y = 10
	var mouth_center := Vector2(0, 8)
	
	match mouth_shape:
		"closed", "rest":
			# Tight cynical lip seal
			draw_line(mouth_center + Vector2(-8, 3), mouth_center + Vector2(8, 3), style.ink_color, 2.5, true)
		
		"small_open":
			# Subtle conversational speech slit (consonants & unstressed vowels)
			var h := 2.5 + mouth_openness * 3.5
			var talk_pts := PackedVector2Array([
				mouth_center + Vector2(-7, 0),
				mouth_center + Vector2(7, 0),
				mouth_center + Vector2(4, h),
				mouth_center + Vector2(-4, h)
			])
			draw_colored_polygon(talk_pts, Color("#381018"))
			draw_polyline(talk_pts, style.ink_color, 2.0, true)
		
		"ae", "a_e":
			# Wide cynical horizontal speech opening ("cat", "say", "whatever")
			var h := 3.5 + mouth_openness * 4.5
			var ae_pts := PackedVector2Array([
				mouth_center + Vector2(-11, 0),
				mouth_center + Vector2(11, 0),
				mouth_center + Vector2(7, h),
				mouth_center + Vector2(-7, h)
			])
			draw_colored_polygon(ae_pts, Color("#381018"))
			draw_polyline(ae_pts, style.ink_color, 2.2, true)
		
		"o_u":
			# Rounded pursed "O" shape peeking over scarf collar ("you", "who", "no")
			var rx := 4.5 + mouth_openness * 1.5
			var ry := 5.5 + mouth_openness * 2.0
			draw_set_transform(mouth_center + Vector2(0, 3), 0.0, Vector2(1.0, ry / rx))
			draw_circle(Vector2.ZERO, rx, Color("#381018"))
			draw_arc(Vector2.ZERO, rx, 0, TAU, 20, style.ink_color, 2.0, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		
		"wide":
			# Wide indignant sarcastic exclamation opening
			var h := 7.0 + mouth_openness * 5.0
			var wide_pts := PackedVector2Array([
				mouth_center + Vector2(-13, -1),
				mouth_center + Vector2(13, -1),
				mouth_center + Vector2(9, h),
				mouth_center + Vector2(-9, h)
			])
			draw_colored_polygon(wide_pts, Color("#381018"))
			draw_polyline(wide_pts, style.ink_color, 2.5, true)
		
		"smirk":
			# Sarcastic one-sided smirk
			var smirk_pts := PackedVector2Array([
				mouth_center + Vector2(-8, 2),
				mouth_center + Vector2(0, 3),
				mouth_center + Vector2(12, -2)
			])
			draw_polyline(smirk_pts, style.ink_color, 2.6, true)
		
		"shout":
			# Rare explosive breakdown shout
			var shout_pts := PackedVector2Array([
				mouth_center + Vector2(-12, -2),
				mouth_center + Vector2(12, -2),
				mouth_center + Vector2(8, 10),
				mouth_center + Vector2(-8, 10)
			])
			draw_colored_polygon(shout_pts, Color("#381018"))
			draw_polyline(shout_pts, style.ink_color, 2.8, true)
		
		"talk_open":
			# Talking opening
			var h := 4.0 + mouth_openness * 5.0
			var talk_pts := PackedVector2Array([
				mouth_center + Vector2(-8, 0),
				mouth_center + Vector2(8, 0),
				mouth_center + Vector2(5, h),
				mouth_center + Vector2(-5, h)
			])
			draw_colored_polygon(talk_pts, Color("#381018"))
			draw_polyline(talk_pts, style.ink_color, 2.2, true)
		
		"sarcastic_frown", "frown":
			var pts := PackedVector2Array([
				mouth_center + Vector2(-10, 4),
				mouth_center + Vector2(0, 1),
				mouth_center + Vector2(10, 4)
			])
			draw_polyline(pts, style.ink_color, 2.4, true)
		
		_: # "deadpan"
			# Flat cynical bar
			draw_line(mouth_center + Vector2(-9, 2), mouth_center + Vector2(9, 2), style.ink_color, 2.6, true)

func _draw_fx_overlays() -> void:
	if show_sweat:
		var drop_pos := Vector2(32, -24)
		var drop_pts := PackedVector2Array([
			drop_pos,
			drop_pos + Vector2(-4, 7),
			drop_pos + Vector2(0, 11),
			drop_pos + Vector2(4, 7)
		])
		draw_colored_polygon(drop_pts, style.sweat_color)
		draw_circle(drop_pos + Vector2(-1, 8), 1.5, Color.WHITE)
		draw_polyline(drop_pts, style.ink_color, 1.6, true)
	
	if show_anger:
		var c := Vector2(-32, -32)
		draw_arc(c + Vector2(-4, 0), 5.0, -0.8, 0.8, 8, style.anger_color, 2.4, true)
		draw_arc(c + Vector2(4, 0), 5.0, PI - 0.8, PI + 0.8, 8, style.anger_color, 2.4, true)
		draw_arc(c + Vector2(0, -4), 5.0, 0.8, PI - 0.8, 8, style.anger_color, 2.4, true)
		draw_arc(c + Vector2(0, 4), 5.0, -PI + 0.8, -0.8, 8, style.anger_color, 2.4, true)
	
	if show_dark_lines:
		# Vertical gloom lines over top of face
		for x in [-24, -16, -8, 0, 8, 16, 24]:
			draw_line(Vector2(x, -36), Vector2(x, -18), Color(0.2, 0.1, 0.3, 0.75), 1.8, true)
	
	if show_toxic_sparkle:
		var sc := Vector2(28, 4)
		var sparkle_pts := PackedVector2Array([
			sc + Vector2(0, -8),
			sc + Vector2(2, -2),
			sc + Vector2(8, 0),
			sc + Vector2(2, 2),
			sc + Vector2(0, 8),
			sc + Vector2(-2, 2),
			sc + Vector2(-8, 0),
			sc + Vector2(-2, -2)
		])
		draw_colored_polygon(sparkle_pts, Color("#d070f8"))
		draw_circle(sc, 1.8, Color.WHITE)
		draw_polyline(sparkle_pts, style.ink_color, 1.2, true)
