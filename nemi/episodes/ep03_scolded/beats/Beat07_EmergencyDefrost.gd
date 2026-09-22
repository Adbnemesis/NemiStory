class_name Ep03Beat07EmergencyDefrost
extends "res://nemi/episodes/ep03_scolded/Ep03BaseBeat.gd"

## Beat 7: The Emergency Defrost Protocol (63.08s – 81.85s | Duration: 18.77s)
## Segments:
## - 015: "I initiated emergency defrost protocol. Hot water bath: complete failure." (7.36s + 0.35s)
## - 016: "Microwave defrost turned one corner into rubber while the center stayed ice." (5.84s + 0.40s)
## - 017: "So naturally... I grabbed my hairdryer and put it on maximum heat." (4.32s + 0.50s)

@onready var chicken_prop = get_node_or_null("PropChicken")
@onready var hairdryer_prop = get_node_or_null("PropHairdryer")
var sparks_doodle: Node2D

func _init() -> void:
	beat_number = 7
	beat_name = "The Emergency Defrost Protocol"

func _run_beat_choreography() -> void:
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
		
	nemi.position = Vector2(460, 480)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("talking")
	nemi.look("right")
	
	if chicken_prop:
		chicken_prop.position = Vector2(800, 470)
		chicken_prop.set_prop_state("frozen")
		
	if hairdryer_prop:
		hairdryer_prop.position = Vector2(620, 430)
		hairdryer_prop.visible = false
		
	# SEGMENT 015 (7.36s + 0.35s = 7.71s)
	play_segment("015")
	# Counting off attempts on fingers
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.lean(6.0, 0.25)
	await wait_seconds(3.5)
	nemi.set_expression("annoyed")
	await wait_seconds(3.86)
	await wait_seconds(0.35) # Pause
	
	# SEGMENT 016 (5.84s + 0.40s = 6.24s)
	# "Microwave defrost turned one corner into rubber while the center stayed ice."
	play_segment("016")
	# Microwave sparks doodle
	sparks_doodle = Ep03DoodlesClass.spawn_microwave_sparks(self, Vector2(800, 360), 0.25)
	if chicken_prop:
		chicken_prop.set_prop_state("defrost_fail")
		
	nemi.set_expression("confused")
	await wait_seconds(5.84)
	await wait_seconds(0.40) # Pause
	
	if is_instance_valid(sparks_doodle):
		sparks_doodle.queue_free()
		
	# SEGMENT 017 (4.32s + 0.50s = 4.82s)
	# "So naturally... I grabbed my hairdryer and put it on maximum heat."
	play_segment("017")
	nemi.set_expression("excited")
	
	# Brandish hairdryer
	if hairdryer_prop:
		hairdryer_prop.visible = true
		hairdryer_prop.scale = Vector2.ONE
		hairdryer_prop.current_state = "blast"
		
	# Screen subtle vibration under hairdryer blast
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.point("right", "fast", false)
		
	await wait_seconds(4.32)
	await wait_seconds(0.50) # Pause hold
	
	end_beat()
	await wait_seconds(1.4)
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.lean(5.0, 0.22)
	await wait_seconds(1.22)
	await wait_seconds(0.50) # Pause hold
	
	end_beat()
