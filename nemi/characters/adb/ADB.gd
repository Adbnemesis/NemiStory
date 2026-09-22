class_name ADB
extends Node2D

## Reusable Illustrated Character: ADB (Cool Streetwear & Goggles Rig V2)
## 100% Godot-native procedural 2D vector character.
## Authored to match Nemi's master illustration language:
## - Organic calligraphic charcoal inking via InkStroke (#2b2623)
## - Voluminous messy anime hair, aviator/cyber goggles, stylish popped-collar techwear jacket
## - Standardized pelvis origin (Y=0) matching Nemi's 1.15x scale and floor line grounding
## - Expressive acting: swagger idle, goggles tip, phone texting, anime hero poses, cute blush

signal pose_changed(new_pose: String)
signal expression_changed(new_expr: String)

const InkStroke = preload("res://nemi/characters/nemi/drawing/InkStroke.gd")

enum ADBExpression {
	NEUTRAL,
	HAPPY,
	CUTE,
	AMUSED,
	CONFUSED,
	SHOCKED,
	ANNOYED,
	SMUG,
	EMBARRASSED,
	EXCITED,
	TIRED,
	DEADPAN
}

# --- MASTER PALETTES ---
const INK_COLOR: Color = Color("#2b2623")              # Deep charcoal sepia ink
const INK_CREASE: Color = Color("#3a3430")             # Subtle inner crease ink
const SKIN_BASE: Color = Color("#fcf0e6")              # Warm porcelain ivory (matches Nemi)
const SKIN_SHADOW: Color = Color("#edd2c0")            # Warm skin shadow
const BLUSH_COLOR: Color = Color(0.98, 0.58, 0.56, 0.45) # Warm cheek flush
const BLUSH_HATCH: Color = Color("#a83226")            # Calligraphic blush hatch

# Hair palette (Deep indigo slate)
const HAIR_BASE: Color = Color("#1e222b")
const HAIR_SHADOW: Color = Color("#151820")
const HAIR_HIGHLIGHT: Color = Color("#384256")
const HAIR_GLINT: Color = Color("#505e78")

# Streetwear Jacket & Pants palette (Cool slate techwear)
const JACKET_BASE: Color = Color("#2e3440")            # Slate obsidian jacket
const JACKET_SHADOW: Color = Color("#242933")          # Deep jacket shadow
const JACKET_TRIM: Color = Color("#434c5e")            # Collar & seam trims
const ZIPPER_COLOR: Color = Color("#8892b0")           # Metallic silver zipper
const INNER_TEE: Color = Color("#191b22")              # Dark inner tee / cowl
const PANTS_COLOR: Color = Color("#1e222b")            # Tapered dark cargo joggers
const PANTS_SEAM: Color = Color("#2c323f")             # Cargo pocket seam

# Goggles Palette (Aviator / Cyber Streetwear)
const GOGGLES_RIM: Color = Color("#1c1f26")            # Metallic charcoal frame
const GOGGLES_RIM_HI: Color = Color("#4c566a")         # Bevel highlight
const GOGGLES_LENS_BASE: Color = Color("#0284c7")      # Vibrant tinted lens
const GOGGLES_LENS_HI: Color = Color("#38bdf8")        # Cyan reflection sheen
const GOGGLES_STRAP: Color = Color("#3f2e24")          # Dark leather strap
const GOGGLES_RIVET: Color = Color("#d8dee9")          # Silver rivet stud

# Shoes Palette
const SNEAKER_BASE: Color = Color("#f8fafc")           # Crisp white high-tops
const SNEAKER_TRIM: Color = Color("#0284c7")           # Cyan accent stripe (matches goggles)
const SNEAKER_SOLE: Color = Color("#e2e8f0")           # Chunky platform sole
const SNEAKER_TREAD: Color = Color("#1e293b")          # Dark rubber tread

# --- RIG TRANSFORM STATES (Pelvis is origin (0, 0)) ---
var current_expression: ADBExpression = ADBExpression.NEUTRAL
var expression_name: String = "neutral"
var current_pose_name: String = "cool_swagger"

# Goggles state
var goggles_on_eyes: bool = false
var goggles_glow: float = 0.0 # 0.0 to 1.0 for dramatic anime moments

# Procedural skeleton nodes (relative to Pelvis (0,0))
var torso_offset: Vector2 = Vector2.ZERO
var torso_tilt: float = 0.0
var head_offset: Vector2 = Vector2(0, -96) # Chin level at -96
var head_tilt: float = 0.0

# Arm transforms (Left = viewer's left, Right = viewer's right)
var left_shoulder: Vector2 = Vector2(-42, -82)
var left_elbow: Vector2 = Vector2(-58, -25)
var left_hand: Vector2 = Vector2(-40, 28)

var right_shoulder: Vector2 = Vector2(42, -82)
var right_elbow: Vector2 = Vector2(58, -25)
var right_hand: Vector2 = Vector2(40, 28)

# Facial controls
var eye_openness: float = 1.0 # 0.0 = closed, 1.0 = open, 1.3 = wide shock
var eye_gaze: Vector2 = Vector2.ZERO # (-1 to 1 for x, y)
var brow_left_angle: float = 0.0
var brow_right_angle: float = 0.0
var brow_height: float = 0.0
var mouth_state: String = "neutral" # neutral, smile, smirk, talk_open, talk_wide, small_o, deadpan
var blush_intensity: float = 0.0

# Dynamic props & FX
var is_holding_phone: bool = false
var show_anime_sparkles: bool = false

# Internal animation state
var _idle_time: float = 0.0
var _active_tween: Tween
var _is_frozen: bool = false

func _ready() -> void:
	set_pose("cool_swagger", 0.0)
	set_expression("neutral", 0.0)

