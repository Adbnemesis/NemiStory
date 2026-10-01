class_name ADBHandwritingTest
extends Node2D

## ADB_HANDWRITING_TEST — Hand-Lettering & Organic Handwriting Verification
## Tests:
## - Short conversational handwritten annotations
## - Irregular baseline and organic word tilt
## - Natural character kerning / spacing
## - Animated write-on progressive reveals
## - Hand-drawn underlines
## - ZERO dialogue boxes, ZERO corporate cards, ZERO generic font look.

const CommonHandwriting = preload("res://common/engine/handwriting/CommonHandwriting.gd")
const CommonDoodle = preload("res://common/engine/doodles/CommonDoodle.gd")

@onready var status_label: Label = $UI/StatusLabel
var notes: Array[CommonHandwriting] = []
var step: int = 0
var timer: float = 0.0

func _ready() -> void:
	_setup_handwriting()
	_run_step(0)

func _setup_handwriting() -> void:
	var items: Array[Dictionary] = [
		{
			"text": "WAIT WHAT?!",
			"pos": Vector2(250, 240),
			"size": 48,
			"color": Color("#1c1822"),
			"underline": true,
			"tilt": -3.5
		},
		{
			"text": "definitely not planned...",
			"pos": Vector2(950, 240),
			"size": 36,
			"color": Color("#8a2435"),
			"underline": false,
			"tilt": 2.0
		},
		{
			"text": "(he actually said that with a straight face)",
			"pos": Vector2(280, 520),
			"size": 34,
			"color": Color("#2d142c"),
			"underline": true,
			"tilt": -1.5
		},
		{
			"text": "note to self: stay completely calm.",
			"pos": Vector2(1000, 520),
			"size": 38,
			"color": Color("#1a3c34"),
			"underline": false,
			"tilt": -2.0
		},
		{
			"text": "<- yes, this took 3 hours to figure out.",
			"pos": Vector2(550, 780),
			"size": 32,
			"color": Color("#333333"),
			"underline": false,
			"tilt": 1.2
		}
	]
	
	for item in items:
		var hw := CommonHandwriting.new()
		hw.position = item["pos"]
		hw.set_handwriting(item["text"], item["size"], item["color"], item["underline"], item["tilt"])
		hw.write_progress = 0.0
		add_child(hw)
		notes.append(hw)

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.85:
		timer = 0.0
		step += 1
		if step < notes.size():
			_run_step(step)
		elif step == notes.size():
			_update_status("All Handwritten Annotations Written Successfully")

func _run_step(s: int) -> void:
	if s < notes.size():
		var hw := notes[s]
		hw.animate_write_on(0.40)
		_update_status("Writing Annotation " + str(s + 1) + "/" + str(notes.size()) + ": \"" + hw.text + "\"")

func _update_status(txt: String) -> void:
	if status_label:
		status_label.text = txt
	print("[ADB_HANDWRITING_TEST] " + txt)
