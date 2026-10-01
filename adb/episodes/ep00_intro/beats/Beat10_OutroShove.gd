class_name Beat10OutroShove
extends "res://adb/episodes/ep00_intro/ADBEp00BaseBeat.gd"

## Beat 10: Outro & The Second Shove (117.00s -> 132.41s, duration 15.41s)
## "So... that's me. I'm ADB. And apparently I'm a storytime animator now."
## Ending Hook: Blurred girlfriend silhouette appears behind him and gives a funny shove.
## ADB: "Okay! LET ME DO THE INTRO!"
## High-density props: Confetti burst, subscribe banner, dust cloud, final speech bubble.

var silhouette: Node2D

func _ready() -> void:
	beat_number = 10
	beat_name = "Outro Shove"
	super._ready()

	backdrop.set_mode(ADBIntroBackdropClass.EnvironmentMode.OUTRO_STAGE, 0.0)
	adb.position = Vector2(960, _base_adb_y)
	adb.set_pose("relaxed_standing", 0.0)

	silhouette = ADBIntroPropsClass.MysterySilhouette.new()
	silhouette.position = Vector2(1280, _base_adb_y)
	silhouette.visible = false
	props_layer.add_child(silhouette)

func start_beat() -> void:
	var tw := create_tween()

	# 0.0s: "So... that's me. I'm ADB." (117.00s global)
	tw.tween_callback(func():
		adb.set_pose("weight_left", 0.20)
		adb.set_expression("happy", 0.15)
		adb.start_speaking(10.5)
		spawn_speech_bubble(Vector2(700, 420), "SO... THAT'S ME.", INK_MAIN, true).auto_dismiss(2.2)
	)

	# 2.24s: End seg36
	tw.tween_interval(2.24)
	tw.tween_callback(func(): adb.stop_speaking())

	# 2.54s: "And apparently... I'm a storytime animator now." (119.54s global)
	tw.tween_interval(0.30)
	tw.tween_callback(func():
		adb.set_pose("explaining", 0.20)
		adb.set_expression("smug", 0.15)
		adb.start_speaking(11.0)
		if doodles.has_method("spawn_confetti"):
			doodles.spawn_confetti(Vector2(960, 450), 25).auto_dismiss(4.0)
		spawn_sparkles(Vector2(960, 420), 4).auto_dismiss(3.0)
		play_sfx("chime")
	)

	# 5.90s: End seg37
	tw.tween_interval(3.36)
	tw.tween_callback(func(): adb.stop_speaking())

	# 6.30s: "We're going to tell some stories, laugh at bad decisions, and see what happens." (123.30s global)
	tw.tween_interval(0.40)
	tw.tween_callback(func():
		adb.set_pose("hands_clasped", 0.22)
		adb.set_expression("happy", 0.15)
		adb.start_speaking(11.5)
		if doodles.has_method("spawn_subscribe_banner"):
			doodles.spawn_subscribe_banner(Vector2(960, 360)).auto_dismiss(4.5)
		spawn_speech_bubble(Vector2(680, 440), "EPISODE 1 NEXT!", INK_CYAN, true).auto_dismiss(4.0)
	)

	# 11.18s: End seg38
	tw.tween_interval(4.88)
	tw.tween_callback(func(): adb.stop_speaking())

	# 11.53s: "Thanks for watching, and I'll—" (128.53s global)
	tw.tween_interval(0.35)
	tw.tween_callback(func():
		adb.set_pose("explaining", 0.15)
		adb.set_expression("happy", 0.12)
		adb.start_speaking(11.0)
	)

	# 12.80s: Silhouette emerges from behind right!
	tw.tween_interval(1.27)
	tw.tween_callback(func():
		silhouette.visible = true
		silhouette.alpha_fade = 0.0
		silhouette.fade_in(0.18)
		var s_tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		s_tw.tween_property(silhouette, "position:x", 1120.0, 0.25)
	)

	# 13.05s: End seg39 / Cutoff by shove!
	tw.tween_interval(0.25)
	tw.tween_callback(func():
		adb.stop_speaking()
		# Silhouette shoves ADB forward
		silhouette.push_forward(75.0, 0.18)
		play_sfx("shove")
		play_sfx("impact")
		cam_shake(0.45, 3.0)
		adb.set_pose("stumble_pushed", 0.12)
		adb.set_expression("shocked", 0.10)
		spawn_push_dust(Vector2(960, 835)).auto_dismiss(1.8)
		spawn_sweat_drops(adb.position + Vector2(0, -106), 2).auto_dismiss(1.8)
		spawn_action_burst(Vector2(1060, 520), "SHOVE!", INK_RED).auto_dismiss(1.5)

		# ADB gets jolted forward and turns head back in playful outrage
		var adb_tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		adb_tw.tween_property(adb, "position:x", 870.0, 0.22)
	)

	# 13.25s: "Okay! LET ME DO THE INTRO!" (130.25s global)
	tw.tween_interval(0.20)
	tw.tween_callback(func():
		adb.set_pose("awkward_freeze", 0.12)
		adb.set_expression("annoyed", 0.10)
		adb.start_speaking(12.5)
		spawn_speech_bubble(Vector2(650, 460), "LET ME DO THE INTRO!", INK_RED, true).auto_dismiss(2.0)

		# Silhouette retracts arm and fades out into mystery
		silhouette.retract(0.25)
		silhouette.fade_out(0.40)
	)

	# 15.01s: End seg40
	tw.tween_interval(1.76)
	tw.tween_callback(func():
		adb.stop_speaking()
		adb.set_expression("smug", 0.15)
	)

	# 15.41s: Finish beat / cut to black!
	tw.tween_interval(0.40)
	tw.tween_callback(finish_beat)
