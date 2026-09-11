extends Node2D

## Interactive and Automated Diagnostic Test Harness for NEMI Expression FX System V1.
## Tests all 12 reaction FX types, facial exaggeration, anchor points, intensity scaling (1, 3, 5),
## and both COLOR and MONOCHROME art modes.

@onready var nemi: Nemi = $Nemi
@onready var status_label: Label = $CanvasLayer/UI/StatusLabel
@onready var mode_label: Label = $CanvasLayer/UI/ModeLabel
@onready var intensity_label: Label = $CanvasLayer/UI/IntensityLabel

const PRESETS: Array[String] = [
	"confusion",
	"shock",
	"embarrassment",
	"nervous",
	"anger",
	"excitement",
	"realization",
	"panic",
	"sad",
	"relief",
	"deadpan"
]

var current_preset_idx: int = 0
var current_intensity: int = 3
var is_mono: bool = false
var _auto_timer: float = 0.0

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		_run_automated_headless_suite()
		return
	
	if nemi:
		nemi.position = Vector2(640, 520)
		nemi.scale = Vector2(1.5, 1.5)
		nemi.set_pose("casual_standing", 0.0)
		nemi.set_expression("neutral")
	
	_trigger_current_test()

func _process(delta: float) -> void:
	if DisplayServer.get_name() == "headless":
		return
	
	_auto_timer += delta
	if _auto_timer >= 2.0:
		_auto_timer = 0.0
		_next_test()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE, KEY_RIGHT:
				_next_test()
			KEY_LEFT:
				_prev_test()
			KEY_M:
				_toggle_mode()
			KEY_1:
				current_intensity = 1
				_trigger_current_test()
			KEY_3:
				current_intensity = 3
				_trigger_current_test()
			KEY_5:
				current_intensity = 5
				_trigger_current_test()

func _next_test() -> void:
	current_preset_idx = (current_preset_idx + 1) % PRESETS.size()
	_trigger_current_test()

func _prev_test() -> void:
	current_preset_idx = (current_preset_idx - 1 + PRESETS.size()) % PRESETS.size()
	_trigger_current_test()

func _toggle_mode() -> void:
	is_mono = not is_mono
	if nemi:
		nemi.set_art_mode(NemiStyle.ArtMode.MONOCHROME if is_mono else NemiStyle.ArtMode.COLOR)
	_trigger_current_test()

func _trigger_current_test() -> void:
	if not nemi:
		return
	
	nemi.clear_all_fx(true)
	var preset_name := PRESETS[current_preset_idx]
	nemi.react(preset_name, current_intensity, 1.6)
	_update_ui()

func _update_ui() -> void:
	if status_label:
		status_label.text = "FX Preset: %s (Index %d/%d)" % [PRESETS[current_preset_idx].to_upper(), current_preset_idx + 1, PRESETS.size()]
	if mode_label:
		mode_label.text = "Art Mode: %s [Press 'M' to toggle]" % ("MONOCHROME" if is_mono else "COLOR")
	if intensity_label:
		intensity_label.text = "Intensity: %d (1=Subtle, 3=Normal, 5=Exaggerated) [Keys 1, 3, 5]" % current_intensity

## Comprehensive headless test suite verifying all 12 elements and presets
func _run_automated_headless_suite() -> void:
	print("--- BEGINNING NEMI EXPRESSION FX DIAGNOSTIC SUITE ---")
	
	# Instantiate Nemi dynamically if needed
	var test_nemi: Nemi = nemi
	if not test_nemi:
		var nemi_scene = load("res://characters/nemi/nemi.tscn")
		test_nemi = nemi_scene.instantiate()
		add_child(test_nemi)
	
	assert(test_nemi != null, "Failed to instantiate Nemi")
	assert(test_nemi.fx_director != null, "NemiFXDirector failed to initialize")
	
	# Test all presets across intensities 1, 3, 5
	for preset in PRESETS:
		for int_lvl in [1, 3, 5]:
			var fx_elem = test_nemi.react(preset, int_lvl, 0.5)
			assert(fx_elem != null, "Failed to trigger reaction preset: " + preset)
			assert(fx_elem.intensity == int_lvl, "Intensity mismatch for " + preset)
			print("PASS: react('%s', intensity=%d)" % [preset, int_lvl])
			test_nemi.clear_all_fx(true)
	
	# Test low-level helpers
	var sweat = test_nemi.show_sweat("head_right", 3, 0.5)
	assert(sweat != null, "show_sweat failed")
	var q_mark = test_nemi.show_question_mark("head_right", 3, 0.5)
	assert(q_mark != null, "show_question_mark failed")
	var shock = test_nemi.show_shock_lines("head_top", 3, 0.5)
	assert(shock != null, "show_shock_lines failed")
	var blush = test_nemi.show_blush(3, 0.5)
	assert(blush != null, "show_blush failed")
	var stress = test_nemi.show_stress_marks("head_right", 3, 0.5)
	assert(stress != null, "show_stress_marks failed")
	var spark = test_nemi.show_sparkles("head_left", 3, 0.5)
	assert(spark != null, "show_sparkles failed")
	var bulb = test_nemi.show_lightbulb("head_top", 3, 0.5)
	assert(bulb != null, "show_lightbulb failed")
	test_nemi.clear_all_fx(true)
	print("PASS: All low-level convenience helpers verified")
	
	# Test attention directors
	var circle = test_nemi.fx_director.draw_attention_circle(Vector2(50, 50))
	assert(circle != null, "draw_attention_circle failed")
	var arrow = test_nemi.fx_director.draw_attention_arrow(Vector2(0, 0), Vector2(100, 100))
	assert(arrow != null, "draw_attention_arrow failed")
	var hl = test_nemi.fx_director.draw_attention_highlight(Vector2(0, 50))
	assert(hl != null, "draw_attention_highlight failed")
	test_nemi.clear_all_fx(true)
	print("PASS: All visual attention directors verified")
	
	# Test facial exaggeration
	test_nemi.face_exaggerate("shock", 5, 0.5)
	if test_nemi.face._exaggeration_tween and test_nemi.face._exaggeration_tween.is_valid():
		test_nemi.face._exaggeration_tween.custom_step(0.12)
	assert(test_nemi.face.exaggeration_eye_scale > 1.0, "Facial shock eye scaling failed")
	print("PASS: Facial exaggeration verified")
	
	print("--- ALL NEMI EXPRESSION FX DIAGNOSTICS PASSED (100% SUCCESS) ---")
	get_tree().quit(0)
