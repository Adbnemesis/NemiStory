class_name Nemi
extends Node2D

## Master Production Character Controller for NEMI (Rig V1)
## 100% Godot-native 2D rigged vector character.
## Zero image textures or sprite crops.
## Live Bone2D rig + procedural vector drawing + dual palette modes.

signal pose_changed(pose_name: String)
signal expression_changed(expr_name: String)
signal mode_changed(mode_name: String)

const NemiProportions = preload("res://characters/nemi/NemiProportions.gd")
const NemiRigDebug = preload("res://characters/nemi/drawing/NemiRigDebug.gd")
const NemiActingDirector = preload("res://characters/nemi/animation/NemiActingDirector.gd")
const NemiFXDirector = preload("res://characters/nemi/fx/NemiFXDirector.gd")

@onready var skeleton: Skeleton2D = $Skeleton2D
@onready var root_bone: Bone2D = $Skeleton2D/RootBone
@onready var torso_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone
@onready var neck_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone/NeckBone
@onready var head_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone/NeckBone/HeadBone

@onready var hair_back_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone/NeckBone/HeadBone/HairBackBone
@onready var hair_left_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone/NeckBone/HeadBone/HairLeftBone
@onready var hair_right_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone/NeckBone/HeadBone/HairRightBone

@onready var left_upper_arm_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone/LeftUpperArmBone
@onready var left_lower_arm_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone/LeftUpperArmBone/LeftLowerArmBone
@onready var left_hand_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone/LeftUpperArmBone/LeftLowerArmBone/LeftHandBone

@onready var right_upper_arm_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone/RightUpperArmBone
@onready var right_lower_arm_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone/RightUpperArmBone/RightLowerArmBone
@onready var right_hand_bone: Bone2D = $Skeleton2D/RootBone/TorsoBone/RightUpperArmBone/RightLowerArmBone/RightHandBone

@onready var skirt_bone: Bone2D = $Skeleton2D/RootBone/SkirtBone
@onready var left_thigh_bone: Bone2D = $Skeleton2D/RootBone/LeftThighBone
@onready var left_shin_bone: Bone2D = $Skeleton2D/RootBone/LeftThighBone/LeftShinBone
@onready var left_foot_bone: Bone2D = $Skeleton2D/RootBone/LeftThighBone/LeftShinBone/LeftFootBone

@onready var right_thigh_bone: Bone2D = $Skeleton2D/RootBone/RightThighBone
@onready var right_shin_bone: Bone2D = $Skeleton2D/RootBone/RightThighBone/RightShinBone
@onready var right_foot_bone: Bone2D = $Skeleton2D/RootBone/RightThighBone/RightShinBone/RightFootBone

@onready var face: Node2D = $Skeleton2D/RootBone/TorsoBone/NeckBone/HeadBone/FaceVisual
@onready var left_hand_visual: Node2D = $Skeleton2D/RootBone/TorsoBone/LeftUpperArmBone/LeftLowerArmBone/LeftHandBone/LeftHandVisual
@onready var right_hand_visual: Node2D = $Skeleton2D/RootBone/TorsoBone/RightUpperArmBone/RightLowerArmBone/RightHandBone/RightHandVisual
@onready var rig_debug: NemiRigDebug = $RigDebug

# Style manager instance
var style: NemiStyle = NemiStyle.new()

# Dedicated Illustrated Acting Director subsystem
var actor: NemiActingDirector

# Dedicated Expression FX & Reaction Director subsystem
var fx_director: NemiFXDirector

# Active state
var current_pose_name: String = "idle"
var current_expression_name: String = "neutral"
var _active_tween: Tween

# Trauma shake state
var _shake_trauma: float = 0.0
var _shake_decay: float = 4.0
var _base_position: Vector2 = Vector2.ZERO

# Hair follow-through physics state
var _prev_head_rot: float = 0.0
var _hair_sway_velocity: float = 0.0
var _hair_sway_offset: float = 0.0
var _base_hair_back_rot: float = 0.0
var _base_hair_left_rot: float = 0.0
var _base_hair_right_rot: float = 0.0

