class_name NemiAudio
extends Node
## NemiAudio — Production Audio System & Timeline Event Dispatcher
##
## Central sound manager for Nemi YouTube videos:
## - Indexes all 166+ curated sound effects from audio/sfx/sfx_catalog.json
## - Simple playback API: NemiAudio.play("cartoon_pop_bubble_01")
## - Timeline event parser: NemiAudio.play_event({"time": 5.37, "event": "sfx", "id": "camera_punch_03"})
## - Volume group mixing: Voice, SFX, Music, Ambience
## - Automatic dialogue ducking support

const CATALOG_PATH := "res://audio/sfx/sfx_catalog.json"

static var instance: NemiAudio = null

# Volume Groups (dB)
@export var master_volume_db: float = 0.0
@export var voice_volume_db: float = 0.0
@export var sfx_volume_db: float = -2.0
@export var music_volume_db: float = -12.0
@export var ambience_volume_db: float = -16.0

# Dialogue Ducking
@export var enable_ducking: bool = true
@export var ducking_offset_db: float = -4.0
var is_dialogue_playing: bool = false

# Internal Catalog & Stream Cache
var _catalog_by_id: Dictionary = {}
var _stream_cache: Dictionary = {}
var _active_players: Array[AudioStreamPlayer] = []

func _enter_tree() -> void:
	if instance == null:
		instance = self

func _ready() -> void:
	_load_catalog()

## Loads and indexes the sound library from sfx_catalog.json
func _load_catalog() -> void:
	if not FileAccess.file_exists(CATALOG_PATH):
		push_warning("NemiAudio: Catalog not found at %s" % CATALOG_PATH)
		return
		
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	if json.parse(text) != OK:
		push_warning("NemiAudio: Failed to parse catalog JSON")
		return
		
	var data: Dictionary = json.data
	var assets: Array = data.get("assets", [])
	for item in assets:
		var id: String = item.get("id", "")
		if not id.is_empty():
			_catalog_by_id[id] = item

## Check if an SFX ID exists in the library
func has_sfx(sfx_id: String) -> bool:
	return _catalog_by_id.has(sfx_id)

## Returns the metadata dictionary for an SFX ID
func get_sfx_info(sfx_id: String) -> Dictionary:
	return _catalog_by_id.get(sfx_id, {})

## Loads and caches an AudioStream for an SFX ID
func get_stream(sfx_id: String) -> AudioStream:
	if _stream_cache.has(sfx_id):
		return _stream_cache[sfx_id]
		
	if not _catalog_by_id.has(sfx_id):
		push_warning("NemiAudio: Unknown SFX ID '%s'" % sfx_id)
		return null
		
	var rel_path: String = _catalog_by_id[sfx_id].get("relative_path", "")
	var res_path: String = "res://" + rel_path
	if not ResourceLoader.exists(res_path):
		push_warning("NemiAudio: Asset missing at '%s'" % res_path)
		return null
		
	var stream: AudioStream = load(res_path)
	if stream != null:
		_stream_cache[sfx_id] = stream
	return stream

## Main API: Plays an SFX by ID
## Usage: NemiAudio.play("cartoon_pop_bubble_01")
func play(sfx_id: String, volume_offset_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer:
	var stream := get_stream(sfx_id)
	if stream == null:
		return null
		
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.pitch_scale = pitch_scale
	
	# Calculate target gain
	var final_db: float = sfx_volume_db + volume_offset_db
	if enable_ducking and is_dialogue_playing:
		var cat: String = _catalog_by_id.get(sfx_id, {}).get("category", "")
		# Duck loud categories during vocal narration
		if cat in ["impacts", "stings", "car", "gym"]:
			final_db += ducking_offset_db
			
	player.volume_db = final_db
	add_child(player)
	_active_players.append(player)
	
	player.finished.connect(func():
		_active_players.erase(player)
		player.queue_free()
	)
	
	player.play()
	return player

## Plays a timeline cue event dictionary
## Example: {"time": 5.37, "event": "sfx", "id": "camera_punch_03", "volume_db": -3.0}
func play_event(event: Dictionary) -> AudioStreamPlayer:
	var id: String = event.get("id", "")
	if id.is_empty():
		return null
		
	var vol_offset: float = event.get("volume_db", 0.0)
	var pitch: float = event.get("pitch_scale", 1.0)
	return play(id, vol_offset, pitch)

## Stops all currently playing sounds
func stop_all() -> void:
	for player in _active_players:
		if is_instance_valid(player):
			player.stop()
			player.queue_free()
	_active_players.clear()
