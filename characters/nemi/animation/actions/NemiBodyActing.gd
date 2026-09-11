class_name NemiBodyActing
extends RefCounted

## Dedicated Body Acting & Gesture Subsystem for NEMI (V2 Temporal Rework)
## Implements torso leans, shock recoils, posture shifts, arm/hand gestures,
## and micro-acting body adjustments.

var character: Node2D
var torso_bone: Bone2D
var skirt_bone: Bone2D

var left_upper_arm: Bone2D
var left_lower_arm: Bone2D
var left_hand_bone: Bone2D
var left_hand_visual: Node2D

var right_upper_arm: Bone2D
var right_lower_arm: Bone2D
var right_hand_bone: Bone2D
var right_hand_visual: Node2D

var hair_back_bone: Bone2D
var hair_left_bone: Bone2D
var hair_right_bone: Bone2D

func _init(p_character: Node2D) -> void:
	character = p_character
	if character:
		torso_bone = character.get_node_or_null("Skeleton2D/RootBone/TorsoBone")
		skirt_bone = character.get_node_or_null("Skeleton2D/RootBone/SkirtBone")
		
		if torso_bone:
			left_upper_arm = torso_bone.get_node_or_null("LeftUpperArmBone")
			if left_upper_arm:
				left_lower_arm = left_upper_arm.get_node_or_null("LeftLowerArmBone")
				if left_lower_arm:
					left_hand_bone = left_lower_arm.get_node_or_null("LeftHandBone")
					if left_hand_bone:
						left_hand_visual = left_hand_bone.get_node_or_null("LeftHandVisual")
			
			right_upper_arm = torso_bone.get_node_or_null("RightUpperArmBone")
			if right_upper_arm:
				right_lower_arm = right_upper_arm.get_node_or_null("RightLowerArmBone")
				if right_lower_arm:
					right_hand_bone = right_lower_arm.get_node_or_null("RightHandBone")
					if right_hand_bone:
						right_hand_visual = right_hand_bone.get_node_or_null("RightHandVisual")
			
			var neck: Bone2D = torso_bone.get_node_or_null("NeckBone")
			if neck:
				var head: Bone2D = neck.get_node_or_null("HeadBone")
				if head:
					hair_back_bone = head.get_node_or_null("HairBackBone")
					hair_left_bone = head.get_node_or_null("HairLeftBone")
					hair_right_bone = head.get_node_or_null("HairRightBone")

