extends "res://nemi/episodes/ep06_how_i_animate/Ep06BaseBeat.gd"

## Beat 06: Why Beats Matter & The Deadpan Punchline (66.44s – 81.46s)
## Segments:
## - seg11_why_beats_matter_explain (7.07s)
## - seg12_why_beats_matter_joke (7.45s)

func _ready() -> void:
	beat_number = 6
	beat_name = "Why Beats Matter"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep06_how_i_animate/audio/segments/seg11_why_beats_matter_explain.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_WHY_BEATS_MATTER, 0.3)

	# Start on Left (Explanatory side)
	nemi.reset()
	nemi.position = Vector2(420.0, 480.0)
	nemi.set_pose("one_hand_explaining", 0.0)
	nemi.set_expression("candid")
	nemi.look("center")

	var cards = Episode06SubtitlesClass.get_cards_for_beat(6)

	# Card 1: "Because animation has to" (1.78s)
	nemi.position = Vector2(425.0, 480.0)
	nemi.set_pose("one_hand_explaining", 0.22)
	doodle_director.spawn_speech_bubble(Vector2(240.0, 250.0), "STORY FIRST", INK_MINT).auto_dismiss(3.0)
	await _run_card(cards[0])

	# Card 2: "follow the storytelling." (1.78s) - Underline under doodle label, NOT on Nemi's body
	nemi.set_pose("both_hands_explaining_asym", 0.2)
	nemi.head_tilt(-3.0, 0.2)
	doodle_director.spawn_underline(Vector2(240.0, 300.0), 140.0, INK_MINT).auto_dismiss(2.5)
	await _run_card(cards[1])

	# Card 3: "This is where I'm" (1.78s) - Lean left
	nemi.position = Vector2(412.0, 482.0)
	nemi.set_pose("casual_lean_left", 0.2)
	await _run_card(cards[2])

	# Card 4: "explaining something." (1.73s) - Presenting to left open space
	nemi.position = Vector2(420.0, 480.0)
	nemi.set_pose("presenting_prop", 0.2)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.set_expression("smile")
	doodle_director.spawn_arrow_with_label(Vector2(350.0, 360.0), Vector2(200.0, 260.0), "EXPLAIN", INK_MAIN).auto_dismiss(2.0)
	await _run_card(cards[3])

	# Pause between seg11 and seg12 (0.45s) — Snap to Right Side!
	nemi.stop_speech()
	nemi.position = Vector2(840.0, 480.0)
	await wait_seconds(0.45)

	# Card 5: "And this... is where" (1.86s) — Sudden Comedic Snap
	cam_punch(Vector2(200, -15), 1.35, 0.08)
	cam_shake(4.0, 0.15)
	nemi.set_pose("arms_crossed_skeptical", 0.08)
	nemi.set_expression("deadpan")
	nemi.look("center")
	doodle_director.spawn_deadpan_sweat(Vector2(840.0, 260.0)).auto_dismiss(3.5)
	await _run_card(cards[4])

	# Card 6: "the joke lands." (1.86s) — Freeze with punchline stamp in clear mid space
	doodle_director.spawn_handwritten_stamp(Vector2(650.0, 320.0), "PUNCHLINE", INK_RED).auto_dismiss(3.0)
	# ZERO MOTION. Absolute comedic hold.
	await _run_card(cards[5])

	# Card 7: "Hold it." (1.86s) — Hold the freeze
	await _run_card(cards[6])

	# Card 8: "Then move on." (1.87s) — Blink and recovery
	nemi.blink(0.12)
	cam_reset(0.3)
	nemi.set_pose("relaxed_standing_right_weight", 0.22)
	nemi.set_expression("smile")
	doodle_director.spawn_circle_callout(Vector2(650.0, 320.0), 50.0, INK_GOLD).auto_dismiss(1.8)
	await _run_card(cards[7])

	# Pause after beat (0.50s)
	nemi.stop_speech()
	await wait_seconds(0.50)
	end_beat()
