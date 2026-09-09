class_name NemiEyeActing
extends RefCounted

## Dedicated Eye Acting & Micro-Gaze Subsystem for NEMI (V2 Temporal Rework)
## Implements snappy eye darts, deliberate blink variations, squinting, and pupil widening.
## Note: Eyes move quickly (fast snappy illustrated timing).

var character: Node2D
var face: Node2D

func _init(p_character: Node2D) -> void:
	character = p_character
	if character:
		face = character.get_node_or_null("Skeleton2D/RootBone/TorsoBone/NeckBone/HeadBone/FaceVisual")

## Look in a discrete named direction or continuous Vector2.
func look(dir: Variant, speed: Variant = "fast") -> void:
	if not face:
		return
	
	var target_vec: Vector2 = Vector2.ZERO
	if dir is Vector2:
		target_vec = dir.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
	elif dir is String:
		match dir.to_lower():
			"left": target_vec = Vector2(-1.0, 0.0)
			"right": target_vec = Vector2(1.0, 0.0)
			"up": target_vec = Vector2(0.0, -0.7)
			"down": target_vec = Vector2(0.0, 0.7)
			"up_left": target_vec = Vector2(-0.75, -0.5)
			"up_right": target_vec = Vector2(0.75, -0.5)
			"down_left": target_vec = Vector2(-0.75, 0.5)
			"down_right": target_vec = Vector2(0.75, 0.5)
			"center", "neutral": target_vec = Vector2.ZERO
			_: target_vec = Vector2.ZERO
	
	var duration: float = NemiTiming.get_duration_for_speed(speed, 0.08)
	if duration <= 0.0:
		face.gaze_direction = target_vec
	else:
		var tw: Tween = character.create_tween()
		tw.tween_property(face, "gaze_direction", target_vec, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tw.finished

## Sharp directional glance (eye dart) that snaps immediately and holds for a brief beat.
func eye_dart(target_dir: Variant, hold_duration: float = 0.15) -> void:
	await look(target_dir, "snap")
	if hold_duration > 0.0 and character and character.get_tree():
		await character.get_tree().create_timer(hold_duration, false).timeout

## Deliberate, non-automatic blinking variations.
func blink(mode: String = "normal") -> void:
	if not face:
		return
	
	var orig_openness: float = face.eye_openness
	
	match mode.to_lower():
		"quick":
			# 0.10s snappy comedic blink
			var tw: Tween = character.create_tween()
			tw.tween_property(face, "eye_openness", 0.0, 0.04).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tw.tween_property(face, "eye_openness", orig_openness, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			await tw.finished
		
		"double":
			# Quick double-blink (processing / surprise / disbelief)
			var tw1: Tween = character.create_tween()
			tw1.tween_property(face, "eye_openness", 0.0, 0.04)
			tw1.tween_property(face, "eye_openness", orig_openness * 0.8, 0.05)
			tw1.tween_property(face, "eye_openness", 0.0, 0.04)
			tw1.tween_property(face, "eye_openness", orig_openness, 0.06)
			await tw1.finished
		
		"delayed", "awkward":
			# 0.28s slow, deliberate unamused / awkward blink
			var tw: Tween = character.create_tween()
			tw.tween_property(face, "eye_openness", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			tw.tween_interval(0.04)
			tw.tween_property(face, "eye_openness", orig_openness, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			await tw.finished
		
		"subtle", "speech":
			# Subtle conversational dip
			var tw: Tween = character.create_tween()
			tw.tween_property(face, "eye_openness", 0.25, 0.06)
			tw.tween_property(face, "eye_openness", orig_openness, 0.08)
			await tw.finished
		
		_: # "normal"
			var tw: Tween = character.create_tween()
			tw.tween_property(face, "eye_openness", 0.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tw.tween_property(face, "eye_openness", orig_openness, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			await tw.finished

## Squint eyes for skepticism, suspicion, or focus
func squint(amount: float = 0.55, duration: float = 0.15) -> void:
	if not face:
		return
	if duration <= 0.0:
		face.eye_openness = amount
	else:
		var tw: Tween = character.create_tween()
		tw.tween_property(face, "eye_openness", amount, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tw.finished

## Widen eyes for shock, surprise, or realization
func widen(amount: float = 1.35, duration: float = 0.12) -> void:
	if not face:
		return
	if duration <= 0.0:
		face.eye_openness = amount
	else:
		var tw: Tween = character.create_tween()
		tw.tween_property(face, "eye_openness", amount, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tw.finished

## Resets gaze and eye openness to neutral defaults
func reset(duration: float = 0.0) -> void:
	if not face:
		return
	if duration <= 0.0:
		face.gaze_direction = Vector2.ZERO
		face.eye_openness = 1.0
	else:
		var tw: Tween = character.create_tween().set_parallel(true)
		tw.tween_property(face, "gaze_direction", Vector2.ZERO, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(face, "eye_openness", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tw.finished
