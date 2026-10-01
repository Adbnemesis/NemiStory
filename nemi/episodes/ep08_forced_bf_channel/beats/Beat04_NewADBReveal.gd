extends "res://nemi/episodes/ep08_forced_bf_channel/Ep08BaseBeat.gd"

## Beat 04: Redesign & New ADB Reveal (21.11s -> 30.58s | 9.47s, buffer to 31.13s)
## Segments:
## - seg08_so_eventually: "So eventually we decided:"
## - seg09_okay_completely_new: "okay. We're making a completely new ADB."
## - seg10_unreasonable_amount: "And after an unreasonable amount of work... we finally made one."

var redesign_sketch: Node2D

func _ready() -> void:
	beat_number = 4
	beat_name = "New ADB Reveal"
	super._ready()

func _run_beat_choreography() -> void:
	# 1. Instant environment cut (ZERO delay)
	backdrop.set_mode(3, 0.0) # REDESIGN_WORKSHOP

	# 2. Characters positioned immediately
	nemi.position = Vector2(620, NEMI_BASE_Y)
	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("warm_smile")

	# Old ADB is initially present on right
	setup_old_adb(Vector2(1280, OLD_ADB_BASE_Y))
	old_adb.set_pose("cool_swagger")
	old_adb.set_expression("neutral")

	cam_reset(0.0)
	cam_pan(Vector2(960, 530), 0.0)

	var cards = Episode08SubtitlesClass.get_cards_for_beat(4)
	var t: float = 21.108

	# Card 14: "So eventually" (21.108 - 21.898)
	nemi.set_pose("one_hand_explaining", 0.16)
	nemi.head_tilt(2.0, 0.14)
	t = await play_card_sync(cards[0], t)

	# Card 15: "we decided:" (21.898 - 22.688)
	nemi.set_pose("leaning_forward_confiding", 0.16)
	t = await play_card_sync(cards[1], t)

	# Card 16: "okay." (22.928 - 23.861) - Decisive nod
	nemi.set_pose("confident_presentation", 0.16)
	nemi.set_expression("candid")
	t = await play_card_sync(cards[2], t)

	# Card 17: "We're making" (23.861 - 24.794) - Hand-drawn sketch sheet appears over Old ADB
	play_sfx("whoosh", -3.0)
	redesign_sketch = doodles.spawn_redesign_sketch_card(Vector2(1280, 520), INK_MAIN, 0.30)
	var fade_tw := create_tween()
	fade_tw.tween_property(old_adb, "modulate:a", 0.0, 0.35)
	t = await play_card_sync(cards[3], t)

	# Card 18: "a completely new ADB." (24.794 - 26.038)
	nemi.set_pose("both_hands_explaining_asym", 0.18)
	nemi.set_expression("excited")
	cam_punch(1.18, false, Vector2(1000, 520))
	t = await play_card_sync(cards[4], t)

	# Card 19: "And after an" (26.458 - 27.444)
	nemi.set_pose("casual_standing", 0.18)
	nemi.set_expression("candid")
	t = await play_card_sync(cards[5], t)

	# Card 20: "unreasonable amount of work..." (27.444 - 29.171) - Nemi sighs
	nemi.set_pose("slumped_defeat", 0.22)
	nemi.head_tilt(-3.0, 0.18)
	doodles.spawn_sweat_drop(Vector2(655, 420), 0.20).auto_dismiss(2.5)
	t = await play_card_sync(cards[6], t)

	# Card 21: "we finally made one." (29.171 - 30.578) - THE NEW ADB REVEAL!
	if redesign_sketch and is_instance_valid(redesign_sketch):
		var sk_tw := create_tween()
		sk_tw.tween_property(redesign_sketch, "position:y", 200.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		sk_tw.parallel().tween_property(redesign_sketch, "modulate:a", 0.0, 0.25)
		sk_tw.tween_callback(redesign_sketch.queue_free)

	setup_new_adb(Vector2(1420, NEW_ADB_BASE_Y))
	new_adb.set_pose("relaxed_standing", 0.0)
	new_adb.set_expression("neutral", 0.0)
	new_adb.look("camera")

	var adb_tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	adb_tw.tween_property(new_adb, "position:x", 1280.0, 0.35)
	play_sfx("whoosh", -3.5, 1.1)
	play_sfx("chime", -2.5)

	# Anime sparkles around New ADB
	doodles.spawn_sparkles(Vector2(1280, 480), 0.30).auto_dismiss(3.0)

	nemi.set_pose("confident_presentation", 0.18)
	nemi.set_expression("warm_smile")
	nemi.look("center")
	cam_pan(Vector2(980, 520), 0.30)

	t = await play_card_sync(cards[7], t)

	new_adb.set_expression("cute", 0.18)
	new_adb.blink(0.12)

	await finish_beat_sync(t, 31.129)
