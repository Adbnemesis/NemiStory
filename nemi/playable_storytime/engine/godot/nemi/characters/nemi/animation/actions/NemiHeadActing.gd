class_name NemiHeadActing
extends RefCounted

## Dedicated Head Acting Subsystem for NEMI (V2 Temporal Rework)
## Implements turns, tilts, nods, head shakes, and deterministic secondary hair response.

var character: Node2D
var neck_bone: Bone2D
var head_bone: Bone2D

var hair_back_bone: Bone2D
var hair_left_bone: Bone2D
var hair_right_bone: Bone2D

func _init(p_character: Node2D) -> void:
	character = p_character
	if character:
		neck_bone = character.get_node_or_null("Skeleton2D/RootBone/TorsoBone/NeckBone")
		if neck_bone:
			head_bone = neck_bone.get_node_or_null("HeadBone")
			if head_bone:
				hair_back_bone = head_bone.get_node_or_null("HairBackBone")
				hair_left_bone = head_bone.get_node_or_null("HairLeftBone")
				hair_right_bone = head_bone.get_node_or_null("HairRightBone")

## Horizontal head turn with natural neck coordination and deterministic secondary hair follow-through.
## Positive = right, Negative = left.
func turn(angle_deg: float, speed: Variant = "normal", with_anticipation: bool = false, with_hair_follow: bool = true) -> void:
	if not head_bone or not neck_bone:
		return
	
	var total_rad: float = deg_to_rad(angle_deg)
	var neck_target: float = total_rad * 0.28
	var head_target: float = total_rad * 0.72
	var duration: float = NemiTiming.get_duration_for_speed(speed, 0.18)
	
	if duration <= 0.0:
		neck_bone.rotation = neck_target
		head_bone.rotation = head_target
		return
	
	if with_anticipation:
		var prep_offset: float = -total_rad * 0.15
		var tw: Tween = character.create_tween().set_parallel(true)
		# Prep windup
		tw.tween_property(neck_bone, "rotation", neck_bone.rotation + prep_offset * 0.28, duration * 0.3)
		tw.tween_property(head_bone, "rotation", head_bone.rotation + prep_offset * 0.72, duration * 0.3)
		await tw.finished
		
		var tw2: Tween = character.create_tween().set_parallel(true)
		# Main snap with subtle overshoot
		tw2.tween_property(neck_bone, "rotation", neck_target, duration * 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw2.tween_property(head_bone, "rotation", head_target, duration * 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tw2.finished
	else:
		var tw: Tween = character.create_tween().set_parallel(true)
		tw.tween_property(neck_bone, "rotation", neck_target, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(head_bone, "rotation", head_target, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		# Deterministic secondary hair lag & follow-through
		if with_hair_follow and (hair_left_bone or hair_right_bone):
			var hair_lag: float = -total_rad * 0.16
			# Hair drags behind slightly
			if hair_left_bone:
				tw.tween_property(hair_left_bone, "rotation", hair_lag, duration * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tw.tween_property(hair_left_bone, "rotation", 0.0, duration * 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(duration * 0.55)
			if hair_right_bone:
				tw.tween_property(hair_right_bone, "rotation", hair_lag, duration * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tw.tween_property(hair_right_bone, "rotation", 0.0, duration * 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(duration * 0.55)
		
		await tw.finished

## Subtle head tilt left or right (e.g. 3°–6° for confusion, deadpan, inquisitiveness).
func tilt(angle_deg: float, duration: float = 0.18) -> void:
	if not head_bone:
		return
	var target_rad: float = deg_to_rad(angle_deg)
	if duration <= 0.0:
		head_bone.rotation = target_rad
		return
	
	var tw: Tween = character.create_tween()
	tw.tween_property(head_bone, "rotation", target_rad, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Affirmative nod (pitch down and snap back)
func nod(intensity: float = 1.0, count: int = 1) -> void:
	if not head_bone:
		return
	
	var pitch_angle: float = deg_to_rad(9.0 * intensity)
	var orig_rot: float = head_bone.rotation
	
	for i in range(count):
		var tw_down: Tween = character.create_tween()
		tw_down.tween_property(head_bone, "rotation", orig_rot + pitch_angle, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tw_down.finished
		
		var tw_up: Tween = character.create_tween()
		tw_up.tween_property(head_bone, "rotation", orig_rot, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tw_up.finished

## Disapproval / disbelief head shake
func shake_head(intensity: float = 1.0, count: int = 2) -> void:
	if not head_bone:
		return
	
	var sweep_angle: float = deg_to_rad(8.0 * intensity)
	var orig_rot: float = head_bone.rotation
	
	for i in range(count):
		# Shake Left
		var tw_left: Tween = character.create_tween()
		tw_left.tween_property(head_bone, "rotation", orig_rot - sweep_angle, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tw_left.finished
		
		# Shake Right
		var tw_right: Tween = character.create_tween()
		tw_right.tween_property(head_bone, "rotation", orig_rot + sweep_angle, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tw_right.finished
	
	# Settle to center
	var tw_settle: Tween = character.create_tween()
	tw_settle.tween_property(head_bone, "rotation", orig_rot, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw_settle.finished

## Resets head and neck rotations to zero
func reset(duration: float = 0.0) -> void:
	if not head_bone or not neck_bone:
		return
	if duration <= 0.0:
		neck_bone.rotation = 0.0
		head_bone.rotation = 0.0
		if hair_left_bone: hair_left_bone.rotation = 0.0
		if hair_right_bone: hair_right_bone.rotation = 0.0
		if hair_back_bone: hair_back_bone.rotation = 0.0
		return
	var tw: Tween = character.create_tween().set_parallel(true)
	tw.tween_property(neck_bone, "rotation", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(head_bone, "rotation", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if hair_left_bone: tw.tween_property(hair_left_bone, "rotation", 0.0, duration)
	if hair_right_bone: tw.tween_property(hair_right_bone, "rotation", 0.0, duration)
	if hair_back_bone: tw.tween_property(hair_back_bone, "rotation", 0.0, duration)
	await tw.finished
