extends "res://nemi/episodes/ep06_how_i_animate/Ep06BaseBeat.gd"

## Beat 02: Real Life Spark & Memory Flashback (13.28s – 26.29s)
## Segments:
## - seg03_first_something_happens (6.81s)
## - seg04_wait_funny_story (5.75s)

func _ready() -> void:
	beat_number = 2
	beat_name = "Real Life Spark"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep06_how_i_animate/audio/segments/seg03_first_something_happens.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_MEMORY_EVENT, 0.4)

	nemi.reset()
	nemi.position = Vector2(370.0, 480.0) # Staged on left third for ideal storytime balance
	nemi.set_pose("thinking_chin_touch", 0.0)
	nemi.set_expression("candid")
	nemi.look("up_right")

	var cards = Episode06SubtitlesClass.get_cards_for_beat(2)

	# Card 1: "First: something actually" (1.52s)
	nemi.set_pose("one_hand_explaining", 0.22)
	nemi.head_tilt(-3.0, 0.2)
	doodle_director.spawn_handwritten_stamp(Vector2(820.0, 180.0), "REAL LIFE", INK_GOLD).auto_dismiss(3.0)
	await _run_card(cards[0])

	# Card 2: "has to happen" (1.31s) - Shift weight to left foot
	nemi.position = Vector2(360.0, 482.0)
	nemi.set_pose("casual_lean_left", 0.2)
	await _run_card(cards[1])

	# Card 3: "to me in real life." (1.91s) - Step forward, point to illustrated incident
	nemi.position = Vector2(375.0, 480.0)
	nemi.set_pose("pointing_forward", 0.2)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.POINTING)
	doodle_director.spawn_arrow_with_label(Vector2(460.0, 340.0), Vector2(790.0, 260.0), "COFFEE INCIDENT", INK_MAIN).auto_dismiss(3.0)
	await _run_card(cards[2])

	# Card 4: "Usually last week," (1.31s) - Hand on hip, candid
	nemi.set_pose("casual_hand_on_hip", 0.2)
	nemi.look("center")
	await _run_card(cards[3])

	# Card 5: "or yesterday." (1.31s)
	nemi.head_tilt(4.0, 0.2)
	cam_punch(Vector2(15, -10), 1.18, 0.15)
	doodle_director.spawn_handwritten_stamp(Vector2(190.0, 240.0), "TRUE STORY", INK_RED).auto_dismiss(2.0)
	await _run_card(cards[4])

	# Pause between seg03 and seg04 (0.45s) — Idea starts clicking
	nemi.stop_speech()
	nemi.set_pose("finger_to_lips", 0.2)
	nemi.set_expression("neutral")
	nemi.look("up_left")
	await wait_seconds(0.45)

	# Card 6: "And then my brain" (1.39s)
	nemi.head_tilt(-2.0, 0.15)
	await _run_card(cards[5])

	# Card 7: "goes: 'Wait...'" (1.49s) — Realization hits! Anticipation recoil step back
	cam_punch(Vector2(0, -20), 1.35, 0.12)
	cam_shake(5.0, 0.2)
	nemi.position = Vector2(438.0, 484.0)
	nemi.set_pose("recoiling", 0.12)
	nemi.set_expression("shock")
	nemi.look("center")
	doodle_director.spawn_idea_spark(Vector2(438.0, 230.0)).auto_dismiss(2.5)
	play_sfx("ping", -5.0)
	await _run_card(cards[6])

	# Card 8: "This could actually be" (1.39s) - Excited forward spring!
	nemi.position = Vector2(465.0, 478.0)
	nemi.set_pose("excited", 0.2)
	nemi.set_expression("laugh")
	doodle_director.spawn_exclamation_spikes(Vector2(465.0, 210.0), INK_GOLD).auto_dismiss(2.0)
	await _run_card(cards[7])

	# Card 9: "a hilarious story!'" (1.49s) - Settle and celebrate
	cam_reset(0.3)
	nemi.position = Vector2(460.0, 480.0)
	nemi.set_pose("both_hands_explaining_asym", 0.2)
	nemi.set_expression("warm")
	doodle_director.spawn_check_mark(Vector2(700.0, 300.0), "COMEDY GOLD!", INK_MINT).auto_dismiss(2.5)
	await _run_card(cards[8])

	# Pause after beat (0.50s)
	nemi.stop_speech()
	await wait_seconds(0.50)
	end_beat()
