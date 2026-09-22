class_name Beat09CasualSignoff
extends Ep04BaseBeat

## Beat 9: Casual Signoff & Outro (62.80s – 73.20s)
## seg09_signoff: "So yeah, wish me luck. Okay, bye!"
## Dialogue Duration: 9.60s + 0.80s pause = 10.40s

func _ready() -> void:
	beat_number = 9
	beat_name = "Casual Signoff"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep04_scared/audio/segments/seg09_signoff.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)

	# Steaming coffee mug on desk
	var mug = coffee_mug(Vector2(460, 490))

	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("warm")
	nemi.look("center")

	# Start subtitle cards and live illustrative speech
	play_segment("seg09_signoff")

	# Card 1: "So yeah," (2.20s)
	nemi.head_tilt(5.0, 0.3)
	await wait_seconds(2.20) # 2.20s reached

	# Spawn cute cat mascot on desk waving
	var cat = cat_mascot(Vector2(340, 520))

	# Card 2: "wish me luck." (2.40s)
	nemi.set_expression("happy")
	nemi.nod(0.8, 0.35)
	nemi.hands_together()
	comic_sparkles(Vector2(640, 240), 2.2)
	var signoff = Ep04Doodles.spawn_signoff(self, Vector2(860, 270))
	var thanks_note = sticky_note("Thank you for\nwatching!! ♡", Vector2(210, 230), -3.0)
	await wait_seconds(2.40) # 4.60s reached

	# Card 3: "Okay, bye!" (5.00s)
	nemi.set_expression("excited")
	nemi.wave("right", 5)
	var bye_bubble = action_bubble("*BYE!! :3*", Vector2(860, 130))
	var hearts = heart_burst(Vector2(530, 260))
	comic_sparkles(Vector2(780, 290), 2.0)
	if doodle_director:
		doodle_director.emphasis(Vector2(740, 360), 32.0, 0.25)
	await wait_seconds(2.50)
	
	# Smooth cinematic pull-back to wide view of the warm sketchbook studio
	cam_preset(StoryCamera2D.ShotPreset.WIDE, 2.3)
	nemi.set_pose("casual_standing", 0.3)
	nemi.set_expression("happy")
	await wait_seconds(2.50) # 9.60s reached (dialogue complete)

	# Post-dialogue pause / outro hold (0.80s)
	nemi.stop_speech()
	await wait_seconds(0.80) # 10.40s reached

	end_beat()
