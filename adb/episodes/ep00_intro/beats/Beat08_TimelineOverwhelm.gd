class_name Beat08TimelineOverwhelm
extends "res://adb/episodes/ep00_intro/ADBEp00BaseBeat.gd"

## Beat 8: The Big Transition / Timeline Overwhelm (89.90s -> 105.37s, duration 15.47s)
## Thousands of hand-drawn frames -> Giant timeline appears -> Deadpan "Great."
## High-density props: Multitask icons, editing timeline, 24 FPS counters, snap zoom.

var timeline_prop: Node2D

func _ready() -> void:
	beat_number = 8
	beat_name = "Timeline Overwhelm"
	super._ready()

	backdrop.set_mode(ADBIntroBackdropClass.EnvironmentMode.TIMELINE_VOID, 0.0)
	adb.position = Vector2(960, _base_adb_y)
	adb.set_pose("relaxed_standing", 0.0)

func start_beat() -> void:
	var tw := create_tween()

	# 0.0s: "Because recently, I looked at my schedule: engineering, gym, sports, games, anime..." (89.90s global)
	tw.tween_callback(func():
		adb.set_pose("explaining", 0.20)
		adb.set_expression("thinking", 0.15)
		adb.start_speaking(11.0)
		if doodles.has_method("spawn_multitask_icons"):
			var d = doodles.spawn_multitask_icons(Vector2(960, 360))
			if d and d.has_method("auto_dismiss"):
				d.auto_dismiss(5.5)
	)

	# 6.88s: End seg28
	tw.tween_interval(6.88)
	tw.tween_callback(func(): adb.stop_speaking())

	# 7.18s: "And I thought... 'You know what would fit perfectly into this?'" (97.08s global)
	tw.tween_interval(0.30)
	tw.tween_callback(func():
		adb.set_pose("chin_rub", 0.20)
		adb.set_expression("smug", 0.15)
		adb.start_speaking(10.5)
		spawn_speech_bubble(Vector2(680, 420), "YOU KNOW WHAT WOULD FIT?", INK_GOLD, true).auto_dismiss(3.2)
	)

	# 10.78s: End seg29
	tw.tween_interval(3.60)
	tw.tween_callback(func(): adb.stop_speaking())

	# 11.13s: "'Thousands of hand-drawn animation frames.'" (101.03s global)
	tw.tween_interval(0.35)
	tw.tween_callback(func():
		play_sfx("whoosh")
		play_sfx("impact")
		cam_shake(0.5, 3.0)
		adb.set_pose("confused_scratch", 0.20)
		adb.set_expression("teary_cry", 0.15)
		adb.start_speaking(11.0)
		spawn_action_burst(Vector2(660, 370), "THOUSANDS OF FRAMES!", INK_RED).auto_dismiss(2.8)
		spawn_sweat_drops(adb.position + Vector2(0, -106), 2).auto_dismiss(2.5)
		spawn_handwritten_note("24 FPS / 14 LAYERS", Vector2(1260, 370), 24, INK_PURPLE, 2.8, true).auto_dismiss(2.8)
	)

	# 14.17s: End seg30
	tw.tween_interval(3.04)
	tw.tween_callback(func():
		adb.stop_speaking()
		doodles.clear_all()
	)

	# 14.47s: "Great." (104.47s global) - Iconic deadpan snap zoom
	tw.tween_interval(0.30)
	tw.tween_callback(func():
		cam_punch(1.12, false)
		play_sfx("bruh")
		adb.set_pose("casual_slouch", 0.08)
		adb.set_expression("deadpan", 0.04)
		adb.start_speaking(9.0)
		spawn_speech_bubble(Vector2(840, 470), "GREAT.", INK_MAIN, false).auto_dismiss(0.8)
	)

	# 14.87s: End seg31
	tw.tween_interval(0.40)
	tw.tween_callback(func():
		adb.stop_speaking()
		cam_reset(0.2)
	)

	# 15.47s: Finish beat
	tw.tween_interval(0.60)
	tw.tween_callback(finish_beat)
