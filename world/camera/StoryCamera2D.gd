class_name StoryCamera2D
extends Camera2D

## 2D Storytelling Camera for Nemi Animated Productions
## Provides cinematic framing presets, comedic punch-in snaps with overshoot,
## slow push-ins, tracking, and reaction shakes matching the YouTube storytelling reference videos.

enum ShotPreset {
	WIDE,             # Zoom ~1.0x - full scene & room visible
	MEDIUM,           # Zoom ~1.25x - waist up, immediate props visible
	MEDIUM_CLOSEUP,   # Zoom ~1.55x - chest up, gestures & hands
	CLOSEUP,          # Zoom ~1.95x - head & shoulders, emotional acting
	EXTREME_CLOSEUP   # Zoom ~2.5x - tight face/eyes for comedic shock
}

const PRESET_ZOOMS = {
	ShotPreset.WIDE: 1.0,
	ShotPreset.MEDIUM: 1.25,
	ShotPreset.MEDIUM_CLOSEUP: 1.55,
	ShotPreset.CLOSEUP: 1.95,
	ShotPreset.EXTREME_CLOSEUP: 2.5
}

@export var default_preset: ShotPreset = ShotPreset.WIDE
@export var base_viewport_size: Vector2 = Vector2(1280, 720)

var current_preset: ShotPreset = ShotPreset.WIDE
var tracking_target: Node2D = null
var tracking_damping: float = 8.0 # Soft camera tracking speed

var _active_tween: Tween
var _shake_intensity: float = 0.0
var _shake_timer: float = 0.0
var _base_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	make_current()
	# Center camera at canvas origin by default
	position = base_viewport_size * 0.5
	_base_offset = position
	apply_preset(default_preset, 0.0)

func _process(delta: float) -> void:
	# Target tracking
	if is_instance_valid(tracking_target) and not (_active_tween and _active_tween.is_valid()):
		var target_dest: Vector2 = tracking_target.global_position
		position = position.lerp(target_dest, clampf(delta * tracking_damping, 0.0, 1.0))
		_base_offset = position
		
	# Shake effect
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var damp := _shake_timer / maxf(_shake_timer + delta, 0.001)
		var current_amp := _shake_intensity * damp
		offset = Vector2(
			randf_range(-current_amp, current_amp),
			randf_range(-current_amp, current_amp)
		)
		if _shake_timer <= 0.0:
			offset = Vector2.ZERO

# -------------------------------------------------------------------------
# FRAMING PRESETS
# -------------------------------------------------------------------------

## Apply one of the standard framing presets
func apply_preset(preset: ShotPreset, duration: float = 0.35, target_node: Node2D = null) -> Signal:
	current_preset = preset
	var target_zoom: float = PRESET_ZOOMS.get(preset, 1.0)
	var dest_pos: Vector2 = _base_offset
	
	if is_instance_valid(target_node):
		dest_pos = target_node.global_position
		# Offset slightly for head framing on closeups
		if preset == ShotPreset.CLOSEUP or preset == ShotPreset.EXTREME_CLOSEUP:
			dest_pos += Vector2(0, -60.0)
			
	if duration <= 0.001:
		zoom = Vector2(target_zoom, target_zoom)
		position = dest_pos
		return get_tree().process_frame
		
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
		
	_active_tween = create_tween().set_parallel(true)
	_active_tween.tween_property(self, "zoom", Vector2(target_zoom, target_zoom), duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "position", dest_pos, duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return _active_tween.finished

# -------------------------------------------------------------------------
# DYNAMIC CAMERA ACTIONS
# -------------------------------------------------------------------------

## Comedic or dramatic punch-in zoom snap with subtle overshoot
func punch_in(target_pos: Vector2, zoom_mult: float = 1.6, duration: float = 0.16, overshoot: float = 1.1) -> Signal:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
		
	var start_zoom: Vector2 = zoom
	var final_zoom := Vector2(zoom_mult, zoom_mult)
	var overshoot_zoom := final_zoom * overshoot
	
	_active_tween = create_tween()
	# Fast snap inward past target
	var half_dur := duration * 0.65
	_active_tween.parallel().tween_property(self, "zoom", overshoot_zoom, half_dur)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.parallel().tween_property(self, "position", target_pos, half_dur)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
	# Settle back to final target
	var settle_dur := duration * 0.35
	_active_tween.chain().tween_property(self, "zoom", final_zoom, settle_dur)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return _active_tween.finished

## Cinematic slow push-in (adds subtle drama while character talks)
func push_in(zoom_delta: float = 0.15, duration: float = 3.0) -> Signal:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
		
	var target_zoom := zoom + Vector2(zoom_delta, zoom_delta)
	_active_tween = create_tween()
	_active_tween.tween_property(self, "zoom", target_zoom, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return _active_tween.finished

## Reframe camera position smoothly
func reframe(target_pos: Vector2, duration: float = 0.35) -> Signal:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
		
	_active_tween = create_tween()
	_active_tween.tween_property(self, "position", target_pos, duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	return _active_tween.finished

## Start or stop target tracking
func track_target(node: Node2D, damping: float = 8.0) -> void:
	tracking_target = node
	tracking_damping = damping

func stop_tracking() -> void:
	tracking_target = null

## Screen shake for impacts or shock moments
func shake(intensity: float = 12.0, duration: float = 0.22) -> void:
	_shake_intensity = intensity
	_shake_timer = duration

## Reset camera to default wide shot centered in canvas
func reset_camera(duration: float = 0.25) -> Signal:
	stop_tracking()
	return apply_preset(ShotPreset.WIDE, duration, null)

## Instant or rapid punch zoom without requiring full re-target
func punch_zoom(zoom_mult: float, duration: float = 0.08) -> Signal:
	if duration <= 0.001:
		zoom = Vector2(zoom_mult, zoom_mult)
		return get_tree().process_frame
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "zoom", Vector2(zoom_mult, zoom_mult), duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return _active_tween.finished

## Reset zoom back to baseline WIDE preset smoothly
func reset_zoom(duration: float = 0.3) -> Signal:
	return reset_camera(duration)

## Cinematic reaction closeup focusing rapidly on character face/eyes
func reaction_closeup(target_pos: Vector2, zoom_level: float = 1.85, duration: float = 0.22) -> Signal:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween().set_parallel(true)
	_active_tween.tween_property(self, "position", target_pos + Vector2(0, -50.0), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "zoom", Vector2(zoom_level, zoom_level), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return _active_tween.finished

## Subtle punch zoom bump for punchline emphasis without jarring jump
func subtle_punch(zoom_bump: float = 1.10, duration: float = 0.15) -> Signal:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	var base_z := zoom
	var peak_z := zoom * zoom_bump
	_active_tween = create_tween()
	_active_tween.tween_property(self, "zoom", peak_z, duration * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.chain().tween_property(self, "zoom", base_z, duration * 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return _active_tween.finished

## Progressive multi-step face zoom progression (e.g. for "Half." -> "A." -> "Second.")
func face_zoom_progression(target_pos: Vector2, levels: Array, step_duration: float = 0.2) -> Signal:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween()
	for lvl in levels:
		var z_val: float = float(lvl)
		_active_tween.tween_property(self, "zoom", Vector2(z_val, z_val), step_duration * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_active_tween.parallel().tween_property(self, "position", target_pos + Vector2(0, -50.0), step_duration * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_active_tween.tween_interval(step_duration * 0.4)
	return _active_tween.finished

