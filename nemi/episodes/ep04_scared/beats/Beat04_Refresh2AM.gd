class_name Beat04Refresh2AM
extends Ep04BaseBeat

## Beat 4: The 2 AM Refresh (24.33s – 33.42s)
## seg04_refresh_2am: "...and then I refresh at two AM, and it's seven views. Half of them from my phone."
## Dialogue Duration: 8.64s + 0.45s pause = 9.09s

var views_card: Node2D = null

func _ready() -> void:
	beat_number = 4
	beat_name = "The 2 AM Refresh"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep04_scared/audio/segments/seg04_refresh_2am.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)

	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# Start subtitle cards and live illustrative speech
	play_segment("seg04_refresh_2am")

	# Card 1: "...and then I refresh" (1.80s)
	views_card = Ep04Doodles.spawn_views_refresh(self, Vector2(840, 260))
	nemi.gesture_open_palm("right", 0.25)
	await wait_seconds(1.80) # 1.80s reached

	# Card 2: "at two AM," (1.40s)
	nemi.look("right")
	nemi.head_tilt(-6.0, 0.25)
	set_night_mode(true, 0.35)
	var phone = notification_buzz(Vector2(260, 480))
	await wait_seconds(1.40) # 3.20s reached

	# Card 3: "and it's seven views." (2.20s)
	# Comedic punch zoom and instant deadpan face
	cam_punch(Vector2(0, -25), 1.30, 0.12)
	nemi.set_expression("deadpan")
	nemi.look("center")
	nemi.head_tilt(0.0, 0.05)
	var views_note = sticky_note("7 VIEWS\n(3 are my mom)", Vector2(230, 230), -6.0)
	await wait_seconds(2.20) # 5.40s reached

	# Card 4: "Half of them" (1.40s)
	if views_card and is_instance_valid(views_card) and views_card.has_method("reveal_phone_callout"):
		views_card.reveal_phone_callout(0.25)
	nemi.eye_dart("down_right", 0.3)
	nemi.set_expression("embarrassed")
	comic_sweat(Vector2(28, -95), 1.0)
	await wait_seconds(1.40) # 6.80s reached

	# Card 5: "from my phone." (1.84s)
	nemi.set_expression("deadpan")
	nemi.look("center")
	# Tiny cute soul floats out of mouth from exhaustion/cringe
	comic_soul(Vector2(6, -55), 2.2)
	var sigh_bubble = action_bubble("*sigh*", Vector2(280, 160))
	await wait_seconds(1.84) # 8.64s reached (dialogue complete)

	# Post-dialogue pause (0.45s)
	nemi.stop_speech()
	var fade_tw := create_tween()
	if views_card and is_instance_valid(views_card) and views_card.has_method("fade_out"):
		views_card.fade_out(0.25)
	if views_note and is_instance_valid(views_note):
		fade_tw.tween_property(views_note, "modulate:a", 0.0, 0.25)
	if sigh_bubble and is_instance_valid(sigh_bubble):
		fade_tw.parallel().tween_property(sigh_bubble, "modulate:a", 0.0, 0.25)
	if phone and is_instance_valid(phone):
		fade_tw.parallel().tween_property(phone, "modulate:a", 0.0, 0.25)
	await wait_seconds(0.45) # 9.09s reached

	end_beat()