func _ready() -> void:
	_ensure_nodes()
	if not actor:
		actor = NemiActingDirector.new(self)
		add_child(actor)
	if not fx_director:
		fx_director = NemiFXDirector.new(self)
		add_child(fx_director)
	_base_position = position
	_propagate_style(self)
	reset()

func _ensure_nodes() -> void:
	if not actor:
		actor = NemiActingDirector.new(self)
		add_child(actor)
	if not fx_director:
		fx_director = NemiFXDirector.new(self)
		add_child(fx_director)
	if not skeleton:
		skeleton = get_node_or_null("Skeleton2D")
	if not root_bone and skeleton:
		root_bone = skeleton.get_node_or_null("RootBone")
	if not torso_bone and root_bone:
		torso_bone = root_bone.get_node_or_null("TorsoBone")
	if not neck_bone and torso_bone:
		neck_bone = torso_bone.get_node_or_null("NeckBone")
	if not head_bone and neck_bone:
		head_bone = neck_bone.get_node_or_null("HeadBone")
	if not face and head_bone:
		face = head_bone.get_node_or_null("FaceVisual")
	
	if not hair_back_bone and head_bone:
		hair_back_bone = head_bone.get_node_or_null("HairBackBone")
	if not hair_left_bone and head_bone:
		hair_left_bone = head_bone.get_node_or_null("HairLeftBone")
	if not hair_right_bone and head_bone:
		hair_right_bone = head_bone.get_node_or_null("HairRightBone")
	
	if not left_upper_arm_bone and torso_bone:
		left_upper_arm_bone = torso_bone.get_node_or_null("LeftUpperArmBone")
	if not left_lower_arm_bone and left_upper_arm_bone:
		left_lower_arm_bone = left_upper_arm_bone.get_node_or_null("LeftLowerArmBone")
	if not left_hand_bone and left_lower_arm_bone:
		left_hand_bone = left_lower_arm_bone.get_node_or_null("LeftHandBone")
	if not left_hand_visual and left_hand_bone:
		left_hand_visual = left_hand_bone.get_node_or_null("LeftHandVisual")
	
	if not right_upper_arm_bone and torso_bone:
		right_upper_arm_bone = torso_bone.get_node_or_null("RightUpperArmBone")
	if not right_lower_arm_bone and right_upper_arm_bone:
		right_lower_arm_bone = right_upper_arm_bone.get_node_or_null("RightLowerArmBone")
	if not right_hand_bone and right_lower_arm_bone:
		right_hand_bone = right_lower_arm_bone.get_node_or_null("RightHandBone")
	if not right_hand_visual and right_hand_bone:
		right_hand_visual = right_hand_bone.get_node_or_null("RightHandVisual")
	
	if not skirt_bone and root_bone:
		skirt_bone = root_bone.get_node_or_null("SkirtBone")
	
	if not left_thigh_bone and root_bone:
		left_thigh_bone = root_bone.get_node_or_null("LeftThighBone")
	if not left_shin_bone and left_thigh_bone:
		left_shin_bone = left_thigh_bone.get_node_or_null("LeftShinBone")
	if not left_foot_bone and left_shin_bone:
		left_foot_bone = left_shin_bone.get_node_or_null("LeftFootBone")
	
	if not right_thigh_bone and root_bone:
		right_thigh_bone = root_bone.get_node_or_null("RightThighBone")
	if not right_shin_bone and right_thigh_bone:
		right_shin_bone = right_thigh_bone.get_node_or_null("RightShinBone")
	if not right_foot_bone and right_shin_bone:
		right_foot_bone = right_shin_bone.get_node_or_null("RightFootBone")
	
	if not rig_debug:
		rig_debug = get_node_or_null("RigDebug")

func _propagate_style(node: Node) -> void:
	if node is NemiPart:
		node.style = style
	for child in node.get_children():
		_propagate_style(child)

