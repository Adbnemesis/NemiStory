class_name Beat07CommentGratitude
extends "res://nemi/episodes/ep05_celebration/Ep05BaseBeat.gd"

## Beat 7: Comment Apology & Sincere Smiling (66.52s – 73.85s | Duration: 7.33s)
## Segments:
## - seg15_reading_promise (6.88s): "I promise I read them, even if I can't reply to everyone. They make me smile like an idiot."

func _ready() -> void:
	beat_number = 7
	beat_name = "Comment Gratitude"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep05_celebration/audio/segments_v2/seg15_reading_promise.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, 0.4)
	transition_backdrop(STATE_COMMENT_IMMERSION, 0.0)

	# V2 Setup: Standing contrapposto beside creator desk
	setup_studio_furniture(false)

	nemi.reset()
	nemi.position = Vector2(540, 430)
	nemi.set_pose("relaxed_standing_left_weight", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# LIVE DOODLE: Organic hand-drawn heart comment card framed cleanly to left of Nemi
	var heart_card = live_heart_card(Vector2(350, 210), 0.7)

	# ----------------------------------------------------
	# Segment 15: "I promise I read them, even if I can't reply to everyone. They make me smile like an idiot." (6.88s)
	# ----------------------------------------------------
	play_segment("seg15_reading_promise")

	# Card 1: "I promise I read them," (1.65s)
	nemi.head_tilt(-5.0, 0.25)
	nemi.set_expression("warm")
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.HAND_TO_CHEST)
	await wait_seconds(1.65)

	# Card 2: "even if I can't" (1.16s)
	nemi.set_pose("thinking_chin_tap", 0.2)
	nemi.set_expression("embarrassed")
	nemi.look("down_left")
	await wait_seconds(1.16)

	# Card 3: "reply to everyone." (1.45s)
	nemi.head_tilt(5.0, 0.2)
	nemi.show_blush(true)
	await wait_seconds(1.45)

	# Card 4: "They make me smile" (1.45s)
	nemi.look("center")
	nemi.set_expression("happy")
	cam_push_in(0.10, 2.0)
	await wait_seconds(1.45)

	# Card 5: "like an idiot." (1.06s)
	nemi.set_expression("smile")
	nemi.head_tilt(6.0, 0.25)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.HAND_TO_CHEEK)
	await wait_seconds(1.06)

	# Pause hold after seg15 (0.56s): Sweet smiling stillness hold
	nemi.stop_speech()
	await wait_seconds(0.56)

	end_beat()
