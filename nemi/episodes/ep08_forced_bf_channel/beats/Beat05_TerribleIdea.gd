extends "res://nemi/episodes/ep08_forced_bf_channel/Ep08BaseBeat.gd"

## Beat 05: The Terrible Idea (31.13s -> 38.34s | 7.21s, buffer to 38.81s)
## Segments:
## - seg11_terrible_idea: "And then I had another terrible idea."
## - seg12_why_doesnt_adb: "If I'm making storytime animations... why doesn't ADB make storytime animations too?"

func _ready() -> void:
	beat_number = 5
	beat_name = "The Terrible Idea"
	super._ready()

func _run_beat_choreography() -> void:
	# 1. Instant environment cut (ZERO delay)
	backdrop.set_mode(4, 0.0) # CONSPIRACY_SCHEME

	# 2. Characters positioned immediately
	nemi.position = Vector2(650, NEMI_BASE_Y)
	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("neutral")

	setup_new_adb(Vector2(1280, NEW_ADB_BASE_Y))
	new_adb.set_pose("relaxed_standing", 0.0)
	new_adb.set_expression("neutral", 0.0)
	new_adb.look("away")

	cam_reset(0.0)
	cam_pan(Vector2(960, 530), 0.0)

	var cards = Episode08SubtitlesClass.get_cards_for_beat(5)
	var t: float = 31.129
	await cue_card(cards[0])

	# Card 22: "And then I had" (31.129 - 31.993)
	nemi.set_pose("one_hand_explaining", 0.16)
	nemi.head_tilt(-2.0, 0.14)
	t = await play_card_sync(cards[0], t)
	await cue_card(cards[1])

	# Card 23: "another terrible idea." (31.993 - 32.929) - Idea lightbulb pops up!
	nemi.set_pose("presenting", 0.18)
	nemi.set_expression("smug")
	doodles.spawn_idea_lightbulb(Vector2(650, 400), doodles.INK_GOLD, 0.25).auto_dismiss(3.0)
	new_adb.set_expression("confused", 0.16)
	new_adb.head_tilt = -3.0
	t = await play_card_sync(cards[1], t)
	await cue_card(cards[2])

	# Card 24: "If I'm making" (33.349 - 34.547) - Nemi turns to ADB
	nemi.set_pose("both_hands_explaining_asym", 0.18)
	nemi.head_tilt(3.5, 0.16)
	t = await play_card_sync(cards[2], t)
	await cue_card(cards[3])

	# Card 25: "storytime animations..." (34.547 - 35.844)
	nemi.set_pose("lean_left", 0.18)
	t = await play_card_sync(cards[3], t)
	await cue_card(cards[4])

	# Card 26: "why doesn't ADB make" (35.844 - 37.142)
	nemi.set_pose("palms_up_what", 0.18)
	nemi.set_expression("excited")
	doodles.spawn_question_marks(Vector2(1280, 420), 2, 0.20).auto_dismiss(2.0)
	t = await play_card_sync(cards[4], t)
	await cue_card(cards[5])

	# Card 27: "storytime animations too?" (37.142 - 38.340)
	cam_punch(1.15, false, Vector2(1000, 520))
	new_adb.set_pose("weight_left", 0.18)
	new_adb.set_expression("annoyed", 0.16)
	new_adb.blink(0.12)
	t = await play_card_sync(cards[5], t)

	await finish_beat_sync(t, 38.808)
