extends "res://nemi/episodes/ep08_forced_bf_channel/Ep08BaseBeat.gd"

## Beat 09: Nemi Takes Back Control & Outro (81.26s -> 94.73s | 13.46s, buffer to 95.41s)
## Segments:
## - seg27_suspiciously_normal: "Wow. That was suspiciously normal."
## - seg28_just_getting_started: "Anyway... ADB is just getting started. So go check out the channel."
## - seg29_worked_way_too_hard: "I worked way too hard to convince this person."
## - seg30_please_make_worth_it: "Please make it worth it."

func _ready() -> void:
	beat_number = 9
	beat_name = "Outro Takeover"
	super._ready()

func _run_beat_choreography() -> void:
	# 1. Instant environment cut (ZERO delay)
	backdrop.set_mode(8, 0.0) # CELEBRATION_WRAPUP

	# 2. Characters positioned immediately
	nemi.position = Vector2(620, NEMI_BASE_Y)
	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("neutral")

	setup_new_adb(Vector2(1240, NEW_ADB_BASE_Y))
	new_adb.set_pose("relaxed_standing", 0.0)
	new_adb.set_expression("neutral", 0.0)
	new_adb.look("camera")

	cam_reset(0.0)
	cam_pan(Vector2(960, 530), 0.0)

	var cards = Episode08SubtitlesClass.get_cards_for_beat(9)
	var t: float = 81.262
	await cue_card(cards[0])

	# Card 58: "Wow." (81.262 - 82.870) - Comedic interruption beat!
	cam_pan(Vector2(940, 520), 0.20)
	nemi.set_pose("shock_recoil", 0.15)
	nemi.set_expression("embarrassed")
	nemi.head_tilt(-3.5, 0.14)
	t = await play_card_sync(cards[0], t)
	await cue_card(cards[1])

	# Card 59: "That was" (82.870 - 84.371)
	nemi.set_pose("lean_left", 0.16)
	nemi.set_expression("deadpan")
	new_adb.set_pose("deadpan_freeze", 0.12)
	new_adb.set_expression("deadpan", 0.10)
	t = await play_card_sync(cards[1], t)
	await cue_card(cards[2])

	# Card 60: "suspiciously normal." (84.371 - 86.622) - ADB gives tiny deadpan shrug
	new_adb.set_pose("shrug_open", 0.26)
	new_adb.blink(0.12)
	t = await play_card_sync(cards[2], t)
	await cue_card(cards[3])

	nemi.set_pose("one_hand_explaining", 0.16)
	nemi.set_expression("warm")
	nemi.look("camera")
	cam_reset(0.25)
	t = await play_card_sync(cards[3], t)
	await cue_card(cards[4])

	# Card 62: "getting started." (88.334 - 89.265)
	nemi.set_pose("presenting", 0.16)
	t = await play_card_sync(cards[4], t)
	await cue_card(cards[5])

	# Card 63: "So go check out" (89.265 - 90.196)
	nemi.set_pose("both_hands_explaining_asym", 0.16)
	nemi.set_expression("excited")
	t = await play_card_sync(cards[5], t)
	await cue_card(cards[6])

	# Card 64: "the channel." (90.196 - 90.972)
	new_adb.set_pose("casual_contrapposto", 0.16)
	new_adb.set_expression("cute", 0.15)
	doodles.spawn_subscribe_bell_button(Vector2(960, 340), 0.28).auto_dismiss(1.2)
	doodles.spawn_confetti_burst(Vector2(960, 240), 0.30).auto_dismiss(1.0)
	t = await play_card_sync(cards[6], t)
	await cue_card(cards[7])

	# Card 65: "I worked way too" (91.392 - 92.360) - Nemi dramatic fatigue
	nemi.set_pose("defeated_slump", 0.18)
	nemi.set_expression("sad")
	t = await play_card_sync(cards[7], t)
	await cue_card(cards[8])

	# Card 66: "hard to convince" (92.360 - 93.005)
	nemi.head_tilt(-2.5, 0.15)
	t = await play_card_sync(cards[8], t)
	await cue_card(cards[9])

	# Card 67: "this person." (93.005 - 93.542) - Gestures dramatically toward ADB
	nemi.set_pose("pointing", 0.15)
	new_adb.set_expression("smug", 0.15)
	t = await play_card_sync(cards[9], t)
	await cue_card(cards[10])

	# Card 68: "Please make it worth it." (93.922 - 94.725) - Pleading deadpan humor to camera
	cam_punch(1.20, true, Vector2(900, 560))
	nemi.set_pose("nervous_hands_together", 0.16)
	nemi.set_expression("deadpan")
	t = await play_card_sync(cards[10], t)

	# Hold the closing frame until the original episode end.
	await finish_beat_sync(t, 95.405)
