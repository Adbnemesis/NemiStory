class_name Beat10WarmSignoff
extends "res://nemi/episodes/ep05_celebration/Ep05BaseBeat.gd"

## Beat 10: "THANK YOU <3" & "NEW VIDEO SOON" (85.09s – 92.45s | Duration: 7.36s)
## Segments:
## - seg18_warm_signoff (6.56s): "So from the bottom of my heart, thank you so much. New video soon. Bye!"

func _ready() -> void:
	beat_number = 10
	beat_name = "Warm Signoff"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep05_celebration/audio/segments_v2/seg18_warm_signoff.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(STATE_SINCERE_WARMTH, 0.0)

	# V2 Setup: Standing contrapposto beside creator desk
	setup_studio_furniture(false)

	nemi.reset()
	nemi.position = Vector2(540, 430)
	nemi.set_pose("relaxed_standing_left_weight", 0.0)
	nemi.set_expression("smile")
	nemi.look("center")

	# ----------------------------------------------------
	# Segment 18: "So from the bottom of my heart, thank you so much. New video soon. Bye!" (6.56s)
	# ----------------------------------------------------
	play_segment("seg18_warm_signoff")

	# Card 1: "So from the bottom" (1.78s)
	nemi.head_tilt(-4.0, 0.25)
	nemi.set_expression("warm")
	await wait_seconds(1.78)

	# Card 2: "of my heart," (1.07s)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.HAND_TO_CHEST)
	nemi.set_expression("tender")
	await wait_seconds(1.07)

	# Card 3: "thank you so much." (1.67s)
	# LIVE DOODLE: Organic hand-drawn "THANK YOU <3" card on clean upper left wall
	var thank_you_card = live_physical_card(Vector2(230, 110), "THANK YOU <3", true, 0.7)
	nemi.set_expression("happy")
	nemi.show_blush(true)
	await wait_seconds(1.67)

	# Card 4: "New video soon." (1.43s)
	# LIVE DOODLE: Organic hand-drawn "NEW VIDEO SOON!" card in clean upper right wall space
	var next_card = live_physical_card(Vector2(940, 200), "NEW VIDEO SOON!", true, 0.6)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.POINTING)
	nemi.set_expression("excited")
	await wait_seconds(1.43)

	# Card 5: "Bye!" (0.48s)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.set_expression("happy")
	cam_push_in(0.08, 1.3)
	await wait_seconds(0.48)

	# Comfortable stillness hold (0.93s): Final warm gratitude hold
	nemi.stop_speech()
	nemi.set_pose("subtle_micro_smile", 0.3)
	await wait_seconds(0.93)

	end_beat()
