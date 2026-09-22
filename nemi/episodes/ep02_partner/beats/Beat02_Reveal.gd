class_name Ep02Beat02Reveal
extends "res://nemi/episodes/ep02_partner/beats/Ep02BaseBeat.gd"

## Beat 2: The Reveal (7.08s – 9.84s | 2.76s)
## Segment 004: "The person I met... is ADB."
## Staging: Camera reframes to two-shot, Nemi gestures right, ADB revealed in cool posture,
## gives tiny cute wave & blink, then smoothly settles into cool composure.

func _run_beat_choreography() -> void:
	beat_number = 2
	beat_name = "The Reveal"
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.WIDE, 0.20)
		
	nemi.position = Vector2(460, 500)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("happy")
	
	if adb:
		adb.position = Vector2(1050, 356) # Start off-screen right
		adb.set_pose("cool_swagger", 0.0)
		adb.set_expression("neutral", 0.0)
		adb.look("camera")
		
	# SEGMENT 004 (2.16s + 0.60s pause = 2.76s)
	# "The person I met... is ADB."
	play_segment("004")
	
	# Nemi turns slightly and extends presenting open palm rightward
	nemi.gesture_open_palm("right", 0.25)
	nemi.head_tilt(5.0, 0.20)
	
	# ADB slides in from off-screen right with cool swagger
	if adb:
		var tw_slide := create_tween()
		tw_slide.tween_property(adb, "position:x", 780.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
	await wait_seconds(1.20) # "The person I met..."
	
	# On "is ADB." ADB reacts: tips cool goggles with glint, confident smirk
	if adb:
		adb.set_pose("goggles_tip", 0.20)
		adb.set_expression("smug", 0.18)
		adb.blink(0.10)
		adb.head_tilt_to(4.0, 0.18)
		
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.16, 0.18)
		
	await wait_seconds(0.96) # "is ADB."
	
	# 0.60s Pause hold: ADB transitions into cool swagger pose with confident gaze
	if adb:
		adb.set_pose("cool_swagger", 0.25)
		adb.set_expression("smug", 0.20)
		
	await wait_seconds(0.60)
	end_beat()
