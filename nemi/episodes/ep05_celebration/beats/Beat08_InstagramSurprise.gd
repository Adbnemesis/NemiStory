class_name Beat08InstagramSurprise
extends "res://nemi/episodes/ep05_celebration/Ep05BaseBeat.gd"

## Beat 8: The Instagram 250 Followers Surprise (73.85s – 77.44s | Duration: 3.59s)
## Segments:
## - seg16_instagram_surprise (3.04s): "And then Instagram hit two hundred and fifty followers too!"

func _ready() -> void:
	beat_number = 8
	beat_name = "Instagram Surprise"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep05_celebration/audio/segments_v2/seg16_instagram_surprise.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(STATE_CELEBRATION_WALL, 0.0)

	# V2 Setup: Standing contrapposto beside creator desk
	setup_studio_furniture(false)

	nemi.reset()
	nemi.position = Vector2(540, 430)
	nemi.set_pose("relaxed_standing_left_weight", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# ----------------------------------------------------
	# Segment 16: "And then Instagram hit two hundred and fifty followers too!" (3.04s)
	# ----------------------------------------------------
	play_segment("seg16_instagram_surprise")

	# Card 1: "And then Instagram hit" (1.10s)
	nemi.look("center")
	nemi.set_expression("surprised")
	nemi.head_tilt(-5.0, 0.25)
	await wait_seconds(1.10)

	# Card 2: "two hundred and fifty" (1.04s)
	cam_punch(Vector2(-12, 0), 1.25, 0.2)
	# Physical reveal: Nemi holds up phone displaying glowing Instagram 250 Followers screen!
	show_phone(HumanProps.StoryPhone.ScreenState.INSTAGRAM, 4.0)
	nemi.set_pose("shy_phone_confession", 0.15)
	nemi.set_expression("shocked")
	await wait_seconds(1.04)

	# Card 3: "followers too!" (0.75s)
	nemi.set_expression("excited")
	nemi.look("center")
	# Left hand fist pump in celebration!
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.FIST)
	nemi.show_blush(true)
	await wait_seconds(0.75)

	# Post-dialogue pause hold (0.70s): Joyful celebratory stillness hold, stows phone away!
	nemi.stop_speech()
	hide_phone()
	nemi.set_pose("excited_anticipation", 0.2)
	await wait_seconds(0.70)

	end_beat()
