class_name EP07ZeroMarks
extends Node2D

## Episode 07 Master Episode Controller: "I GOT 0 MARKS IN MY EXAM"
## Total Duration: 136.89 seconds (~2 minutes 17 seconds)
## Voice Actor: Sohee (Canonical Qwen3-TTS 1.7B, spk_id: 2864, EP00 Parity)
## Rig: Live Vector Nemi Bone2D Rig
## Format: 1920 × 1080 @ 30 FPS progressive
## Subtitles: 100% compliant (All 94 cards <= 5 words)
## Doodles: 100% hand-authored pen-and-ink vector DNA

const BEAT_SCENES: Array[PackedScene] = [
	preload("res://nemi/episodes/ep07_zero_marks/beats/Beat01_WaitHook.tscn"),
	preload("res://nemi/episodes/ep07_zero_marks/beats/Beat02_OnlineCollege.tscn"),
	preload("res://nemi/episodes/ep07_zero_marks/beats/Beat03_ThirdSemester.tscn"),
	preload("res://nemi/episodes/ep07_zero_marks/beats/Beat04_TerriblePlan.tscn"),
	preload("res://nemi/episodes/ep07_zero_marks/beats/Beat05_TheEmail.tscn"),
	preload("res://nemi/episodes/ep07_zero_marks/beats/Beat06_StudyGrind.tscn"),
	preload("res://nemi/episodes/ep07_zero_marks/beats/Beat07_ExamBlankMind.tscn"),
	preload("res://nemi/episodes/ep07_zero_marks/beats/Beat08_WritingFrenzy.tscn"),
	preload("res://nemi/episodes/ep07_zero_marks/beats/Beat09_ZeroReveal.tscn"),
	preload("res://nemi/episodes/ep07_zero_marks/beats/Beat10_FutureMeStrategy.tscn")
]

@onready var master_audio: AudioStreamPlayer = $MasterAudio
@onready var beat_container: Node2D = $BeatContainer

var current_beat_instance: Node2D = null

func _ready() -> void:
	start_episode()

func start_episode() -> void:
	print("============================================================")
	print("EPISODE 07: \"I GOT 0 MARKS IN MY EXAM\"")
	print("Duration: 136.89s | Voice: Sohee | Rig: Vector Nemi Bone2D")
	print("Target: 1920x1080 @ 30 FPS")
	print("============================================================")

	if master_audio:
		if not master_audio.stream:
			if ResourceLoader.exists("res://nemi/episodes/ep07_zero_marks/audio/EP07_voice.wav"):
				master_audio.stream = load("res://nemi/episodes/ep07_zero_marks/audio/EP07_voice.wav")
		master_audio.play(0.0)

	for beat_idx in range(BEAT_SCENES.size()):
		var beat_scene: PackedScene = BEAT_SCENES[beat_idx]
		print("[MASTER] Loading Beat %d of %d at frame %d..." % [beat_idx + 1, BEAT_SCENES.size(), Engine.get_process_frames()])

		var beat_instance = beat_scene.instantiate()
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
	print("EPISODE 07 PLAYBACK COMPLETED SUCCESSFULLY (136.89s)")
	print("============================================================")

	for f in range(10):
		await get_tree().process_frame
	get_tree().quit(0)
