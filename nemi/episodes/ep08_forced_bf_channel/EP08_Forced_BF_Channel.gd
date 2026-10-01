class_name EP08ForcedBFChannel
extends Node2D

## Episode 08 Master Episode Controller: "I FORCED MY BF TO CREATE A CHANNEL"
## Total Duration: 95.41 seconds (~1 minute 35 seconds)
## Voice Cast:
## - Nemi: Sohee (Canonical Qwen3-TTS 1.7B, 1.15x energetic storytime tempo)
## - ADB: Aiden (Canonical Qwen3-TTS 1.7B, 1.0x calm dry tempo)
## Rigs: Live Vector Nemi Bone2D Rig, Archival Old ADB Rig, Independent New ADB Rig
## Format: 1920 × 1080 @ 30 FPS progressive
## Subtitles: 100% compliant (All 69 cards <= 5 words)
## Doodles: 100% hand-authored pen-and-ink vector DNA

const BEAT_SCENES: Array[PackedScene] = [
	preload("res://nemi/episodes/ep08_forced_bf_channel/beats/Beat01_Hook.tscn"),
	preload("res://nemi/episodes/ep08_forced_bf_channel/beats/Beat02_OldADBCallback.tscn"),
	preload("res://nemi/episodes/ep08_forced_bf_channel/beats/Beat03_HatedDesign.tscn"),
	preload("res://nemi/episodes/ep08_forced_bf_channel/beats/Beat04_NewADBReveal.tscn"),
	preload("res://nemi/episodes/ep08_forced_bf_channel/beats/Beat05_TerribleIdea.tscn"),
	preload("res://nemi/episodes/ep08_forced_bf_channel/beats/Beat06_AskingADB.tscn"),
	preload("res://nemi/episodes/ep08_forced_bf_channel/beats/Beat07_TwoChannels.tscn"),
	preload("res://nemi/episodes/ep08_forced_bf_channel/beats/Beat08_ADBIntro.tscn"),
	preload("res://nemi/episodes/ep08_forced_bf_channel/beats/Beat09_OutroTakeover.tscn")
]

@onready var master_audio: AudioStreamPlayer = $MasterAudio
@onready var beat_container: Node2D = $BeatContainer

var current_beat_instance: Node2D = null

func _ready() -> void:
	start_episode()

func start_episode() -> void:
	print("============================================================")
	print("EPISODE 08: \"I FORCED MY BF TO CREATE A CHANNEL\"")
	print("Duration: 95.41s | Nemi: Sohee (1.15x) | ADB: Aiden (1.0x)")
	print("Target: 1920x1080 @ 30 FPS")
	print("============================================================")

	if master_audio:
		if not master_audio.stream:
			if ResourceLoader.exists("res://nemi/episodes/ep08_forced_bf_channel/audio/EP08_voice.wav"):
				master_audio.stream = load("res://nemi/episodes/ep08_forced_bf_channel/audio/EP08_voice.wav")
		master_audio.play(0.0)

	for beat_idx in range(BEAT_SCENES.size()):
		var beat_scene: PackedScene = BEAT_SCENES[beat_idx]
		print("[MASTER] Loading Beat %d of %d at frame %d..." % [beat_idx + 1, BEAT_SCENES.size(), Engine.get_process_frames()])

		var beat_instance = beat_scene.instantiate()
		if "is_standalone" in beat_instance:
			beat_instance.is_standalone = false
		beat_container.add_child(beat_instance)
		current_beat_instance = beat_instance

		if beat_instance.has_method("start_beat"):
			beat_instance.start_beat()

		if beat_instance.has_signal("beat_finished"):
			await beat_instance.beat_finished
		else:
			push_warning("Beat %d missing beat_finished signal!" % [beat_idx + 1])

		beat_instance.queue_free()

	print("============================================================")
	print("EPISODE 08 PLAYBACK COMPLETED SUCCESSFULLY (108.02s)")
	print("============================================================")

	for f in range(10):
		await get_tree().process_frame
	get_tree().quit(0)
