class_name Beat06GymWorkout
extends "res://adb/episodes/ep00_intro/ADBEp00BaseBeat.gd"

## Beat 6: Regular Gym Routine (68.20s -> 81.18s, duration 12.98s)
## Confidently lifting dumbbell -> Comedic collapse after leg day.
## High-density props: Gym dumbbell, discipline action burst, stairs warning doodle, defeat swirls.

var dumbbell: Node2D

func _ready() -> void:
	beat_number = 6
	beat_name = "Gym Workout"
	super._ready()

	backdrop.set_mode(ADBIntroBackdropClass.EnvironmentMode.GYM_FLOOR, 0.0)
	adb.position = Vector2(960, _base_adb_y)
	adb.set_pose("relaxed_standing", 0.0)

	dumbbell = ADBIntroPropsClass.GymDumbbell.new()
	dumbbell.visible = false
	props_layer.add_child(dumbbell)

func start_beat() -> void:
	var tw := create_tween()

	# 0.0s: "To balance all that sitting, I go to the gym regularly." (68.20s global)
	tw.tween_callback(func():
		adb.set_pose("weight_left", 0.22)
		adb.set_expression("neutral", 0.15)
		adb.start_speaking(11.0)
		spawn_speech_bubble(Vector2(700, 420), "LIFTING WEIGHTS!", INK_BLUE, true).auto_dismiss(2.5)
	)

	# 2.96s: End seg21
	tw.tween_interval(2.96)
	tw.tween_callback(func(): adb.stop_speaking())

	# 3.21s: "Discipline. Form. Progressive overload." (71.41s global)
	tw.tween_interval(0.25)
	tw.tween_callback(func():
		dumbbell.visible = true
		dumbbell.position = adb.position + adb.right_hand + Vector2(10, 0)
		play_sfx("gym_clank")
		adb.set_pose("gym_squat_stance", 0.20)
		adb.set_expression("determined", 0.15)
		adb.start_speaking(10.0)
		spawn_action_burst(Vector2(680, 390), "DISCIPLINE!", INK_GOLD).auto_dismiss(2.5)
		# Bicep curl motion with dumbbell
		var d_tw := create_tween()
		d_tw.tween_property(dumbbell, "position:y", adb.position.y + adb.right_hand.y - 25, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)

	# 6.25s: End seg22
	tw.tween_interval(3.04)
	tw.tween_callback(func(): adb.stop_speaking())

	# 6.55s: "Right up until I try to walk up stairs after leg day." (74.75s global)
	tw.tween_interval(0.30)
	tw.tween_callback(func():
		doodles.spawn_gym_fx(Vector2(1180, 460)).auto_dismiss(3.0)
		spawn_sweat_drops(adb.position + Vector2(0, -106), 2).auto_dismiss(2.5)
		spawn_speech_bubble(Vector2(680, 410), "STAIRS DEFEAT ME!", INK_RED, true).auto_dismiss(2.6)
		adb.set_pose("awkward_freeze", 0.18)
		adb.set_expression("flustered", 0.15)
		adb.start_speaking(11.0)
		# Drop dumbbell down with impact to grounded floor Y = 840
		var d_tw := create_tween()
		d_tw.tween_property(dumbbell, "position:y", 840.0, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		cam_shake(0.4, 3.0)
	)

	# 9.51s: End seg23
	tw.tween_interval(2.96)
	tw.tween_callback(func():
		adb.stop_speaking()
		play_sfx("gym_clank")
	)

	# 9.81s: "Then I question every life choice I've ever made." (78.01s global)
	tw.tween_interval(0.30)
	tw.tween_callback(func():
		cam_punch(1.10, false)
		adb.set_pose("casual_slouch", 0.25)
		adb.set_expression("exhausted", 0.20)
		adb.start_speaking(10.0)
		play_sfx("fail")
		spawn_confusion_marks(Vector2(1060, 420)).auto_dismiss(2.5)
	)

	# 12.53s: Climax hold
	tw.tween_interval(2.72)
	tw.tween_callback(func():
		adb.stop_speaking()
		dumbbell.visible = false
		cam_reset(0.2)
	)

	# 12.98s: Finish beat
	tw.tween_interval(0.45)
	tw.tween_callback(finish_beat)
