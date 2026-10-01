class_name ADBEP00Intro
extends Node2D

## Episode 00 Master Episode Controller: "HI, I'M ADB."
## Total Duration: 132.41 seconds (~2 minutes 12 seconds)
## Voice Actor: Aiden (Qwen3-TTS 1.7B CustomVoice, 24kHz mono WAV)
## Rig: Live Vector ADB Rig (res://adb/characters/adb/ADB.tscn)
## Format: 1920 × 1080 @ 30 FPS progressive progressive (NO 4K)
## Subtitles: 100% compliant (All 101 cards <= 5 words)
## Doodles: 100% hand-authored pen-and-ink vector DNA
## BGM: Strictly OFF (SFX only)

const BEAT_SCENES: Array[PackedScene] = [
	preload("res://adb/episodes/ep00_intro/beats/Beat01_PushedHook.tscn"),
	preload("res://adb/episodes/ep00_intro/beats/Beat02_IntroConfession.tscn"),
	preload("res://adb/episodes/ep00_intro/beats/Beat03_TableTennis.tscn"),
	preload("res://adb/episodes/ep00_intro/beats/Beat04_SportsGames.tscn"),
	preload("res://adb/episodes/ep00_intro/beats/Beat05_AnimeMountain.tscn"),
	preload("res://adb/episodes/ep00_intro/beats/Beat06_GymWorkout.tscn"),
	preload("res://adb/episodes/ep00_intro/beats/Beat07_EngineeringJob.tscn"),
	preload("res://adb/episodes/ep00_intro/beats/Beat08_TimelineOverwhelm.tscn"),
	preload("res://adb/episodes/ep00_intro/beats/Beat09_GirlfriendHelp.tscn"),
	preload("res://adb/episodes/ep00_intro/beats/Beat10_OutroShove.tscn")
]

const MASTER_AUDIO_PATH: String = "res://adb/episodes/ep00_intro/audio/ADB_Intro_voice.wav"

@onready var master_audio: AudioStreamPlayer = $MasterAudio
@onready var beat_container: Node2D = $BeatContainer

var current_beat_instance: Node2D = null
var global_time: float = 0.0
var _is_running: bool = false

func _ready() -> void:
	start_episode()

func _process(delta: float) -> void:
	if not _is_running:
		return

	global_time += delta

	# Synchronize active subtitles deterministically
	if is_instance_valid(current_beat_instance) and current_beat_instance.has_method("update_subtitles_for_time"):
		current_beat_instance.update_subtitles_for_time(global_time)

const BEAT_STARTS: Array[float] = [
	0.0,    # Beat 1: Pushed Hook (0.00 -> 5.57)
	5.57,   # Beat 2: Intro Confession (5.57 -> 17.84)
	17.84,  # Beat 3: Table Tennis (17.84 -> 37.68)
	37.68,  # Beat 4: Sports & Games (37.68 -> 52.04)
	52.04,  # Beat 5: Anime Mountain (52.04 -> 68.20)
	68.20,  # Beat 6: Gym Workout (68.20 -> 81.18)
	81.18,  # Beat 7: Engineering Job (81.18 -> 89.90)
	89.90,  # Beat 8: Timeline Overwhelm (89.90 -> 105.37)
	105.37, # Beat 9: Girlfriend Help (105.37 -> 117.00)
	117.00  # Beat 10: Outro Shove (117.00 -> 132.41)
]

const BEAT_ENDS: Array[float] = [
	5.57,
	17.84,
	37.68,
	52.04,
	68.20,
	81.18,
	89.90,
	105.37,
	117.00,
	132.41
]

func start_episode() -> void:
	print("============================================================")
	print("ADB EPISODE 00: \"HI, I'M ADB.\"")
	print("Duration: 132.41s | Voice: Aiden | Rig: Vector ADB Rig")
	print("Target: 1920x1080 @ 30 FPS | BGM: OFF")
	print("============================================================")

	if master_audio:
		if not master_audio.stream and ResourceLoader.exists(MASTER_AUDIO_PATH):
			master_audio.stream = load(MASTER_AUDIO_PATH)
		if master_audio.stream:
			master_audio.play(0.0)

	_is_running = true
	global_time = 0.0

	for beat_idx in range(BEAT_SCENES.size()):
		var target_start: float = BEAT_STARTS[beat_idx]
		var target_end: float = BEAT_ENDS[beat_idx]

		# Wait until the audio master clock reaches the scheduled start of this beat
		while global_time < target_start - 0.005:
			await get_tree().process_frame

		var beat_scene: PackedScene = BEAT_SCENES[beat_idx]
		print("[ADB MASTER] Loading Beat %d of %d (global_time=%.2fs, scheduled=%.2fs..%.2fs)..." % [
			beat_idx + 1, BEAT_SCENES.size(), global_time, target_start, target_end
		])

		var beat_instance = beat_scene.instantiate()
		beat_instance.is_standalone = false
		beat_container.add_child(beat_instance)
		current_beat_instance = beat_instance

		# Initialize beat start
		if beat_instance.has_method("start_beat"):
			beat_instance.start_beat()

		# Run until the beat completes or scheduled end time is reached
		while global_time < target_end - 0.005 and is_instance_valid(beat_instance):
			await get_tree().process_frame

		beat_instance.queue_free()
		current_beat_instance = null

	_is_running = false

	print("============================================================")
	print("ADB EPISODE 00 PLAYBACK COMPLETED SUCCESSFULLY (132.41s)")
	print("============================================================")

	for f in range(15):
		await get_tree().process_frame
	get_tree().quit(0)
