class_name Beat02SevenViewsFlashback
extends "res://nemi/episodes/ep05_celebration/Ep05BaseBeat.gd"

## Beat 2: The 2 AM 7-Views Flashback (9.54s – 20.73s | Duration: 11.19s)
## Segments:
## - seg03_last_week_seven_views (6.96s): "Because literally last week, I was refreshing at two in the morning, staring at seven views."
## - seg04_from_my_own_phone (3.28s): "And honestly? Three of those were from my own phone."

func _ready() -> void:
	beat_number = 2
	beat_name = "7-Views Flashback"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep05_celebration/audio/segments_v2/seg03_last_week_seven_views.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(STATE_NORMAL_STUDIO, 0.0)

	# V2 Setup: Creator desk, chair behind, standing in contrapposto beside desk
	setup_studio_furniture(false)

	nemi.reset()
	nemi.position = Vector2(540, 430)
	nemi.set_pose("relaxed_standing_left_weight", 0.0)
	nemi.set_expression("candid")
	nemi.look("center")

	# ----------------------------------------------------
	# Segment 03: "Because literally last week, I was refreshing at two in the morning, staring at seven views." (6.96s)
	# ----------------------------------------------------
	play_segment("seg03_last_week_seven_views")

	# Card 1: "Because literally last week," (2.20s)
	nemi.head_tilt(-5.0, 0.25)
	await wait_seconds(2.20)

	# Card 2: "I was refreshing" (1.28s)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.look("center")
	await wait_seconds(1.28)

	# Card 3: "at two in the morning," (1.56s) - Environmental interaction: coffee sip at 2 AM
	take_coffee_sip()
	nemi.set_expression("deadpan")
	await wait_seconds(1.56)

	# Card 4: "staring at seven views..." (1.74s) - Places mug down on desk & points up-right
	detach_mug_to_desk()
	cam_punch(Vector2(0, -10), 1.20, 0.15)
	nemi.set_pose("pointing_low_doodle", 0.2)
	nemi.look("up_right")
	
	# LIVE DOODLE: Organic hand-drawn cursive "7 VIEWS" in clean upper right wall space
	if human_doodles_layer:
		human_doodles_layer.draw_word("7 VIEWS", Vector2(800, 180), 48.0, 0.5)
		human_doodles_layer.draw_emphasis_circle(Vector2(880, 200), Vector2(110, 50), 0.4)
	await wait_seconds(1.74)

	# Pause between seg03 and seg04 (0.58s)
	nemi.stop_speech()
	await wait_seconds(0.58)

	# ----------------------------------------------------
	# Segment 04: "And honestly? Three of those were from my own phone." (3.28s)
	# ----------------------------------------------------
	play_segment("seg04_from_my_own_phone")

	# Card 1: "And honestly?" (0.89s)
	cam_punch(Vector2(0, -12), 1.30, 0.15)
	nemi.set_pose("counting_three", 0.2)
	nemi.set_expression("smug")
	nemi.head_tilt(7.0, 0.2)
	await wait_seconds(0.89)

	# Card 2: "Three of those were" (1.18s)
	# Clear silhouette hold of 3 fingers against negative space
	await wait_seconds(1.18)

	# Card 3: "from my own phone." (1.03s)
	# Physical pickup: Nemi brings up phone with glowing 7-views screen to show audience
	show_phone(HumanProps.StoryPhone.ScreenState.VIEWS_RECAP, 4.0)
	nemi.set_pose("shy_phone_confession", 0.2)
	nemi.show_blush(true)
	nemi.look("center")
	await wait_seconds(1.03)

	# Post-dialogue deadpan comedy hold (0.73s): Stows phone away cleanly!
	nemi.stop_speech()
	hide_phone()
	nemi.set_pose("deadpan_camera_stare", 0.1)
	await wait_seconds(0.73)

	end_beat()
