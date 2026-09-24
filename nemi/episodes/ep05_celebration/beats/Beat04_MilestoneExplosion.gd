class_name Beat04MilestoneExplosion
extends "res://nemi/episodes/ep05_celebration/Ep05BaseBeat.gd"

## Beat 4: The 1,000 Milestone Explosion (33.90s – 45.55s | Duration: 11.65s)
## Segments:
## - seg08_one_thousand (2.96s): "And then... one thousand."
## - seg09_wait_what_one_thousand (5.36s): "Wait, what?! One thousand subscribers?!"
## - seg10_are_you_serious (2.08s): "Are you guys actually serious right now?!"

func _ready() -> void:
	beat_number = 4
	beat_name = "Milestone Explosion"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep05_celebration/audio/segments_v2/seg08_one_thousand.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)

	# V2 Setup: Standing contrapposto beside creator desk
	setup_studio_furniture(false)

	nemi.reset()
	nemi.position = Vector2(540, 430)
	nemi.set_pose("relaxed_standing_left_weight", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# ----------------------------------------------------
	# Segment 08: "And then... one thousand." (2.96s)
	# ----------------------------------------------------
	play_segment("seg08_one_thousand")

	# Card 1: "And then..." (1.09s)
	nemi.look("up_right")
	nemi.set_expression("suspense")
	await wait_seconds(1.09)

	# Card 2: "one thousand." (1.71s)
	# EXPLOSION MOMENT!
	transition_backdrop(STATE_CELEBRATION_WALL, 0.3)
	cam_punch(Vector2(0, -20), 1.35, 0.12)
	cam_shake(8.0, 0.4)

	# LIVE DOODLE: Organic hand-lettered bold red "1,000" with sunburst rays & stars in clean upper right wall space
	var giant = live_giant_1000(Vector2(860, 170), 0.7)

	nemi.look("up_right")
	nemi.set_expression("shocked")
	nemi.set_pose("scared_recoil", 0.08)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.HAND_TO_CHEEK)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.HAND_TO_CHEEK)
	await wait_seconds(1.71)

	# Pause between seg08 and seg09 (0.51s)
	nemi.stop_speech()
	await wait_seconds(0.51)

	# ----------------------------------------------------
	# Segment 09: "Wait, what?! One thousand subscribers?!" (5.36s)
	# ----------------------------------------------------
	play_segment("seg09_wait_what_one_thousand")

	# Card 1: "Wait, what?!" (1.52s)
	cam_punch(Vector2(0, -10), 1.20, 0.1)
	cam_shake(5.0, 0.25)
	nemi.set_expression("excited")
	nemi.head_tilt(-8.0, 0.15)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.SPLAYED_FINGERS)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.SPLAYED_FINGERS)
	await wait_seconds(1.52)

	# Card 2: "One thousand" (1.67s)
	nemi.set_pose("excited_burst", 0.2)
	nemi.look("center")
	nemi.set_expression("laughing")
	await wait_seconds(1.67)

	# Card 3: "subscribers?!" (1.98s)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.look("center")
	nemi.head_tilt(5.0, 0.25)
	await wait_seconds(1.98)

	# Pause between seg09 and seg10 (0.54s)
	nemi.stop_speech()
	await wait_seconds(0.54)

	# ----------------------------------------------------
	# Segment 10: "Are you guys actually serious right now?!" (2.08s)
	# ----------------------------------------------------
	play_segment("seg10_are_you_serious")

	# Card 1: "Are you guys actually" (0.99s)
	nemi.head_tilt(6.0, 0.2)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.HAND_TO_CHEST)
	await wait_seconds(0.99)

	# Card 2: "serious right now?!" (0.94s)
	nemi.set_expression("smile")
	nemi.look("center")
	nemi.show_blush(true)
	await wait_seconds(0.94)

	# Disbelief laugh pause hold (0.70s)
	nemi.stop_speech()
	await wait_seconds(0.70)

	end_beat()
