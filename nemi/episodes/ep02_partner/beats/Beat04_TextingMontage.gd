class_name Ep02Beat04TextingMontage
extends "res://nemi/episodes/ep02_partner/beats/Ep02BaseBeat.gd"

## Beat 4: The Texting Montage (20.35s – 29.49s | 9.14s)
## Segments: 007 ("And for two to three months? We just texted. Constantly."), 008 ("Messages all day...")
## Staging: Phone prop, dark ink chat bubbles pinging rapidly, calendar flipping, 3 AM clock, sheepish laugh.

const PropPhoneClass = preload("res://nemi/world/props/PropPhone.gd")

var phone_prop: Node2D
var active_doodle_list: Array[Node2D] = []

func _run_beat_choreography() -> void:
	beat_number = 4
	beat_name = "The Texting Montage"
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
		
	nemi.position = Vector2(500, 500)
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("smiling")
	
	if adb:
		adb.position = Vector2(820, 356)
		adb.set_pose("phone_texting", 0.0)
		adb.set_expression("smug", 0.0)
		adb.look("phone")
		
	# Phone prop
	phone_prop = PropPhoneClass.new()
	phone_prop.position = Vector2(535, 330)
	phone_prop.scale = Vector2(1.2, 1.2)
	add_child(phone_prop)
	
	# SEGMENT 007 (5.12s + 0.40s pause = 5.52s)
	# "And for two to three months? We just texted. Constantly."
	play_segment("007")
	
	# Calendar page doodle flips on "two to three months"
	var cal := Ep02DoodlesClass.spawn_calendar(self, Vector2(340, 230), "M1-3", 0.30)
	active_doodle_list.append(cal)
	
	await wait_seconds(2.40) # "And for two to three months?"
	
	# On "We just texted." -> First chat bubble
	var bubble1 := Ep02DoodlesClass.spawn_chat_bubble(self, Vector2(640, 210), "hey", true, 0.20)
	active_doodle_list.append(bubble1)
	
	await wait_seconds(1.32) # "We just texted."
	
	# On "Constantly." -> Second chat bubble from ADB
	var bubble2 := Ep02DoodlesClass.spawn_chat_bubble(self, Vector2(720, 160), "lol", false, 0.20)
	active_doodle_list.append(bubble2)
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.15, 0.15)
		
	await wait_seconds(1.40) # "Constantly."
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 008 (3.12s + 0.50s pause = 3.62s)
	# "Messages all day... and random memes until three in the morning."
	play_segment("008")
	
	# Rapid third chat bubble
	var bubble3 := Ep02DoodlesClass.spawn_chat_bubble(self, Vector2(620, 120), "meme", true, 0.18)
	active_doodle_list.append(bubble3)
	
	await wait_seconds(1.10) # "Messages all day..."
	
	# Spinning 3 AM Analog Clock doodle appears on "three in the morning"
	var clock_doodle := Ep02DoodlesClass.spawn_3am_clock(self, Vector2(760, 210), 0.30)
	active_doodle_list.append(clock_doodle)
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.12, 0.15)
		
	nemi.gesture_self(0.20)
	nemi.set_expression("laughing")
	if adb:
		adb.set_expression("amused", 0.20)
		adb.head_tilt_to(-5.0, 0.20)
		
	await wait_seconds(2.02) # "and random memes until three in the morning."
	await wait_seconds(0.50) # Pause hold
	
	# Clean up props & doodles
	for d in active_doodle_list:
		if is_instance_valid(d):
			d.queue_free()
	if is_instance_valid(phone_prop):
		phone_prop.queue_free()
		
	end_beat()