func _process(delta: float) -> void:
	if _is_frozen:
		queue_redraw()
		return
		
	_idle_time += delta
	# Organic living breathing
	var breath := sin(_idle_time * 2.4) * 1.2
	torso_offset.y = breath * 0.4
	head_offset.y = -96 + breath * 0.7
	queue_redraw()

# -----------------------------------------------------------------------------
# HIGH-LEVEL ACTING & POSING API
# -----------------------------------------------------------------------------

func set_pose(pose_name: String, duration: float = 0.22) -> void:
	current_pose_name = pose_name.to_lower()
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	if duration > 0.001:
		_active_tween = create_tween().set_parallel(true)
	else:
		_active_tween = null
	
	is_holding_phone = false
	show_anime_sparkles = false
	
	match current_pose_name:
		"cool_swagger", "cool_idle", "neutral":
			_tween_prop("torso_tilt", deg_to_rad(2.0), duration)
			_tween_prop("head_tilt", deg_to_rad(-2.5), duration)
			# Hands resting casually in jacket pockets
			_tween_prop("left_shoulder", Vector2(-40, -82), duration)
			_tween_prop("left_elbow", Vector2(-54, -28), duration)
			_tween_prop("left_hand", Vector2(-36, 25), duration)
			
			_tween_prop("right_shoulder", Vector2(40, -82), duration)
			_tween_prop("right_elbow", Vector2(54, -28), duration)
			_tween_prop("right_hand", Vector2(36, 25), duration)
			
		"goggles_tip", "goggles_touch":
			# Cool anime pose: right hand raised up adjusting goggles on forehead
			_tween_prop("torso_tilt", deg_to_rad(1.5), duration)
			_tween_prop("head_tilt", deg_to_rad(3.5), duration)
			_tween_prop("left_shoulder", Vector2(-40, -82), duration)
			_tween_prop("left_elbow", Vector2(-52, -28), duration)
			_tween_prop("left_hand", Vector2(-36, 25), duration)
			
			_tween_prop("right_shoulder", Vector2(42, -82), duration)
			_tween_prop("right_elbow", Vector2(62, -80), duration)
			_tween_prop("right_hand", Vector2(38, -132), duration) # Hand at goggles rim
			goggles_glow = 1.0
			var tw_glow := create_tween()
			tw_glow.tween_property(self, "goggles_glow", 0.0, 0.45)
			
		"arms_crossed":
			# Confident arms crossed across chest
			_tween_prop("torso_tilt", deg_to_rad(-1.5), duration)
			_tween_prop("head_tilt", deg_to_rad(2.0), duration)
			_tween_prop("left_shoulder", Vector2(-40, -82), duration)
			_tween_prop("left_elbow", Vector2(-52, -45), duration)
			_tween_prop("left_hand", Vector2(18, -48), duration)
			
			_tween_prop("right_shoulder", Vector2(40, -82), duration)
			_tween_prop("right_elbow", Vector2(52, -45), duration)
			_tween_prop("right_hand", Vector2(-18, -48), duration)
			
		"phone_texting":
			is_holding_phone = true
			_tween_prop("torso_tilt", deg_to_rad(-1.0), duration)
			_tween_prop("head_tilt", deg_to_rad(4.0), duration)
			_tween_prop("left_shoulder", Vector2(-38, -82), duration)
			_tween_prop("left_elbow", Vector2(-46, -30), duration)
			_tween_prop("left_hand", Vector2(-12, -22), duration)
			
			_tween_prop("right_shoulder", Vector2(38, -82), duration)
			_tween_prop("right_elbow", Vector2(46, -30), duration)
			_tween_prop("right_hand", Vector2(12, -22), duration)
			
		"anime_hero":
			# Dramatic shonen finger-gun / cape pose
			show_anime_sparkles = true
			_tween_prop("torso_tilt", deg_to_rad(3.5), duration)
			_tween_prop("head_tilt", deg_to_rad(-4.0), duration)
			_tween_prop("left_shoulder", Vector2(-42, -82), duration)
			_tween_prop("left_elbow", Vector2(-56, -30), duration)
			_tween_prop("left_hand", Vector2(-38, 25), duration)
			
			_tween_prop("right_shoulder", Vector2(42, -82), duration)
			_tween_prop("right_elbow", Vector2(68, -60), duration)
			_tween_prop("right_hand", Vector2(72, -95), duration)
			
		"teasing_poke":
			# Leaning sideways poking finger playfully toward Nemi
			_tween_prop("torso_tilt", deg_to_rad(-5.0), duration)
			_tween_prop("head_tilt", deg_to_rad(-6.0), duration)
			_tween_prop("left_shoulder", Vector2(-40, -82), duration)
			_tween_prop("left_elbow", Vector2(-58, -40), duration)
			_tween_prop("left_hand", Vector2(-88, -45), duration) # Extended pointing left
			
			_tween_prop("right_shoulder", Vector2(40, -82), duration)
			_tween_prop("right_elbow", Vector2(52, -28), duration)
			_tween_prop("right_hand", Vector2(36, 25), duration)
			
		"cute_wave":
			_tween_prop("torso_tilt", deg_to_rad(-1.0), duration)
			_tween_prop("head_tilt", deg_to_rad(4.0), duration)
			_tween_prop("left_shoulder", Vector2(-40, -82), duration)
			_tween_prop("left_elbow", Vector2(-52, -28), duration)
			_tween_prop("left_hand", Vector2(-36, 25), duration)
			
			_tween_prop("right_shoulder", Vector2(40, -82), duration)
			_tween_prop("right_elbow", Vector2(56, -65), duration)
			_tween_prop("right_hand", Vector2(52, -108), duration)
			
		"supportive_nod", "supportive":
			_tween_prop("torso_tilt", deg_to_rad(-2.0), duration)
			_tween_prop("head_tilt", deg_to_rad(-3.5), duration)
			_tween_prop("left_shoulder", Vector2(-40, -82), duration)
			_tween_prop("left_elbow", Vector2(-50, -28), duration)
			_tween_prop("left_hand", Vector2(-36, 25), duration)
			_tween_prop("right_shoulder", Vector2(40, -82), duration)
			_tween_prop("right_elbow", Vector2(50, -28), duration)
			_tween_prop("right_hand", Vector2(36, 25), duration)
			
		"deadpan_freeze", "deadpan":
			_tween_prop("torso_tilt", 0.0, duration)
			_tween_prop("head_tilt", 0.0, duration)
			_tween_prop("left_shoulder", Vector2(-40, -82), duration)
			_tween_prop("left_elbow", Vector2(-52, -28), duration)
			_tween_prop("left_hand", Vector2(-38, 25), duration)
			_tween_prop("right_shoulder", Vector2(40, -82), duration)
			_tween_prop("right_elbow", Vector2(52, -28), duration)
			_tween_prop("right_hand", Vector2(38, 25), duration)
			
		_:
			push_warning("Unknown pose: " + pose_name)
			
	pose_changed.emit(current_pose_name)

