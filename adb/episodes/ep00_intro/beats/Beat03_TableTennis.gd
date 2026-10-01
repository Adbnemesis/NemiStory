class_name Beat03TableTennis
extends "res://adb/episodes/ep00_intro/ADBEp00BaseBeat.gd"

## Beat 3: National-Level Table Tennis Past (17.84s -> 37.68s, duration 19.84s)
## Dramatic visual gag: Sudden serious anime table tennis tournament protagonist!
## High-density props: Table tennis paddle, bouncing celluloid ball, topspin arc, smash burst.

var paddle: Node2D
var ball: Node2D

func _ready() -> void:
	beat_number = 3
	beat_name = "Table Tennis"
	super._ready()

	adb.position = Vector2(960, _base_adb_y)
	adb.set_pose("relaxed_standing", 0.0)
	adb.set_expression("neutral", 0.0)

	# Paddle attached to right hand coordinate space
	paddle = ADBIntroPropsClass.TableTennisPaddle.new()
	paddle.visible = false
	props_layer.add_child(paddle)
	ball = ADBIntroPropsClass.TableTennisBall.new()
	ball.visible = false
	props_layer.add_child(ball)

func start_beat() -> void:
	var tw := create_tween()

	# 0.0s: "Now, before this, my life was pretty normal." (17.84s global)
	tw.tween_callback(func():
		cam_reset(0.2)
		adb.set_pose("weight_right", 0.25)
		adb.set_expression("neutral", 0.15)
		adb.start_speaking(11.0)
	)

	# 3.04s: End seg08
	tw.tween_interval(3.04)
	tw.tween_callback(func(): adb.stop_speaking())

	# 3.29s: "A lot of people don't know this, but I used to play sports." (21.13s global)
	tw.tween_interval(0.25)
	tw.tween_callback(func():
		adb.set_pose("explaining", 0.22)
		adb.set_expression("happy", 0.15)
		adb.start_speaking(11.0)
		spawn_speech_bubble(Vector2(700, 420), "I PLAYED SPORTS?!", INK_BLUE, true).auto_dismiss(2.8)
		play_sfx("pop", -3.0)
	)

	# 6.73s: End seg09
	tw.tween_interval(3.44)
	tw.tween_callback(func(): adb.stop_speaking())

	# 6.98s: "Specifically... table tennis. At the national level." (24.82s global)
	tw.tween_interval(0.25)
	tw.tween_callback(func():
		backdrop.set_mode(ADBIntroBackdropClass.EnvironmentMode.TABLE_TENNIS_ARENA, 0.25)
		paddle.visible = true
		paddle.position = adb.position + adb.right_hand + Vector2(10, 5)
		adb.set_pose("athletic_ready", 0.22)
		adb.set_expression("determined", 0.18)
		adb.start_speaking(10.0)
		play_sfx("whoosh", -2.0)
		spawn_action_burst(Vector2(660, 400), "NATIONAL LEVEL!", INK_GOLD).auto_dismiss(3.0)
	)

	# 10.34s: End seg10 -> Dramatic snap to Anime Tournament Stance!
	tw.tween_interval(3.36)
	tw.tween_callback(func():
		adb.stop_speaking()
		backdrop.speedline_intensity = 1.0
		cam_punch(1.18, true)
		play_sfx("whoosh")
		adb.set_pose("smash_lunge", 0.10)
		adb.set_expression("determined", 0.08)
		paddle.position = adb.position + adb.right_hand + Vector2(25, -15)
		paddle.face_angle = -0.4
	)

	# 10.74s: "And yes, it was intense." (28.58s global)
	tw.tween_interval(0.40)
	tw.tween_callback(func():
		adb.start_speaking(12.0)
		cam_shake(0.5, 3.0)
		spawn_speech_bubble(Vector2(680, 400), "VERY INTENSE!", INK_RED, true).auto_dismiss(1.8)
	)

	# 12.74s: End seg11 -> Ball Smash Action!
	tw.tween_interval(2.00)
	tw.tween_callback(func():
		adb.stop_speaking()
		ball.visible = true
		ball.position = Vector2(1200, 480)
		ball.trail_progress = 1.0
		var b_tw := create_tween()
		b_tw.tween_property(ball, "position", Vector2(400, 620), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		play_sfx("click")
		cam_shake(0.65, 3.0)
		spawn_action_burst(Vector2(880, 460), "SMASH!", INK_RED).auto_dismiss(1.8)
		if doodles.has_method("spawn_spin_arc"):
			doodles.spawn_spin_arc(Vector2(960, 360)).auto_dismiss(2.5)
	)

	# 13.04s: "Spinning balls, lightning rallies, extreme tournament focus." (30.88s global)
	tw.tween_interval(0.30)
	tw.tween_callback(func():
		adb.set_pose("excited", 0.18)
		adb.start_speaking(12.0)
	)

	# 16.08s: End seg12 -> Recover to calm normal guy
	tw.tween_interval(3.04)
	tw.tween_callback(func():
		adb.stop_speaking()
		ball.visible = false
		backdrop.speedline_intensity = 0.0
		backdrop.set_mode(ADBIntroBackdropClass.EnvironmentMode.STUDIO_NEUTRAL, 0.3)
		cam_reset(0.3)
		play_sfx("chime")
		adb.set_pose("relaxed_standing", 0.25)
		adb.set_expression("amused", 0.20)
		paddle.position = adb.position + adb.right_hand + Vector2(10, 20)
		paddle.face_angle = 0.0
	)

	# 16.43s: "Then I grew up... and retired my paddle." (34.27s global)
	tw.tween_interval(0.35)
	tw.tween_callback(func():
		adb.set_pose("weight_left", 0.22)
		adb.start_speaking(10.0)
		spawn_speech_bubble(Vector2(720, 430), "RETIRED PADDLE.", INK_SOFT, false).auto_dismiss(2.2)
	)

	# 19.39s: End of seg13 -> Hide paddle and finish
	tw.tween_interval(2.96)
	tw.tween_callback(func():
		adb.stop_speaking()
		paddle.visible = false
	)

	# 19.84s: Finish beat
	tw.tween_interval(0.45)
	tw.tween_callback(finish_beat)
