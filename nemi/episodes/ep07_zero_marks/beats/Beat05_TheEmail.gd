extends "res://nemi/episodes/ep07_zero_marks/Ep07BaseBeat.gd"

## Beat 05: The Shocking Email & Class Panic (46.33s – 56.60s)
## Segments:
## - seg13_one_week_before (46.33s – 50.97s, pause 0.50s)
## - seg14_not_online_anymore (51.47s – 54.59s, pause 0.45s)
## - seg15_everyone_panicked (55.04s – 56.00s, pause 0.60s)

var phone_prop: Node2D

func _ready() -> void:
	beat_number = 5
	beat_name = "The Email"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg13_one_week_before.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_NORMAL_STUDIO, 0.0)

	nemi.reset()
	nemi.position = Vector2(460.0, 470.0)
	nemi.set_pose("relaxed_standing", 0.0)
	nemi.set_expression("candid")
	nemi.look("center")

	var cards = Episode07SubtitlesClass.get_cards_for_beat(5)
	var t: float = 46.33

	# Card 0: "Then, one week" (46.330 - 47.722) - Foreshadowing tone
	nemi.set_pose("thinking_chin_touch", 0.2)
	nemi.head_tilt(-3.0, 0.2)
	t = await play_card_sync(cards[0], t)

	# Card 1: "before the finals..." (47.722 - 49.346) - Ominous suspense
	nemi.look("up_right")
	t = await play_card_sync(cards[1], t)

	# Card 2: "we got the email." (49.346 - 50.970) - Notification arrives with illustrated email note
	play_sfx("notification", -2.0)
	doodle_director.draw_email_reveal(Vector2(840.0, 240.0), 0.35).auto_dismiss(5.5)
	nemi.set_pose("phone_checking", 0.2)
	nemi.set_expression("shock")
	nemi.look("down_right")
	t = await play_card_sync(cards[2], t)

	# Pause (50.97s - 51.47s) - Sudden realization strikes
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg14_not_online_anymore.wav")
		voice_player.play(0.0)

	transition_backdrop(MODE_EMAIL_PANIC, 0.3)
	cam_punch(Vector2(0, -10), 1.2, 0.15)

	# Card 3: "The exams would NOT" (51.470 - 52.562) - Online gets crossed out
	doodle_director.draw_online_to_offline(Vector2(840.0, 240.0), 0.35).auto_dismiss(4.5)
	nemi.set_pose("shocked_recoil", 0.15)
	nemi.set_expression("horror")
	t = await play_card_sync(cards[3], t)

	# Card 4: "be online anymore." (52.562 - 53.592)
	nemi.head_tilt(3.0, 0.15)
	t = await play_card_sync(cards[4], t)

	# Card 5: "They'd be offline." (53.592 - 54.590) - Camera hard punch & horror
	cam_punch(Vector2(0, -5), 1.25, 0.12)
	play_sfx("error", -3.0)
	t = await play_card_sync(cards[5], t)

	# Pause (54.59s - 55.04s) - Chaos breaks loose
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg15_everyone_panicked.wav")
		voice_player.play(0.0)

	cam_shake(6.5, 0.5)

	# Card 6: "Everyone panicked." (55.040 - 56.000) - Dramatic full panic
	nemi.set_pose("hands_on_head_panic", 0.15)
	nemi.set_expression("panic")
	doodle_director.spawn_speech_bubble(Vector2(460.0, 220.0), "PANIC!!", INK_RED).auto_dismiss(1.8)
	t = await play_card_sync(cards[6], t)

	# Hold into Beat 06 (56.00s - 56.60s)
	await finish_beat_sync(t, 56.60)
