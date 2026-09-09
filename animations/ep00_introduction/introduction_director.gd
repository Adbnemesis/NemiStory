extends Node2D
class_name IntroductionDirector

## Choreography Director for Nemi's Debut Introduction Video
## Target Duration: 1:30 - 2:00 (90 - 120 seconds)
## Follows the 8-beat structure specified in docs/Nemi_Introduction_Video_Requirements.md

@onready var nemi = $Nemi
@onready var world = $WorldSystem
@onready var camera = $StoryCamera2D
@onready var subtitle_label: Label = $UI/Subtitle
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

func _ready() -> void:
	if subtitle_label:
		subtitle_label.text = ""
	call_deferred("_start_introduction")

func _start_introduction() -> void:
	print("--- NEMI INTRODUCTION VIDEO STARTED ---")
	
	if voice_player and voice_player.stream:
		voice_player.play()
	
	_run_introduction_timeline()

func _run_introduction_timeline() -> void:
	# =========================================================================
	# BEAT 1: The Hook (0:00 - 0:06)
	# Immediate scroll-stopping disruption, mid-predicament or urgent callout.
	# =========================================================================
	print("[Beat 1] The Hook (0:00 - 0:06)")
	# Cues to be defined when final script is loaded
	await wait_seconds(6.0)
	
	# =========================================================================
	# BEAT 2: Identity & Mission (0:06 - 0:20)
	# Name (Nemi), Age (24), first serious storytelling attempt on YouTube.
	# =========================================================================
	print("[Beat 2] Identity & Mission (0:06 - 0:20)")
	await wait_seconds(14.0)
	
	# =========================================================================
	# BEAT 3: The Animation Struggle (0:20 - 0:40)
	# Digital drawing reality vs imagination, frame rates, hand anatomy.
	# =========================================================================
	print("[Beat 3] Animation Struggle (0:20 - 0:40)")
	await wait_seconds(20.0)
	
	# =========================================================================
	# BEAT 4: Hobbies as Story Fuel (0:40 - 1:00)
	# Anime deep-dives, gym ambitions, acoustic singing mishaps.
	# =========================================================================
	print("[Beat 4] Hobbies as Story Fuel (0:40 - 1:00)")
	await wait_seconds(20.0)
	
	# =========================================================================
	# BEAT 5: Comedic Escalation (1:00 - 1:25)
	# Compounding blunder, overconfidence collision, deadpan pause.
	# =========================================================================
	print("[Beat 5] Comedic Escalation (1:00 - 1:25)")
	await wait_seconds(25.0)
	
	# =========================================================================
	# BEAT 6: Channel Vision & Expectations (1:25 - 1:45)
	# What viewers can expect: awkward stories, art journey, shared journey.
	# =========================================================================
	print("[Beat 6] Channel Vision (1:25 - 1:45)")
	await wait_seconds(20.0)
	
	# =========================================================================
	# BEAT 7: Understated Outro (1:45 - 1:52)
	# Warm invitation to stay without generic begging.
	# =========================================================================
	print("[Beat 7] Understated Outro (1:45 - 1:52)")
	await wait_seconds(7.0)
	
	# =========================================================================
	# BEAT 8: Post-Credit Stinger (1:52 - 2:00)
	# Stepped panic cycle or self-aware closing realization.
	# =========================================================================
	print("[Beat 8] Post-Credit Stinger (1:52 - 2:00)")
	await wait_seconds(8.0)
	
	print("--- NEMI INTRODUCTION VIDEO COMPLETED ---")

# --- Helper Methods ---

func set_subtitle(text: String) -> void:
	if subtitle_label:
		subtitle_label.text = text

func clear_subtitle() -> void:
	if subtitle_label:
		subtitle_label.text = ""

func wait_seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