func _process(delta: float) -> void:
	# Stillness is first-class: clamp any residual sway/shake during holds and freezes
	if actor and (actor.acting_state == "HOLDING" or actor.acting_state == "FROZEN"):
		_shake_trauma = 0.0
		_hair_sway_velocity = 0.0
		_hair_sway_offset = 0.0
		if head_bone:
			_prev_head_rot = head_bone.rotation
		position = _base_position
		return
	
	# 1. Trauma shake
	if _shake_trauma > 0.0:
		_shake_trauma = max(0.0, _shake_trauma - _shake_decay * delta)
		var shake_offset := Vector2(
			randf_range(-1.0, 1.0) * _shake_trauma * 16.0,
			randf_range(-1.0, 1.0) * _shake_trauma * 16.0
		)
		position = _base_position + shake_offset
	else:
		_base_position = position
	
	# 2. Subtle hair follow-through during head turns
	if head_bone and delta > 0.0:
		var current_h_rot: float = head_bone.rotation
		var d_rot: float = current_h_rot - _prev_head_rot
		_prev_head_rot = current_h_rot
		
		# Impulse from head motion
		_hair_sway_velocity -= d_rot * 10.0
		# Spring physics (stiff, settles quickly, stillness is a feature!)
		var spring_k := 28.0
		var damp := 7.0
		_hair_sway_velocity += (-_hair_sway_offset * spring_k - _hair_sway_velocity * damp) * delta
		_hair_sway_offset += _hair_sway_velocity * delta
		
		# Apply secondary sway to hair bones
		if absf(_hair_sway_offset) > 0.0001:
			if hair_left_bone:
				hair_left_bone.rotation = _base_hair_left_rot + _hair_sway_offset * 0.7
			if hair_right_bone:
				hair_right_bone.rotation = _base_hair_right_rot + _hair_sway_offset * 0.7
			if hair_back_bone:
				hair_back_bone.rotation = _base_hair_back_rot + _hair_sway_offset * 0.45


# -------------------------------------------------------------------------
# HIGH-LEVEL AGENT API
# -------------------------------------------------------------------------

## Resets character rig, facial state, and transforms to neutral rest pose
func reset() -> void:
	_ensure_nodes()
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	
	_shake_trauma = 0.0
	_hair_sway_velocity = 0.0
	_hair_sway_offset = 0.0
	_base_hair_back_rot = 0.0
	_base_hair_left_rot = 0.0
	_base_hair_right_rot = 0.0
	
	set_pose("idle", 0.0)
	set_expression("neutral")
	look("center")
	
	if hair_left_bone: hair_left_bone.rotation = 0.0
	if hair_right_bone: hair_right_bone.rotation = 0.0
	if hair_back_bone: hair_back_bone.rotation = 0.0

## Sets the character's pose via live rig transforms.
## If transition_time == 0.0, uses 0-frame snap cut (storytime style).
func set_pose(pose_name: String, transition_time: float = 0.0) -> void:
	_ensure_nodes()
	current_pose_name = pose_name
	var pose_data: Dictionary = NemiPose.get_pose(pose_name)
	
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	
	if transition_time <= 0.0:
		# 0-frame snap cut
		_apply_pose_data(pose_data)
	else:
		# Stepped / tween transition
		_active_tween = create_tween().set_parallel(true)
		_tween_bone(torso_bone, pose_data.get("torso_rot", 0.0), transition_time)
		_tween_bone(neck_bone, pose_data.get("neck_rot", 0.0), transition_time)
		_tween_bone(head_bone, pose_data.get("head_rot", 0.0), transition_time)
		_tween_bone(left_upper_arm_bone, pose_data.get("left_upper_arm_rot", 0.0), transition_time)
		_tween_bone(left_lower_arm_bone, pose_data.get("left_lower_arm_rot", 0.0), transition_time)
		_tween_bone(right_upper_arm_bone, pose_data.get("right_upper_arm_rot", 0.0), transition_time)
		_tween_bone(right_lower_arm_bone, pose_data.get("right_lower_arm_rot", 0.0), transition_time)
		_tween_bone(skirt_bone, pose_data.get("skirt_rot", 0.0), transition_time)
		_tween_bone(left_thigh_bone, pose_data.get("left_thigh_rot", 0.0), transition_time)
		_tween_bone(left_shin_bone, pose_data.get("left_shin_rot", 0.0), transition_time)
		_tween_bone(left_foot_bone, pose_data.get("left_foot_rot", 0.0), transition_time)
		_tween_bone(right_thigh_bone, pose_data.get("right_thigh_rot", 0.0), transition_time)
		_tween_bone(right_shin_bone, pose_data.get("right_shin_rot", 0.0), transition_time)
		_tween_bone(right_foot_bone, pose_data.get("right_foot_rot", 0.0), transition_time)
		
		if "hair_back_rot" in pose_data and hair_back_bone:
			_tween_bone(hair_back_bone, pose_data["hair_back_rot"], transition_time)
			_base_hair_back_rot = pose_data["hair_back_rot"]
		if "hair_left_rot" in pose_data and hair_left_bone:
			_tween_bone(hair_left_bone, pose_data["hair_left_rot"], transition_time)
			_base_hair_left_rot = pose_data["hair_left_rot"]
		if "hair_right_rot" in pose_data and hair_right_bone:
			_tween_bone(hair_right_bone, pose_data["hair_right_rot"], transition_time)
			_base_hair_right_rot = pose_data["hair_right_rot"]
		
		# Hand poses and expressions update immediately
		if "left_hand_pose" in pose_data and left_hand_visual:
			left_hand_visual.hand_pose = pose_data["left_hand_pose"]
		if "right_hand_pose" in pose_data and right_hand_visual:
			right_hand_visual.hand_pose = pose_data["right_hand_pose"]
		if "expression" in pose_data and face:
			set_expression(pose_data["expression"])
		if "gaze" in pose_data and face:
			face.gaze_direction = pose_data["gaze"]
	
	pose_changed.emit(pose_name)

