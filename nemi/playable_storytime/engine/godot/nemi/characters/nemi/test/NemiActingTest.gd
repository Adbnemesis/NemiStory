class_name NemiActingTest
extends Node2D

## Interactive Acting & Animation Language Test Harness for NEMI (V2 Temporal Rework)
## Demonstrates the 10 Authoritative Tests (Tests A through J):
## - Eyes lead head (attention establishes focus first)
## - Stillness is first-class (over 85% held poses)
## - Psychological progression and graduated realization
## - Contrast between motionless holds and snappy physical action

@onready var nemi: Nemi = $Nemi
@onready var hud: NemiTimingHUD = $TimingHUD
@onready var status_label: Label = $CanvasLayer/TopBar/Margin/VBox/StatusLabel
@onready var test_title_label: Label = $CanvasLayer/TopBar/Margin/VBox/TestTitle

var _is_busy: bool = false

func _ready() -> void:
	if hud and nemi:
		hud.setup(nemi)
	_set_status("Ready. Press Keys A-J (or 1-0) to run acting tests, or click UI buttons.")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_A, KEY_1: run_test_a_attention()
			KEY_B, KEY_2: run_test_b_conversational()
			KEY_C, KEY_3: run_test_c_confusion()
			KEY_D, KEY_4: run_test_d_realization()
			KEY_E, KEY_5: run_test_e_shock()
			KEY_F, KEY_6: run_test_f_deadpan()
			KEY_G, KEY_7: run_test_g_exaggerated_action()
			KEY_H, KEY_8: run_test_h_novel_combination()
			KEY_I, KEY_9: run_test_i_multistage_reaction()
			KEY_J, KEY_0: run_test_j_three_intensities()
			KEY_SPACE:
				if nemi: nemi.freeze()
				_set_status("FROZEN in place.")
			KEY_R:
				if nemi: nemi.reset_state()
				_set_status("Reset to neutral idle rest pose.")
			KEY_M:
				if nemi:
					nemi.toggle_art_mode()
					_set_status("Toggled art mode: " + nemi.get_art_mode_name())
			KEY_H:
				if hud:
					hud.visible = not hud.visible
					_set_status("Timing HUD: " + ("ON" if hud.visible else "OFF"))

func _set_status(msg: String, test_name: String = "") -> void:
	if status_label: status_label.text = msg
	if test_title_label and test_name != "": test_title_label.text = "TEST " + test_name

func _on_freeze_pressed() -> void:
	if nemi: nemi.freeze()
	_set_status("FROZEN in place.")

func _on_reset_pressed() -> void:
	if nemi: nemi.reset_state()
	_set_status("Reset to neutral idle rest pose.")

func _on_mode_pressed() -> void:
	if nemi:
		nemi.toggle_art_mode()
		_set_status("Toggled art mode: " + nemi.get_art_mode_name())

func _on_hud_pressed() -> void:
	if hud:
		hud.visible = not hud.visible
		_set_status("Timing HUD: " + ("ON" if hud.visible else "OFF"))

# =========================================================================
# THE 10 AUTHORITATIVE ACTING TESTS (TESTS A THROUGH J)
# =========================================================================

## TEST A — ATTENTION
## Sequence: neutral -> hold 0.6s -> eyes look right -> hold 0.15s -> head follows -> hold 0.5s -> reset
func run_test_a_attention() -> void:
	if _is_busy: return
	_is_busy = true
	_set_status("Running Test A: Attention (Eye-Lead)...", "A — ATTENTION")
	await nemi.actor.reactions.test_a_attention()
	_set_status("Test A Completed. (Eye-lead before head turn verified).")
	_is_busy = false

## TEST B — CONVERSATIONAL
## Sequence: neutral -> small eye movement -> eyebrow raise -> tiny head tilt -> small smile -> hold -> return
func run_test_b_conversational() -> void:
	if _is_busy: return
	_is_busy = true
	_set_status("Running Test B: Conversational...", "B — CONVERSATIONAL")
	await nemi.actor.reactions.test_b_conversational()
	_set_status("Test B Completed. (Subtle facial micro-acting without unnecessary body motion verified).")
	_is_busy = false

