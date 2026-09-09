class_name StoryCharacter
extends Node2D

## Modular 2D Storytime Character Controller
## Supports instant pose/expression swaps, intentional holds, micro-animations,
## stepped 2s bouncing, and deterministic shake reactions.

signal pose_changed(pose_name: String)
signal expression_changed(expression_name: String)

@export var character_id: String = "storyteller"

# Node references
@onready var body_sprite: Sprite2D = $BodyAnchor/BodySprite
@onready var head_base: Sprite2D = $HeadAnchor/HeadBase
@onready var eyes_sprite: Sprite2D = $HeadAnchor/Face/EyesSprite
@onready var mouth_sprite: Sprite2D = $HeadAnchor/Face/MouthSprite
@onready var blush_sprite: Sprite2D = $HeadAnchor/Face/BlushSprite
@onready var detail_sprite: Sprite2D = $HeadAnchor/Face/DetailSprite
@onready var prop_anchor: Marker2D = $PropAnchor

# Libraries
var poses: Dictionary = {}
var eye_textures: Dictionary = {}
var mouth_textures: Dictionary = {}
var detail_textures: Dictionary = {}

# Current state
var current_pose: String = "neutral"
var current_expression: String = "neutral"

# Micro-motion state
var is_bouncing: bool = false
var bounce_height: float = 22.0
var bounce_hz: float = 6.0
var bounce_elapsed: float = 0.0

var shake_trauma: float = 0.0
var shake_decay: float = 3.0
var shake_elapsed: float = 0.0

var base_position: Vector2 = Vector2.ZERO
var base_eyes_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	base_position = position
	if eyes_sprite:
		base_eyes_position = eyes_sprite.position
	_load_default_library()

func _load_default_library() -> void:
	# Default Body Poses
	register_pose("neutral", load("res://assets/characters/storyteller/body/pose_neutral.png"))
	register_pose("crossed_arms", load("res://assets/characters/storyteller/body/pose_crossed_arms.png"))
	register_pose("gesturing", load("res://assets/characters/storyteller/body/pose_gesturing.png"))
	register_pose("recoil", load("res://assets/characters/storyteller/body/pose_recoil.png"))

	# Default Eye Textures
	register_eyes("neutral", load("res://assets/characters/storyteller/eyes/eyes_neutral.png"))
	register_eyes("squint", load("res://assets/characters/storyteller/eyes/eyes_squint.png"))
	register_eyes("shocked", load("res://assets/characters/storyteller/eyes/eyes_shocked.png"))
	register_eyes("deadpan", load("res://assets/characters/storyteller/eyes/eyes_deadpan.png"))
	register_eyes("sparkle", load("res://assets/characters/storyteller/eyes/eyes_sparkle.png"))
	register_eyes("blink", load("res://assets/characters/storyteller/eyes/eyes_blink.png"))

	# Default Mouth Textures
	register_mouth("open_o", load("res://assets/characters/storyteller/mouths/mouth_open_o.png"))
	register_mouth("smile", load("res://assets/characters/storyteller/mouths/mouth_smile.png"))
	register_mouth("blep", load("res://assets/characters/storyteller/mouths/mouth_blep.png"))
	register_mouth("smirk", load("res://assets/characters/storyteller/mouths/mouth_smirk.png"))
	register_mouth("flat", load("res://assets/characters/storyteller/mouths/mouth_flat.png"))

	# Default Details
	register_detail("blush", load("res://assets/characters/storyteller/details/detail_blush.png"))
	register_detail("sweat", load("res://assets/characters/storyteller/details/detail_sweat.png"))
	register_detail("exclamation", load("res://assets/characters/storyteller/details/detail_exclamation.png"))

func _process(delta: float) -> void:
	var total_offset: Vector2 = Vector2.ZERO

	# 1. Stepped bounce on 2s (rhythmic talking / excitement)
	if is_bouncing:
		bounce_elapsed += delta
		total_offset += HandDrawnMath.stepped_bounce_offset(bounce_elapsed, bounce_height, bounce_hz)

	# 2. Deterministic trauma shake
	if shake_trauma > 0.0:
		shake_elapsed += delta
		total_offset += HandDrawnMath.shake_offset(shake_elapsed, shake_trauma, 16.0, 35.0, 101)
		shake_trauma = maxf(0.0, shake_trauma - shake_decay * delta)

	position = base_position + total_offset

