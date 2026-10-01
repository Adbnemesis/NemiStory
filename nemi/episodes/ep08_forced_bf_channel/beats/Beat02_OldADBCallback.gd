extends "res://nemi/episodes/ep08_forced_bf_channel/Ep08BaseBeat.gd"

## Beat 02: Old ADB Callback (6.71s -> 13.89s | 7.18s, buffer to 14.36s)
## Segments:
## - seg03_guys_remember: "Guys... remember ADB?"
## - seg04_yeah_this_adb: "Yeah. THIS ADB."
## - seg05_yeah_this_version: "...yeah. This version."

func _ready() -> void:
	beat_number = 2
	beat_name = "Old ADB Callback"
	super._ready()

func _run_beat_choreography() -> void:
	# 1. Instant environment cut (ZERO delay)
	backdrop.set_mode(1, 0.0) # ARCHIVAL_MEMORY

	# 2. Characters positioned immediately
	nemi.position = Vector2(620, NEMI_BASE_Y)
	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("warm_smile")
	nemi.look("camera")

	# Old ADB on right stage (archival callback)
	setup_old_adb(Vector2(1300, OLD_ADB_BASE_Y))
	old_adb.set_pose("cool_swagger")
	old_adb.set_expression("neutral")

	cam_reset(0.0)
	cam_pan(Vector2(960, 530), 0.0)

	var cards = Episode08SubtitlesClass.get_cards_for_beat(2)
	var t: float = 6.707

	# Card 4: "Guys..." (6.707 - 7.683)
	nemi.set_pose("leaning_forward_confiding", 0.16)
	nemi.set_expression("happy")
	t = await play_card_sync(cards[0], t)

	# Card 5: "remember ADB?" (7.683 - 9.147) - Nemi gestures rightward toward Old ADB
	nemi.set_pose("one_hand_explaining", 0.18)
	nemi.head_tilt(3.2, 0.16)
	doodles.spawn_question_marks(Vector2(850, 370), 3, 0.22).auto_dismiss(2.0)
	t = await play_card_sync(cards[1], t)

	# Card 6: "Yeah." (9.487 - 10.335)
	nemi.set_pose("relaxed_standing", 0.15)
	nemi.look("center")
	t = await play_card_sync(cards[2], t)

	# Card 7: "THIS ADB." (10.335 - 11.607) - Strong reveal & arrow doodle!
	cam_punch(1.24, true, Vector2(1040, 520))
	play_sfx("whoosh", -2.5, 1.05)
	play_sfx("pop", -1.8)
	doodles.spawn_hand_drawn_arrow(Vector2(1060, 580), Vector2(1, -0.1)).auto_dismiss(3.0)
	doodles.spawn_comic_exclamation(Vector2(1300, 320), 0.18).auto_dismiss(2.2)
	old_adb.set_pose("cool_swagger")
	old_adb.set_expression("smug")
	old_adb.blink(0.12)
	t = await play_card_sync(cards[3], t)

	# Nemi side-glances at Old ADB
	nemi.set_pose("awkward_recoil", 0.16)
	nemi.set_expression("cringe")
	nemi.head_tilt(-3.5, 0.15)

	# Card 8: "...yeah." (12.027 - 12.808)
	doodles.spawn_sweat_drop(Vector2(655, 395), 0.20).auto_dismiss(1.8)
	t = await play_card_sync(cards[4], t)

	# Card 9: "This version." (12.808 - 13.891) - Rough circle doodle around Old ADB's chunky goggles
	doodles.spawn_rough_circle(Vector2(1300, 480), 90.0).auto_dismiss(2.5)
	play_sfx("pop", -3.0)
	t = await play_card_sync(cards[5], t)

	# Transition to Beat 3 (13.89s -> 14.36s)
	await finish_beat_sync(t, 14.359)
