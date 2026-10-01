extends "res://nemi/episodes/ep08_forced_bf_channel/Ep08BaseBeat.gd"

## Beat 08: Hand The Mic To ADB (61.84s -> 80.61s | 18.78s, buffer to 81.26s)
## Segments:
## - seg21_introduce_yourself (Nemi: sohee): "Actually... ADB. Introduce yourself."
## - seg22_adb_uh_im_adb (ADB: aiden): "Uh... I'm ADB."
## - seg23_adb_make_animations (ADB: aiden): "I make storytime animations too."
## - seg24_adb_overshare (ADB: aiden): "I talk about my own experiences... and probably overshare way too much."
## - seg25_adb_check_channel (ADB: aiden): "So... if you're curious, check out my channel."
## - seg26_adb_link_description (ADB: aiden): "The link's in the description."

func _ready() -> void:
	beat_number = 8
	beat_name = "ADB Introduction"
	super._ready()

func _run_beat_choreography() -> void:
	# 1. Instant environment cut (ZERO delay)
	backdrop.set_mode(7, 0.0) # ADB_STAGE

	# 2. Characters positioned immediately
	nemi.position = Vector2(620, NEMI_BASE_Y)
	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("warm_smile")

	setup_new_adb(Vector2(1240, NEW_ADB_BASE_Y))
	new_adb.set_pose("relaxed_standing", 0.0)
	new_adb.set_expression("neutral", 0.0)
	new_adb.look("camera")

	cam_reset(0.0)
	cam_pan(Vector2(960, 530), 0.0)

	var cards = Episode08SubtitlesClass.get_cards_for_beat(8)
	var t: float = 61.835

	# Card 43: "Actually..." (61.835 - 62.989) - Nemi pauses, turns to ADB
	nemi.set_pose("one_hand_explaining", 0.16)
	nemi.head_tilt(3.5, 0.15)
	t = await play_card_sync(cards[0], t)

	# Card 44: "ADB." (62.989 - 64.142) - Direct call
	nemi.set_pose("confident_presentation", 0.16)
	new_adb.look("nemi")
	new_adb.head_tilt = -3.0
	t = await play_card_sync(cards[1], t)

	# Card 45: "Introduce yourself." (64.142 - 65.955) - Nemi holds out vintage mic & cue card!
	nemi.set_pose("open_hands_pleading", 0.18)
	nemi.set_expression("happy")
	doodles.spawn_cue_card(Vector2(730, 480), 0.22).auto_dismiss(3.0)
	doodles.spawn_vintage_microphone(Vector2(700, 620), Vector2(1240, 530), 0.30).auto_dismiss(15.0)
	t = await play_card_sync(cards[2], t)

	# Hand-off beat: camera reframes onto ADB
	cam_pan(Vector2(1080, 520), 0.30)
	cam_punch(1.18, false, Vector2(1080, 520))
	new_adb.look("camera")
	new_adb.set_pose("casual_contrapposto", 0.20)
	new_adb.set_expression("neutral", 0.15)
	nemi.set_pose("casual_standing", 0.22)
	nemi.set_expression("candid")

	# Card 46: "Uh..." (66.465 - 67.372) - ADB starts speaking with soundwaves
	new_adb.set_expression("amused", 0.15)
	doodles.spawn_audio_waves(Vector2(1240, 490), 0.25).auto_dismiss(2.5)
	t = await play_card_sync(cards[3], t)

	# Card 47: "I'm ADB." (67.372 - 68.625)
	new_adb.set_pose("relaxed_standing", 0.18)
	new_adb.blink(0.12)
	t = await play_card_sync(cards[4], t)

	# Card 48: "I make storytime" (69.025 - 69.947) - Natural hand gesture
	new_adb.set_pose("weight_left", 0.18)
	t = await play_card_sync(cards[5], t)

	# Card 49: "animations too." (69.947 - 70.945)
	t = await play_card_sync(cards[6], t)

	# Card 50: "I talk about my" (71.345 - 72.510) - Gesture toward self
	new_adb.set_pose("casual_lean", 0.20)
	new_adb.set_expression("neutral", 0.15)
	t = await play_card_sync(cards[7], t)

	# Card 51: "own experiences..." (72.510 - 73.508)
	t = await play_card_sync(cards[8], t)

	# Card 52: "and probably overshare" (73.508 - 74.548) - Dry comedic smirk
	new_adb.set_expression("smug", 0.16)
	new_adb.head_tilt = 3.0
	nemi.head_tilt(-2.0, 0.18)
	nemi.set_expression("smug")
	t = await play_card_sync(cards[9], t)

	# Card 53: "way too much." (74.548 - 75.505)
	t = await play_card_sync(cards[10], t)

	# Card 54: "So... if you're curious," (76.055 - 77.415) - Looks at camera directly
	new_adb.set_pose("relaxed_standing", 0.18)
	new_adb.set_expression("cute", 0.16)
	new_adb.look("camera")
	t = await play_card_sync(cards[11], t)

	# Card 55: "check out my channel." (77.415 - 78.775)
	t = await play_card_sync(cards[12], t)

	# Card 56: "The link's in" (79.175 - 79.866) - Gestures downward naturally
	new_adb.set_pose("pointing", 0.16)
	new_adb.step_foot(false, Vector2(10, 0), 0.0, 0.18)
	doodles.spawn_link_description_cue(Vector2(1240, 720), doodles.INK_MAIN, 0.28).auto_dismiss(4.5)
	play_sfx("pop", -2.5)
	t = await play_card_sync(cards[13], t)

	# Card 57: "the description." (79.866 - 80.612)
	t = await play_card_sync(cards[14], t)

	await finish_beat_sync(t, 81.262)
