class_name ADBLipSync
extends RefCounted

## Independent Lip-Sync & Phoneme Controller for ADB Character
## Connects audio timestamps or speech cadence to ADB's parametric mouth states.

var _target_face = null
var _is_speaking: bool = false
var _speak_cadence: float = 11.0 # Shapes per second
var _elapsed: float = 0.0

const PHONEME_CYCLE: Array[String] = [
	"talk_open",
	"talk_wide",
	"talk_round",
	"talk_open",
	"neutral"
]
var _cycle_idx: int = 0

func _init(face = null) -> void:
	if face:
		_target_face = face

func setup(face) -> void:
	_target_face = face

func start_speaking(cadence: float = 11.0) -> void:
	_is_speaking = true
	_speak_cadence = cadence
	_elapsed = 0.0
	_cycle_idx = 0
	if _target_face:
		_target_face.set_mouth("talk_open")

func stop_speaking() -> void:
	_is_speaking = false
	if _target_face:
		# Return to face's current emotional resting mouth or neutral
		match _target_face.expression_name:
			"cute", "happy":
				_target_face.set_mouth("smile")
			"smug", "amused":
				_target_face.set_mouth("smirk")
			"deadpan", "annoyed", "frustrated":
				_target_face.set_mouth("deadpan")
			"embarrassed", "shocked", "confused", "surprised":
				_target_face.set_mouth("small_o")
			_:
				_target_face.set_mouth("neutral")

func update(delta: float) -> void:
	if not _is_speaking or not _target_face:
		return
		
	_elapsed += delta
	var interval := 1.0 / _speak_cadence
	if _elapsed >= interval:
		_elapsed -= interval
		_cycle_idx = (_cycle_idx + 1) % PHONEME_CYCLE.size()
		_target_face.set_mouth(PHONEME_CYCLE[_cycle_idx])

func queue_phoneme(shape: String) -> void:
	if _target_face:
		_target_face.set_mouth(shape)
