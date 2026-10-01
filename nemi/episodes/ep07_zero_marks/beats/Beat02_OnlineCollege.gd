extends "res://nemi/episodes/ep07_zero_marks/Ep07BaseBeat.gd"

## Beat 02: Online College & Quarantine Shorthand (5.08s – 17.82s)
## Segments:
## - seg03_started_in_college (5.08s – 7.64s, pause 0.40s)
## - seg04_first_couple_online (8.04s – 11.48s, pause 0.35s)
## - seg05_classes_tests_assignments (11.83s – 17.27s, pause 0.55s)

var laptop_prop: Node2D
var desk_prop: Node2D

func _ready() -> void:
	beat_number = 2
	beat_name = "Online College"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg03_started_in_college.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.WIDE, 0.0)
	transition_backdrop(MODE_COVID_ONLINE, 0.35)

	# Staging: Desk on left, Nemi on right-center
	desk_prop = spawn_prop("desk", Vector2(240.0, 485.0))
	laptop_prop = spawn_prop("laptop", Vector2(240.0, 440.0))

	nemi.reset()
	nemi.position = Vector2(520.0, 480.0)
	nemi.set_pose("relaxed_standing_right_weight", 0.0)
	nemi.set_expression("candid")
	nemi.look("center")

	var cards = Episode07SubtitlesClass.get_cards_for_beat(2)
	var t: float = 5.08

	# Card 0: "It started back" (5.080 - 5.899)
	nemi.head_tilt(-2.0, 0.2)
	t = await play_card_sync(cards[0], t)

	# Card 1: "in college," (5.899 - 6.616)
	nemi.set_pose("thinking_chin_touch", 0.2)
	nemi.look("up_right")
	t = await play_card_sync(cards[1], t)

	# Card 2: "during COVID." (6.616 - 7.640) - Subtle sad/nostalgic smile
	nemi.set_expression("warm_smile")
	nemi.head_tilt(3.0, 0.2)
	doodle_director.draw_online_laptop(Vector2(240.0, 260.0), 0.4).auto_dismiss(8.5)
	t = await play_card_sync(cards[2], t)

	# Pause (7.64s - 8.04s)
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg04_first_couple_online.wav")
		voice_player.play(0.0)

	nemi.set_pose("one_hand_explaining", 0.2)
	nemi.look("center")

	# Card 3: "For the first couple" (8.040 - 9.210)
	t = await play_card_sync(cards[3], t)

	# Card 4: "of semesters," (9.210 - 10.104) - Two fingers gesture
	nemi.set_pose("casual_lean_left", 0.2)
	nemi.head_tilt(-3.0, 0.18)
	t = await play_card_sync(cards[4], t)

	# Card 5: "everything was online." (10.104 - 11.480) - Broad gesture toward laptop
	cam_punch(Vector2(-20, -5), 1.15, 0.2)
	nemi.set_pose("pointing_forward", 0.2)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.POINTING)
	play_sfx("whoosh", -5.0)
	t = await play_card_sync(cards[5], t)

	# Pause (11.48s - 11.83s) - Preparing the checklist
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg05_classes_tests_assignments.wav")
		voice_player.play(0.0)

	nemi.set_pose("both_hands_explaining_asym", 0.2)
	nemi.set_expression("candid")

	# Card 6: "Classes." (11.830 - 13.027) - First checklist item pops
	doodle_director.draw_checklist_step(Vector2(880.0, 210.0), "Classes.", 0.25).auto_dismiss(5.0)
	play_sfx("pop", -3.0)
	t = await play_card_sync(cards[6], t)

	# Card 7: "Tests." (13.027 - 14.224) - Second checklist item pops
	nemi.head_tilt(3.0, 0.18)
	doodle_director.draw_checklist_step(Vector2(880.0, 270.0), "Tests.", 0.25).auto_dismiss(4.0)
	play_sfx("pop", -2.0, 1.1)
	t = await play_card_sync(cards[7], t)

	# Card 8: "Assignments." (14.224 - 15.747) - Third checklist item pops
	nemi.set_pose("one_hand_explaining", 0.2)
	doodle_director.draw_checklist_step(Vector2(880.0, 330.0), "Assignments.", 0.25).auto_dismiss(3.0)
	play_sfx("pop", -2.0, 1.2)
	t = await play_card_sync(cards[8], t)

	# Card 9: "Everything." (15.747 - 17.270) - Deadpan wrapup & camera punch
	cam_punch(Vector2(10, -5), 1.25, 0.18)
	nemi.set_pose("arms_crossed_skeptical", 0.2)
	nemi.set_expression("deadpan")
	doodle_director.spawn_speech_bubble(Vector2(850.0, 410.0), "LITERALLY EVERYTHING", INK_GOLD).auto_dismiss(1.8)
	play_sfx("click", -3.0)
	t = await play_card_sync(cards[9], t)

	# Hold into Beat 03 (17.27s - 17.82s)
	await finish_beat_sync(t, 17.82)
