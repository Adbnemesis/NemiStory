class_name ADBCommonHandDrawnTest
extends Node2D

## ADB_COMMON_HAND_DRAWN_TEST — Unified Visual Language Verification
## Verifies that:
## - ADB Character
## - Hand-drawn Prop (notebook)
## - Hand-authored Doodle (curved arrow)
## - Organic Handwriting ("he didn't even notice.")
## all appear as if created by the EXACT SAME human illustrator.
## Zero stock-vector aesthetics, zero corporate UI callouts, zero generic fonts.

const ADB = preload("res://adb/characters/adb/ADB.gd")
const CommonDoodle = preload("res://common/engine/doodles/CommonDoodle.gd")
const CommonHandwriting = preload("res://common/engine/handwriting/CommonHandwriting.gd")

@onready var adb: ADB = $ADB
@onready var doodle: CommonDoodle = $Doodle
@onready var handwriting: CommonHandwriting = $Handwriting
@onready var status_label: Label = $UI/StatusLabel

var timer: float = 0.0
var sequence_phase: int = 0

func _ready() -> void:
	if not adb:
		adb = $ADB
	_setup_scene()

func _setup_scene() -> void:
	# Configure ADB character
	adb.position = Vector2(850, 560)
	adb.set_pose("pointing", 0.20)
	adb.set_expression("smug", 0.15)
	adb.look("side_eye")
	adb.head_tilt_to(5.0, 0.18)
	
	# Configure Doodle (Curved arrow pointing towards ADB's expression)
	if doodle:
		doodle.position = Vector2(1280, 480)
		doodle.set_doodle(CommonDoodle.DoodleType.ARROW, Color("#8a2435"), 1.6)
		doodle.draw_progress = 0.0
	
	# Configure Handwriting
	if handwriting:
		handwriting.position = Vector2(1300, 360)
		handwriting.set_handwriting("he didn't even notice.", 40, Color("#1c1822"), true, -3.0)
		handwriting.write_progress = 0.0

func _process(delta: float) -> void:
	timer += delta
	
	if timer >= 0.8 and sequence_phase == 0:
		sequence_phase = 1
		_update_status("Phase 1: Revealing Hand-Drawn Annotation...")
		if handwriting:
			handwriting.animate_write_on(0.40)
			
	elif timer >= 1.6 and sequence_phase == 1:
		sequence_phase = 2
		_update_status("Phase 2: Revealing Authored Arrow Doodle...")
		if doodle:
			doodle.animate_draw_on(0.25)
			
	elif timer >= 2.4 and sequence_phase == 2:
		sequence_phase = 3
		_update_status("Phase 3: Conversational Reaction Blink & Gaze Shift")
		adb.look("camera")
		adb.blink(0.14)
		adb.set_expression("cute", 0.20)
		
	elif timer >= 5.0 and sequence_phase == 3:
		# Reset loop
		timer = 0.0
		sequence_phase = 0
		_setup_scene()

func _update_status(txt: String) -> void:
	if status_label:
		status_label.text = txt
	print("[ADB_COMMON_HAND_DRAWN_TEST] " + txt)