func set_expression(expr_name: String, duration: float = 0.18) -> void:
	expression_name = expr_name.to_lower()
	
	match expression_name:
		"neutral":
			current_expression = ADBExpression.NEUTRAL
			eye_openness = 1.0
			brow_left_angle = 0.0
			brow_right_angle = 0.0
			brow_height = 0.0
			mouth_state = "neutral"
			blush_intensity = 0.0
			goggles_on_eyes = false
			
		"smug", "confident":
			current_expression = ADBExpression.SMUG
			eye_openness = 0.82
			brow_left_angle = -0.15
			brow_right_angle = 0.22 # Raised eyebrow
			brow_height = 2.0
			mouth_state = "smirk"
			blush_intensity = 0.15
			
		"cute", "soft":
			current_expression = ADBExpression.CUTE
			eye_openness = 1.08
			brow_left_angle = 0.12
			brow_right_angle = -0.12
			brow_height = 1.0
			mouth_state = "smile"
			blush_intensity = 0.70
			
		"embarrassed", "flustered":
			current_expression = ADBExpression.EMBARRASSED
			eye_openness = 0.90
			brow_left_angle = 0.20
			brow_right_angle = -0.20
			brow_height = -2.0
			mouth_state = "small_o"
			blush_intensity = 0.95
			eye_gaze = Vector2(0.8, -0.4) # Looking away shyly
			
		"excited", "anime":
			current_expression = ADBExpression.EXCITED
			eye_openness = 1.25
			brow_left_angle = 0.18
			brow_right_angle = -0.18
			brow_height = 3.0
			mouth_state = "talk_wide"
			blush_intensity = 0.40
			goggles_glow = 1.0
			
		"amused", "laughing":
			current_expression = ADBExpression.AMUSED
			eye_openness = 0.0 # Closed happy laughing eyes
			brow_left_angle = 0.0
			brow_right_angle = 0.0
			brow_height = 1.5
			mouth_state = "smile"
			blush_intensity = 0.50
			
		"deadpan", "unimpressed":
			current_expression = ADBExpression.DEADPAN
			eye_openness = 0.50
			brow_left_angle = 0.0
			brow_right_angle = 0.25 # Raised single eyebrow
			brow_height = 0.0
			mouth_state = "deadpan"
			blush_intensity = 0.0
			eye_gaze = Vector2.ZERO
			
		"shocked":
			current_expression = ADBExpression.SHOCKED
			eye_openness = 1.35
			brow_left_angle = 0.30
			brow_right_angle = -0.30
			brow_height = 5.0
			mouth_state = "small_o"
			blush_intensity = 0.0
			
		_:
			current_expression = ADBExpression.NEUTRAL
			eye_openness = 1.0
			mouth_state = "neutral"
			blush_intensity = 0.0
			
	expression_changed.emit(expression_name)
	queue_redraw()

func look(direction: String) -> void:
	match direction.to_lower():
		"camera", "center":
			eye_gaze = Vector2.ZERO
		"nemi", "left":
			eye_gaze = Vector2(-0.85, -0.1)
		"right":
			eye_gaze = Vector2(0.85, -0.1)
		"away":
			eye_gaze = Vector2(0.8, -0.4)
		"down":
			eye_gaze = Vector2(0.0, 0.7)
		_:
			eye_gaze = Vector2.ZERO
	queue_redraw()

