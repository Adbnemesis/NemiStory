class_name NemiFaceActing
extends RefCounted

## Dedicated Facial Acting & Expression Transition Subsystem for NEMI (V2 Temporal Rework)
## Implements expression transitions (snap, normal, delayed, escalation) and micro-accents.

var character: Node2D
var face: Node2D

func _init(p_character: Node2D) -> void:
	character = p_character
	if character:
		face = character.get_node_or_null("Skeleton2D/RootBone/TorsoBone/NeckBone/HeadBone/FaceVisual")

## Sets facial expression with configurable transition style.
## Transition styles:
## - "snap": 0-frame instantaneous cut (storytime animatics)
## - "normal": Standard subtle transition
## - "delay": Eyes transition first, then mouth updates 0.12s later
func set_expression(expr_name: String, transition: String = "normal") -> void:
	if not face:
		return
	
	match transition.to_lower():
		"snap", "instant":
			face.set_expression_by_name(expr_name)
		
		"delay":
			# Save original mouth shape
			var orig_mouth: String = face.mouth_shape
			# Apply expression (updates eyes and brows)
			face.set_expression_by_name(expr_name)
			var target_mouth: String = face.mouth_shape
			# Temporarily hold old mouth shape
			face.mouth_shape = orig_mouth
			if character and character.get_tree():
				await character.get_tree().create_timer(0.12, false).timeout
			# Snap mouth to target
			face.mouth_shape = target_mouth
		
		_: # "normal"
			face.set_expression_by_name(expr_name)

## Comedic expression escalation through discrete stages
## Example: neutral -> slight confusion -> realization -> full shock
func escalate_expression(stages: Array[String], delays: Array[float]) -> void:
	for i in range(stages.size()):
		set_expression(stages[i], "snap")
		if i < delays.size() and delays[i] > 0.0 and character and character.get_tree():
			await character.get_tree().create_timer(delays[i], false).timeout

## Sets procedural eyebrow offsets and tilts
func set_eyebrows(side: String, raise_px: float, tilt_rad: float, duration: float = 0.15) -> void:
	if not face:
		return
	
	var is_left: bool = (side == "left" or side == "both")
	var is_right: bool = (side == "right" or side == "both")
	
	if duration <= 0.0:
		if is_left:
			face.left_brow_offset = Vector2(0, -raise_px)
			face.left_brow_tilt = tilt_rad
		if is_right:
			face.right_brow_offset = Vector2(0, -raise_px)
			face.right_brow_tilt = tilt_rad
		return
	
	var tw: Tween = character.create_tween().set_parallel(true)
	if is_left:
		tw.tween_property(face, "left_brow_offset", Vector2(0, -raise_px), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(face, "left_brow_tilt", tilt_rad, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if is_right:
		tw.tween_property(face, "right_brow_offset", Vector2(0, -raise_px), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(face, "right_brow_tilt", tilt_rad, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

## Sets procedural mouth shape ("neutral", "smile", "smile_wide", "open_excited", "open_shocked", "surprised", "smirk", "wavy", "frown", "pout")
func set_mouth(shape_name: String) -> void:
	if face:
		face.mouth_shape = shape_name

## Toggles comic micro-accents: "blush", "sweat", "sparkles", "question", "shock_lines"
func set_accent(accent_name: String, active: bool) -> void:
	if face:
		face.set_micro_accent(accent_name, active)

## Clears all micro-accents
func clear_accents() -> void:
	if face:
		face.set_micro_accent("blush", false)
		face.set_micro_accent("sweat", false)
		face.set_micro_accent("sparkles", false)
		face.set_micro_accent("question", false)
		face.set_micro_accent("shock_lines", false)

## Resets face to neutral defaults
func reset(duration: float = 0.0) -> void:
	if not face:
		return
	clear_accents()
	set_expression("neutral", "snap")
	set_eyebrows("both", 0.0, 0.0, duration)
