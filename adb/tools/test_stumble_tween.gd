extends SceneTree

func _init() -> void:
	var adb_scene = load("res://adb/characters/adb/ADB.tscn")
	var adb = adb_scene.instantiate()
	root.add_child(adb)
	adb.position = Vector2(400, 400)
	adb.set_pose("explaining", 0.0)
	
	for i in range(5):
		await process_frame
		
	# Now trigger stumble_pushed with 0.12s
	adb.set_pose("stumble_pushed", 0.12)
	
	# Step a few frames (e.g. 2 frames at 30fps is ~0.066s)
	for i in range(3):
		await process_frame
		
	var img = root.get_texture().get_image()
	img.save_png("res://adb/renders/test_stumble_mid_tween.png")
	print("Saved test_stumble_mid_tween.png")
	quit(0)
