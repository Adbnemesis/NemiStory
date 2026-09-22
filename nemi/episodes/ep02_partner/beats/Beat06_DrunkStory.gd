class_name Ep02Beat06DrunkStory
extends "res://nemi/episodes/ep02_partner/beats/Ep02BaseBeat.gd"

## Beat 6: The Drunk Story (38.55s – 48.34s | 9.79s)
## Segments: 011 ("And then... one day, we got drunk."), 012 ("...And things happened.")
## Staging: Drink glasses clink with wobble lines, sudden blackout stamp,
## instant cut back to Nemi & ADB staring directly into lens in 1.5s deadpan silence with straight dash mouths.

const PropDrinkGlassesClass = preload("res://nemi/episodes/ep02_partner/props/PropDrinkGlasses.gd")

var drink_glasses: Node2D
var blackout_rect: ColorRect

func _run_beat_choreography() -> void:
	beat_number = 6
	beat_name = "The Drunk Story"
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
		
	nemi.position = Vector2(490, 500)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("whisper")
	
	if adb:
		adb.position = Vector2(790, 356)
		adb.set_pose("cool_swagger", 0.0)
		adb.set_expression("neutral", 0.0)
		adb.look("camera")
		
	# Blackout overlay
	blackout_rect = ColorRect.new()
	blackout_rect.color = Color(0.12, 0.11, 0.10, 1.0)
	blackout_rect.size = Vector2(1920, 1080)
	blackout_rect.position = Vector2(-300, -200)
	blackout_rect.visible = false
	add_child(blackout_rect)
	
	# SEGMENT 011 (5.92s + 0.45s pause = 6.37s)
	# "And then... one day, we got drunk."
	print("[BEAT06] Playing segment 011...")
	play_segment("011")
	print("[BEAT06] Waiting 1.80s...")
	await wait_seconds(1.80) # "And then..."
	print("[BEAT06] Waiting 1.50s...")
	await wait_seconds(1.50) # "one day,"
	print("[BEAT06] Spawning drink glasses...")
	
	# Spawn drink glasses on "we got drunk."
	drink_glasses = PropDrinkGlassesClass.new()
	drink_glasses.position = Vector2(640, 270)
	drink_glasses.scale = Vector2(1.3, 1.3)
	add_child(drink_glasses)
	print("[BEAT06] Drink glasses added to tree!")
	
	if drink_glasses.has_method("clink"):
		drink_glasses.clink(0.40)
		
	var swirl_doodle := Ep02DoodlesClass.spawn_drunken_swirls(self, Vector2(640, 190), 0.35)
	print("[BEAT06] Swirl doodle added!")
	
	nemi.set_expression("amused")
	if adb:
		adb.set_expression("smug", 0.20)
		adb.head_tilt_to(-4.0, 0.20)
		
	print("[BEAT06] Waiting 2.62s...")
	await wait_seconds(2.62) # "we got drunk."
	print("[BEAT06] Waiting 0.45s pause...")
	await wait_seconds(0.45) # Pause
	
	if is_instance_valid(swirl_doodle):
		swirl_doodle.queue_free()
		
	# SEGMENT 012 (1.92s + 1.50s pause = 3.42s)
	# "...And things happened."
	play_segment("012")
	nemi.look("center")
	
	await wait_seconds(1.92) # "...And things happened."
	
	# SUDDEN BLACKOUT CUT / COMEDIC STAMP (for 0.20s)
	if is_instance_valid(drink_glasses):
		drink_glasses.queue_free()
	blackout_rect.visible = true
	await wait_seconds(0.20)
	blackout_rect.visible = false
	
	# SNAP BACK TO PUNCH CLOSE-UP WITH TOTAL DEADPAN SILENCE
	if camera and camera.has_method("punch_zoom"):
		camera.punch_zoom(1.40, 0.0) # Instant 0-frame cut!
		
	nemi.set_pose("deadpan", 0.0)
	nemi.set_expression("deadpan")
	nemi.look("center")
	
	if adb:
		adb.set_pose("deadpan", 0.0)
		adb.set_expression("deadpan", 0.0)
		adb.look("camera")
		
	# THE GOLDEN 1.5-SECOND DEADPAN SILENCE HOLD
	print("[DEADPAN] Total stillness hold: 1.50 seconds")
	nemi.freeze_stillness(1.30)
	if adb:
		adb.freeze_stillness(1.30)
		
	await wait_seconds(1.30) # Remaining pause hold
	
	end_beat()
