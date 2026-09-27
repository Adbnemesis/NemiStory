extends "res://nemi/episodes/ep06_how_i_animate/Ep06BaseBeat.gd"

## Beat 10: Final Render & Warm Outro (121.10s – 141.75s)
## Segments:
## - seg18_final_render_renders (10.45s)
## - seg19_see_you_next_story (8.83s)

func _ready() -> void:
	beat_number = 10
	beat_name = "Final Render & Outro"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep06_how_i_animate/audio/segments/seg18_final_render_renders.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_WARM_WRAPUP, 0.4)

	nemi.reset()
	nemi.position = Vector2(520.0, 480.0)
	nemi.set_pose("relaxed_standing_right_weight", 0.0)
	nemi.set_expression("warm")
	nemi.look("center")

	var cards = Episode06SubtitlesClass.get_cards_for_beat(10)

	# Card 1: "And finally... after hours" (2.18s)
	nemi.position = Vector2(525.0, 480.0)
	nemi.set_pose("one_hand_explaining", 0.25)
	doodle_director.spawn_handwritten_stamp(Vector2(760.0, 190.0), "100+ HOURS", INK_MAIN).auto_dismiss(3.5)
	await _run_card(cards[0])

	# Card 2: "of tweaking lip sync" (1.96s)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	doodle_director.spawn_speech_bubble(Vector2(780.0, 290.0), "FRAME BY FRAME", INK_MAIN).auto_dismiss(2.2)
	await _run_card(cards[1])

	# Card 3: "and sound effects," (1.85s)
	nemi.head_tilt(-3.0, 0.2)
	doodle_director.spawn_sparkle(Vector2(280.0, 280.0), 30.0, INK_BLUE).auto_dismiss(2.0)
	doodle_director.spawn_sparkle(Vector2(880.0, 260.0), 25.0, INK_GOLD).auto_dismiss(2.0)
	await _run_card(cards[2])

	# Card 4: "the episode renders." (1.74s) — Celebratory burst!
	cam_push_in(0.12, 1.5)
	cam_shake(2.0, 0.35)
	nemi.position = Vector2(520.0, 474.0)
	nemi.set_pose("excited", 0.2)
	nemi.set_expression("laugh")
	doodle_director.spawn_render_complete(Vector2(760.0, 260.0)).auto_dismiss(4.0)
	doodle_director.spawn_handwritten_stamp(Vector2(760.0, 190.0), "RENDER 100%", INK_MINT).auto_dismiss(3.0)
	doodle_director.spawn_exclamation_spikes(Vector2(760.0, 260.0), INK_GOLD).auto_dismiss(2.5)
	play_sfx("chime", -4.0)
	await _run_card(cards[3])

	# Card 5: "So the next time" (1.52s) - Arrow in open left space
	nemi.position = Vector2(520.0, 480.0)
	nemi.set_pose("casual_hand_on_hip", 0.2)
	nemi.set_expression("smile")
	doodle_director.spawn_arrow_with_label(Vector2(280.0, 320.0), Vector2(420.0, 360.0), "THIS VIDEO", INK_BLUE).auto_dismiss(2.5)
	await _run_card(cards[4])

	# Card 6: "you watch one of" (1.20s)
	nemi.head_tilt(3.0, 0.2)
	await _run_card(cards[5])

	# Card 7: "these..." (0.43s)
	nemi.look("center")
	await _run_card(cards[6])

	# Pause between seg18 and seg19 (0.35s)
	nemi.stop_speech()
	await wait_seconds(0.35)

	# Card 8: "Now you know:" (1.50s) - Presenting secret
	nemi.position = Vector2(510.0, 482.0)
	nemi.set_pose("presenting_prop", 0.22)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.OPEN_PALM_UP)
	doodle_director.spawn_speech_bubble(Vector2(780.0, 270.0), "THE SECRET!", INK_GOLD).auto_dismiss(2.2)
	await _run_card(cards[7])

	# Card 9: "it didn't just" (1.33s)
	nemi.set_pose("one_hand_explaining", 0.2)
	await _run_card(cards[8])

	# Card 10: "magically appear." (1.50s) - Underline the stamp text, NOT on Nemi's skirt
	nemi.position = Vector2(530.0, 480.0)
	nemi.set_pose("casual_lean_left", 0.2)
	nemi.set_expression("warm")
	doodle_director.spawn_handwritten_stamp(Vector2(760.0, 200.0), "NO MAGIC WAND!", INK_RED).auto_dismiss(2.6)
	await _run_card(cards[9])

	# Card 11: "It was an entire" (1.50s)
	nemi.set_pose("both_hands_explaining_asym", 0.22)
	doodle_director.spawn_check_mark(Vector2(760.0, 280.0), "STORY + CRAFT", INK_GOLD).auto_dismiss(3.0)
	await _run_card(cards[10])

	# Card 12: "journey." (0.83s)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.HAND_TO_CHEST)
	await _run_card(cards[11])

	# Card 13: "See you in the" (0.83s)
	nemi.position = Vector2(520.0, 480.0)
	nemi.set_pose("relaxed_standing_right_weight", 0.18)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.set_expression("smile")
	await _run_card(cards[12])

	# Card 14: "next story!" (0.83s) — Warm signoff wave!
	nemi.position = Vector2(520.0, 476.0)
	nemi.set_pose("excited", 0.18)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.set_expression("laugh")
	doodle_director.spawn_handwritten_stamp(Vector2(760.0, 190.0), "SEE YA! 👋", INK_PURPLE).auto_dismiss(4.0)
	doodle_director.spawn_sparkle(Vector2(280.0, 240.0), 35.0, INK_GOLD).auto_dismiss(3.5)
	doodle_director.spawn_sparkle(Vector2(760.0, 260.0), 30.0, INK_BLUE).auto_dismiss(3.5)
	doodle_director.spawn_sparkle(Vector2(520.0, 150.0), 40.0, INK_RED).auto_dismiss(3.5)
	play_sfx("chime", -4.0)
	await _run_card(cards[13])

	# Outro settle pause (0.75s)
	nemi.stop_speech()
	cam_reset(0.4)
	await wait_seconds(0.75)
	end_beat()
