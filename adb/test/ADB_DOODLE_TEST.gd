class_name ADBDoodleTest
extends Node2D

## ADB_DOODLE_TEST — Test Suite for Hand-Authored Doodles
## Demonstrates:
## - Arrow (authored curve with flick barbs)
## - Imperfect Circle (spiral overlap, organic oval)
## - Star (5-point hand-sketched with organic vertices)
## - Question mark (hand-inked hook with dot)
## - Exclamation mark
## - Handwritten underline (organic wave)
## - Emphasis scribble (energy burst strokes)
## - Check mark
## Zero generic vector icons, zero artificial jitter.

const CommonDoodle = preload("res://common/engine/doodles/CommonDoodle.gd")

@onready var status_label: Label = $UI/StatusLabel
var doodles: Array[CommonDoodle] = []
var step: int = 0
var timer: float = 0.0

func _ready() -> void:
	_setup_doodles()
	_run_step(0)

func _setup_doodles() -> void:
	var items: Array[Dictionary] = [
		{"type": CommonDoodle.DoodleType.ARROW, "pos": Vector2(300, 300), "name": "Curved Arrow", "scale": 1.4, "col": Color("#1c1822")},
		{"type": CommonDoodle.DoodleType.CIRCLE, "pos": Vector2(600, 300), "name": "Imperfect Circle", "scale": 1.5, "col": Color("#2d142c")},
		{"type": CommonDoodle.DoodleType.STAR, "pos": Vector2(900, 300), "name": "Hand-Drawn Star", "scale": 1.4, "col": Color("#d48832")},
		{"type": CommonDoodle.DoodleType.QUESTION, "pos": Vector2(1200, 300), "name": "Question Hook", "scale": 1.5, "col": Color("#1c1822")},
		{"type": CommonDoodle.DoodleType.EXCLAMATION, "pos": Vector2(1500, 300), "name": "Exclamation Mark", "scale": 1.5, "col": Color("#8a2435")},
		{"type": CommonDoodle.DoodleType.UNDERLINE, "pos": Vector2(450, 680), "name": "Organic Underline", "scale": 1.8, "col": Color("#1c1822")},
		{"type": CommonDoodle.DoodleType.EMPHASIS_SCRIBBLE, "pos": Vector2(850, 680), "name": "Energy Scribble", "scale": 1.6, "col": Color("#c4323f")},
		{"type": CommonDoodle.DoodleType.CHECK_MARK, "pos": Vector2(1250, 680), "name": "Check Mark", "scale": 1.5, "col": Color("#2a6f43")}
	]
	
	for item in items:
		var d := CommonDoodle.new()
		d.position = item["pos"]
		d.set_doodle(item["type"], item["col"], item["scale"])
		d.draw_progress = 0.0
		add_child(d)
		doodles.append(d)
		
		# Add title below
		var lbl := Label.new()
		lbl.text = item["name"]
		lbl.position = Vector2(-70, 70)
		lbl.add_theme_font_size_override("font_size", 18)
		lbl.add_theme_color_override("font_color", Color(0.3, 0.3, 0.35, 0.8))
		d.add_child(lbl)

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.75:
		timer = 0.0
		step += 1
		if step < doodles.size():
			_run_step(step)
		elif step == doodles.size():
			_update_status("All Authored Doodles Revealed Successfully")

func _run_step(s: int) -> void:
	if s < doodles.size():
		var d := doodles[s]
		d.animate_draw_on(0.28)
		_update_status("Revealing Doodle " + str(s + 1) + "/" + str(doodles.size()) + ": " + d.get_child(0).text)

func _update_status(txt: String) -> void:
	if status_label:
		status_label.text = txt
	print("[ADB_DOODLE_TEST] " + txt)
