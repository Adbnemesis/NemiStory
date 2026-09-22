class_name Ep02Beat07ADBAnime
extends "res://nemi/episodes/ep02_partner/beats/Ep02BaseBeat.gd"

## Beat 7: ADB is Cute & Loves Anime (48.34s – 64.95s | 16.61s)
## Segments: 013 ("Look, ADB is really cute..."), 014 ("And ADB is completely obsessed with anime."), 015 ("Which means...")
## Staging: Nemi praises ADB, ADB is flustered with cute cheek blush, manga burst doodles explode around ADB, synchronized nodding.

var manga_doodle: Node2D

func _run_beat_choreography() -> void:
	beat_number = 7
	beat_name = "ADB is Cute & Loves Anime"
	
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.20)
		
	nemi.position = Vector2(470, 500)
	nemi.set_pose("neutral", 0.0)
	nemi.set_expression("smiling")
	
	if adb:
		adb.position = Vector2(790, 356)
		adb.set_pose("cool_swagger", 0.0)
		adb.set_expression("neutral", 0.0)
		adb.look("camera")
		
	# SEGMENT 013 (7.36s + 0.40s pause = 7.76s)
	# "Look, ADB is really cute. Like, ridiculously cute."
	play_segment("013")
	nemi.gesture_open_palm("right", 0.25)
	nemi.set_expression("happy")
	await wait_seconds(3.40) # "Look, ADB is really cute."
	
	# ADB gets caught off guard -> bashful blush, pulls goggles over eyes!
	if adb:
		adb.set_expression("embarrassed", 0.20)
		adb.set_goggles_on_eyes(true)
		adb.head_tilt_to(6.0, 0.20)
		adb.blink(0.12)
		
	await wait_seconds(3.96) # "Like, ridiculously cute."
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 014 (4.88s + 0.40s pause = 5.28s)
	# "And ADB is completely obsessed with anime."
	play_segment("014")
	
	# ADB snaps into anime hero pose with glowing goggles!
	if adb:
		adb.set_goggles_on_eyes(false)
		adb.set_pose("anime_hero", 0.20)
		adb.set_expression("excited", 0.20)
		adb.head_tilt_to(-4.0, 0.18)
		manga_doodle = Ep02DoodlesClass.spawn_anime_katana_aura(self, adb.position + Vector2(0, -60), 0.35)
		
	if camera and camera.has_method("subtle_punch"):
		camera.subtle_punch(1.18, 0.18)
		
	await wait_seconds(4.88)
	await wait_seconds(0.40) # Pause
	
	# SEGMENT 015 (3.12s + 0.45s pause = 3.57s)
	# "Which means we can talk about storylines for hours."
	play_segment("015")
	nemi.set_expression("excited")
	
	# Both nod enthusiastically in synchronized anime joy
	var tw_nod := create_tween().set_parallel(true).set_loops(3)
	tw_nod.tween_property(nemi, "position:y", 492.0, 0.15)
	tw_nod.tween_property(nemi, "position:y", 500.0, 0.15)
	if adb:
		tw_nod.tween_property(adb, "position:y", 348.0, 0.15)
		tw_nod.tween_property(adb, "position:y", 356.0, 0.15)
		
	await wait_seconds(3.12)
	await wait_seconds(0.45) # Pause hold
	
	if is_instance_valid(manga_doodle):
		manga_doodle.queue_free()
		
	end_beat()
