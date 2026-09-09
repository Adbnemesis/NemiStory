class_name StoryCamera
extends Camera2D

## Narrative Framing Camera for Storytime Animatic
## Handles instant punch-ins, creeping push-ins, framing pans, and deterministic screenshake.

enum Framing {
	WIDE,
	MEDIUM,
	CLOSEUP,
	EXTREME_CLOSEUP
}

const FRAMING_ZOOMS = {
	Framing.WIDE: Vector2(0.85, 0.85),
	Framing.MEDIUM: Vector2(1.0, 1.0),
	Framing.CLOSEUP: Vector2(1.3, 1.3),
	Framing.EXTREME_CLOSEUP: Vector2(1.7, 1.7)
}

var base_camera_pos: Vector2 = Vector2.ZERO
var base_zoom: Vector2 = Vector2.ONE

var shake_trauma: float = 0.0
var shake_decay: float = 3.5
var shake_elapsed: float = 0.0
var shake_max_offset: float = 14.0

var active_tween: Tween = null

func _ready() -> void:
	base_camera_pos = position
	base_zoom = zoom

func _process(delta: float) -> void:
	# Screenshake with non-linear trauma decay
	if shake_trauma > 0.0:
		shake_elapsed += delta
		var offset: Vector2 = HandDrawnMath.shake_offset(shake_elapsed, shake_trauma, shake_max_offset, 40.0, 77)
		offset_position(offset)
		shake_trauma = maxf(0.0, shake_trauma - shake_decay * delta)
	else:
		offset_position(Vector2.ZERO)

func offset_position(p_offset: Vector2) -> void:
	position = base_camera_pos + p_offset

## Instant comedic punch-in zoom (0-frame snap)
func punch_in(zoom_multiplier: float = 1.25, snap: bool = true, target_pos: Vector2 = Vector2.INF) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	var target_zoom: Vector2 = base_zoom * zoom_multiplier
	var new_pos: Vector2 = base_camera_pos if target_pos == Vector2.INF else target_pos

	if snap:
		zoom = target_zoom
		base_camera_pos = new_pos
		position = new_pos
	else:
		active_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		active_tween.tween_property(self, "zoom", target_zoom, 0.12)
		active_tween.parallel().tween_property(self, "base_camera_pos", new_pos, 0.12)

## Creeping slow push-in during storytelling
func slow_push(zoom_multiplier: float = 1.15, duration: float = 3.0) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	var target_zoom: Vector2 = base_zoom * zoom_multiplier
	active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(self, "zoom", target_zoom, duration)

## Pan framing to another subject or prop
func pan_to(target_pos: Vector2, duration: float = 0.5, snap: bool = false) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	if snap:
		base_camera_pos = target_pos
		position = target_pos
	else:
		active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		active_tween.tween_property(self, "base_camera_pos", target_pos, duration)

## Trigger screenshake on comedic realization or punchline impact
func shake(trauma: float = 0.8, decay: float = 3.5, max_offset: float = 14.0) -> void:
	shake_trauma = clampf(trauma, 0.0, 1.0)
	shake_decay = decay
	shake_max_offset = max_offset
	shake_elapsed = 0.0

## Reset to default framing
func reset_framing(duration: float = 0.0) -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	if duration <= 0.0:
		zoom = Vector2.ONE
		base_zoom = Vector2.ONE
		base_camera_pos = Vector2(640, 360)
		position = base_camera_pos
	else:
		active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		active_tween.tween_property(self, "zoom", Vector2.ONE, duration)
		active_tween.parallel().tween_property(self, "base_camera_pos", Vector2(640, 360), duration)
