extends Node2D
class_name EP02Partner

## Episode 02 Master Episode Controller: "How I Met My Partner"
## Locked Master Duration: 102.06 seconds
## Voice Actor: Sohee (22 segments, 001.wav - 022.wav)
## Rig: Live Vector Nemi + Live Vector ADB
##
## Sequentially coordinates all 10 beats with continuous master audio timeline:
## - Beat 1: The Secret (0:00.00 – 7.08s)
## - Beat 2: The Reveal (7.08s – 9.84s)
## - Beat 3: College / COVID Online (9.84s – 20.35s)
## - Beat 4: The Texting Montage (20.35s – 29.49s)
## - Beat 5: Getting Closer (29.49s – 38.55s)
## - Beat 6: The Drunk Story (38.55s – 48.34s)
## - Beat 7: ADB is Cute & Loves Anime (48.34s – 64.95s)
## - Beat 8: Mutual Irritation & Balance (64.95s – 82.16s)
## - Beat 9: Helping Each Other (82.16s – 88.98s)
## - Beat 10: Best Friends & Secret Callback (88.98s – 102.06s)

const BEAT_SCENES: Array[PackedScene] = [
	preload("res://nemi/episodes/ep02_partner/beats/Beat01_Secret.tscn"),
	preload("res://nemi/episodes/ep02_partner/beats/Beat02_Reveal.tscn"),
	preload("res://nemi/episodes/ep02_partner/beats/Beat03_OnlineCollege.tscn"),
	preload("res://nemi/episodes/ep02_partner/beats/Beat04_TextingMontage.tscn"),
	preload("res://nemi/episodes/ep02_partner/beats/Beat05_GettingCloser.tscn"),
	preload("res://nemi/episodes/ep02_partner/beats/Beat06_DrunkStory.tscn"),
	preload("res://nemi/episodes/ep02_partner/beats/Beat07_ADBAnime.tscn"),
	preload("res://nemi/episodes/ep02_partner/beats/Beat08_MutualIrritation.tscn"),
	preload("res://nemi/episodes/ep02_partner/beats/Beat09_HelpingEachOther.tscn"),
	preload("res://nemi/episodes/ep02_partner/beats/Beat10_BestFriends.tscn")
]

@export var debug_mode: bool = false

@onready var master_audio: AudioStreamPlayer = $MasterAudio
@onready var beat_container: Node2D = $BeatContainer

var current_beat_instance: Node2D = null

func _ready() -> void:
	call_deferred("start_episode")

func start_episode() -> void:
	print("============================================================")
	print("EPISODE 02: \"HOW I MET MY PARTNER\" — MASTER PLAYBACK")
	print("Duration: 102.06s | Voice: Sohee | Rig: Vector Nemi & Vector ADB")
	print("============================================================")
	
	if master_audio:
		if not master_audio.stream:
			if ResourceLoader.exists("res://nemi/episodes/ep02_partner/audio/EP02_audio_sfx_master.wav"):
				master_audio.stream = load("res://nemi/episodes/ep02_partner/audio/EP02_audio_sfx_master.wav")
			elif ResourceLoader.exists("res://nemi/episodes/ep02_partner/audio/EP02_voice.wav"):
				master_audio.stream = load("res://nemi/episodes/ep02_partner/audio/EP02_voice.wav")
			else:
				push_error("Master audio EP02_audio_sfx_master.wav not found!")
		master_audio.play(0.0)
		
	for beat_idx in range(BEAT_SCENES.size()):
		var beat_scene: PackedScene = BEAT_SCENES[beat_idx]
		print("[MASTER EP02] Loading Beat %d of %d..." % [beat_idx + 1, BEAT_SCENES.size()])
		
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
	print("EPISODE 02 PLAYBACK COMPLETED SUCCESSFULLY (102.06s)")
	print("============================================================")
	
	for f in range(30):
		await RenderingServer.frame_post_draw
	get_tree().quit(0)
