class_name Ep02Beat09HelpingEachOther
extends "res://nemi/episodes/ep02_partner/beats/Ep02BaseBeat.gd"

## Beat 9: Helping Each Other (82.16s – 88.98s | 6.82s)
## Segments: 019 ("Whenever things get chaotic..."), 020 ("No matter what happens, we help each other through it.")
## Staging: Warm supportive connection, two-way flowing arrows, sincere grounded nods.

var arrows_doodle: Node2D

func _run_beat_choreography() -> void:
	beat_number = 9
	beat_name = "Helping Each Other"
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
		
	nemi.position = Vector2(490, 500)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("warm")
	nemi.look("center")
	
	if adb:
		adb.position = Vector2(790, 356)
		adb.set_pose("supportive_nod", 0.0)
		adb.set_expression("neutral", 0.0)
		adb.look("nemi")
		
	# SEGMENT 019 (3.52s + 0.40s pause = 3.92s)
	# "Whenever things get chaotic, we're always backing each other up."
	play_segment("019")
	nemi.gesture_open_palm("right", 0.25)
	
	# Protective umbrella doodle shelters both
	var umbrella_doodle := Ep02DoodlesClass.spawn_umbrella(self, Vector2(640, 190), 0.35)
	await wait_seconds(1.60)
	
	# Two-way help arrows draw between them
	arrows_doodle = Ep02DoodlesClass.spawn_help_arrows(self, Vector2(640, 260), 0.30)
	
	await wait_seconds(1.92)
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 020 (2.40s + 0.50s pause = 2.90s)
	# "No matter what happens, we help each other through it."
	play_segment("020")
	nemi.look("adb")
	nemi.set_expression("smiling")
	
	if adb:
		adb.head_tilt_to(4.0, 0.22)
		adb.set_expression("smug", 0.20)
		adb.set_pose("supportive_nod", 0.25)
		
	await wait_seconds(2.40)
	await wait_seconds(0.50) # Pause hold
	
	if is_instance_valid(umbrella_doodle):
		umbrella_doodle.queue_free()
	if is_instance_valid(arrows_doodle):
		var tw := create_tween()
		tw.tween_property(arrows_doodle, "modulate:a", 0.0, 0.20)
		tw.tween_callback(arrows_doodle.queue_free)
		
	end_beat()
