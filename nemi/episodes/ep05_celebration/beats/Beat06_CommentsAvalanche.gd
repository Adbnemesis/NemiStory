class_name Beat06CommentsAvalanche
extends "res://nemi/episodes/ep05_celebration/Ep05BaseBeat.gd"

## Beat 6: The 1,000 Comments Avalanche (57.38s – 66.52s | Duration: 9.14s)
## Segments:
## - seg13_checked_comments (4.56s): "And then I checked the comments, and there are around one thousand comments across the videos."
## - seg14_thousand_comments_shout (3.68s): "A thousand comments?! Guys... what?!"

func _ready() -> void:
	beat_number = 6
	beat_name = "Comments Avalanche"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep05_celebration/audio/segments_v2/seg13_checked_comments.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(STATE_COMMENT_IMMERSION, 0.4)

	# V2 Setup: Standing contrapposto beside creator desk
	setup_studio_furniture(false)

	nemi.reset()
	nemi.position = Vector2(540, 430)
	nemi.set_pose("relaxed_standing_left_weight", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# ----------------------------------------------------
	# Segment 13: "And then I checked the comments, and there are around one thousand comments across the videos." (4.56s)
	# ----------------------------------------------------
	play_segment("seg13_checked_comments")

	# Card 1: "And then I checked" (0.86s) - Environmental interaction: checking laptop comments
	nemi.look("down_right") # Looking down at creator laptop
	nemi.head_tilt(5.0, 0.2)
	set_laptop_screen(2)    # Comments feed active on laptop screen!
	await wait_seconds(0.86)

	# Card 2: "the comments," (0.63s)
	# LIVE DOODLE: Organic hand-drawn first comment bubble in clean upper-left wall
	var b1 = live_comment_bubble(Vector2(230, 110), "SO PROUD OF YOU!!", Vector2(210, 58), 0.4)
	await wait_seconds(0.63)

	# Card 3: "and there are around" (0.97s)
	# LIVE DOODLE: Organic hand-drawn second comment bubble in clean upper-right wall
	var b2 = live_comment_bubble(Vector2(950, 140), "FIRST!! <3", Vector2(180, 54), 0.4)
	nemi.set_expression("surprised")
	nemi.look("right")
	await wait_seconds(0.97)

	# Card 4: "one thousand comments" (1.09s)
	# LIVE DOODLE: Organic hand-drawn third & fourth comment bubbles in dedicated negative space columns
	var b3 = live_comment_bubble(Vector2(230, 310), "THE ART IS AMAZING!", Vector2(220, 58), 0.4)
	var b4 = live_comment_bubble(Vector2(930, 240), "1,000 SUBS LETS GOO", Vector2(210, 54), 0.4)
	nemi.set_pose("scared_recoil", 0.15)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.SPLAYED_FINGERS)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.SPLAYED_FINGERS)
	nemi.set_expression("shocked")
	await wait_seconds(1.09)

	# Card 5: "across the videos." (0.86s)
	nemi.look("center")
	await wait_seconds(0.86)

	# Pause between seg13 and seg14 (0.55s)
	nemi.stop_speech()
	await wait_seconds(0.55)

	# ----------------------------------------------------
	# Segment 14: "A thousand comments?! Guys... what?!" (3.68s)
	# ----------------------------------------------------
	play_segment("seg14_thousand_comments_shout")

	# Card 1: "A thousand comments?!" (2.33s)
	cam_punch(Vector2(0, -10), 1.20, 0.12)
	cam_shake(4.0, 0.25)
	nemi.set_pose("excited_burst", 0.15)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.set_expression("excited")
	await wait_seconds(2.33)

	# Card 2: "Guys... what?!" (1.22s)
	# Sharp punch into stunned deadpan
	cam_punch(Vector2(0, -18), 1.35, 0.10)
	cam_shake(6.0, 0.30)
	nemi.set_pose("deadpan_camera_stare", 0.05)
	nemi.set_expression("shocked")
	nemi.look("center")
	await wait_seconds(1.22)

	# Deadpan silence hold after seg14 (0.63s): Absolute freeze-frame stillness
	nemi.stop_speech()
	await wait_seconds(0.63)

	end_beat()
