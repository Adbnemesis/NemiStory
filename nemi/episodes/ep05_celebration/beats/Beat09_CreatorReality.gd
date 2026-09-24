class_name Beat09CreatorReality
extends "res://nemi/episodes/ep05_celebration/Ep05BaseBeat.gd"

## Beat 9: Overwhelmed Creator Reality (77.44s – 85.09s | Duration: 7.65s)
## Segments:
## - seg17_drawing_by_hand (7.20s): "When you sit alone drawing every single frame by hand, this kind of support means everything to me."

func _ready() -> void:
	beat_number = 9
	beat_name = "Creator Reality"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep05_celebration/audio/segments_v2/seg17_drawing_by_hand.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(STATE_SINCERE_WARMTH, 1.2)

	# V2 Setup: Standing contrapposto beside creator desk, phone placed down
	setup_studio_furniture(false)

	nemi.reset()
	nemi.position = Vector2(540, 430)
	nemi.set_pose("relaxed_standing_left_weight", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# LIVE DOODLE: Organic hand-drawn "DRAWN BY HAND / FRAME BY FRAME" card in clean upper right wall space
	var card = live_physical_card(Vector2(930, 190), "DRAWN BY HAND\nFRAME BY FRAME", true, 0.8)

	# ----------------------------------------------------
	# Segment 17: "When you sit alone drawing every single frame by hand, this kind of support means everything to me." (7.20s)
	# ----------------------------------------------------
	play_segment("seg17_drawing_by_hand")

	# Card 1: "When you sit alone" (1.32s)
	nemi.head_tilt(-4.0, 0.25)
	await wait_seconds(1.32)

	# Card 2: "drawing every single frame" (2.03s)
	nemi.look("down_right") # Looking at drawing on desk
	nemi.set_expression("tender")
	nemi.set_pose("thinking_chin_tap", 0.2)
	cam_push_in(0.15, 6.0)
	await wait_seconds(2.03)

	# Card 3: "by hand," (0.53s)
	nemi.look("center")
	await wait_seconds(0.53)

	# Card 4: "this kind of support" (1.50s)
	nemi.set_pose("overwhelmed_chest_touch", 0.2)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.HAND_TO_CHEST)
	nemi.set_expression("warm")
	nemi.show_blush(true)
	await wait_seconds(1.50)

	# Card 5: "means everything to me." (1.67s)
	nemi.set_expression("smile")
	nemi.head_tilt(5.0, 0.25)
	nemi.look("center")
	await wait_seconds(1.67)

	# Quiet sincere hold (0.60s): Deep heartfelt stillness hold
	nemi.stop_speech()
	await wait_seconds(0.60)

	end_beat()
