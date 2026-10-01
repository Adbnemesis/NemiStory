class_name Beat04SportsGames
extends "res://adb/episodes/ep00_intro/ADBEp00BaseBeat.gd"

## Beat 4: Sports & Games (37.68s -> 52.04s, duration 14.36s)
## Game controller prop, gaming doodles, 3:42 AM late-night clock, competitive ladder humor.

var controller: Node2D

func _ready() -> void:
	beat_number = 4
	beat_name = "Sports & Games"
	super._ready()

	backdrop.set_mode(ADBIntroBackdropClass.EnvironmentMode.GAMING_CORNER, 0.0)
	adb.position = Vector2(960, _base_adb_y)
	adb.set_pose("relaxed_standing", 0.0)

	controller = ADBIntroPropsClass.GameController.new()
	controller.position = adb.position + Vector2(0, -35)
	props_layer.add_child(controller)

func start_beat() -> void:
	var tw := create_tween()

	# 0.0s: "I still love sports, but mostly these days... I play games." (37.68s global)
	tw.tween_callback(func():
		adb.set_pose("casual_contrapposto", 0.22)
		adb.set_expression("happy", 0.15)
		adb.start_speaking(11.0)
		play_sfx("click")
		spawn_speech_bubble(Vector2(700, 420), "I PLAY GAMES NOW!", INK_CYAN, true).auto_dismiss(3.0)
	)

	# 3.92s: End seg14
	tw.tween_interval(3.92)
	tw.tween_callback(func(): adb.stop_speaking())

	# 4.17s: "Like, way too many games." (41.85s global)
	tw.tween_interval(0.25)
	tw.tween_callback(func():
		cam_punch(1.10, false)
		play_sfx("camera_zoom")
		adb.set_pose("embarrassed", 0.22)
		adb.set_expression("flustered", 0.18)
		adb.start_speaking(10.0)
		spawn_sweat_drops(adb.position + Vector2(0, -106), 2).auto_dismiss(2.0)
		if doodles.has_method("spawn_digital_clock"):
			doodles.spawn_digital_clock(Vector2(680, 390), "3:42 AM").auto_dismiss(2.5)
	)

	# 6.25s: End seg15
	tw.tween_interval(2.08)
	tw.tween_callback(func(): adb.stop_speaking())

	# 6.55s: "Competitive shooters, RPGs, strategy..." (44.23s global)
	tw.tween_interval(0.30)
	tw.tween_callback(func():
		adb.set_pose("pacing_step_left", 0.22)
		adb.set_expression("excited", 0.15)
		adb.start_speaking(11.5)
		play_sfx("pop")
		spawn_sparkles(Vector2(680, 420), 4).auto_dismiss(3.0)
		spawn_action_burst(Vector2(1180, 450), "ONE MORE GAME!", INK_RED).auto_dismiss(3.5)
		spawn_handwritten_note("RANKED GRIND", Vector2(720, 700), 26, INK_BLUE, -2.0, true).auto_dismiss(3.0)
	)

	# 13.91s: End seg16 -> Controller dismiss & transition
	tw.tween_interval(7.36)
	tw.tween_callback(func():
		adb.stop_speaking()
		controller.visible = false
		cam_reset(0.3)
		adb.set_pose("relaxed_standing", 0.20)
		adb.set_expression("neutral", 0.15)
	)

	# 14.36s: Finish beat
	tw.tween_interval(0.45)
	tw.tween_callback(finish_beat)
