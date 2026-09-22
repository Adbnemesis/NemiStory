class_name Beat01RawConfession
extends Ep04BaseBeat

## Beat 1: Raw Confession (0.00s – 9.92s)
## seg01_terrified: "Okay, so... I don't know how to say this without sounding dramatic, but... I'm kind of terrified."
## Dialogue Duration: 9.52s + 0.40s pause = 9.92s

func _ready() -> void:
	beat_number = 1
	beat_name = "Raw Confession"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep04_scared/audio/segments/seg01_terrified.wav")
		voice_player.play(0.0)

	# 1. Staging & Initial Framing
	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)

	# Rich cozy props on desk and sketchbook wall
	var mug = coffee_mug(Vector2(450, 490))
	var note = sticky_note("TODO:\nsurvive 1st video", Vector2(760, 170), 3.5)

	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# Subtle attention hook: eyes notice camera, blink, slight forward lean
	await wait_seconds(0.15)
	nemi.blink(0.18)
	await wait_seconds(0.20)
	nemi.lean(6.0, 0.25)
	nemi.hands_together()

	# 2. Start Subtitle Cards and Voice Lip-Sync (Total 9.52s)
	play_segment("seg01_terrified")

	# Card 1: "Okay, so..." (1.80s)
	await wait_seconds(1.20)
	nemi.head_tilt(-5.0, 0.3)
	await wait_seconds(0.60) # 1.80s reached

	# Card 2: "I don't know" (1.40s)
	nemi.set_expression("confused")
	nemi.eye_dart("left", 0.2)
	await wait_seconds(1.40) # 3.20s reached

	# Card 3: "how to say this" (1.60s)
	nemi.look("center")
	nemi.head_tilt(4.0, 0.25)
	await wait_seconds(1.60) # 4.80s reached

	# Card 4: "without sounding dramatic," (2.10s)
	cam_push_in(0.18, 4.0)
	nemi.set_expression("smile")
	nemi.head_tilt(-6.0, 0.3)
	nemi.eye_dart("down_right", 0.25)
	nemi.gesture_open_palm("right", 0.3)
	await wait_seconds(2.10) # 6.90s reached

	# Spawn cute cat mascot on desk area
	var cat = cat_mascot(Vector2(380, 520))

	# Card 5: "but... I'm kind of terrified." (2.62s)
	# Comic punch zoom + nervous camera shake
	cam_punch(Vector2(0, -18), 1.20, 0.25)
	cam_shake(6.0, 0.35, 22.0)

	nemi.set_expression("scared")
	nemi.head_turn(0.0, 0.2)
	nemi.look("center")
	
	# Hand-drawn animated panic gauge with trembling red needle!
	var meter = panic_meter(Vector2(210, 230))
	var bubble = action_bubble("*PANIK*", Vector2(260, 130))
	comic_sweat(Vector2(22, -90), 1.0)

	await wait_seconds(2.62) # 9.52s reached (dialogue complete)

	# 3. Post-dialogue pause (0.40s)
	nemi.stop_speech()
	var fade_tw := create_tween()
	if meter and is_instance_valid(meter):
		fade_tw.tween_property(meter, "modulate:a", 0.0, 0.25)
	if bubble and is_instance_valid(bubble):
		fade_tw.parallel().tween_property(bubble, "modulate:a", 0.0, 0.25)
	if note and is_instance_valid(note):
		fade_tw.parallel().tween_property(note, "modulate:a", 0.0, 0.25)
	await wait_seconds(0.40) # 9.92s reached

	end_beat()