func blink(duration: float = 0.12) -> void:
	var prev_openness: float = eye_openness
	var tw := create_tween()
	tw.tween_property(self, "eye_openness", 0.0, duration * 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "eye_openness", prev_openness, duration * 0.6)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func head_tilt_to(angle_deg: float, duration: float = 0.20) -> void:
	var tw := create_tween()
	tw.tween_property(self, "head_tilt", deg_to_rad(angle_deg), duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func toggle_goggles(on_eyes: bool, duration: float = 0.25) -> void:
	goggles_on_eyes = on_eyes
	queue_redraw()

func set_goggles_on_eyes(on_eyes: bool) -> void:
	toggle_goggles(on_eyes)

func freeze_stillness(duration: float) -> void:
	_is_frozen = true
	await get_tree().create_timer(duration).timeout
	_is_frozen = false

func _tween_prop(prop_name: String, target_val: Variant, duration: float) -> void:
	if _active_tween and _active_tween.is_valid():
		if duration > 0.001:
			_active_tween.tween_property(self, prop_name, target_val, duration)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			set(prop_name, target_val)

# -----------------------------------------------------------------------------
# MASTER 2D VECTOR DRAWING PIPELINE
# -----------------------------------------------------------------------------

func _draw() -> void:
	_draw_contact_shadow()
	_draw_legs_and_shoes()
	_draw_torso_and_jacket()
	_draw_arms()
	_draw_head_and_hair()

func _draw_contact_shadow() -> void:
	# Subtle contact puddle ellipse under sneakers on floor line
	draw_set_transform(Vector2(0, 195), 0.0, Vector2(1.0, 0.22))
	draw_circle(Vector2.ZERO, 38.0, Color(0.17, 0.15, 0.14, 0.18))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_legs_and_shoes() -> void:
	# Tapered Dark Cargo Joggers (Pelvis origin (0,0) down to ankles (172))
	# Left leg (viewer's left)
	var left_thigh := PackedVector2Array([
		Vector2(-24, 0), Vector2(-6, 0), Vector2(-8, 86), Vector2(-22, 86)
	])
	draw_colored_polygon(left_thigh, PANTS_COLOR)
	var lt_stroke := InkStroke.from_points(PackedVector2Array([Vector2(-24, 0), Vector2(-22, 86)]), 2.4, InkStroke.Profile.TAPER_BOTH, INK_COLOR)
	lt_stroke.draw_to(self)
	
	var left_shin := PackedVector2Array([
		Vector2(-22, 86), Vector2(-8, 86), Vector2(-10, 172), Vector2(-20, 172)
	])
	draw_colored_polygon(left_shin, PANTS_COLOR)
	var ls_stroke := InkStroke.from_points(PackedVector2Array([Vector2(-22, 86), Vector2(-20, 172)]), 2.4, InkStroke.Profile.TAPER_BOTH, INK_COLOR)
	ls_stroke.draw_to(self)
	
	# Left Cargo Pocket Flap & Strap
	draw_polyline(PackedVector2Array([Vector2(-24, 94), Vector2(-10, 94)]), INK_COLOR, 1.8)
	draw_line(Vector2(-17, 94), Vector2(-17, 110), PANTS_SEAM, 1.6)

	# Right leg (viewer's right)
	var right_thigh := PackedVector2Array([
		Vector2(6, 0), Vector2(24, 0), Vector2(22, 86), Vector2(8, 86)
	])
	draw_colored_polygon(right_thigh, PANTS_COLOR)
	var rt_stroke := InkStroke.from_points(PackedVector2Array([Vector2(24, 0), Vector2(22, 86)]), 2.4, InkStroke.Profile.TAPER_BOTH, INK_COLOR)
	rt_stroke.draw_to(self)
	
	var right_shin := PackedVector2Array([
		Vector2(8, 86), Vector2(22, 86), Vector2(20, 172), Vector2(10, 172)
	])
	draw_colored_polygon(right_shin, PANTS_COLOR)
	var rs_stroke := InkStroke.from_points(PackedVector2Array([Vector2(22, 86), Vector2(20, 172)]), 2.4, InkStroke.Profile.TAPER_BOTH, INK_COLOR)
	rs_stroke.draw_to(self)
	
	# Right Cargo Pocket Flap
	draw_polyline(PackedVector2Array([Vector2(10, 94), Vector2(24, 94)]), INK_COLOR, 1.8)
	draw_line(Vector2(17, 94), Vector2(17, 110), PANTS_SEAM, 1.6)

	# Crotch & inner inseam
	var inseam := InkStroke.from_points(PackedVector2Array([Vector2(-6, 0), Vector2(0, 15), Vector2(6, 0)]), 1.8, InkStroke.Profile.DELICATE_CREASE, INK_COLOR)
	inseam.draw_to(self)
	
	# --- SNEAKERS (Ankle 172 to Sole 195) ---
	_draw_sneaker(Vector2(-15, 172), true)
	_draw_sneaker(Vector2(15, 172), false)

func _draw_sneaker(pos: Vector2, is_left: bool) -> void:
	var s_x := -1.0 if is_left else 1.0
	
	# Sneaker upper body
	var upper_pts := PackedVector2Array([
		pos + Vector2(-s_x * 8, 0), pos + Vector2(s_x * 8, 0),
		pos + Vector2(s_x * 12, 16), pos + Vector2(s_x * 16, 20),
		pos + Vector2(-s_x * 14, 20), pos + Vector2(-s_x * 10, 12)
	])
	draw_colored_polygon(upper_pts, SNEAKER_BASE)
	draw_polyline(upper_pts + PackedVector2Array([upper_pts[0]]), INK_COLOR, 2.2)
	
	# Cyan racing stripe (matches goggles accent)
	draw_line(pos + Vector2(-s_x * 6, 8), pos + Vector2(s_x * 10, 14), SNEAKER_TRIM, 3.2)
	
	# Platform sole
	var sole_pts := PackedVector2Array([
		pos + Vector2(-s_x * 15, 20), pos + Vector2(s_x * 17, 20),
		pos + Vector2(s_x * 17, 23), pos + Vector2(-s_x * 15, 23)
	])
	draw_colored_polygon(sole_pts, SNEAKER_SOLE)
	draw_polyline(sole_pts + PackedVector2Array([sole_pts[0]]), INK_COLOR, 1.8)
	
	# Dark bottom tread
	draw_line(pos + Vector2(-s_x * 15, 23), pos + Vector2(s_x * 17, 23), SNEAKER_TREAD, 2.0)

func _draw_torso_and_jacket() -> void:
	var t_pos: Vector2 = torso_offset
	
	# 1. Inner dark turtleneck / fitted tee
	var inner_pts := PackedVector2Array([
		t_pos + Vector2(-22, -88), t_pos + Vector2(22, -88),
		t_pos + Vector2(16, -10), t_pos + Vector2(-16, -10)
	])
	draw_colored_polygon(inner_pts, INNER_TEE)
	
	# 2. Main Techwear Jacket Silhouette
	var jacket_pts := PackedVector2Array([
		t_pos + Vector2(-36, -82), t_pos + Vector2(-24, -88), # Left shoulder
		t_pos + Vector2(-10, -88),                             # Popped collar inner left
		t_pos + Vector2(10, -88),                              # Popped collar inner right
		t_pos + Vector2(24, -88), t_pos + Vector2(36, -82),   # Right shoulder
		t_pos + Vector2(30, 6),                                # Right hem
		t_pos + Vector2(-30, 6)                                # Left hem
	])
	draw_colored_polygon(jacket_pts, JACKET_BASE)
	
	# Jacket outer calligraphic contour
	var j_stroke := InkStroke.from_points(jacket_pts + PackedVector2Array([jacket_pts[0]]), 2.8, InkStroke.Profile.TAPER_BOTH, INK_COLOR)
	j_stroke.draw_to(self)
	
	# 3. Popped Cowl Collar (Left & Right lapels)
	var left_collar := PackedVector2Array([
		t_pos + Vector2(-24, -88), t_pos + Vector2(-16, -102),
		t_pos + Vector2(-4, -92), t_pos + Vector2(-10, -82)
	])
	draw_colored_polygon(left_collar, JACKET_TRIM)
	draw_polyline(left_collar, INK_COLOR, 2.4)
	
	var right_collar := PackedVector2Array([
		t_pos + Vector2(24, -88), t_pos + Vector2(16, -102),
		t_pos + Vector2(4, -92), t_pos + Vector2(10, -82)
	])
	draw_colored_polygon(right_collar, JACKET_TRIM)
	draw_polyline(right_collar, INK_COLOR, 2.4)
	
	# 4. Asymmetric Zipper & Hardware
	var zipper_line := PackedVector2Array([
		t_pos + Vector2(-4, -90), t_pos + Vector2(6, 6)
	])
	draw_polyline(zipper_line, INK_COLOR, 3.2)
	draw_dashed_line(t_pos + Vector2(-4, -90), t_pos + Vector2(6, 6), ZIPPER_COLOR, 1.8, 3.0)
	# Silver zipper pull tab
	draw_circle(t_pos + Vector2(-1, -50), 3.0, ZIPPER_COLOR)
	draw_line(t_pos + Vector2(-1, -50), t_pos + Vector2(-1, -40), ZIPPER_COLOR, 2.0)
	
	# 5. Jacket hem band
	draw_line(t_pos + Vector2(-30, 4), t_pos + Vector2(30, 4), INK_COLOR, 2.4)
	draw_line(t_pos + Vector2(-28, 0), t_pos + Vector2(28, 0), JACKET_SHADOW, 1.6)

func _draw_arms() -> void:
	# Left Arm
	var left_arm_pts := PackedVector2Array([left_shoulder, left_elbow, left_hand])
	draw_polyline(left_arm_pts, INK_COLOR, 15.0)
	draw_polyline(left_arm_pts, JACKET_BASE, 10.0)
	draw_circle(left_elbow, 5.0, JACKET_BASE)
	# Hand / Cuff
	draw_circle(left_hand, 7.5, SKIN_BASE)
	draw_arc(left_hand, 7.5, 0, TAU, 16, INK_COLOR, 2.2)
	
	# Right Arm
	var right_arm_pts := PackedVector2Array([right_shoulder, right_elbow, right_hand])
	draw_polyline(right_arm_pts, INK_COLOR, 15.0)
	draw_polyline(right_arm_pts, JACKET_BASE, 10.0)
	draw_circle(right_elbow, 5.0, JACKET_BASE)
	# Hand
	draw_circle(right_hand, 7.5, SKIN_BASE)
	draw_arc(right_hand, 7.5, 0, TAU, 16, INK_COLOR, 2.2)
	
	# Handheld Phone Prop if active
	if is_holding_phone:
		var phone_center: Vector2 = (left_hand + right_hand) * 0.5 + Vector2(0, -6)
		var phone_rect := Rect2(phone_center - Vector2(10, 16), Vector2(20, 32))
		draw_rect(phone_rect, Color("#0f172a"))
		draw_rect(phone_rect, INK_COLOR, false, 2.0)
		# Glowing screen
		var screen_rect := Rect2(phone_center - Vector2(8, 14), Vector2(16, 28))
		draw_rect(screen_rect, Color("#38bdf8"))
		# Screen glow halo
		draw_circle(phone_center, 18.0, Color(0.22, 0.74, 0.97, 0.20))

func _draw_head_and_hair() -> void:
	var h_pos: Vector2 = head_offset
	
	# 1. Neck
	var neck_poly := PackedVector2Array([
		h_pos + Vector2(-10, 0), h_pos + Vector2(10, 0),
		h_pos + Vector2(8, 18), h_pos + Vector2(-8, 18)
	])
	draw_colored_polygon(neck_poly, SKIN_BASE)
	draw_line(h_pos + Vector2(-10, 0), h_pos + Vector2(-8, 18), INK_COLOR, 2.0)
	draw_line(h_pos + Vector2(10, 0), h_pos + Vector2(8, 18), INK_COLOR, 2.0)
	
	# 2. Back Hair Volume (Dense, layered dark slate mane)
	var hair_back := PackedVector2Array([
		h_pos + Vector2(-38, -45), h_pos + Vector2(-46, -10),
		h_pos + Vector2(-42, 18), h_pos + Vector2(-32, 28),
		h_pos + Vector2(32, 28), h_pos + Vector2(42, 18),
		h_pos + Vector2(46, -10), h_pos + Vector2(38, -45),
		h_pos + Vector2(0, -56)
	])
	draw_colored_polygon(hair_back, HAIR_BASE)
	var hb_stroke := InkStroke.from_points(hair_back + PackedVector2Array([hair_back[0]]), 3.0, InkStroke.Profile.TAPER_BOTH, INK_COLOR)
	hb_stroke.draw_to(self)
	
	# Goggles Leather Strap (wraps around back hair)
	var strap_y: float = h_pos.y - 30.0 if not goggles_on_eyes else h_pos.y - 12.0
	draw_line(Vector2(h_pos.x - 42, strap_y), Vector2(h_pos.x + 42, strap_y), GOGGLES_STRAP, 5.0)
	draw_line(Vector2(h_pos.x - 42, strap_y), Vector2(h_pos.x + 42, strap_y), INK_COLOR, 1.8)
	
	# 3. Face / Jaw Contour (Smooth anime taper)
	var face_pts := PackedVector2Array([
		h_pos + Vector2(-28, -25), h_pos + Vector2(-29, 2),
		h_pos + Vector2(-16, 24), h_pos + Vector2(0, 30), # Chin point
		h_pos + Vector2(16, 24), h_pos + Vector2(29, 2),
		h_pos + Vector2(28, -25)
	])
	draw_colored_polygon(face_pts, SKIN_BASE)
	var face_stroke := InkStroke.from_points(face_pts, 2.6, InkStroke.Profile.TAPER_BOTH, INK_COLOR)
	face_stroke.draw_to(self)
	
	# Soft chin shadow
	draw_line(h_pos + Vector2(-8, 27), h_pos + Vector2(8, 27), SKIN_SHADOW, 2.0)
	
	# 4. Ears with delicate inner curl
	_draw_ear(h_pos + Vector2(-30, 2), true)
	_draw_ear(h_pos + Vector2(30, 2), false)
	
	# 5. Facial Features (Eyes, Brows, Nose, Mouth, Blush)
	_draw_face_features(h_pos)
	
	# 6. Front Layered Anime Bangs (Sharp dynamic locks framing the face)
	_draw_front_hair_locks(h_pos)
	
	# 7. Streetwear Aviator/Cyber Goggles
	_draw_goggles(h_pos)
	
	# 8. Anime sparkles if active
	if show_anime_sparkles:
		_draw_sparkle(h_pos + Vector2(-38, -48), 10.0)
		_draw_sparkle(h_pos + Vector2(38, -44), 8.0)

func _draw_ear(pos: Vector2, is_left: bool) -> void:
	var s_x := -1.0 if is_left else 1.0
	draw_circle(pos, 6.5, SKIN_BASE)
	draw_arc(pos, 6.5, -PI * 0.5, PI * 0.5 if is_left else -PI * 0.5, 12, INK_COLOR, 2.0)
	# Inner ear crease
	draw_line(pos + Vector2(s_x * 1, -2), pos + Vector2(s_x * 2, 2), INK_CREASE, 1.4)

func _draw_face_features(h_pos: Vector2) -> void:
	# A. Cheek Blush with Calligraphic Hatching
	if blush_intensity > 0.05:
		var blush_col := Color(BLUSH_COLOR.r, BLUSH_COLOR.g, BLUSH_COLOR.b, BLUSH_COLOR.a * blush_intensity)
		draw_circle(h_pos + Vector2(-18, 12), 9.0, blush_col)
		draw_circle(h_pos + Vector2(18, 12), 9.0, blush_col)
		# Diagonal subtle hatching lines (///)
		if blush_intensity > 0.4:
			var h_col := Color(BLUSH_HATCH.r, BLUSH_HATCH.g, BLUSH_HATCH.b, 0.45 * blush_intensity)
			draw_line(h_pos + Vector2(-22, 10), h_pos + Vector2(-17, 15), h_col, 1.4)
			draw_line(h_pos + Vector2(-19, 9), h_pos + Vector2(-14, 14), h_col, 1.4)
			draw_line(h_pos + Vector2(14, 10), h_pos + Vector2(19, 15), h_col, 1.4)
			draw_line(h_pos + Vector2(17, 9), h_pos + Vector2(22, 14), h_col, 1.4)
			
	# If goggles are down over eyes, skip eye drawing and let reflective lenses shine
	if not goggles_on_eyes:
		# B. Eyebrows (Sharp confident calligraphic anime arches)
		var brow_y := h_pos.y - 18.0 + brow_height
		var lb_pts := PackedVector2Array([
			Vector2(h_pos.x - 24, brow_y + brow_left_angle * 10.0),
			Vector2(h_pos.x - 12, brow_y - 3.0),
			Vector2(h_pos.x - 4, brow_y + 1.0)
		])
		var lb_stroke := InkStroke.from_points(lb_pts, 2.6, InkStroke.Profile.TAPER_BOTH, INK_COLOR)
		lb_stroke.draw_to(self)
		
		var rb_pts := PackedVector2Array([
			Vector2(h_pos.x + 4, brow_y + 1.0),
			Vector2(h_pos.x + 12, brow_y - 3.0),
			Vector2(h_pos.x + 24, brow_y - brow_right_angle * 10.0)
		])
		var rb_stroke := InkStroke.from_points(rb_pts, 2.6, InkStroke.Profile.TAPER_BOTH, INK_COLOR)
		rb_stroke.draw_to(self)
		
		# C. Eyes (Calligraphic Anime System matching Nemi's quality)
		_draw_calligraphic_eye(h_pos + Vector2(-15, -6), true)
		_draw_calligraphic_eye(h_pos + Vector2(15, -6), false)
	
	# D. Delicate Nose tick
	var nose_pos := h_pos + Vector2(0, 8)
	draw_line(nose_pos + Vector2(0, -3), nose_pos, INK_COLOR, 2.0)
	draw_line(nose_pos, nose_pos + Vector2(2.5, 0), INK_COLOR, 1.8)
	
	# E. Illustrated Mouth Shapes
	_draw_mouth_shape(h_pos + Vector2(0, 20))

func _draw_calligraphic_eye(center: Vector2, is_left: bool) -> void:
	var s_x := -1.0 if is_left else 1.0
	
	# Closed smiling eye arc (^ ^)
	if eye_openness < 0.2:
		var closed_c := Curve2D.new()
		closed_c.add_point(center + Vector2(-s_x * 10, 2), Vector2(0,0), Vector2(2 * s_x, -5))
		closed_c.add_point(center + Vector2(0, -3), Vector2(-4 * s_x, 0), Vector2(4 * s_x, 0))
		closed_c.add_point(center + Vector2(s_x * 10, 0), Vector2(-2 * s_x, -3), Vector2(2 * s_x, -1))
		var stroke := InkStroke.from_curve(closed_c, 3.2, InkStroke.Profile.CALLIGRAPHIC_LASH, INK_COLOR)
		stroke.draw_to(self)
		return
		
	# Almond Sclera base
	var half_w := 9.5
	var half_h := 6.5 * eye_openness
	var eye_poly := PackedVector2Array([
		center + Vector2(-half_w, 0), center + Vector2(-half_w * 0.5, -half_h),
		center + Vector2(half_w * 0.5, -half_h), center + Vector2(half_w, 0),
		center + Vector2(half_w * 0.4, half_h * 0.65), center + Vector2(-half_w * 0.4, half_h * 0.65)
	])
	draw_colored_polygon(eye_poly, Color("#ffffff"))
	
	# Gaze pupil & iris center
	var max_gaze := Vector2(3.5, 2.0)
	var pupil_c := center + Vector2(eye_gaze.x * max_gaze.x, eye_gaze.y * max_gaze.y - 1.2)
	var iris_r := 5.2
	
	# Iris (Deep slate indigo with gradient depth)
	draw_circle(pupil_c, iris_r, HAIR_BASE)
	draw_circle(pupil_c + Vector2(0, -1), iris_r * 0.7, Color("#2b3548"))
	# Dark inner pupil
	draw_circle(pupil_c, 2.2, Color("#0c0e14"))
	# Specular highlights (dual white dots)
	draw_circle(pupil_c + Vector2(-s_x * 1.8, -1.8), 1.8, Color("#ffffff"))
	draw_circle(pupil_c + Vector2(s_x * 1.5, 1.5), 1.0, Color("#ffffff"))
	
	# Upper Calligraphic Lash line (bold sweeping wing)
	var lash_pts := PackedVector2Array([
		center + Vector2(-s_x * 10.5, 1.5),
		center + Vector2(-s_x * 4, -half_h - 0.5),
		center + Vector2(s_x * 6, -half_h - 0.2),
		center + Vector2(s_x * 12, -half_h + 3.0) # Wing flick
	])
	var lash_stroke := InkStroke.from_points(lash_pts, 3.4, InkStroke.Profile.CALLIGRAPHIC_LASH, INK_COLOR)
	lash_stroke.draw_to(self)
	
	# Delicate lower lid tick
	draw_line(center + Vector2(-s_x * 4, half_h * 0.6), center + Vector2(s_x * 4, half_h * 0.6), INK_CREASE, 1.4)

func _draw_mouth_shape(m_pos: Vector2) -> void:
	match mouth_state:
		"smirk":
			# Confident lopsided smirk flicking upward on right
			var smirk_pts := PackedVector2Array([
				m_pos + Vector2(-9, 1), m_pos + Vector2(0, 0),
				m_pos + Vector2(8, -3), m_pos + Vector2(11, -5)
			])
			var s_stroke := InkStroke.from_points(smirk_pts, 2.6, InkStroke.Profile.TAPER_START, INK_COLOR)
			s_stroke.draw_to(self)
			draw_line(m_pos + Vector2(10, -5), m_pos + Vector2(11, -7), INK_COLOR, 1.6)
			
		"smile":
			var smile_pts := PackedVector2Array([
				m_pos + Vector2(-8, -1), m_pos + Vector2(0, 3), m_pos + Vector2(8, -1)
			])
			var s_stroke := InkStroke.from_points(smile_pts, 2.4, InkStroke.Profile.TAPER_BOTH, INK_COLOR)
			s_stroke.draw_to(self)
			
		"talk_open":
			var mouth_poly := PackedVector2Array([
				m_pos + Vector2(-8, -2), m_pos + Vector2(8, -2),
				m_pos + Vector2(6, 6), m_pos + Vector2(-6, 6)
			])
			draw_colored_polygon(mouth_poly, Color("#991b1b"))
			draw_polyline(mouth_poly + PackedVector2Array([mouth_poly[0]]), INK_COLOR, 2.2)
			draw_line(m_pos + Vector2(-5, 0), m_pos + Vector2(5, 0), Color("#ffffff"), 1.8)
			
		"talk_wide":
			var wide_poly := PackedVector2Array([
				m_pos + Vector2(-10, -3), m_pos + Vector2(10, -3),
				m_pos + Vector2(8, 8), m_pos + Vector2(-8, 8)
			])
			draw_colored_polygon(wide_poly, Color("#991b1b"))
			draw_polyline(wide_poly + PackedVector2Array([wide_poly[0]]), INK_COLOR, 2.4)
			# Top teeth
			draw_colored_polygon(PackedVector2Array([
				m_pos + Vector2(-8, -3), m_pos + Vector2(8, -3),
				m_pos + Vector2(6, 0), m_pos + Vector2(-6, 0)
			]), Color("#ffffff"))
			
		"small_o":
			draw_circle(m_pos, 4.5, INK_COLOR)
			draw_circle(m_pos, 2.6, Color("#991b1b"))
			
		"deadpan":
			# Flat straight unimpressed dash
			draw_line(m_pos + Vector2(-8, 0), m_pos + Vector2(8, 0), INK_COLOR, 2.4)
			
		_: # Neutral resting mouth
			var n_pts := PackedVector2Array([
				m_pos + Vector2(-7, 0), m_pos + Vector2(0, 1), m_pos + Vector2(7, 0)
			])
			draw_polyline(n_pts, INK_COLOR, 2.2)

func _draw_front_hair_locks(h_pos: Vector2) -> void:
	# Layered messy anime bangs & dynamic side locks
	# 1. Left sweeping temple lock
	var l_lock := PackedVector2Array([
		h_pos + Vector2(-36, -35), h_pos + Vector2(-42, -5),
		h_pos + Vector2(-34, 15), h_pos + Vector2(-30, 2),
		h_pos + Vector2(-28, -25)
	])
	draw_colored_polygon(l_lock, HAIR_BASE)
	var ll_stroke := InkStroke.from_points(l_lock, 2.6, InkStroke.Profile.TAPER_END, INK_COLOR)
	ll_stroke.draw_to(self)
	
	# 2. Right sweeping temple lock
	var r_lock := PackedVector2Array([
		h_pos + Vector2(36, -35), h_pos + Vector2(42, -5),
		h_pos + Vector2(34, 15), h_pos + Vector2(30, 2),
		h_pos + Vector2(28, -25)
	])
	draw_colored_polygon(r_lock, HAIR_BASE)
	var rl_stroke := InkStroke.from_points(r_lock, 2.6, InkStroke.Profile.TAPER_END, INK_COLOR)
	rl_stroke.draw_to(self)
	
	# 3. Center bangs (asymmetric anime bangs sweeping across forehead)
	var c_bangs := PackedVector2Array([
		h_pos + Vector2(-28, -35), h_pos + Vector2(-14, -14),
		h_pos + Vector2(-8, -25), h_pos + Vector2(2, -10),
		h_pos + Vector2(10, -22), h_pos + Vector2(20, -12),
		h_pos + Vector2(28, -35), h_pos + Vector2(0, -48)
	])
	draw_colored_polygon(c_bangs, HAIR_BASE)
	var cb_stroke := InkStroke.from_points(c_bangs, 2.6, InkStroke.Profile.TAPER_BOTH, INK_COLOR)
	cb_stroke.draw_to(self)
	
	# 4. Top voluminous cowlick / flick
	var cowlick := PackedVector2Array([
		h_pos + Vector2(-6, -54), h_pos + Vector2(8, -68), h_pos + Vector2(18, -62), h_pos + Vector2(8, -52)
	])
	draw_colored_polygon(cowlick, HAIR_HIGHLIGHT)
	var cl_stroke := InkStroke.from_points(cowlick, 2.4, InkStroke.Profile.TAPER_END, INK_COLOR)
	cl_stroke.draw_to(self)

func _draw_goggles(h_pos: Vector2) -> void:
	# Position: either resting on messy hair (Y = -36) or down over eyes (Y = -6)
	var g_center: Vector2 = h_pos + (Vector2(0, -6) if goggles_on_eyes else Vector2(0, -38))
	
	# Leather bridge connection
	draw_line(g_center + Vector2(-10, 0), g_center + Vector2(10, 0), GOGGLES_STRAP, 6.0)
	draw_line(g_center + Vector2(-10, 0), g_center + Vector2(10, 0), INK_COLOR, 2.0)
	# Center metallic buckle
	draw_rect(Rect2(g_center - Vector2(4, 5), Vector2(8, 10)), GOGGLES_RIM_HI)
	draw_rect(Rect2(g_center - Vector2(4, 5), Vector2(8, 10)), INK_COLOR, false, 1.8)
	
	# Draw Left & Right Aviator/Cyber Lenses
	_draw_single_goggle_lens(g_center + Vector2(-18, 0), true)
	_draw_single_goggle_lens(g_center + Vector2(18, 0), false)

func _draw_single_goggle_lens(center: Vector2, is_left: bool) -> void:
	var w := 24.0
	var h := 18.0
	var rim_rect := Rect2(center - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	
	# 1. Metallic Rim (Dark slate rim with bevel)
	draw_rect(rim_rect, GOGGLES_RIM)
	draw_rect(rim_rect, INK_COLOR, false, 2.6)
	draw_line(rim_rect.position, rim_rect.position + Vector2(w, 0), GOGGLES_RIM_HI, 1.8)
	
	# 2. Tinted Reflective Glass Lens
	var lens_inset := 3.0
	var lens_rect := Rect2(rim_rect.position + Vector2(lens_inset, lens_inset), rim_rect.size - Vector2(lens_inset * 2, lens_inset * 2))
	var lens_color := GOGGLES_LENS_BASE
	if goggles_glow > 0.05:
		lens_color = lens_color.lerp(Color("#ffffff"), goggles_glow * 0.8)
	draw_rect(lens_rect, lens_color)
	
	# 3. Diagonal Specular Glass Reflection Slash
	var slash_pts := PackedVector2Array([
		lens_rect.position + Vector2(lens_rect.size.x * 0.2, 0),
		lens_rect.position + Vector2(lens_rect.size.x * 0.5, 0),
		lens_rect.position + Vector2(0, lens_rect.size.y * 0.75),
		lens_rect.position + Vector2(0, lens_rect.size.y * 0.4)
	])
	draw_colored_polygon(slash_pts, Color(1.0, 1.0, 1.0, 0.45 + goggles_glow * 0.5))
	
	# Secondary tiny corner glint
	draw_circle(lens_rect.position + Vector2(lens_rect.size.x - 3, 3), 1.5, Color("#ffffff"))
	
	# 4. Corner Rivet Studs
	draw_circle(rim_rect.position + Vector2(2.5, 2.5), 1.5, GOGGLES_RIVET)
	draw_circle(rim_rect.position + Vector2(w - 2.5, 2.5), 1.5, GOGGLES_RIVET)
	draw_circle(rim_rect.position + Vector2(2.5, h - 2.5), 1.5, GOGGLES_RIVET)
	draw_circle(rim_rect.position + Vector2(w - 2.5, h - 2.5), 1.5, GOGGLES_RIVET)

func _draw_sparkle(pos: Vector2, size: float) -> void:
	draw_line(pos + Vector2(-size, 0), pos + Vector2(size, 0), Color("#ffffff"), 2.2)
	draw_line(pos + Vector2(0, -size), pos + Vector2(0, size), Color("#ffffff"), 2.2)
	draw_circle(pos, 2.0, Color("#38bdf8"))
