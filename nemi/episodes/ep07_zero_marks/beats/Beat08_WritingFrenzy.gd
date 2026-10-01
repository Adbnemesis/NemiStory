extends "res://nemi/episodes/ep07_zero_marks/Ep07BaseBeat.gd"

## Beat 08: The Desperate Writing Frenzy (87.67s – 102.86s)
## Segments:
## - seg24_pretty_good_student (87.67s – 92.95s, pause 0.35s)
## - seg25_leave_unanswered (93.30s – 94.82s, pause 0.45s)
## - seg26_wrote_for_every (95.27s – 97.43s, pause 0.35s)
## - seg27_every_single_question (97.78s – 102.26s, pause 0.60s)

var desk_prop: Node2D
var chair_prop: Node2D
var paper_prop: Node2D
var pen_prop: Node2D

func _ready() -> void:
	beat_number = 8
	beat_name = "Writing Frenzy"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg24_pretty_good_student.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_EXAM_HALL, 0.0)

	# Seated Exam Desk Staging
	chair_prop = spawn_prop("chair", Vector2(640.0, 430.0), bg_props_layer)
	desk_prop = spawn_prop("desk", Vector2(640.0, 440.0), fg_props_layer)
	paper_prop = spawn_prop("paper_sheet", Vector2(640.0, 410.0), fg_props_layer)

	nemi.reset()
	nemi.position = Vector2(640.0, 430.0)
	nemi.set_pose("seated_writing_exam", 0.0)
	nemi.set_expression("candid")
	nemi.look("center")

	var cards = Episode07SubtitlesClass.get_cards_for_beat(8)
	var t: float = 87.67

	# Card 0: "But I've always been" (87.670 - 89.043) - Spine straightens, sudden pride
	nemi.head_tilt(-2.0, 0.2)
	t = await play_card_sync(cards[0], t)

	# Card 1: "a pretty good student," (89.043 - 90.521) - Determined focus
	nemi.set_expression("warm")
	t = await play_card_sync(cards[1], t)

	# Card 2: "so there was ONE thing" (90.521 - 91.894) - Hand reaches for pen
	nemi.set_expression("determined")
	pen_prop = spawn_prop("pen", Vector2(680.0, 415.0), fg_props_layer)
	t = await play_card_sync(cards[2], t)

	# Card 3: "I refused to do." (91.894 - 92.950) - Fierce resolve
	cam_punch(Vector2(0, 10), 1.18, 0.15)
	t = await play_card_sync(cards[3], t)

	# Pause (92.95s - 93.30s) - Transition into frenzy mode
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg25_leave_unanswered.wav")
		voice_player.play(0.0)

	transition_backdrop(MODE_WRITING_FRENZY, 0.25)
	nemi.set_pose("panicked_writing", 0.15)
	play_sfx("whoosh", -4.0)

	# Card 4: "Leave anything unanswered." (93.300 - 94.820) - Furious writing begins
	doodle_director.spawn_speech_bubble(Vector2(880.0, 240.0), "WRITE SOMETHING!!", INK_GOLD).auto_dismiss(3.0)
	play_sfx("typing", -5.0)
	t = await play_card_sync(cards[4], t)

	# Pause (94.82s - 95.27s)
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg26_wrote_for_every.wav")
		voice_player.play(0.0)

	# Card 5: "So I wrote something" (95.270 - 96.393) - Head bobbing with each stroke
	nemi.head_tilt(3.0, 0.1)
	t = await play_card_sync(cards[5], t)

	# Card 6: "for every question." (96.393 - 97.430)
	nemi.head_tilt(-3.0, 0.1)
	t = await play_card_sync(cards[6], t)

	# Pause (97.43s - 97.78s) - Building to the 3-hit punch
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg27_every_single_question.wav")
		voice_player.play(0.0)

	# Card 7: "Every." (97.780 - 99.258) - Punch 1
	cam_punch(Vector2(0, 15), 1.20, 0.12)
	play_sfx("pop", -2.0)
	doodle_director.spawn_speech_bubble(Vector2(320.0, 180.0), "EVERY.", INK_MAIN).auto_dismiss(2.2)
	t = await play_card_sync(cards[7], t)

	# Card 8: "Single." (99.258 - 100.737) - Punch 2
	cam_punch(Vector2(0, 20), 1.25, 0.12)
	play_sfx("pop", -1.5, 1.1)
	doodle_director.spawn_speech_bubble(Vector2(880.0, 180.0), "SINGLE.", INK_MAIN).auto_dismiss(2.2)
	t = await play_card_sync(cards[8], t)

	# Card 9: "Question." (100.737 - 102.260) - Punch 3 hard close
	cam_punch(Vector2(0, 25), 1.30, 0.12)
	play_sfx("error", -3.0)
	doodle_director.spawn_speech_bubble(Vector2(640.0, 140.0), "QUESTION!!", INK_RED).auto_dismiss(2.2)
	t = await play_card_sync(cards[9], t)

	# Hold into Beat 09 (102.26s - 102.86s)
	await finish_beat_sync(t, 102.86)
