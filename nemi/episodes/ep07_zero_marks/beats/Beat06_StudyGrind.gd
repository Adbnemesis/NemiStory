extends "res://nemi/episodes/ep07_zero_marks/Ep07BaseBeat.gd"

## Beat 06: The 2 AM Hardcore Study Montage (56.60s – 72.93s)
## Segments:
## - seg16_hardworking_class (56.60s – 60.60s, pause 0.35s)
## - seg17_studied_every_day (60.95s – 64.15s, pause 0.50s)
## - seg18_books_notes_everywhere (64.65s – 69.53s, pause 0.35s)
## - seg19_fighting_for_lives (69.88s – 72.28s, pause 0.65s)

var desk_prop: Node2D
var lamp_prop: Node2D
var notebook_prop: Node2D

func _ready() -> void:
	beat_number = 6
	beat_name = "Study Grind"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg16_hardworking_class.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.WIDE, 0.0)
	transition_backdrop(MODE_MIDNIGHT_STUDY, 0.4)

	# Staging: Late night study desk setup
	desk_prop = spawn_prop("desk", Vector2(360.0, 485.0))
	lamp_prop = spawn_prop("lamp", Vector2(250.0, 435.0))
	notebook_prop = spawn_prop("notebook", Vector2(380.0, 460.0))

	nemi.reset()
	nemi.position = Vector2(580.0, 480.0)
	nemi.set_pose("relaxed_standing", 0.0)
	nemi.set_expression("candid")
	nemi.look("center")

	var cards = Episode07SubtitlesClass.get_cards_for_beat(6)
	var t: float = 56.60

	# Card 0: "Suddenly the entire class" (56.600 - 58.520)
	nemi.set_pose("one_hand_explaining", 0.2)
	nemi.head_tilt(-2.0, 0.2)
	t = await play_card_sync(cards[0], t)

	# Card 1: "became extremely hardworking." (58.520 - 60.600) - Ironic smile
	nemi.set_pose("casual_hand_on_hip", 0.2)
	nemi.set_expression("smug")
	nemi.head_tilt(3.0, 0.2)
	t = await play_card_sync(cards[1], t)

	# Pause (60.60s - 60.95s) - Transition into exhaustion
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg17_studied_every_day.wav")
		voice_player.play(0.0)

	nemi.set_pose("defeated_slump", 0.25)
	nemi.set_expression("tired")

	# Card 2: "We studied every day." (60.950 - 62.614)
	t = await play_card_sync(cards[2], t)

	# Card 3: "Until 2 AM." (62.614 - 64.150) - 2 AM Clock visual payoff with ticking SFX
	cam_punch(Vector2(0, -10), 1.25, 0.15)
	doodle_director.draw_clock_2am(Vector2(640.0, 220.0), 0.35).auto_dismiss(5.5)
	play_sfx("clock-ticking", -4.0)
	nemi.set_expression("exhausted")
	nemi.head_tilt(4.0, 0.2)
	t = await play_card_sync(cards[3], t)

	# Pause (64.15s - 64.65s)
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg18_books_notes_everywhere.wav")
		voice_player.play(0.0)

	# Card 4: "Books everywhere." (64.650 - 65.821) - Props appearing
	doodle_director.spawn_speech_bubble(Vector2(320.0, 260.0), "BOOKS", INK_MAIN).auto_dismiss(2.2)
	play_sfx("pop", -3.0)
	t = await play_card_sync(cards[4], t)

	# Card 5: "Notes everywhere." (65.821 - 66.992)
	doodle_director.spawn_speech_bubble(Vector2(880.0, 260.0), "NOTES", INK_MAIN).auto_dismiss(2.2)
	play_sfx("pop", -2.5, 1.1)
	t = await play_card_sync(cards[5], t)

	# Card 6: "People asking each other" (66.992 - 68.652) - Frantic questioning
	nemi.set_pose("hands_on_head_panic", 0.2)
	nemi.set_expression("panic")
	t = await play_card_sync(cards[6], t)

	# Card 7: "questions." (68.652 - 69.530)
	nemi.head_tilt(-3.0, 0.15)
	t = await play_card_sync(cards[7], t)

	# Pause (69.53s - 69.88s)
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg19_fighting_for_lives.wav")
		voice_player.play(0.0)

	# Card 8: "We were fighting" (69.880 - 71.032) - Desperate battle posture
	nemi.set_pose("arms_crossed_skeptical", 0.2)
	nemi.set_expression("shock")
	cam_punch(Vector2(10, -5), 1.28, 0.15)
	t = await play_card_sync(cards[8], t)

	# Card 9: "for our lives." (71.032 - 72.280) - Comedic melodrama & sweat drop
	doodle_director.spawn_speech_bubble(Vector2(850.0, 320.0), "SURVIVAL MODE", INK_RED).auto_dismiss(2.0)
	play_sfx("bruh", -5.0)
	t = await play_card_sync(cards[9], t)

	# Hold into Beat 07 (72.28s - 72.93s)
	await finish_beat_sync(t, 72.93)
