class_name Ep03Beat02ThePlan
extends "res://nemi/episodes/ep03_scolded/Ep03BaseBeat.gd"

## Beat 2: The Golden Rule (13.67s – 22.34s | Duration: 8.67s)
## Segments:
## - 004: "Mom left the house around ten in the morning with one simple rule." (4.08s + 0.35s)
## - 005: "Take the chicken out of the freezer at two PM so it can defrost for dinner." (3.84s + 0.40s)

var sticky_note: Node2D

func _init() -> void:
	beat_number = 2
	beat_name = "The Plan"

func _run_beat_choreography() -> void:
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.WIDE, 0.0)
		
	nemi.position = Vector2(400, 480)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("talking")
	nemi.look("right")
	
	if mom:
		mom.position = Vector2(900, 490)
		mom.set_pose("departure", 0.0)
		
	# SEGMENT 004 (4.08s + 0.35s = 4.43s)
	play_segment("004")
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.point("right", "fast", true)
		
	await wait_seconds(2.0)
	nemi.blink(0.12)
	await wait_seconds(2.08)
	await wait_seconds(0.35) # Pause
	
	# SEGMENT 005 (3.84s + 0.40s = 4.24s)
	# "Take the chicken out of the freezer at two PM so it can defrost for dinner."
	play_segment("005")
	nemi.set_expression("neutral")
	
	# Floating handwritten sticky note pops up
	sticky_note = Ep03DoodlesClass.spawn_sticky_note(self, Vector2(650, 240), 0.28)
	
	await wait_seconds(3.84)
	await wait_seconds(0.40) # Pause hold
	
	if is_instance_valid(sticky_note):
		var tw_fade := create_tween()
		tw_fade.tween_property(sticky_note, "modulate:a", 0.0, 0.25)
		tw_fade.tween_callback(sticky_note.queue_free)
		
	end_beat()
