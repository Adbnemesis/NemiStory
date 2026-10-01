class_name Beat05AnimeMountain
extends "res://adb/episodes/ep00_intro/ADBEp00BaseBeat.gd"

## Beat 5: The Anime Obsession (52.04s -> 68.20s, duration 16.16s)
## "I've watched hundreds of anime." -> Absurd mountain of manga + "cultural research".
## High-density manga panels, sparkles, speech bubbles, and buster sword doodles.

func _ready() -> void:
	beat_number = 5
	beat_name = "Anime Mountain"
	super._ready()

	backdrop.set_mode(ADBIntroBackdropClass.EnvironmentMode.ANIME_REALM, 0.0)
	adb.position = Vector2(960, _base_adb_y)
	adb.set_pose("hand_near_face", 0.0)
	adb.set_expression("neutral", 0.0)

func start_beat() -> void:
	var tw := create_tween()

	# 0.0s: "And then... there's anime." (52.04s global)
	tw.tween_callback(func():
		cam_push(1.15, 2.0)
		adb.set_expression("neutral", 0.15)
		adb.start_speaking(10.0)
	)

	# 2.08s: End seg17
	tw.tween_interval(2.08)
	tw.tween_callback(func(): adb.stop_speaking())

	# 2.43s: "I've watched hundreds of anime." (54.47s global)
	tw.tween_interval(0.35)
	tw.tween_callback(func():
		cam_punch(1.10, false)
		play_sfx("camera_zoom")
		adb.set_pose("relaxed_standing", 0.20)
		adb.set_expression("deadpan", 0.15)
		adb.start_speaking(10.5)
		spawn_speech_bubble(Vector2(680, 400), "HUNDREDS OF ANIME?!", INK_PURPLE, true).auto_dismiss(2.2)
	)

	# 4.67s: End seg18 -> Reveal Absurd Manga Mountain & "this is normal"
	tw.tween_interval(2.24)
	tw.tween_callback(func():
		adb.stop_speaking()
		cam_reset(0.2)
		play_sfx("pop")
		doodles.spawn_anime_mountain(adb.position)
		spawn_handwritten_note("THIS IS NORMAL", Vector2(700, 360), 28, INK_RED, -4.0, true).auto_dismiss(3.5)
		spawn_sparkles(Vector2(960, 480), 4).auto_dismiss(2.5)
	)

	# 5.12s: "Action, shonen, slice of life, psychological thrillers..." (57.16s global)
	tw.tween_interval(0.45)
	tw.tween_callback(func():
		adb.set_pose("explaining", 0.22)
		adb.set_expression("excited", 0.15)
		adb.start_speaking(12.0)
		spawn_action_burst(Vector2(1200, 420), "PEAK FICTION!", INK_GOLD).auto_dismiss(3.2)
	)

	# 9.12s: End seg19
	tw.tween_interval(4.00)
	tw.tween_callback(func(): adb.stop_speaking())

	# 9.42s: "My friends say it's an obsession. I call it... thorough cultural research." (61.46s global)
	tw.tween_interval(0.30)
	tw.tween_callback(func():
		cam_punch(1.12, false)
		adb.set_pose("smug_point", 0.22)
		adb.set_expression("smug", 0.18)
		adb.start_speaking(11.0)
		play_sfx("anime_wow")
		spawn_speech_bubble(Vector2(680, 400), "CULTURAL RESEARCH!", INK_BLUE, true).auto_dismiss(5.5)
	)

	# 15.66s: Climax hold
	tw.tween_interval(6.24)
	tw.tween_callback(func():
		adb.stop_speaking()
		adb.set_mouth("smirk")
		cam_reset(0.3)
	)

	# 16.16s: Finish beat
	tw.tween_interval(0.50)
	tw.tween_callback(finish_beat)
