class_name EP05Celebration
extends Node2D

## Episode 05 Master Episode Controller: "WHAT IS GOING ON WITH YOUTUBE?"
## Duration: 92.45 seconds (1 minute 32.5 seconds)
## Voice Actor: Sohee (EP00 Voice Parity, 10 beats)
## Rig: Live Vector Nemi Bone2D Rig
## Hard Subtitle Constraint: All cards <= 5 words
## Rule 7: Zero gendered self-references

const BEAT_SCENES: Array[PackedScene] = [
	preload("res://nemi/episodes/ep05_celebration/beats/Beat01_AnalyticsFreeze.tscn"),
	preload("res://nemi/episodes/ep05_celebration/beats/Beat02_SevenViewsFlashback.tscn"),
	preload("res://nemi/episodes/ep05_celebration/beats/Beat03_CounterClimb.tscn"),
	preload("res://nemi/episodes/ep05_celebration/beats/Beat04_MilestoneExplosion.tscn"),
	preload("res://nemi/episodes/ep05_celebration/beats/Beat05_HumanBeings.tscn"),
	preload("res://nemi/episodes/ep05_celebration/beats/Beat06_CommentsAvalanche.tscn"),
	preload("res://nemi/episodes/ep05_celebration/beats/Beat07_CommentGratitude.tscn"),
	preload("res://nemi/episodes/ep05_celebration/beats/Beat08_InstagramSurprise.tscn"),
	preload("res://nemi/episodes/ep05_celebration/beats/Beat09_CreatorReality.tscn"),
	preload("res://nemi/episodes/ep05_celebration/beats/Beat10_WarmSignoff.tscn")
]

@onready var master_audio: AudioStreamPlayer = $MasterAudio
@onready var beat_container: Node2D = $BeatContainer

var current_beat_instance: Node2D = null

func _ready() -> void:
	start_episode()

func start_episode() -> void:
	print("============================================================")
	print("EPISODE 05: \"WHAT IS GOING ON WITH YOUTUBE?\" — MASTER PLAYBACK")
	print("Duration: 92.45s | Voice: Sohee (EP00 Parity) | Rig: Vector Nemi")
	print("============================================================")
	
	if master_audio:
		if not master_audio.stream:
			if ResourceLoader.exists("res://nemi/episodes/ep05_celebration/audio/EP05_audio_sfx_master.wav"):
				master_audio.stream = load("res://nemi/episodes/ep05_celebration/audio/EP05_audio_sfx_master.wav")
			elif ResourceLoader.exists("res://nemi/episodes/ep05_celebration/audio/EP05_voice_v2.wav"):
				master_audio.stream = load("res://nemi/episodes/ep05_celebration/audio/EP05_voice_v2.wav")
			elif ResourceLoader.exists("res://nemi/episodes/ep05_celebration/audio/EP05_voice_v2.mp3"):
				master_audio.stream = load("res://nemi/episodes/ep05_celebration/audio/EP05_voice_v2.mp3")
		master_audio.play(0.0)

	for beat_idx in range(BEAT_SCENES.size()):
		var beat_scene: PackedScene = BEAT_SCENES[beat_idx]
		print("[MASTER] Loading Beat %d of %d at frame %d..." % [beat_idx + 1, BEAT_SCENES.size(), Engine.get_process_frames()])
		
		var beat_instance = beat_scene.instantiate()
		beat_instance.is_standalone = false
		beat_container.add_child(beat_instance)
		current_beat_instance = beat_instance
		
		# Start beat choreography
		if beat_instance.has_method("start_beat"):
			beat_instance.start_beat()
			
		# Wait for beat completion signal
		if beat_instance.has_signal("beat_finished"):
			await beat_instance.beat_finished
		else:
			push_warning("Beat %d does not have beat_finished signal!" % [beat_idx + 1])
			
		# Clean up beat instance synchronously without accumulating delay
		beat_instance.queue_free()
		
	print("============================================================")
	print("EPISODE 05 PLAYBACK COMPLETED SUCCESSFULLY (92.45s)")
	print("============================================================")
	
	for f in range(10):
		await get_tree().process_frame
	get_tree().quit(0)
