extends Node2D
class_name Beat02Identity

## Beat 2: Identity & Premise (00:14.70 – 00:31.19 | 16.84s total with pause)
## Dialogue Segments 005 - 008
## Visual Direction Overhaul V2:
## - Warm medium-close framing (1.25x)
## - "Hi. I'm Nemi. I'm 24." -> warm smile, self-gesture (hand to chest)
## - "And apparently..." -> expression shift, sheepish shrug, *YEAR 1 ON YOUTUBE* badge pops
## - "terrible idea" -> playful chin tap thinking gesture, eyes dart upward
## - "How hard could that possibly be?" -> proud chest puff, smug smile, sparkle highlight
## - *FAMOUS LAST WORDS* comic punchline badge drops in with squash & stretch
## - All subtitles strictly <= 5 words via Episode00Subtitles
## - Live illustrative lip-sync active

signal beat_finished()

const Episode00Subtitles = preload("res://episodes/ep00_introduction/Episode00Subtitles.gd")
const NemiDoodleDirectorClass = preload("res://world/doodles/NemiDoodleDirector.gd")
const DoodleInstanceClass = preload("res://world/doodles/DoodleInstance.gd")

@export var is_standalone: bool = false

@onready var nemi = $Nemi
@onready var camera = $StoryCamera2D
@onready var world = $WorldSystem
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

var year1_badge: Node2D
var famous_last_words_badge: Node2D
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
	print("--- BEAT 2 V2: IDENTITY & PREMISE STARTED (00:14.70 - 00:31.54) ---")
	
	if is_standalone and voice_player and not OS.has_feature("movie"):
		if not voice_player.stream:
			voice_player.stream = load("res://animations/ep00_introduction/voiceover/voiceover.wav")
		voice_player.play(14.70)
	
	_run_beat2_choreography()

