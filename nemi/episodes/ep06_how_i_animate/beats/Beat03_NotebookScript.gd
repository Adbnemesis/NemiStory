extends "res://nemi/episodes/ep06_how_i_animate/Ep06BaseBeat.gd"

## Beat 03: Scriptwriting in the Spiral Notebook (26.29s – 39.89s)
## Segments:
## - seg05_then_i_write (8.00s)
## - seg06_crossing_out_boring (5.15s)

var notebook: Node2D

func _ready() -> void:
	beat_number = 3
	beat_name = "Scriptwriting"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep06_how_i_animate/audio/segments/seg05_then_i_write.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_DESK_FOCUS, 0.4)

	# Setup desk scene & large open spiral notebook - desk at left, Nemi beside it
	spawn_prop("desk", Vector2(360.0, 485.0), bg_props_layer)
	notebook = spawn_prop("notebook", Vector2(360.0, 442.0), fg_props_layer)
	spawn_prop("cup", Vector2(420.0, 446.0), fg_props_layer)

	nemi.reset()
	nemi.position = Vector2(570.0, 480.0)
	nemi.set_pose("relaxed_standing_right_weight", 0.0)
	nemi.set_expression("concentrated")
	nemi.look("down_left")

	var cards = Episode06SubtitlesClass.get_cards_for_beat(3)

	# Card 1: "So I sit down" (1.45s) - Lean toward desk
	nemi.position = Vector2(560.0, 482.0)
	nemi.set_pose("casual_lean_left", 0.22)
	await _run_card(cards[0])

	# Card 2: "with my notebook" (1.45s) - Point down to the notebook on desk
	nemi.set_pose("pointing_forward", 0.22)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.POINTING)
	doodle_director.spawn_arrow_with_label(Vector2(530.0, 380.0), Vector2(390.0, 430.0), "SKETCHBOOK", INK_MAIN).auto_dismiss(2.5)
	await _run_card(cards[1])

	# Card 3: "and write the script." (1.81s)
	await _run_card(cards[2])

	# Card 4: "Figuring out what's funny," (1.81s) - Thinking chin touch
	nemi.set_pose("thinking_chin_touch", 0.2)
	nemi.set_expression("candid")
	nemi.look("up_right")
	doodle_director.spawn_speech_bubble(Vector2(750.0, 260.0), "IS THIS FUNNY?", INK_GOLD).auto_dismiss(2.5)
	await _run_card(cards[3])

	# Card 5: "and what actually happened." (1.45s) - Circle callout on the notebook
	nemi.set_pose("one_hand_explaining", 0.2)
	nemi.look("down_left")
	doodle_director.spawn_circle_callout(Vector2(360.0, 442.0), 45.0, INK_BLUE).auto_dismiss(2.0)
	await _run_card(cards[4])

	# Pause between seg05 and seg06 (0.45s)
	nemi.stop_speech()
	await wait_seconds(0.45)

	# Card 6: "I write a joke," (1.19s)
	nemi.position = Vector2(560.0, 482.0)
	nemi.set_pose("casual_lean_left", 0.18)
	nemi.look("down_left")
	await _run_card(cards[5])

	# Card 7: "immediately cross it out," (1.39s) — Cross out in red over notebook! Recoil step
	cam_punch(Vector2(0, -10), 1.22, 0.14)
	cam_shake(3.0, 0.15)
	nemi.position = Vector2(585.0, 482.0)
	nemi.set_pose("recoiling", 0.12)
	nemi.set_expression("frown")
	if notebook and notebook.has_method("animate_cross_out"):
		notebook.animate_cross_out(0.2)
	doodle_director.spawn_script_crossout(Vector2(360.0, 430.0)).auto_dismiss(2.5)
	await _run_card(cards[6])

	# Card 8: "because it's way" (1.19s) - Slump in comedic defeat
	nemi.set_pose("defeated_slump", 0.2)
	nemi.set_expression("deadpan")
	nemi.look("center")
	doodle_director.spawn_deadpan_sweat(Vector2(550.0, 300.0)).auto_dismiss(2.0)
	await _run_card(cards[7])

	# Card 9: "too boring." (1.19s) - Stamp TRASH over the crossed out script
	nemi.head_tilt(4.0, 0.2)
	doodle_director.spawn_handwritten_stamp(Vector2(360.0, 350.0), "TRASH", INK_RED).auto_dismiss(1.8)
	play_sfx("pop", -4.0)
	await _run_card(cards[8])

	# Card 10: "And repeat." (0.75s) - Resilient bounce back
	cam_reset(0.25)
	nemi.position = Vector2(570.0, 480.0)
	nemi.set_pose("casual_hand_on_hip", 0.18)
	nemi.set_expression("smile")
	doodle_director.spawn_circle_callout(Vector2(360.0, 350.0), 30.0, INK_GOLD).auto_dismiss(1.5)
	await _run_card(cards[9])

	# Pause after beat (0.45s)
	nemi.stop_speech()
	await wait_seconds(0.45)
	end_beat()
