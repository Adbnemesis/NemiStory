class_name NemiFace
extends NemiPart

const NemiProportions = preload("res://characters/nemi/NemiProportions.gd")
const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")
const NemiDoodles = preload("res://characters/nemi/drawing/NemiDoodles.gd")

## Live procedural facial drawing system for NEMI
## 100% hand-drawn YouTube storytime illustration quality:
## - Variable-width calligraphic lash bands with lush wing flicks
## - Tall organic bean/pill irises with gradient shading pool and crisp dual highlights
## - Dynamic expressive brush eyebrows with tapering
## - Rich storytime mouth shapes (smile, excited open teeth, shock 'O', cat mouth, smirk, wavy)
## - Soft pink blush ovals with diagonal ink hatch scratches (///)
## - Comedic storytime accents (sweat drops, sparkles, question marks, tension lines)

signal expression_changed(expr_name: String)

enum FaceExpr {
	NEUTRAL,
	HAPPY,
	EXCITED,
	CONFUSED,
	ANGRY,
	SAD,
	EMBARRASSED,
	SHOCKED,
	SMUG,
	ANNOYED,
	LAUGHING,
	DEADPAN,
	TERRIFIED
}

var current_expression: FaceExpr = FaceExpr.NEUTRAL

# Continuous facial parameters
var eye_openness: float = 1.0: # 0.0 = fully closed / smiling squint, 1.0 = normal, 1.35 = shocked
	set(val):
		eye_openness = clampf(val, 0.0, 1.5)
		queue_redraw()

var gaze_direction: Vector2 = Vector2.ZERO: # (-1, 0) = looking left, (1, 0) = looking right
	set(val):
		gaze_direction = val.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
		queue_redraw()

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

var mouth_shape: String = "smile":
	set(val):
		mouth_shape = val
		queue_redraw()

var pupil_scale: float = 1.0:
	set(val):
		pupil_scale = clampf(val, 0.3, 2.2)
		queue_redraw()

var pupil_offset: Vector2 = Vector2.ZERO:
	set(val):
		pupil_offset = val.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
		queue_redraw()

var show_blush: bool = true:
	set(val):
		show_blush = val
		queue_redraw()

var show_sweat_drop: bool = false:
	set(val):
		show_sweat_drop = val
		queue_redraw()

var show_action_lines: bool = false:
	set(val):
		show_action_lines = val
		queue_redraw()

var show_question_mark: bool = false:
	set(val):
		show_question_mark = val
		queue_redraw()

var show_sparkles: bool = false:
	set(val):
		show_sparkles = val
		queue_redraw()

# Blink tween
var _blink_tween: Tween

func set_eyebrow(side: String, offset_y: float, tilt: float) -> void:
	match side.to_lower():
		"left":
			left_brow_offset.y = offset_y
			left_brow_tilt = tilt
		"right":
			right_brow_offset.y = offset_y
			right_brow_tilt = tilt
		_:
			left_brow_offset.y = offset_y
			right_brow_offset.y = offset_y
			left_brow_tilt = tilt
			right_brow_tilt = -tilt
	queue_redraw()

func set_mouth_shape(shape_name: String) -> void:
	mouth_shape = shape_name.to_lower()
	queue_redraw()

func set_micro_accent(accent_name: String, enabled: bool) -> void:
	match accent_name.to_lower():
		"sweat", "sweat_drop":
			show_sweat_drop = enabled
		"action", "action_lines", "shock_lines":
			show_action_lines = enabled
		"question", "question_mark":
			show_question_mark = enabled
		"sparkles", "sparkle":
			show_sparkles = enabled
		"blush":
			show_blush = enabled
	queue_redraw()

func look(dir_name: String) -> void:
	match dir_name.to_lower():
		"left": gaze_direction = Vector2(-0.8, 0.0)
		"right": gaze_direction = Vector2(0.8, 0.0)
		"up": gaze_direction = Vector2(0.0, -0.6)
		"down": gaze_direction = Vector2(0.0, 0.6)
		"up_left": gaze_direction = Vector2(-0.6, -0.5)
		"up_right": gaze_direction = Vector2(0.6, -0.5)
		"down_left": gaze_direction = Vector2(-0.6, 0.5)
		"down_right": gaze_direction = Vector2(0.6, 0.5)
		_: gaze_direction = Vector2.ZERO
	queue_redraw()

