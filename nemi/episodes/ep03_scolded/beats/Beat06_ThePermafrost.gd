class_name Ep03Beat06ThePermafrost
extends "res://nemi/episodes/ep03_scolded/Ep03BaseBeat.gd"

## Beat 6: The Arctic Permafrost (51.35s – 63.08s | Duration: 11.73s)
## Segments:
## - 012: "I sprinted to the freezer. The chicken was not defrosting." (4.08s + 0.35s)
## - 013: "It was an indestructible block of Arctic permafrost." (4.08s + 0.40s)
## - 014: "You could have built a house out of this poultry." (2.32s + 0.50s)

@onready var chicken_prop = get_node_or_null("PropChicken")
var gauge_doodle: Node2D

func _init() -> void:
	beat_number = 6
	beat_name = "The Arctic Permafrost"

func _run_beat_choreography() -> void:
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
		
	nemi.position = Vector2(440, 480)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("nervous")
	nemi.look("right")
	
	if chicken_prop:
		chicken_prop.position = Vector2(740, 470)
		chicken_prop.set_prop_state("frozen")
		
	# SEGMENT 012 (4.08s + 0.35s = 4.43s)
	play_segment("012")
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.point("right", "fast", false)
		
	await wait_seconds(4.08)
	await wait_seconds(0.35) # Pause
	
	# SEGMENT 013 (4.08s + 0.40s = 4.48s)
	# "It was an indestructible block of Arctic permafrost."
	play_segment("013")
	nemi.set_expression("deadpan")
	# Permafrost gauge doodle
	gauge_doodle = Ep03DoodlesClass.spawn_permafrost_gauge(self, Vector2(900, 320), 0.30)
	
	# Tap the chicken
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.lean(8.0, 0.20)
	await wait_seconds(4.08)
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 014 (2.32s + 0.50s = 2.82s)
	# "You could have built a house out of this poultry."
	play_segment("014")
	if nemi.actor and nemi.actor.body:
		nemi.actor.body.shrug(1.0, 0.25)
	nemi.look("camera")
	
	await wait_seconds(2.32)
	await wait_seconds(0.50) # Pause hold
	
	if is_instance_valid(gauge_doodle):
		var tw_fade := create_tween()
		tw_fade.tween_property(gauge_doodle, "modulate:a", 0.0, 0.25)
		tw_fade.tween_callback(gauge_doodle.queue_free)
		
	end_beat()
