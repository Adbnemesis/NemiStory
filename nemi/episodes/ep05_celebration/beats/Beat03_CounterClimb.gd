class_name Beat03CounterClimb
extends "res://nemi/episodes/ep05_celebration/Ep05BaseBeat.gd"

## Beat 3: The Rapid Counter Climb (20.73s – 33.90s | Duration: 13.17s)
## Segments:
## - seg05_opened_dashboard (3.20s): "So I opened the dashboard today, expecting nothing..."
## - seg06_counter_climbing (6.96s): "And the subscriber counter was just climbing. One, seventeen, eighty-four, five hundred..."
## - seg07_nine_ninety_nine (1.76s): "Nine hundred ninety-nine..."

func _ready() -> void:
	beat_number = 3
	beat_name = "Counter Climb"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep05_celebration/audio/segments_v2/seg05_opened_dashboard.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(STATE_SUSPENSE_WALL, 0.8)

	# V2 Setup: Creator desk, phone placed down, standing in contrapposto
	setup_studio_furniture(false)

	nemi.reset()
	nemi.position = Vector2(540, 430)
	nemi.set_pose("relaxed_standing_left_weight", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# ----------------------------------------------------
	# Segment 05: "So I opened the dashboard today, expecting nothing..." (3.20s)
	# ----------------------------------------------------
	play_segment("seg05_opened_dashboard")

	# Card 1: "So I opened the dashboard" (1.51s) - Environmental interaction: checking creator dashboard
	nemi.head_tilt(-4.0, 0.25)
	nemi.look("down_right") # Looking at creator laptop
	set_laptop_screen(1)    # Dashboard analytics active on laptop screen!
	await wait_seconds(1.51)

	# Card 2: "today, expecting nothing..." (1.51s)
	nemi.set_expression("candid")
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.look("center")
	await wait_seconds(1.51)

	# Pause between seg05 and seg06 (0.53s)
	nemi.stop_speech()
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.RELAXED)
	await wait_seconds(0.53)

	# ----------------------------------------------------
	# Segment 06: "And the subscriber counter was just climbing. One, seventeen, eighty-four, five hundred..." (6.96s)
	# ----------------------------------------------------
	play_segment("seg06_counter_climbing")

	# LIVE DOODLE: Organic hand-drawn subscriber counter box in clean upper right space
	var counter = live_counter_box(Vector2(880, 180), 0.5)

	# Card 1: "And the subscriber counter" (2.11s)
	nemi.set_pose("pointing", 0.2)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.POINTING)
	nemi.look("up_right")
	await wait_seconds(2.11)

	# Card 2: "was just climbing." (1.38s)
	cam_push_in(0.12, 4.5)
	nemi.set_expression("surprised")
	await wait_seconds(1.38)

	# Card 3: "One..." (0.37s)
	counter.climb_to(1, 0.2)
	await wait_seconds(0.37)

	# Card 4: "seventeen..." (0.83s)
	counter.climb_to(17, 0.35)
	nemi.head_tilt(5.0, 0.25)
	await wait_seconds(0.83)

	# Card 5: "eighty-four..." (1.01s)
	counter.climb_to(84, 0.45)
	nemi.set_pose("excited_anticipation", 0.2)
	nemi.look("up_right")
	await wait_seconds(1.01)

	# Card 6: "five hundred..." (1.01s)
	counter.climb_to(500, 0.55)
	nemi.set_expression("shocked")
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.HANDS_TOGETHER)
	await wait_seconds(1.01)

	# Pause between seg06 and seg07 (0.65s)
	nemi.stop_speech()
	await wait_seconds(0.65)

	# ----------------------------------------------------
	# Segment 07: "Nine hundred ninety-nine..." (1.76s)
	# ----------------------------------------------------
	play_segment("seg07_nine_ninety_nine")

	# Card 1: "Nine hundred ninety-nine..." (1.60s)
	counter.climb_to(999, 0.7)
	cam_punch(Vector2(0, -10), 1.15, 0.15)
	nemi.look("up_right")
	await wait_seconds(1.60)

	# Dramatic suspense hold at 999 (0.66s): Absolute stillness hold
	nemi.stop_speech()
	await wait_seconds(0.66)

	end_beat()
