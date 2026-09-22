extends Node2D
class_name EP01Cat

## Episode 01 Master Episode Controller: "I Used To Have A Cat"
## Locked Duration: 82.13 seconds (1 minute 22 seconds)
## Voice Actor: Sohee (19 segments, 001.wav - 019.wav)
##
## Sequentially coordinates all 9 beats with continuous master audio timeline:
## - Beat 1: The Hook (0:00.00 – 2.96s)
## - Beat 2: The Clarification (2.96s – 10.78s)
## - Beat 3: The Discovery (10.78s – 21.58s)
## - Beat 4: The Care (21.58s – 36.97s)
## - Beat 5: The Problem (36.97s – 46.60s)
## - Beat 6: The Shopkeeper (46.60s – 58.84s)
## - Beat 7: Searching for a Home (58.84s – 69.96s)
## - Beat 8: The Payoff (69.96s – 77.36s)
## - Beat 9: Ending (77.36s – 82.13s)

const BEAT_SCENES: Array[PackedScene] = [
	preload("res://nemi/episodes/ep01_cat/beats/Beat01_Hook.tscn"),
	preload("res://nemi/episodes/ep01_cat/beats/Beat02_Clarification.tscn"),
	preload("res://nemi/episodes/ep01_cat/beats/Beat03_Discovery.tscn"),
	preload("res://nemi/episodes/ep01_cat/beats/Beat04_Care.tscn"),
	preload("res://nemi/episodes/ep01_cat/beats/Beat05_Problem.tscn"),
	preload("res://nemi/episodes/ep01_cat/beats/Beat06_Shopkeeper.tscn"),
	preload("res://nemi/episodes/ep01_cat/beats/Beat07_Search.tscn"),
	preload("res://nemi/episodes/ep01_cat/beats/Beat08_Payoff.tscn"),
	preload("res://nemi/episodes/ep01_cat/beats/Beat09_Ending.tscn")
]

@export var debug_mode: bool = false

@onready var master_audio: AudioStreamPlayer = $MasterAudio
@onready var beat_container: Node2D = $BeatContainer

var current_beat_instance: Node2D = null

func _ready() -> void:
	call_deferred("start_episode")

func start_episode() -> void:
	print("============================================================")
	print("EPISODE 01: \"I USED TO HAVE A CAT\" — MASTER PLAYBACK")
	print("Duration: 82.13s | Voice: Sohee | Rig: Vector Nemi | Cat: Neeko")
	print("============================================================")
	
	if master_audio:
		if not master_audio.stream:
			if ResourceLoader.exists("res://nemi/episodes/ep01_cat/audio/EP01_voice.wav"):
				master_audio.stream = load("res://nemi/episodes/ep01_cat/audio/EP01_voice.wav")
			else:
				push_error("Master audio EP01_voice.wav not found!")
		master_audio.play(0.0)
	
	for beat_idx in range(BEAT_SCENES.size()):
		var beat_scene: PackedScene = BEAT_SCENES[beat_idx]
		print("[MASTER EP01] Loading Beat %d of %d..." % [beat_idx + 1, BEAT_SCENES.size()])
		
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
	print("EPISODE 01 PLAYBACK COMPLETED SUCCESSFULLY (82.13s)")
	print("============================================================")
	
	for f in range(30):
		await RenderingServer.frame_post_draw
	get_tree().quit(0)
