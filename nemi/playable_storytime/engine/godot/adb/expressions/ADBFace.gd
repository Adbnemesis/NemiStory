class_name ADBFace
extends Node2D

## Independent Procedural Vector Facial System for ADB Character
## Renders handsome almond anime eyes, mobile expressive eyebrows,
## detailed iris highlights, nose shadow, dynamic mouth visemes, and cheek blush.
## Origin (0, 0) is Chin apex. All features are positioned relative to chin.

const ADBStyle = preload("res://adb/characters/adb/ADBStyle.gd")
const CommonInkStroke = preload("res://common/engine/drawing/CommonInkStroke.gd")

signal expression_changed(new_expression: String)

enum ADBExpressionState {
	NEUTRAL,
	CUTE,
	SMUG,
	EMBARRASSED,
	DEADPAN,
	EXCITED,
	ANNOYED,
	CONFUSED,
	SHOCKED,
	HAPPY,
	AMUSED,
	TIRED,
	SURPRISED,
	FRUSTRATED,
	TEARY_CRY,
	SAD,
	NERVOUS_SWEAT,
	DETERMINED,
	EXHAUSTED,
	PROUD,
	MISCHIEVOUS,
	POUT
}

var current_expression: ADBExpressionState = ADBExpressionState.NEUTRAL
var expression_name: String = "neutral"

# Eye controls (centered at Y = -48)
var eye_openness_left: float = 1.0     # 0.0 (closed) to 1.4 (wide shock)
var eye_openness_right: float = 1.0
var eye_gaze: Vector2 = Vector2.ZERO   # Normalized (-1.0 to 1.0)
var eye_sparkle: bool = false          # Anime starry glint for excited state

# Eyebrow controls (centered at Y = -66)
var brow_left_angle: float = 0.0       # Degrees tilt
var brow_right_angle: float = 0.0
var brow_left_height: float = 0.0      # Offset in pixels
var brow_right_height: float = 0.0

# Mouth controls (centered at Y = -16)
var mouth_state: String = "neutral"
var mouth_openness: float = 0.0

# Cheek blush (at Y = -36)
var blush_intensity: float = 0.0

# Subtle anime emotional accents
var tear_intensity: float = 0.0        # 0.0 to 1.0 delicate glassy watery tears
var sweat_intensity: float = 0.0       # 0.0 to 1.0 temple sweat teardrop bead

var _face_tween: Tween
var _blink_tween: Tween

# Geometric landmarks relative to Chin apex (0, 0)
const EYE_POS_LEFT: Vector2 = Vector2(-22, -48)
const EYE_POS_RIGHT: Vector2 = Vector2(22, -48)
const EYE_WIDTH: float = 20.0
const EYE_HEIGHT: float = 12.0

const BROW_POS_LEFT: Vector2 = Vector2(-23, -66)
const BROW_POS_RIGHT: Vector2 = Vector2(23, -66)

const NOSE_POS: Vector2 = Vector2(0, -32)
const MOUTH_POS: Vector2 = Vector2(0, -16)

func _ready() -> void:
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# 1. Nose (subtle stylish anime shadow dot & crease)
	_draw_nose()
	
	# 2. Cheek Blush (if active)
	if blush_intensity > 0.01:
		_draw_blush()
		
	# 3. Eyes (Sclera, Iris, Pupil, Catchlights, Upper & Lower Lashes)
	_draw_eye(EYE_POS_LEFT, eye_openness_left, false)
	_draw_eye(EYE_POS_RIGHT, eye_openness_right, true)
	
	# 4. Eyebrows
	_draw_eyebrows()
	
	# 5. Mouth
	_draw_mouth()

	# 6. Delicate emotional accents: Tears & Temple Sweat
	if tear_intensity > 0.01:
		_draw_tears()
	if sweat_intensity > 0.01:
		_draw_temple_sweat()

