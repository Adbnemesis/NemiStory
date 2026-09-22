class_name Ep03Beat03Overconfidence
extends "res://nemi/episodes/ep03_scolded/Ep03BaseBeat.gd"

## Beat 3: Theoretical Overconfidence (22.34s – 33.43s | Duration: 11.09s)
## Segments:
## - 006: "Now, two PM was four hours away. That is basically infinite time." (6.24s + 0.35s)
## - 007: "I told myself: I have full control over this situation." (4.00s + 0.50s)

var crown_doodle: Node2D

func _init() -> void:
	beat_number = 3
	beat_name = "Theoretical Overconfidence"

func _run_beat_choreography() -> void:
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, 0.0)
		
	nemi.position = Vector2(640, 480)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("talking")
	nemi.look("center")
	
	# SEGMENT 006 (6.24s + 0.35s = 6.59s)
	play_segment("006")
	await wait_seconds(1.8)
	nemi.set_expression("smug")
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.lean(-4.0, 0.25)
		
	await wait_seconds(2.0)
	nemi.blink(0.12)
	await wait_seconds(2.44)
	await wait_seconds(0.35) # Pause
	
	# SEGMENT 007 (4.00s + 0.50s = 4.50s)
	# "I told myself: I have full control over this situation."
	play_segment("007")
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.18, 0.20)
		
	nemi.set_expression("excited")
	# Spawn golden crown doodle
	crown_doodle = Ep03DoodlesClass.spawn_crown_and_sparkles(self, Vector2(640, 210), 0.25)
	
	await wait_seconds(4.00)
	await wait_seconds(0.50) # Pause hold
	
	if is_instance_valid(crown_doodle):
		var tw_fade := create_tween()
		tw_fade.tween_property(crown_doodle, "modulate:a", 0.0, 0.25)
		tw_fade.tween_callback(crown_doodle.queue_free)
		
	end_beat()