func _run_beat2_choreography() -> void:
	# -------------------------------------------------------------------------
	# INITIAL CAMERA & STAGING RESET (WARM MEDIUM CLOSE-UP)
	# -------------------------------------------------------------------------
	if camera and camera.has_method("punch_in"):
		camera.punch_in(Vector2(640, 370), 1.25, 0.3)
	
	# -------------------------------------------------------------------------
	# SEGMENT 005 (00:14.70 - 00:16.70, pause 0.35s)
	# "Hi. I'm Nemi." (1.05s) / "I'm 24." (0.95s)
	# -------------------------------------------------------------------------
	nemi.set_expression("smile")
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.tilt(8.0, 0.25)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("center")
	
	# Small natural gesture to self
	nemi.gesture_self(0.3)
	
	# Hand-drawn "24" doodle annotation on "I'm 24."
	if doodle_director:
		doodle_director.label("24", Vector2(745, 420), 0.20, DoodleInstanceClass.StylePreset.COMEDIC)
		doodle_director.circle(Vector2(745, 420), 24.0, 0.22)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "005", self)
	
	await wait_seconds(2.35) # 2.00s dialogue + 0.35s pause = 2.35s (Reaches 17.05s)
	
	if doodle_director:
		doodle_director.clear_all(0.20)
	
	# -------------------------------------------------------------------------
	# SEGMENT 006 (00:17.05 - 00:21.77, pause 0.35s)
	# "And apparently..." (1.40s) / "I am making" (1.32s) / "animated YouTube videos now." (2.00s)
	# -------------------------------------------------------------------------
	# Eyebrow arch + tiny pause on "And apparently..."
	nemi.set_expression("smirk")
	if nemi.actor and nemi.actor.face:
		nemi.actor.face.set_eyebrows("right", 7.0, 0.18, 0.25)
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.tilt(-5.0, 0.25)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "006", self)
	
	# Wait for "And apparently..." (1.40s)
	await wait_seconds(1.40)
	
	# Shrug + "*YEAR 1 ON YOUTUBE*" badge pops on "I am making animated YouTube videos now."
	nemi.shrug(0.7)
	year1_badge = _create_badge("*YEAR 1 ON YOUTUBE*", Vector2(640, 240), Color("#d4883b"))
	add_child(year1_badge)
	
	await wait_seconds(3.67) # Remainder reaches 22.12s
	
	# -------------------------------------------------------------------------
	# SEGMENT 007 (00:22.12 - 00:28.92, pause 0.35s)
	# "I've spent years" (1.3s) / "watching storytime creators" (1.4s) /
	# "talk about their lives," (1.4s) / "and recently my brain" (1.3s) /
	# "had a terrible idea:" (1.4s)
	# -------------------------------------------------------------------------
	if is_instance_valid(year1_badge):
		var tw_b := create_tween()
		tw_b.tween_property(year1_badge, "modulate:a", 0.0, 0.25)
		tw_b.finished.connect(year1_badge.queue_free)
	
	# Playful thinking gesture: hand taps chin, eyes look upward in thought
	nemi.gesture_thinking(0.3)
	nemi.set_expression("neutral")
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("up_right")
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "007", self)
	
	await wait_seconds(4.1) # Chunks 1-3 finish
	
	# "and recently my brain had a terrible idea:" -> Camera subtly punches closer, eyes snap center with knowing deadpan reaction
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.10, 0.2)
	if nemi.actor and nemi.actor.eyes:
		nemi.actor.eyes.look("center")
	nemi.set_expression("deadpan")
	nemi.fx("realization", "head_top", 2, 1.4)
	
	if doodle_director:
		doodle_director.mini("brain", Vector2(640, 260), 32.0, 0.24)
		doodle_director.label("BAD IDEA", Vector2(640, 210), 0.20, DoodleInstanceClass.StylePreset.COMEDIC)
		doodle_director.cross(Vector2(640, 260), 32.0, 0.18)
	
	await wait_seconds(3.05) # Remainder reaches 29.27s
	
	# -------------------------------------------------------------------------
	# SEGMENT 008 (00:29.27 - 00:31.19, pause 0.35s)
	# "How hard" (0.85s) / "could that possibly be?" (1.07s)
	# -------------------------------------------------------------------------
	# Puffs chest out, confident smug smile, subtle camera punch, radiant calligraphic sparkle stars
	nemi.chest_puff(0.25)
	nemi.set_expression("smug")
	nemi.face_exaggerate("excitement", 2, 0.7)
	nemi.fx("excitement", "head_left", 3, 1.4)
	
	Episode00Subtitles.play_segment(subtitle_label, nemi, "008", self)
	
	await wait_seconds(1.2) # Sparkle and smug pause before punchline drops
	
	# Hand-drawn bold comic punchline stamp: "*FAMOUS LAST WORDS*" slams down with squash & stretch
	famous_last_words_badge = _create_badge("*FAMOUS LAST WORDS*", Vector2(640, 230), Color("#992030"), true)
	add_child(famous_last_words_badge)
	if camera and camera.has_method("shake"):
		camera.shake(6.0, 0.18)
	nemi.fx("shock", "head_top", 3, 1.0)
	nemi.face_exaggerate("shock", 3, 0.6)
	
	await wait_seconds(0.72) # Reaches 31.19s
	
	# Stillness hold for 0.35s pause
	nemi.freeze_stillness(0.35)
	await wait_seconds(0.35) # Reaches 31.54s
	
	# Clean up doodles before next beat
	if doodle_director:
		doodle_director.clear_all(0.25)
	
	print("--- BEAT 2 V3 COMPLETED (31.54s) ---")
	beat_finished.emit()
	
	if is_standalone:
		await wait_seconds(0.5)
		get_tree().quit(0)

# --- Helper Methods ---

func _create_badge(text_content: String, pos: Vector2, accent_color: Color, is_bold: bool = false) -> Node2D:
	var badge := Node2D.new()
	badge.position = pos
	badge.scale = Vector2(0.2, 0.2)
	badge.modulate.a = 0.0
	
	var label := Label.new()
	label.text = text_content
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22 if is_bold else 18)
	label.add_theme_color_override("font_color", Color("#ffffff"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	label.add_theme_constant_override("shadow_offset_y", 2)
	
	var panel := PanelContainer.new()
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = accent_color
	style_box.border_width_bottom = 3
	style_box.border_width_top = 2
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_color = Color("#2b111e")
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	style_box.content_margin_left = 18.0
	style_box.content_margin_right = 18.0
	style_box.content_margin_top = 8.0
	style_box.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", style_box)
	
	panel.add_child(label)
	badge.add_child(panel)
	
	# Center panel on origin
	panel.position = Vector2(-120, -20)
	
	# Pop in tween
	var tw := badge.create_tween().set_parallel(true)
	tw.tween_property(badge, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(badge, "modulate:a", 1.0, 0.15)
	
	return badge

func wait_seconds(duration: float) -> void:
	if DisplayServer.get_name() == "headless":
		await get_tree().create_timer(duration).timeout
	else:
		var frames: int = int(round(duration * 60.0))
		for i in range(frames):
			await RenderingServer.frame_post_draw


