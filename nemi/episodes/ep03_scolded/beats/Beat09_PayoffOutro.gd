class_name Ep03Beat09PayoffOutro
extends "res://nemi/episodes/ep03_scolded/Ep03BaseBeat.gd"

## Beat 9: The Payoff & Cereal Dinner (98.21s – 110.89s | Duration: 12.68s)
## Segments:
## - 021: "I didn't even try to defend myself. There was zero scientific rebuttal." (5.60s + 0.40s)
## - 022: "We ate cold cereal for dinner in complete silence." (2.96s + 0.50s)
## - 023: "And I have officially been banned from the freezer." (2.72s + 1.00s)

var cereal_doodle: Node2D

func _init() -> void:
	beat_number = 9
	beat_name = "The Payoff & Cereal Dinner"

func _run_beat_choreography() -> void:
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
		
	nemi.position = Vector2(640, 480)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("embarrassed")
	nemi.look("center")
	
	# SEGMENT 021 (5.60s + 0.40s = 6.00s)
	play_segment("021")
	# Hands open in total surrender
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.shrug(0.8, 0.3)
	await wait_seconds(3.0)
	nemi.blink(0.12)
	await wait_seconds(2.60)
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 022 (2.96s + 0.50s = 3.46s)
	# "We ate cold cereal for dinner in complete silence."
	play_segment("022")
	nemi.set_expression("deadpan")
	# Cereal bowl doodle
	cereal_doodle = Ep03DoodlesClass.spawn_cereal_payoff(self, Vector2(640, 520), 0.30)
	
	await wait_seconds(2.96)
	await wait_seconds(0.50) # Pause
	
	# SEGMENT 023 (2.72s + 1.00s = 3.72s)
	# "And I have officially been banned from the freezer."
	play_segment("023")
	nemi.look("camera")
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.12, 0.20)
		
	await wait_seconds(1.5)
	# Tiny solemn nod
	if nemi.actor and nemi.actor.head:
		nemi.actor.head.nod(0.8, 1)
		
	await wait_seconds(1.22)
	
	# Final quiet stillness hold for 1.0s before gentle fade
	await wait_seconds(1.00)
	
	end_beat()
	# Final quiet stillness hold for 1.0s before end
	await wait_seconds(1.00)
	
	if is_instance_valid(cereal_doodle):
		var tw_fade := create_tween()
		tw_fade.tween_property(cereal_doodle, "modulate:a", 0.0, 0.3)
		tw_fade.tween_callback(cereal_doodle.queue_free)
		
	end_beat()
