extends "res://nemi/episodes/ep06_how_i_animate/Ep06BaseBeat.gd"

## Beat 09: The Microscopic Hair Pixel Fix (104.68s – 121.10s)
## Segments:
## - seg16_fifty_times (8.04s)
## - seg17_zoom_no_unacceptable (7.88s)

func _ready() -> void:
	beat_number = 9
	beat_name = "The Microscopic Fix"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep06_how_i_animate/audio/segments/seg16_fifty_times.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_NORMAL_STUDIO, 0.0)

	nemi.reset()
	nemi.position = Vector2(540.0, 480.0)
	nemi.set_pose("relaxed_standing_right_weight", 0.0)
	nemi.set_expression("candid")
	nemi.look("center")

	var cards = Episode06SubtitlesClass.get_cards_for_beat(9)

	# Card 1: "Then I watch it" (1.45s)
	nemi.position = Vector2(545.0, 480.0)
	nemi.set_pose("one_hand_explaining", 0.22)
	doodle_director.spawn_speech_bubble(Vector2(760.0, 240.0), "POLISHING...", INK_MAIN).auto_dismiss(2.5)
	await _run_card(cards[0])

	# Card 2: "fifty times to polish" (1.81s) - Lean left
	nemi.position = Vector2(530.0, 482.0)
	nemi.set_pose("casual_lean_left", 0.2)
	nemi.head_tilt(-3.0, 0.2)
	doodle_director.spawn_handwritten_stamp(Vector2(320.0, 260.0), "x50 TIMES", INK_GOLD).auto_dismiss(2.5)
	await _run_card(cards[1])

	# Card 3: "the timing." (1.08s)
	nemi.set_pose("casual_hand_on_hip", 0.18)
	await _run_card(cards[2])

	# Card 4: "Everything looks fine..." (1.63s)
	nemi.position = Vector2(540.0, 480.0)
	nemi.set_pose("both_hands_explaining_asym", 0.2)
	nemi.set_expression("smile")
	await _run_card(cards[3])

	# Card 5: "until I notice one" (1.45s) — Sudden detection!
	nemi.set_pose("finger_to_lips", 0.15)
	nemi.set_expression("shock")
	nemi.look("up_right")
	await _run_card(cards[4])

	# Card 6: "tiny hair pixel jittering." (1.63s) - Point to ahoge tuft
	nemi.set_pose("pointing_forward", 0.18)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.POINTING)
	doodle_director.spawn_circle_callout(Vector2(540.0, 305.0), 28.0, INK_RED).auto_dismiss(2.0)
	await _run_card(cards[5])

	# Card 7: "Zoom in." (1.62s) — Extreme Punch Zoom
	nemi.stop_speech()
	transition_backdrop(MODE_MICROSCOPIC_ZOOM, 0.2)
	await wait_seconds(0.1)

	cam_punch(Vector2(0, -60), 1.65, 0.12)
	cam_shake(4.0, 0.15)
	doodle_director.spawn_magnifier_focus(Vector2(570.0, 310.0)).auto_dismiss(3.5)
	await _run_card(cards[6])

	# Card 8: "No." (1.30s) — Deadpan Hold! Stamp in open upper right space
	nemi.set_pose("arms_crossed_skeptical", 0.08)
	nemi.set_expression("deadpan")
	nemi.look("center")
	doodle_director.spawn_handwritten_stamp(Vector2(750.0, 210.0), "NO.", INK_RED, 34).auto_dismiss(2.5)
	await _run_card(cards[7])

	# Card 9: "Unacceptable." (1.62s)
	nemi.head_tilt(3.5, 0.15)
	doodle_director.spawn_handwritten_stamp(Vector2(750.0, 280.0), "UNACCEPTABLE!", INK_RED, 24).auto_dismiss(2.5)
	await _run_card(cards[8])

	# Card 10: "Fix it immediately." (1.94s) - Fixed checkmark in open right space
	nemi.set_pose("one_hand_explaining", 0.2)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.POINTING)
	nemi.set_expression("candid")
	doodle_director.spawn_check_mark(Vector2(750.0, 350.0), "FIXED (1 PIXEL)", INK_MINT).auto_dismiss(2.5)
	play_sfx("ping", -5.0)
	await _run_card(cards[9])

	# Pause after beat (0.55s)
	nemi.stop_speech()
	cam_reset(0.4)
	await wait_seconds(0.55)
	end_beat()