func _apply_pose_data(data: Dictionary) -> void:
	if torso_bone: torso_bone.rotation = data.get("torso_rot", 0.0)
	if neck_bone: neck_bone.rotation = data.get("neck_rot", 0.0)
	if head_bone: head_bone.rotation = data.get("head_rot", 0.0)
	if left_upper_arm_bone: left_upper_arm_bone.rotation = data.get("left_upper_arm_rot", 0.0)
	if left_lower_arm_bone: left_lower_arm_bone.rotation = data.get("left_lower_arm_rot", 0.0)
	if right_upper_arm_bone: right_upper_arm_bone.rotation = data.get("right_upper_arm_rot", 0.0)
	if right_lower_arm_bone: right_lower_arm_bone.rotation = data.get("right_lower_arm_rot", 0.0)
	if skirt_bone: skirt_bone.rotation = data.get("skirt_rot", 0.0)
	if left_thigh_bone: left_thigh_bone.rotation = data.get("left_thigh_rot", 0.0)
	if left_shin_bone: left_shin_bone.rotation = data.get("left_shin_rot", 0.0)
	if left_foot_bone: left_foot_bone.rotation = data.get("left_foot_rot", 0.0)
	if right_thigh_bone: right_thigh_bone.rotation = data.get("right_thigh_rot", 0.0)
	if right_shin_bone: right_shin_bone.rotation = data.get("right_shin_rot", 0.0)
	if right_foot_bone: right_foot_bone.rotation = data.get("right_foot_rot", 0.0)
	
	if hair_back_bone:
		_base_hair_back_rot = data.get("hair_back_rot", 0.0)
		hair_back_bone.rotation = _base_hair_back_rot
	if hair_left_bone:
		_base_hair_left_rot = data.get("hair_left_rot", 0.0)
		hair_left_bone.rotation = _base_hair_left_rot
	if hair_right_bone:
		_base_hair_right_rot = data.get("hair_right_rot", 0.0)
		hair_right_bone.rotation = _base_hair_right_rot
	
	if "left_hand_pose" in data and left_hand_visual:
		left_hand_visual.set("hand_pose", data["left_hand_pose"])
	if "right_hand_pose" in data and right_hand_visual:
		right_hand_visual.set("hand_pose", data["right_hand_pose"])
	if "expression" in data and face:
		set_expression(data["expression"])
	if "gaze" in data and face:
		face.set("gaze_direction", data["gaze"])