## Register a body pose texture
func register_pose(p_name: String, tex: Texture2D) -> void:
	poses[p_name] = tex

## Register facial parts
func register_eyes(e_name: String, tex: Texture2D) -> void:
	eye_textures[e_name] = tex

func register_mouth(m_name: String, tex: Texture2D) -> void:
	mouth_textures[m_name] = tex

func register_detail(d_name: String, tex: Texture2D) -> void:
	detail_textures[d_name] = tex

## Instant pose replacement (0-frame snap)
func set_pose(p_name: String) -> void:
	if poses.has(p_name):
		current_pose = p_name
		if body_sprite:
			body_sprite.texture = poses[p_name]
		emit_signal("pose_changed", p_name)
	else:
		push_warning("Pose not found: " + p_name)

## Modular expression swap
func set_expression(expr_name: String) -> void:
	current_expression = expr_name
	match expr_name:
		"neutral":
			_apply_face("neutral", "open_o", false, "")
		"happy", "squint_happy":
			_apply_face("squint", "smile", true, "")
		"shocked", "startled":
			_apply_face("shocked", "open_o", false, "sweat")
		"smug", "blep":
			_apply_face("squint", "blep", true, "")
		"deadpan":
			_apply_face("deadpan", "flat", false, "")
		"sparkle", "excited":
			_apply_face("sparkle", "open_o", true, "sparkle")
		_:
			push_warning("Unknown expression preset: " + expr_name)
	emit_signal("expression_changed", expr_name)

func _apply_face(eye_key: String, mouth_key: String, show_blush: bool, detail_key: String) -> void:
	if eyes_sprite and eye_textures.has(eye_key):
		eyes_sprite.texture = eye_textures[eye_key]
	if mouth_sprite and mouth_textures.has(mouth_key):
		mouth_sprite.texture = mouth_textures[mouth_key]
	if blush_sprite:
		blush_sprite.visible = show_blush
	if detail_sprite:
		if detail_key != "" and detail_textures.has(detail_key):
			detail_sprite.texture = detail_textures[detail_key]
			detail_sprite.visible = true
		else:
			detail_sprite.visible = false

## Micro-animation: 2-frame quick blink (open -> closed -> open)
func blink(hold_closed_time: float = 0.08) -> void:
	var prev_eye_tex = eyes_sprite.texture if eyes_sprite else null
	if eye_textures.has("blink") and eyes_sprite:
		eyes_sprite.texture = eye_textures["blink"]
	await get_tree().create_timer(hold_closed_time).timeout
	if eyes_sprite and prev_eye_tex:
		eyes_sprite.texture = prev_eye_tex

## Micro-animation: eye dart / glance to a direction
func glance(offset: Vector2, hold_time: float = 0.5) -> void:
	if not eyes_sprite:
		return
	eyes_sprite.position = base_eyes_position + offset
	await get_tree().create_timer(hold_time).timeout
	eyes_sprite.position = base_eyes_position

## Comedic stepped bounce (alternating on 2s)
func start_stepped_bounce(height: float = 22.0, hz: float = 6.0) -> void:
	bounce_height = height
	bounce_hz = hz
	bounce_elapsed = 0.0
	is_bouncing = true

func stop_stepped_bounce() -> void:
	is_bouncing = false
	bounce_elapsed = 0.0
	position = base_position

## Apply sudden impact shake
func apply_shake(trauma: float = 1.0, decay: float = 3.0) -> void:
	shake_trauma = clampf(trauma, 0.0, 1.0)
	shake_decay = decay
	shake_elapsed = 0.0

## Sudden recoil back with overshoot and freeze
func recoil(offset: Vector2 = Vector2(-30, 10), duration: float = 0.15) -> void:
	var start_pos: Vector2 = base_position
	var target_pos: Vector2 = base_position + offset
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "base_position", target_pos, duration)
	apply_shake(0.8, 4.0)
