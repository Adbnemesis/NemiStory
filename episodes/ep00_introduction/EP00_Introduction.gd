extends Node2D
class_name EP00Introduction

## Episode 00 Master Episode Controller: "Wait, Listen to Me"
## Locked Duration: 125.10 seconds (2 minutes 05 seconds)
## Voice Actor: Sohee (22 segments, 001.wav - 022.wav)
##
## Sequentially runs all 7 beats with continuous audio timeline:
## - Beat 1: The Hook (0:00.00 – 14.70s)
## - Beat 2: Identity & Premise (14.70s – 31.54s)
## - Beat 3: The Animation Struggle (31.54s – 51.31s)
## - Beat 4: Hobbies as Story Fuel (51.31s – 77.72s)
## - Beat 5: Comedic Escalation & The Rabbit Hole (77.72s – 105.18s)
## - Beat 6: Channel Vision & What to Expect (105.18s – 114.49s)
## - Beat 7: Understated Outro (114.49s – 125.10s)

const BEAT_SCENES: Array[PackedScene] = [
	preload("res://episodes/ep00_introduction/beats/Beat01_Hook.tscn"),
	preload("res://episodes/ep00_introduction/beats/Beat02_Identity.tscn"),
	preload("res://episodes/ep00_introduction/beats/Beat03_Struggle.tscn"),
	preload("res://episodes/ep00_introduction/beats/Beat04_Hobbies.tscn"),
	preload("res://episodes/ep00_introduction/beats/Beat05_RabbitHole.tscn"),
	preload("res://episodes/ep00_introduction/beats/Beat06_ChannelVision.tscn"),
	preload("res://episodes/ep00_introduction/beats/Beat07_Outro.tscn")
]

@export var debug_mode: bool = false

@onready var master_audio: AudioStreamPlayer = $MasterAudio
@onready var beat_container: Node2D = $BeatContainer

var current_beat_instance: Node2D = null
var debug_overlay: CanvasLayer = null

func _ready() -> void:
	call_deferred("start_episode")

func start_episode() -> void:
	print("============================================================")
	print("EPISODE 00: \"WAIT, LISTEN TO ME\" — MASTER PRODUCTION PLAYBACK")
	print("Duration: 125.10s | Voice: Sohee | Rig: Vector Nemi")
	print("============================================================")
	
	if master_audio:
		if not master_audio.stream:
			if ResourceLoader.exists("res://episodes/ep00_introduction/EP00_audio_sfx_master.wav"):
				master_audio.stream = load("res://episodes/ep00_introduction/EP00_audio_sfx_master.wav")
			else:
				master_audio.stream = load("res://animations/ep00_introduction/voiceover/voiceover.wav")
		master_audio.play(0.0)
	
	if debug_mode:
		debug_overlay = preload("res://episodes/ep00_introduction/Episode00DebugOverlay.gd").new()
		debug_overlay.debug_mode = true
		add_child(debug_overlay)

	for beat_idx in range(BEAT_SCENES.size()):
		var beat_scene: PackedScene = BEAT_SCENES[beat_idx]
		print("[MASTER] Loading Beat %d of %d..." % [beat_idx + 1, BEAT_SCENES.size()])
		if debug_overlay:
			debug_overlay.update_event("Beat %d" % [beat_idx + 1], "active")
		
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
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		
	print("============================================================")
	print("EPISODE 00 PLAYBACK COMPLETED SUCCESSFULLY (125.10s)")
	print("============================================================")
	
	for f in range(30):
		await RenderingServer.frame_post_draw
	get_tree().quit(0)
