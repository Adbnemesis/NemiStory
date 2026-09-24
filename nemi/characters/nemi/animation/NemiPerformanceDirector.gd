class_name NemiPerformanceDirector
extends Node

## NemiPerformanceDirector - Master Human-Hand-Drawn Performance Engine
## Orchestrates believable, human-timed, hierarchical character acting for Nemi:
## 1. Attention Leads Movement: Eyes shift before head, head leads torso, arms follow.
## 2. Anticipation: Brief subtle compression/counter-lean before major gestures.
## 3. Asymmetric Weight Bearing: Hips shift, legs take load, spine counter-balances.
## 4. Overshoot & Settle: Physical momentum causes soft overshoot before resting.
## 5. Absolute Stillness Holds: Zero procedural jitter or wandering; holds are rock-solid.

signal performance_transition_started(pose_name: String)
signal performance_transition_finished(pose_name: String)

var character: Node2D

var root_bone: Bone2D
var torso_bone: Bone2D
var neck_bone: Bone2D
var head_bone: Bone2D
var skirt_bone: Bone2D

var left_thigh_bone: Bone2D
var left_shin_bone: Bone2D
var left_foot_bone: Bone2D

var right_thigh_bone: Bone2D
var right_shin_bone: Bone2D
var right_foot_bone: Bone2D

var left_upper_arm_bone: Bone2D
var left_lower_arm_bone: Bone2D
var left_hand_bone: Bone2D
var left_hand_visual: Node2D

var right_upper_arm_bone: Bone2D
var right_lower_arm_bone: Bone2D
var right_hand_bone: Bone2D
var right_hand_visual: Node2D

var hair_left_bone: Bone2D
var hair_right_bone: Bone2D
var hair_back_bone: Bone2D

var face: Node2D

var active_tween: Tween

func _init(p_character: Node2D = null) -> void:
	if p_character:
		initialize(p_character)

func initialize(p_character: Node2D) -> void:
	character = p_character
	_cache_bones()

func _cache_bones() -> void:
	if not character:
		return
	var skeleton = character.get_node_or_null("Skeleton2D")
	if not skeleton:
		return
	root_bone = skeleton.get_node_or_null("RootBone")
	if not root_bone:
		return
	
	torso_bone = root_bone.get_node_or_null("TorsoBone")
	skirt_bone = root_bone.get_node_or_null("SkirtBone")
	
	left_thigh_bone = root_bone.get_node_or_null("LeftThighBone")
	if left_thigh_bone:
		left_shin_bone = left_thigh_bone.get_node_or_null("LeftShinBone")
		if left_shin_bone:
			left_foot_bone = left_shin_bone.get_node_or_null("LeftFootBone")
			
	right_thigh_bone = root_bone.get_node_or_null("RightThighBone")
	if right_thigh_bone:
		right_shin_bone = right_thigh_bone.get_node_or_null("RightShinBone")
		if right_shin_bone:
			right_foot_bone = right_shin_bone.get_node_or_null("RightFootBone")
			
	if torso_bone:
		neck_bone = torso_bone.get_node_or_null("NeckBone")
		if neck_bone:
			head_bone = neck_bone.get_node_or_null("HeadBone")
			if head_bone:
				face = head_bone.get_node_or_null("FaceVisual")
				hair_left_bone = head_bone.get_node_or_null("HairLeftBone")
				hair_right_bone = head_bone.get_node_or_null("HairRightBone")
				hair_back_bone = head_bone.get_node_or_null("HairBackBone")
				
		left_upper_arm_bone = torso_bone.get_node_or_null("LeftUpperArmBone")
		if left_upper_arm_bone:
			left_lower_arm_bone = left_upper_arm_bone.get_node_or_null("LeftLowerArmBone")
			if left_lower_arm_bone:
				left_hand_bone = left_lower_arm_bone.get_node_or_null("LeftHandBone")
				if left_hand_bone:
					left_hand_visual = left_hand_bone.get_node_or_null("LeftHandVisual")
					
		right_upper_arm_bone = torso_bone.get_node_or_null("RightUpperArmBone")
		if right_upper_arm_bone:
			right_lower_arm_bone = right_upper_arm_bone.get_node_or_null("RightLowerArmBone")
			if right_lower_arm_bone:
				right_hand_bone = right_lower_arm_bone.get_node_or_null("RightHandBone")
				if right_hand_bone:
					right_hand_visual = right_hand_bone.get_node_or_null("RightHandVisual")

