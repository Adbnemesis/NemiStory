class_name Beat05HumanBeings
extends "res://nemi/episodes/ep05_celebration/Ep05BaseBeat.gd"

## Beat 5: Actual Human Beings?! (45.55s – 57.38s | Duration: 11.83s)
## Segments:
## - seg11_process_that (3.04s): "I don't even know how to process that."
## - seg12_living_human_beings (7.84s): "That's not just a digital number on a screen. That is one thousand actual, living human beings."

func _ready() -> void:
	beat_number = 5
	beat_name = "Actual Human Beings"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep05_celebration/audio/segments_v2/seg11_process_that.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.WIDE, 0.0)
	transition_backdrop(STATE_CELEBRATION_WALL, 0.0)

	# V2 Setup: Standing contrapposto on right leg
	setup_studio_furniture(false)

	nemi.reset()
	nemi.position = Vector2(540, 430)
	nemi.set_pose("relaxed_standing_right_weight", 0.0)
	nemi.set_expression("confused")
	nemi.look("center")

	# ----------------------------------------------------
	# Segment 11: "I don't even know how to process that." (3.04s)
	# ----------------------------------------------------
	play_segment("seg11_process_that")

	# Card 1: "I don't even know" (1.36s)
	nemi.head_tilt(-6.0, 0.25)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.HAND_TO_CHEEK)
	await wait_seconds(1.36)

	# Card 2: "how to process that." (1.56s)
	nemi.set_pose("thinking_chin_tap", 0.2)
	nemi.set_expression("embarrassed")
	await wait_seconds(1.56)

	# Pause between seg11 and seg12 (0.52s)
	nemi.stop_speech()
	await wait_seconds(0.52)

	# ----------------------------------------------------
	# Segment 12: "That's not just a digital number on a screen. That is one thousand actual, living human beings." (7.84s)
	# ----------------------------------------------------
	play_segment("seg12_living_human_beings")

	# Card 1: "That's not just a" (1.45s)
	nemi.set_pose("conversational_open_one", 0.2)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.POINTING)
	nemi.look("center")
	await wait_seconds(1.45)

	# Card 2: "digital number on screen." (2.17s)
	nemi.set_expression("deadpan")
	nemi.head_tilt(5.0, 0.25)
	await wait_seconds(2.17)

	# Card 3: "That is one thousand" (1.76s)
	# LIVE DOODLE: Organic hand-drawn tiny crowd of 24 human figures waving across the upper celebration wall!
	var crowd = live_tiny_crowd(Vector2(640, 170), 1.2)
	nemi.set_expression("surprised")
	nemi.look("up") # Looking up in wonder at the community crowd!
	await wait_seconds(1.76)

	# Card 4: "actual, living human beings." (2.38s)
	crowd.start_waving()
	nemi.set_expression("happy")
	nemi.set_pose("overwhelmed_chest_touch", 0.2)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.HAND_TO_CHEST)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.look("center")
	cam_push_in(0.12, 3.0)
	nemi.show_blush(true)
	await wait_seconds(2.38)

	# Pause hold after seg12 (0.63s)
	nemi.stop_speech()
	await wait_seconds(0.63)

	end_beat()
