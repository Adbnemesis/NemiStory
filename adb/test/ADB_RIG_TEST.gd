class_name ADBRigTest
extends Node2D

## Comprehensive Technical Rig Test for ADB Character
## Tests neutral, blink, eye dart, head tilt, expressions, gestures, body lean, weight shift, reactions, and lip sync.

const ADB = preload("res://adb/characters/adb/ADB.gd")

@onready var adb: ADB = $ADB
@onready var status_label: Label = $UI/StatusLabel

var test_step: int = 0
var timer: float = 0.0

func _ready() -> void:
	if not adb:
		adb = $ADB
	_run_step(0)

func _process(delta: float) -> void:
	timer += delta
	if timer >= 1.0:
		timer = 0.0
		test_step += 1
		if test_step > 15:
			test_step = 0
		_run_step(test_step)

func _run_step(step: int) -> void:
	match step:
		0:
			_update_status("01/16: Neutral Baseline")
			adb.set_pose("relaxed_standing", 0.20)
			adb.set_expression("neutral", 0.15)
			adb.look("camera")
			adb.stop_speaking()
			
		1:
			_update_status("02/16: Conversational Blink")
			adb.blink(0.14)
			
		2:
			_update_status("03/16: Eye Dart & Gaze (Side-Eye)")
			adb.look("side_eye")
			adb.head_tilt_to(6.0, 0.20)
			
		3:
			_update_status("04/16: Weight Shift Left Hip")
			adb.set_pose("weight_left", 0.25)
			adb.look("camera")
			
		4:
			_update_status("05/16: Weight Shift Right Hip + Smug Smile")
			adb.set_pose("weight_right", 0.25)
			adb.set_expression("smug", 0.18)
			
		5:
			_update_status("06/16: Explaining Gesture + Lip-Sync Speech")
			adb.set_pose("explaining", 0.22)
			adb.set_expression("happy", 0.15)
			adb.start_speaking(12.0)
			
		6:
			_update_status("07/16: Pointing Emphasis + Stop Speaking")
			adb.stop_speaking()
			adb.set_pose("pointing", 0.20)
			adb.set_expression("neutral", 0.15)
			
		7:
			_update_status("08/16: Confused Reaction (Asymmetric Brows)")
			adb.set_pose("hand_near_face", 0.25)
			adb.set_expression("confused", 0.18)
			adb.head_tilt_to(10.0, 0.20)
			
		8:
			_update_status("09/16: Sudden Shock / Surprise (Wide Eyes)")
			adb.set_pose("surprised_snap", 0.15)
			adb.set_expression("shocked", 0.12)
			adb.head_tilt_to(0.0, 0.10)
			
		9:
			_update_status("10/16: Embarrassed Cute Fluster (Cheek Blush + Small 'o')")
			adb.set_pose("embarrassed", 0.25)
			adb.set_expression("embarrassed", 0.20)
			adb.head_tilt_to(8.0, 0.20)
			
		10:
			_update_status("11/16: Secretly Cute Smile (Soft Pink Wash)")
			adb.set_pose("relaxed_standing", 0.25)
			adb.set_expression("cute", 0.18)
			adb.head_tilt_to(-4.0, 0.18)
			
		11:
			_update_status("12/16: Annoyed Crossed Arms (Sideways Glare)")
			adb.set_pose("annoyed", 0.25)
			adb.set_expression("annoyed", 0.18)
			
		12:
			_update_status("13/16: Excited Anime Sparkle Burst")
			adb.set_pose("excited", 0.20)
			adb.set_expression("excited", 0.15)
			adb.head_tilt_to(0.0, 0.15)
			
		13:
			_update_status("14/16: Baffled Shrug ('Who Knows?')")
			adb.set_pose("shrug_open", 0.20)
			adb.set_expression("amused", 0.18)
			adb.head_tilt_to(7.0, 0.18)
			
		14:
			_update_status("15/16: Comedic Deadpan Freeze (0-Motion Hold)")
			adb.set_pose("deadpan_freeze", 0.08)
			adb.set_expression("deadpan", 0.08)
			adb.look("camera")
			adb.head_tilt_to(0.0, 0.05)
			adb.freeze_stillness(1.2)
			
		15:
			_update_status("16/16: Delayed Post-Freeze Blink")
			adb.blink(0.14)

func _update_status(text: String) -> void:
	if status_label:
		status_label.text = text
	print("[ADB_RIG_TEST] " + text)
