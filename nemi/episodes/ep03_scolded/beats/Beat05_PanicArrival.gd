class_name Ep03Beat05PanicArrival
extends "res://nemi/episodes/ep03_scolded/Ep03BaseBeat.gd"

## Beat 5: The Driveway Crunch (42.75s – 51.35s | Duration: 8.60s)
## Segments:
## - 010: "And that was the exact moment I heard gravel crunch in the driveway." (4.72s + 0.40s)
## - 011: "Followed by the car door slamming shut." (2.08s + 1.40s)

var soundwaves_doodle: Node2D

func _init() -> void:
	beat_number = 5
	beat_name = "The Driveway Crunch"

func _run_beat_choreography() -> void:
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, 0.0)
		
	nemi.position = Vector2(640, 480)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("shocked")
	nemi.look("center")
	
	# SEGMENT 010 (4.72s + 0.40s = 5.12s)
	play_segment("010")
	# Head snaps to right window
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.turn(18.0, "fast")
	nemi.look("right")
	
	# Soundwave shockwaves doodle
	soundwaves_doodle = Ep03DoodlesClass.spawn_car_soundwaves(self, Vector2(760, 280), 0.22)
	
	await wait_seconds(4.72)
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 011 (2.08s + 1.40s = 3.48s)
	# "Followed by the car door slamming shut."
	play_segment("011")
	# Extreme punch zoom onto face
	if camera and camera.has_method("reaction_closeup"):
		camera.reaction_closeup(nemi.global_position + Vector2(0, -90), 1.55, 0.12)
		
	nemi.set_expression("deadpan")
	nemi.look("camera")
	
	await wait_seconds(2.08)
	
	# Deadpan hold in absolute stillness for 1.4s
	await wait_seconds(1.40)
	
	if is_instance_valid(soundwaves_doodle):
		soundwaves_doodle.queue_free()
		
	end_beat()
