extends "res://nemi/episodes/ep06_how_i_animate/Ep06BaseBeat.gd"

## Beat 05: The Illustrated Story Beats Timeline (52.47s – 66.44s)
## Segments:
## - seg09_divided_into_beats (6.28s)
## - seg10_beat_examples (7.24s)

func _ready() -> void:
	beat_number = 5
	beat_name = "Story Beats Timeline"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep06_how_i_animate/audio/segments/seg09_divided_into_beats.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_TIMELINE_STAGE, 0.4)

	nemi.reset()
	nemi.position = Vector2(520.0, 480.0)
	nemi.set_pose("relaxed_standing_right_weight", 0.0)
	nemi.set_expression("smile")
	nemi.look("center")

	var cards = Episode06SubtitlesClass.get_cards_for_beat(5)

	# Card 1: "Next: dividing narration" (2.13s) - Step and stamp
	nemi.position = Vector2(525.0, 480.0)
	nemi.set_pose("one_hand_explaining", 0.25)
	nemi.look("up_left")
	doodle_director.spawn_handwritten_stamp(Vector2(260.0, 240.0), "STEP 3: BEATS", INK_MINT).auto_dismiss(3.0)
	await _run_card(cards[0])

	# Card 2: "into storytelling beats." (2.13s) - Lean pointing toward timeline, arrow in open space
	nemi.position = Vector2(515.0, 482.0)
	nemi.set_pose("pointing_forward", 0.22)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.POINTING)
	doodle_director.spawn_arrow_with_label(Vector2(440.0, 360.0), Vector2(280.0, 260.0), "TIMELINE", INK_GOLD).auto_dismiss(2.5)
	await _run_card(cards[1])

	# Card 3: "Not just sentences." (1.88s) - Arms crossed skeptical, weight shifts back
	nemi.position = Vector2(530.0, 480.0)
	nemi.set_pose("arms_crossed_skeptical", 0.2)
	nemi.set_expression("candid")
	nemi.look("center")
	doodle_director.spawn_speech_bubble(Vector2(760.0, 310.0), "NO MONOLOGUES", INK_RED).auto_dismiss(2.2)
	await _run_card(cards[2])

	# Pause between seg09 and seg10 (0.45s)
	nemi.stop_speech()
	await wait_seconds(0.45)

	# Card 4: "Explain. Reaction. Joke." (2.41s) — Lighting up beat markers
	cam_punch(Vector2(20, -10), 1.18, 0.15)
	nemi.position = Vector2(510.0, 490.0)
	nemi.set_pose("pointing_forward", 0.18)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.POINTING)
	doodle_director.spawn_timeline_marker(Vector2(320.0, 240.0), "BEAT!", INK_GOLD).auto_dismiss(2.5)
	play_sfx("pop", -4.0)
	await _run_card(cards[3])

	# Card 5: "Pause. Cutaway." (2.41s) - Open arms, second marker
	nemi.position = Vector2(530.0, 490.0)
	nemi.set_pose("both_hands_explaining_asym", 0.2)
	nemi.set_expression("laugh")
	doodle_director.spawn_timeline_marker(Vector2(780.0, 240.0), "PAUSE", INK_BLUE).auto_dismiss(2.5)
	await _run_card(cards[4])

	# Card 6: "Every single beat." (2.41s) - Checkmark in open right space
	cam_reset(0.3)
	nemi.position = Vector2(520.0, 490.0)
	nemi.set_pose("relaxed_standing_left_weight", 0.22)
	nemi.set_expression("warm")
	doodle_director.spawn_check_mark(Vector2(750.0, 340.0), "STRUCTURED", INK_MINT).auto_dismiss(2.5)
	await _run_card(cards[5])

	# Pause after beat (0.45s)
	nemi.stop_speech()
	await wait_seconds(0.45)
	end_beat()
