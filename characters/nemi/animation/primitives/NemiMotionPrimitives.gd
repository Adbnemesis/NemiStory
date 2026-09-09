class_name NemiMotionPrimitives
extends RefCounted

## Low-Level Reusable Motion Primitives for NEMI (V2 Temporal Rework)
## Implements holds, absolute freeze, snaps, anticipation, overshoot, settle,
## stepped motion, and multi-track staggered timelines.

## Holds the character completely still for a specific duration.
## Stillness is first-class: ensures 0 unwanted movement during the hold.
static func hold(tree: SceneTree, duration: float) -> void:
	if duration <= 0.0 or not tree:
		return
	await tree.create_timer(duration, false).timeout

## Freezes character in place immediately, killing all running tweens and momentum.
## Guarantees 0 residual velocity, hair sway, or trauma shake.
## If duration > 0, additionally holds in this frozen state for that duration.
static func freeze(character: Node2D, duration: float = -1.0) -> void:
	if not character:
		return
	if character.get("_active_tween") and character._active_tween.is_valid():
		character._active_tween.kill()
	
	# Zero out any secondary hair sway or trauma shake
	character.set("_shake_trauma", 0.0)
	character.set("_hair_sway_velocity", 0.0)
	character.set("_hair_sway_offset", 0.0)
	
	if duration > 0.0 and character.get_tree():
		await character.get_tree().create_timer(duration, false).timeout

## 0-frame instantaneous rotation snap
static func snap_bone(bone: Bone2D, target_angle: float) -> void:
	if bone:
		bone.rotation = target_angle

## Smooth single-bone tween with standard storytime quadratic ease-out
static func tween_bone(character: Node2D, bone: Bone2D, target_angle: float, duration: float, trans: Tween.TransitionType = Tween.TRANS_QUAD, ease_type: Tween.EaseType = Tween.EASE_OUT) -> Signal:
	if not bone or not character:
		return Signal()
	if duration <= 0.0:
		bone.rotation = target_angle
		return character.tree_exiting
	
	var tw: Tween = character.create_tween()
	tw.tween_property(bone, "rotation", target_angle, duration).set_trans(trans).set_ease(ease_type)
	return tw.finished

## Anticipation: subtle backward pre-rotation before snapping to target angle
static func anticipate_and_move(character: Node2D, bone: Bone2D, target_angle: float, prep_offset_rad: float, duration: float, prep_ratio: float = 0.3) -> Signal:
	if not bone or not character:
		return Signal()
	if duration <= 0.0:
		bone.rotation = target_angle
		return character.tree_exiting
	
	var prep_dur: float = duration * prep_ratio
	var main_dur: float = duration * (1.0 - prep_ratio)
	var prep_angle: float = bone.rotation + prep_offset_rad
	
	var tw: Tween = character.create_tween()
	# Prep windup (slow ease in)
	tw.tween_property(bone, "rotation", prep_angle, prep_dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# Fast main action (sharp ease out)
	tw.tween_property(bone, "rotation", target_angle, main_dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return tw.finished

## Overshoot and settle: reaches slightly beyond target, then smoothly settles back
static func overshoot_and_settle(character: Node2D, bone: Bone2D, target_angle: float, overshoot_rad: float, duration: float, settle_ratio: float = 0.35) -> Signal:
	if not bone or not character:
		return Signal()
	if duration <= 0.0:
		bone.rotation = target_angle
		return character.tree_exiting
	
	var reach_dur: float = duration * (1.0 - settle_ratio)
	var settle_dur: float = duration * settle_ratio
	var over_angle: float = target_angle + overshoot_rad
	
	var tw: Tween = character.create_tween()
	# Fast reach past target
	tw.tween_property(bone, "rotation", over_angle, reach_dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Gentle settle to target
	tw.tween_property(bone, "rotation", target_angle, settle_dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tw.finished

## Stepped rotation: animates in discrete pose jumps (e.g. on 2s or 3s)
static func stepped_rotate(character: Node2D, bone: Bone2D, target_angle: float, steps: int, duration: float) -> Signal:
	if not bone or not character:
		return Signal()
	if duration <= 0.0 or steps <= 1:
		bone.rotation = target_angle
		return character.tree_exiting
	
	var start_angle: float = bone.rotation
	var tw: Tween = character.create_tween()
	var step_time: float = duration / float(steps)
	
	for i in range(1, steps + 1):
		var fraction: float = float(i) / float(steps)
		var step_angle: float = lerp_angle(start_angle, target_angle, fraction)
		tw.tween_interval(step_time)
		tw.tween_callback(func(): bone.rotation = step_angle)
	
	return tw.finished

## Multi-track staggered timeline helper: executes parallel actions with distinct start delays
## Each element in tasks: { "node": Object, "property": String, "target": Variant, "delay": float, "duration": float, "trans": ..., "ease": ... }
static func staggered_timeline(character: Node2D, tasks: Array[Dictionary]) -> Signal:
	if not character or tasks.is_empty():
		return Signal()
	
	var master_tw: Tween = character.create_tween().set_parallel(true)
	for task in tasks:
		var node: Object = task.get("node")
		var prop: String = task.get("property", "rotation")
		var target: Variant = task.get("target")
		var delay: float = task.get("delay", 0.0)
		var dur: float = task.get("duration", 0.15)
		var trans: Tween.TransitionType = task.get("trans", Tween.TRANS_QUAD)
		var ease_t: Tween.EaseType = task.get("ease", Tween.EASE_OUT)
		
		if not node or target == null:
			continue
		
		if delay > 0.0:
			master_tw.tween_property(node, prop, target, dur).set_trans(trans).set_ease(ease_t).set_delay(delay)
		else:
			master_tw.tween_property(node, prop, target, dur).set_trans(trans).set_ease(ease_t)
	
	return master_tw.finished
