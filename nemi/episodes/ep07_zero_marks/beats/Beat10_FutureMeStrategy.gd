extends "res://nemi/episodes/ep07_zero_marks/Ep07BaseBeat.gd"

## Beat 10: The Callback & "Future Me" Strategy Wrapup (122.55s – 136.89s)
## Segments:
## - seg33_stared_at_paper (122.55s – 123.91s, pause 0.60s)
## - seg34_after_studying_for_this (124.51s – 129.71s, pause 0.70s)
## - seg35_future_me_strategy (130.41s – 136.09s, pause 0.80s)

var paper_prop: Node2D

func _ready() -> void:
	beat_number = 10
	beat_name = "Future Me Strategy"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg33_stared_at_paper.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, 0.0)
	transition_backdrop(MODE_WARM_WRAPUP, 0.4)

	# Paper held in hand
	paper_prop = spawn_prop("paper_sheet", Vector2(450.0, 430.0), fg_props_layer)

	nemi.reset()
	nemi.position = Vector2(450.0, 465.0)
	nemi.set_pose("holding_sheet_front", 0.0)
	nemi.set_expression("deadpan")
	nemi.look("down_center")

	var cards = Episode07SubtitlesClass.get_cards_for_beat(10)
	var t: float = 122.55

	# Card 0: "I just stared" (122.550 - 123.230) - Pure deadpan gaze down
	t = await play_card_sync(cards[0], t)

	# Card 1: "at the paper." (123.230 - 123.910) - Slow head raise, direct eye contact
	nemi.look("center")
	nemi.head_tilt(2.0, 0.2)
	t = await play_card_sync(cards[1], t)

	# Pause (123.91s - 124.51s) - Let the deadpan stare breathe
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg34_after_studying_for_this.wav")
		voice_player.play(0.0)

	nemi.blink(0.14)

	# Card 2: "After studying until 2 AM." (124.510 - 127.890) - Visual callback: 2 AM clock
	doodle_director.draw_clock_2am(Vector2(260.0, 240.0), 0.35).auto_dismiss(5.0)
	nemi.set_pose("defeated_slump", 0.25)
	nemi.set_expression("tired")
	t = await play_card_sync(cards[2], t)

	# Card 3: "For this." (127.890 - 129.710) - Gesture at paper, camera punch
	cam_punch(Vector2(0, 10), 1.25, 0.15)
	nemi.set_expression("deadpan")
	play_sfx("bruh", -4.0)
	t = await play_card_sync(cards[3], t)

	# Pause (129.71s - 130.41s) - Reaching peace with the absurdity
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg35_future_me_strategy.wav")
		voice_player.play(0.0)

	nemi.set_pose("casual_hand_on_hip", 0.25)
	nemi.set_expression("candid")
	cam_reset(0.4)

	# Card 4: "Turns out..." (130.410 - 131.546)
	nemi.head_tilt(-2.0, 0.2)
	t = await play_card_sync(cards[4], t)

	# Card 5: "'future me" (131.546 - 132.568) - Future me annotation
	doodle_director.draw_future_me_annotation(Vector2(450.0, 200.0), 0.35).auto_dismiss(4.5)
	play_sfx("pop", -3.0)
	t = await play_card_sync(cards[5], t)

	# Card 6: "will figure it out'" (132.568 - 133.932)
	nemi.set_pose("thinking_chin_touch", 0.2)
	nemi.look("up_right")
	t = await play_card_sync(cards[6], t)

	# Card 7: "was not, in fact," (133.932 - 135.068)
	nemi.set_pose("one_hand_explaining", 0.2)
	nemi.look("center")
	t = await play_card_sync(cards[7], t)

	# Card 8: "a very good strategy." (135.068 - 136.090) - Gentle, self-aware smile
	nemi.set_pose("relaxed_standing", 0.25)
	nemi.set_expression("smile")
	nemi.head_tilt(3.0, 0.2)
	t = await play_card_sync(cards[8], t)

	# Final Peaceful Hold & Fadeout (136.09s - 136.89s)
	await finish_beat_sync(t, 136.89)
