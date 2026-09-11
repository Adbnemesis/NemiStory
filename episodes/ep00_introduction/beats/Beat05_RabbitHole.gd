extends Node2D
class_name Beat05RabbitHole

## Beat 5: Comedic Escalation & The Rabbit Hole (01:17.72 - 01:44.38 | Duration: 26.66s)
## Visual Direction V3 (Expression FX Upgrade):
## - Research rabbit hole escalation: nervous sweat → confusion marks → realization on blueprint
## - Absurdity builds into snap zoom into eyes + face_zoom_progression
## - "Half." "A." "Second." → deadpan FX + face exaggeration + stepped camera zoom
## - 1.8s deadpan silence with monochrome ink drain, deadpan FX overlay, and single blink
## - Return to color → sad FX on slouch → excitement sparkles on proud nod → relief sigh on eye-roll
## - Visual Density: Active (research) → Peak (deadpan sequence) → Empty (silence) → Calm (recovery)
## - All subtitles strictly <= 5 words via Episode00Subtitles
## - Live illustrative lip-sync active

signal beat_finished()

const Episode00Subtitles = preload("res://episodes/ep00_introduction/Episode00Subtitles.gd")
const NemiDoodleDirectorClass = preload("res://world/doodles/NemiDoodleDirector.gd")
const DoodleInstanceClass = preload("res://world/doodles/DoodleInstance.gd")

@export var is_standalone: bool = false

@onready var world_system: Node2D = $WorldSystem
@onready var camera: StoryCamera2D = $StoryCamera2D
@onready var nemi: Node2D = $Nemi
@onready var bg_rect: ColorRect = $Background
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

var typing_hands_prop: Node2D
var bridge_prop: Node2D
var clock_prop: Node2D
var monochrome_overlay: ColorRect
var doodle_director: Node2D

func _ready() -> void:
	doodle_director = NemiDoodleDirectorClass.new()
	doodle_director.name = "DoodleDirector"
	add_child(doodle_director)
	if subtitle_label:
		subtitle_label.text = ""
	if is_standalone:
		call_deferred("start_beat")

func start_beat() -> void:
	print("--- BEAT 5 V2: RABBIT HOLE STARTED (01:17.72 - 01:44.38) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://animations/ep00_introduction/voiceover/voiceover.wav")
		voice_player.play(77.72)
	
	_run_beat5_choreography()

