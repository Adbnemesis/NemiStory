class_name Ep02Beat01Secret
extends "res://nemi/episodes/ep02_partner/beats/Ep02BaseBeat.gd"

## Beat 1: The Secret (0.00s – 7.08s | 7.08s)
## Segments: 001 ("Okay... I have a secret."), 002 ("Do not tell anyone."), 003 ("I have a partner.")
## Staging: Nemi leans close toward camera in conspiratorial whisper, dark ink lock doodle clicks open.

var lock_doodle: Node2D

func _run_beat_choreography() -> void:
	beat_number = 1
	beat_name = "The Secret"
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, 0.0)
		
	nemi.position = Vector2(640, 500)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")
	
	# SEGMENT 001 (3.44s + 0.40s pause = 3.84s)
	# "Okay... I have a secret."
	await wait_seconds(0.15)
	nemi.blink(0.12)
	
	# Conspiratorial forward lean
	var tw_lean := create_tween().set_parallel(true)
	tw_lean.tween_property(nemi, "position:y", 345.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.lean(7.0, 0.35)
	nemi.set_expression("whisper")
	
	play_segment("001")
	await wait_seconds(1.20) # "Okay..."
	
	# Hand-drawn lock doodle appears on "I have a secret."
	lock_doodle = Ep02DoodlesClass.spawn_lock(self, Vector2(780, 210), 0.30)
	nemi.set_expression("secret")
	await wait_seconds(2.24) # "I have a secret."
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 002 (1.28s + 0.50s pause = 1.78s)
	# "Do not tell anyone."
	play_segment("002")
	nemi.gesture_thinking(0.22)
	nemi.blink(0.10)
	await wait_seconds(1.28)
	await wait_seconds(0.50) # Pause
	
	# SEGMENT 003 (0.96s + 0.50s pause = 1.46s)
	# "I have a partner."
	play_segment("003")
	nemi.set_expression("proud_smirk")
	nemi.head_tilt(6.0, 0.20)
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.15, 0.18)
		
	# Lock clicks open
	if is_instance_valid(lock_doodle):
		var tw_unlock := create_tween()
		tw_unlock.tween_property(lock_doodle, "scale", Vector2(1.1, 1.1), 0.15)
		tw_unlock.tween_property(lock_doodle, "scale", Vector2.ONE, 0.15)
		
	await wait_seconds(0.96)
	await wait_seconds(0.50) # Pause hold
	
	if is_instance_valid(lock_doodle):
		var tw_fade := create_tween()
		tw_fade.tween_property(lock_doodle, "modulate:a", 0.0, 0.25)
		tw_fade.tween_callback(lock_doodle.queue_free)
		
	end_beat()
