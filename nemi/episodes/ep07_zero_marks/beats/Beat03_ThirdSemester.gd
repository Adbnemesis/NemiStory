extends "res://nemi/episodes/ep07_zero_marks/Ep07BaseBeat.gd"

## Beat 03: Third Semester & The Absurd Contradiction (17.82s – 27.52s)
## Segments:
## - seg06_third_semester (17.82s – 21.50s, pause 0.30s)
## - seg07_which_was_great (21.80s – 22.52s, pause 0.40s)
## - seg08_except_somehow (22.92s – 26.92s, pause 0.60s)

func _ready() -> void:
	beat_number = 3
	beat_name = "Third Semester"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg06_third_semester.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.WIDE, 0.0)
	transition_backdrop(MODE_COLLEGE_HALLWAY, 0.35)

	# Staging: Nemi arrives at physical campus
	var backpack = spawn_prop("backpack", Vector2(710.0, 520.0))

	nemi.reset()
	nemi.position = Vector2(580.0, 480.0)
	nemi.set_pose("cheerful_wave", 0.0)
	nemi.set_expression("happy")
	nemi.look("center")

	var cards = Episode07SubtitlesClass.get_cards_for_beat(3)
	var t: float = 17.82

	# Card 0: "Then in third semester," (17.820 - 19.292)
	nemi.set_pose("energetic_explaining", 0.2)
	nemi.head_tilt(3.0, 0.2)
	t = await play_card_sync(cards[0], t)

	# Card 1: "we finally went" (19.292 - 20.396) - Step forward
	nemi.position = Vector2(600.0, 480.0)
	nemi.set_pose("casual_lean_left", 0.18)
	t = await play_card_sync(cards[1], t)

	# Card 2: "to college." (20.396 - 21.500) - Joyful open posture
	nemi.set_pose("celebrating", 0.2)
	nemi.set_expression("smile")
	doodle_director.spawn_speech_bubble(Vector2(850.0, 220.0), "REAL CAMPUS!", INK_MINT).auto_dismiss(2.2)
	play_sfx("anime-wow", -6.0)
	t = await play_card_sync(cards[2], t)

	# Pause (21.50s - 21.80s)
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg07_which_was_great.wav")
		voice_player.play(0.0)

	# Card 3: "Which was great." (21.800 - 22.520) - Content nod
	nemi.set_pose("hands_on_hips", 0.15)
	nemi.set_expression("warm")
	nemi.head_tilt(-2.0, 0.15)
	t = await play_card_sync(cards[3], t)

	# Pause (22.52s - 22.92s) - Comedic turn begins: suspicion creeps in
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg08_except_somehow.wav")
		voice_player.play(0.0)

	nemi.set_pose("hand_behind_head_sheepish", 0.2)
	nemi.set_expression("confused")
	nemi.look("up_left")

	# Card 4: "Except somehow..." (22.920 - 24.320)
	t = await play_card_sync(cards[4], t)

	# Card 5: "the exams were" (24.320 - 25.440) - Floating online laptop returns comically
	nemi.set_pose("one_hand_explaining", 0.2)
	doodle_director.draw_online_laptop(Vector2(280.0, 280.0), 0.35).auto_dismiss(3.0)
	t = await play_card_sync(cards[5], t)

	# Card 6: "STILL online." (25.440 - 26.920) - Full baffled recoil & punch
	cam_punch(Vector2(0, -10), 1.25, 0.15)
	nemi.set_pose("arms_crossed_skeptical", 0.18)
	nemi.set_expression("baffled")
	nemi.look("center")
	doodle_director.spawn_speech_bubble(Vector2(850.0, 260.0), "STILL ONLINE?!", INK_RED).auto_dismiss(2.0)
	play_sfx("bruh", -4.0)
	t = await play_card_sync(cards[6], t)

	# Hold into Beat 04 (26.92s - 27.52s)
	await finish_beat_sync(t, 27.52)