func _draw_nose() -> void:
	# Small vertical ink tick and subtle shadow dot
	var n_col: Color = ADBStyle.INK_CONTOUR
	draw_line(NOSE_POS + Vector2(-1, -4), NOSE_POS + Vector2(1, 0), n_col, 2.0, true)
	draw_circle(NOSE_POS + Vector2(2, 0), 1.2, n_col)

func _draw_blush() -> void:
	var alpha := clampf(blush_intensity, 0.0, 1.0)
	var col := Color(0.957, 0.52, 0.48, alpha * 0.55)
	
	# Soft elliptical cheeks
	_draw_ellipse(Vector2(-28, -36), 14.0, 7.0, col)
	_draw_ellipse(Vector2(28, -36), 14.0, 7.0, col)
	
	# Flustered hatch lines if high blush
	if blush_intensity > 0.4:
		var hatch_col := Color(0.85, 0.32, 0.32, alpha * 0.75)
		for i in range(3):
			var x_off: float = float(i) * 5.0 - 5.0
			draw_line(Vector2(-30 + x_off, -40), Vector2(-26 + x_off, -32), hatch_col, 1.8)
			draw_line(Vector2(26 + x_off, -40), Vector2(30 + x_off, -32), hatch_col, 1.8)

func _draw_eye(center: Vector2, openness: float, is_right: bool) -> void:
	var flip: float = 1.0 if is_right else -1.0
	var h: float = EYE_HEIGHT * clampf(openness, 0.05, 1.4)
	var w: float = EYE_WIDTH
	
	# If eye is closed (blink), draw calligraphic lash line
	if openness <= 0.12:
		var closed_pts := PackedVector2Array([
			center + Vector2(-w * 0.5 * flip, 1),
			center + Vector2(-w * 0.1 * flip, 3),
			center + Vector2(w * 0.3 * flip, 2),
			center + Vector2(w * 0.55 * flip, -1)
		])
		var stroke := CommonInkStroke.from_points(closed_pts, 3.2, CommonInkStroke.Profile.CALLIGRAPHIC_LASH, ADBStyle.INK_CONTOUR)
		stroke.draw_to(self)
		return
	
	# Sclera (Eye white)
	var sclera_pts := PackedVector2Array([
		center + Vector2(-w * 0.5 * flip, 0),
		center + Vector2(-w * 0.2 * flip, -h * 0.48),
		center + Vector2(w * 0.2 * flip, -h * 0.52),
		center + Vector2(w * 0.5 * flip, -h * 0.1),
		center + Vector2(w * 0.25 * flip, h * 0.45),
		center + Vector2(-w * 0.25 * flip, h * 0.40)
	])
	draw_colored_polygon(sclera_pts, Color(0.98, 0.98, 0.99, 1.0))
	
	# Iris & Pupil
	var gaze_offset := Vector2(eye_gaze.x * 4.5, eye_gaze.y * 2.5)
	var iris_center := center + gaze_offset + Vector2(0.5 * flip, -0.5)
	var iris_r := clampf(h * 0.42, 3.5, 6.0)
	
	# Dark Slate Navy Iris
	draw_circle(iris_center, iris_r, Color("#263248"))
	draw_circle(iris_center, iris_r * 0.65, Color("#131a26"))
	
	if eye_sparkle:
		# 4-point star sparkle
		var sc := iris_center
		draw_line(sc + Vector2(-4, 0), sc + Vector2(4, 0), Color.WHITE, 2.0)
		draw_line(sc + Vector2(0, -4), sc + Vector2(0, 4), Color.WHITE, 2.0)
	else:
		# Specular catchlight
		draw_circle(iris_center + Vector2(-1.8 * flip, -1.8), 1.8, Color.WHITE)
		draw_circle(iris_center + Vector2(2.0 * flip, 1.5), 1.0, Color(1, 1, 1, 0.7))
	
	# Eyelid Crease (double lid line)
	var crease_pts := PackedVector2Array([
		center + Vector2(-w * 0.35 * flip, -h * 0.72),
		center + Vector2(0, -h * 0.80),
		center + Vector2(w * 0.35 * flip, -h * 0.70)
	])
	var crease_stroke := CommonInkStroke.from_points(crease_pts, 1.6, CommonInkStroke.Profile.DELICATE_CREASE, ADBStyle.INK_CONTOUR)
	crease_stroke.draw_to(self)
	
	# Upper Eyelid Lash Line (Authored calligraphic sweep with outer wing flick)
	var lash_pts := PackedVector2Array([
		center + Vector2(-w * 0.52 * flip, 0),
		center + Vector2(-w * 0.2 * flip, -h * 0.50),
		center + Vector2(w * 0.15 * flip, -h * 0.54),
		center + Vector2(w * 0.48 * flip, -h * 0.25),
		center + Vector2(w * 0.65 * flip, -h * 0.42) # Wing flick
	])
	var lash_stroke := CommonInkStroke.from_points(lash_pts, 3.6, CommonInkStroke.Profile.CALLIGRAPHIC_LASH, ADBStyle.INK_CONTOUR)
	lash_stroke.draw_to(self)
	
	# Lower Lash Accent
	var lower_pts := PackedVector2Array([
		center + Vector2(-w * 0.20 * flip, h * 0.42),
		center + Vector2(w * 0.30 * flip, h * 0.45)
	])
	draw_polyline(lower_pts, ADBStyle.INK_CONTOUR, 1.8, true)

