class_name Beat07EngineeringJob
extends "res://adb/episodes/ep00_intro/ADBEp00BaseBeat.gd"

## Beat 7: Engineering Job (81.18s -> 89.90s, duration 8.72s)
## "I also have an engineering job... And apparently that wasn't enough work."
## High-density props: Engineering laptop, blueprint schematics, math formulas, "why did I do this" doodle.

var laptop: Node2D
var note_why: Node2D

func _ready() -> void:
	beat_number = 7
	beat_name = "Engineering Job"
	super._ready()

	backdrop.set_mode(ADBIntroBackdropClass.EnvironmentMode.ENGINEERING_OFFICE, 0.0)
	adb.position = Vector2(880, _base_adb_y)
	adb.set_pose("relaxed_standing", 0.0)

	laptop = ADBIntroPropsClass.EngineeringLaptop.new()
	laptop.visible = false
	props_layer.add_child(laptop)

func start_beat() -> void:
	var tw := create_tween()

	# 0.0s: "Oh, and by the way..." (81.18s global)
	tw.tween_callback(func():
		adb.set_pose("pacing_step_right", 0.20)
		adb.set_expression("neutral", 0.15)
		adb.start_speaking(11.0)
	)

	# 1.60s: End seg25
	tw.tween_interval(1.60)
	tw.tween_callback(func(): adb.stop_speaking())

	# 1.85s: "I also have an engineering job." (83.03s global)
	tw.tween_interval(0.25)
	tw.tween_callback(func():
		laptop.visible = true
		laptop.position = Vector2(1100, 830)
		if doodles.has_method("spawn_math_formulas"):
			doodles.spawn_math_formulas(Vector2(680, 420)).auto_dismiss(3.5)
		play_sfx("click")
		play_sfx("typing")
		adb.set_pose("hands_clasped", 0.20)
		adb.set_expression("smug", 0.15)
		adb.start_speaking(11.0)
		spawn_speech_bubble(Vector2(1180, 410), "ENGINEER BY DAY!", INK_BLUE, true).auto_dismiss(3.0)
	)

	# 3.53s: End seg26
	tw.tween_interval(1.68)
	tw.tween_callback(func(): adb.stop_speaking())

	# 3.98s: "And apparently... that wasn't enough work for one human being." (85.16s global)
	tw.tween_interval(0.45)
	tw.tween_callback(func():
		cam_punch(1.10, false)
		adb.set_pose("casual_slouch", 0.25)
		adb.set_expression("deadpan", 0.20)
		adb.start_speaking(9.5)
		spawn_sweat_drops(adb.position + Vector2(0, -106), 2).auto_dismiss(2.5)
	)

	# 5.50s: Handwritten annotation "WHY DID I DO THIS" appears
	tw.tween_interval(1.52)
	tw.tween_callback(func():
		note_why = spawn_handwritten_note("WHY DID I DO THIS?!", Vector2(980, 400), 32, INK_RED, -5.0, true)
		if note_why and note_why.has_method("auto_dismiss"):
			note_why.auto_dismiss(2.5)
		spawn_action_burst(Vector2(680, 430), "NOT ENOUGH?!", INK_GOLD).auto_dismiss(2.2)
		play_sfx("pop")
	)

	# 8.22s: End seg27
	tw.tween_interval(2.72)
	tw.tween_callback(func():
		adb.stop_speaking()
		laptop.visible = false
		cam_reset(0.2)
	)

	# 8.72s: Finish beat
	tw.tween_interval(0.50)
	tw.tween_callback(finish_beat)