## Hierarchical, organic pose transition that feels hand-animated.
## Follows Disney / Anime animation hierarchy:
## Attention/Gaze -> Anticipation -> Pelvis/Legs -> Torso -> Head -> Arms -> Hands -> Settle
func perform_pose_transition(target_pose_name: String, duration: float = 0.28, with_anticipation: bool = true, with_overshoot: bool = true) -> void:
	if not character:
		return
	_cache_bones()
	
	var pose_data: Dictionary = NemiPose.get_pose(target_pose_name)
	if pose_data.is_empty():
		push_warning("NemiPerformanceDirector: Unknown pose '%s'" % target_pose_name)
		return
		
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	performance_transition_started.emit(target_pose_name)
	character.set("current_pose_name", target_pose_name)
	
	# If duration is 0, snap immediately
	if duration <= 0.0:
		_snap_to_pose(pose_data)
		performance_transition_finished.emit(target_pose_name)
		return

	var target_root_pos: Vector2 = pose_data.get("root_offset", Vector2.ZERO)
	var target_torso_rot: float = pose_data.get("torso_rot", 0.0)
	var target_neck_rot: float = pose_data.get("neck_rot", 0.0)
	var target_head_rot: float = pose_data.get("head_rot", 0.0)
	var target_skirt_rot: float = pose_data.get("skirt_rot", 0.0)
	
	var target_l_thigh: float = pose_data.get("left_thigh_rot", 0.0)
	var target_l_shin: float = pose_data.get("left_shin_rot", 0.0)
	var target_l_foot: float = pose_data.get("left_foot_rot", 0.0)
	var target_r_thigh: float = pose_data.get("right_thigh_rot", 0.0)
	var target_r_shin: float = pose_data.get("right_shin_rot", 0.0)
	var target_r_foot: float = pose_data.get("right_foot_rot", 0.0)
	
	var target_l_upper: float = pose_data.get("left_upper_arm_rot", 0.0)
	var target_l_lower: float = pose_data.get("left_lower_arm_rot", 0.0)
	var target_r_upper: float = pose_data.get("right_upper_arm_rot", 0.0)
	var target_r_lower: float = pose_data.get("right_lower_arm_rot", 0.0)
	
	var target_hair_left: float = pose_data.get("hair_left_rot", 0.0)
	var target_hair_right: float = pose_data.get("hair_right_rot", 0.0)
	var target_hair_back: float = pose_data.get("hair_back_rot", 0.0)
	
	# Step 1: Attention Leads Movement (Gaze shifts first)
	if "gaze" in pose_data and face:
		face.set("gaze_direction", pose_data["gaze"])
	if "expression" in pose_data and character.has_method("set_expression"):
		character.set_expression(pose_data["expression"])

	# Create the coordinated performance tween
	active_tween = character.create_tween().set_parallel(true)
	
	var current_root_pos: Vector2 = root_bone.position if root_bone else Vector2.ZERO
	var current_torso_rot: float = torso_bone.rotation if torso_bone else 0.0
	var current_head_rot: float = head_bone.rotation if head_bone else 0.0
	
	var root_delta: Vector2 = target_root_pos - current_root_pos
	var torso_delta: float = target_torso_rot - current_torso_rot
	
	# Anticipation phase timings
	var antic_dur: float = 0.06 if (with_anticipation and duration >= 0.18 and (absf(torso_delta) > 0.05 or root_delta.length() > 3.0)) else 0.0
	var main_dur: float = duration - antic_dur
	
	# Step 2: Anticipation (Dip/Counter-lean)
	if antic_dur > 0.0 and root_bone:
		var antic_root: Vector2 = current_root_pos + Vector2(-signf(root_delta.x) * 2.0 if absf(root_delta.x) > 2.0 else 0.0, 2.5)
		var antic_torso: float = current_torso_rot - signf(torso_delta) * 0.03 if absf(torso_delta) > 0.04 else current_torso_rot
		
		# Quick squash / preparation
		active_tween.tween_property(root_bone, "position", antic_root, antic_dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if torso_bone:
			active_tween.tween_property(torso_bone, "rotation", antic_torso, antic_dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Step 3: Pelvis, Legs, Weight shift (Staggered: starts at antic_dur)
	var pelvis_delay: float = antic_dur
	var pelvis_dur: float = main_dur * 0.85
	
	if root_bone:
		var root_tw: PropertyTweener = active_tween.tween_property(root_bone, "position", target_root_pos, pelvis_dur)
		root_tw.set_delay(pelvis_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
	# Legs Kinematics (Move with pelvis)
	if left_thigh_bone:
		active_tween.tween_property(left_thigh_bone, "rotation", target_l_thigh, pelvis_dur).set_delay(pelvis_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if left_shin_bone:
		active_tween.tween_property(left_shin_bone, "rotation", target_l_shin, pelvis_dur).set_delay(pelvis_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if left_foot_bone:
		active_tween.tween_property(left_foot_bone, "rotation", target_l_foot, pelvis_dur).set_delay(pelvis_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
	if right_thigh_bone:
		active_tween.tween_property(right_thigh_bone, "rotation", target_r_thigh, pelvis_dur).set_delay(pelvis_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if right_shin_bone:
		active_tween.tween_property(right_shin_bone, "rotation", target_r_shin, pelvis_dur).set_delay(pelvis_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if right_foot_bone:
		active_tween.tween_property(right_foot_bone, "rotation", target_r_foot, pelvis_dur).set_delay(pelvis_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Skirt counter-rotates with hips
	if skirt_bone:
		active_tween.tween_property(skirt_bone, "rotation", target_skirt_rot, pelvis_dur).set_delay(pelvis_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Step 4: Torso & Spine (Slight delay after pelvis: +0.02s)
	var torso_delay: float = antic_dur + 0.02
	var torso_dur: float = main_dur * 0.88
	if torso_bone:
		if with_overshoot and absf(torso_delta) > 0.08:
			var overshoot_torso: float = target_torso_rot + torso_delta * 0.08
			var tw1: PropertyTweener = active_tween.tween_property(torso_bone, "rotation", overshoot_torso, torso_dur * 0.7)
			tw1.set_delay(torso_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			var tw2: PropertyTweener = active_tween.tween_property(torso_bone, "rotation", target_torso_rot, torso_dur * 0.3)
			tw2.set_delay(torso_delay + torso_dur * 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		else:
			var tw: PropertyTweener = active_tween.tween_property(torso_bone, "rotation", target_torso_rot, torso_dur)
			tw.set_delay(torso_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Step 5: Neck and Head (Follows torso: +0.04s delay)
	var head_delay: float = antic_dur + 0.04
	var head_dur: float = main_dur * 0.85
	if neck_bone:
		active_tween.tween_property(neck_bone, "rotation", target_neck_rot, head_dur).set_delay(head_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if head_bone:
		var head_delta: float = target_head_rot - current_head_rot
		if with_overshoot and absf(head_delta) > 0.08:
			var overshoot_head: float = target_head_rot + head_delta * 0.07
			var htw1: PropertyTweener = active_tween.tween_property(head_bone, "rotation", overshoot_head, head_dur * 0.72)
			htw1.set_delay(head_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			var htw2: PropertyTweener = active_tween.tween_property(head_bone, "rotation", target_head_rot, head_dur * 0.28)
			htw2.set_delay(head_delay + head_dur * 0.72).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		else:
			var htw: PropertyTweener = active_tween.tween_property(head_bone, "rotation", target_head_rot, head_dur)
			htw.set_delay(head_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Step 6: Arms & Gestures (Slight follow-through: +0.05s delay)
	var arm_delay: float = antic_dur + 0.05
	var arm_dur: float = main_dur * 0.85
	if left_upper_arm_bone:
		active_tween.tween_property(left_upper_arm_bone, "rotation", target_l_upper, arm_dur).set_delay(arm_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if left_lower_arm_bone:
		active_tween.tween_property(left_lower_arm_bone, "rotation", target_l_lower, arm_dur * 1.05).set_delay(arm_delay + 0.02).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
	if right_upper_arm_bone:
		active_tween.tween_property(right_upper_arm_bone, "rotation", target_r_upper, arm_dur).set_delay(arm_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if right_lower_arm_bone:
		active_tween.tween_property(right_lower_arm_bone, "rotation", target_r_lower, arm_dur * 1.05).set_delay(arm_delay + 0.02).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Hand switch: switch hand poses midway through arm travel
	if "left_hand_pose" in pose_data and left_hand_visual:
		var hand_delay: float = arm_delay + arm_dur * 0.45
		active_tween.tween_callback(func():
			if left_hand_visual:
				left_hand_visual.set("hand_pose", pose_data["left_hand_pose"])
		).set_delay(hand_delay)
		
	if "right_hand_pose" in pose_data and right_hand_visual:
		var hand_delay: float = arm_delay + arm_dur * 0.45
		active_tween.tween_callback(func():
			if right_hand_visual:
				right_hand_visual.set("hand_pose", pose_data["right_hand_pose"])
		).set_delay(hand_delay)

	# Step 7: Secondary Hair Physics (Lags head motion, then settles)
	var hair_delay: float = head_delay + 0.02
	var hair_dur: float = main_dur * 0.95
	var hair_drag: float = -torso_delta * 0.25 # Inertial hair flare
	
	if hair_left_bone:
		var hair_tw1: PropertyTweener = active_tween.tween_property(hair_left_bone, "rotation", target_hair_left + hair_drag, hair_dur * 0.5)
		hair_tw1.set_delay(hair_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		var hair_tw2: PropertyTweener = active_tween.tween_property(hair_left_bone, "rotation", target_hair_left, hair_dur * 0.5)
		hair_tw2.set_delay(hair_delay + hair_dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		character.set("_base_hair_left_rot", target_hair_left)
		
	if hair_right_bone:
		var hair_tw1: PropertyTweener = active_tween.tween_property(hair_right_bone, "rotation", target_hair_right + hair_drag, hair_dur * 0.5)
		hair_tw1.set_delay(hair_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		var hair_tw2: PropertyTweener = active_tween.tween_property(hair_right_bone, "rotation", target_hair_right, hair_dur * 0.5)
		hair_tw2.set_delay(hair_delay + hair_dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		character.set("_base_hair_right_rot", target_hair_right)
		
	if hair_back_bone:
		var hair_tw1: PropertyTweener = active_tween.tween_property(hair_back_bone, "rotation", target_hair_back + hair_drag * 0.6, hair_dur * 0.5)
		hair_tw1.set_delay(hair_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		var hair_tw2: PropertyTweener = active_tween.tween_property(hair_back_bone, "rotation", target_hair_back, hair_dur * 0.5)
		hair_tw2.set_delay(hair_delay + hair_dur * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		character.set("_base_hair_back_rot", target_hair_back)

	active_tween.finished.connect(func():
		performance_transition_finished.emit(target_pose_name)
		if character.has_signal("pose_changed"):
			character.pose_changed.emit(target_pose_name)
	, CONNECT_ONE_SHOT)

## Instant snap to pose without interpolation (Storytime cut style)
func _snap_to_pose(data: Dictionary) -> void:
	if root_bone: root_bone.position = data.get("root_offset", Vector2.ZERO)
	if torso_bone: torso_bone.rotation = data.get("torso_rot", 0.0)
	if neck_bone: neck_bone.rotation = data.get("neck_rot", 0.0)
	if head_bone: head_bone.rotation = data.get("head_rot", 0.0)
	if skirt_bone: skirt_bone.rotation = data.get("skirt_rot", 0.0)
	
	if left_thigh_bone: left_thigh_bone.rotation = data.get("left_thigh_rot", 0.0)
	if left_shin_bone: left_shin_bone.rotation = data.get("left_shin_rot", 0.0)
	if left_foot_bone: left_foot_bone.rotation = data.get("left_foot_rot", 0.0)
	
	if right_thigh_bone: right_thigh_bone.rotation = data.get("right_thigh_rot", 0.0)
	if right_shin_bone: right_shin_bone.rotation = data.get("right_shin_rot", 0.0)
	if right_foot_bone: right_foot_bone.rotation = data.get("right_foot_rot", 0.0)
	
	if left_upper_arm_bone: left_upper_arm_bone.rotation = data.get("left_upper_arm_rot", 0.0)
	if left_lower_arm_bone: left_lower_arm_bone.rotation = data.get("left_lower_arm_rot", 0.0)
	if right_upper_arm_bone: right_upper_arm_bone.rotation = data.get("right_upper_arm_rot", 0.0)
	if right_lower_arm_bone: right_lower_arm_bone.rotation = data.get("right_lower_arm_rot", 0.0)
	
	if hair_left_bone:
		hair_left_bone.rotation = data.get("hair_left_rot", 0.0)
		character.set("_base_hair_left_rot", hair_left_bone.rotation)
	if hair_right_bone:
		hair_right_bone.rotation = data.get("hair_right_rot", 0.0)
		character.set("_base_hair_right_rot", hair_right_bone.rotation)
	if hair_back_bone:
		hair_back_bone.rotation = data.get("hair_back_rot", 0.0)
		character.set("_base_hair_back_rot", hair_back_bone.rotation)
		
	if "left_hand_pose" in data and left_hand_visual:
		left_hand_visual.set("hand_pose", data["left_hand_pose"])
	if "right_hand_pose" in data and right_hand_visual:
		right_hand_visual.set("hand_pose", data["right_hand_pose"])
		
	if "expression" in data and character.has_method("set_expression"):
		character.set_expression(data["expression"])
	if "gaze" in data and face:
		face.set("gaze_direction", data["gaze"])
		
	if character.has_signal("pose_changed"):
		character.pose_changed.emit(character.get("current_pose_name"))

## Subtle contrapposto weight shift: shifts hips and counter-balances spine
func shift_weight(side: String = "right", duration: float = 0.28) -> void:
	if not character:
		return
	_cache_bones()
	
	var target_hip_x: float = 0.0
	var target_skirt: float = 0.0
	var target_torso: float = 0.0
	var target_l_leg: float = 0.0
	var target_r_leg: float = 0.0
	
	match side.to_lower():
		"left":
			target_hip_x = -13.0
			target_skirt = 0.05
			target_torso = 0.035
			target_l_leg = 0.02
			target_r_leg = 0.08
		"right":
			target_hip_x = 13.0
			target_skirt = -0.05
			target_torso = -0.035
			target_l_leg = -0.08
			target_r_leg = -0.02
		_: # "center" or "neutral"
			target_hip_x = 0.0
			target_skirt = 0.0
			target_torso = 0.0
			target_l_leg = 0.0
			target_r_leg = 0.0
			
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	if duration <= 0.0:
		if root_bone: root_bone.position.x = target_hip_x
		if skirt_bone: skirt_bone.rotation = target_skirt
		if torso_bone: torso_bone.rotation = target_torso
		if left_thigh_bone: left_thigh_bone.rotation = target_l_leg
		if right_thigh_bone: right_thigh_bone.rotation = target_r_leg
		return

	active_tween = character.create_tween().set_parallel(true)
	if root_bone:
		active_tween.tween_property(root_bone, "position:x", target_hip_x, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if skirt_bone:
		active_tween.tween_property(skirt_bone, "rotation", target_skirt, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if torso_bone:
		active_tween.tween_property(torso_bone, "rotation", target_torso, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if left_thigh_bone:
		active_tween.tween_property(left_thigh_bone, "rotation", target_l_leg, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if right_thigh_bone:
		active_tween.tween_property(right_thigh_bone, "rotation", target_r_leg, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## First-class stillness hold: clamps all motion and holds motionless
func hold(duration: float) -> void:
	if character:
		character.set("_shake_trauma", 0.0)
		character.set("_hair_sway_velocity", 0.0)
		character.set("_hair_sway_offset", 0.0)
	if character and character.get_tree():
		await character.get_tree().create_timer(duration).timeout
