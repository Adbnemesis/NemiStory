class_name Ep02Beat03OnlineCollege
extends "res://nemi/episodes/ep02_partner/beats/Ep02BaseBeat.gd"

## Beat 3: College / COVID Online (9.84s – 20.35s | 10.51s)
## Segments: 005 ("We actually met during college..."), 006 ("So basically... everything happened online.")
## Staging: Illustrated video-call window appears, Nemi and ADB in separate frames, Wi-Fi blinking, laptop typing burst.

const PropVideoCallWindowClass = preload("res://nemi/episodes/ep02_partner/props/PropVideoCallWindow.gd")

var call_window: Node2D

func _run_beat_choreography() -> void:
	beat_number = 3
	beat_name = "College / COVID Online"
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
		
	nemi.position = Vector2(480, 500)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("smiling")
	nemi.look("center")
	
	# Spawn Cozy Desk Doodle to Nemi's left
	var desk_doodle := Ep02DoodlesClass.spawn_desk_setup(self, Vector2(280, 460), 0.35)
	
	# Spawn VideoCallWindow to the right
	call_window = PropVideoCallWindowClass.new()
	call_window.position = Vector2(780, 270)
	call_window.scale = Vector2(0.1, 0.1)
	add_child(call_window)
	
	var tw_win := create_tween()
	tw_win.tween_property(call_window, "scale", Vector2(1.25, 1.25), 0.40).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# SEGMENT 005 (4.88s + 0.35s pause = 5.23s)
	# "We actually met during college, right in the middle of the COVID lockdown."
	play_segment("005")
	nemi.gesture_open_palm("right", 0.25)
	await wait_seconds(2.30) # "We actually met during college,"
	
	# On "right in the middle of the COVID lockdown." -> Nemi points to call window
	nemi.point("right")
	nemi.head_tilt(-6.0, 0.20)
	nemi.set_expression("skeptical")
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.12, 0.15)
		
	await wait_seconds(2.58) # "right in the middle of the COVID lockdown."
	await wait_seconds(0.35) # Pause
	
	# SEGMENT 006 (4.88s + 0.40s pause = 5.28s)
	# "So basically... everything happened online."
	play_segment("006")
	nemi.look("center")
	await wait_seconds(1.90) # "So basically..."
	
	# Comedic shrug directly to viewer
	nemi.shrug(0.25)
	nemi.set_expression("comedic")
	nemi.head_tilt(8.0, 0.20)
	
	await wait_seconds(2.98) # "everything happened online."
	await wait_seconds(0.40) # Pause
	
	if is_instance_valid(call_window):
		var tw_out := create_tween()
		tw_out.tween_property(call_window, "scale", Vector2.ZERO, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw_out.tween_callback(call_window.queue_free)
		
	if is_instance_valid(desk_doodle):
		var tw_desk := create_tween()
		tw_desk.tween_property(desk_doodle, "modulate:a", 0.0, 0.25)
		tw_desk.tween_callback(desk_doodle.queue_free)
		
	end_beat()
