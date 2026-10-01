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
	nemi.set_expression("candid")

	setup_new_adb(Vector2(1240, NEW_ADB_BASE_Y))
	new_adb.set_pose("relaxed_standing", 0.0)
	new_adb.set_expression("neutral", 0.0)
	new_adb.look("camera")

	cam_reset(0.0)
	cam_pan(Vector2(960, 530), 0.0)

	var cards = Episode08SubtitlesClass.get_cards_for_beat(9)
	var t: float = 81.262

	# Card 58: "Wow." (81.262 - 82.870) - Comedic interruption beat!
	print("[Beat09] Card 0 starting at t=", t)
	cam_pan(Vector2(940, 520), 0.20)
	nemi.set_pose("shocked_recoil", 0.15)
	nemi.set_expression("cringe")
	nemi.head_tilt(-3.5, 0.14)
	doodles.spawn_sweat_drop(Vector2(655, 395), 0.20).auto_dismiss(3.0)
	play_sfx("pop", -3.0)
	t = await play_card_sync(cards[0], t)
	print("[Beat09] Card 0 finished at t=", t)

	# Card 59: "That was" (82.870 - 84.371)
	print("[Beat09] Card 1 starting at t=", t)
	nemi.set_pose("leaning_forward_confiding", 0.16)
	nemi.set_expression("deadpan")
	new_adb.set_pose("deadpan_freeze", 0.12)
	new_adb.set_expression("deadpan", 0.10)
	t = await play_card_sync(cards[1], t)
	print("[Beat09] Card 1 finished at t=", t)

	# Card 60: "suspiciously normal." (84.371 - 86.622) - ADB gives tiny deadpan shrug
	print("[Beat09] Card 2 starting at t=", t)
	new_adb.set_pose("shrug_open", 0.16)
	new_adb.blink(0.12)
	t = await play_card_sync(cards[2], t)
	print("[Beat09] Card 2 finished at t=", t)

	print("[Beat09] Step 1: set_pose")
	nemi.set_pose("one_hand_explaining", 0.16)
	print("[Beat09] Step 2: set_expression")
	nemi.set_expression("warm_smile")
	print("[Beat09] Step 3: look")
	nemi.look("camera")
	print("[Beat09] Step 4: cam_reset")
	cam_reset(0.25)
	print("[Beat09] Step 5: play_card_sync cards[3]")
	t = await play_card_sync(cards[3], t)
	print("[Beat09] Card 3 finished at t=", t)

	# Card 62: "getting started." (88.334 - 89.265)
	print("[Beat09] Card 4 starting at t=", t)
	nemi.set_pose("confident_presentation", 0.16)
	t = await play_card_sync(cards[4], t)
	print("[Beat09] Card 4 finished at t=", t)

	# Card 63: "So go check out" (89.265 - 90.196)
	print("[Beat09] Card 5 starting at t=", t)
	nemi.set_pose("both_hands_explaining_asym", 0.16)
	nemi.set_expression("excited")
	t = await play_card_sync(cards[5], t)
	print("[Beat09] Card 5 finished at t=", t)

	# Card 64: "the channel." (90.196 - 90.972)
	print("[Beat09] Card 6 starting at t=", t)
	new_adb.set_pose("casual_contrapposto", 0.16)
	new_adb.set_expression("cute", 0.15)
	doodles.spawn_subscribe_bell_button(Vector2(960, 390), 0.28).auto_dismiss(4.5)
	doodles.spawn_confetti_burst(Vector2(960, 320), 0.30).auto_dismiss(4.0)
	t = await play_card_sync(cards[6], t)
	print("[Beat09] Card 6 finished at t=", t)

	# Card 65: "I worked way too" (91.392 - 92.360) - Nemi dramatic fatigue
	print("[Beat09] Card 7 starting at t=", t)
	nemi.set_pose("slumped_defeat", 0.18)
	nemi.set_expression("tired")
	t = await play_card_sync(cards[7], t)
	print("[Beat09] Card 7 finished at t=", t)

	# Card 66: "hard to convince" (92.360 - 93.005)
	print("[Beat09] Card 8 starting at t=", t)
	nemi.head_tilt(-2.5, 0.15)
	t = await play_card_sync(cards[8], t)
	print("[Beat09] Card 8 finished at t=", t)

	# Card 67: "this person." (93.005 - 93.542) - Gestures dramatically toward ADB
	print("[Beat09] Card 9 starting at t=", t)
	nemi.set_pose("pointing", 0.15)
	new_adb.set_expression("smug", 0.15)
	t = await play_card_sync(cards[9], t)
	print("[Beat09] Card 9 finished at t=", t)

	# Card 68: "Please make it worth it." (93.922 - 94.725) - Pleading deadpan humor to camera
	print("[Beat09] Card 10 starting at t=", t)
	cam_punch(1.15, false, Vector2(920, 520))
	nemi.set_pose("pleading_hands", 0.16)
	nemi.set_expression("awkward_smile")
	doodles.spawn_link_description_cue(Vector2(960, 720), doodles.INK_MAIN, 0.28).auto_dismiss(4.5)
	t = await play_card_sync(cards[10], t)
	print("[Beat09] Card 10 finished at t=", t)

	# Hold warm closing frame until 95.41s
	await finish_beat_sync(t, 95.405)