func _run_beat5_choreography() -> void:
	# -------------------------------------------------------------------------
	# SEGMENT 016 (01:17.72 - 01:27.16, pause 0.35s)
	# "Like last week," / "when I spent" / "six entire hours" /
	# "researching the exact" / "structural tension" / "of Victorian iron bridges..."
	# -------------------------------------------------------------------------
	if bg_rect:
		bg_rect.color = Color(0.96, 0.94, 0.91, 1.0) # Warm cream wash
		
	if not monochrome_overlay:
		monochrome_overlay = ColorRect.new()
		monochrome_overlay.size = Vector2(1280, 720)
		monochrome_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var mat = ShaderMaterial.new()
		var sh = Shader.new()
		sh.code = """
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float amount : hint_range(0.0, 1.0) = 0.0;
void fragment() {
	vec4 c = texture(screen_texture, SCREEN_UV);
	float gray = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(mix(c.rgb, vec3(gray), amount), c.a);
}
"""
		mat.shader = sh
		mat.set_shader_parameter("amount", 0.0)
		monochrome_overlay.material = mat
		monochrome_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		if has_node("UI"):
			$UI.add_child(monochrome_overlay)
			$UI.move_child(monochrome_overlay, 0)
		else:
			add_child(monochrome_overlay)
		
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.WIDE, 0.2)
		
	nemi.position = Vector2(640, 480)
	nemi.set_pose("neutral")
	nemi.set_expression("thinking")
	
	# Nervous sweat as the research obsession builds
	nemi.fx("nervous", "head_right", 2, 8.0) # Persistent anxious sweat drops
	
	# Attach frantic typing hands for the first short burst (1.25s)
	typing_hands_prop = preload("res://episodes/ep00_introduction/props/PropTypingHands.gd").new()
	typing_hands_prop.position = Vector2(0, 45)
	nemi.add_child(typing_hands_prop)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "016", self)
	
	# Short typing burst (1.25s) -> STOP typing, focus on research findings
	await wait_seconds(1.3)
	if is_instance_valid(typing_hands_prop):
		typing_hands_prop.queue_free()
	
	await wait_seconds(1.1)
	# Wall clock pops in on upper right: "six entire hours"
	clock_prop = preload("res://world/props/PropClock.gd").new()
	clock_prop.position = Vector2(980, 160)
	add_child(clock_prop)
	clock_prop.pop_in(0.22)
	if doodle_director:
		doodle_director.label("6 HOURS", Vector2(980, 230), 0.22, DoodleInstanceClass.StylePreset.COMEDIC)

	# Blueprint pop-in: realization FX sparks as Victorian bridge diagram slides in
	bridge_prop = preload("res://episodes/ep00_introduction/props/PropVictorianBridge.gd").new()
	bridge_prop.position = Vector2(340, 220)
	bridge_prop.scale = Vector2(0.85, 0.85)
	add_child(bridge_prop)
	nemi.fx("realization", "head_top", 2, 2.0) # Lightbulb spark as the blueprint appears
	
	# Dimension arrow and technical note on bridge blueprint
	if doodle_director:
		doodle_director.arrow(Vector2(245, 265), Vector2(305, 235), 0.22)
		doodle_director.label("TENSION: 42kN", Vector2(240, 280), 0.22, DoodleInstanceClass.StylePreset.SUBTLE)
	
	# Nemi inspects the blueprint, pointing right and checking formulas
	nemi.point("left", "fast")
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("down_left")
	
	# Escalating confusion marks as research deepens: clutter accumulation!
	await wait_seconds(3.0)
	nemi.fx("confusion", "head_right", 2, 2.5) # Why am I doing this?
	nemi.face_exaggerate("confusion", 2, 2.0) # Asymmetric brow creep
	
	if doodle_director:
		doodle_director.double_arrow(Vector2(260, 310), Vector2(420, 310), 0.24)
		doodle_director.label("SPAN: 120m", Vector2(340, 330), 0.22, DoodleInstanceClass.StylePreset.SUBTLE)
		doodle_director.scribble(Vector2(480, 240), 40.0, 0.25)
		doodle_director.label("WHY?!", Vector2(480, 195), 0.20, DoodleInstanceClass.StylePreset.COMEDIC)
	
	# Subtle camera shake as the rabbit hole clutter intensifies
	if camera and camera.has_method("screen_shake"):
		camera.screen_shake(0.35, 3.5)
		
	await wait_seconds(4.04) # Spoken duration reaches 01:27.16
	
	# 0.35s pause hold
	await wait_seconds(0.35) # Reaches 01:27.51
	
	# -------------------------------------------------------------------------
	# SEGMENT 017 (01:27.51 - 01:32.95, pause 0.35s)
	# "...just to draw" / "one single background" / "that is on screen" / "for half a second."
	# -------------------------------------------------------------------------
	# Bridge & clock fade out and doodles clear
	if is_instance_valid(bridge_prop):
		var tw = create_tween()
		tw.tween_property(bridge_prop, "modulate:a", 0.0, 0.25)
		tw.tween_callback(bridge_prop.queue_free)
	if is_instance_valid(clock_prop):
		var tw_clock = create_tween()
		tw_clock.tween_property(clock_prop, "modulate:a", 0.0, 0.25)
		tw_clock.tween_callback(clock_prop.queue_free)
	if doodle_director:
		doodle_director.clear_all(0.25)
	
	# Eyes narrow, staring straight into camera — attention FX for dramatic stare
	nemi.set_expression("skeptical")
	nemi.fx("attention", "face_center", 2, 4.0) # Focused stare emphasis
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("center")
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "017", self)
	
	await wait_seconds(5.44) # Spoken duration reaches 01:32.95
	
	# -------------------------------------------------------------------------
	# CAMERA SNAP ZOOM (01:32.95 - 01:33.30)
	# 1-frame snap zoom 1.45x into face/eyes
	# -------------------------------------------------------------------------
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(640, 350), 1.45, 0.0)
	
	# Camera subtle punch for the snap zoom impact
	if camera and camera.has_method("shake"):
		camera.shake(6.0, 0.12)
	await wait_seconds(0.35) # Reaches 01:33.30
	
	# -------------------------------------------------------------------------
	# SEGMENT 018 (01:33.30 - 01:35.38)
	# "Half." (0.65s) / "A." (0.65s) / "Second." (0.78s)
	# -------------------------------------------------------------------------
	nemi.set_expression("deadpan")
	# Hard Rule: Restrained deadpan - NO unnecessary FX, NO three-dot ellipsis
	nemi.face_exaggerate("deadpan", 3, 2.0) # Flat compressed features
	
	# Progressive face zoom: each word punches tighter
	if camera and camera.has_method("face_zoom_progression"):
		camera.face_zoom_progression(Vector2(640, 340), [1.55, 1.75, 2.0], 0.65)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "018", self)
	
	# Hand-drawn typography: "HALF." -> "A." -> "SECOND."
	if doodle_director:
		doodle_director.label("HALF.", Vector2(640, 150), 0.18, DoodleInstanceClass.StylePreset.COMEDIC)
	await wait_seconds(0.65)
	if doodle_director:
		doodle_director.label("A.", Vector2(640, 190), 0.16, DoodleInstanceClass.StylePreset.COMEDIC)
	await wait_seconds(0.65)
	if doodle_director:
		doodle_director.label("SECOND.", Vector2(640, 230), 0.20, DoodleInstanceClass.StylePreset.COMEDIC)
	await wait_seconds(0.78)
	
	# CLEAR THE VISUAL FIELD COMPLETELY before the 1.8s deadpan silence!
	if doodle_director:
		doodle_director.clear_all(0.10)
	
	# -------------------------------------------------------------------------
	# 1.8s DEADPAN SILENCE PAUSE (01:35.38 - 01:37.18)
	# Clean silence: clear all FX. Background drains to monochrome ink. Absolute freeze.
	# At 01:36.4, Nemi blinks ONCE.
	# -------------------------------------------------------------------------
	nemi.clear_all_fx(true) # Silence rule: NO unnecessary FX during the long deadpan silence
	if bg_rect:
		var tw_bg = create_tween()
		tw_bg.tween_property(bg_rect, "color", Color(0.92, 0.92, 0.92, 1.0), 0.4)
	if monochrome_overlay and monochrome_overlay.material:
		var tw_mono = create_tween()
		tw_mono.tween_method(func(val: float):
			monochrome_overlay.material.set_shader_parameter("amount", val)
		, 0.0, 1.0, 0.4)
	
	# Clamps all movement to absolute zero
	nemi.freeze_stillness(1.0)
	await wait_seconds(1.0) # Reaches 01:36.38
	
	# Single deadpan blink in the silence
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.blink("normal")
		
	nemi.freeze_stillness(0.8)
	await wait_seconds(0.8) # Reaches 01:37.18
	
	# -------------------------------------------------------------------------
	# SEGMENT 019 (01:37.18 - 01:44.38, pause 0.80s)
	# "...My posture was ruined." / "My tea was ice cold." / "But the bridge" / "was architecturally sound."
	# -------------------------------------------------------------------------
	# Return background and full color to warm wash
	if bg_rect:
		var tw_bg_back = create_tween()
		tw_bg_back.tween_property(bg_rect, "color", Color(0.96, 0.94, 0.91, 1.0), 0.3)
	if monochrome_overlay and monochrome_overlay.material:
		var tw_mono_back = create_tween()
		tw_mono_back.tween_method(func(val: float):
			monochrome_overlay.material.set_shader_parameter("amount", val)
		, 1.0, 0.0, 0.3)
		
	# Posture slouch on "...My posture was ruined. My tea was ice cold."
	nemi.set_expression("frown")
	nemi.fx("sad", "head_left", 2, 3.5) # Melancholy droopy lines
	nemi.collapse(0.8, 0.25)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "019", self)
	
	await wait_seconds(4.1) # Chunks 1 & 2 finish
	
	# "...But the bridge was architecturally sound."
	# Proud chest puff with excitement sparkles!
	nemi.clear_all_fx() # Clear the sad FX first
	nemi.chest_puff(0.25)
	nemi.set_expression("smug")
	nemi.fx("excitement", "head_left", 3, 2.0) # Proud sparkle burst
	nemi.face_exaggerate("excitement", 2, 1.5) # Subtle confident widening
	if nemi.actor and nemi.actor.head and nemi.actor.head.has_method("nod"):
		nemi.actor.head.nod(1.0, 1)
	
	# Camera subtle punch on the punchline
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.06, 0.14)
		
	await wait_seconds(1.8) # Nod finishes
	
	# Weary eye-roll with relief sigh FX
	nemi.clear_all_fx()
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("up_right")
	nemi.set_expression("skeptical")
	nemi.fx("relief", "head_right", 2, 1.5) # Exhausted sigh
	
	await wait_seconds(1.3) # Dialogue finishes at 104.38s
	
	# 0.80s pause hold before Beat 6
	await wait_seconds(0.80) # Reaches 105.18s
	
	nemi.clear_all_fx(true) # Clean up any lingering FX
	print("--- BEAT 5 V3 COMPLETED (01:45.18 / 105.18s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.5)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	if DisplayServer.get_name() == "headless":
		await get_tree().create_timer(duration).timeout
	else:
		var frames: int = int(round(duration * 60.0))
		for i in range(frames):
			await RenderingServer.frame_post_draw
