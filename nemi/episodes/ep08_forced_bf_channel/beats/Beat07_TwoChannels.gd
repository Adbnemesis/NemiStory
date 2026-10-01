extends "res://nemi/episodes/ep08_forced_bf_channel/Ep08BaseBeat.gd"

## Beat 07: Two Channels (47.57s -> 61.33s | 13.75s, buffer to 61.84s)
## Segments:
## - seg18_and_now_both: "And now... there's Nemi... and there's ADB... both making storytime animations."
## - seg19_little_dangerous: "Which is honestly... a little dangerous."
## - seg20_annoy_each_other: "Because now we can annoy each other with animation too."

func _ready() -> void:
	beat_number = 7
	beat_name = "Two Channels"
	super._ready()

func _run_beat_choreography() -> void:
	# 1. Instant environment cut (ZERO delay)
	backdrop.set_mode(6, 0.0) # DUAL_STUDIO_SPLIT

	# 2. Characters positioned immediately
	nemi.position = Vector2(650, NEMI_BASE_Y)
	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("warm_smile")

	setup_new_adb(Vector2(1270, NEW_ADB_BASE_Y))
	new_adb.set_pose("relaxed_standing", 0.0)
	new_adb.set_expression("neutral", 0.0)
	new_adb.look("camera")

	cam_reset(0.0)
	cam_pan(Vector2(960, 530), 0.0)

	var cards = Episode08SubtitlesClass.get_cards_for_beat(7)
	var t: float = 47.571

	# Card 34: "And now..." (47.571 - 48.825)
	nemi.set_pose("one_hand_explaining", 0.16)
	t = await play_card_sync(cards[0], t)

	# Card 35: "there's Nemi..." (48.825 - 50.330) - Nemi gestures to herself
	nemi.set_pose("hand_on_chest", 0.18)
	nemi.set_expression("happy")
	t = await play_card_sync(cards[1], t)

	# Card 36: "and there's ADB..." (50.330 - 51.960) - Nemi presents ADB
	nemi.set_pose("confident_presentation", 0.18)
	nemi.head_tilt(3.0, 0.15)
	new_adb.set_pose("casual_contrapposto", 0.18)
	new_adb.set_expression("smug", 0.14)
	t = await play_card_sync(cards[2], t)

	# Card 37: "both making storytime animations." (51.960 - 53.841) - Dual channel badges appear!
	play_sfx("pop", -2.5)
	doodles.spawn_dual_channel_badges(Vector2(960, 390), 0.30).auto_dismiss(5.0)
	nemi.set_pose("both_hands_explaining_asym", 0.18)
	nemi.set_expression("excited")
	t = await play_card_sync(cards[3], t)

	# Card 38: "Which is honestly..." (54.261 - 55.996) - Conspiratorial shift
	nemi.set_pose("leaning_forward_confiding", 0.18)
	nemi.set_expression("candid")
	cam_punch(1.14, false, Vector2(960, 520))
	t = await play_card_sync(cards[4], t)

	# Card 39: "a little dangerous." (55.996 - 57.731) - Playful warning
	nemi.set_pose("one_hand_explaining", 0.18)
	nemi.set_expression("smug")
	new_adb.set_expression("amused", 0.16)
	new_adb.head_tilt = -3.0
	t = await play_card_sync(cards[5], t)

	# Card 40: "Because now we can" (58.111 - 59.267)
	nemi.set_pose("confident_presentation", 0.18)
	t = await play_card_sync(cards[6], t)

	# Card 41: "annoy each other with" (59.267 - 60.422) - Playful rivalry sparks doodle
	play_sfx("whoosh", -3.0)
	doodles.spawn_rivalry_sparks(Vector2(960, 480), 0.25).auto_dismiss(3.0)
	play_sfx("pop", -2.0)
	nemi.set_pose("both_hands_explaining_asym", 0.18)
	nemi.set_expression("excited")
	new_adb.set_pose("weight_left", 0.18)
	new_adb.set_expression("mischievous", 0.16)
	t = await play_card_sync(cards[7], t)

	# Card 42: "animation too." (60.422 - 61.325)
	t = await play_card_sync(cards[8], t)

	await finish_beat_sync(t, 61.835)
