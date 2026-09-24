class_name Beat01AnalyticsFreeze
extends "res://nemi/episodes/ep05_celebration/Ep05BaseBeat.gd"

## Beat 1: The Analytics Freeze (0.00s – 9.54s | Duration: 9.54s)
## Segments:
## - seg01_freeze_hook (2.96s): "Guys... what is going on with YouTube right now?"
## - seg02_sat_at_desk (5.68s): "I sat down at my desk today, opened my analytics... and I just froze."

func _ready() -> void:
	beat_number = 1
	beat_name = "The Analytics Freeze"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep05_celebration/audio/segments_v2/seg01_freeze_hook.wav")
		voice_player.play(0.0)

	# 1. Staging & Initial Framing
	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(STATE_NORMAL_STUDIO, 0.0)

	# V2 Setup: Grounded wooden studio chair, creator desk, laptop, and resting phone
	setup_studio_furniture(true)

	nemi.reset()
	nemi.position = Vector2(540, 360)
	nemi.set_pose("seated_at_desk_relaxed", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# LIVE DOODLE: Organic hand-drawn sticky note on corkboard / background (clean top-left negative space)
	var note = live_sticky_note(Vector2(280, 160), "TODO:\nDON'T PANIC", Vector2(170, 95), 0.6)

	# ----------------------------------------------------
	# Segment 01: "Guys... what is going on with YouTube right now?" (2.96s)
	# ----------------------------------------------------
	play_segment("seg01_freeze_hook")

	# Card 1: "Guys... what is" (0.77s)
	nemi.blink(0.14)
	nemi.head_tilt(-3.0, 0.25)
	await wait_seconds(0.77)

	# Card 2: "going on with YouTube" (1.39s)
	nemi.set_expression("confused")
	nemi.head_tilt(5.0, 0.35)
	nemi.look("up_right")
	await wait_seconds(1.39)

	# Card 3: "right now?" (0.69s)
	nemi.look("center")
	nemi.set_expression("candid")
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	await wait_seconds(0.69)

	# Pause between seg01 and seg02 (0.51s)
	nemi.stop_speech()
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.RELAXED)
	nemi.set_pose("seated_at_desk_relaxed", 0.2)
	await wait_seconds(0.51)

	# ----------------------------------------------------
	# Segment 02: "I sat down at my desk today, opened my analytics... and I just froze." (5.68s)
	# ----------------------------------------------------
	play_segment("seg02_sat_at_desk")

	# Card 1: "I sat down" (0.86s)
	nemi.set_expression("smile")
	nemi.head_tilt(-4.0, 0.25)
	nemi.look("down_left")
	await wait_seconds(0.86)

	# Card 2: "at my desk today," (1.40s) - Environmental interaction: typing on laptop!
	nemi.look("down_right")
	nemi.set_expression("neutral")
	type_on_laptop()
	await wait_seconds(1.40)

	# Card 3: "opened my analytics..." (1.83s) - Checking dashboard on screen
	nemi.look("down_right")
	nemi.head_tilt(6.0, 0.25)
	set_laptop_screen(1) # Analytics chart spikes on laptop screen
	cam_push_in(0.12, 1.8)
	await wait_seconds(1.83)

	# Card 4: "and I just froze." (1.40s)
	# Sudden snap punch-in + frozen shock
	cam_punch(Vector2(0, -12), 1.25, 0.12)
	cam_shake(4.0, 0.20)
	nemi.set_expression("shocked")
	nemi.look("center")
	nemi.set_pose("shocked_analytics_freeze", 0.0)

	# LIVE DOODLE: Organic hand-drawn comic shock bubble "*FROZE!*" in clear upper right wall space
	var bubble = live_comment_bubble(Vector2(800, 160), "*FROZE!*", Vector2(160, 55), 0.4)

	await wait_seconds(1.40)

	# Deadpan silence hold after seg02 (0.69s)
	nemi.stop_speech()
	await wait_seconds(0.69)

	end_beat()
