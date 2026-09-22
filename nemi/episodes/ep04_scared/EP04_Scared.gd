class_name EP04Scared
extends Node2D

## Episode 04 Master Episode Controller: "Guys, I'm Scared."
## Duration: 73.20 seconds (1 minute 13.2 seconds)
## Voice Actor: Sohee (Approved Qwen3-TTS Master Audio, 9 beats)
## Rig: Live Vector Nemi Bone2D Rig
## Hard Subtitle Constraint: All cards <= 5 words
## Rule 7: Zero gendered self-references

const BEAT_SCENES: Array[PackedScene] = [
	preload("res://nemi/episodes/ep04_scared/beats/Beat01_RawConfession.tscn"),
	preload("res://nemi/episodes/ep04_scared/beats/Beat02_NotHorror.tscn"),
	preload("res://nemi/episodes/ep04_scared/beats/Beat03_ObsessingFrames.tscn"),
	preload("res://nemi/episodes/ep04_scared/beats/Beat04_Refresh2AM.tscn"),
	preload("res://nemi/episodes/ep04_scared/beats/Beat05_OverthinkingDoubts.tscn"),
	preload("res://nemi/episodes/ep04_scared/beats/Beat06_ProdigiesAndChaos.tscn"),
	preload("res://nemi/episodes/ep04_scared/beats/Beat07_BecauseICare.tscn"),
	preload("res://nemi/episodes/ep04_scared/beats/Beat08_GroundedDetermination.tscn"),
	preload("res://nemi/episodes/ep04_scared/beats/Beat09_CasualSignoff.tscn")
]

@onready var master_audio: AudioStreamPlayer = $MasterAudio
@onready var beat_container: Node2D = $BeatContainer

var current_beat_instance: Node2D = null

func _ready() -> void:
	call_deferred("start_episode")

func start_episode() -> void:
	print("============================================================")
	print("EPISODE 04: \"GUYS, I'M SCARED.\" — MASTER PRODUCTION PLAYBACK")
	print("Duration: 73.20s | Voice: Sohee | Rig: Vector Nemi")
	print("============================================================")
	
	if master_audio:
		if not master_audio.stream:
			if ResourceLoader.exists("res://nemi/episodes/ep04_scared/audio/EP04_voice.wav"):
				master_audio.stream = load("res://nemi/episodes/ep04_scared/audio/EP04_voice.wav")
			elif ResourceLoader.exists("res://nemi/episodes/ep04_scared/audio/EP04_voice.mp3"):
				master_audio.stream = load("res://nemi/episodes/ep04_scared/audio/EP04_voice.mp3")
		master_audio.play(0.0)

	for beat_idx in range(BEAT_SCENES.size()):
		var beat_scene: PackedScene = BEAT_SCENES[beat_idx]
		print("[MASTER] Loading Beat %d of %d..." % [beat_idx + 1, BEAT_SCENES.size()])
		
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
			
		# Clean up beat instance before next beat begins
		beat_instance.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
		
	print("============================================================")
	print("EPISODE 04 PLAYBACK COMPLETED SUCCESSFULLY (73.20s)")
	print("============================================================")
	
	for f in range(10):
		await get_tree().process_frame
	get_tree().quit(0)
