extends "res://nemi/episodes/ep06_how_i_animate/Ep06BaseBeat.gd"

## Beat 08: Hand-Drawn Props & Doodles (96.15s – 104.68s)
## Segments:
## - seg15_props_and_doodles (8.08s)

var tablet_prop: Node2D
var stylus_prop: Node2D

func _ready() -> void:
	beat_number = 8
	beat_name = "Props & Doodles"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep06_how_i_animate/audio/segments/seg15_props_and_doodles.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_DOODLE_GALLERY, 0.35)

	# Spawn artist desk with drawing tablet and stylus resting firmly on tabletop
	spawn_prop("desk", Vector2(700.0, 485.0), bg_props_layer)
	tablet_prop = spawn_prop("drawing_tablet", Vector2(685.0, 470.0), fg_props_layer)
	stylus_prop = spawn_prop("stylus", Vector2(735.0, 474.0), fg_props_layer)

	nemi.reset()
	nemi.position = Vector2(480.0, 480.0)
	nemi.set_pose("relaxed_standing_right_weight", 0.0)
	nemi.set_expression("smile")
	nemi.look("right")

	var cards = Episode06SubtitlesClass.get_cards_for_beat(8)

	# Card 1: "Next come the hand-drawn" (1.37s)
	nemi.position = Vector2(485.0, 480.0)
	nemi.set_pose("one_hand_explaining", 0.22)
	doodle_director.spawn_speech_bubble(Vector2(280.0, 240.0), "HAND-DRAWN", INK_MAIN, true).auto_dismiss(2.5)
	await _run_card(cards[0])

	# Card 2: "props, the doodles," (1.29s) - Lean toward desk and tablet
	nemi.position = Vector2(500.0, 482.0)
	nemi.set_pose("presenting_prop", 0.2)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	doodle_director.spawn_doodle_showcase(Vector2(700.0, 260.0)).auto_dismiss(3.0)
	await _run_card(cards[1])

	# Card 3: "and handwritten notes." (1.29s) - Open both hands
	nemi.position = Vector2(485.0, 480.0)
	nemi.set_pose("both_hands_explaining_asym", 0.2)
	nemi.set_expression("laugh")
	doodle_director.spawn_handwritten_stamp(Vector2(260.0, 260.0), "ORGANIC INK", INK_GOLD).auto_dismiss(2.5)
	await _run_card(cards[2])

	# Card 4: "Every stroke is drawn" (1.37s)
	nemi.set_pose("one_hand_explaining", 0.2)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.OPEN_PALM_UP)
	await _run_card(cards[3])

	# Card 5: "by hand so the" (1.37s) - Sparks over tablet
	cam_punch(Vector2(0, -10), 1.18, 0.15)
	nemi.head_tilt(-3.0, 0.2)
	doodle_director.spawn_magic_sparks(Vector2(700.0, 360.0)).auto_dismiss(2.0)
	await _run_card(cards[4])

	# Card 6: "whole world feels alive." (1.37s) - Excited jump and checkmark in open left space
	cam_reset(0.3)
	nemi.position = Vector2(480.0, 476.0)
	nemi.set_pose("excited", 0.2)
	nemi.set_expression("smile")
	doodle_director.spawn_check_mark(Vector2(280.0, 340.0), "100% ORGANIC", INK_MINT).auto_dismiss(2.5)
	await _run_card(cards[5])

	# Pause after beat (0.45s)
	nemi.stop_speech()
	nemi.position = Vector2(480.0, 480.0)
	await wait_seconds(0.45)
	end_beat()