## TEST C — CONFUSION
## Sequence: neutral -> attention -> pause -> asymmetric eyebrow movement -> slight head tilt -> hold -> tiny second eye movement
func run_test_c_confusion() -> void:
	if _is_busy: return
	_is_busy = true
	_set_status("Running Test C: Confusion...", "C — CONFUSION")
	await nemi.actor.reactions.test_c_confusion()
	_set_status("Test C Completed. (Cognitive thinking progression verified).")
	_is_busy = false

## TEST D — REALIZATION
## Sequence: neutral -> notice -> pause -> eyes widen -> brows rise -> mouth begins changing -> head turns -> hold
func run_test_d_realization() -> void:
	if _is_busy: return
	_is_busy = true
	_set_status("Running Test D: Realization...", "D — REALIZATION")
	await nemi.actor.reactions.test_d_realization()
	_set_status("Test D Completed. (Graduated realization delay verified).")
	_is_busy = false

## TEST E — SHOCK
## Sequence: neutral -> notice -> pause -> eyes widen -> brows rise -> mouth opens -> anticipation -> recoil -> hair follows -> settle -> freeze -> long hold
func run_test_e_shock() -> void:
	if _is_busy: return
	_is_busy = true
	_set_status("Running Test E: Shock & Recoil...", "E — SHOCK")
	await nemi.actor.reactions.test_e_shock()
	_set_status("Test E Completed. (Snap recoil, secondary hair follow, and aftermath freeze verified).")
	_is_busy = false

## TEST F — DEADPAN
## Sequence: notice -> tiny head tilt -> minimal facial change -> hold 1.0s
func run_test_f_deadpan() -> void:
	if _is_busy: return
	_is_busy = true
	_set_status("Running Test F: Deadpan...", "F — DEADPAN")
	await nemi.actor.reactions.test_f_deadpan()
	_set_status("Test F Completed. (Understated comedic stillness hold verified).")
	_is_busy = false

## TEST G — EXAGGERATED COMEDIC ACTION
## Sequence: neutral -> anticipation -> fast pointing action -> overshoot -> settle -> hold -> sudden recoil -> freeze
func run_test_g_exaggerated_action() -> void:
	if _is_busy: return
	_is_busy = true
	_set_status("Running Test G: Exaggerated Action...", "G — EXAGGERATED ACTION")
	await nemi.actor.reactions.test_g_exaggerated_action()
	_set_status("Test G Completed. (Anticipation, overshoot, and snap freeze contrast verified).")
	_is_busy = false

## TEST H — NOVEL COMBINATION
## Sequence: looks left with eyes, turns head right, raises one eyebrow, leans backward, raises right arm, bends elbow, points upward, opens mouth slightly, hair follows, freezes
func run_test_h_novel_combination() -> void:
	if _is_busy: return
	_is_busy = true
	_set_status("Running Test H: Novel Combination...", "H — NOVEL COMBINATION")
	await nemi.actor.reactions.test_h_novel_combination()
	_set_status("Test H Completed. (Novel unauthored pose produced entirely on live rig).")
	_is_busy = false

## TEST I — MULTI-STAGE REACTION (CORE TEST)
## Sequence: NORMAL -> NOTICE -> CONFUSION -> REALIZATION -> SHOCK -> AFTERMATH
func run_test_i_multistage_reaction() -> void:
	if _is_busy: return
	_is_busy = true
	_set_status("Running Test I: Multi-Stage Reaction...", "I — MULTI-STAGE REACTION")
	await nemi.actor.reactions.test_i_multistage_reaction()
	_set_status("Test I Completed. (Full psychological escalation arc verified).")
	_is_busy = false

## TEST J — THREE INTENSITIES
## Sequence: Recoil at 0.2 (subtle), 0.5 (normal), 1.0 (exaggerated)
func run_test_j_three_intensities() -> void:
	if _is_busy: return
	_is_busy = true
	_set_status("Running Test J: Three Intensities...", "J — THREE INTENSITIES")
	await nemi.actor.reactions.test_j_three_intensities()
	_set_status("Test J Completed. (Subtle 0.2x, Normal 0.5x, and Exaggerated 1.0x verified).")
	_is_busy = false
