extends Node2D
class_name EP03Scolded

## Episode 03 Master Episode Controller: "My Mom Scolded Me"
## Locked Master Duration: 110.89 seconds
## Voice Actor: Sohee (23 segments, 001.wav - 023.wav)
## Rig: Live Vector Nemi + Illustrated Vector Mom
##
## Sequentially coordinates all 9 beats with continuous master audio timeline:
## - Beat 1: The Hook (0.00s – 13.67s)
## - Beat 2: The Golden Rule (13.67s – 22.34s)
## - Beat 3: Theoretical Overconfidence (22.34s – 33.43s)
## - Beat 4: The Creative Trap (33.43s – 42.75s)
## - Beat 5: The Driveway Crunch (42.75s – 51.35s)
## - Beat 6: The Arctic Permafrost (51.35s – 63.08s)
## - Beat 7: The Emergency Defrost Protocol (63.08s – 81.85s)
## - Beat 8: The Maternal Radar & The Scolding (81.85s – 98.21s)
## - Beat 9: The Payoff & Cereal Dinner (98.21s – 110.89s)

const BEAT_SCENES: Array[PackedScene] = [
	preload("res://nemi/episodes/ep03_scolded/beats/Beat01_Hook.tscn"),
	preload("res://nemi/episodes/ep03_scolded/beats/Beat02_ThePlan.tscn"),
	preload("res://nemi/episodes/ep03_scolded/beats/Beat03_Overconfidence.tscn"),
	preload("res://nemi/episodes/ep03_scolded/beats/Beat04_CreativeTrap.tscn"),
	preload("res://nemi/episodes/ep03_scolded/beats/Beat05_PanicArrival.tscn"),
	preload("res://nemi/episodes/ep03_scolded/beats/Beat06_ThePermafrost.tscn"),
	preload("res://nemi/episodes/ep03_scolded/beats/Beat07_EmergencyDefrost.tscn"),
	preload("res://nemi/episodes/ep03_scolded/beats/Beat08_TheScolding.tscn"),
	preload("res://nemi/episodes/ep03_scolded/beats/Beat09_PayoffOutro.tscn")
]

@export var debug_mode: bool = false

@onready var master_audio: AudioStreamPlayer = $MasterAudio
@onready var beat_container: Node2D = $BeatContainer

var current_beat_instance: Node2D = null

func _ready() -> void:
	call_deferred("start_episode")

func start_episode() -> void:
	print("============================================================")
	print("EPISODE 03: \"MY MOM SCOLDED ME\" — MASTER PLAYBACK")
	print("Duration: 110.89s | Voice: Sohee | Rig: Vector Nemi & Vector Mom")
	print("============================================================")
	
	if master_audio:
		if not master_audio.stream:
			if ResourceLoader.exists("res://nemi/episodes/ep03_scolded/audio/EP03_audio_sfx_master.wav"):
				master_audio.stream = load("res://nemi/episodes/ep03_scolded/audio/EP03_audio_sfx_master.wav")
			elif ResourceLoader.exists("res://nemi/episodes/ep03_scolded/audio/EP03_voice.wav"):
				master_audio.stream = load("res://nemi/episodes/ep03_scolded/audio/EP03_voice.wav")
			else:
				push_error("Master audio EP03_audio_sfx_master.wav not found!")
		master_audio.play(0.0)
		
	for beat_idx in range(BEAT_SCENES.size()):
		var beat_scene: PackedScene = BEAT_SCENES[beat_idx]
		print("[MASTER EP03] Loading Beat %d of %d..." % [beat_idx + 1, BEAT_SCENES.size()])
		
		var beat_instance = beat_scene.instantiate()
		beat_instance.is_standalone = false
		beat_container.add_child(beat_instance)
		current_beat_instance = beat_instance
		
		if beat_instance.has_method("start_beat"):
			beat_instance.start_beat()
			
		if beat_instance.has_signal("beat_finished"):
			await beat_instance.beat_finished
		else:
			push_warning("Beat %d does not have beat_finished signal!" % [beat_idx + 1])
			
		beat_instance.queue_free()
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		
	print("============================================================")
	print("EPISODE 03 PLAYBACK COMPLETED SUCCESSFULLY (110.89s)")
	print("============================================================")
	
	for f in range(30):
		await RenderingServer.frame_post_draw
	get_tree().quit(0)