## Torso lean with natural skirt counter-rotation
func lean(angle_deg: float, duration: float = 0.22, style: String = "normal") -> void:
	if not torso_bone:
		return
	
	var target_rad: float = deg_to_rad(angle_deg)
	var skirt_rad: float = target_rad * 0.45
	
	if duration <= 0.0 or style == "snap":
		torso_bone.rotation = target_rad
		if skirt_bone: skirt_bone.rotation = skirt_rad
		return
	
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(torso_bone, "rotation", target_rad, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if skirt_bone:
		tw.tween_property(skirt_bone, "rotation", skirt_rad, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Sudden comedic shock recoil backwards with defensive arms and hair flare
func recoil(intensity: float = 0.5, with_shake: bool = true, duration: float = 0.16) -> void:
	if not torso_bone:
		return
	
	var lean_angle: float = -deg_to_rad(16.0 * intensity)
	var tw: Tween = character.create_tween().set_parallel(true)
	
	# 1. Fast backward torso jerk
	tw.tween_property(torso_bone, "rotation", lean_angle, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if skirt_bone:
		tw.tween_property(skirt_bone, "rotation", lean_angle * 0.45, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 2. Defensive hands pull back towards chest
	if left_upper_arm and left_lower_arm:
		tw.tween_property(left_upper_arm, "rotation", deg_to_rad(24.0 * intensity), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(left_lower_arm, "rotation", deg_to_rad(32.0 * intensity), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if right_upper_arm and right_lower_arm:
		tw.tween_property(right_upper_arm, "rotation", deg_to_rad(-24.0 * intensity), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(right_lower_arm, "rotation", deg_to_rad(-32.0 * intensity), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 3. Hair flings back dynamically
	var hair_flare: float = deg_to_rad(14.0 * intensity)
	if hair_left_bone:
		tw.tween_property(hair_left_bone, "rotation", hair_flare, duration * 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if hair_right_bone:
		tw.tween_property(hair_right_bone, "rotation", hair_flare, duration * 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if hair_back_bone:
		tw.tween_property(hair_back_bone, "rotation", hair_flare * 0.6, duration * 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 4. Camera trauma shake
	if with_shake:
		character.set("_shake_trauma", min(1.0, 0.45 * intensity))
	
	await tw.finished

## Snappy pointing gesture with optional anticipation and overshoot
func point(side: String = "right", speed: Variant = "fast", with_anticipation: bool = false, with_overshoot: bool = true) -> void:
	var is_left: bool = (side.to_lower() == "left")
	var u_arm: Bone2D = left_upper_arm if is_left else right_upper_arm
	var l_arm: Bone2D = left_lower_arm if is_left else right_lower_arm
	var h_vis: Node2D = left_hand_visual if is_left else right_hand_visual
	
	if not u_arm or not l_arm:
		return
	
	var target_u: float = deg_to_rad(75.0 if is_left else -75.0)
	var target_l: float = deg_to_rad(55.0 if is_left else -55.0)
	var duration: float = NemiTiming.get_duration_for_speed(speed, 0.16)
	
	if h_vis:
		h_vis.set("hand_pose", NemiLimbPart.HandPose.POINTING)
	
	if duration <= 0.0:
		u_arm.rotation = target_u
		l_arm.rotation = target_l
		return
	
	if with_anticipation:
		# Slight pre-compression back
		var tw_ant: Tween = character.create_tween().set_parallel(true)
		if torso_bone:
			tw_ant.tween_property(torso_bone, "rotation", deg_to_rad(-3.0), duration * 0.35)
		tw_ant.tween_property(u_arm, "rotation", u_arm.rotation * 0.8, duration * 0.35)
		await tw_ant.finished
	
	if with_overshoot:
		var over_u: float = target_u + deg_to_rad(6.0 if is_left else -6.0)
		var over_l: float = target_l + deg_to_rad(4.0 if is_left else -4.0)
		
		var tw1: Tween = character.create_tween().set_parallel(true)
		tw1.tween_property(u_arm, "rotation", over_u, duration * 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw1.tween_property(l_arm, "rotation", over_l, duration * 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if torso_bone:
			tw1.tween_property(torso_bone, "rotation", 0.0, duration * 0.65)
		await tw1.finished
		
		var tw2: Tween = character.create_tween().set_parallel(true)
		tw2.tween_property(u_arm, "rotation", target_u, duration * 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw2.tween_property(l_arm, "rotation", target_l, duration * 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tw2.finished
	else:
		var tw: Tween = character.create_tween().set_parallel(true)
		tw.tween_property(u_arm, "rotation", target_u, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(l_arm, "rotation", target_l, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tw.finished

## Expressive comedic shrug
func shrug(intensity: float = 1.0, duration: float = 0.28) -> void:
	if not left_upper_arm or not right_upper_arm:
		return
	
	if left_hand_visual: left_hand_visual.set("hand_pose", NemiLimbPart.HandPose.OPEN)
	if right_hand_visual: right_hand_visual.set("hand_pose", NemiLimbPart.HandPose.OPEN)
	
	var tw: Tween = character.create_tween().set_parallel(true)
	# Shoulders raised outward and elbows bent
	tw.tween_property(left_upper_arm, "rotation", deg_to_rad(32.0 * intensity), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(left_lower_arm, "rotation", deg_to_rad(45.0 * intensity), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(right_upper_arm, "rotation", deg_to_rad(-32.0 * intensity), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(right_lower_arm, "rotation", deg_to_rad(-45.0 * intensity), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Conversational wave gesture
func wave(side: String = "right", cycles: int = 2) -> void:
	var is_left: bool = (side.to_lower() == "left")
	var u_arm: Bone2D = left_upper_arm if is_left else right_upper_arm
	var l_arm: Bone2D = left_lower_arm if is_left else right_lower_arm
	var h_bone: Bone2D = left_hand_bone if is_left else right_hand_bone
	var h_vis: Node2D = left_hand_visual if is_left else right_hand_visual
	
	if not u_arm or not l_arm:
		return
	
	if h_vis: h_vis.set("hand_pose", NemiLimbPart.HandPose.OPEN)
	
	var raise_u: float = deg_to_rad(85.0 if is_left else -85.0)
	var raise_l: float = deg_to_rad(20.0 if is_left else -20.0)
	
	var tw_raise: Tween = character.create_tween().set_parallel(true)
	tw_raise.tween_property(u_arm, "rotation", raise_u, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_raise.tween_property(l_arm, "rotation", raise_l, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw_raise.finished
	
	if h_bone:
		var wave_amp: float = deg_to_rad(20.0)
		for c in range(cycles):
			var tw1: Tween = character.create_tween()
			tw1.tween_property(h_bone, "rotation", wave_amp, 0.10)
			await tw1.finished
			var tw2: Tween = character.create_tween()
			tw2.tween_property(h_bone, "rotation", -wave_amp, 0.10)
			await tw2.finished
		var tw_h_reset: Tween = character.create_tween()
		tw_h_reset.tween_property(h_bone, "rotation", 0.0, 0.08)
		await tw_h_reset.finished

## Introverted / polite hands brought together in front of body
func hands_together(duration: float = 0.22) -> void:
	if not left_upper_arm or not right_upper_arm:
		return
	
	if left_hand_visual: left_hand_visual.set("hand_pose", NemiLimbPart.HandPose.RELAXED)
	if right_hand_visual: right_hand_visual.set("hand_pose", NemiLimbPart.HandPose.RELAXED)
	
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(left_upper_arm, "rotation", deg_to_rad(18.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(left_lower_arm, "rotation", deg_to_rad(48.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(right_upper_arm, "rotation", deg_to_rad(-18.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(right_lower_arm, "rotation", deg_to_rad(-48.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Casual relaxed hands down
func hands_down(duration: float = 0.18) -> void:
	if not left_upper_arm or not right_upper_arm:
		return
	
	if left_hand_visual: left_hand_visual.set("hand_pose", NemiLimbPart.HandPose.RELAXED)
	if right_hand_visual: right_hand_visual.set("hand_pose", NemiLimbPart.HandPose.RELAXED)
	
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(left_upper_arm, "rotation", deg_to_rad(8.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(left_lower_arm, "rotation", deg_to_rad(12.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(right_upper_arm, "rotation", deg_to_rad(-8.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(right_lower_arm, "rotation", deg_to_rad(-12.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Slouch into introverted / tired posture
func slouch(intensity: float = 1.0, duration: float = 0.25) -> void:
	if not torso_bone:
		return
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(torso_bone, "rotation", deg_to_rad(6.0 * intensity), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if left_upper_arm: tw.tween_property(left_upper_arm, "rotation", deg_to_rad(5.0), duration)
	if right_upper_arm: tw.tween_property(right_upper_arm, "rotation", deg_to_rad(-5.0), duration)
	await tw.finished

## Straighten posture back to baseline
func straighten(duration: float = 0.20) -> void:
	if not torso_bone:
		return
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(torso_bone, "rotation", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if skirt_bone: tw.tween_property(skirt_bone, "rotation", 0.0, duration)
	await tw.finished

## Micro-action: subtle shoulder shift
func shoulder_shift(intensity: float = 0.3, duration: float = 0.15) -> void:
	if not left_upper_arm or not right_upper_arm:
		return
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(left_upper_arm, "rotation", deg_to_rad(12.0 * intensity), duration * 0.5)
	tw.tween_property(right_upper_arm, "rotation", deg_to_rad(-12.0 * intensity), duration * 0.5)
	await tw.finished
	var tw_back: Tween = character.create_tween().set_parallel(true)
	tw_back.tween_property(left_upper_arm, "rotation", deg_to_rad(8.0), duration * 0.5)
	tw_back.tween_property(right_upper_arm, "rotation", deg_to_rad(-8.0), duration * 0.5)
	await tw_back.finished

## Micro-action: subtle posture correction
func posture_correct(duration: float = 0.25) -> void:
	if not torso_bone:
		return
	var orig_rot: float = torso_bone.rotation
	var tw: Tween = character.create_tween()
	tw.tween_property(torso_bone, "rotation", -deg_to_rad(2.5), duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(torso_bone, "rotation", orig_rot, duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await tw.finished

## Resets all body transforms to neutral
func reset(duration: float = 0.0) -> void:
	if not torso_bone:
		return
	if duration <= 0.0:
		torso_bone.rotation = 0.0
		if skirt_bone: skirt_bone.rotation = 0.0
		if left_upper_arm: left_upper_arm.rotation = deg_to_rad(8.0)
		if left_lower_arm: left_lower_arm.rotation = deg_to_rad(12.0)
		if right_upper_arm: right_upper_arm.rotation = deg_to_rad(-8.0)
		if right_lower_arm: right_lower_arm.rotation = deg_to_rad(-12.0)
		if left_hand_bone: left_hand_bone.rotation = 0.0
		if right_hand_bone: right_hand_bone.rotation = 0.0
		if left_hand_visual: left_hand_visual.set("hand_pose", NemiLimbPart.HandPose.RELAXED)
		if right_hand_visual: right_hand_visual.set("hand_pose", NemiLimbPart.HandPose.RELAXED)
		return
	
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(torso_bone, "rotation", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if skirt_bone: tw.tween_property(skirt_bone, "rotation", 0.0, duration)
	if left_upper_arm: tw.tween_property(left_upper_arm, "rotation", deg_to_rad(8.0), duration)
	if left_lower_arm: tw.tween_property(left_lower_arm, "rotation", deg_to_rad(12.0), duration)
	if right_upper_arm: tw.tween_property(right_upper_arm, "rotation", deg_to_rad(-8.0), duration)
	if right_lower_arm: tw.tween_property(right_lower_arm, "rotation", deg_to_rad(-12.0), duration)
	if left_hand_bone: tw.tween_property(left_hand_bone, "rotation", 0.0, duration)
	if right_hand_bone: tw.tween_property(right_hand_bone, "rotation", 0.0, duration)
	await tw.finished
	if left_hand_visual: left_hand_visual.set("hand_pose", NemiLimbPart.HandPose.RELAXED)
	if right_hand_visual: right_hand_visual.set("hand_pose", NemiLimbPart.HandPose.RELAXED)

## Conversational gesture: Hand points or gestures toward oneself
func gesture_self(duration: float = 0.22) -> void:
	if not right_upper_arm or not right_lower_arm:
		return
	if right_hand_visual: right_hand_visual.set("hand_pose", NemiLimbPart.HandPose.OPEN)
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(right_upper_arm, "rotation", deg_to_rad(-24.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(right_lower_arm, "rotation", deg_to_rad(-68.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if right_hand_bone:
		tw.tween_property(right_hand_bone, "rotation", deg_to_rad(-15.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Conversational gesture: Open palm outward presentation
func gesture_open_palm(side: String = "right", duration: float = 0.22) -> void:
	var is_left: bool = (side.to_lower() == "left")
	var u_arm: Bone2D = left_upper_arm if is_left else right_upper_arm
	var l_arm: Bone2D = left_lower_arm if is_left else right_lower_arm
	var h_vis: Node2D = left_hand_visual if is_left else right_hand_visual
	if not u_arm or not l_arm:
		return
	if h_vis: h_vis.set("hand_pose", NemiLimbPart.HandPose.OPEN)
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(u_arm, "rotation", deg_to_rad(38.0 if is_left else -38.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(l_arm, "rotation", deg_to_rad(42.0 if is_left else -42.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Comedic thinking gesture: Hand to chin with slight head tilt
func gesture_thinking(duration: float = 0.24) -> void:
	if not right_upper_arm or not right_lower_arm:
		return
	if right_hand_visual: right_hand_visual.set("hand_pose", NemiLimbPart.HandPose.POINTING)
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(right_upper_arm, "rotation", deg_to_rad(-45.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(right_lower_arm, "rotation", deg_to_rad(-85.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if torso_bone:
		tw.tween_property(torso_bone, "rotation", deg_to_rad(-2.5), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Overconfident chest puff posture (anime hero stance)
func gesture_chest_puff(duration: float = 0.25) -> void:
	if not torso_bone:
		return
	if left_hand_visual: left_hand_visual.set("hand_pose", NemiLimbPart.HandPose.FIST)
	if right_hand_visual: right_hand_visual.set("hand_pose", NemiLimbPart.HandPose.FIST)
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(torso_bone, "rotation", deg_to_rad(-4.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if skirt_bone:
		tw.tween_property(skirt_bone, "rotation", deg_to_rad(-2.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if left_upper_arm: tw.tween_property(left_upper_arm, "rotation", deg_to_rad(-12.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if right_upper_arm: tw.tween_property(right_upper_arm, "rotation", deg_to_rad(12.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if left_lower_arm: tw.tween_property(left_lower_arm, "rotation", deg_to_rad(30.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if right_lower_arm: tw.tween_property(right_lower_arm, "rotation", deg_to_rad(-30.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Sudden comedic posture collapse / failure drop
func gesture_collapse(intensity: float = 1.0, duration: float = 0.25) -> void:
	if not torso_bone:
		return
	if left_hand_visual: left_hand_visual.set("hand_pose", NemiLimbPart.HandPose.RELAXED)
	if right_hand_visual: right_hand_visual.set("hand_pose", NemiLimbPart.HandPose.RELAXED)
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(torso_bone, "rotation", deg_to_rad(8.5 * intensity), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if skirt_bone:
		tw.tween_property(skirt_bone, "rotation", deg_to_rad(4.0 * intensity), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if left_upper_arm: tw.tween_property(left_upper_arm, "rotation", deg_to_rad(18.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if right_upper_arm: tw.tween_property(right_upper_arm, "rotation", deg_to_rad(-18.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if left_lower_arm: tw.tween_property(left_lower_arm, "rotation", deg_to_rad(24.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if right_lower_arm: tw.tween_property(right_lower_arm, "rotation", deg_to_rad(-24.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Sincere / passionate hand on chest / heart gesture
func gesture_hand_on_chest(duration: float = 0.22) -> void:
	if not left_upper_arm or not left_lower_arm:
		return
	if left_hand_visual: left_hand_visual.set("hand_pose", NemiLimbPart.HandPose.RELAXED)
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(left_upper_arm, "rotation", deg_to_rad(25.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(left_lower_arm, "rotation", deg_to_rad(65.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if left_hand_bone:
		tw.tween_property(left_hand_bone, "rotation", deg_to_rad(15.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Comedic tremor vibration (e.g. leg day failure or panic)
func tremble(intensity: float = 0.5, duration: float = 1.0) -> void:
	if not character or not character.get_tree() or duration <= 0.0:
		return
	var frames: int = int(round(duration * 60.0))
	var base_pos: Vector2 = character.position
	var amp: float = 2.5 * intensity
	for f in range(frames):
		var jitter := Vector2(randf_range(-amp, amp), randf_range(-amp * 0.5, amp * 0.5))
		character.position = base_pos + jitter
		await RenderingServer.frame_post_draw
	character.position = base_pos

## Absolute zero-motion freeze hold
func freeze_stillness(duration: float) -> void:
	if not character or not character.get_tree():
		return
	character.set("_shake_trauma", 0.0)
	character.set("_hair_sway_velocity", 0.0)
	character.set("_hair_sway_offset", 0.0)
	var frames: int = int(round(duration * 60.0))
	for f in range(frames):
		await RenderingServer.frame_post_draw