func _draw_eyebrows() -> void:
	_draw_single_eyebrow(BROW_POS_LEFT + Vector2(0, -brow_left_height), brow_left_angle, false)
	_draw_single_eyebrow(BROW_POS_RIGHT + Vector2(0, -brow_right_height), brow_right_angle, true)

func _draw_single_eyebrow(origin: Vector2, angle_deg: float, is_right: bool) -> void:
	var flip: float = 1.0 if is_right else -1.0
	var rad := deg_to_rad(angle_deg * flip)
	
	var pts := PackedVector2Array([
		origin + Vector2(-12 * flip, 2).rotated(rad),
		origin + Vector2(-3 * flip, -3).rotated(rad),
		origin + Vector2(8 * flip, -2).rotated(rad),
		origin + Vector2(14 * flip, 3).rotated(rad)
	])
	
	var stroke := CommonInkStroke.from_points(pts, 3.0, CommonInkStroke.Profile.TAPER_BOTH, ADBStyle.INK_CONTOUR)
	stroke.draw_to(self)

func _draw_mouth() -> void:
	match mouth_state:
		"neutral":
			# Composed, relaxed horizontal mouth line
			var pts := PackedVector2Array([
				MOUTH_POS + Vector2(-10, 1),
				MOUTH_POS + Vector2(0, 0),
				MOUTH_POS + Vector2(10, 1)
			])
			var stroke := CommonInkStroke.from_points(pts, 2.8, CommonInkStroke.Profile.TAPER_BOTH, ADBStyle.INK_CONTOUR)
			stroke.draw_to(self)
			
			# Subtle lower lip shadow accent
			draw_line(MOUTH_POS + Vector2(-3, 6), MOUTH_POS + Vector2(3, 6), ADBStyle.SKIN_SHADOW, 2.0)
			
		"smile":
			# Warm, pleasant upward curve
			var pts := PackedVector2Array([
				MOUTH_POS + Vector2(-11, -1),
				MOUTH_POS + Vector2(-6, 3),
				MOUTH_POS + Vector2(6, 3),
				MOUTH_POS + Vector2(11, -1)
			])
			var stroke := CommonInkStroke.from_points(pts, 3.0, CommonInkStroke.Profile.TAPER_BOTH, ADBStyle.INK_CONTOUR)
			stroke.draw_to(self)
			draw_line(MOUTH_POS + Vector2(-3, 7), MOUTH_POS + Vector2(3, 7), ADBStyle.SKIN_SHADOW, 2.0)
			
		"smirk":
			# Charismatic cocky right-side smirk
			var pts := PackedVector2Array([
				MOUTH_POS + Vector2(-9, 2),
				MOUTH_POS + Vector2(0, 1),
				MOUTH_POS + Vector2(8, -2),
				MOUTH_POS + Vector2(12, -6)
			])
			var stroke := CommonInkStroke.from_points(pts, 3.2, CommonInkStroke.Profile.TAPER_BOTH, ADBStyle.INK_CONTOUR)
			stroke.draw_to(self)
			draw_line(MOUTH_POS + Vector2(-1, 6), MOUTH_POS + Vector2(5, 5), ADBStyle.SKIN_SHADOW, 2.0)
			
		"deadpan":
			# Rigid flat dash for comedic hold
			draw_line(MOUTH_POS + Vector2(-11, 0), MOUTH_POS + Vector2(11, 0), ADBStyle.INK_CONTOUR, 3.2, true)
			
		"small_o":
			# Small surprised / flustered 'o'
			_draw_ellipse(MOUTH_POS + Vector2(0, 2), 5.0, 6.0, ADBStyle.INK_CONTOUR)
			
		"talk_open":
			var oral := PackedVector2Array([
				MOUTH_POS + Vector2(-9, -2),
				MOUTH_POS + Vector2(9, -2),
				MOUTH_POS + Vector2(7, 8),
				MOUTH_POS + Vector2(-7, 8)
			])
			draw_colored_polygon(oral, ADBStyle.INK_CONTOUR)
			draw_colored_polygon([
				MOUTH_POS + Vector2(-5, 4),
				MOUTH_POS + Vector2(5, 4),
				MOUTH_POS + Vector2(4, 7),
				MOUTH_POS + Vector2(-4, 7)
			], Color("#d96860"))
			draw_polyline(oral, ADBStyle.INK_CONTOUR, 2.5, true)
			
		"talk_wide":
			var oral := PackedVector2Array([
				MOUTH_POS + Vector2(-13, -3),
				MOUTH_POS + Vector2(13, -3),
				MOUTH_POS + Vector2(10, 11),
				MOUTH_POS + Vector2(-10, 11)
			])
			draw_colored_polygon(oral, ADBStyle.INK_CONTOUR)
			# Upper teeth bar
			draw_line(MOUTH_POS + Vector2(-10, -2), MOUTH_POS + Vector2(10, -2), Color.WHITE, 2.5)
			# Tongue
			draw_colored_polygon([
				MOUTH_POS + Vector2(-6, 5),
				MOUTH_POS + Vector2(6, 5),
				MOUTH_POS + Vector2(5, 10),
				MOUTH_POS + Vector2(-5, 10)
			], Color("#d96860"))
			draw_polyline(oral, ADBStyle.INK_CONTOUR, 2.8, true)
			
		"talk_round":
			_draw_ellipse(MOUTH_POS + Vector2(0, 2), 7.0, 8.0, ADBStyle.INK_CONTOUR)

		"quiver", "wobbly":
			# Quivering, emotional wavy mouth for suppressed tears
			var pts := PackedVector2Array([
				MOUTH_POS + Vector2(-10, 2),
				MOUTH_POS + Vector2(-5, -1),
				MOUTH_POS + Vector2(0, 2),
				MOUTH_POS + Vector2(5, -1),
				MOUTH_POS + Vector2(10, 2)
			])
			var stroke := CommonInkStroke.from_points(pts, 2.6, CommonInkStroke.Profile.TAPER_BOTH, ADBStyle.INK_CONTOUR)
			stroke.draw_to(self)
			draw_line(MOUTH_POS + Vector2(-2, 6), MOUTH_POS + Vector2(2, 6), ADBStyle.SKIN_SHADOW, 1.8)

		"grimace", "clenched":
			# Clenched teeth line for intense focus, heavy effort, or athletic determination
			var rect_pts := PackedVector2Array([
				MOUTH_POS + Vector2(-11, -2),
				MOUTH_POS + Vector2(11, -2),
				MOUTH_POS + Vector2(9, 4),
				MOUTH_POS + Vector2(-9, 4)
			])
			draw_colored_polygon(rect_pts, Color.WHITE)
			draw_polyline(rect_pts, ADBStyle.INK_CONTOUR, 2.4, true)
			draw_line(MOUTH_POS + Vector2(-4, -1), MOUTH_POS + Vector2(-4, 3), ADBStyle.INK_INNER, 1.4)
			draw_line(MOUTH_POS + Vector2(0, -1), MOUTH_POS + Vector2(0, 3), ADBStyle.INK_INNER, 1.4)
			draw_line(MOUTH_POS + Vector2(4, -1), MOUTH_POS + Vector2(4, 3), ADBStyle.INK_INNER, 1.4)

		"pout":
			# Downward sulky anime pout curve
			var pts := PackedVector2Array([
				MOUTH_POS + Vector2(-9, 3),
				MOUTH_POS + Vector2(0, 0),
				MOUTH_POS + Vector2(9, 3)
			])
			var stroke := CommonInkStroke.from_points(pts, 2.8, CommonInkStroke.Profile.TAPER_BOTH, ADBStyle.INK_CONTOUR)
			stroke.draw_to(self)
			draw_line(MOUTH_POS + Vector2(-3, 6), MOUTH_POS + Vector2(3, 6), ADBStyle.SKIN_SHADOW, 2.0)

		"nervous_grin":
			# Flustered asymmetric nervous grimace/grin
			var pts := PackedVector2Array([
				MOUTH_POS + Vector2(-10, 1),
				MOUTH_POS + Vector2(-3, 4),
				MOUTH_POS + Vector2(5, 1),
				MOUTH_POS + Vector2(11, -3)
			])
			var stroke := CommonInkStroke.from_points(pts, 2.8, CommonInkStroke.Profile.TAPER_BOTH, ADBStyle.INK_CONTOUR)
			stroke.draw_to(self)
			draw_line(MOUTH_POS + Vector2(0, 6), MOUTH_POS + Vector2(6, 4), ADBStyle.SKIN_SHADOW, 1.8)

		"cat_smirk":
			# Mischievous playful cat mouth :3
			var l_w := PackedVector2Array([MOUTH_POS + Vector2(-10, 0), MOUTH_POS + Vector2(-5, 4), MOUTH_POS + Vector2(0, 1)])
			var r_w := PackedVector2Array([MOUTH_POS + Vector2(0, 1), MOUTH_POS + Vector2(5, 4), MOUTH_POS + Vector2(10, 0)])
			draw_polyline(l_w, ADBStyle.INK_CONTOUR, 2.4, false)
			draw_polyline(r_w, ADBStyle.INK_CONTOUR, 2.4, false)

		_:
			draw_line(MOUTH_POS + Vector2(-8, 0), MOUTH_POS + Vector2(8, 0), ADBStyle.INK_CONTOUR, 2.5, true)

