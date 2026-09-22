class_name Ep03Beat08TheScolding
extends "res://nemi/episodes/ep03_scolded/Ep03BaseBeat.gd"

## Beat 8: The Maternal Radar & The Scolding (81.85s – 98.21s | Duration: 16.36s)
## Segments:
## - 018: "Right as the hairdryer hit maximum blast... the kitchen door swung open." (5.92s + 0.40s)
## - 019: "My mom stood there. Just looking at me." (2.40s + 1.20s)
## - 020: "Then she said: 'You have a college degree, and you are blow-drying raw meat.'" (5.84s + 0.60s)

@onready var chicken_prop = get_node_or_null("PropChicken")
@onready var hairdryer_prop = get_node_or_null("PropHairdryer")
var radar_doodle: Node2D

func _init() -> void:
	beat_number = 8
	beat_name = "The Maternal Radar & The Scolding"

func _run_beat_choreography() -> void:
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.WIDE, 0.0)
		
	nemi.position = Vector2(400, 480)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("shocked")
	nemi.look("right")
	
	if hairdryer_prop:
		hairdryer_prop.position = Vector2(520, 430)
		hairdryer_prop.current_state = "blast"
		
	if chicken_prop:
		chicken_prop.position = Vector2(620, 470)
		chicken_prop.set_prop_state("defrost_fail")
		
	if mom:
		mom.position = Vector2(920, 490)
		mom.set_pose("silent_stare", 0.0)
		mom.visible = false
		
	# SEGMENT 018 (5.92s + 0.40s = 6.32s)
	play_segment("018")
	await wait_seconds(3.5) # "Right as the hairdryer hit maximum blast..."
	
	# Door swings open: hairdryer cuts off, Mom appears
	if hairdryer_prop:
		hairdryer_prop.current_state = "off"
		
	if mom:
		mom.visible = true
		mom.set_pose("silent_stare", 0.15)
		
	nemi.set_expression("shocked")
	await wait_seconds(2.42)
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 019 (2.40s + 1.20s = 3.60s)
	# "My mom stood there. Just looking at me."
	play_segment("019")
	# Maternal radar targets hairdryer
	radar_doodle = Ep03DoodlesClass.spawn_target_reticle(self, Vector2(520, 430), 0.25)
	
	await wait_seconds(2.40)
	
	# Complete deadpan silence hold for 1.2s
	await wait_seconds(1.20)
	
	# SEGMENT 020 (5.84s + 0.60s = 6.44s)
	# "Then she said: 'You have a college degree, and you are blow-drying raw meat.'"
	play_segment("020")
	if mom:
		mom.set_pose("scolding_wag", 0.20)
		
	await wait_seconds(2.0)
	# Nemi slumps into defeated posture
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.slouch(1.0, 0.35)
	nemi.set_expression("embarrassed")
	nemi.look("center")
	
	await wait_seconds(3.84)
	await wait_seconds(0.60) # Pause hold
	
	if is_instance_valid(radar_doodle):
		radar_doodle.queue_free()
		
	end_beat()