func set_expression_by_name(expr_name: String) -> void:
	match expr_name.to_lower():
		"happy":
			set_expression(FaceExpr.HAPPY)
		"excited":
			set_expression(FaceExpr.EXCITED)
		"confused":
			set_expression(FaceExpr.CONFUSED)
		"angry":
			set_expression(FaceExpr.ANGRY)
		"sad":
			set_expression(FaceExpr.SAD)
		"embarrassed":
			set_expression(FaceExpr.EMBARRASSED)
		"shocked":
			set_expression(FaceExpr.SHOCKED)
		"smug":
			set_expression(FaceExpr.SMUG)
		"annoyed":
			set_expression(FaceExpr.ANNOYED)
		"laughing":
			set_expression(FaceExpr.LAUGHING)
		"deadpan":
			set_expression(FaceExpr.DEADPAN)
		"terrified", "scared":
			set_expression(FaceExpr.TERRIFIED)
		_:
			set_expression(FaceExpr.NEUTRAL)

func set_expression(expr: FaceExpr) -> void:
	current_expression = expr
	show_sweat_drop = false
	show_action_lines = false
	show_question_mark = false
	show_sparkles = false
	
	match expr:
		FaceExpr.NEUTRAL:
			eye_openness = 1.0
			gaze_direction = Vector2.ZERO
			left_brow_offset = Vector2.ZERO
			right_brow_offset = Vector2.ZERO
			left_brow_tilt = 0.0
			right_brow_tilt = 0.0
			mouth_shape = "smile"
		
		FaceExpr.HAPPY:
			eye_openness = 0.0 # Cute closed smiling eye arcs (^ ^)
			gaze_direction = Vector2.ZERO
			left_brow_offset = Vector2(0, -4)
			right_brow_offset = Vector2(0, -4)
			left_brow_tilt = 0.1
			right_brow_tilt = -0.1
			mouth_shape = "smile_wide"
			show_sparkles = true
		
		FaceExpr.EXCITED:
			eye_openness = 1.15
			gaze_direction = Vector2(0, -0.2)
			left_brow_offset = Vector2(0, -6)
			right_brow_offset = Vector2(0, -6)
			left_brow_tilt = 0.15
			right_brow_tilt = -0.15
			mouth_shape = "open_excited"
			show_sparkles = true
		
		FaceExpr.CONFUSED:
			eye_openness = 0.95
			gaze_direction = Vector2(-0.4, -0.2)
			left_brow_offset = Vector2(0, -8)  # One brow raised high
			right_brow_offset = Vector2(0, 2)  # Other brow lowered
			left_brow_tilt = 0.25
			right_brow_tilt = 0.1
			mouth_shape = "wavy"
			show_question_mark = true
		
		FaceExpr.ANGRY:
			eye_openness = 0.85
			gaze_direction = Vector2.ZERO
			left_brow_offset = Vector2(0, 5)
			right_brow_offset = Vector2(0, 5)
			left_brow_tilt = -0.32
			right_brow_tilt = 0.32
			mouth_shape = "frown"
		
		FaceExpr.SAD:
			eye_openness = 0.8
			gaze_direction = Vector2(0, 0.3)
			left_brow_offset = Vector2(0, -2)
			right_brow_offset = Vector2(0, -2)
			left_brow_tilt = 0.28
			right_brow_tilt = -0.28
			mouth_shape = "frown"
		
		FaceExpr.EMBARRASSED:
			eye_openness = 0.72
			gaze_direction = Vector2(0.6, 0.2) # Averted shy gaze
			left_brow_offset = Vector2(0, -2)
			right_brow_offset = Vector2(0, -2)
			left_brow_tilt = 0.2
			right_brow_tilt = -0.2
			mouth_shape = "wavy"
			show_sweat_drop = true
		
		FaceExpr.SHOCKED:
			eye_openness = 1.35 # Wide pupil constriction
			gaze_direction = Vector2.ZERO
			left_brow_offset = Vector2(0, -10)
			right_brow_offset = Vector2(0, -10)
			left_brow_tilt = 0.2
			right_brow_tilt = -0.2
			mouth_shape = "open_shocked"
			show_action_lines = true
			show_sweat_drop = true
		
		FaceExpr.SMUG:
			eye_openness = 0.55 # Half-lidded cocky gaze
			gaze_direction = Vector2(-0.6, 0.0)
			left_brow_offset = Vector2(0, -3)
			right_brow_offset = Vector2(0, -5)
			left_brow_tilt = -0.1
			right_brow_tilt = 0.22
			mouth_shape = "smirk"
		
		FaceExpr.ANNOYED:
			eye_openness = 0.8
			gaze_direction = Vector2(0.4, -0.2)
			left_brow_offset = Vector2(0, 4)
			right_brow_offset = Vector2(0, -2)
			left_brow_tilt = -0.25
			right_brow_tilt = 0.1
			mouth_shape = "pout"
			show_sweat_drop = true
		
		FaceExpr.LAUGHING:
			eye_openness = 0.0
			gaze_direction = Vector2.ZERO
			left_brow_offset = Vector2(0, -5)
			right_brow_offset = Vector2(0, -5)
			left_brow_tilt = 0.15
			right_brow_tilt = -0.15
			mouth_shape = "open_excited"
			show_sparkles = true

		FaceExpr.DEADPAN:
			eye_openness = 0.65 # Half-lidded dry unblinking gaze
			gaze_direction = Vector2.ZERO
			left_brow_offset = Vector2.ZERO
			right_brow_offset = Vector2.ZERO
			left_brow_tilt = 0.0
			right_brow_tilt = 0.0
			mouth_shape = "neutral"

		FaceExpr.TERRIFIED:
			eye_openness = 1.35 # Wide panic eyes with constricted pupils
			gaze_direction = Vector2.ZERO
			left_brow_offset = Vector2(0, -12)
			right_brow_offset = Vector2(0, -12)
			left_brow_tilt = 0.35
			right_brow_tilt = -0.35
			mouth_shape = "wavy"
			show_action_lines = true
			show_sweat_drop = true
	
	queue_redraw()
	expression_changed.emit(get_expression_name())

