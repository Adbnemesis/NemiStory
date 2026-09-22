class_name Ep02Beat08MutualIrritation
extends "res://nemi/episodes/ep02_partner/beats/Ep02BaseBeat.gd"

## Beat 8: Mutual Irritation & Balance (64.95s – 82.16s | 17.21s)
## Segments: 016 ("Now... does ADB irritate me..."), 017 ("Every single day."), 018 ("But I also irritate ADB...")
## Staging: ADB teases Nemi with playful poke, Nemi reacts with deadpan glare + tiny stress mark,
## Nemi acts goofy, ADB delivers deadpan eyebrow cock, balance scale locks at 50/50.

var balance_doodle: Node2D

func _run_beat_choreography() -> void:
	beat_number = 8
	beat_name = "Mutual Irritation & Balance"
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.WIDE, 0.20)
		
	nemi.position = Vector2(480, 500)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("skeptical")
	
	if adb:
		adb.position = Vector2(800, 356)
		adb.set_pose("cool_swagger", 0.0)
		adb.set_expression("smug", 0.0)
		adb.look("nemi")
		
	# SEGMENT 016 (5.04s + 0.40s pause = 5.44s)
	# "Now... does ADB irritate me sometimes? Absolutely."
	play_segment("016")
	await wait_seconds(1.40) # "Now... does ADB"
	
	# ADB playfully pokes toward Nemi with tease poker doodle
	var poke_doodle: Node2D
	if adb:
		adb.set_pose("teasing_poke", 0.22)
		adb.set_expression("smug", 0.18)
		poke_doodle = Ep02DoodlesClass.spawn_tease_poker(self, Vector2(620, 290), 0.22)
		
	# Nemi dry glare sideways with tiny anger mark
	nemi.look("adb")
	nemi.set_expression("annoyed")
	nemi.fx("anger", "head_right", 2, 1.8)
	await wait_seconds(1.94) # "irritate me sometimes?"
	
	if is_instance_valid(poke_doodle):
		poke_doodle.queue_free()
		
	# On "Absolutely." -> Snap to camera
	nemi.look("center")
	nemi.set_expression("deadpan")
	await wait_seconds(1.70) # "Absolutely."
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 017 (1.52s + 0.45s pause = 1.97s)
	# "Every single day."
	play_segment("017")
	nemi.head_tilt(-8.0, 0.20)
	await wait_seconds(1.52)
	await wait_seconds(0.45) # Pause
	
	# SEGMENT 018 (9.20s + 0.60s pause = 9.80s)
	# "But I also irritate ADB every single day. So the balance is completely even."
	play_segment("018")
	
	# Nemi turns smug and acts goofy
	nemi.set_expression("smug")
	nemi.head_tilt(8.0, 0.20)
	
	# ADB now gives unimpressed deadpan eyebrow cock
	if adb:
		adb.set_pose("deadpan_freeze", 0.22)
		adb.set_expression("deadpan", 0.18)
		adb.look("camera")
		
	await wait_seconds(4.20) # "But I also irritate ADB every single day."
	
	# On "So the balance is completely even." -> Balance scale doodle draws
	balance_doodle = Ep02DoodlesClass.spawn_balance_scale(self, Vector2(640, 180), 0.35)
	
	# Both look at camera in shared comedic balance
	nemi.look("center")
	nemi.set_expression("deadpan")
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.15, 0.20)
		
	await wait_seconds(5.00) # "So the balance is completely even."
	await wait_seconds(0.60) # Pause hold
	
	if is_instance_valid(balance_doodle):
		var tw := create_tween()
		tw.tween_property(balance_doodle, "modulate:a", 0.0, 0.25)
		tw.tween_callback(balance_doodle.queue_free)
		
	end_beat()
