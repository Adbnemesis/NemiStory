extends "res://nemi/episodes/ep06_how_i_animate/Ep06BaseBeat.gd"

## Beat 04: Recording the Narration (39.89s – 52.47s)
## Segments:
## - seg07_then_voice (6.04s)
## - seg08_master_clock (6.04s)

var mic_prop: Node2D

func _ready() -> void:
	beat_number = 4
	beat_name = "Recording the Voice"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep06_how_i_animate/audio/segments/seg07_then_voice.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_RECORDING_BOOTH, 0.4)

	# Illustrated Studio Condenser Mic on stand in foreground
	mic_prop = spawn_prop("microphone", Vector2(640.0, 410.0), fg_props_layer)

	nemi.reset()
	nemi.position = Vector2(470.0, 480.0)
	nemi.set_pose("relaxed_standing_right_weight", 0.0)
	nemi.set_expression("smile")
	nemi.look("right")

	var cards = Episode06SubtitlesClass.get_cards_for_beat(4)

	# Card 1: "Then comes the voice." (1.69s) - Lean toward microphone
	nemi.position = Vector2(478.0, 480.0)
	nemi.set_pose("one_hand_explaining", 0.22)
	doodle_director.spawn_speech_bubble(Vector2(760.0, 240.0), "VOICE FIRST!", INK_GOLD).auto_dismiss(2.5)
	await _run_card(cards[0])

	# Card 2: "The voice is the" (1.69s) - Sound waves between mouth and mic
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.head_tilt(-3.0, 0.2)
	doodle_director.spawn_sound_wave_pulse(Vector2(560.0, 350.0)).auto_dismiss(3.0)
	await _run_card(cards[1])

	# Card 3: "absolute backbone of everything." (2.66s) - Both hands, big stamp in open space
	cam_push_in(0.12, 2.5)
	nemi.position = Vector2(470.0, 480.0)
	nemi.set_pose("both_hands_explaining_asym", 0.25)
	nemi.set_expression("candid")
	doodle_director.spawn_handwritten_stamp(Vector2(260.0, 240.0), "BACKBONE", INK_RED).auto_dismiss(2.5)
	await _run_card(cards[2])

	# Card 4: "I record it," (1.45s) - Lean back and reflect
	nemi.position = Vector2(460.0, 482.0)
	nemi.set_pose("casual_lean_left", 0.2)
	nemi.look("up_right")
	await _run_card(cards[3])

	# Card 5: "listen back," (1.33s) - Finger to lips, checking
	nemi.set_pose("finger_to_lips", 0.2)
	nemi.head_tilt(4.0, 0.2)
	nemi.look("center")
	doodle_director.spawn_speech_bubble(Vector2(760.0, 260.0), "CHECKING...", INK_BLUE).auto_dismiss(2.0)
	await _run_card(cards[4])

	# Card 6: "and that audio becomes" (1.57s) - Presenting the timeline master
	nemi.position = Vector2(470.0, 480.0)
	nemi.set_pose("presenting_prop", 0.25)
	nemi.set_expression("candid")
	await _run_card(cards[5])

	# Card 7: "the master clock." (1.57s) - Settle and confirm
	cam_punch(Vector2(0, -12), 1.25, 0.15)
	nemi.set_pose("relaxed_standing_left_weight", 0.2)
	nemi.set_expression("warm")
	doodle_director.spawn_check_mark(Vector2(750.0, 340.0), "100% TIMED", INK_MINT).auto_dismiss(2.2)
	await _run_card(cards[6])

	# Pause after beat (0.50s)
	nemi.stop_speech()
	cam_reset(0.3)
	await wait_seconds(0.50)
	end_beat()
