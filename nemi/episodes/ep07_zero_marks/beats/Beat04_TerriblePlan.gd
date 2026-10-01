extends "res://nemi/episodes/ep07_zero_marks/Ep07BaseBeat.gd"

## Beat 04: Disinterest, Procrastination & The Terrible Plan (27.52s – 46.33s)
## Segments:
## - seg09_one_subject (27.52s – 35.04s, pause 0.35s)
## - seg10_study_later (35.39s – 38.03s, pause 0.45s)
## - seg11_obviously_online (38.48s – 42.56s, pause 0.40s)
## - seg12_had_a_plan (42.96s – 45.68s, pause 0.65s)

var notebook_prop: Node2D

func _ready() -> void:
	beat_number = 4
	beat_name = "Terrible Plan"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg09_one_subject.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.WIDE, 0.0)
	transition_backdrop(MODE_PROCRASTINATION, 0.35)

	# Staging: A lonely textbook on a side table
	notebook_prop = spawn_prop("notebook", Vector2(400.0, 470.0))

	nemi.reset()
	nemi.position = Vector2(580.0, 480.0)
	nemi.set_pose("relaxed_standing", 0.0)
	nemi.set_expression("candid")
	nemi.look("center")

	var cards = Episode07SubtitlesClass.get_cards_for_beat(4)
	var t: float = 27.52

	# Card 0: "So when final exams" (27.520 - 29.325)
	nemi.set_pose("one_hand_explaining", 0.2)
	t = await play_card_sync(cards[0], t)

	# Card 1: "came around," (29.325 - 30.528)
	nemi.head_tilt(3.0, 0.2)
	t = await play_card_sync(cards[1], t)

	# Card 2: "there was one subject" (30.528 - 32.408) - Glance down at textbook with boredom
	nemi.set_pose("bored_slouch", 0.25)
	nemi.look("down_left")
	t = await play_card_sync(cards[2], t)

	# Card 3: "I really didn't" (32.408 - 33.762)
	nemi.head_tilt(-4.0, 0.2)
	t = await play_card_sync(cards[3], t)

	# Card 4: "care about." (33.762 - 35.040) - Casual, human shrug
	nemi.set_pose("casual_hand_on_hip", 0.2)
	nemi.set_expression("bored")
	nemi.look("center")
	t = await play_card_sync(cards[4], t)

	# Pause (35.04s - 35.39s) - Smug expression surfaces
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg10_study_later.wav")
		voice_player.play(0.0)

	nemi.set_pose("thinking_chin_touch", 0.15)
	nemi.set_expression("smug")

	# Card 5: "And I thought..." (35.390 - 36.446)
	t = await play_card_sync(cards[5], t)

	# Card 6: "'eh, I'll study later.'" (36.446 - 38.030) - Pushing textbook away, handwritten "later"
	nemi.set_pose("dismissive_wave", 0.2)
	doodle_director.draw_handwritten_later(Vector2(820.0, 240.0), 0.35).auto_dismiss(6.0)
	play_sfx("whoosh", -5.0)
	t = await play_card_sync(cards[6], t)

	# Pause (38.03s - 38.48s) - Overconfidence settles in
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg11_obviously_online.wav")
		voice_player.play(0.0)

	nemi.set_pose("hands_on_hips", 0.2)
	nemi.set_expression("confident")

	# Card 7: "Because obviously..." (38.480 - 39.908)
	nemi.head_tilt(3.0, 0.2)
	t = await play_card_sync(cards[7], t)

	# Card 8: "the exam was going" (39.908 - 41.336)
	nemi.set_pose("one_hand_explaining", 0.2)
	t = await play_card_sync(cards[8], t)

	# Card 9: "to be online." (41.336 - 42.560) - Confident nod to the audience
	nemi.look("center")
	t = await play_card_sync(cards[9], t)

	# Pause (42.56s - 42.96s) - Revealing the "plan"
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg12_had_a_plan.wav")
		voice_player.play(0.0)

	nemi.set_pose("presenting_prop", 0.2)
	nemi.set_expression("smile")

	# Card 10: "I had a plan." (42.960 - 44.102) - Tiny hand-drawn flowchart appears
	doodle_director.draw_terrible_plan(Vector2(320.0, 240.0), 0.35).auto_dismiss(3.5)
	play_sfx("pop", -3.0)
	t = await play_card_sync(cards[10], t)

	# Card 11: "It was a terrible plan." (44.102 - 45.680) - Camera punch & deadpan hold
	cam_punch(Vector2(15, -10), 1.25, 0.15)
	nemi.set_pose("defeated_slump", 0.2)
	nemi.set_expression("deadpan")
	nemi.look("center")
	play_sfx("bruh", -4.0)
	t = await play_card_sync(cards[11], t)

	# Hold into Beat 05 (45.68s - 46.33s)
	await finish_beat_sync(t, 46.33)
