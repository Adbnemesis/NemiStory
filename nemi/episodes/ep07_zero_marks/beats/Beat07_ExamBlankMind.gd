extends "res://nemi/episodes/ep07_zero_marks/Ep07BaseBeat.gd"

## Beat 07: Exam Day & The Complete Blank Mind (72.93s – 87.67s)
## Segments:
## - seg20_exam_day (72.93s – 75.73s, pause 0.45s)
## - seg21_got_question_paper (76.18s – 79.06s, pause 0.80s)
## - seg22_nothing_absolutely (79.86s – 83.14s, pause 0.70s)
## - seg23_brain_left_building (83.84s – 87.12s, pause 0.55s)

var desk_prop: Node2D
var chair_prop: Node2D
var paper_prop: Node2D

func _ready() -> void:
	beat_number = 7
	beat_name = "Exam Blank Mind"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg20_exam_day.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.WIDE, 0.0)
	transition_backdrop(MODE_EXAM_HALL, 0.4)

	# Staging: Institutional Exam Hall Seating
	# Chair behind Nemi (z=-1)
	chair_prop = spawn_prop("chair", Vector2(640.0, 430.0), bg_props_layer)
	# Desk in foreground (z=15)
	desk_prop = spawn_prop("desk", Vector2(640.0, 440.0), fg_props_layer)
	# Exam paper on desk
	paper_prop = spawn_prop("paper_sheet", Vector2(640.0, 410.0), fg_props_layer)

	nemi.reset()
	nemi.position = Vector2(640.0, 430.0)
	nemi.set_pose("seated_writing_exam", 0.0)
	nemi.set_expression("candid")
	nemi.look("center")

	var cards = Episode07SubtitlesClass.get_cards_for_beat(7)
	var t: float = 72.93

	# Card 0: "And then..." (72.930 - 74.190) - Quiet dread
	nemi.head_tilt(-2.0, 0.2)
	t = await play_card_sync(cards[0], t)

	# Card 1: "exam day." (74.190 - 75.730)
	cam_punch(Vector2(0, -10), 1.15, 0.2)
	nemi.set_expression("deadpan")
	t = await play_card_sync(cards[1], t)

	# Pause (75.73s - 76.18s) - Paper slides onto the desk
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg21_got_question_paper.wav")
		voice_player.play(0.0)

	play_sfx("whoosh", -6.0)

	# Card 2: "I got the" (76.180 - 76.986)
	t = await play_card_sync(cards[2], t)

	# Card 3: "question paper." (76.986 - 77.966) - Hands rest on paper, looking down
	nemi.look("down_center")
	nemi.head_tilt(3.0, 0.2)
	t = await play_card_sync(cards[3], t)

	# Card 4: "I looked at it." (77.966 - 79.060) - Reading in intense silence
	t = await play_card_sync(cards[4], t)

	# 0.8s Intentional Comedic Silence (79.06s - 79.86s)
	# Nemi slowly raises head from paper and stares into the camera lens with a frozen blank face
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg22_nothing_absolutely.wav")
		voice_player.play(0.0)

	nemi.set_pose("exam_blank_stare", 0.3)
	nemi.set_expression("deadpan")
	nemi.look("center")
	cam_punch(Vector2(0, -5), 1.25, 0.2)

	# Card 5: "Nothing." (79.860 - 81.336) - Pure deadpan delivery
	t = await play_card_sync(cards[5], t)

	# Card 6: "Absolutely nothing." (81.336 - 83.140) - Slight blink, held stillness
	nemi.blink(0.12)
	t = await play_card_sync(cards[6], t)

	# Pause (83.14s - 83.84s) - Brain metaphor spawns
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg23_brain_left_building.wav")
		voice_player.play(0.0)

	# Card 7: "My brain had" (83.840 - 84.890) - Hand-drawn brain with little legs walking away
	doodle_director.draw_brain_leaving(Vector2(880.0, 240.0), 0.4).auto_dismiss(4.0)
	play_sfx("pop", -3.0)
	t = await play_card_sync(cards[7], t)

	# Card 8: "completely left" (84.890 - 86.005)
	nemi.head_tilt(-3.0, 0.2)
	t = await play_card_sync(cards[8], t)

	# Card 9: "the building." (86.005 - 87.120) - Helpless gaze tracking the brain
	nemi.look("up_right")
	t = await play_card_sync(cards[9], t)

	# Hold into Beat 08 (87.12s - 87.67s)
	await finish_beat_sync(t, 87.67)