func get_expression_name() -> String:
	return FaceExpr.keys()[current_expression].to_lower()

func trigger_blink(duration: float = 0.18) -> void:
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	
	var orig_openness: float = eye_openness
	_blink_tween = create_tween()
	_blink_tween.tween_property(self, "eye_openness", 0.0, duration * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_blink_tween.tween_property(self, "eye_openness", orig_openness, duration * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	if not style:
		return
	
	# 1. Left Eye (x = -25, y = -48)
	_draw_eye(Vector2(-NemiProportions.EYE_OFFSET_X, NemiProportions.EYE_POS_Y), true)
	
	# 2. Right Eye (x = +25, y = -48)
	_draw_eye(Vector2(NemiProportions.EYE_OFFSET_X, NemiProportions.EYE_POS_Y), false)
	
	# 3. Eyebrows (rendered with sweeping tapered ink brush strokes)
	_draw_eyebrows()
	
	# 4. Illustrated Nose (delicate tapered hook)
	_draw_nose()
	
	# 5. Mouth (hand-drawn illustrated shapes)
	_draw_mouth()
	
	# 6. Cheek Blush (soft warm pink glow + /// hatching)
	if show_blush:
		_draw_blush()
	
	# 7. Comedic Accents
	if show_sweat_drop:
		NemiDoodles.draw_sweat_drop(self, Vector2(38, -52), 11.0, Color("#aee2f8"), style.ink_line_color)
	if show_action_lines:
		NemiDoodles.draw_shock_lines(self, Vector2(0, -90), 5, 20.0, 10.0, style.ink_line_color)
	if show_question_mark:
		NemiDoodles.draw_question_mark(self, Vector2(40, -78), 20.0, Color("#e67e22") if style.current_mode == NemiStyle.ArtMode.COLOR else style.ink_line_color)
	if show_sparkles:
		NemiDoodles.draw_sparkle_star(self, Vector2(-42, -65), 11.0, Color("#fff6b0"), style.ink_line_color)
		NemiDoodles.draw_sparkle_star(self, Vector2(42, -60), 9.0, Color("#fff6b0"), style.ink_line_color)

# -------------------------------------------------------------------------
# EYE RENDERING (Hand-drawn Calligraphic System)
# -------------------------------------------------------------------------

func _draw_eye(center: Vector2, is_left: bool) -> void:
	var sign_x := -1.0 if is_left else 1.0
	
	# 1. Closed Smiling Eye Arc (^ ^)
	if eye_openness < 0.15:
		var closed_c := Curve2D.new()
		closed_c.add_point(center + Vector2(-sign_x * 12, 3), Vector2(0, 0), Vector2(3 * sign_x, -7))
		closed_c.add_point(center + Vector2(0, -5), Vector2(-5 * sign_x, 0), Vector2(5 * sign_x, 0))
		closed_c.add_point(center + Vector2(sign_x * 12, 1), Vector2(-3 * sign_x, -5), Vector2(2 * sign_x, -2))
		closed_c.add_point(center + Vector2(sign_x * 15.5, -2), Vector2(0, 0), Vector2(0, 0)) # Wing flick
		
		var stroke := InkStroke.from_curve(closed_c, style.lash_line_width, InkStroke.Profile.CALLIGRAPHIC_LASH, style.ink_line_color)
		stroke.draw_to(self)
		return
	
	# 2. Almond Sclera Base (smoothly tucked under upper lash)
	var eye_c := Curve2D.new()
	var half_w := 12.0
	var half_h := 8.2 * eye_openness
	eye_c.add_point(center + Vector2(-sign_x * half_w, 1.2), Vector2(0, 0), Vector2(3 * sign_x, -half_h))
	eye_c.add_point(center + Vector2(0, -half_h), Vector2(-5 * sign_x, 0), Vector2(5 * sign_x, 0))
	eye_c.add_point(center + Vector2(sign_x * half_w, 0.0), Vector2(-3 * sign_x, -half_h * 0.7), Vector2(0, 3.5))
	eye_c.add_point(center + Vector2(0, half_h * 0.75), Vector2(4 * sign_x, 0), Vector2(-4 * sign_x, 0))
	var sclera_pts := eye_c.tessellate(4, 2.0)
	draw_colored_polygon(sclera_pts, style.eye_sclera_color)
	
	# 3. Gaze Tracking Center (elevated by -2.2 so iris settles tucked under upper lash)
	var max_gaze_x := 5.2
	var max_gaze_y := 2.8
	var total_gaze := (gaze_direction + pupil_offset).clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
	var pupil_center := center + Vector2(total_gaze.x * max_gaze_x, total_gaze.y * max_gaze_y - 2.2)
	
	# 4. Organic Bean/Pill Iris Shape (Taller than wide, soft anime curvature)
	var is_constricted: bool = (current_expression == FaceExpr.SHOCKED or current_expression == FaceExpr.TERRIFIED)
	var iris_rx := 7.0 if not is_constricted else 3.8
	var iris_ry := (9.0 * clampf(eye_openness, 0.4, 1.1)) if not is_constricted else 4.2
	
	var iris_c := Curve2D.new()
	iris_c.add_point(pupil_center + Vector2(0, -iris_ry), Vector2(-iris_rx * 0.7, 0), Vector2(iris_rx * 0.7, 0))
	iris_c.add_point(pupil_center + Vector2(iris_rx, 0), Vector2(0, -iris_ry * 0.6), Vector2(0, iris_ry * 0.6))
	iris_c.add_point(pupil_center + Vector2(0, iris_ry), Vector2(iris_rx * 0.7, 0), Vector2(-iris_rx * 0.7, 0))
	iris_c.add_point(pupil_center + Vector2(-iris_rx, 0), Vector2(0, iris_ry * 0.6), Vector2(0, -iris_ry * 0.6))
	var iris_pts := iris_c.tessellate(4, 2.0)
	draw_colored_polygon(iris_pts, style.eye_iris_color)
	
	# Luminous lower reflection crescent (Reference A emerald glow)
	if style.current_mode == NemiStyle.ArtMode.COLOR and not is_constricted:
		var crescent_c := Curve2D.new()
		crescent_c.add_point(pupil_center + Vector2(-iris_rx * 0.7, iris_ry * 0.25))
		crescent_c.add_point(pupil_center + Vector2(0, iris_ry * 0.85))
		crescent_c.add_point(pupil_center + Vector2(iris_rx * 0.7, iris_ry * 0.25))
		crescent_c.add_point(pupil_center + Vector2(0, iris_ry * 0.38))
		var crescent_pts := crescent_c.tessellate(3, 2.5)
		draw_colored_polygon(crescent_pts, Color("#6be49f"))
	
	# Upper shadow in iris for rich depth
	var shadow_ry := iris_ry * 0.55
	var shadow_c := Curve2D.new()
	shadow_c.add_point(pupil_center + Vector2(0, -iris_ry), Vector2(-iris_rx * 0.7, 0), Vector2(iris_rx * 0.7, 0))
	shadow_c.add_point(pupil_center + Vector2(iris_rx, -iris_ry * 0.3), Vector2(0, -shadow_ry * 0.5), Vector2(-iris_rx * 0.5, shadow_ry * 0.3))
	shadow_c.add_point(pupil_center + Vector2(0, -iris_ry * 0.05), Vector2(iris_rx * 0.4, 0), Vector2(-iris_rx * 0.4, 0))
	shadow_c.add_point(pupil_center + Vector2(-iris_rx, -iris_ry * 0.3), Vector2(iris_rx * 0.5, shadow_ry * 0.3), Vector2(0, -shadow_ry * 0.5))
	var shadow_pts := shadow_c.tessellate(4, 2.0)
	draw_colored_polygon(shadow_pts, Color(0.06, 0.22, 0.14, 0.65) if style.current_mode == NemiStyle.ArtMode.COLOR else Color(0.1, 0.1, 0.1, 0.55))
	
	# Dark Pupil
	var pupil_rx := (3.4 * pupil_scale) if not is_constricted else (1.8 * pupil_scale)
	var pupil_ry := (4.2 * pupil_scale) if not is_constricted else (2.0 * pupil_scale)
	var pupil_c := Curve2D.new()
	pupil_c.add_point(pupil_center + Vector2(0, -pupil_ry), Vector2(-pupil_rx * 0.7, 0), Vector2(pupil_rx * 0.7, 0))
	pupil_c.add_point(pupil_center + Vector2(pupil_rx, 0), Vector2(0, -pupil_ry * 0.6), Vector2(0, pupil_ry * 0.6))
	pupil_c.add_point(pupil_center + Vector2(0, pupil_ry), Vector2(pupil_rx * 0.7, 0), Vector2(-pupil_rx * 0.7, 0))
	pupil_c.add_point(pupil_center + Vector2(-pupil_rx, 0), Vector2(0, pupil_ry * 0.6), Vector2(0, -pupil_ry * 0.6))
	var pupil_pts := pupil_c.tessellate(4, 2.0)
	draw_colored_polygon(pupil_pts, style.eye_pupil_color)
	
	# Hand-placed Specular Highlights (Top-left key light on BOTH eyes)
	draw_circle(pupil_center + Vector2(-2.4, -2.8), 2.2, style.eye_highlight_color)
	draw_circle(pupil_center + Vector2(2.4, 2.2), 1.1, style.eye_highlight_color)
	
	# 5. Bold Calligraphic Upper Lash Band with Wing Flick
	var lash_c := Curve2D.new()
	lash_c.add_point(center + Vector2(-sign_x * 12.0, 0.8), Vector2(0, 0), Vector2(3 * sign_x, -half_h - 1.8))
	lash_c.add_point(center + Vector2(0, -half_h - 1.8), Vector2(-5 * sign_x, 0), Vector2(5 * sign_x, 0))
	lash_c.add_point(center + Vector2(sign_x * 12.0, -0.6), Vector2(-3 * sign_x, -half_h * 0.5), Vector2(2 * sign_x, -1.8))
	lash_c.add_point(center + Vector2(sign_x * 15.2, -2.8), Vector2(0, 0), Vector2(0, 0)) # Soft anime cat-eye wing
	
	var lash_stroke := InkStroke.from_curve(lash_c, style.lash_line_width, InkStroke.Profile.CALLIGRAPHIC_LASH, style.ink_line_color)
	lash_stroke.draw_to(self)
	
	# 6. Upper Eyelid Fold Crease
	var crease_c := Curve2D.new()
	crease_c.add_point(center + Vector2(-sign_x * 6, -half_h - 4.5))
	crease_c.add_point(center + Vector2(sign_x * 4, -half_h - 4.5))
	var crease_stroke := InkStroke.from_curve(crease_c, style.detail_line_width, InkStroke.Profile.DELICATE_CREASE, style.ink_line_color)
	crease_stroke.draw_to(self)
	
	# 7. Lower Delicate Eyelid Tick
	var lower_c := Curve2D.new()
	lower_c.add_point(center + Vector2(-sign_x * 2.0, half_h * 0.75))
	lower_c.add_point(center + Vector2(sign_x * 3.5, half_h * 0.75))
	var lower_stroke := InkStroke.from_curve(lower_c, style.detail_line_width, InkStroke.Profile.DELICATE_CREASE, style.ink_line_color)
	lower_stroke.draw_to(self)

# -------------------------------------------------------------------------
# EYEBROWS (Calligraphic Tapered Brush Strokes)
# -------------------------------------------------------------------------

func _draw_eyebrows() -> void:
	var left_pos := Vector2(-NemiProportions.EYE_OFFSET_X, NemiProportions.EYEBROW_POS_Y) + left_brow_offset
	var right_pos := Vector2(NemiProportions.EYE_OFFSET_X, NemiProportions.EYEBROW_POS_Y) + right_brow_offset
	var brow_color := Color("#8a281e") if style.current_mode == NemiStyle.ArtMode.COLOR else style.ink_line_color
	
	# Left Eyebrow (graceful 3-point arch)
	var lb := Curve2D.new()
	lb.add_point(left_pos + Vector2(-11, 2 + left_brow_tilt * 8), Vector2(0, 0), Vector2(5, -4))
	lb.add_point(left_pos + Vector2(0, -3 + left_brow_tilt * 4), Vector2(-4, 0), Vector2(4, 0))
	lb.add_point(left_pos + Vector2(10, -1 - left_brow_tilt * 8), Vector2(-4, -2), Vector2(0, 0))
	var l_stroke := InkStroke.from_curve(lb, 2.2, InkStroke.Profile.TAPER_BOTH, brow_color)
	l_stroke.draw_to(self)
	
	# Right Eyebrow (graceful 3-point arch)
	var rb := Curve2D.new()
	rb.add_point(right_pos + Vector2(-10, -1 - right_brow_tilt * 8), Vector2(0, 0), Vector2(4, -2))
	rb.add_point(right_pos + Vector2(0, -3 + right_brow_tilt * 4), Vector2(-4, 0), Vector2(4, 0))
	rb.add_point(right_pos + Vector2(11, 2 + right_brow_tilt * 8), Vector2(-5, -4), Vector2(0, 0))
	var r_stroke := InkStroke.from_curve(rb, 2.2, InkStroke.Profile.TAPER_BOTH, brow_color)
	r_stroke.draw_to(self)

# -------------------------------------------------------------------------
# NOSE (Delicate Minimalist Anime Mark)
# -------------------------------------------------------------------------

func _draw_nose() -> void:
	var ny := NemiProportions.NOSE_POS_Y
	var stroke := InkStroke.from_points(PackedVector2Array([
		Vector2(0.0, ny - 1.2),
		Vector2(0.5, ny + 1.2)
	]), 1.3, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	stroke.draw_to(self)
	draw_circle(Vector2(1.5, ny + 0.8), 0.7, Color(style.skin_shadow_color.r, style.skin_shadow_color.g, style.skin_shadow_color.b, 0.55))

# -------------------------------------------------------------------------
# MOUTH (Hand-drawn Storytime Expressions)
# -------------------------------------------------------------------------

func _draw_mouth() -> void:
	var my := NemiProportions.MOUTH_POS_Y
	var line_color := style.ink_line_color
	match mouth_shape:
		"smile_wide":
			var c := Curve2D.new()
			c.add_point(Vector2(-10, my - 2), Vector2(0, 0), Vector2(4, 4))
			c.add_point(Vector2(0, my + 3.5), Vector2(-4, 0), Vector2(4, 0))
			c.add_point(Vector2(10, my - 2), Vector2(-4, 4), Vector2(0, 0))
			var stroke := InkStroke.from_curve(c, 2.2, InkStroke.Profile.TAPER_BOTH, line_color)
			stroke.draw_to(self)
			draw_circle(Vector2(0, my + 6.5), 1.0, Color(style.skin_shadow_color.r, style.skin_shadow_color.g, style.skin_shadow_color.b, 0.6))
		
		"open_excited":
			# Arched open mouth cavity with upper white teeth bar and pink tongue
			var cavity_c := Curve2D.new()
			cavity_c.add_point(Vector2(-10, my - 2), Vector2(0, 0), Vector2(10, 0))
			cavity_c.add_point(Vector2(10, my - 2), Vector2(-2, 0), Vector2(0, 6))
			cavity_c.add_point(Vector2(8, my + 10), Vector2(2, -4), Vector2(-4, 3))
			cavity_c.add_point(Vector2(0, my + 13), Vector2(4, 0), Vector2(-4, 0))
			cavity_c.add_point(Vector2(-8, my + 10), Vector2(4, 3), Vector2(-2, -4))
			var cavity_pts := cavity_c.tessellate(4, 2.0)
			draw_colored_polygon(cavity_pts, style.mouth_interior_color)
			
			# Tongue pad
			var tongue_c := Curve2D.new()
			tongue_c.add_point(Vector2(-5, my + 11))
			tongue_c.add_point(Vector2(0, my + 7))
			tongue_c.add_point(Vector2(5, my + 11))
			var tongue_pts := tongue_c.tessellate(3, 2.5)
			draw_colored_polygon(tongue_pts, style.mouth_tongue_color)
			
			# Upper teeth bar
			var teeth_pts := PackedVector2Array([
				Vector2(-8, my - 2), Vector2(8, my - 2),
				Vector2(7, my + 2), Vector2(-7, my + 2)
			])
			draw_colored_polygon(teeth_pts, style.mouth_teeth_color)
			
			# Calligraphic lip perimeter
			var outline := InkStroke.from_points(cavity_pts + PackedVector2Array([cavity_pts[0]]), 2.2, InkStroke.Profile.UNIFORM, line_color)
			outline.draw_to(self)
		
		"open_shocked":
			# Vertical oval 'O' mouth
			var shock_c := Curve2D.new()
			shock_c.add_point(Vector2(-6, my - 3), Vector2(0, -3), Vector2(0, 5))
			shock_c.add_point(Vector2(-5, my + 9), Vector2(0, -3), Vector2(5, 2))
			shock_c.add_point(Vector2(0, my + 11), Vector2(-3, 0), Vector2(3, 0))
			shock_c.add_point(Vector2(5, my + 9), Vector2(-5, 2), Vector2(0, -3))
			shock_c.add_point(Vector2(6, my - 3), Vector2(0, 5), Vector2(0, -3))
			shock_c.add_point(Vector2(0, my - 5), Vector2(3, 0), Vector2(-3, 0))
			var shock_pts := shock_c.tessellate(4, 2.0)
			draw_colored_polygon(shock_pts, style.mouth_interior_color)
			var outline := InkStroke.from_points(shock_pts + PackedVector2Array([shock_pts[0]]), 2.0, InkStroke.Profile.UNIFORM, line_color)
			outline.draw_to(self)
		
		"smirk":
			# Asymmetric cocky smirk with corner dimple flick
			var c := Curve2D.new()
			c.add_point(Vector2(-7, my + 1), Vector2(0, 0), Vector2(4, -1))
			c.add_point(Vector2(0, my), Vector2(-4, 0), Vector2(4, -2))
			c.add_point(Vector2(8, my - 3), Vector2(-4, 2), Vector2(2, -2))
			c.add_point(Vector2(10, my - 5), Vector2(0, 0), Vector2(0, 0))
			var stroke := InkStroke.from_curve(c, 2.2, InkStroke.Profile.TAPER_BOTH, line_color)
			stroke.draw_to(self)
		
		"wavy":
			# Squiggly flustered comic mouth
			var pts := PackedVector2Array([
				Vector2(-8, my), Vector2(-4, my + 2.5), Vector2(0, my - 1.5),
				Vector2(4, my + 2.5), Vector2(8, my)
			])
			var stroke := InkStroke.from_points(pts, 2.0, InkStroke.Profile.TAPER_BOTH, line_color)
			stroke.draw_to(self)
		
		"frown":
			var c := Curve2D.new()
			c.add_point(Vector2(-7, my + 3), Vector2(0, 0), Vector2(3.5, -3.5))
			c.add_point(Vector2(0, my), Vector2(-3.5, 0), Vector2(3.5, 0))
			c.add_point(Vector2(7, my + 3), Vector2(-3.5, -3.5), Vector2(0, 0))
			var stroke := InkStroke.from_curve(c, 2.0, InkStroke.Profile.TAPER_BOTH, line_color)
			stroke.draw_to(self)
		
		"neutral":
			var c := Curve2D.new()
			c.add_point(Vector2(-5.0, my), Vector2(0, 0), Vector2(2.5, 0.4))
			c.add_point(Vector2(0, my + 0.3), Vector2(-2.5, 0), Vector2(2.5, 0))
			c.add_point(Vector2(5.0, my), Vector2(-2.5, 0.4), Vector2(0, 0))
			var stroke := InkStroke.from_curve(c, 1.8, InkStroke.Profile.TAPER_BOTH, line_color)
			stroke.draw_to(self)
			draw_circle(Vector2(0, my + 4.5), 0.8, Color(style.skin_shadow_color.r, style.skin_shadow_color.g, style.skin_shadow_color.b, 0.45))
		
		"surprised":
			var c := Curve2D.new()
			c.add_point(Vector2(-4.5, my - 2), Vector2(0, -2), Vector2(0, 4))
			c.add_point(Vector2(0, my + 7), Vector2(-3, 0), Vector2(3, 0))
			c.add_point(Vector2(4.5, my - 2), Vector2(0, 4), Vector2(0, -2))
			c.add_point(Vector2(0, my - 3), Vector2(3, 0), Vector2(-3, 0))
			var pts := c.tessellate(4, 2.0)
			draw_colored_polygon(pts, style.mouth_interior_color)
			var stroke := InkStroke.from_points(pts + PackedVector2Array([pts[0]]), 1.8, InkStroke.Profile.UNIFORM, line_color)
			stroke.draw_to(self)
		
		"pout":
			var pts := PackedVector2Array([
				Vector2(-4, my + 1), Vector2(0, my - 1), Vector2(4, my + 1)
			])
			var stroke := InkStroke.from_points(pts, 2.2, InkStroke.Profile.TAPER_BOTH, line_color)
			stroke.draw_to(self)
		
		_: # Standard Gentle Smile
			var c := Curve2D.new()
			c.add_point(Vector2(-7.5, my - 1.0), Vector2(0, 0), Vector2(3.5, 2.5))
			c.add_point(Vector2(0, my + 1.8), Vector2(-3.5, 0), Vector2(3.5, 0))
			c.add_point(Vector2(7.5, my - 1.0), Vector2(-3.5, 2.5), Vector2(0, 0))
			var stroke := InkStroke.from_curve(c, 2.0, InkStroke.Profile.TAPER_BOTH, line_color)
			stroke.draw_to(self)
			# Subtle lower lip shadow mark
			draw_circle(Vector2(0, my + 5.0), 0.9, Color(style.skin_shadow_color.r, style.skin_shadow_color.g, style.skin_shadow_color.b, 0.5))

# -------------------------------------------------------------------------
# CHEEK BLUSH
# -------------------------------------------------------------------------

func _draw_blush() -> void:
	var left_blush_pos := Vector2(-25, -27)
	var right_blush_pos := Vector2(25, -27)
	
	# Draw soft background glow
	draw_circle(left_blush_pos, 8.0, style.blush_color)
	draw_circle(right_blush_pos, 8.0, style.blush_color)
	
	# Diagonal ink hatching scratches (///)
	NemiDoodles.draw_blush_hatch(self, left_blush_pos, 12.0, 9.0, style.blush_hatch_color)
	NemiDoodles.draw_blush_hatch(self, right_blush_pos, 12.0, 9.0, style.blush_hatch_color)
