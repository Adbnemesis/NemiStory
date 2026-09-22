class_name Ep03BaseBeat
extends Node2D

## Base Class for Episode 03 Beat Scenes: "My Mom Scolded Me"
## Provides deterministic frame-accurate timing (MovieWriter 30 FPS mode),
## subtitle card sequencing, character coordination, and audio playback.

signal beat_finished()

const Episode03Subtitles = preload("res://nemi/episodes/ep03_scolded/Episode03Subtitles.gd")
const NemiDoodleDirectorClass = preload("res://nemi/world/doodles/NemiDoodleDirector.gd")
const Ep03DoodlesClass = preload("res://nemi/episodes/ep03_scolded/Ep03Doodles.gd")

@export var is_standalone: bool = false
@export var beat_number: int = 1
@export var beat_name: String = "Beat"

@onready var nemi = get_node_or_null("Nemi")
@onready var mom = get_node_or_null("Mom")
@onready var camera = get_node_or_null("StoryCamera2D")
@onready var world = get_node_or_null("WorldSystem")
@onready var subtitle_label: Label = get_node_or_null("UI/Subtitle")
@onready var voice_player: AudioStreamPlayer = get_node_or_null("VoicePlayer")

var doodle_director: Node2D

func _ready() -> void:
	doodle_director = NemiDoodleDirectorClass.new()
	doodle_director.name = "DoodleDirector"
	add_child(doodle_director)
	
	if subtitle_label:
		subtitle_label.text = ""
		
	if is_standalone:
		call_deferred("start_beat")

func start_beat() -> void:
	print("--- EPISODE 03 BEAT %d: %s STARTED ---" % [beat_number, beat_name.to_upper()])
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	pass

func end_beat() -> void:
	if doodle_director:
		doodle_director.clear_all(0.20)
	if subtitle_label:
		subtitle_label.text = ""
	print("--- EPISODE 03 BEAT %d: %s COMPLETED at frame %d ---" % [beat_number, beat_name.to_upper(), Engine.get_process_frames()])
	beat_finished.emit()
	if is_standalone:
		await wait_seconds(0.2)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	var frames: int = maxi(1, int(round(duration * 30.0)))
	for i in range(frames):
		await get_tree().process_frame

func play_segment(seg_id: String) -> void:
	Episode03Subtitles.play_segment(subtitle_label, nemi, seg_id, self)

func _run_subtitle_cards(label: Label, character: Node2D, cards: Array) -> void:
	for c in cards:
		if label and is_instance_valid(label):
			label.text = c["text"]
		var dur: float = c["duration"]
		var emo: String = c.get("emotion", "normal")
		if character and is_instance_valid(character) and character.has_method("speak"):
			character.speak(c["text"], dur, emo)
		await wait_seconds(dur)
	if label and is_instance_valid(label):
		label.text = ""
