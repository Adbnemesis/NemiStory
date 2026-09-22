class_name Ep02Beat05GettingCloser
extends "res://nemi/episodes/ep02_partner/beats/Ep02BaseBeat.gd"

## Beat 5: Getting Closer (29.49s – 38.55s | 9.06s)
## Segments: 009 ("At first it was just casual chatting."), 010 ("Then we realized... our brains are wired...")
## Staging: Matching thought connection, hand-drawn puzzle pieces clicking together, shared eye contact.

var puzzle_doodle: Node2D

func _run_beat_choreography() -> void:
	beat_number = 5
	beat_name = "Getting Closer"
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
		
	nemi.position = Vector2(490, 500)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("warm")
	nemi.look("center")
	
	if adb:
		adb.position = Vector2(790, 356)
		adb.set_pose("cool_swagger", 0.0)
		adb.set_expression("neutral", 0.0)
		adb.look("nemi")
		
	# SEGMENT 009 (1.84s + 0.35s pause = 2.19s)
	# "At first it was just casual chatting."
	play_segment("009")
	nemi.gesture_open_palm("right", 0.25)
	await wait_seconds(1.84)
	await wait_seconds(0.35) # Pause
	
	# SEGMENT 010 (6.32s + 0.55s pause = 6.87s)
	# "Then we realized... our brains are wired in the exact same chaotic way."
	play_segment("010")
	nemi.set_expression("warm")
	await wait_seconds(1.60) # "Then we realized..."
	
	# Brain electricity doodle sparks across
	var electric_doodle := Ep02DoodlesClass.spawn_brain_electricity(self, Vector2(640, 210), 0.25)
	await wait_seconds(0.60)
	
	# Puzzle pieces doodle draws and snaps together on "our brains are wired..."
	puzzle_doodle = Ep02DoodlesClass.spawn_puzzle_pieces(self, Vector2(640, 210), 0.35)
	nemi.look("adb")
	nemi.set_expression("smiling")
	
	if adb:
		adb.head_tilt_to(-4.0, 0.22)
		adb.set_expression("smug", 0.20)
		adb.set_pose("supportive_nod", 0.25)
		
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.18, 0.20)
		
	await wait_seconds(4.12) # "our brains are wired in the exact same chaotic way."
	await wait_seconds(0.55) # Pause hold
	
	if is_instance_valid(electric_doodle):
		electric_doodle.queue_free()
	
	if is_instance_valid(puzzle_doodle):
		var tw := create_tween()
		tw.tween_property(puzzle_doodle, "modulate:a", 0.0, 0.25)
		tw.tween_callback(puzzle_doodle.queue_free)
		
	end_beat()
