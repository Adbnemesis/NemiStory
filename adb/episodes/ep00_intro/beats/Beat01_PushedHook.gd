class_name Beat01PushedHook
extends "res://adb/episodes/ep00_intro/ADBEp00BaseBeat.gd"

## Beat 1: The Pushed Hook (0.00s -> 5.57s)
## ADB is forced into frame by the mystery girlfriend silhouette.
## High-density comic storytelling: push dust, flying sweat drops, comic bubbles, camera jolt.

var silhouette: Node2D

func _ready() -> void:
	beat_number = 1
	beat_name = "The Pushed Hook"
	super._ready()

	# Initial Staging: ADB reluctant on screen right-center, looking annoyed
	adb.position = Vector2(850, _base_adb_y)
	adb.set_pose("casual_slouch", 0.0)
	adb.set_expression("annoyed", 0.0)
	adb.look("away")

	# Mystery Silhouette positioned to ADB's right, grounded on floor line
	silhouette = ADBIntroPropsClass.MysterySilhouette.new()
	silhouette.position = Vector2(1090, _base_adb_y)
	props_layer.add_child(silhouette)

func start_beat() -> void:
	var tw := create_tween()

	# 0.20s: Silhouette pushes ADB forward
	tw.tween_interval(0.20)
	tw.tween_callback(func():
		play_sfx("whoosh")
		silhouette.push_forward(75.0, 0.22)
		cam_punch(1.10, false)
		cam_shake(0.35)
		adb.set_pose("stumble_pushed", 0.15)
		adb.set_expression("shocked", 0.12)
		spawn_push_dust(Vector2(850, 835)).auto_dismiss(1.2)
		spawn_sweat_drops(adb.position + Vector2(0, -106), 2).auto_dismiss(1.2)
	)

	# 0.35s: ADB slides forward and protests: "Wait—hold on. Stop pushing me."
	tw.tween_interval(0.15)
	tw.tween_callback(func():
		adb.set_pose("awkward_freeze", 0.18)
		adb.set_expression("confused", 0.15)
		adb.start_speaking(11.0)
		spawn_speech_bubble(Vector2(680, 420), "WAIT-- HOLD ON!", INK_RED, true).auto_dismiss(1.0)
	)
	tw.tween_property(adb, "position:x", 910.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 1.45s: Silhouette pushes again firmly!
	tw.tween_interval(0.90)
	tw.tween_callback(func():
		adb.stop_speaking()
		play_sfx("pop")
		silhouette.push_forward(90.0, 0.20)
		cam_shake(0.45)
		adb.set_pose("stumble_pushed", 0.12)
		adb.set_expression("flustered", 0.12)
		spawn_push_dust(Vector2(910, 835)).auto_dismiss(1.0)
		spawn_action_burst(Vector2(1040, 560), "SHOVE!", INK_GOLD).auto_dismiss(0.9)
	)

	# 1.65s: ADB slides to center, stepping to catch balance
	tw.tween_interval(0.20)
	tw.tween_property(adb, "position:x", 960.0, 0.30).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		silhouette.retract(0.25)
		silhouette.fade_out(0.40)
		adb.set_pose("casual_contrapposto", 0.22)
		adb.set_expression("amused", 0.18)
		adb.start_speaking(11.0)
	)

	# 3.20s: ADB recovers composure and introduces himself
	tw.tween_interval(1.55)
	tw.tween_callback(func():
		adb.stop_speaking()
		cam_reset(0.3)
		adb.set_pose("relaxed_standing", 0.25)
		adb.set_expression("neutral", 0.15)
		adb.look("camera")
	)

	# 3.60s: "Hi. I'm ADB."
	tw.tween_interval(0.40)
	tw.tween_callback(func():
		cam_punch(1.22, false)
		play_sfx("camera_zoom")
		adb.set_pose("one_hand_gesture", 0.20)
		adb.set_expression("neutral", 0.15)
		adb.start_speaking(10.0)
		spawn_speech_bubble(Vector2(750, 430), "HI. I'M ADB.", INK_MAIN, false).auto_dismiss(1.4)
		spawn_sparkles(Vector2(960, 480), 4).auto_dismiss(1.2)
	)

	# 5.10s: Finish speech & hold
	tw.tween_interval(1.50)
	tw.tween_callback(func():
		adb.stop_speaking()
		adb.set_pose("relaxed_standing", 0.20)
	)

	# End of beat at 5.57s
	tw.tween_interval(0.47)
	tw.tween_callback(finish_beat)
