extends "res://nemi/episodes/ep08_forced_bf_channel/Ep08BaseBeat.gd"

## Beat 06: Asking ADB (38.81s -> 47.02s | 8.21s, buffer to 47.57s)
## Segments:
## - seg13_adb_said_no_1: "ADB said no."
## - seg14_asked_again_1: "I asked again."
## - seg15_adb_said_no_2: "ADB said no."
## - seg16_asked_again_2: "I asked again."
## - seg17_eventually_made_channel: "And eventually... ADB made a channel."

func _ready() -> void:
	beat_number = 6
	beat_name = "Asking ADB"
	super._ready()

func _run_beat_choreography() -> void:
	# 1. Instant environment cut (ZERO delay)
	backdrop.set_mode(5, 0.0) # LIVING_ROOM

	# 2. Characters positioned immediately
	nemi.position = Vector2(650, NEMI_BASE_Y)
	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("candid")

	setup_new_adb(Vector2(1280, NEW_ADB_BASE_Y))
	new_adb.set_pose("relaxed_standing", 0.0)
	new_adb.set_expression("neutral", 0.0)
	new_adb.look("nemi")

	cam_reset(0.0)
	cam_pan(Vector2(960, 530), 0.0)

	var cards = Episode08SubtitlesClass.get_cards_for_beat(6)
	var t: float = 38.808

	# 1st "ADB said no." (38.808 - 39.838) - Rhythmic snap to ADB
	cam_pan(Vector2(1100, 520), 0.15)
	cam_punch(1.15, true, Vector2(1100, 520))
	new_adb.set_pose("weight_left", 0.14)
	new_adb.set_expression("deadpan", 0.12)
	new_adb.head_tilt = -4.0
	play_sfx("pop", -2.5)
	doodles.spawn_handwritten_no(Vector2(1150, 430), 0.85).auto_dismiss(2.0)
	nemi.set_pose("one_hand_explaining", 0.15)
	nemi.set_expression("deadpan")
	t = await play_card_sync(cards[0], t)

	# 1st "I asked again." (40.178 - 41.018) - Snap to Nemi leaning in
	cam_pan(Vector2(780, 520), 0.15)
	var n_tw := create_tween()
	n_tw.tween_property(nemi, "position:x", 740.0, 0.18)
	nemi.set_pose("open_hands_pleading", 0.16)
	nemi.set_expression("happy")
	t = await play_card_sync(cards[1], t)

	# 2nd "ADB said no." (41.358 - 42.468) - Snap to ADB crossed arms & BRICK WALL
	cam_pan(Vector2(1120, 520), 0.15)
	new_adb.set_pose("crossed_arms", 0.14)
	new_adb.set_expression("annoyed", 0.12)
	new_adb.head_tilt = 3.0
	play_sfx("pop", -1.5, 0.75)
	doodles.spawn_brick_wall_no(Vector2(1240, 440), 0.25).auto_dismiss(2.5)
	t = await play_card_sync(cards[2], t)

	# 2nd "I asked again." (42.808 - 43.898) - Snap back to Nemi pleading
	cam_pan(Vector2(780, 520), 0.15)
	nemi.set_pose("pleading_hands", 0.15)
	nemi.set_expression("excited")
	doodles.spawn_asked_again_note(Vector2(880, 460), doodles.INK_GOLD, 0.22).auto_dismiss(2.2)
	t = await play_card_sync(cards[3], t)

	# Silence pause: ADB relents, looks at Nemi
	cam_reset(0.20)
	new_adb.set_pose("shrug", 0.20)
	new_adb.set_expression("cute", 0.18)
	new_adb.blink(0.12)

	# Card 32: "And eventually..." (44.538 - 45.580)
	nemi.set_pose("confident_presentation", 0.16)
	nemi.set_expression("warm_smile")
	t = await play_card_sync(cards[4], t)

	# Card 33: "ADB made a channel." (45.580 - 47.019) - Confetti triumph!
	play_sfx("chime", -2.5)
	doodles.spawn_confetti_burst(Vector2(960, 450), 0.30).auto_dismiss(3.0)
	nemi.set_pose("triumphant_arms_up", 0.18)
	nemi.set_expression("excited")
	cam_punch(1.18, false, Vector2(960, 510))
	t = await play_card_sync(cards[5], t)

	await finish_beat_sync(t, 47.571)
