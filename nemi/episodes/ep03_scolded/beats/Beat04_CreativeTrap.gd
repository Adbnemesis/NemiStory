class_name Ep03Beat04CreativeTrap
extends "res://nemi/episodes/ep03_scolded/Ep03BaseBeat.gd"

## Beat 4: The Creative Trap (33.43s – 42.75s | Duration: 9.32s)
## Segments:
## - 008: "At one fifty-five, I sat down at my tablet to fix just one single animation line." (4.40s + 0.40s)
## - 009: "I blinked twice... and suddenly it was five forty-five." (3.92s + 0.60s)

var spinning_clock: Node2D

func _init() -> void:
	beat_number = 4
	beat_name = "The Creative Trap"

func _run_beat_choreography() -> void:
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
		
	nemi.position = Vector2(480, 480)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("talking")
	nemi.look("center")
	
	# SEGMENT 008 (4.40s + 0.40s = 4.80s)
	play_segment("008")
	# Lean into drawing focus
	var tw := create_tween()
	tw.tween_property(nemi, "position:y", 495.0, 0.25)
	nemi.set_expression("curious")
	
	await wait_seconds(4.40)
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 009 (3.92s + 0.60s = 4.52s)
	# "I blinked twice... and suddenly it was five forty-five."
	play_segment("009")
	nemi.blink(0.08)
	await wait_seconds(0.4)
	nemi.blink(0.08)
	
	# Spinning time-skip clock doodle appears
	spinning_clock = Ep03DoodlesClass.spawn_spinning_clock(self, Vector2(850, 320), 0.35)
	
	await wait_seconds(1.2)
	# Shock / horror realization
	nemi.set_expression("shocked")
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.recoil(1.0, false)
		
	await wait_seconds(2.32)
	await wait_seconds(0.60) # Pause hold
	
	if is_instance_valid(spinning_clock):
		var tw_fade := create_tween()
		tw_fade.tween_property(spinning_clock, "modulate:a", 0.0, 0.25)
		tw_fade.tween_callback(spinning_clock.queue_free)
		
	end_beat()
