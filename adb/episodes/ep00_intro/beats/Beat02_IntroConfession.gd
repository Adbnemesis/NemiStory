class_name Beat02IntroConfession
extends "res://adb/episodes/ep00_intro/ADBEp00BaseBeat.gd"

## Beat 2: First Intro & The Confession (5.57s -> 17.84s, duration 12.27s)
## "I'm 24... and apparently I have no idea what I'm doing."
## Packed with comic badges, speech bubbles, confusion swirls, and punchline bursts.

func _ready() -> void:
	beat_number = 2
	beat_name = "Intro Confession"
	super._ready()

	adb.position = Vector2(960, _base_adb_y)
	adb.set_pose("relaxed_standing", 0.0)
	adb.set_expression("neutral", 0.0)

func start_beat() -> void:
	var tw := create_tween()

	# 0.0s: "I'm 24..." (5.57s global)
	tw.tween_callback(func():
		adb.set_pose("weight_left", 0.22)
		adb.set_expression("neutral", 0.15)
		adb.start_speaking(11.0)
		spawn_handwritten_note("AGE: 24", Vector2(1180, 480), 26, INK_GOLD, 4.0, true).auto_dismiss(2.0)
		play_sfx("pop", -2.0)
	)

	# 2.45s: Pause before seg05
	tw.tween_interval(2.45)
	tw.tween_callback(func():
		adb.stop_speaking()
	)

	# 2.80s: "...and apparently, I'm making storytime animations now." (8.37s global)
	tw.tween_interval(0.35)
	tw.tween_callback(func():
		adb.set_pose("explaining", 0.25)
		adb.set_expression("smug", 0.20)
		adb.start_speaking(11.0)
		spawn_speech_bubble(Vector2(680, 450), "STORYTIME ANIMATION!", INK_BLUE, true).auto_dismiss(3.2)
		spawn_sparkles(Vector2(960, 480), 4).auto_dismiss(2.0)
		play_sfx("whoosh", -3.0)
	)

	# 6.45s: End of seg05 -> Comedic hold buffer
	tw.tween_interval(3.65)
	tw.tween_callback(func():
		adb.stop_speaking()
		adb.set_pose("relaxed_standing", 0.15)
		adb.set_expression("deadpan", 0.12)
		adb.look("camera")
	)

	# 6.85s: "Which is interesting..." (12.42s global)
	tw.tween_interval(0.40)
	tw.tween_callback(func():
		adb.set_pose("chin_rub", 0.22)
		adb.set_expression("confused", 0.15)
		adb.start_speaking(10.0)
		spawn_confusion_marks(Vector2(1060, 420)).auto_dismiss(2.2)
		play_sfx("pop", -4.0)
	)

	# 9.55s: End of seg06 -> Camera punch-in preparation
	tw.tween_interval(2.70)
	tw.tween_callback(func():
		adb.stop_speaking()
		cam_punch(1.12, false)
		play_sfx("camera_zoom")
	)

	# 9.90s: "...because I have absolutely no idea what I'm doing." (15.47s global)
	tw.tween_interval(0.35)
	tw.tween_callback(func():
		adb.set_pose("open_palms", 0.20)
		adb.set_expression("flustered", 0.15)
		adb.start_speaking(11.0)
		spawn_action_burst(Vector2(680, 450), "ZERO IDEA!", INK_RED).auto_dismiss(1.9)
		spawn_sweat_drops(adb.position + Vector2(0, -106), 2).auto_dismiss(1.8)
	)

	# 11.90s: Climax comedic hold with deadpan face
	tw.tween_interval(2.00)
	tw.tween_callback(func():
		adb.stop_speaking()
		adb.set_mouth("deadpan")
		adb.set_pose("deadpan_freeze", 0.10)
		play_sfx("bruh")
		spawn_handwritten_note("NO IDEA", Vector2(960, 720), 32, INK_RED, -3.0, true).auto_dismiss(0.3)
	)

	# 12.00s: Reset camera before next beat
	tw.tween_interval(0.10)
	tw.tween_callback(func():
		cam_reset(0.20)
	)

	# 12.27s: Beat finish
	tw.tween_interval(0.27)
	tw.tween_callback(finish_beat)