func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var pts := PackedVector2Array()
	var segs := 20
	for i in range(segs):
		var th := float(i) * TAU / float(segs)
		pts.append(center + Vector2(cos(th) * rx, sin(th) * ry))
	draw_colored_polygon(pts, color)

func _draw_tears() -> void:
	var alpha := clampf(tear_intensity, 0.0, 1.0)
	var water_tint := Color(0.70, 0.88, 1.0, alpha * 0.75)
	var water_stream := Color(0.55, 0.80, 0.98, alpha * 0.60)
	var white_sparkle := Color(1.0, 1.0, 1.0, alpha * 0.90)

	# 1. Glistening glassy water wells along lower lash line (delicate anime water highlight)
	_draw_ellipse(EYE_POS_LEFT + Vector2(2, 5), 7.5, 2.5, water_tint)
	_draw_ellipse(EYE_POS_RIGHT + Vector2(-2, 5), 7.5, 2.5, water_tint)

	# 2. Delicate bright specular catchlights
	draw_circle(EYE_POS_LEFT + Vector2(-5, 4), 1.5, white_sparkle)
	draw_circle(EYE_POS_LEFT + Vector2(6, 4), 1.2, white_sparkle)
	draw_circle(EYE_POS_RIGHT + Vector2(5, 4), 1.5, white_sparkle)
	draw_circle(EYE_POS_RIGHT + Vector2(-6, 4), 1.2, white_sparkle)

	# 3. Delicate organic trickling tear streams down cheeks (subtle 1.8px line, NOT giant blobs)
	if tear_intensity > 0.25:
		var l_tear_pts := PackedVector2Array([
			EYE_POS_LEFT + Vector2(4, 6),
			EYE_POS_LEFT + Vector2(6, 14),
			EYE_POS_LEFT + Vector2(3, 23)
		])
		draw_polyline(l_tear_pts, water_stream, 2.0, false)
		draw_circle(EYE_POS_LEFT + Vector2(3, 24), 2.4, water_tint)
		draw_circle(EYE_POS_LEFT + Vector2(2.4, 23.6), 1.0, white_sparkle)

		var r_tear_pts := PackedVector2Array([
			EYE_POS_RIGHT + Vector2(-4, 6),
			EYE_POS_RIGHT + Vector2(-6, 14),
			EYE_POS_RIGHT + Vector2(-3, 23)
		])
		draw_polyline(r_tear_pts, water_stream, 2.0, false)
		draw_circle(EYE_POS_RIGHT + Vector2(-3, 24), 2.4, water_tint)
		draw_circle(EYE_POS_RIGHT + Vector2(-3.6, 23.6), 1.0, white_sparkle)

