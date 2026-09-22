class_name Ep03Beat01Hook
extends "res://nemi/episodes/ep03_scolded/Ep03BaseBeat.gd"

## Beat 1: The Hook (0.00s – 13.67s | Duration: 13.67s)
## Segments: 
## - 001: "My mom has scolded me many times in my life." (5.84s + 0.35s)
## - 002: "Most of them were completely unfair." (2.16s + 0.40s)
## - 003: "...Except this one. This one was entirely deserved." (4.32s + 0.60s)

var gavel_doodle: Node2D

func _init() -> void:
	beat_number = 1
	beat_name = "The Hook"

func _run_beat_choreography() -> void:
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
		
	nemi.position = Vector2(640, 480)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")
	
	# SEGMENT 001 (5.84s + 0.35s = 6.19s)
	await wait_seconds(0.12)
	nemi.blink(0.12)
	play_segment("001")
	
	# Subtle conversational head tilt & hand gesture
	nemi.head_tilt(5.0, 0.25)
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.lean(4.0, 0.30)
		
	await wait_seconds(3.0)
	nemi.blink(0.10)
	await wait_seconds(2.84)
	await wait_seconds(0.35) # Pause
	
	# SEGMENT 002 (2.16s + 0.40s = 2.56s)
	# "Most of them were completely unfair."
	play_segment("002")
	nemi.set_expression("skeptical")
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.shrug(1.0, 0.25)
		
	await wait_seconds(2.16)
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 003 (4.32s + 0.60s = 4.92s)
	# "...Except this one. This one was entirely deserved."
	# Conspiratorial forward lean & camera subtle punch
	var tw_lean := create_tween().set_parallel(true)
	tw_lean.tween_property(nemi, "position:y", 350.0, 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.15, 0.20)
		
	nemi.set_expression("whisper")
	play_segment("003")
	await wait_seconds(1.80) # "...Except this one."
	
	# Gavel stamp doodle slams down
	gavel_doodle = Ep03DoodlesClass.spawn_gavel_stamp(self, Vector2(810, 260), 0.25)
	nemi.set_expression("deadpan")
	nemi.look("camera")
	
	await wait_seconds(2.52) # "This one was entirely deserved."
	await wait_seconds(0.60) # Pause hold
	
	if is_instance_valid(gavel_doodle):
		var tw_fade := create_tween()
		tw_fade.tween_property(gavel_doodle, "modulate:a", 0.0, 0.25)
		tw_fade.tween_callback(gavel_doodle.queue_free)
		
	end_beat()
