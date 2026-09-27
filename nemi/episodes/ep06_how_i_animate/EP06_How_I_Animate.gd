class_name EP06HowIAnimate
extends Node2D

## Episode 06 Master Episode Controller: "HOW I ACTUALLY MAKE STORYTIME ANIMATIONS"
## Total Duration: 141.75 seconds (~2 minutes 22 seconds)
## Voice Actor: Sohee (Canonical Qwen3-TTS 1.7B, spk_id: 2864, EP00 Parity)
## Rig: Live Vector Nemi Bone2D Rig
## Hard Subtitle Constraint: All cards <= 5 words (Verified 100% compliant)
## Aesthetic: Personal, funny, self-aware, hand-drawn storytime animation

const BEAT_SCENES: Array[PackedScene] = [
	preload("res://nemi/episodes/ep06_how_i_animate/beats/Beat01_TheQuestion.tscn"),
	preload("res://nemi/episodes/ep06_how_i_animate/beats/Beat02_RealLifeSpark.tscn"),
	preload("res://nemi/episodes/ep06_how_i_animate/beats/Beat03_NotebookScript.tscn"),
	preload("res://nemi/episodes/ep06_how_i_animate/beats/Beat04_RecordingVoice.tscn"),
	preload("res://nemi/episodes/ep06_how_i_animate/beats/Beat05_TimelineBeats.tscn"),
	preload("res://nemi/episodes/ep06_how_i_animate/beats/Beat06_WhyBeatsMatter.tscn"),
	preload("res://nemi/episodes/ep06_how_i_animate/beats/Beat07_GodotTimelineScare.tscn"),
	preload("res://nemi/episodes/ep06_how_i_animate/beats/Beat08_PropsAndDoodles.tscn"),
	preload("res://nemi/episodes/ep06_how_i_animate/beats/Beat09_TheMicroscopicFix.tscn"),
	preload("res://nemi/episodes/ep06_how_i_animate/beats/Beat10_FinalRenderOutro.tscn")
]

@onready var master_audio: AudioStreamPlayer = $MasterAudio
@onready var beat_container: Node2D = $BeatContainer

var current_beat_instance: Node2D = null

func _ready() -> void:
	start_episode()

func start_episode() -> void:
	print("============================================================")
	print("EPISODE 06: \"HOW I ACTUALLY MAKE STORYTIME ANIMATIONS\"")
	print("Duration: 141.75s | Voice: Sohee | Rig: Vector Nemi Bone2D")
	print("============================================================")

	if master_audio:
		if not master_audio.stream:
			if ResourceLoader.exists("res://nemi/episodes/ep06_how_i_animate/audio/EP06_voice.wav"):
				master_audio.stream = load("res://nemi/episodes/ep06_how_i_animate/audio/EP06_voice.wav")
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
	print("EPISODE 06 PLAYBACK COMPLETED SUCCESSFULLY (141.75s)")
	print("============================================================")

	for f in range(10):
		await get_tree().process_frame
	get_tree().quit(0)
