class_name Beat09GirlfriendHelp
extends "res://adb/episodes/ep00_intro/ADBEp00BaseBeat.gd"

## Beat 9: Girlfriend Help / Mystery Silhouette (105.37s -> 117.00s, duration 11.63s)
## "I'm getting some help from my girlfriend... ...A LOT of help."
## STRICT MYSTERY GAG: Solid black / blurred silhouette. ZERO Nemi reveal.
## High-density props: Mystery silhouette, thumbs-up, heart doodle, 3-stage potato evolution chart.

var silhouette: Node2D
var potato: Node2D

func _ready() -> void:
	beat_number = 9
	beat_name = "Girlfriend Help"
	super._ready()

	backdrop.set_mode(ADBIntroBackdropClass.EnvironmentMode.GIRLFRIEND_CORNER, 0.0)
	adb.position = Vector2(880, _base_adb_y)
	adb.set_pose("relaxed_standing", 0.0)

	silhouette = ADBIntroPropsClass.MysterySilhouette.new()
	silhouette.position = Vector2(1720, _base_adb_y)
	silhouette.visible = false
	props_layer.add_child(silhouette)

func start_beat() -> void:
	var tw := create_tween()

	# 0.0s: "Now, to be fair... I'm not doing this completely alone." (105.37s global)
	tw.tween_callback(func():
		adb.set_pose("hands_clasped", 0.20)
		adb.set_expression("neutral", 0.15)
		adb.start_speaking(11.0)
	)

	# 3.84s: End seg32
	tw.tween_interval(3.84)
	tw.tween_callback(func(): adb.stop_speaking())

	# 4.14s: "I'm getting some help from my girlfriend." (109.51s global)
	tw.tween_interval(0.30)
	tw.tween_callback(func():
		# Mystery silhouette glides into frame right (cropped, blurred, dark)
		silhouette.visible = true
		silhouette.alpha_fade = 0.0
		silhouette.is_thumbs_up = false
		silhouette.fade_in(0.30)
		var sil_tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		sil_tw.tween_property(silhouette, "position:x", 1580.0, 0.40)

		# Camera reframes slightly toward the interaction
		cam_pan(Vector2(930, 540), 0.35)

		# ADB leans casually toward off-screen right
		adb.set_pose("casual_contrapposto", 0.20)
		adb.set_expression("happy", 0.15)
		adb.start_speaking(11.0)

		if doodles.has_method("spawn_heart_doodle"):
			doodles.spawn_heart_doodle(Vector2(1460, 440)).auto_dismiss(3.0)
	)

	# 5.90s: End seg33
	tw.tween_interval(1.76)
	tw.tween_callback(func(): adb.stop_speaking())

	# 6.25s: "...A LOT of help." (111.62s global)
	tw.tween_interval(0.35)
	tw.tween_callback(func():
		# Silhouette gives playful thumbs up from edge
		silhouette.is_thumbs_up = true
		play_sfx("pop")

		# ADB glances sideways at silhouette with sheepish blush
		adb.set_pose("awkward_freeze", 0.15)
		adb.set_expression("cute", 0.15)
		adb.face.set_blush(0.65, 0.25)
		adb.start_speaking(10.0)
		spawn_speech_bubble(Vector2(680, 420), "A LOT OF HELP!", INK_GOLD, true).auto_dismiss(2.2)
	)

	# 7.29s: End seg34
	tw.tween_interval(1.04)
	tw.tween_callback(func(): adb.stop_speaking())

	# 7.74s: "She basically made sure my character didn't look like a potato." (113.11s global)
	tw.tween_interval(0.45)
	tw.tween_callback(func():
		# Spawn 3-stage Potato Evolution Chart
		if doodles.has_method("spawn_potato_evolution_chart"):
			potato = doodles.spawn_potato_evolution_chart(Vector2(540, 460))
			if potato and potato.has_method("auto_dismiss"):
				potato.auto_dismiss(3.8)
		play_sfx("bell")

		adb.set_pose("pointing_up", 0.20)
		adb.set_expression("excited", 0.15)
		adb.start_speaking(11.5)
	)

	# 11.18s: End seg35
	tw.tween_interval(3.44)
	tw.tween_callback(func():
		adb.stop_speaking()
		silhouette.fade_out(0.35)
		cam_pan(Vector2(960, 540), 0.35)
	)

	# 11.63s: Finish beat
	tw.tween_interval(0.45)
	tw.tween_callback(finish_beat)