func _draw_temple_sweat() -> void:
	var alpha := clampf(sweat_intensity, 0.0, 1.0)
	var sw_pos := Vector2(38, -68) # Temple position relative to chin apex (0, 0)
	var sw_tint := Color(0.65, 0.85, 1.0, alpha * 0.85)

	# Classic subtle anime sweat teardrop: sleek, compact, 12px tall, 6px wide
	var drop_pts := PackedVector2Array([
		sw_pos + Vector2(0, -8),
		sw_pos + Vector2(3.5, -2),
		sw_pos + Vector2(3.0, 5),
		sw_pos + Vector2(0, 7),
		sw_pos + Vector2(-3.0, 5),
		sw_pos + Vector2(-3.5, -2)
	])
	draw_colored_polygon(drop_pts, sw_tint)
	draw_polyline(drop_pts, ADBStyle.INK_CONTOUR, 1.5, true)
	draw_circle(sw_pos + Vector2(-1.2, 2.0), 1.0, Color(1, 1, 1, alpha * 0.95))

func set_expression(expr_name: String, duration: float = 0.15) -> void:
	expression_name = expr_name.to_lower()
	
	var target_openness := 1.0
	var target_sparkle := false
	var target_brow_angle := 0.0
	var target_brow_height := 0.0
	var target_brow_r_angle := 0.0
	var target_brow_r_height := 0.0
	var target_mouth := "neutral"
	var target_blush := 0.0
	var target_gaze := Vector2.ZERO
	var target_tear := 0.0
	var target_sweat := 0.0
	
	match expression_name:
		"neutral":
			current_expression = ADBExpressionState.NEUTRAL
			target_openness = 1.0
			target_mouth = "neutral"
			
		"cute":
			current_expression = ADBExpressionState.CUTE
			target_openness = 1.08
			target_brow_angle = 3.0
			target_brow_r_angle = 3.0
			target_mouth = "smile"
			target_blush = 0.70
			
		"smug":
			current_expression = ADBExpressionState.SMUG
			target_openness = 0.80
			target_brow_angle = -2.0
			target_brow_r_angle = 14.0 # Arched eyebrow
			target_brow_r_height = 5.0
			target_mouth = "smirk"
			
		"deadpan":
			current_expression = ADBExpressionState.DEADPAN
			target_openness = 0.45
			target_mouth = "deadpan"
			target_brow_angle = 0.0
			target_brow_r_angle = 0.0
			target_brow_height = 0.0
			target_brow_r_height = 0.0
			target_tear = 0.0
			target_sweat = 0.0
			target_blush = 0.0
			tear_intensity = 0.0
			sweat_intensity = 0.0
			
		"excited":
			current_expression = ADBExpressionState.EXCITED
			target_openness = 1.25
			target_sparkle = true
			target_brow_angle = 6.0
			target_brow_r_angle = 6.0
			target_brow_height = 5.0
			target_brow_r_height = 5.0
			target_mouth = "talk_wide"
			target_blush = 0.35
			
		"embarrassed":
			current_expression = ADBExpressionState.EMBARRASSED
			target_openness = 0.90
			target_brow_angle = -6.0
			target_brow_r_angle = -6.0
			target_mouth = "small_o"
			target_blush = 0.90
			
		"shocked":
			current_expression = ADBExpressionState.SHOCKED
			target_openness = 1.35
			target_brow_angle = 8.0
			target_brow_r_angle = 8.0
			target_brow_height = 7.0
			target_brow_r_height = 7.0
			target_mouth = "small_o"
			
		"confused":
			current_expression = ADBExpressionState.CONFUSED
			target_openness = 0.90
			target_brow_angle = -6.0 # Furrowed left
			target_brow_r_angle = 10.0 # Raised right
			target_brow_r_height = 4.0
			target_mouth = "neutral"
			
		"annoyed":
			current_expression = ADBExpressionState.ANNOYED
			target_openness = 0.65
			target_brow_angle = -8.0
			target_brow_r_angle = -8.0
			target_mouth = "deadpan"
			
		"happy":
			current_expression = ADBExpressionState.HAPPY
			target_openness = 1.05
			target_mouth = "smile"
			target_brow_angle = 2.0
			target_brow_r_angle = 2.0
			
		"amused":
			current_expression = ADBExpressionState.AMUSED
			target_openness = 0.85
			target_mouth = "smirk"
			target_brow_r_angle = 8.0

		"teary_cry", "crying", "cry":
			current_expression = ADBExpressionState.TEARY_CRY
			target_openness = 0.80
			target_brow_angle = -11.0 # Pained sorrowful brows arched in middle
			target_brow_r_angle = -11.0
			target_brow_height = -2.0
			target_brow_r_height = -2.0
			target_mouth = "quiver"
			target_tear = 0.95
			target_blush = 0.45

		"sad":
			current_expression = ADBExpressionState.SAD
			target_openness = 0.75
			target_brow_angle = -8.0
			target_brow_r_angle = -8.0
			target_mouth = "pout"
			target_tear = 0.45

		"nervous_sweat", "flustered":
			current_expression = ADBExpressionState.NERVOUS_SWEAT
			target_openness = 0.88
			target_brow_angle = -7.0
			target_brow_r_angle = 6.0
			target_mouth = "nervous_grin"
			target_sweat = 1.0
			target_blush = 0.40

		"determined":
			current_expression = ADBExpressionState.DETERMINED
			target_openness = 0.95
			target_brow_angle = 11.0 # Sharp downward furrow
			target_brow_r_angle = 11.0
			target_brow_height = -4.0
			target_brow_r_height = -4.0
			target_mouth = "grimace"

		"exhausted", "tired":
			current_expression = ADBExpressionState.EXHAUSTED
			target_openness = 0.40
			target_brow_angle = -4.0
			target_brow_r_angle = -4.0
			target_mouth = "quiver"

		"proud":
			current_expression = ADBExpressionState.PROUD
			target_openness = 0.08 # Arched closed smile eyes
			target_brow_angle = 4.0
			target_brow_r_angle = 4.0
			target_mouth = "smile"
			target_blush = 0.30

		"mischievous":
			current_expression = ADBExpressionState.MISCHIEVOUS
			target_openness = 0.82
			target_brow_r_angle = 9.0
			target_mouth = "cat_smirk"

		"pout":
			current_expression = ADBExpressionState.POUT
			target_openness = 0.80
			target_brow_angle = -5.0
			target_brow_r_angle = -5.0
			target_mouth = "pout"
			target_blush = 0.55

		_:
			current_expression = ADBExpressionState.NEUTRAL
			target_openness = 1.0
			target_mouth = "neutral"
	
	eye_sparkle = target_sparkle
	mouth_state = target_mouth
	
	if duration <= 0.001:
		eye_openness_left = target_openness
		eye_openness_right = target_openness
		brow_left_angle = target_brow_angle
		brow_right_angle = target_brow_r_angle
		brow_left_height = target_brow_height
		brow_right_height = target_brow_r_height
		blush_intensity = target_blush
		tear_intensity = target_tear
		sweat_intensity = target_sweat
		queue_redraw()
		return
		
	if _face_tween and _face_tween.is_valid():
		_face_tween.kill()
		
	_face_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_face_tween.tween_property(self, "eye_openness_left", target_openness, duration)
	_face_tween.tween_property(self, "eye_openness_right", target_openness, duration)
	_face_tween.tween_property(self, "brow_left_angle", target_brow_angle, duration)
	_face_tween.tween_property(self, "brow_right_angle", target_brow_r_angle, duration)
	_face_tween.tween_property(self, "brow_left_height", target_brow_height, duration)
	_face_tween.tween_property(self, "brow_right_height", target_brow_r_height, duration)
	_face_tween.tween_property(self, "blush_intensity", target_blush, duration)
	_face_tween.tween_property(self, "tear_intensity", target_tear, duration)
	_face_tween.tween_property(self, "sweat_intensity", target_sweat, duration)
	_face_tween.step_finished.connect(func(_idx): queue_redraw())
	_face_tween.finished.connect(queue_redraw)
	
	expression_changed.emit(expression_name)

