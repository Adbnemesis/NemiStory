extends Node2D
class_name AnimationDirectorTemplate

## Reusable Animation Director Blueprint
## Synchronizes audio playback, Nemi acting states, camera choreography, doodles, and subtitles.

@onready var nemi = $Nemi
@onready var camera = $StoryCamera2D
@onready var background = $DynamicBackground
@onready var doodles = $DoodleManager
@onready var props = $Props
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

func _ready() -> void:
	if subtitle_label:
		subtitle_label.text = ""
	
	# Start story after node tree settles
	call_deferred("_start_animation")

func _start_animation() -> void:
	print("--- Animation Started: [ANIMATION_TITLE] ---")
	
	# Start voiceover if audio stream is assigned
	if voice_player and voice_player.stream:
		voice_player.play()
	
	_run_story_beats()

func _run_story_beats() -> void:
	# -------------------------------------------------------------------------
	# BEAT 1: The Hook (0:00 - 0:06)
	# -------------------------------------------------------------------------
	set_subtitle("Wait—before you scroll, look at this.")
	nemi.set_pose("neutral")
	nemi.set_expression("talking")
	await wait_seconds(1.8)
	
	# Snap zoom punchline
	camera.punch_zoom(1.3, 0.1)
	nemi.set_expression("shocked")
	await wait_seconds(2.0)
	
	# -------------------------------------------------------------------------
	# BEAT 2: Context (0:06 - 0:20)
	# -------------------------------------------------------------------------
	camera.reset_zoom(0.4)
	nemi.set_pose("gesturing")
	nemi.set_expression("happy")
	set_subtitle("I thought starting an animation channel was going to be simple.")
	await wait_seconds(3.0)
	
	# -------------------------------------------------------------------------
	# BEAT 3: Deadpan Beat
	# -------------------------------------------------------------------------
	clear_subtitle()
	nemi.set_pose("neutral")
	nemi.set_expression("deadpan")
	# Hold stillness for 1.5s
	await wait_seconds(1.5)
	
	set_subtitle("...It wasn't.")
	await wait_seconds(2.0)
	
	print("--- Animation Finished ---")

# --- Helper Methods ---

func set_subtitle(text: String) -> void:
	if subtitle_label:
		subtitle_label.text = text

func clear_subtitle() -> void:
	if subtitle_label:
		subtitle_label.text = ""

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