func _tween_bone(bone: Bone2D, target_rot: float, duration: float) -> void:
	if bone and _active_tween:
		_active_tween.tween_property(bone, "rotation", target_rot, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## Sets procedural facial expression by name
func set_expression(expr_name: String) -> void:
	_ensure_nodes()
	current_expression_name = expr_name
	if face and face.has_method("set_expression_by_name"):
		face.set_expression_by_name(expr_name)
	expression_changed.emit(expr_name)

## Sets mouth shape by name
func set_mouth_shape(shape_name: String) -> void:
	_ensure_nodes()
	if face and face.has_method("set_mouth_shape"):
		face.set_mouth_shape(shape_name)

## Convenient alias for illustrative mouth shape changes
func mouth(shape_name: String) -> void:
	set_mouth_shape(shape_name)

# -------------------------------------------------------------------------
# EXPRESSION FX & REACTION SYSTEM V1 DELEGATES
# -------------------------------------------------------------------------

## Triggers an expression reaction preset (e.g. "shocked", "confused", "embarrassed", "excited")
func react(reaction_name: String, intensity: int = 3, duration: float = 1.3) -> Node2D:
	_ensure_nodes()
	return fx_director.react(reaction_name, intensity, duration) if fx_director else null

## Spawns a specific low-level procedural FX element
func fx(fx_name: String, anchor_str: String = "", intensity: int = 3, duration: float = 1.2, custom_offset: Vector2 = Vector2.ZERO) -> Node2D:
	_ensure_nodes()
	return fx_director.fx(fx_name, anchor_str, intensity, duration, custom_offset) if fx_director else null

## Triggers temporary cartoon facial exaggeration with non-destructive spring recovery
func face_exaggerate(emotion: String, intensity: int = 3, duration: float = 0.6) -> void:
	_ensure_nodes()
	if face and face.has_method("face_exaggerate"):
		face.face_exaggerate(emotion, intensity, duration)

## Direct FX convenience helpers
func show_sweat(anchor: String = "head_right", intensity: int = 3, duration: float = 1.2) -> Node2D:
	_ensure_nodes()
	return fx_director.show_sweat(anchor, intensity, duration) if fx_director else null

func show_question_mark(anchor: String = "head_right", intensity: int = 3, duration: float = 1.2) -> Node2D:
	_ensure_nodes()
	return fx_director.show_question_mark(anchor, intensity, duration) if fx_director else null

func show_shock_lines(anchor: String = "head_top", intensity: int = 3, duration: float = 1.0) -> Node2D:
	_ensure_nodes()
	return fx_director.show_shock_lines(anchor, intensity, duration) if fx_director else null

func show_blush(intensity: int = 3, duration: float = 1.5) -> Node2D:
	_ensure_nodes()
	return fx_director.show_blush(intensity, duration) if fx_director else null

func show_stress_marks(anchor: String = "head_right", intensity: int = 3, duration: float = 1.2) -> Node2D:
	_ensure_nodes()
	return fx_director.show_stress_marks(anchor, intensity, duration) if fx_director else null

func show_sparkles(anchor: String = "head_left", intensity: int = 3, duration: float = 1.4) -> Node2D:
	_ensure_nodes()
	return fx_director.show_sparkles(anchor, intensity, duration) if fx_director else null

func show_lightbulb(anchor: String = "head_top", intensity: int = 3, duration: float = 1.4) -> Node2D:
	_ensure_nodes()
	return fx_director.show_lightbulb(anchor, intensity, duration) if fx_director else null

func clear_all_fx(immediate: bool = false) -> void:
	if fx_director:
		fx_director.clear_all_fx(immediate)

## Directional eye gaze ("center", "left", "right", "up", "down")
func look(dir_name: String) -> void:
	_ensure_nodes()
	if face and face.has_method("look"):
		face.look(dir_name)

## Continuous 2D eye gaze vector (-1.0 to 1.0)
func look_at_direction(dir: Vector2) -> void:
	_ensure_nodes()
	if face and "gaze_direction" in face:
		face.gaze_direction = dir

## Sets eyebrow offset and tilt
func set_eyebrow(side: String, raise_amount: float, tilt_amount: float) -> void:
	_ensure_nodes()
	if face and face.has_method("set_eyebrow"):
		face.set_eyebrow(side, -raise_amount, tilt_amount)

## Sets eye openness (0.0 = closed/blink, 1.0 = normal, 1.35 = wide shocked)
func set_eye_openness(openness: float) -> void:
	_ensure_nodes()
	if face and "eye_openness" in face:
		face.eye_openness = openness

## Sets pupil scaling for dilation/constriction
func set_pupil_scale(scale: float) -> void:
	_ensure_nodes()
	if face and "pupil_scale" in face:
		face.pupil_scale = scale

## Toggles micro-expression comic accents (blush, sweat, sparkles, question, shock_lines)
func set_micro_accent(accent_name: String, active: bool) -> void:
	_ensure_nodes()
	if face and face.has_method("set_micro_accent"):
		face.set_micro_accent(accent_name, active)

## Triggers an organic procedural blink
func blink(duration: float = 0.18) -> void:
	_ensure_nodes()
	if face and face.has_method("trigger_blink"):
		face.trigger_blink(duration)

## Turns the head left/right with subtle motivated hair follow-through
func head_turn(angle_deg: float, transition_time: float = 0.2) -> void:
	_ensure_nodes()
	var target_rot := deg_to_rad(angle_deg)
	if transition_time <= 0.0:
		if head_bone: head_bone.rotation = target_rot * 0.75
		if neck_bone: neck_bone.rotation = target_rot * 0.25
	else:
		var tw := create_tween().set_parallel(true)
		if head_bone:
			tw.tween_property(head_bone, "rotation", target_rot * 0.75, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if neck_bone:
			tw.tween_property(neck_bone, "rotation", target_rot * 0.25, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## Tilts the head left/right
func head_tilt(angle_deg: float, transition_time: float = 0.2) -> void:
	_ensure_nodes()
	var target_rot := deg_to_rad(angle_deg)
	if transition_time <= 0.0:
		if head_bone: head_bone.rotation = target_rot
	else:
		create_tween().tween_property(head_bone, "rotation", target_rot, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## Quick affirmative conversational nod
func nod(amount: float = 1.0, duration: float = 0.3) -> void:
	_ensure_nodes()
	if not head_bone: return
	var orig_rot := head_bone.rotation
	var dip := deg_to_rad(8.0 * amount)
	var tw := create_tween()
	tw.tween_property(head_bone, "rotation", orig_rot + dip, duration * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(head_bone, "rotation", orig_rot, duration * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

## Leans the character body
func lean(angle_deg: float, duration: float = 0.2) -> void:
	_ensure_nodes()
	var target_rot := deg_to_rad(angle_deg)
	if duration <= 0.0:
		if torso_bone: torso_bone.rotation = target_rot
		if skirt_bone: skirt_bone.rotation = target_rot * 0.6
	else:
		var tw := create_tween().set_parallel(true)
		if torso_bone:
			tw.tween_property(torso_bone, "rotation", target_rot, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if skirt_bone:
			tw.tween_property(skirt_bone, "rotation", target_rot * 0.6, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## Recoils backward with comedic shock
func recoil(strength: float = 0.4) -> void:
	set_pose("recoiling", 0.08)
	shake(strength)

## Trauma screen shake
func shake(trauma: float = 0.5) -> void:
	_shake_trauma = clamp(trauma, 0.0, 1.0)

## Arm control with specific angles and hand pose
# -------------------------------------------------------------------------
# ILLUSTRATED ACTING API (DELEGATED TO NemiActingDirector)
# -------------------------------------------------------------------------

## First-class stillness hold primitive
func hold(duration: float) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.hold(duration)

## Completely freezes character animation and cancels momentum
func freeze(duration: float = -1.0) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.freeze(duration)

## Reusable attention behavior: eyes move -> pause -> head follows -> hold
func look_at_target(direction: Variant, speed: Variant = "fast", hold_before_head: float = 0.15, with_eyebrow: bool = false) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.look_at_target(direction, speed, hold_before_head, with_eyebrow)

func attention(direction: Variant = "right") -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.look_at_target(direction, "fast", 0.15, true)

## Snappy directional eye dart
func eye_dart(dir: Variant, hold_duration: float = 0.15) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.eye_dart(dir, hold_duration)

## Disbelief or refusal head shake
func shake_head(intensity: float = 1.0, count: int = 2) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.shake_head(intensity, count)

## Pointing gesture
func point(side: String = "right", speed: Variant = "fast", with_anticipation: bool = false, with_overshoot: bool = true) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.body.point(side, speed, with_anticipation, with_overshoot)

## Shrug gesture
func shrug(intensity: float = 1.0) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.shrug(intensity)

## Wave gesture
func wave(side: String = "right", cycles: int = 2) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.wave(side, cycles)

## Hands together introverted gesture
func hands_together() -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.hands_together()

## Hands down casual gesture
func hands_down() -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.hands_down()

## Synchronizes live illustrative lip-sync mouth animation to spoken phrase
func speak(text: String, duration: float, emotion: String = "normal") -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.speak(text, duration, emotion)

## Conversational gesture towards oneself
func gesture_self(duration: float = 0.22) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.gesture_self(duration)

## Conversational open palm gesture
func gesture_open_palm(side: String = "right", duration: float = 0.22) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.gesture_open_palm(side, duration)

func open_palm(side: String = "right", duration: float = 0.22) -> void:
	await gesture_open_palm(side, duration)

## Thinking chin tap gesture
func gesture_thinking(duration: float = 0.24) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.gesture_thinking(duration)

## Confident chest puff pose
func chest_puff(duration: float = 0.25) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.chest_puff(duration)

## Sudden posture collapse / failure drop
func collapse(intensity: float = 1.0, duration: float = 0.25) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.collapse(intensity, duration)

## Sincere / passionate hand on chest gesture
func hand_on_chest(duration: float = 0.22) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.hand_on_chest(duration)

## Comedic vibration tremor
func tremble(intensity: float = 0.5, duration: float = 1.0) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.tremble(intensity, duration)

## Absolute zero-motion freeze hold
func freeze_stillness(duration: float) -> void:
	if not actor: _ensure_nodes()
	if actor: await actor.freeze_stillness(duration)


## Plays a pre-composed reaction sequence (Tests A-J or named reactions)
func play_reaction(reaction_name: String) -> void:
	if not actor: _ensure_nodes()
	if not actor or not actor.reactions: return
	
	match reaction_name.to_lower():
		"a", "test_a", "attention": await actor.reactions.test_a_attention()
		"b", "test_b", "conversational": await actor.reactions.test_b_conversational()
		"c", "test_c", "confusion": await actor.reactions.test_c_confusion()
		"d", "test_d", "realization": await actor.reactions.test_d_realization()
		"e", "test_e", "shock": await actor.reactions.test_e_shock()
		"f", "test_f", "deadpan": await actor.reactions.test_f_deadpan()
		"g", "test_g", "exaggerated", "exaggerated_action": await actor.reactions.test_g_exaggerated_action()
		"h", "test_h", "novel", "novel_combination": await actor.reactions.test_h_novel_combination()
		"i", "test_i", "multistage", "multistage_reaction": await actor.reactions.test_i_multistage_reaction()
		"j", "test_j", "three_intensities": await actor.reactions.test_j_three_intensities()
		"embarrassment": await actor.reactions.embarrassment()
		"awkward", "awkward_pause": await actor.reactions.awkward_pause()
		"comedic_timing": await actor.reactions.comedic_timing()
		_: await actor.reactions.test_a_attention()


## Creates a fluent acting sequence
func create_sequence() -> NemiSequence:
	if not actor: _ensure_nodes()
	return actor.create_sequence() if actor else null

## Full character reset to baseline
func reset_state() -> void:
	reset()

## Arm control with specific angles and hand pose
func set_arm(is_left: bool, upper_rot_deg: float, lower_rot_deg: float, hand_pose_str: String = "relaxed", transition_time: float = 0.0) -> void:
	_ensure_nodes()
	var u_bone := left_upper_arm_bone if is_left else right_upper_arm_bone
	var l_bone := left_lower_arm_bone if is_left else right_lower_arm_bone
	var h_vis := left_hand_visual if is_left else right_hand_visual
	
	var u_target := deg_to_rad(upper_rot_deg)
	var l_target := deg_to_rad(lower_rot_deg)
	
	if transition_time <= 0.0:
		if u_bone: u_bone.rotation = u_target
		if l_bone: l_bone.rotation = l_target
	else:
		var tw := create_tween().set_parallel(true)
		if u_bone: tw.tween_property(u_bone, "rotation", u_target, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if l_bone: tw.tween_property(l_bone, "rotation", l_target, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if h_vis:
		set_hand_pose(is_left, hand_pose_str)

## Leg control with specific angles
func set_leg(is_left: bool, thigh_rot_deg: float, shin_rot_deg: float, foot_rot_deg: float, transition_time: float = 0.0) -> void:
	_ensure_nodes()
	var t_bone := left_thigh_bone if is_left else right_thigh_bone
	var s_bone := left_shin_bone if is_left else right_shin_bone
	var f_bone := left_foot_bone if is_left else right_foot_bone
	
	var t_target := deg_to_rad(thigh_rot_deg)
	var s_target := deg_to_rad(shin_rot_deg)
	var f_target := deg_to_rad(foot_rot_deg)
	
	if transition_time <= 0.0:
		if t_bone: t_bone.rotation = t_target
		if s_bone: s_bone.rotation = s_target
		if f_bone: f_bone.rotation = f_target
	else:
		var tw := create_tween().set_parallel(true)
		if t_bone: tw.tween_property(t_bone, "rotation", t_target, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if s_bone: tw.tween_property(s_bone, "rotation", s_target, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if f_bone: tw.tween_property(f_bone, "rotation", f_target, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## Sets hand gesture ("relaxed", "pointing", "fist", "open")
func set_hand_pose(is_left: bool, pose_str: String) -> void:
	_ensure_nodes()
	var h_vis := left_hand_visual if is_left else right_hand_visual
	if not h_vis: return
	
	match pose_str.to_lower():
		"pointing", "point":
			h_vis.set("hand_pose", NemiLimbPart.HandPose.POINTING)
		"fist", "clenched":
			h_vis.set("hand_pose", NemiLimbPart.HandPose.FIST)
		"open", "gesture", "palm":
			h_vis.set("hand_pose", NemiLimbPart.HandPose.OPEN)
		_:
			h_vis.set("hand_pose", NemiLimbPart.HandPose.RELAXED)

## Sets hair mass sway angles
func set_hair_sway(back_deg: float, left_deg: float, right_deg: float, transition_time: float = 0.2) -> void:
	_ensure_nodes()
	_base_hair_back_rot = deg_to_rad(back_deg)
	_base_hair_left_rot = deg_to_rad(left_deg)
	_base_hair_right_rot = deg_to_rad(right_deg)
	
	if transition_time <= 0.0:
		if hair_back_bone: hair_back_bone.rotation = _base_hair_back_rot
		if hair_left_bone: hair_left_bone.rotation = _base_hair_left_rot
		if hair_right_bone: hair_right_bone.rotation = _base_hair_right_rot
	else:
		var tw := create_tween().set_parallel(true)
		if hair_back_bone: tw.tween_property(hair_back_bone, "rotation", _base_hair_back_rot, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if hair_left_bone: tw.tween_property(hair_left_bone, "rotation", _base_hair_left_rot, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if hair_right_bone: tw.tween_property(hair_right_bone, "rotation", _base_hair_right_rot, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## Switches art mode by name ("color" or "monochrome")
func set_style(style_name: String) -> void:
	match style_name.to_lower():
		"mono", "monochrome", "ink":
			set_art_mode(NemiStyle.ArtMode.MONOCHROME)
		_:
			set_art_mode(NemiStyle.ArtMode.COLOR)

## Switches between COLOR and MONOCHROME art mode
func set_art_mode(mode: NemiStyle.ArtMode) -> void:
	style.set_mode(mode)
	_propagate_style(self)
	mode_changed.emit("COLOR" if mode == NemiStyle.ArtMode.COLOR else "MONOCHROME")

func toggle_art_mode() -> void:
	style.toggle_mode()
	_propagate_style(self)
	mode_changed.emit("COLOR" if style.current_mode == NemiStyle.ArtMode.COLOR else "MONOCHROME")

func get_art_mode_name() -> String:
	return "COLOR" if style.current_mode == NemiStyle.ArtMode.COLOR else "MONOCHROME"

## Toggles visual rig debug overlay
func set_rig_debug(debug_visible: bool) -> void:
	_ensure_nodes()
	if rig_debug:
		rig_debug.enabled = debug_visible

func toggle_rig_debug() -> void:
	_ensure_nodes()
	if rig_debug:
		rig_debug.enabled = not rig_debug.enabled
