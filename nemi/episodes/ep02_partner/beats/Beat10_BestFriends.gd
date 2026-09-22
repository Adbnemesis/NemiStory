class_name Ep02Beat10BestFriends
extends "res://nemi/episodes/ep02_partner/beats/Ep02BaseBeat.gd"

## Beat 10: Best Friends & Secret Callback (88.98s – 102.06s | 13.08s)
## Segments: 021 ("So yeah. My partner... and my absolute best friend."), 022 ("Okay... now you know. Keep it between us.")
## Staging: Nemi and ADB stand together, connected doodle figures draw beneath them,
## secret callback wink to viewer, gentle settle into stillness.

var pair_doodle: Node2D

func _run_beat_choreography() -> void:
	beat_number = 10
	beat_name = "Best Friends & Secret Callback"
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
		
	nemi.position = Vector2(500, 500)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("warm")
	
	if adb:
		adb.position = Vector2(780, 356)
		adb.set_pose("cool_swagger", 0.0)
		adb.set_expression("neutral", 0.0)
		adb.look("nemi")
		
	# SEGMENT 021 (7.52s + 0.50s pause = 8.02s)
	# "So yeah. My partner... and my absolute best friend."
	play_segment("021")
	await wait_seconds(1.60) # "So yeah."
	
	# Nemi looks warmly at ADB
	nemi.look("adb")
	nemi.set_expression("smiling")
	await wait_seconds(2.12) # "My partner..."
	
	# Connected stick figures doodle draws beneath them
	pair_doodle = Ep02DoodlesClass.spawn_connected_pair(self, Vector2(640, 260), 0.40)
	
	if adb:
		adb.set_expression("smug", 0.20)
		adb.head_tilt_to(-3.0, 0.20)
		
	await wait_seconds(3.80) # "and my absolute best friend."
	await wait_seconds(0.50) # Pause hold
	
	# SEGMENT 022 (4.56s + 1.00s pause = 5.56s)
	# "Okay... now you know. Keep it between us."
	play_segment("022")
	nemi.look("center")
	nemi.set_expression("secret")
	await wait_seconds(1.30) # "Okay..."
	await wait_seconds(1.50) # "now you know."
	
	# Conspiratorial wink and secret tap to lens
	nemi.head_tilt(5.0, 0.20)
	nemi.blink(0.15)
	if adb:
		adb.look("camera")
		adb.set_pose("goggles_tip", 0.20)
		adb.set_expression("smug", 0.20)
		adb.blink(0.12)
		
	await wait_seconds(1.76) # "Keep it between us."
	
	# Final 1.0s peaceful hold in total stillness
	nemi.freeze_stillness(0.90)
	if adb:
		adb.freeze_stillness(0.90)
	await wait_seconds(0.90)
	
	end_beat()
