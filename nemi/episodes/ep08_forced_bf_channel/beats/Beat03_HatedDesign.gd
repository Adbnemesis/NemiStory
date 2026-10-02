extends "res://nemi/episodes/ep08_forced_bf_channel/Ep08BaseBeat.gd"

## Beat 03: ADB Hated The Old Design (14.36s -> 20.43s | 6.07s, buffer to 21.11s)
## Segments:
## - seg06_adb_hated: "ADB hated this character."
## - seg07_understand_why: "Honestly... I kinda understand why."

func _ready() -> void:
	beat_number = 3
	beat_name = "Hated Design"
	super._ready()

func _run_beat_choreography() -> void:
	# 1. Instant environment cut (ZERO delay)
	backdrop.set_mode(2, 0.0) # CRITIQUE_BOARD

	# 2. Character positions
	nemi.position = Vector2(620, NEMI_BASE_Y)
	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("neutral")

	setup_old_adb(Vector2(1300, OLD_ADB_BASE_Y))
	old_adb.set_pose("cool_swagger")
	old_adb.set_expression("annoyed")

	cam_reset(0.0)
	cam_pan(Vector2(960, 530), 0.0)

	var cards = Episode08SubtitlesClass.get_cards_for_beat(3)
	var t: float = 14.359
	await cue_card(cards[0])

	# Card 10: "ADB hated" (14.359 - 15.385)
	nemi.set_pose("one_hand_explaining", 0.18)
	nemi.head_tilt(-2.5, 0.15)
	doodles.spawn_critique_notes(Vector2(1040, 360), 0.25).auto_dismiss(4.5)
	t = await play_card_sync(cards[0], t)
	await cue_card(cards[1])

	# Card 11: "this character." (15.385 - 16.639) - Big rubber stamp DISAPPROVED slams down!
	nemi.set_pose("both_hands_explaining_asym", 0.18)
	nemi.set_expression("deadpan")
	cam_shake(0.35, 4.0)
	doodles.spawn_rubber_stamp_rejected(Vector2(1300, 420), 0.15).auto_dismiss(4.0)
	doodles.spawn_crumpled_paper_ball(Vector2(1150, 830), 0.20).auto_dismiss(4.0)
	old_adb.blink(0.12)
	t = await play_card_sync(cards[1], t)
	await cue_card(cards[2])

	# Card 12: "Honestly..." (17.019 - 18.554) - Awkward silence setup
	nemi.set_pose("lean_left", 0.20)
	nemi.set_expression("nervous")
	nemi.look("camera")
	cam_punch(1.15, false, Vector2(880, 520))
	t = await play_card_sync(cards[2], t)
	await cue_card(cards[3])

	# Card 13: "I kinda understand why." (18.554 - 20.428) - Sheepish guilty admission
	nemi.set_pose("embarrassed_shrink", 0.20)
	nemi.set_expression("embarrassed")
	doodles.spawn_sweat_drop(Vector2(655, 395), 0.20).auto_dismiss(2.5)
	t = await play_card_sync(cards[3], t)

	# Comedic silence hold (20.43s -> 21.11s)
	await finish_beat_sync(t, 21.108)