func blink(duration: float = 0.14) -> void:
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	var prev_l := eye_openness_left
	var prev_r := eye_openness_right
	
	_blink_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_blink_tween.tween_property(self, "eye_openness_left", 0.0, duration * 0.45)
	_blink_tween.parallel().tween_property(self, "eye_openness_right", 0.0, duration * 0.45)
	_blink_tween.tween_property(self, "eye_openness_left", prev_l, duration * 0.55).set_ease(Tween.EASE_OUT)
	_blink_tween.parallel().tween_property(self, "eye_openness_right", prev_r, duration * 0.55).set_ease(Tween.EASE_OUT)
	_blink_tween.step_finished.connect(func(_idx): queue_redraw())
	_blink_tween.finished.connect(queue_redraw)

func look_at_direction(gaze: Vector2) -> void:
	eye_gaze = gaze.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
	queue_redraw()

func set_mouth(mouth_shape: String) -> void:
	mouth_state = mouth_shape
	queue_redraw()

func set_mouth_viseme(viseme: String) -> void:
	set_mouth(viseme)

func set_blush(intensity: float, duration: float = 0.20) -> void:
	if duration <= 0.001:
		blush_intensity = intensity
		queue_redraw()
		return
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "blush_intensity", intensity, duration)
	tw.step_finished.connect(func(_idx): queue_redraw())
	tw.finished.connect(queue_redraw)
