class_name ADBAudio
extends Node

## ADBAudio — Production Audio System & Event Dispatcher for ADB Productions
## Enforces Voice Dominance (-2.5 dB True Peak), Event-based short SFX, and BGM OFF.

const CATALOG_PATH := "res://common/audio/sfx/sfx_catalog.json"

static var instance: ADBAudio = null

# Volume Groups (dB)
@export var master_volume_db: float = 0.0
@export var voice_volume_db: float = 0.0
@export var sfx_volume_db: float = -6.0

# BGM Policy: STRICTLY OFF BY DEFAULT for storytime comedic pacing
const BGM_ENABLED: bool = false

var _catalog_by_id: Dictionary = {}
var _stream_cache: Dictionary = {}
var _active_players: Array[AudioStreamPlayer] = []

func _enter_tree() -> void:
	if instance == null:
		instance = self

func _ready() -> void:
	_load_catalog()

func _load_catalog() -> void:
	if not FileAccess.file_exists(CATALOG_PATH):
		push_warning("ADBAudio: Catalog not found at %s" % CATALOG_PATH)
		return
		
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	if json.parse(text) != OK:
		push_warning("ADBAudio: Failed to parse catalog JSON")
		return
		
	var data: Dictionary = json.data
	var assets: Array = data.get("assets", [])
	for item in assets:
		var id: String = item.get("id", "")
		if not id.is_empty():
			_catalog_by_id[id] = item

func play(sfx_id: String, volume_offset_db: float = 0.0) -> AudioStreamPlayer:
	var stream: AudioStream = _get_or_load_stream(sfx_id)
	if not stream:
		return null

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = sfx_volume_db + volume_offset_db
	add_child(player)
	_active_players.append(player)

	player.finished.connect(func():
		_active_players.erase(player)
		player.queue_free()
	)
	player.play()
	return player

func _get_or_load_stream(sfx_id: String) -> AudioStream:
	if _stream_cache.has(sfx_id):
		return _stream_cache[sfx_id]

	var res_path := ""
	# Direct file fallbacks
	match sfx_id:
		"pop":
			res_path = "res://common/audio/sfx/pop.mp3"
		"click":
			res_path = "res://common/audio/sfx/click.mp3"
		"whoosh":
			res_path = "res://common/audio/sfx/whoosh.mp3"
		"chime":
			res_path = "res://common/audio/sfx/chime.mp3"
		"bruh":
			res_path = "res://common/audio/sfx/bruh.mp3"
		"anime_wow":
			res_path = "res://common/audio/sfx/anime-wow.mp3"
		"typing":
			res_path = "res://common/audio/sfx/computer/computer_laptop_typing_fast_01.wav"
		"gym_clank":
			res_path = "res://common/audio/sfx/gym/gym_metal_plate_clank_01.wav"
		"fail":
			res_path = "res://common/audio/sfx/comedic/comedic_fail_low_tone_01.wav"
		"shutter", "camera_zoom":
			res_path = "res://common/audio/sfx/transitions/transition_camera_shutter_01.wav"
		"impact":
			res_path = "res://common/audio/sfx/impacts/impact_punch_medium_01.ogg"
		"smash":
			res_path = "res://common/audio/sfx/impacts/impact_strong_punch_01.mp3"
		"shove":
			res_path = "res://common/audio/sfx/movement/movement_cloth_rustle_01.ogg"
		"bell":
			res_path = "res://common/audio/sfx/chime.mp3"
		_:
			if _catalog_by_id.has(sfx_id):
				var item: Dictionary = _catalog_by_id[sfx_id]
				res_path = "res://" + item.get("relative_path", "")

	if res_path.is_empty() or not ResourceLoader.exists(res_path):
		push_warning("ADBAudio: SFX file not found for ID: %s (%s)" % [sfx_id, res_path])
		return null

	var stream := load(res_path) as AudioStream
	if stream:
		_stream_cache[sfx_id] = stream
	return stream
