class_name ADBPerformanceTest
extends Node2D

## ADB_PERFORMANCE_TEST — 16-Second Storytime Character Performance
## Demonstrates:
## - Genuine storytime human animation pacing
## - Real lip-sync phoneme modulation
## - Torso weight shifts & hip asymmetry
## - Hand gestures (explaining, pointing, hand-to-neck, shrug)
## - Facial acting & micro-expressions (blink, eye dart, blush, eyebrow tension)
## - Secondary hair sway & head coordination
## - Intentional comedic stillness (zero-motion deadpan hold)

const ADB = preload("res://adb/characters/adb/ADB.gd")

@onready var adb: ADB = $ADB
@onready var status_label: Label = $UI/StatusLabel
@onready var beat_label: Label = $UI/BeatLabel
@onready var time_label: Label = $UI/TimeLabel

var elapsed_time: float = 0.0
var current_beat: int = -1
const TOTAL_DURATION: float = 16.0

func _ready() -> void:
	if not adb:
		adb = $ADB
	_enter_beat(0)

func _process(delta: float) -> void:
	elapsed_time += delta
	if time_label:
		time_label.text = "TIME: %04.2fs / %04.2fs" % [elapsed_time, TOTAL_DURATION]
	
	if elapsed_time < 2.5:
		if current_beat != 0:
			_enter_beat(0)
	elif elapsed_time < 5.5:
		if current_beat != 1:
			_enter_beat(1)
	elif elapsed_time < 8.5:
		if current_beat != 2:
			_enter_beat(2)
	elif elapsed_time < 11.0:
		if current_beat != 3:
			_enter_beat(3)
	elif elapsed_time < 13.5:
		if current_beat != 4:
			_enter_beat(4)
	elif elapsed_time < 16.0:
		if current_beat != 5:
			_enter_beat(5)
	else:
		# Loop test
		elapsed_time = 0.0
		_enter_beat(0)

func _enter_beat(beat_idx: int) -> void:
	current_beat = beat_idx
	match beat_idx:
		0:
			_update_ui("BEAT 01: Relaxed Baseline Opening", "Casual posture, calm eyes, conversational blink")
			adb.set_pose("relaxed_standing", 0.30)
			adb.set_expression("neutral", 0.20)
			adb.look("camera")
			adb.stop_speaking()
			adb.head_tilt_to(0.0, 0.20)
			
			# Trigger a natural blink 0.8s in
			get_tree().create_timer(0.8).timeout.connect(func():
				if current_beat == 0:
					adb.blink(0.14)
			)
			
		1:
			_update_ui("BEAT 02: Weight Shift & Conversational Lip-Sync", "Weight left hip, open-palm explaining gesture, active speech")
			adb.set_pose("weight_left", 0.28)
			adb.set_expression("amused", 0.18)
			adb.head_tilt_to(6.5, 0.22)
			adb.look("camera")
			adb.start_speaking(13.5)
			
		2:
			_update_ui("BEAT 03: Pointing Emphasis & Gaze Shift", "Right-hand point, side-eye dart, confident smirk")
			adb.set_pose("pointing", 0.22)
			adb.set_expression("smug", 0.18)
			adb.look("side_eye")
			adb.head_tilt_to(-5.0, 0.20)
			
			# Dart back to camera halfway through beat
			get_tree().create_timer(1.2).timeout.connect(func():
				if current_beat == 2:
					adb.look("camera")
					adb.blink(0.12)
			)
			
		3:
			_update_ui("BEAT 04: Unexpected Surprise -> Cute Fluster", "Sudden shock snap, cheek blush wash, hand touches neck")
			adb.stop_speaking()
			adb.set_pose("surprised_snap", 0.12)
			adb.set_expression("shocked", 0.10)
			adb.head_tilt_to(0.0, 0.10)
			
			# Settle into embarrassed fluster after initial snap
			get_tree().create_timer(0.6).timeout.connect(func():
				if current_beat == 3:
					adb.set_pose("embarrassed", 0.25)
					adb.set_expression("embarrassed", 0.20)
					adb.head_tilt_to(8.0, 0.20)
					adb.start_speaking(9.0) # Flustered stutter speech
			)
			
		4:
			_update_ui("BEAT 05: Comedic Deadpan Hold (0-Motion Stillness)", "Abrupt speech stop, horizontal brows, staring directly into camera")
			adb.stop_speaking()
			adb.set_pose("deadpan_freeze", 0.08)
			adb.set_expression("deadpan", 0.08)
			adb.look("camera")
			adb.head_tilt_to(0.0, 0.05)
			adb.freeze_stillness(2.2) # Intentional comedic freeze
			
		5:
			_update_ui("BEAT 06: Delayed Post-Freeze Blink & Shrug Settle", "Delayed comedic blink, shoulders shrug, relaxed smile")
			adb.blink(0.14)
			adb.set_pose("shrug_open", 0.25)
			adb.set_expression("cute", 0.20)
			adb.head_tilt_to(-4.5, 0.22)

func _update_ui(beat_txt: String, status_txt: String) -> void:
	if beat_label:
		beat_label.text = beat_txt
	if status_label:
		status_label.text = status_txt
	print("[ADB_PERFORMANCE_TEST] " + beat_txt + " | " + status_txt)
